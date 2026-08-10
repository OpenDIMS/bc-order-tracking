/// <summary>
/// Read-only API endpoint over Posted Sales Invoice Header.
/// Surfaces the link from an invoice back to its source sales order, so OpenDIMS can
/// chain salesInvoices → orderNumber → salesShipments to attach tracking data to invoices.
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
            }
        }
    }
}
