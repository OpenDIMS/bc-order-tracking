// What each item's attributes are actually set to, one row per item, with the
// values in a JSON object keyed by attribute id — the same shape odsItems uses
// for fieldValues, so OpenDIMS decodes it the way it already decodes those.
//
// The join lives here on purpose. Business Central spreads an item's
// specifications over three tables — the mapping (7502) carries only ids, the
// value (7501) holds the text and the number, and the attribute (7500) holds the
// name — and an integration reading them separately would have to reassemble
// them over the network, per item, in the wrong place. Here it is one query
// against tables that are already indexed for it.
//
// A separate endpoint rather than a column on odsItems, because this costs a
// read per item: an integration that maps no attribute never pays for it.
//
// GET /api/opendims/integration/v1.0/companies({companyId})/itemAttributeValues
//     ?$filter=number eq '10464250'
page 85490 "ODS Item Attribute Values"
{
    PageType = API;
    Caption = 'itemAttributeValue', Locked = true;
    APIPublisher = 'opendims';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'itemAttributeValue';
    EntitySetName = 'itemAttributeValues';
    SourceTable = Item;
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    Editable = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId) { Caption = 'id', Locked = true; ApplicationArea = All; Editable = false; }
                field(number; Rec."No.") { Caption = 'number', Locked = true; ApplicationArea = All; Editable = false; }
                field(attributeValues; AttributeValuesJson) { Caption = 'attributeValues', Locked = true; ApplicationArea = All; Editable = false; }
            }
        }
    }

    var
        AttributeValuesJson: Text;

    trigger OnAfterGetRecord()
    begin
        AttributeValuesJson := BuildAttributeValues(Rec."No.");
    end;

    /// <summary>
    /// The item's attributes as {"3": 425.0, "9": "Sort"} — the attribute id
    /// against its value, a number where the attribute is numeric and a string
    /// otherwise.
    ///
    /// Numeric attributes travel as numbers rather than as their text, because
    /// the text is whatever the last person to type it saw: "20,8" in Danish and
    /// "20.8" in English, from the same row. Reading Numeric Value keeps the
    /// answer the same in every company on the tenant.
    /// </summary>
    local procedure BuildAttributeValues(ItemNo: Code[20]): Text
    var
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
        ItemAttributeValue: Record "Item Attribute Value";
        ItemAttribute: Record "Item Attribute";
        Values: JsonObject;
        Result: Text;
        AttributeKey: Text;
    begin
        // Without read permission the platform would throw rather than answer,
        // and one unreadable table must not take the whole item import with it —
        // an integration that maps no attribute would still be reading this.
        if not ItemAttributeValueMapping.ReadPermission() then
            exit('');
        if not ItemAttributeValue.ReadPermission() then
            exit('');

        ItemAttributeValueMapping.SetRange("Table ID", Database::Item);
        ItemAttributeValueMapping.SetRange("No.", ItemNo);
        if ItemAttributeValueMapping.FindSet() then
            repeat
                if ItemAttributeValue.Get(
                    ItemAttributeValueMapping."Item Attribute ID",
                    ItemAttributeValueMapping."Item Attribute Value ID")
                then begin
                    AttributeKey := Format(ItemAttributeValue."Attribute ID");
                    if not ItemAttribute.Get(ItemAttributeValue."Attribute ID") then
                        Clear(ItemAttribute);
                    case ItemAttribute.Type of
                        ItemAttribute.Type::Integer,
                        ItemAttribute.Type::Decimal:
                            Values.Add(AttributeKey, ItemAttributeValue."Numeric Value");
                        else
                            Values.Add(AttributeKey, ItemAttributeValue.Value);
                    end;
                end;
            until ItemAttributeValueMapping.Next() = 0;

        if Values.Keys().Count() = 0 then
            exit('');
        Values.WriteTo(Result);
        exit(Result);
    end;
}
