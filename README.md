# OpenDIMS Business Central extension

A per-tenant AL extension that surfaces Business Central data OpenDIMS needs but the standard API v2.0 does not expose. It is **not required** to use the BC connectors — install it only when a sync needs one of its endpoints, and grant only the matching permission set.

## What it adds

Read-only API endpoints under `/api/opendims/integration/v1.0/companies({id})/`:

**Posted documents** (permission set `OPENDIMS TRACKING`):

- **`salesShipments`** — rows over Posted Sales Shipment Header. Fields:
  `id, number, orderNumber, externalDocumentNumber, customerNumber, customerName, shipmentDate, packageTrackingNumber, shippingAgentCode, shippingAgentServiceCode, hasComment, lastModifiedDateTime`, plus `fieldValues` — the other ~100 fields of the shipment.
- **`salesInvoiceLinks`** — rows over Posted Sales Invoice Header, exposing the link back to the source order. Fields:
  `id, invoiceNumber, orderNumber, externalDocumentNumber, customerNumber, postingDate, lastModifiedDateTime`, plus `fieldValues` and the invoice's calculated columns `amount, amountIncludingVat, remainingAmount, invoiceDiscountAmount, closed, cancelled, corrective, reversed, sentAsEmail, lastEmailSentTime, hasComment`.
- **`postedSalesInvoiceLines`** — `id, documentNumber, lineNumber, itemNumber, fieldValues, lastModifiedDateTime`. This
  table has no calculated columns at all, so the dump is the whole of it.
- **`postedSalesShipmentLines`** — `id, documentNumber, lineNumber, itemNumber, orderNumber, orderLineNumber,
  fieldValues, currencyCode, lastModifiedDateTime`. `orderNumber`/`orderLineNumber` link a shipped line back to the
  order line it came from.

OpenDIMS uses these endpoints to attach tracking data to imported documents:

- For **sales orders**: join by `orderNumber` directly to `salesShipments`.
- For **sales invoices**: chain `invoiceNumber` → `orderNumber` (via `salesInvoiceLinks`) → shipment (via
  `salesShipments`).

**Discount matrix** (permission set `OPENDIMS DISCOUNTS`) — feeds the BC ↔ webshop discount sync:

- **`customerDiscountGroups`** — Customer Discount Group (Debitorrabatgrupper): `id, code, description, lastModifiedDateTime`.
- **`itemDiscountGroups`** — Item Discount Group (Varerabatgrupper): `id, code, description, lastModifiedDateTime`.
- **`priceListLines`** — Price List Line (modern pricing, BC16+ — Salgsprisaftaler incl. line discounts):
  `id, priceListCode, lineNumber, status, priceType, sourceType, sourceNumber, assetType, assetNumber, variantCode, unitOfMeasureCode, minimumQuantity, amountType, unitPrice, lineDiscountPercent, currencyCode, startingDate, endingDate, lastModifiedDateTime`.

**Composed products** (permission set `OPENDIMS BOM`):

- **`bomComponents`** — Assembly BOM components (table `BOM Component`), the lines of a product that
  consists of other products: `id, parentItemNumber, lineNumber, type, number, description, quantityPer,
  unitOfMeasureCode, variantCode, position, lastModifiedDateTime`.

**The whole record, not the API's slice** (permission sets `OPENDIMS ITEMS`, `OPENDIMS CUSTOMERS`, `OPENDIMS SALES`):

Standard API v2.0 publishes a fraction of what Business Central's tables hold, and almost everything it leaves out is
ordinary Business Central — *Leverandørs varenr.*, *Kostpris (standard)*, *Vores kontonr.*, *Deres reference* — not
something an add-on put there. These endpoints hand over the rest, and pick up any field another extension added on
top for free.

| Table | Fields | v2.0 API publishes | Endpoint |
|---|---|---|---|
| Item (27) | 220 | ~20 | `odsItems`, `itemBomCosts`, `itemStatistics` |
| Customer (18) | 170 | ~25 | `odsCustomers` |
| Sales Header (36) | 181 | ~30 | `odsSalesDocuments` |
| Sales Line (37) | 193 | ~25 | `odsSalesDocumentLines` |
| Sales Invoice Header (112) | 131 | ~30 | `salesInvoiceLinks` |
| Sales Invoice Line (113) | 102 | ~25 | `postedSalesInvoiceLines` |
| Sales Shipment Header (110) | 103 | none | `salesShipments` |
| Sales Shipment Line (111) | 101 | none | `postedSalesShipmentLines` |

- **`tableFields`** — the field catalogue: one row per readable field on those tables, *including the fields other
  extensions added on this tenant*. Fields: `tableNumber, fieldNumber, fieldName, fieldCaption, elementName, dataType,
  fieldClass, fieldLength, isCustom, optionMembers`. Built in memory from table metadata on every call, so a field
  added by installing another extension shows up immediately. Filter it (`?$filter=tableNumber eq 18`) to describe one
  table; unfiltered it describes all four, skipping any the API user has no read permission for. `isCustom` (field
  number ≥ 50000) is a label for the reader, not a filter — every readable field is listed.
- **`odsItems`** — the values: `id, number, displayName, fieldValues` plus the calculated columns
  `assemblyBom, inventory, qtyOnPurchOrder, qtyOnSalesOrder, qtyOnAssemblyOrder, qtyOnAsmComponent, qtyOnJobOrder,
  qtyInTransit, qtyOnPurchReturn, qtyOnSalesReturn, costIsPostedToGL, substitutesExist, stockkeepingUnitExists,
  lastModifiedDateTime`.
- **`itemBomCosts`** — `id, number, assemblyBom, componentCount, calculatedBomCost, standardCost, unitCost,
  lastDirectCost, lastModifiedDateTime`. `calculatedBomCost` rolls the assembly BOM up again on the spot (components ×
  quantity per × qty. per unit of measure, recursing into sub-assemblies) without writing anything back — BC's own
  *Calculate Standard Cost* stores its result on the item, which an API GET must not do. Separate endpoint so only an
  integration that maps it pays for the walk.
- **`itemStatistics`** — what the item ledger says: `netChange, netInvoicedQty, purchasesQty, salesQty,
  positiveAdjmtQty, negativeAdjmtQty, transferredQty, purchasesLcy, salesLcy, positiveAdjmtLcy, negativeAdjmtLcy,
  transferredLcy, cogsLcy, reservedQtyOnInventory, reservedQtyOnSalesOrders, reservedQtyOnPurchOrders,
  qtyAssignedToShip, qtyPicked, qtyOnServiceOrder, qtyOnProdOrder, qtyOnComponentLines, noOfSubstitutes,
  lastPhysInvtDate, hasComment`. Unfiltered, these are the totals over the item's whole life. Separate endpoint for
  the same reason as the BOM cost: every one of them is a calculated column BC has to work out per item.
- **`odsCustomers`** — `id, number, displayName, fieldValues` plus the balances the customer card shows:
  `balance, balanceLcy, balanceDue, balanceDueLcy, netChange, netChangeLcy, salesLcy, profitLcy, invAmountsLcy,
  paymentsLcy, outstandingOrdersLcy, outstandingInvoicesLcy, shippedNotInvoicedLcy, hasComment,
  lastModifiedDateTime`. These are sums over the customer ledger with a SIFT index behind them, cheap enough to sit on
  the main page rather than on an endpoint of their own.
- **`odsSalesDocuments`** — the *open* sales documents (Sales Header, not the posted ones): `id, documentType, number,
  customerNumber, fieldValues` plus `amount, amountIncludingVat, invoiceDiscountAmount, shipped, completelyShipped,
  shippedNotInvoiced, lastShipmentDate, lateOrderShipping, numberOfArchivedVersions, hasComment,
  lastModifiedDateTime`. The table's key is (Document Type, No.), so `documentType` travels with every row and a
  caller matching on the number alone must filter on it: `?$filter=documentType eq 'Order' and number in ('S-ORD-1')`.
- **`odsSalesDocumentLines`** — `id, documentType, documentNumber, lineNumber, fieldValues` plus `reservedQuantity,
  whseOutstandingQty, qtyToAssign, qtyAssigned, substitutionAvailable, postingDate, attachedDocCount,
  lastModifiedDateTime`. `lineNumber` is the Sales Line's own *Line No.*, which is what the standard API calls
  `sequence` on an order line — that pair is how OpenDIMS matches a line up.

`fieldValues` is a JSON object holding every readable, non-calculated field of the record **keyed by its Business
Central field number** — `{"32":"2004210","24":19737.26,"50100":true}` is Vendor Item No., Standard Cost and a
custom field. The number is the only part of a field that survives a rename and does not change with the display
language, which is what keeps an OpenDIMS mapping stable. `tableFields.elementName` (`BCField_32_VendorItemNo`)
names those numbers for the mapping UI. Empty values are sent as `null` so clearing a value in BC clears it in
OpenDIMS too.

Calculated (FlowField) columns cannot travel in `fieldValues` — BC has to compute each one per item — so the ones
from the item card are named columns instead, and OpenDIMS asks for them with `$select` only when they are mapped.
Of the Item table's 220 fields that leaves 139 in `fieldValues`, 13 named on `odsItems`, 24 on `itemStatistics`, 13
flow *filters* that carry no data, and one `MediaSet` (the item picture). The rest are MRP planning internals —
`Planning Receipt (Qty.)`, `Res. Qty. on Prod. Order Comp.` and the like — left out on purpose; add them to
`itemStatistics` if a customer ever wants them. The same split on the other tables: Customer 98 dumped + 14 named,
Sales Header 160 + 10, Sales Line 180 + 7, posted invoice 115 + 11, posted invoice line 102 + 0, posted shipment
100 + 1, posted shipment line 100 + 1.

These pages are extensible: another extension can add typed columns with a `pageextension`, and they show up in
`$metadata` and in OpenDIMS' mapping alongside everything else.

## Permission sets

The extension ships six assignable, read-only permission sets — `OPENDIMS TRACKING`,
`OPENDIMS DISCOUNTS`, `OPENDIMS BOM`, `OPENDIMS ITEMS`, `OPENDIMS CUSTOMERS`, `OPENDIMS SALES` — one per feature area. Assign only the set(s) matching the
channels a tenant actually runs to the API client (the Microsoft Entra app's BC user), so an
integration that only reads tracking never has access to pricing or BOM data.

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
  attaches `opendims-bc-extension.zip`** (GitHub blocks bare `.app` uploads — the archive contains the single `.app`
  file, just unzip after download).
- A release created/published from the GitHub UI — same as above, attaches the zip to the existing release.
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

If you grabbed the file from a GitHub release, unzip `opendims-bc-extension.zip` first and copy the resulting `.app`
file into the path above.

## How a customer installs it

1. In Business Central, search for **Extension Management**.
2. Click ⋯ → **Upload Extension**.
3. Pick the `.app` file, accept terms, **Deploy**.
4. Confirm it shows up under *Installed Extensions* with publisher `OpenDIMS`.

After install, in OpenDIMS' BusinessCentralOrdersImport connector, switch **"Use the OpenDIMS BC extension for tracking"** to *Yes*. The driver will then read the four extra fields on `salesOrders` and (optionally) the `salesShipments` endpoint.

## Notes

- The `id` field in `app.json` is the extension's permanent GUID. Don't change it across versions — BC uses it as the upgrade key.
- Object id range `85445-85494` is inside the standard per-tenant extension (PTE) range, which is shared with every
  other PTE on the tenant. Version 1.1.0.0 and earlier used `50100-50149` — the range the VS Code AL project template
  hands out by default — and collided with another partner app on a customer tenant (`The application object of type
  'Page' with the ID '50101' is defined in multiple apps`). Never move back into the low `50000-50999` block, and if
  this ever ships on AppSource, request a dedicated range from Microsoft.
- Renumbering objects is safe for this extension: endpoint URLs come from
  `APIPublisher`/`APIGroup`/`APIVersion`/`EntitySetName`, and permission set assignments are keyed by name, not by
  object id. Keep the `app.json` GUID and BC treats a renumbered build as a normal upgrade. The one table it owns
  (`ODS Table Field`) is only ever used as a temporary record and never holds a row in the tenant's database, and
  there are no table extensions, so no customer data rides on an object id.
- The extension is **read-only**: it doesn't write to BC, only exposes data. Uninstalling it is reversible.
