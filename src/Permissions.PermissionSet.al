// Granular, assignable permission sets — one per feature area, so an admin
// grants the OpenDIMS API client exactly the data its channels use and
// nothing more. All read-only, matching the extension's read-only pages.

permissionset 85451 "OPENDIMS TRACKING"
{
    Caption = 'OpenDIMS: shipment tracking (read)', Locked = true;
    Assignable = true;

    Permissions =
        tabledata "Sales Shipment Header" = R,
        tabledata "Sales Invoice Header" = R,
        page "ODS Posted Sales Shipments" = X,
        page "ODS Sales Invoice Links" = X;
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
        page "ODS BOM Components" = X;
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
        tabledata Resource = R,
        tabledata "BOM Component" = R,
        tabledata "ODS Table Field" = RIMD,
        page "ODS Items" = X,
        page "ODS Table Fields" = X,
        page "ODS Item BOM Costs" = X,
        page "ODS Item Statistics" = X,
        codeunit "ODS Field Reflection" = X,
        codeunit "ODS BOM Cost" = X;
}
