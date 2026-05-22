# OpenDIMS Business Central extension

A per-tenant AL extension that surfaces shipment-tracking data from Business Central in a shape OpenDIMS can read. It is **not required** to use the BC connectors — install it only when you want to sync tracking numbers and posted shipments back from BC to a webshop.

## What it adds

Publishes two read-only API endpoints under `/api/opendims/integration/v1.0/companies({id})/`:

- **`salesShipments`** — rows over Posted Sales Shipment Header. Fields:
  `id, number, orderNumber, externalDocumentNumber, customerNumber, customerName, shipmentDate, packageTrackingNumber, shippingAgentCode, shippingAgentServiceCode, lastModifiedDateTime`.
- **`salesInvoiceLinks`** — rows over Posted Sales Invoice Header, exposing the link back to the source order. Fields:
  `id, invoiceNumber, orderNumber, externalDocumentNumber, customerNumber, postingDate, lastModifiedDateTime`.

OpenDIMS uses these endpoints to attach tracking data to imported documents:

- For **sales orders**: join by `orderNumber` directly to `salesShipments`.
- For **sales invoices**: chain `invoiceNumber` → `orderNumber` (via `salesInvoiceLinks`) → shipment (via
  `salesShipments`).

Microsoft's standard `salesOrders` API page is **not** extended — that page lives in an internal `_Exclude_APIV2_`
symbol that BcContainerHelper deliberately omits, and extending it would break across BC version bumps. The custom
shipments endpoint is more stable.

## Compiling the .app file

Four options. All call the same `build.ps1`, so output is identical.

### A. GitHub Actions

`.github/workflows/build-bc-extension.yml` runs on `windows-latest`, caches BC artifacts between runs, and uploads
`opendims-bc-extension.app` as a workflow artifact.

Triggers:

- Push to `develop` / `main` — builds + uploads workflow artifact only.
- Push of a tag matching `v*` or `bc-ext-v*` — builds, and **creates a GitHub release for that tag if missing, then
  attaches the `.app`**.
- A release created/published from the GitHub UI — same as above, attaches to the existing release.
- Pull requests — builds + uploads workflow artifact only.
- Manual: **Actions → Build BC extension → Run workflow** (optional `bcVersion` input).

To cut a customer-facing release in one step:

```bash
# Bump version in app.json first, commit, then:
git tag v1.0.1.0
git push origin v1.0.1.0
```

Cold build ~5-7 min, warm ~1 min thanks to `actions/cache`.

### B. GitLab CI

`.gitlab-ci.yml` defines two jobs:

- `build_bc_extension` runs on every MR / push to `develop` or `main`. Produces `out/opendims-bc-extension.app` as a job artifact. Linux runner, no Docker-in-Docker, no Windows.
- `publish_bc_extension` runs on tags matching `bc-ext-*` and uploads the `.app` to the project's Generic Packages registry at
  `…/api/v4/projects/<id>/packages/generic/bc-extension/<tag>/opendims-bc-extension.app`.

To make a customer-facing release:
```bash
git tag bc-ext-v1.0.0.0
git push origin bc-ext-v1.0.0.0
```

### C. Local via Docker

Uses the same image as the GitLab job. No PowerShell install required on the host — just Docker.

```bash
./build-docker.sh                 # uses BC version from app.json
./build-docker.sh 23.0            # override BC version
BC_BUILD_CACHE_DIR=/tmp/bc-cache ./build-docker.sh   # custom cache location
```

First run downloads + extracts ~600 MB of BC platform symbols into `~/.cache/opendims-bc-build/` — this takes **5–15 minutes** depending on disk speed (PowerShell's `Expand-Archive` is single-threaded). Subsequent runs reuse the cache and finish in ~30 seconds. Output: `out/opendims-bc-extension.app`, owned by your host user (no `sudo` cleanup needed).

### D. Local via `build.ps1` directly

If you already have PowerShell 7 (`pwsh`) — on Fedora: `sudo dnf install powershell` from the Microsoft repo. Then:

```bash
pwsh -File ./build.ps1
```

Same cache + timing characteristics as option C, just without the Docker wrapper.

### E. VS Code with the AL Language extension (Windows / macOS only)

Microsoft's AL extension officially supports Windows and macOS, not Linux.

1. Open this folder in VS Code.
2. Ctrl/Cmd+Shift+P → `AL: Download symbols`.
3. Ctrl/Cmd+Shift+B → builds `OpenDIMS_OpenDIMS Integration_1.0.0.0.app` next to `app.json`.

To bump versions, change `version` in `app.json` and rebuild.

## Where to put the compiled file

Copy the compiled `.app` to the OpenDIMS API public folder so users can download it from inside the app UI:

```
api/public/downloads/business-central/opendims-bc-extension.app
```

The driver advertises the URL `<APP_URL>/downloads/business-central/opendims-bc-extension.app` in its settings help text.

## How a customer installs it

1. In Business Central, search for **Extension Management**.
2. Click ⋯ → **Upload Extension**.
3. Pick the `.app` file, accept terms, **Deploy**.
4. Confirm it shows up under *Installed Extensions* with publisher `OpenDIMS`.

After install, in OpenDIMS' BusinessCentralOrdersImport connector, switch **"Use the OpenDIMS BC extension for tracking"** to *Yes*. The driver will then read the four extra fields on `salesOrders` and (optionally) the `salesShipments` endpoint.

## Notes

- The `id` field in `app.json` is the extension's permanent GUID. Don't change it across versions — BC uses it as the upgrade key.
- Object id range `50100-50149` is inside the standard per-tenant extension (PTE) range. If you ever ship this on AppSource you must request a dedicated range from Microsoft.
- The extension is **read-only**: it doesn't write to BC, only exposes data. Uninstalling it is reversible.
