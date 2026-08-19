/// <summary>
/// Read-only API endpoint over Posted Sales Shipment Header.
/// Reachable at /api/opendims/integration/v1.0/companies({id})/salesShipments
/// once the extension is installed on the tenant.
/// </summary>
page 85445 "ODS Posted Sales Shipments"
{
    PageType = API;
    Caption = 'salesShipments', Locked = true;
    APIPublisher = 'opendims';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'salesShipment';
    EntitySetName = 'salesShipments';
    SourceTable = "Sales Shipment Header";
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
                field(number; Rec."No.")
                {
                    Caption = 'number', Locked = true;
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
                field(customerName; Rec."Sell-to Customer Name")
                {
                    Caption = 'customerName', Locked = true;
                    ApplicationArea = All;
                    Editable = false;
                }
                field(shipmentDate; Rec."Shipment Date")
                {
                    Caption = 'shipmentDate', Locked = true;
                    ApplicationArea = All;
                    Editable = false;
                }
                field(packageTrackingNumber; Rec."Package Tracking No.")
                {
                    Caption = 'packageTrackingNumber', Locked = true;
                    ApplicationArea = All;
                    Editable = false;
                }
                field(shippingAgentCode; Rec."Shipping Agent Code")
                {
                    Caption = 'shippingAgentCode', Locked = true;
                    ApplicationArea = All;
                    Editable = false;
                }
                field(shippingAgentServiceCode; Rec."Shipping Agent Service Code")
                {
                    Caption = 'shippingAgentServiceCode', Locked = true;
                    ApplicationArea = All;
                    Editable = false;
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'lastModifiedDateTime', Locked = true;
                    ApplicationArea = All;
                    Editable = false;
                }
                // Every normal field of the posted shipment, keyed by field
                // number — the other 100 the tracking fields above sit among.
                field(fieldValues; FieldValuesJson) { Caption = 'fieldValues', Locked = true; ApplicationArea = All; Editable = false; }
                field(hasComment; Rec.Comment) { Caption = 'hasComment', Locked = true; ApplicationArea = All; Editable = false; }
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
