# Private canonical inbox — 2026-09-14

Status: INTERNAL_INBOX_VALIDATED_AUTOMATIC_DEVICE_TRANSPORT_PENDING.
This is an internal local inbox, not automatic Garmin sync or release readiness.

## Boundary

The private inbox is no longer exposed as a manual file-import action in the
user-facing Sessions screen. It remains available to integration tests and the
future device transport. It reads an explicit account identity, but does not
call `saveRecordedSession`, the public sessions adapter, cloud storage, or a
backend endpoint.
Existing public-save behavior is unchanged. Existing app startup/network behavior
is outside this component; this is not a claim that the whole app is offline.

The internal Android ACTION_OPEN_DOCUMENT validator requests a local,
user-selected file. The channel
reads at most 2 MiB. Original canonical bytes are stored under the application's
`noBackupFilesDir/canonical_inbox_v1/accounts/<opaque-account-key>`, not shared
storage. Preserve an external copy: uninstalling/clearing application data
removes this inbox. This is OS-private storage, not an additional encryption
layer. Provider lifecycle and backup behavior still require Android validation.
No broad storage permission was added.
Each signed-in account uses an opaque SHA-256-derived subdirectory under
`canonical_inbox_v1/accounts`; the account identifier is not written as a path
component. Opening the inbox fails closed when there is no authenticated account.
An open production inbox also observes authentication changes; signing out or
switching users clears its visible sessions and disables further imports.
The application router now listens to the same authentication stream and
reevaluates its redirects instead of relying only on manual logout navigation.
Legacy installation-scoped entries remain untouched at the old root and are not
shown or automatically attributed to any account.

## Integrity and limits

- Checked-in Canonical Session v1 schema is byte-identical to the Watch schema.
- Validator supports the fixed schema keyword subset, not arbitrary JSON Schema.
- Current producer's compact JSON field/checksum framing is required; arbitrary
  reserialization or other export formats are not supported.
- Per-record CRC32, stream CRC32, sequence, manifest/completion, counts, private
  visibility, dates and schema are checked before writing.
- CRC/SHA checks are integrity/deduplication checks, not proof of sender identity.
- Strict UTF-8, duplicate-key rejection, maximum JSON depth 32, 16 KiB per line,
  10,000 records, 2 MiB per file, 32 imported sessions, 64 directory entries.
- Exact-byte SHA-256 distinguishes identical retry from same-source-ID conflict.
- Writes use a staging directory, flush, read-back validation, then rename.
  Interrupted staging is retained and ignored; corrupt committed files fail closed
  without erasure. No automatic cleanup, multi-process lock or power-loss guarantee.
- IDs are preserved; no UUID mapping, jump metrics or canonical schema changes.
- The list retains only metadata and hashes in memory; canonical bytes remain on
  disk and are validated again when listing. It does not cache every stream.

## Verification

Focused tests use only synthetic GPS/HR/pressure records produced by the Watch
exporter; no personal capture or environment asset is included.

```
flutter test --no-pub --no-test-assets --reporter expanded test/private_canonical_inbox_test.dart
```

Rechecked 2026-09-15: 9/9 focused inbox tests PASS. These now await asynchronous
failure assertions and include a same-ID/different-valid-payload conflict with
recomputed checksums, account-path opacity and separation between two accounts.
Sessions-page navigation and account-change tests: 7/7 PASS; combined inbox and
broader related test set: 21/21 PASS. The architecture-focused set, including
the router refresh notifier, is 23/23 PASS; the complete Flutter suite is
178/178 PASS. Full `flutter analyze --no-pub`: PASS. The schema is
byte-identical to the Watch contract. The native bridge now finishes a pending
import once if its Activity is destroyed; abnormal Activity recreation during
an in-flight picker/read has not been physically exercised. A physical invalid
file trial exposed a raw English JSON parser error; the validator now returns
a stable Spanish error and the focused test covers it (7/7 PASS after the fix).

An isolated Android debug APK built successfully with Gradle `assembleDebug`
(Kotlin included). Its validation-only entrypoint opens the real inbox page;
the validator, inbox, page, native MainActivity and schema were byte-compared
with this worktree. In the temporary copy, the `local.env.json` asset and
Google Services Gradle plugin were omitted; no existing configuration was
changed. The separate package ID is `com.windwisher.app.inboxvalidation`, so
this APK cannot replace `com.windwisher.app`. APK contents include the schema
and do not include `local.env.json` or `google-services.json`. The artifact and
synthetic valid/invalid files are in ignored `build/validation/private-canonical-inbox/`.
This proves native compilation of the real bridge, not a normal production build
or app startup with the normal configuration. No credentials or original
session files were read. The debug build emitted Java 8 compatibility
warnings from dependencies, but no build errors.

Physical trial 2026-09-14, Xiaomi M2101K7BNY: after the operator enabled USB
installation, `adb install` of the separate validation package passed. The
existing `com.windwisher.app` remained installed. Only two synthetic fixtures
were copied to Downloads. The valid Watch-exporter fixture was selected through
ACTION_OPEN_DOCUMENT; one private session appeared. Its stored SHA-256 matched
the source exactly (`0ad088ea713d7c106ee709cb0dae42145ba70881b6b166300f21001471420be2`).
Selecting it again reported no duplicate and retained one entry. Cancelling a
fresh picker returned to the enabled button with one entry. An invalid synthetic
file was rejected without adding an entry. After `am force-stop` of only the
validation package and relaunch, the entry and hash remained unchanged.
An in-place update of only that package retained the same hash; selecting the
invalid fixture then displayed `Archivo canónico inválido o incompleto.`
In a second validation-only build, the entrypoint opened the real Sessions page
with local session persistence and external-device discovery disabled. On the
same Xiaomi, `Importar sesion real` navigated to the private inbox and displayed
the previously imported synthetic session. The stored SHA-256 still matched
after installing this updated isolated APK. With a picker open, force-stopping
only the validation package and reopening it left the inbox usable and the
synthetic entry intact. This checks forced process interruption and reentry,
not Android Activity recreation during an in-flight file read.
The Xiaomi did not destroy the stopped Activity with the developer setting
`always_finish_activities=1`, even when the isolated app was relaunched under
that setting; it was restored to `0`. A separate, temporary build of the same
isolated package removed only the orientation/screen-size `configChanges`
handling to force recreation while the Android picker was open. After rotating
and cancelling the picker, Flutter returned to the initial Sessions route rather
than the inbox route. Reopening the inbox showed its enabled picker button and
the one synthetic entry; the stored SHA-256 was unchanged. The phone's rotation
settings and the isolated APK's normal manifest were restored afterward. This
is a forced-manifest recovery test, not proof that the production manifest
preserves navigation during unexpected Activity or process recreation.
On 2026-09-15, a temporary isolated build added a five-second pause and a log
marker immediately after the native bridge read its first block. The synthetic
valid file was selected and only `com.windwisher.app.inboxvalidation` was
force-stopped after the marker and before the read could complete. No new or
partial inbox directory appeared. After relaunch, the picker was enabled, the
single previously committed synthetic session remained available and its
SHA-256 was unchanged. The pause and marker were then removed, and the saved
clean isolated APK was reinstalled in place. This verifies recovery from forced
process death during native file reading; it does not exercise Activity-only
recreation at that exact point or a real Watch capture.
On 2026-09-15, the existing authorized private Watch export `session-1.jsonl`
was checked against its previously recorded size, mode and SHA-256 without
printing telemetry. A newly built credential-free APK from the current mobile
worktree imported it through ACTION_OPEN_DOCUMENT on the Xiaomi: 60 canonical
records, 28,038 ms elapsed duration and verified integrity. The private inbox
copy has SHA-256
`83b1e333dddbd353d0b2467a263d0ed8e91988a84a43f54cb7017c4b26c8ab2c`,
exactly matching the preserved host original. Selecting the same file again
reported an existing import and retained one real entry plus the earlier
synthetic entry. The temporary shared-Downloads copy was removed immediately;
the host original was not changed. The current clean isolated APK replaced the
older ignored validation artifact and contains neither `local.env.json` nor
`google-services.json`.
Temporary screenshots used for UI observation were outside the repository and
removed afterward. No private telemetry values were printed.

On 2026-09-15, account isolation was exercised on the Xiaomi with a temporary,
credential-free build of the separate validation package. The device created
two opaque account roots, imported one synthetic canonical session into account
A, reopened both inboxes and reported `ACCOUNT_SCOPE_PASS`: A contained one
session, B contained none, and an identical retry did not add a duplicate. The
two pre-existing installation-scoped imports retained their exact SHA-256 hashes
and remained outside both account roots. The temporary APK contained the schema
and synthetic fixture but neither `local.env.json` nor `google-services.json`.
It was then replaced with a clean isolated Sessions build from the same current
worktree; that APK contains neither credentials nor the synthetic fixture. The
temporary shared Downloads fixture and build copy were removed. The normal
`com.windwisher.app` package was not replaced or opened during this validation.

The clean isolated APK was rebuilt and reinstalled after the final domain-port,
dependency-injection and authentication-change locking changes. On the Xiaomi it
opened the real Sessions surface and exposed `Start Session` and
`Importar sesion real`; both the isolated and normal package remained installed.
The two preserved legacy inbox files retained their exact hashes before and after
installation. APK inspection again found the canonical schema and found neither
`local.env.json`, `google-services.json` nor the synthetic fixture. This Android
build exercises the inbox/DI path; router auth refresh is covered by Flutter tests
and analysis, not by this isolated entrypoint.

On 2026-09-15, a separate Android integration-test package exercised the same
inbox with two temporary, confirmed Supabase users. User A imported one synthetic
canonical session and displayed it. Signing out A and signing in B produced a
different authenticated user ID, immediately locked and cleared A's open inbox,
and B's account-scoped inbox was empty. Signing back into A recovered exactly one
persisted session. The test passed on the Xiaomi. Both temporary users were then
deleted through the admin API and independently returned `404`; the temporary
package, build tree and credential files were also removed.

The Flutter integration runner unexpectedly removed `com.windwisher.app` while
preparing the isolated package because the temporary build retained the normal
Android namespace. The normal debug APK was restored, but Android had already
removed its local sandbox and authentication session, so the operator must sign
in again. The separate `com.windwisher.app.inboxvalidation` package and its prior
evidence remained installed. Future Android integration variants must isolate
both `applicationId` and namespace before execution.

After the operator signed in again, the current worktree was built as the normal
`com.windwisher.app` package from a credential-free temporary source copy. The
build omitted the `local.env.json` asset and used an explicit allowlist containing
only the seven client configuration values consumed by `EnvConfig`; APK checks
confirmed that neither the Supabase service-role key nor the personal access
token was present. `adb install -r` preserved the authenticated preferences file
byte-for-byte before first launch. On the Xiaomi, the authenticated normal app
opened `Session`, displayed `Importar sesion real`, opened the private inbox,
closed it and reopened it successfully. No file was selected and no personal or
synthetic session was changed during this normal-app traversal.

This verifies one real private Watch canonical export, the bounded synthetic
local-import journey, a real A-to-B-to-A authentication transition and an
authenticated open-close-reopen journey in the normal Android app. It does not
verify selecting and importing a canonical file in the normal app, cloud sync,
a cross-device matrix, sensor accuracy or recovery from unexpected Activity
destruction.

## Device transfer flow

The Sessions transfer state machine supports inventory inspection and bounded
canonical downloads. Before writing, the application rejects empty or repeated
opaque IDs, more than 32 sessions, incomplete responses, unexpected IDs and any
mismatch between the device reference and the canonical manifest. Devices
without an implemented transport continue to use the explicitly unsupported
adapter and never expose a fake download action.
The product flow is: detect pending sessions, show `Descargar sesiones`, validate
and persist the canonical bytes in the private account inbox, then expose a
private review with source device, date, duration, summary, format and available
jump count. Closing review keeps the download private; deleting requires a
second confirmation; publishing continues through an explicit `Subir sesion`
action. Generic BLE discovery is not a session transport and must not enable
these actions. Keep all existing and original session data intact. Cloud
ingestion, WOO and jump accuracy remain separate gates.

## Garmin Connect IQ boundary

Android now discovers watches through Garmin's Companion App SDK 2.4.0 and keeps
the Connect IQ device identifier opaque. The session watch app currently uses
application id `f25ab89e57f74368b256069658c6d2d8`.

The watch runtime and Android bridge implement the versioned inventory and
bounded line-by-line transfer protocol. Android acknowledges each line in exact
order, applies size and timeout limits, and passes the complete Garmin frame
envelope to Dart. Dart verifies framing, order, Adler-32 checksums, semantic
counters and final completeness before deterministically converting the stream
to Canonical Session v1. The canonical validator then runs before the private
account inbox persists the session. The mobile app does not reconstruct missing
records or infer identities.

Software evidence currently includes native watch protocol tests, Connect IQ
watch builds, Android Kotlin compilation, Dart bridge/converter tests and private
inbox tests. A physical end-to-end transfer between the Garmin watch and the
Xiaomi has not yet been run, so device delivery, background behavior and timeout
recovery remain hardware verification gates.

### Physical diagnostic check, 2026-09-17

- Xiaomi detects one Connect IQ device; the Fenix 7 is already linked and
  selected. Linked devices are intentionally absent from the add-device list.
- Opening Sessions reproduced `garmin_busy`: discovery and inventory raced
  during native SDK initialization. The Dart client now serializes native calls
  across instances. Tests cover concurrent discovery/inventory and recovery
  after a native error.
- Retrying after initialization returned `garmin_timeout`. This does not prove
  that the installed watch app supports or is running the transfer protocol.
  After installing the serialized client, startup discovered one device and
  reached the 15-second response timeout without the previous `garmin_busy`.
- Diagnostic APKs were installed as updates, without uninstalling the app.
  The packaged environment was restricted to client configuration keys.
- Actual session download, persistence and upload from the watch remain
  unverified. Next: open the compatible WindWisher watch app and retry; verify
  its installed build if it still times out. Do not delete existing recordings.

### USB preparation, 2026-09-17

- Fenix 7 was accessible through MTP after releasing Android File Transfer.
  The installed PRG was not exposed in the Apps listing, so its version could
  not be established. No claim that the old build lacked transfer support.
- Preserved local copies of WWSEDEV DAT, IDX, IMT and MBX in the ignored
  `.tmp/garmin-check-20260917/` directory. No device data/log deletion.
- Built the current Watch session-engine source for fenix7 and copied only
  `WWSEDEV.prg` into GARMIN/Apps, retaining the application ID.
- Source and device readback SHA-256 both equal
  `8fd541f2ca63e3add21c2699678cc06c13aab13edf75d492cc8932012c01e49c`.
  This verifies file transfer, not watch import, launch or session delivery.
- Next operator action: disconnect USB and open WW Session Engine Dev near the
  Xiaomi. Retry inventory without starting or deleting a recording.

### Inventory retry after USB update, 2026-09-17

Retried on the already-linked Fenix 7 through Connect IQ, without changing BLE
pairing. The Xiaomi changed from checking to "El dispositivo no tiene sesiones
pendientes." This verifies completion of the inventory/inbox check, not a real
download. The UI filters sessions already present in the inbox, so this message
alone does not establish that the watch storage is empty. No download, upload,
recording or deletion was initiated in this check.

### First new recording download attempt, 2026-09-17

After the operator recorded a short session, the Xiaomi displayed one new
session on the linked Connect IQ Fenix 7. Pressed Download once. Repeated UI
checks still showed downloading after several minutes; no completion or preview
was observed and the local inbox contained no files at the time it was checked.
Do not claim successful transfer or persistence. No upload or deletion was
initiated. Keep this recording for further diagnosis; do not ask for another
recording. Progress visibility and transfer duration need investigation before
calling this user flow ready.

### Transfer diagnostics follow-up

- Added native active-transfer counters (accepted lines and bytes) queried by
  the mobile UI every two seconds, outside the serialized command queue. No
  inferred percentage or session content is exposed in progress queries.
- Added a five-minute native transfer deadline in addition to response timeout,
  with best-effort transport abort on failure. Abort does not delete recordings.
- Fixed errors before PendingTransfer creation that previously called a no-op
  failActive and left the MethodChannel result unresolved. This is a confirmed
  code defect, not yet the established cause of the physical stalled download.
- Targeted Flutter tests: 13 passed; directed analysis clean. Physical completion
  remains unverified. Reopen the watch app to release the old attempt before
  retrying the same recording with the diagnostic APK.

### Physical progress observation, 2026-09-18

The linked Fenix inventory showed two pending sessions. Download was pressed
once. Observed counters advanced through 10/1767, 27/4939, 49/9101, 69/13042,
87/16608, 108/20822 and 140/27239 (fragments/bytes). The operation then failed
with `garmin_transfer_deadline` at the five-minute native deadline. The inbox
still contained zero files. No upload or deletion was performed.

This attempt demonstrates an advancing but slow transfer, not a frozen UI.
It does not establish the cause of earlier attempts without counters. Next
transport work should reduce per-line round trips (bounded batching with
integrity/ordering tests), rather than treating a longer timeout as the fix.
Reuse these recordings; successful complete download and preview remain pending.

### Bounded batching implementation, 2026-09-18

Android requests optional `batchLines: 8` in protocol-v1 download_start. New
watch builds return download_batch with sessionId, starting lineIndex and a
lines array. Legacy watches may still return download_line. The receiver checks
identity, exact ordering, 1..8 lines, per-line limits, a 4096-byte encoded batch
limit, total lines and total bytes before appending the complete batch. The ACK
identifies its last line. Existing envelope checksum and canonical validation
are unchanged.

The watch batches at most eight lines / 2048 ASCII characters (a single line
may stand alone), retaining the exact batch for replay until acknowledged.
Its producer is read-only: advancing it never deletes journal data. A completed
transfer now permits a new request, fixing the previous TRANSFER_BUSY on the
next session while preserving final-ACK replay until that new request.

Validation: 14 simulator tests reported PASS (runner exit code 1 despite the
all-pass report); 13 focused Flutter tests passed; Android compileDebugKotlin
and fenix7 PRG build succeeded. The new transport is NOT yet installed or
physically verified. Requires updating BOTH Android and the watch before retry.

### Batch deployment preparation, 2026-09-18

- Preserved current WWSEDEV.DAT (384216 bytes) and IDX (1048 bytes) locally in
  ignored `.tmp/garmin-batch-20260918/`; no recording deletion.
- Rebuilt the batch watch PRG and copied it to GARMIN/Apps/WWSEDEV.prg after
  intermittent USB failures. Successful device readback matches source SHA-256
  `7044c138164b96410cb2f0ae4ee45a3780824e846ca1c6faedf655c48dc8ee28`.
- Built Android in `.tmp/garmin-batch-apk/` with client-only environment keys;
  checked packaged environment keys and installed with adb install -r (Success).
- Both binary transfers are complete. Watch import/launch and physical batched
  download remain unverified. Disconnect USB, open WW Session Engine Dev, then
  retry the existing recordings near Xiaomi. No upload has been initiated.
