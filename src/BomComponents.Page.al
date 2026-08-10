// Read-only API page over BOM Component (table 90) — the assembly BOM lines
// that make up a "product consisting of other products". Standard BC API v2.0
// does not expose assembly BOMs at all, so OpenDIMS reads them from here to
// import product component lists.
//
// GET /api/opendims/integration/v1.0/companies({companyId})/bomComponents
//     ?$filter=parentItemNumber in ('A','B')
page 85447 "ODS BOM Components"
{
    PageType = API;
    Caption = 'bomComponents', Locked = true;
    APIPublisher = 'opendims';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'bomComponent';
    EntitySetName = 'bomComponents';
    SourceTable = "BOM Component";
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
                field(parentItemNumber; Rec."Parent Item No.") { Caption = 'parentItemNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(lineNumber; Rec."Line No.") { Caption = 'lineNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(type; Rec.Type) { Caption = 'type', Locked = true; ApplicationArea = All; Editable = false; }
                field(number; Rec."No.") { Caption = 'number', Locked = true; ApplicationArea = All; Editable = false; }
                field(description; Rec.Description) { Caption = 'description', Locked = true; ApplicationArea = All; Editable = false; }
                field(quantityPer; Rec."Quantity per") { Caption = 'quantityPer', Locked = true; ApplicationArea = All; Editable = false; }
                field(unitOfMeasureCode; Rec."Unit of Measure Code") { Caption = 'unitOfMeasureCode', Locked = true; ApplicationArea = All; Editable = false; }
                field(variantCode; Rec."Variant Code") { Caption = 'variantCode', Locked = true; ApplicationArea = All; Editable = false; }
                field(position; Rec.Position) { Caption = 'position', Locked = true; ApplicationArea = All; Editable = false; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'lastModifiedDateTime', Locked = true; ApplicationArea = All; Editable = false; }
            }
        }
    }
}
