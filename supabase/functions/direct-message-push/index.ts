import { createClient } from "jsr:@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";
import { jsonResponse, readJson } from "../_shared/http.ts";

type DirectMessagePushRequest = {
  messageId?: string;
};

type DirectMessagePushTargetRow = {
  message_id: string;
  thread_id: string;
  recipient_user_id: string;
  device_token: string;
  platform: string;
  provider: string;
  sender_user_id: string;
  sender_display_name: string;
  sender_handle: string;
  message_body: string;
  attachment_type: string;
};

type FirebaseServiceAccount = {
  project_id: string;
  client_email: string;
  private_key: string;
};

const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
const anonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
const firebaseServiceAccountJson =
  Deno.env.get("FIREBASE_SERVICE_ACCOUNT_JSON") ?? "";

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (request.method !== "POST") {
    return jsonResponse({ error: "method-not-allowed" }, { status: 405 });
  }
  if (!supabaseUrl || !anonKey) {
    return jsonResponse({ error: "missing-supabase-config" }, { status: 500 });
  }

  const authorization = request.headers.get("Authorization") ?? "";
  if (!authorization.trim()) {
    return jsonResponse({ error: "missing-authorization" }, { status: 401 });
  }

  const supabase = createClient(supabaseUrl, anonKey, {
    auth: { persistSession: false, autoRefreshToken: false },
    global: {
      headers: {
        Authorization: authorization,
      },
    },
  });

  const {
    data: { user },
    error: userError,
  } = await supabase.auth.getUser();
  if (userError != null || user == null) {
    return jsonResponse({ error: "unauthorized" }, { status: 401 });
  }

  let payload: DirectMessagePushRequest;
  try {
    payload = await readJson<DirectMessagePushRequest>(request);
  } catch (_) {
    return jsonResponse({ error: "invalid-body" }, { status: 400 });
  }

  const messageId = payload.messageId?.trim() ?? "";
  if (!messageId) {
    return jsonResponse({ error: "missing-message-id" }, { status: 400 });
  }

  const { data, error } = await supabase.rpc(
    "get_backend_direct_message_push_targets",
    {
      target_message_id: messageId,
    },
  );
  if (error != null) {
    return jsonResponse(
      { error: "load-push-targets-failed", details: error.message },
      { status: 400 },
    );
  }

  const targets = (data ?? []) as DirectMessagePushTargetRow[];
  if (targets.length === 0) {
    return jsonResponse({ ok: true, sent: 0, failed: 0, reason: "no-targets" });
  }

  const firebase = parseFirebaseServiceAccount(firebaseServiceAccountJson);
  if (firebase == null) {
    return jsonResponse(
      { error: "missing-firebase-service-account-json" },
      { status: 500 },
    );
  }

  const accessToken = await getFirebaseAccessToken(firebase);
  let sent = 0;
  let failed = 0;
  const errors: string[] = [];

  for (const target of targets) {
    if (target.provider !== "fcm") {
      failed += 1;
      errors.push("unsupported-push-provider");
      continue;
    }

    const response = await fetch(
      `https://fcm.googleapis.com/v1/projects/${firebase.project_id}/messages:send`,
      {
        method: "POST",
        headers: {
          authorization: `Bearer ${accessToken}`,
          "content-type": "application/json; charset=utf-8",
        },
        body: JSON.stringify({
          message: {
            token: target.device_token,
            notification: {
              title: target.sender_display_name,
              body: buildPreview(target),
            },
            data: {
              type: "direct_message",
              threadId: target.thread_id,
              messageId: target.message_id,
              senderUserId: target.sender_user_id,
              senderDisplayName: target.sender_display_name,
              senderHandle: target.sender_handle,
              attachmentType: target.attachment_type,
              preview: buildPreview(target),
            },
            android: {
              priority: "high",
              notification: {
                channel_id: "direct_messages_v1",
                sound: "default",
                default_sound: true,
                default_vibrate_timings: true,
                notification_priority: "PRIORITY_HIGH",
              },
            },
            apns: {
              headers: {
                "apns-priority": "10",
                "apns-push-type": "alert",
              },
              payload: {
                aps: {
                  sound: "default",
                  badge: 1,
                },
              },
            },
          },
        }),
      },
    );

    if (response.ok) {
      sent += 1;
      continue;
    }

    failed += 1;
    const responseText = await response.text();
    errors.push(`fcm-${response.status}:${responseText.slice(0, 180)}`);
  }

  return jsonResponse({
    ok: sent > 0,
    senderUserId: user.id,
    sent,
    failed,
    reason: sent > 0
      ? (failed > 0 ? "partial-push-delivery" : "push-delivered")
      : (errors[0] ?? "push-send-failed"),
  });
});

function buildPreview(target: DirectMessagePushTargetRow): string {
  switch (target.attachment_type) {
    case "image":
      return "Te ha enviado una foto.";
    case "video":
      return "Te ha enviado un video.";
    default: {
      const trimmed = target.message_body.trim();
      if (!trimmed) {
        return "Tienes un mensaje nuevo.";
      }
      return trimmed.length > 160 ? `${trimmed.slice(0, 157)}...` : trimmed;
    }
  }
}

function parseFirebaseServiceAccount(
  raw: string,
): FirebaseServiceAccount | null {
  try {
    const parsed = JSON.parse(raw) as Partial<FirebaseServiceAccount>;
    if (
      typeof parsed.project_id !== "string" ||
      typeof parsed.client_email !== "string" ||
      typeof parsed.private_key !== "string" ||
      !parsed.project_id.trim() ||
      !parsed.client_email.trim() ||
      !parsed.private_key.trim()
    ) {
      return null;
    }
    return {
      project_id: parsed.project_id.trim(),
      client_email: parsed.client_email.trim(),
      private_key: parsed.private_key,
    };
  } catch (_) {
    return null;
  }
}

async function getFirebaseAccessToken(
  serviceAccount: FirebaseServiceAccount,
) {
  const now = Math.floor(Date.now() / 1000);
  const header = {
    alg: "RS256",
    typ: "JWT",
  };
  const claimSet = {
    iss: serviceAccount.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  };
  const encodedHeader = base64UrlEncode(JSON.stringify(header));
  const encodedClaimSet = base64UrlEncode(JSON.stringify(claimSet));
  const unsignedJwt = `${encodedHeader}.${encodedClaimSet}`;
  const signature = await signJwt(unsignedJwt, serviceAccount.private_key);
  const assertion = `${unsignedJwt}.${signature}`;

  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: {
      "content-type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion,
    }),
  });
  if (!response.ok) {
    throw new Error(`firebase-token-request-failed:${response.status}`);
  }
  const data = await response.json() as { access_token?: string };
  if (!data.access_token) {
    throw new Error("missing-firebase-access-token");
  }
  return data.access_token;
}

async function signJwt(unsignedJwt: string, privateKeyPem: string) {
  const pemContents = privateKeyPem
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replaceAll(/\s+/g, "");
  const keyBytes = Uint8Array.from(
    atob(pemContents),
    (char) => char.charCodeAt(0),
  );
  const cryptoKey = await crypto.subtle.importKey(
    "pkcs8",
    keyBytes.buffer,
    {
      name: "RSASSA-PKCS1-v1_5",
      hash: "SHA-256",
    },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    cryptoKey,
    new TextEncoder().encode(unsignedJwt),
  );
  return base64UrlEncodeBytes(new Uint8Array(signature));
}

function base64UrlEncode(value: string) {
  return base64UrlEncodeBytes(new TextEncoder().encode(value));
}

function base64UrlEncodeBytes(bytes: Uint8Array) {
  let binary = "";
  for (const byte of bytes) {
    binary += String.fromCharCode(byte);
  }
  return btoa(binary).replaceAll("+", "-").replaceAll("/", "_").replaceAll(
    "=",
    "",
  );
}
