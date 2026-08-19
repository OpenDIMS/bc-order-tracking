// The buying side, mirroring the sales endpoints: open purchase documents
// (Purchase Header/Line) and the posted ones (Purch. Inv. Header/Line,
// Purch. Rcpt. Header/Line).
//
// Standard API v2.0 has nothing at all for purchase orders or receipts, so
// unlike the sales side these are the only route to any of it. Everything the
// tables hold travels in fieldValues keyed by Business Central field number,
// named by the tableFields endpoint (?$filter=tableNumber eq 38 / 39 / 122 /
// 123 / 120 / 121).
//
// Purchase Header and Line are keyed by document type, so it travels with every
// row and a caller matching on the number alone must filter on it:
//
// GET …/odsPurchaseDocuments?$filter=documentType eq 'Order' and number in ('P-ORD-1')
page 85470 "ODS Purchase Documents"
{
    PageType = API;
    Caption = 'odsPurchaseDocuments', Locked = true;
    APIPublisher = 'opendims';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'odsPurchaseDocument';
    EntitySetName = 'odsPurchaseDocuments';
    SourceTable = "Purchase Header";
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
                field(vendorNumber; Rec."Buy-from Vendor No.") { Caption = 'vendorNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(fieldValues; FieldValuesJson) { Caption = 'fieldValues', Locked = true; ApplicationArea = All; Editable = false; }
                field(amount; Rec.Amount) { Caption = 'amount', Locked = true; ApplicationArea = All; Editable = false; }
                field(amountIncludingVat; Rec."Amount Including VAT") { Caption = 'amountIncludingVat', Locked = true; ApplicationArea = All; Editable = false; }
                field(invoiceDiscountAmount; Rec."Invoice Discount Amount") { Caption = 'invoiceDiscountAmount', Locked = true; ApplicationArea = All; Editable = false; }
                field(completelyReceived; Rec."Completely Received") { Caption = 'completelyReceived', Locked = true; ApplicationArea = All; Editable = false; }
                field(partiallyInvoiced; Rec."Partially Invoiced") { Caption = 'partiallyInvoiced', Locked = true; ApplicationArea = All; Editable = false; }
                field(amtRcdNotInvoicedLcy; Rec."Amt. Rcd. Not Invoiced (LCY)") { Caption = 'amtRcdNotInvoicedLcy', Locked = true; ApplicationArea = All; Editable = false; }
                field(numberOfArchivedVersions; Rec."No. of Archived Versions") { Caption = 'numberOfArchivedVersions', Locked = true; ApplicationArea = All; Editable = false; }
                field(pendingApprovals; Rec."Pending Approvals") { Caption = 'pendingApprovals', Locked = true; ApplicationArea = All; Editable = false; }
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
            Amount, "Amount Including VAT", "Invoice Discount Amount", "Completely Received",
            "Partially Invoiced", "Amt. Rcd. Not Invoiced (LCY)", "No. of Archived Versions",
            "Pending Approvals", Comment);
        FieldValuesJson := FieldReflection.DumpFields(Rec);
    end;
}

page 85471 "ODS Purchase Document Lines"
{
    PageType = API;
    Caption = 'odsPurchaseDocumentLines', Locked = true;
    APIPublisher = 'opendims';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'odsPurchaseDocumentLine';
    EntitySetName = 'odsPurchaseDocumentLines';
    SourceTable = "Purchase Line";
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
                field(itemNumber; Rec."No.") { Caption = 'itemNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(fieldValues; FieldValuesJson) { Caption = 'fieldValues', Locked = true; ApplicationArea = All; Editable = false; }
                field(reservedQuantity; Rec."Reserved Quantity") { Caption = 'reservedQuantity', Locked = true; ApplicationArea = All; Editable = false; }
                field(qtyToAssign; Rec."Qty. to Assign") { Caption = 'qtyToAssign', Locked = true; ApplicationArea = All; Editable = false; }
                field(qtyAssigned; Rec."Qty. Assigned") { Caption = 'qtyAssigned', Locked = true; ApplicationArea = All; Editable = false; }
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
        Rec.CalcFields("Reserved Quantity", "Qty. to Assign", "Qty. Assigned", "Attached Doc Count");
        FieldValuesJson := FieldReflection.DumpFields(Rec);
    end;
}
