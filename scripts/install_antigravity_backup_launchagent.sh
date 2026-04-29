#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_SCRIPT="${REPO_ROOT}/scripts/backup_antigravity_conversations.sh"
LAUNCH_AGENTS_DIR="${HOME}/Library/LaunchAgents"
PLIST_PATH="${LAUNCH_AGENTS_DIR}/com.raulmartinez.antigravity-conversations-backup.plist"

mkdir -p "${LAUNCH_AGENTS_DIR}"

cat > "${PLIST_PATH}" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.raulmartinez.antigravity-conversations-backup</string>

  <key>ProgramArguments</key>
  <array>
    <string>${BACKUP_SCRIPT}</string>
  </array>

  <key>RunAtLoad</key>
  <true/>

  <key>StartInterval</key>
  <integer>1800</integer>

  <key>StandardOutPath</key>
  <string>${HOME}/Library/Logs/antigravity-conversations-backup.log</string>

  <key>StandardErrorPath</key>
  <string>${HOME}/Library/Logs/antigravity-conversations-backup.log</string>
</dict>
</plist>
PLIST

launchctl unload "${PLIST_PATH}" >/dev/null 2>&1 || true
launchctl load "${PLIST_PATH}"

echo "Installed launch agent: ${PLIST_PATH}"
echo "Backup script: ${BACKUP_SCRIPT}"
echo "Schedule: every 30 minutes and at login"
