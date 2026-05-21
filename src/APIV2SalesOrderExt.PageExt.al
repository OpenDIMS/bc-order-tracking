/// <summary>
/// Extends the standard APIV2 Sales Orders endpoint with the shipment / tracking
/// fields that exist on the Sales Header table but are not surfaced by Microsoft's
/// default v2.0 API. OpenDIMS reads these to send tracking info back to the webshop.
/// </summary>
pageextension 50100 "ODS APIV2 Sales Order Ext" extends "APIV2 - Sales Orders"
{
    layout
    {
        addlast(Group)
        {
            field(packageTrackingNumber; Rec."Package Tracking No.")
            {
                Caption = 'packageTrackingNumber', Locked = true;
                ApplicationArea = All;
            }
            field(shipmentDate; Rec."Shipment Date")
            {
                Caption = 'shipmentDate', Locked = true;
                ApplicationArea = All;
            }
            field(shippingAgentCode; Rec."Shipping Agent Code")
            {
                Caption = 'shippingAgentCode', Locked = true;
                ApplicationArea = All;
            }
            field(shippingAgentServiceCode; Rec."Shipping Agent Service Code")
            {
                Caption = 'shippingAgentServiceCode', Locked = true;
                ApplicationArea = All;
            }
        }
    }
}
