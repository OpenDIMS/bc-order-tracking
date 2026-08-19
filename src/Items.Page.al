// Read-only API page over Item (table 27) that hands OpenDIMS everything the
// standard v2.0 "items" endpoint leaves out — including the fields another
// extension added to the item card on this tenant.
//
// The bulk of it travels in the fieldValues column: a JSON object holding every
// readable, non-calculated field of the item keyed by its Business Central
// field number (32 = "Vendor Item No.", 24 = "Standard Cost", and so on). The
// companion "tableFields" endpoint names those numbers, so OpenDIMS can offer
// them for mapping without this app knowing what they are.
//
// Calculated (FlowField) columns cannot travel that way — they have to be
// computed one at a time — so the ones from the item card are named here.
//
// Other extensions may add typed columns with a pageextension; anything they
// add shows up in $metadata and OpenDIMS will offer it too.
//
// GET /api/opendims/integration/v1.0/companies({companyId})/odsItems
//     ?$filter=number in ('A','B')&$select=number,fieldValues
page 85457 "ODS Items"
{
    PageType = API;
    Caption = 'odsItems', Locked = true;
    APIPublisher = 'opendims';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'odsItem';
    EntitySetName = 'odsItems';
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
                field(displayName; Rec.Description) { Caption = 'displayName', Locked = true; ApplicationArea = All; Editable = false; }
                // Every normal field of the item, keyed by field number.
                field(fieldValues; FieldValuesJson) { Caption = 'fieldValues', Locked = true; ApplicationArea = All; Editable = false; }
                // Calculated columns from the item card's Inventory group.
                field(assemblyBom; Rec."Assembly BOM") { Caption = 'assemblyBom', Locked = true; ApplicationArea = All; Editable = false; }
                field(inventory; Rec.Inventory) { Caption = 'inventory', Locked = true; ApplicationArea = All; Editable = false; }
                field(qtyOnPurchOrder; Rec."Qty. on Purch. Order") { Caption = 'qtyOnPurchOrder', Locked = true; ApplicationArea = All; Editable = false; }
                field(qtyOnSalesOrder; Rec."Qty. on Sales Order") { Caption = 'qtyOnSalesOrder', Locked = true; ApplicationArea = All; Editable = false; }
                field(qtyOnAssemblyOrder; Rec."Qty. on Assembly Order") { Caption = 'qtyOnAssemblyOrder', Locked = true; ApplicationArea = All; Editable = false; }
                field(qtyOnAsmComponent; Rec."Qty. on Asm. Component") { Caption = 'qtyOnAsmComponent', Locked = true; ApplicationArea = All; Editable = false; }
                field(qtyOnJobOrder; Rec."Qty. on Job Order") { Caption = 'qtyOnJobOrder', Locked = true; ApplicationArea = All; Editable = false; }
                field(qtyInTransit; Rec."Qty. in Transit") { Caption = 'qtyInTransit', Locked = true; ApplicationArea = All; Editable = false; }
                field(qtyOnPurchReturn; Rec."Qty. on Purch. Return") { Caption = 'qtyOnPurchReturn', Locked = true; ApplicationArea = All; Editable = false; }
                field(qtyOnSalesReturn; Rec."Qty. on Sales Return") { Caption = 'qtyOnSalesReturn', Locked = true; ApplicationArea = All; Editable = false; }
                field(costIsPostedToGL; Rec."Cost is Posted to G/L") { Caption = 'costIsPostedToGL', Locked = true; ApplicationArea = All; Editable = false; }
                field(substitutesExist; Rec."Substitutes Exist") { Caption = 'substitutesExist', Locked = true; ApplicationArea = All; Editable = false; }
                field(stockkeepingUnitExists; Rec."Stockkeeping Unit Exists") { Caption = 'stockkeepingUnitExists', Locked = true; ApplicationArea = All; Editable = false; }
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
            "Assembly BOM",
            Inventory,
            "Qty. on Purch. Order",
            "Qty. on Sales Order",
            "Qty. on Assembly Order",
            "Qty. on Asm. Component",
            "Qty. on Job Order",
            "Qty. in Transit",
            "Qty. on Purch. Return",
            "Qty. on Sales Return",
            "Cost is Posted to G/L",
            "Substitutes Exist",
            "Stockkeeping Unit Exists");
        FieldValuesJson := FieldReflection.DumpFields(Rec);
    end;
}
