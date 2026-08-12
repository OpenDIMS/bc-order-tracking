// The field catalogue OpenDIMS reads to find out what a tenant's records
// actually look like: one row per readable field on the item, customer and
// sales and purchase document tables and the ledgers, including the fields other extensions added there.
//
// It is what turns the opaque numeric keys in odsItems.fieldValues into
// mappable elements — elementName is the name OpenDIMS shows in its field
// mapping, and isCustom flags the fields that are not part of standard
// Business Central.
//
// The rows are built in memory from table metadata on every call, so a field
// added by installing another extension shows up immediately and nothing is
// written to the tenant's database.
//
// GET /api/opendims/integration/v1.0/companies({companyId})/tableFields
//     ?$filter=isCustom eq true
page 85458 "ODS Table Fields"
{
    PageType = API;
    Caption = 'tableFields', Locked = true;
    APIPublisher = 'opendims';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'tableField';
    EntitySetName = 'tableFields';
    SourceTable = "ODS Table Field";
    SourceTableTemporary = true;
    ODataKeyFields = "Table No.", "Field No.";
    DelayedInsert = true;
    Editable = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(tableNumber; Rec."Table No.") { Caption = 'tableNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(fieldNumber; Rec."Field No.") { Caption = 'fieldNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(fieldName; Rec."Field Name") { Caption = 'fieldName', Locked = true; ApplicationArea = All; Editable = false; }
                field(fieldCaption; Rec."Field Caption") { Caption = 'fieldCaption', Locked = true; ApplicationArea = All; Editable = false; }
                field(elementName; Rec."Element Name") { Caption = 'elementName', Locked = true; ApplicationArea = All; Editable = false; }
                field(dataType; Rec."Data Type") { Caption = 'dataType', Locked = true; ApplicationArea = All; Editable = false; }
                field(fieldClass; Rec."Field Class") { Caption = 'fieldClass', Locked = true; ApplicationArea = All; Editable = false; }
                field(fieldLength; Rec."Field Length") { Caption = 'fieldLength', Locked = true; ApplicationArea = All; Editable = false; }
                field(isCustom; Rec."Is Custom") { Caption = 'isCustom', Locked = true; ApplicationArea = All; Editable = false; }
                field(optionMembers; Rec."Option Members") { Caption = 'optionMembers', Locked = true; ApplicationArea = All; Editable = false; }
            }
        }
    }

    var
        FieldReflection: Codeunit "ODS Field Reflection";

    trigger OnOpenPage()
    var
        Requested: Integer;
    begin
        // Any table the API user may read — the named endpoints cover the ones
        // OpenDIMS uses daily, tableRecords covers the rest of Business Central,
        // and both need their fields named. Business Central's own permissions
        // are the boundary; a table this client cannot read describes as empty.
        if Evaluate(Requested, Rec.GetFilter("Table No.")) then begin
            if FieldReflection.IsReadableTable(Requested) then
                FieldReflection.BuildCatalog(Requested, Rec);
            exit;
        end;

        // Unfiltered: the tables this app publishes an endpoint of its own for.

        FieldReflection.BuildCatalog(Database::Item, Rec);
        FieldReflection.BuildCatalog(Database::Customer, Rec);
        FieldReflection.BuildCatalog(Database::"Sales Header", Rec);
        FieldReflection.BuildCatalog(Database::"Sales Line", Rec);
        FieldReflection.BuildCatalog(Database::"Sales Invoice Header", Rec);
        FieldReflection.BuildCatalog(Database::"Sales Invoice Line", Rec);
        FieldReflection.BuildCatalog(Database::"Sales Shipment Header", Rec);
        FieldReflection.BuildCatalog(Database::"Sales Shipment Line", Rec);
        FieldReflection.BuildCatalog(Database::Vendor, Rec);
        FieldReflection.BuildCatalog(Database::"Purchase Header", Rec);
        FieldReflection.BuildCatalog(Database::"Purchase Line", Rec);
        FieldReflection.BuildCatalog(Database::"Purch. Inv. Header", Rec);
        FieldReflection.BuildCatalog(Database::"Purch. Inv. Line", Rec);
        FieldReflection.BuildCatalog(Database::"Purch. Rcpt. Header", Rec);
        FieldReflection.BuildCatalog(Database::"Purch. Rcpt. Line", Rec);
        FieldReflection.BuildCatalog(Database::"Item Ledger Entry", Rec);
        FieldReflection.BuildCatalog(Database::"Value Entry", Rec);
        FieldReflection.BuildCatalog(Database::"Cust. Ledger Entry", Rec);
        FieldReflection.BuildCatalog(Database::"Detailed Cust. Ledg. Entry", Rec);
        FieldReflection.BuildCatalog(Database::"Vendor Ledger Entry", Rec);
        FieldReflection.BuildCatalog(Database::"Detailed Vendor Ledg. Entry", Rec);
        FieldReflection.BuildCatalog(Database::"G/L Entry", Rec);
    end;

}
