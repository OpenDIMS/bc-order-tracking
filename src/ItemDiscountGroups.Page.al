// Read-only API page over Item Discount Group (table 341) —
// "Varerabatgrupper". Maps to the webshop side's product discount groups
// (Hostedshop DiscountGroupProduct / Produktrabatgruppe).
//
// GET /api/opendims/integration/v1.0/companies({companyId})/itemDiscountGroups
page 85449 "ODS Item Discount Groups"
{
    PageType = API;
    Caption = 'itemDiscountGroups', Locked = true;
    APIPublisher = 'opendims';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'itemDiscountGroup';
    EntitySetName = 'itemDiscountGroups';
    SourceTable = "Item Discount Group";
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
                field(code; Rec.Code) { Caption = 'code', Locked = true; ApplicationArea = All; Editable = false; }
                field(description; Rec.Description) { Caption = 'description', Locked = true; ApplicationArea = All; Editable = false; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'lastModifiedDateTime', Locked = true; ApplicationArea = All; Editable = false; }
            }
        }
    }
}
