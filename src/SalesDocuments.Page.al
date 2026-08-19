// Read-only API pages over Sales Header (36) and Sales Line (37) — the open
// sales documents, not the posted ones. Standard API v2.0 publishes about 30 of
// the header's 181 fields and 25 of the line's 193; the rest travel in
// fieldValues keyed by Business Central field number, named by the tableFields
// endpoint (?$filter=tableNumber eq 36 / 37).
//
// Sales Header's primary key is (Document Type, No.), so documentType travels
// with every row and a caller matching on number alone must filter on it:
//
// GET …/odsSalesDocuments?$filter=documentType eq 'Order' and number in ('S-ORD-1')
// GET …/odsSalesDocumentLines?$filter=documentType eq 'Order' and documentNumber in ('S-ORD-1')
page 85463 "ODS Sales Documents"
{
    PageType = API;
    Caption = 'odsSalesDocuments', Locked = true;
    APIPublisher = 'opendims';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'odsSalesDocument';
    EntitySetName = 'odsSalesDocuments';
    SourceTable = "Sales Header";
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
                field(documentType; Rec."Document Type") { Caption = 'documentType', Locked = true; ApplicationArea = All; Editable = false; }
                field(number; Rec."No.") { Caption = 'number', Locked = true; ApplicationArea = All; Editable = false; }
                field(customerNumber; Rec."Sell-to Customer No.") { Caption = 'customerNumber', Locked = true; ApplicationArea = All; Editable = false; }
                // Every normal field of the document, keyed by field number.
                field(fieldValues; FieldValuesJson) { Caption = 'fieldValues', Locked = true; ApplicationArea = All; Editable = false; }
                // Totals and shipment state Business Central works out per document.
                field(amount; Rec.Amount) { Caption = 'amount', Locked = true; ApplicationArea = All; Editable = false; }
                field(amountIncludingVat; Rec."Amount Including VAT") { Caption = 'amountIncludingVat', Locked = true; ApplicationArea = All; Editable = false; }
                field(invoiceDiscountAmount; Rec."Invoice Discount Amount") { Caption = 'invoiceDiscountAmount', Locked = true; ApplicationArea = All; Editable = false; }
                field(shipped; Rec.Shipped) { Caption = 'shipped', Locked = true; ApplicationArea = All; Editable = false; }
                field(completelyShipped; Rec."Completely Shipped") { Caption = 'completelyShipped', Locked = true; ApplicationArea = All; Editable = false; }
                field(shippedNotInvoiced; Rec."Shipped Not Invoiced") { Caption = 'shippedNotInvoiced', Locked = true; ApplicationArea = All; Editable = false; }
                field(lastShipmentDate; Rec."Last Shipment Date") { Caption = 'lastShipmentDate', Locked = true; ApplicationArea = All; Editable = false; }
                field(lateOrderShipping; Rec."Late Order Shipping") { Caption = 'lateOrderShipping', Locked = true; ApplicationArea = All; Editable = false; }
                field(numberOfArchivedVersions; Rec."No. of Archived Versions") { Caption = 'numberOfArchivedVersions', Locked = true; ApplicationArea = All; Editable = false; }
                field(hasComment; Rec.Comment) { Caption = 'hasComment', Locked = true; ApplicationArea = All; Editable = false; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'lastModifiedDateTime', Locked = true; ApplicationArea = All; Editable = false; }
            }
        }
    }

    var
        FieldReflection: Codeunit "ODS Field Reflection";
        FieldValuesJson: Text;

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields(
            Amount, "Amount Including VAT", "Invoice Discount Amount", Shipped,
            "Completely Shipped", "Shipped Not Invoiced", "Last Shipment Date",
            "Late Order Shipping", "No. of Archived Versions", Comment);
        FieldValuesJson := FieldReflection.DumpFields(Rec);
    end;
}

page 85464 "ODS Sales Document Lines"
{
    PageType = API;
    Caption = 'odsSalesDocumentLines', Locked = true;
    APIPublisher = 'opendims';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'odsSalesDocumentLine';
    EntitySetName = 'odsSalesDocumentLines';
    SourceTable = "Sales Line";
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
                field(documentType; Rec."Document Type") { Caption = 'documentType', Locked = true; ApplicationArea = All; Editable = false; }
                field(documentNumber; Rec."Document No.") { Caption = 'documentNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(lineNumber; Rec."Line No.") { Caption = 'lineNumber', Locked = true; ApplicationArea = All; Editable = false; }
                // Every normal field of the line, keyed by field number.
                field(fieldValues; FieldValuesJson) { Caption = 'fieldValues', Locked = true; ApplicationArea = All; Editable = false; }
                // What is reserved and what the warehouse still owes.
                field(reservedQuantity; Rec."Reserved Quantity") { Caption = 'reservedQuantity', Locked = true; ApplicationArea = All; Editable = false; }
                field(whseOutstandingQty; Rec."Whse. Outstanding Qty.") { Caption = 'whseOutstandingQty', Locked = true; ApplicationArea = All; Editable = false; }
                field(qtyToAssign; Rec."Qty. to Assign") { Caption = 'qtyToAssign', Locked = true; ApplicationArea = All; Editable = false; }
                field(qtyAssigned; Rec."Qty. Assigned") { Caption = 'qtyAssigned', Locked = true; ApplicationArea = All; Editable = false; }
                field(substitutionAvailable; Rec."Substitution Available") { Caption = 'substitutionAvailable', Locked = true; ApplicationArea = All; Editable = false; }
                field(postingDate; Rec."Posting Date") { Caption = 'postingDate', Locked = true; ApplicationArea = All; Editable = false; }
                field(attachedDocCount; Rec."Attached Doc Count") { Caption = 'attachedDocCount', Locked = true; ApplicationArea = All; Editable = false; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'lastModifiedDateTime', Locked = true; ApplicationArea = All; Editable = false; }
            }
        }
    }

    var
        FieldReflection: Codeunit "ODS Field Reflection";
        FieldValuesJson: Text;

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields(
            "Reserved Quantity", "Whse. Outstanding Qty.", "Qty. to Assign",
            "Qty. Assigned", "Substitution Available", "Posting Date", "Attached Doc Count");
        FieldValuesJson := FieldReflection.DumpFields(Rec);
    end;
}
