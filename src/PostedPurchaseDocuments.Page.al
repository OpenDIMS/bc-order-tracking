// The posted purchase documents: invoices (Purch. Inv. Header/Line) and
// receipts (Purch. Rcpt. Header/Line). Both are keyed by "No." on the header
// and (Document No., Line No.) on the line, so a caller reads a whole document
// at once and needs no document-type filter.
//
// Microsoft publishes a postedPurchaseInvoices resource of its own on the older
// api/v1.0 surface; these live under the opendims publisher and, unlike it,
// carry every field of the record rather than a fixed subset — and a receipt
// has no standard resource at all.
//
// GET …/postedPurchaseInvoices?$filter=number in ('PP-INV-1')
// GET …/postedPurchaseReceiptLines?$filter=documentNumber in ('PP-RCPT-1')
page 85472 "ODS Posted Purch. Invoices"
{
    PageType = API;
    Caption = 'postedPurchaseInvoices', Locked = true;
    APIPublisher = 'opendims';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'postedPurchaseInvoice';
    EntitySetName = 'postedPurchaseInvoices';
    SourceTable = "Purch. Inv. Header";
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
                field(number; Rec."No.") { Caption = 'number', Locked = true; ApplicationArea = All; Editable = false; }
                field(vendorNumber; Rec."Buy-from Vendor No.") { Caption = 'vendorNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(orderNumber; Rec."Order No.") { Caption = 'orderNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(fieldValues; FieldValuesJson) { Caption = 'fieldValues', Locked = true; ApplicationArea = All; Editable = false; }
                field(amount; Rec.Amount) { Caption = 'amount', Locked = true; ApplicationArea = All; Editable = false; }
                field(amountIncludingVat; Rec."Amount Including VAT") { Caption = 'amountIncludingVat', Locked = true; ApplicationArea = All; Editable = false; }
                field(remainingAmount; Rec."Remaining Amount") { Caption = 'remainingAmount', Locked = true; ApplicationArea = All; Editable = false; }
                field(invoiceDiscountAmount; Rec."Invoice Discount Amount") { Caption = 'invoiceDiscountAmount', Locked = true; ApplicationArea = All; Editable = false; }
                field(closed; Rec.Closed) { Caption = 'closed', Locked = true; ApplicationArea = All; Editable = false; }
                field(cancelled; Rec.Cancelled) { Caption = 'cancelled', Locked = true; ApplicationArea = All; Editable = false; }
                field(corrective; Rec.Corrective) { Caption = 'corrective', Locked = true; ApplicationArea = All; Editable = false; }
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
            Amount, "Amount Including VAT", "Remaining Amount", "Invoice Discount Amount",
            Closed, Cancelled, Corrective, Comment);
        FieldValuesJson := FieldReflection.DumpFields(Rec);
    end;
}

page 85473 "ODS Posted Purch. Inv. Lines"
{
    PageType = API;
    Caption = 'postedPurchaseInvoiceLines', Locked = true;
    APIPublisher = 'opendims';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'postedPurchaseInvoiceLine';
    EntitySetName = 'postedPurchaseInvoiceLines';
    SourceTable = "Purch. Inv. Line";
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
                // This table has no calculated columns, so the dump is all of it.
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

page 85474 "ODS Posted Purch. Receipts"
{
    PageType = API;
    Caption = 'postedPurchaseReceipts', Locked = true;
    APIPublisher = 'opendims';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'postedPurchaseReceipt';
    EntitySetName = 'postedPurchaseReceipts';
    SourceTable = "Purch. Rcpt. Header";
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
                field(number; Rec."No.") { Caption = 'number', Locked = true; ApplicationArea = All; Editable = false; }
                field(vendorNumber; Rec."Buy-from Vendor No.") { Caption = 'vendorNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(orderNumber; Rec."Order No.") { Caption = 'orderNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(fieldValues; FieldValuesJson) { Caption = 'fieldValues', Locked = true; ApplicationArea = All; Editable = false; }
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
        Rec.CalcFields(Comment);
        FieldValuesJson := FieldReflection.DumpFields(Rec);
    end;
}

page 85475 "ODS Posted Purch. Rcpt. Lines"
{
    PageType = API;
    Caption = 'postedPurchaseReceiptLines', Locked = true;
    APIPublisher = 'opendims';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'postedPurchaseReceiptLine';
    EntitySetName = 'postedPurchaseReceiptLines';
    SourceTable = "Purch. Rcpt. Line";
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
