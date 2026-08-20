// What an item is already committed to — Business Central's "gross
// requirement", the outgoing half of its availability calculation.
//
// Business Central stores this nowhere: the Item Availability page computes it
// on the spot in codeunit 353 "Item Availability Forms Mgt". A webshop that
// wants an honest stock figure needs exactly this number, because
// `Inventory - grossRequirement` is what is really on the shelf and unsold,
// with nothing counted that has not arrived yet.
//
// The sum mirrors CalculateNeed() in that codeunit for the company-wide case.
// Business Central itself zeroes the three transfer quantities when no Location
// Filter is set — a transfer between a company's own locations is not a net
// outflow — so they are absent here for the same reason, and the figure matches
// what the item card shows with no location filter applied.
//
// It is a separate endpoint rather than a column on odsItems so that an
// integration which does not map it pays nothing: these are calculated columns,
// and Business Central works out every one of them per item.
//
// GET /api/opendims/integration/v1.0/companies({companyId})/itemAvailabilities
//     ?$filter=number in ('A','B')
page 85488 "ODS Item Availability"
{
    PageType = API;
    Caption = 'itemAvailability', Locked = true;
    APIPublisher = 'opendims';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'itemAvailability';
    EntitySetName = 'itemAvailabilities';
    SourceTable = Item;
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
                field(grossRequirement; GrossRequirement) { Caption = 'grossRequirement', Locked = true; ApplicationArea = All; Editable = false; }
                // Published because it is the one component of the sum that no
                // other OpenDIMS endpoint offers, and it is already calculated
                // here, so it costs nothing extra.
                field(planningIssuesQty; Rec."Planning Issues (Qty.)") { Caption = 'planningIssuesQty', Locked = true; ApplicationArea = All; Editable = false; }
            }
        }
    }

    var
        GrossRequirement: Decimal;

    trigger OnAfterGetRecord()
    var
        JobPlanningLine: Record "Job Planning Line";
    begin
        Rec.CalcFields(
            "Qty. on Sales Order",
            "Qty. on Service Order",
            "Qty. on Component Lines",
            "Planning Issues (Qty.)",
            "Qty. on Asm. Component",
            "Qty. on Purch. Return");
        GrossRequirement :=
            Rec."Qty. on Sales Order" + Rec."Qty. on Service Order" + Rec."Qty. on Component Lines" +
            Rec."Planning Issues (Qty.)" + Rec."Qty. on Asm. Component" + Rec."Qty. on Purch. Return";

        // The same guard the platform applies: without read permission on job
        // planning lines the FlowField cannot be calculated at all. Business
        // Central leaves it out rather than failing, and so does this — which
        // means a client without that permission gets a figure that omits job
        // demand, quietly. Grant OPENDIMS ITEMS's Job Planning Line read to a
        // customer who uses jobs.
        if JobPlanningLine.ReadPermission then begin
            Rec.CalcFields("Qty. on Job Order");
            GrossRequirement += Rec."Qty. on Job Order";
        end;
    end;
}
