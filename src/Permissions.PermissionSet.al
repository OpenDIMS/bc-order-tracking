// Granular, assignable permission sets — one per feature area, so an admin
// grants the OpenDIMS API client exactly the data its channels use and
// nothing more. All read-only, matching the extension's read-only pages.

permissionset 50107 "OPENDIMS TRACKING"
{
    Caption = 'OpenDIMS: shipment tracking (read)', Locked = true;
    Assignable = true;

    Permissions =
        tabledata "Sales Shipment Header" = R,
        tabledata "Sales Invoice Header" = R,
        page "ODS Posted Sales Shipments" = X,
        page "ODS Sales Invoice Links" = X;
}

permissionset 50108 "OPENDIMS DISCOUNTS"
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

permissionset 50109 "OPENDIMS BOM"
{
    Caption = 'OpenDIMS: assembly BOM components (read)', Locked = true;
    Assignable = true;

    Permissions =
        tabledata "BOM Component" = R,
        page "ODS BOM Components" = X;
}
