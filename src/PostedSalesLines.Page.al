// The lines of a posted sales invoice and of a posted shipment.
//
// Their headers are already published as salesInvoiceLinks and salesShipments;
// these are what those documents actually contain. Standard API v2.0 publishes
// about 25 of an invoice line's 102 fields and has no shipment-line endpoint at
// all, so both travel here as a fieldValues dump keyed by Business Central
// field number, named by the tableFields endpoint (?$filter=tableNumber eq 113
// / 111).
//
// Both tables are keyed by (Document No., Line No.), so a caller reads a whole
// document's lines at once:
//
// GET …/postedSalesInvoiceLines?$filter=documentNumber in ('PS-INV-1001')
// GET …/postedSalesShipmentLines?$filter=documentNumber in ('PS-SHPT-1001')
page 85467 "ODS Posted Sales Inv. Lines"
{
    PageType = API;
    Caption = 'postedSalesInvoiceLines', Locked = true;
    APIPublisher = 'opendims';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'postedSalesInvoiceLine';
    EntitySetName = 'postedSalesInvoiceLines';
    SourceTable = "Sales Invoice Line";
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId) { Caption = 'id', Locked = true; ApplicationArea = All; Editable = false; }
                field(documentNumber; Rec."Document No.") { Caption = 'documentNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(lineNumber; Rec."Line No.") { Caption = 'lineNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(itemNumber; Rec."No.") { Caption = 'itemNumber', Locked = true; ApplicationArea = All; Editable = false; }
                // Every field of the line — this table has no calculated ones,
                // so the dump is the whole of it.
                field(fieldValues; FieldValuesJson) { Caption = 'fieldValues', Locked = true; ApplicationArea = All; Editable = false; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'lastModifiedDateTime', Locked = true; ApplicationArea = All; Editable = false; }
            }
        }
    }

    var
        FieldReflection: Codeunit "ODS Field Reflection";
        FieldValuesJson: Text;

    trigger OnAfterGetRecord()
    begin
        FieldValuesJson := FieldReflection.DumpFields(Rec);
    end;
}

page 85468 "ODS Posted Sales Shpt. Lines"
{
    PageType = API;
    Caption = 'postedSalesShipmentLines', Locked = true;
    APIPublisher = 'opendims';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'postedSalesShipmentLine';
    EntitySetName = 'postedSalesShipmentLines';
    SourceTable = "Sales Shipment Line";
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId) { Caption = 'id', Locked = true; ApplicationArea = All; Editable = false; }
                field(documentNumber; Rec."Document No.") { Caption = 'documentNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(lineNumber; Rec."Line No.") { Caption = 'lineNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(itemNumber; Rec."No.") { Caption = 'itemNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(orderNumber; Rec."Order No.") { Caption = 'orderNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(orderLineNumber; Rec."Order Line No.") { Caption = 'orderLineNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(fieldValues; FieldValuesJson) { Caption = 'fieldValues', Locked = true; ApplicationArea = All; Editable = false; }
                field(currencyCode; Rec."Currency Code") { Caption = 'currencyCode', Locked = true; ApplicationArea = All; Editable = false; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'lastModifiedDateTime', Locked = true; ApplicationArea = All; Editable = false; }
            }
        }
    }

    var
        FieldReflection: Codeunit "ODS Field Reflection";
        FieldValuesJson: Text;

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Currency Code");
        FieldValuesJson := FieldReflection.DumpFields(Rec);
    end;
}
