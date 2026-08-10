// Read-only API page over Customer Discount Group (table 340) —
// "Debitorrabatgrupper". Maps to the webshop side's customer discount groups
// (Hostedshop DiscountGroup / Kunderabatgruppe).
//
// GET /api/opendims/integration/v1.0/companies({companyId})/customerDiscountGroups
page 85448 "ODS Customer Discount Groups"
{
    PageType = API;
    Caption = 'customerDiscountGroups', Locked = true;
    APIPublisher = 'opendims';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'customerDiscountGroup';
    EntitySetName = 'customerDiscountGroups';
    SourceTable = "Customer Discount Group";
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
