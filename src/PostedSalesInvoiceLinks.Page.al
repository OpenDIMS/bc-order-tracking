/// <summary>
/// Read-only API endpoint over Posted Sales Invoice Header.
/// Surfaces the link from an invoice back to its source sales order, so OpenDIMS can
/// chain salesInvoices → orderNumber → salesShipments to attach tracking data to invoices,
/// and — through fieldValues — the other 115 fields a posted invoice carries that the
/// standard v2.0 API does not publish. The table's own key is just "No.".
///
/// Reachable at /api/opendims/integration/v1.0/companies({id})/salesInvoiceLinks
/// once the extension is installed on the tenant.
/// </summary>
page 85446 "ODS Sales Invoice Links"
{
    PageType = API;
    Caption = 'salesInvoiceLinks', Locked = true;
    APIPublisher = 'opendims';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'salesInvoiceLink';
    EntitySetName = 'salesInvoiceLinks';
    SourceTable = "Sales Invoice Header";
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'id', Locked = true;
                    ApplicationArea = All;
                    Editable = false;
                }
                field(invoiceNumber; Rec."No.")
                {
                    Caption = 'invoiceNumber', Locked = true;
                    ApplicationArea = All;
                    Editable = false;
                }
                field(orderNumber; Rec."Order No.")
                {
                    Caption = 'orderNumber', Locked = true;
                    ApplicationArea = All;
                    Editable = false;
                }
                field(externalDocumentNumber; Rec."External Document No.")
                {
                    Caption = 'externalDocumentNumber', Locked = true;
                    ApplicationArea = All;
                    Editable = false;
                }
                field(customerNumber; Rec."Sell-to Customer No.")
                {
                    Caption = 'customerNumber', Locked = true;
                    ApplicationArea = All;
                    Editable = false;
                }
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'postingDate', Locked = true;
                    ApplicationArea = All;
                    Editable = false;
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'lastModifiedDateTime', Locked = true;
                    ApplicationArea = All;
                    Editable = false;
                }
                // Every normal field of the posted invoice, keyed by field number.
                field(fieldValues; FieldValuesJson) { Caption = 'fieldValues', Locked = true; ApplicationArea = All; Editable = false; }
                // Totals and state Business Central works out per invoice.
                field(amount; Rec.Amount) { Caption = 'amount', Locked = true; ApplicationArea = All; Editable = false; }
                field(amountIncludingVat; Rec."Amount Including VAT") { Caption = 'amountIncludingVat', Locked = true; ApplicationArea = All; Editable = false; }
                field(remainingAmount; Rec."Remaining Amount") { Caption = 'remainingAmount', Locked = true; ApplicationArea = All; Editable = false; }
                field(invoiceDiscountAmount; Rec."Invoice Discount Amount") { Caption = 'invoiceDiscountAmount', Locked = true; ApplicationArea = All; Editable = false; }
                field(closed; Rec.Closed) { Caption = 'closed', Locked = true; ApplicationArea = All; Editable = false; }
                field(cancelled; Rec.Cancelled) { Caption = 'cancelled', Locked = true; ApplicationArea = All; Editable = false; }
                field(corrective; Rec.Corrective) { Caption = 'corrective', Locked = true; ApplicationArea = All; Editable = false; }
                field(reversed; Rec.Reversed) { Caption = 'reversed', Locked = true; ApplicationArea = All; Editable = false; }
                field(sentAsEmail; Rec."Sent as Email") { Caption = 'sentAsEmail', Locked = true; ApplicationArea = All; Editable = false; }
                field(lastEmailSentTime; Rec."Last Email Sent Time") { Caption = 'lastEmailSentTime', Locked = true; ApplicationArea = All; Editable = false; }
                field(hasComment; Rec.Comment) { Caption = 'hasComment', Locked = true; ApplicationArea = All; Editable = false; }
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
            Closed, Cancelled, Corrective, Reversed, "Sent as Email", "Last Email Sent Time", Comment);
        FieldValuesJson := FieldReflection.DumpFields(Rec);
    end;
}
