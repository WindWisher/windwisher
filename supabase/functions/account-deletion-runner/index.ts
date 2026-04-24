import { createClient } from "jsr:@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";
import { jsonResponse } from "../_shared/http.ts";

type AccountDeletionRow = {
  id: string;
  user_id: string;
  execute_after: string | null;
  confirmed_at: string | null;
  created_at: string;
};

const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const runnerSecret = Deno.env.get("ACCOUNT_DELETION_RUNNER_SECRET") ?? "";
const batchSize = resolveBatchSize(
  Deno.env.get("ACCOUNT_DELETION_RUNNER_BATCH_SIZE"),
);

const supabase = createClient(supabaseUrl, serviceRoleKey, {
  auth: { persistSession: false, autoRefreshToken: false },
});

Deno.serve(async (request) => {
  try {
    if (request.method === "OPTIONS") {
      return new Response("ok", { headers: corsHeaders });
    }
    if (request.method !== "POST") {
      return jsonResponse({ error: "method-not-allowed" }, { status: 405 });
    }
    if (!supabaseUrl || !serviceRoleKey) {
      return jsonResponse(
        { error: "missing-supabase-service-role-config" },
        { status: 500 },
      );
    }
    if (!runnerSecret) {
      return jsonResponse(
        { error: "missing-account-deletion-runner-secret" },
        { status: 500 },
      );
    }
    if (
      (request.headers.get("authorization") ?? "") !== `Bearer ${runnerSecret}`
    ) {
      return jsonResponse({ error: "unauthorized" }, { status: 401 });
    }

    const dueRows = await loadDueAccountDeletionRows();
    let deleted = 0;
    let failed = 0;
    let skipped = 0;
    const diagnostics: Record<string, unknown>[] = [];

    for (const row of dueRows) {
      if (!row.confirmed_at || !row.execute_after) {
        skipped += 1;
        await insertAuditRow({
          requestId: row.id,
          userId: row.user_id,
          status: "skipped_invalid_row",
          executeAfter: row.execute_after,
          confirmedAt: row.confirmed_at,
          errorMessage: null,
        });
        diagnostics.push({
          requestId: row.id,
          userId: row.user_id,
          status: "skipped-invalid-row",
          confirmedAt: row.confirmed_at,
          executeAfter: row.execute_after,
        });
        continue;
      }

      const { error } = await supabase.auth.admin.deleteUser(row.user_id);
      if (error != null) {
        failed += 1;
        await insertAuditRow({
          requestId: row.id,
          userId: row.user_id,
          status: "delete_failed",
          executeAfter: row.execute_after,
          confirmedAt: row.confirmed_at,
          errorMessage: error.message,
        });
        diagnostics.push({
          requestId: row.id,
          userId: row.user_id,
          status: "delete-failed",
          executeAfter: row.execute_after,
          error: error.message,
        });
        continue;
      }

      deleted += 1;
      await insertAuditRow({
        requestId: row.id,
        userId: row.user_id,
        status: "deleted",
        executeAfter: row.execute_after,
        confirmedAt: row.confirmed_at,
        errorMessage: null,
      });
      diagnostics.push({
        requestId: row.id,
        userId: row.user_id,
        status: "deleted",
        executeAfter: row.execute_after,
      });
    }

    return jsonResponse({
      ok: failed == 0,
      due: dueRows.length,
      deleted,
      failed,
      skipped,
      batchSize,
      diagnostics,
    });
  } catch (error) {
    return jsonResponse(
      {
        ok: false,
        error: error instanceof Error ? error.message : "unknown-runner-error",
      },
      { status: 500 },
    );
  }
});

async function loadDueAccountDeletionRows(): Promise<AccountDeletionRow[]> {
  const nowIso = new Date().toISOString();
  const { data, error } = await supabase
    .from("account_deletion_requests")
    .select("id,user_id,execute_after,confirmed_at,created_at")
    .eq("status", "scheduled")
    .not("confirmed_at", "is", null)
    .not("execute_after", "is", null)
    .lte("execute_after", nowIso)
    .order("execute_after", { ascending: true });

  if (error != null) {
    throw error;
  }

  return ((data ?? []) as AccountDeletionRow[]).slice(0, batchSize);
}

function resolveBatchSize(value: string | undefined): number {
  const parsed = Number.parseInt(value ?? "", 10);
  if (!Number.isFinite(parsed) || parsed <= 0) {
    return 10;
  }
  return Math.min(parsed, 100);
}

async function insertAuditRow(input: {
  requestId: string;
  userId: string;
  status: "deleted" | "delete_failed" | "skipped_invalid_row";
  executeAfter: string | null;
  confirmedAt: string | null;
  errorMessage: string | null;
}): Promise<void> {
  const { error } = await supabase.from("account_deletion_audit").insert({
    request_id: input.requestId,
    user_id: input.userId,
    status: input.status,
    scheduled_execute_after: input.executeAfter,
    confirmed_at: input.confirmedAt,
    error_message: input.errorMessage,
  });

  if (error != null) {
    throw error;
  }
}
