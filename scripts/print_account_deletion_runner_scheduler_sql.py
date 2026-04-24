#!/usr/bin/env python3
"""Print ready-to-run SQL for scheduling the account deletion runner."""

from __future__ import annotations

import json
from pathlib import Path
import sys


def main() -> int:
    root = Path(__file__).resolve().parents[1]
    env_path = root / "local.env.json"
    if not env_path.exists():
        print("local.env.json not found", file=sys.stderr)
        return 1

    env = json.loads(env_path.read_text())
    project_url = env.get("SUPABASE_URL")
    runner_secret = env.get("ACCOUNT_DELETION_RUNNER_SECRET")

    if not project_url or not runner_secret:
        print(
            "SUPABASE_URL or ACCOUNT_DELETION_RUNNER_SECRET missing in local.env.json",
            file=sys.stderr,
        )
        return 1

    sql = f"""-- Paste this into the Supabase SQL Editor once per environment.
select vault.create_secret('{project_url}', 'account_deletion_runner_project_url')
on conflict do nothing;

select vault.create_secret('{runner_secret}', 'account_deletion_runner_secret')
on conflict do nothing;

select cron.unschedule('account-deletion-runner-every-15-min');

select
  cron.schedule(
    'account-deletion-runner-every-15-min',
    '*/15 * * * *',
    $$
    select
      net.http_post(
        url := (
          select decrypted_secret
          from vault.decrypted_secrets
          where name = 'account_deletion_runner_project_url'
        ) || '/functions/v1/account-deletion-runner',
        headers := jsonb_build_object(
          'Content-Type', 'application/json',
          'Authorization', 'Bearer ' || (
            select decrypted_secret
            from vault.decrypted_secrets
            where name = 'account_deletion_runner_secret'
          )
        ),
        body := '{{}}'::jsonb
      );
    $$
  );
"""
    print(sql)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
