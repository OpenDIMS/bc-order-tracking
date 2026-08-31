// Granular, assignable permission sets — one per feature area, so an admin
// grants the OpenDIMS API client exactly the data its channels use and
// nothing more. All read-only, matching the extension's read-only pages.

permissionset 85451 "OPENDIMS TRACKING"
{
    Caption = 'OpenDIMS: shipment tracking (read)', Locked = true;
    Assignable = true;

    Permissions =
        tabledata "Sales Shipment Header" = R,
        tabledata "Sales Shipment Line" = R,
        tabledata "Sales Invoice Header" = R,
        tabledata "Sales Invoice Line" = R,
        tabledata "ODS Table Field" = RIMD,
        page "ODS Posted Sales Shipments" = X,
        page "ODS Sales Invoice Links" = X,
        page "ODS Posted Sales Inv. Lines" = X,
        page "ODS Posted Sales Shpt. Lines" = X,
        page "ODS Table Fields" = X,
        codeunit "ODS Field Reflection" = X;
}

permissionset 85452 "OPENDIMS DISCOUNTS"
{
    Caption = 'OpenDIMS: discount groups & price list lines (read)', Locked = true;
    Assignable = true;

    Permissions =
        tabledata "Customer Discount Group" = R,
        tabledata "Item Discount Group" = R,
        tabledata "Price List Line" = R,
        page "ODS Customer Discount Groups" = X,
        page "ODS Item Discount Groups" = X,
        page "ODS Price List Lines" = X;
}

permissionset 85453 "OPENDIMS BOM"
{
    Caption = 'OpenDIMS: assembly BOM components (read)', Locked = true;
    Assignable = true;

    Permissions =
        tabledata "BOM Component" = R,
        // Gross requirement sums demand from each of these. A missing one
        // does not fail the call, it silently drops that part of the demand.
        tabledata "Sales Line" = R,
        tabledata "Service Line" = R,
        tabledata "Job Planning Line" = R,
        tabledata "Prod. Order Component" = R,
        tabledata "Planning Component" = R,
        tabledata "Assembly Line" = R,
        tabledata "Purchase Line" = R,
        page "ODS BOM Components" = X;
}

permissionset 85488 "OPENDIMS TABLE DATA"
{
    Caption = 'OpenDIMS: read any table the client already has rights to', Locked = true;
    Assignable = true;

    // Deliberately grants no tabledata beyond this app's own buffer. What a
    // client can read through tableRecords is exactly what the other permission
    // sets it was granted let it read — this only opens the door.
    Permissions =
        tabledata "ODS Table Record" = RIMD,
        tabledata "ODS Table Field" = RIMD,
        page "ODS Table Records" = X,
        page "ODS Table Fields" = X,
        codeunit "ODS Field Reflection" = X;
}

permissionset 85485 "OPENDIMS LEDGERS"
{
    Caption = 'OpenDIMS: item, customer, vendor and G/L entries (read)', Locked = true;
    Assignable = true;

    Permissions =
        tabledata "Item Ledger Entry" = R,
        tabledata "Value Entry" = R,
        tabledata "Cust. Ledger Entry" = R,
        tabledata "Detailed Cust. Ledg. Entry" = R,
        tabledata "Vendor Ledger Entry" = R,
        tabledata "Detailed Vendor Ledg. Entry" = R,
        tabledata "G/L Entry" = R,
        tabledata "ODS Table Field" = RIMD,
        page "ODS Item Ledger Entries" = X,
        page "ODS Value Entries" = X,
        page "ODS Cust. Ledger Entries" = X,
        page "ODS Det. Cust. Ledg. Entries" = X,
        page "ODS Vendor Ledger Entries" = X,
        page "ODS Det. Vendor Ledg. Entries" = X,
        page "ODS General Ledger Entries" = X,
        page "ODS Table Fields" = X,
        codeunit "ODS Field Reflection" = X;
}

permissionset 85476 "OPENDIMS VENDORS"
{
    Caption = 'OpenDIMS: extended vendor fields (read)', Locked = true;
    Assignable = true;

    Permissions =
        tabledata Vendor = R,
        tabledata "ODS Table Field" = RIMD,
        page "ODS Vendors" = X,
        page "ODS Table Fields" = X,
        codeunit "ODS Field Reflection" = X;
}

permissionset 85477 "OPENDIMS PURCHASES"
{
    Caption = 'OpenDIMS: purchase documents, posted and open (read)', Locked = true;
    Assignable = true;

    Permissions =
        tabledata "Purchase Header" = R,
        tabledata "Purchase Line" = R,
        tabledata "Purch. Inv. Header" = R,
        tabledata "Purch. Inv. Line" = R,
        tabledata "Purch. Rcpt. Header" = R,
        tabledata "Purch. Rcpt. Line" = R,
        tabledata "ODS Table Field" = RIMD,
        page "ODS Purchase Documents" = X,
        page "ODS Purchase Document Lines" = X,
        page "ODS Posted Purch. Invoices" = X,
        page "ODS Posted Purch. Inv. Lines" = X,
        page "ODS Posted Purch. Receipts" = X,
        page "ODS Posted Purch. Rcpt. Lines" = X,
        page "ODS Table Fields" = X,
        codeunit "ODS Field Reflection" = X;
}

permissionset 85465 "OPENDIMS CUSTOMERS"
{
    Caption = 'OpenDIMS: extended customer fields (read)', Locked = true;
    Assignable = true;

    Permissions =
        tabledata Customer = R,
        tabledata "ODS Table Field" = RIMD,
        page "ODS Customers" = X,
        page "ODS Table Fields" = X,
        codeunit "ODS Field Reflection" = X;
}

permissionset 85466 "OPENDIMS SALES"
{
    Caption = 'OpenDIMS: extended sales document fields (read)', Locked = true;
    Assignable = true;

    Permissions =
        tabledata "Sales Header" = R,
        tabledata "Sales Line" = R,
        tabledata "ODS Table Field" = RIMD,
        page "ODS Sales Documents" = X,
        page "ODS Sales Document Lines" = X,
        page "ODS Table Fields" = X,
        codeunit "ODS Field Reflection" = X;
}

permissionset 85460 "OPENDIMS ITEMS"
{
    Caption = 'OpenDIMS: extended item fields & BOM cost (read)', Locked = true;
    Assignable = true;

    // "ODS Table Field" is only ever used as a temporary record, but a
    // temporary record still needs the permission on its table object.
    Permissions =
        tabledata Item = R,
        tabledata "Item Unit of Measure" = R,
        // Product specifications — "Effekt (watt)", "Panelgaranti" — are item
        // attributes rather than fields on the item, spread over three tables.
        // Read-only, like everything else here: OpenDIMS reads specifications
        // from Business Central, it does not write them back.
        tabledata "Item Attribute" = R,
        tabledata "Item Attribute Value" = R,
        tabledata "Item Attribute Value Mapping" = R,
        tabledata Resource = R,
        tabledata "BOM Component" = R,
        // Gross requirement sums demand from each of these. A missing one
        // does not fail the call, it silently drops that part of the demand.
        tabledata "Sales Line" = R,
        tabledata "Service Line" = R,
        tabledata "Job Planning Line" = R,
        tabledata "Prod. Order Component" = R,
        tabledata "Planning Component" = R,
        tabledata "Assembly Line" = R,
        tabledata "Purchase Line" = R,
        tabledata "ODS Table Field" = RIMD,
        page "ODS Items" = X,
        page "ODS Item Attributes" = X,
        page "ODS Item Attribute Values" = X,
        page "ODS Table Fields" = X,
        page "ODS Item BOM Costs" = X,
        page "ODS Item Statistics" = X,
        page "ODS Item Availability" = X,
        codeunit "ODS Field Reflection" = X,
        codeunit "ODS BOM Cost" = X;
}
