// The item attribute catalogue — the names behind the numbers in
// itemAttributeValues.attributeValues, exactly as tableFields names the numbers
// in odsItems.fieldValues.
//
// Business Central keeps product specifications like "Effekt (watt)" or
// "Panelgaranti" as item attributes rather than as fields on the item, in three
// tables: the attribute itself (7500), its allowed values (7501) and which item
// carries which value (7502). None of that reaches the standard v2.0 API, and
// none of it is on the item card, so an integration that only reads the item
// sees nothing of it.
//
// elementName is what OpenDIMS shows in its field mapping, so this app decides
// the name once and OpenDIMS never has to guess it — the same contract
// tableFields has.
//
// GET /api/opendims/integration/v1.0/companies({companyId})/itemAttributes
page 85489 "ODS Item Attributes"
{
    PageType = API;
    Caption = 'itemAttribute', Locked = true;
    APIPublisher = 'opendims';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'itemAttribute';
    EntitySetName = 'itemAttributes';
    SourceTable = "Item Attribute";
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
                field(attributeId; Rec.ID) { Caption = 'attributeId', Locked = true; ApplicationArea = All; Editable = false; }
                field(name; Rec.Name) { Caption = 'name', Locked = true; ApplicationArea = All; Editable = false; }
                // Text, Integer, Decimal, Option or Date — OpenDIMS reads this to
                // give the mapped field the right type instead of storing
                // everything as text.
                field(type; TypeName) { Caption = 'type', Locked = true; ApplicationArea = All; Editable = false; }
                field(unitOfMeasure; Rec."Unit of Measure") { Caption = 'unitOfMeasure', Locked = true; ApplicationArea = All; Editable = false; }
                field(blocked; Rec.Blocked) { Caption = 'blocked', Locked = true; ApplicationArea = All; Editable = false; }
                field(elementName; ElementNameText) { Caption = 'elementName', Locked = true; ApplicationArea = All; Editable = false; }
            }
        }
    }

    var
        TypeName: Text;
        ElementNameText: Text;
        ElementPrefixTok: Label 'BCAttr_', Locked = true;
        AllowedNameCharsTok: Label 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', Locked = true;

    trigger OnAfterGetRecord()
    begin
        TypeName := Format(Rec.Type, 0, 9);
        ElementNameText := AttributeElementName(Rec.ID, Rec.Name);
    end;

    // The same shape as ODS Field Reflection's ElementName, so an attribute and a
    // field are named the same way: prefix, number, and the name with everything
    // that is not a letter or a digit taken out.
    local procedure AttributeElementName(AttributeId: Integer; AttributeName: Text): Text
    var
        Index: Integer;
        Character: Text[1];
        Compacted: Text;
    begin
        for Index := 1 to StrLen(AttributeName) do begin
            Character := CopyStr(AttributeName, Index, 1);
            if DelChr(Character, '=', AllowedNameCharsTok) = '' then
                Compacted += Character;
        end;
        exit(ElementPrefixTok + Format(AttributeId) + '_' + Compacted);
    end;
}
