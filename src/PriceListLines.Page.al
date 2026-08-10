// Read-only API page over Price List Line (table 7001) — the modern (BC16+)
// pricing lines ("Salgsprisaftaler"), incl. the customer-group × item-group
// line discounts that standard API v2.0 does not expose. OpenDIMS imports
// these to drive webshop discount-matrix sync.
//
// GET /api/opendims/integration/v1.0/companies({companyId})/priceListLines
//     ?$filter=status eq 'Active' and priceType eq 'Sale'
page 85450 "ODS Price List Lines"
{
    PageType = API;
    Caption = 'priceListLines', Locked = true;
    APIPublisher = 'opendims';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'priceListLine';
    EntitySetName = 'priceListLines';
    SourceTable = "Price List Line";
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
                field(priceListCode; Rec."Price List Code") { Caption = 'priceListCode', Locked = true; ApplicationArea = All; Editable = false; }
                field(lineNumber; Rec."Line No.") { Caption = 'lineNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(status; Rec.Status) { Caption = 'status', Locked = true; ApplicationArea = All; Editable = false; }
                field(priceType; Rec."Price Type") { Caption = 'priceType', Locked = true; ApplicationArea = All; Editable = false; }
                field(sourceType; Rec."Source Type") { Caption = 'sourceType', Locked = true; ApplicationArea = All; Editable = false; }
                field(sourceNumber; Rec."Source No.") { Caption = 'sourceNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(assetType; Rec."Asset Type") { Caption = 'assetType', Locked = true; ApplicationArea = All; Editable = false; }
                field(assetNumber; Rec."Asset No.") { Caption = 'assetNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(variantCode; Rec."Variant Code") { Caption = 'variantCode', Locked = true; ApplicationArea = All; Editable = false; }
                field(unitOfMeasureCode; Rec."Unit of Measure Code") { Caption = 'unitOfMeasureCode', Locked = true; ApplicationArea = All; Editable = false; }
                field(minimumQuantity; Rec."Minimum Quantity") { Caption = 'minimumQuantity', Locked = true; ApplicationArea = All; Editable = false; }
                field(amountType; Rec."Amount Type") { Caption = 'amountType', Locked = true; ApplicationArea = All; Editable = false; }
                field(unitPrice; Rec."Unit Price") { Caption = 'unitPrice', Locked = true; ApplicationArea = All; Editable = false; }
                field(lineDiscountPercent; Rec."Line Discount %") { Caption = 'lineDiscountPercent', Locked = true; ApplicationArea = All; Editable = false; }
                field(currencyCode; Rec."Currency Code") { Caption = 'currencyCode', Locked = true; ApplicationArea = All; Editable = false; }
                field(startingDate; Rec."Starting Date") { Caption = 'startingDate', Locked = true; ApplicationArea = All; Editable = false; }
                field(endingDate; Rec."Ending Date") { Caption = 'endingDate', Locked = true; ApplicationArea = All; Editable = false; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'lastModifiedDateTime', Locked = true; ApplicationArea = All; Editable = false; }
            }
        }
    }
}
