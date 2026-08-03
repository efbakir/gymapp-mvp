# What’s New automation

The public page is `/updates`. App Store Connect is the release-note source.
Vercel Blob stores the last successful catalog, so an Apple outage does not
take the page down or erase earlier releases.

## Runtime map

| Path | Trigger | Authentication |
|---|---|---|
| `POST /api/app-store/webhook` | App Store version state webhook | Apple `x-apple-signature` HMAC |
| `POST /api/app-store/sync` | Manual recovery or testing | `Bearer $UPDATES_SYNC_SECRET` |
| `GET /api/cron/app-store-sync` | Vercel daily cron at 03:00 UTC | `Bearer $CRON_SECRET` |
| `/updates` | Public page | None |

Only `APP_STORE_VERSION_APP_VERSION_STATE_UPDATED` with
`READY_FOR_DISTRIBUTION` can publish a new version. Daily reconciliation also
keeps historical `REPLACED_WITH_NEW_VERSION` records. Pending, review,
rejected, build-upload, and TestFlight states never enter the catalog.

## One-time Vercel setup

1. In the Vercel project, open Storage and create a **private Blob** store.
2. Connect it to Production. Connect a separate store to Preview, or set a
   preview-only `UPDATES_BLOB_PATH` such as `updates-preview/releases.json`.
3. Add these encrypted Production variables:

   - `APP_STORE_CONNECT_KEY_ID`
   - `APP_STORE_CONNECT_ISSUER_ID`
   - `APP_STORE_CONNECT_PRIVATE_KEY_BASE64`
   - `APP_STORE_APP_ID=6775008893`
   - `APP_STORE_WEBHOOK_SECRET`
   - `UPDATES_SYNC_SECRET`
   - `CRON_SECRET`
   - `BLOB_READ_WRITE_TOKEN` (created by Vercel)

4. Generate each secret independently with at least 32 random bytes.
5. Base64-encode the downloaded `.p8` file before setting
   `APP_STORE_CONNECT_PRIVATE_KEY_BASE64`:

   ```sh
   base64 < AuthKey_KEYID.p8 | tr -d '\n'
   ```

Do not add the `.p8` file or real values to `.env.example`. Preview must not
use the production Blob token unless its path is isolated.

## One-time App Store Connect setup

1. Create a read-only API key with the Marketing role. Record its key ID and
   issuer ID, then download its private key once.
2. Sign in as Account Holder, Admin, or App Manager.
3. Open Users and Access → Integrations → Webhooks.
4. Create a webhook named `Unit public version`.
5. Set the app to Unit and the payload URL to:
   `https://www.unitlift.app/api/app-store/webhook`
6. Select only `APP_STORE_VERSION_APP_VERSION_STATE_UPDATED`.
7. Enter the same random value stored as `APP_STORE_WEBHOOK_SECRET`.
8. Enable the webhook and send Apple’s test ping.
9. Confirm a `204` delivery in App Store Connect and
   `webhook_ignored` with reason `unrelated_event` in Vercel logs.

The webhook is app-scoped, and the server independently checks the returned app
ID and `IOS` platform before writing.

## Initial history import

Run this after the first production deployment:

```sh
curl --request POST 'https://www.unitlift.app/api/app-store/sync' \
  --header "Authorization: Bearer $UPDATES_SYNC_SECRET" \
  --header 'Content-Type: application/json' \
  --data '{"mode":"full"}'
```

The response reports `added`, `updated`, and `releaseCount`; it does not return
release-note bodies or credentials.

Release dates resolve in this order:

1. Signed webhook transition time for future releases.
2. App Store Connect `earliestReleaseDate`.
3. Apple public lookup date for the current or initial version.
4. An existing stored date.

If an older version still has no date, the sync fails before writing and logs
`UPDATES_RELEASE_DATES_UNRESOLVED`. Read that version’s
`READY_FOR_DISTRIBUTION` time from App Store Connect → History, then add a
temporary Production variable:

```text
APP_STORE_RELEASE_DATE_OVERRIDES_JSON={"1.2":"2026-06-21T09:15:00Z"}
```

Run the full sync again. The stored source becomes `ascHistoryBootstrap`. The
override may remain for reproducibility; it contains no secret.

## Manual recovery

Sync every public version:

```sh
curl --request POST 'https://www.unitlift.app/api/app-store/sync' \
  --header "Authorization: Bearer $UPDATES_SYNC_SECRET" \
  --header 'Content-Type: application/json' \
  --data '{"mode":"full"}'
```

Sync one App Store version resource:

```sh
curl --request POST 'https://www.unitlift.app/api/app-store/sync' \
  --header "Authorization: Bearer $UPDATES_SYNC_SECRET" \
  --header 'Content-Type: application/json' \
  --data '{"mode":"version","versionId":"APP_STORE_VERSION_RESOURCE_ID"}'
```

Revalidate the page after an operator restores Blob data:

```sh
curl --request POST 'https://www.unitlift.app/api/app-store/sync' \
  --header "Authorization: Bearer $UPDATES_SYNC_SECRET" \
  --header 'Content-Type: application/json' \
  --data '{"mode":"revalidate"}'
```

Apple delivery retries are safe: the stable App Store version ID and content
hash make replay a no-op.

## Monitoring

Filter Vercel logs by `scope=updates`.

Success events:

- `webhook_sync_succeeded`
- `cron_sync_succeeded`
- `manual_sync_succeeded`

Failure events:

- `webhook_sync_failed`
- `cron_sync_failed`
- `manual_sync_failed`
- `updates_page_catalog_unavailable`

Logs contain event/version IDs, counts, durations, and stable error codes.
They never contain JWTs, signatures, request bodies, release notes, or private
keys. App Store Connect → Webhook Deliveries is the second source for failed
delivery inspection and redelivery.

Vercel cron does not retry failures. The next daily run repairs missed data;
run a manual full sync for immediate recovery.

## Rollback

Every changed catalog writes an immutable private backup under
`updates/backups/` before the current catalog changes.

1. Disable the daily cron if Apple currently returns bad metadata.
2. In Vercel Blob, copy the selected backup over the configured
   `UPDATES_BLOB_PATH`.
3. Call manual sync with `{"mode":"revalidate"}`.
4. Correct the source metadata or credentials.
5. Run `{"mode":"full"}`, inspect `/updates`, then re-enable cron.

For code rollback, use Vercel Instant Rollback. Check the Cron Jobs screen
afterward because active cron configuration does not roll back with the
deployment.

## Verification

Before deployment:

```sh
pnpm test
pnpm lint
pnpm typecheck
pnpm build
```

After deployment:

1. Invalid webhook signature returns `401`.
2. Apple ping returns `204`.
3. A non-public signed fixture returns `204` without a Blob write.
4. A valid public fixture writes once; replay leaves `releaseCount` unchanged.
5. `/updates` HTML contains version headings, dates, notes, canonical metadata,
   and the App Store action.
6. `/changelog` permanently redirects to `/updates`.
7. `/sitemap.xml` contains the final `https://www.unitlift.app/updates` URL.
