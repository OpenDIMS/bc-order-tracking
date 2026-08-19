// The cost of a product that is assembled from other products.
//
// Business Central shows this on the item card as "Standard Cost" — but that is
// whatever the last run of "Calculate Standard Cost" wrote there, which may be
// stale or never have run. calculatedBomCost rolls the assembly BOM up again on
// the spot, without writing anything back.
//
// It is a separate endpoint from odsItems on purpose: the roll-up walks the BOM
// tree per item, so it is only paid for by an integration that maps it.
//
// GET /api/opendims/integration/v1.0/companies({companyId})/itemBomCosts
//     ?$filter=number in ('A','B')
page 85459 "ODS Item BOM Costs"
{
    PageType = API;
    Caption = 'itemBomCosts', Locked = true;
    APIPublisher = 'opendims';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'itemBomCost';
    EntitySetName = 'itemBomCosts';
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
                field(assemblyBom; Rec."Assembly BOM") { Caption = 'assemblyBom', Locked = true; ApplicationArea = All; Editable = false; }
                field(componentCount; ComponentCount) { Caption = 'componentCount', Locked = true; ApplicationArea = All; Editable = false; }
                field(calculatedBomCost; CalculatedBomCost) { Caption = 'calculatedBomCost', Locked = true; ApplicationArea = All; Editable = false; }
                field(standardCost; Rec."Standard Cost") { Caption = 'standardCost', Locked = true; ApplicationArea = All; Editable = false; }
                field(unitCost; Rec."Unit Cost") { Caption = 'unitCost', Locked = true; ApplicationArea = All; Editable = false; }
                field(lastDirectCost; Rec."Last Direct Cost") { Caption = 'lastDirectCost', Locked = true; ApplicationArea = All; Editable = false; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'lastModifiedDateTime', Locked = true; ApplicationArea = All; Editable = false; }
            }
        }
    }

    var
        BomCost: Codeunit "ODS BOM Cost";
        CalculatedBomCost: Decimal;
        ComponentCount: Integer;

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Assembly BOM");
        ComponentCount := 0;
        CalculatedBomCost := 0;
        if Rec."Assembly BOM" then begin
            ComponentCount := BomCost.ComponentLineCount(Rec."No.");
            CalculatedBomCost := BomCost.CalculateBomCost(Rec."No.");
        end;
    end;
}
