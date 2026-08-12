// Reflection helpers shared by the "ODS Items" and "ODS Table Fields" endpoints.
//
// Everything here walks a RecordRef instead of naming fields, so a field that
// another extension bolted onto the Item table with a tableextension is picked
// up automatically — no change to this app, no change to OpenDIMS. That is the
// whole point: OpenDIMS asks the tenant what its items look like, rather than
// shipping a fixed list of columns.
//
// Values are keyed by field number, which is the only part of a field that is
// stable across renames and across display languages.
codeunit 85455 "ODS Field Reflection"
{
    Access = Public;

    var
        ElementPrefixTok: Label 'BCField_', Locked = true;
        AllowedNameCharsTok: Label 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', Locked = true;

    /// <summary>
    /// Dump every readable, normal (non-calculated) field of a record as a JSON
    /// object keyed by field number. Empty values are written as null so that
    /// clearing a value in Business Central also clears it in OpenDIMS.
    /// </summary>
    procedure DumpFields(RecordVariant: Variant): Text
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        Values: JsonObject;
        Result: Text;
        Index: Integer;
    begin
        RecRef.GetTable(RecordVariant);
        for Index := 1 to RecRef.FieldCount() do begin
            FldRef := RecRef.FieldIndex(Index);
            if IsReadable(FldRef) then
                AddFieldValue(Values, FldRef);
        end;
        Values.WriteTo(Result);
        exit(Result);
    end;

    /// <summary>
    /// Fill a (temporary) buffer with one row per readable field on a table,
    /// including fields contributed by other extensions.
    /// </summary>
    procedure BuildCatalog(TableNo: Integer; var Buffer: Record "ODS Table Field")
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        Index: Integer;
    begin
        RecRef.Open(TableNo);
        // An API user granted only some of the permission sets should not be
        // offered fields it will never be allowed to read.
        if not RecRef.ReadPermission() then begin
            RecRef.Close();
            exit;
        end;
        for Index := 1 to RecRef.FieldCount() do begin
            FldRef := RecRef.FieldIndex(Index);
            if IsReadable(FldRef) then
                InsertCatalogRow(TableNo, FldRef, Buffer);
        end;
        RecRef.Close();
    end;

    /// <summary>
    /// The element name OpenDIMS shows in its field mapping, e.g. field 32
    /// ("Vendor Item No.") becomes BCField_32_VendorItemNo. The number keeps the
    /// mapping stable; the name only makes it readable.
    /// </summary>
    procedure ElementName(FieldNo: Integer; FieldName: Text): Text
    var
        Index: Integer;
        Character: Text[1];
        Compacted: Text;
    begin
        for Index := 1 to StrLen(FieldName) do begin
            Character := CopyStr(FieldName, Index, 1);
            if DelChr(Character, '=', AllowedNameCharsTok) = '' then
                Compacted += Character;
        end;
        exit(ElementPrefixTok + Format(FieldNo) + '_' + Compacted);
    end;

    local procedure InsertCatalogRow(TableNo: Integer; var FldRef: FieldRef; var Buffer: Record "ODS Table Field")
    begin
        Buffer.Init();
        Buffer."Table No." := TableNo;
        Buffer."Field No." := FldRef.Number();
        Buffer."Field Name" := CopyStr(FldRef.Name(), 1, MaxStrLen(Buffer."Field Name"));
        Buffer."Field Caption" := CopyStr(FldRef.Caption(), 1, MaxStrLen(Buffer."Field Caption"));
        Buffer."Data Type" := CopyStr(Format(FldRef.Type()), 1, MaxStrLen(Buffer."Data Type"));
        Buffer."Field Class" := CopyStr(Format(FldRef.Class()), 1, MaxStrLen(Buffer."Field Class"));
        Buffer."Field Length" := FldRef.Length();
        // Microsoft's own fields live below 50000; everything above is a
        // per-tenant or AppSource extension, i.e. "custom" from OpenDIMS' view.
        Buffer."Is Custom" := FldRef.Number() >= 50000;
        if FldRef.Type() = FieldType::Option then
            Buffer."Option Members" := CopyStr(FldRef.OptionMembers(), 1, MaxStrLen(Buffer."Option Members"));
        Buffer."Element Name" := CopyStr(ElementName(FldRef.Number(), FldRef.Name()), 1, MaxStrLen(Buffer."Element Name"));
        if Buffer.Insert() then;
    end;

    /// Normal fields only, and only the data types that survive a JSON round
    /// trip. Calculated (FlowField) columns are exposed as named fields on the
    /// API pages instead, so that they are only computed when they are asked for.
    local procedure IsReadable(var FldRef: FieldRef): Boolean
    begin
        if not FldRef.Active() then
            exit(false);
        if FldRef.Class() <> FieldClass::Normal then
            exit(false);
        exit(FldRef.Type() in [
            FieldType::Boolean,
            FieldType::Option,
            FieldType::Integer,
            FieldType::BigInteger,
            FieldType::Decimal,
            FieldType::Duration,
            FieldType::Text,
            FieldType::Code,
            FieldType::Date,
            FieldType::Time,
            FieldType::DateTime,
            FieldType::DateFormula,
            FieldType::GUID]);
    end;

    local procedure AddFieldValue(var Values: JsonObject; var FldRef: FieldRef)
    var
        FieldKey: Text;
        BoolValue: Boolean;
        IntValue: Integer;
        BigIntValue: BigInteger;
        DecValue: Decimal;
        DateValue: Date;
        TimeValue: Time;
        DateTimeValue: DateTime;
        DurationValue: Duration;
        GuidValue: Guid;
    begin
        FieldKey := Format(FldRef.Number());
        case FldRef.Type() of
            FieldType::Boolean:
                begin
                    BoolValue := FldRef.Value();
                    Values.Add(FieldKey, BoolValue);
                end;
            FieldType::Integer:
                begin
                    IntValue := FldRef.Value();
                    Values.Add(FieldKey, IntValue);
                end;
            FieldType::BigInteger:
                begin
                    BigIntValue := FldRef.Value();
                    Values.Add(FieldKey, BigIntValue);
                end;
            FieldType::Decimal:
                begin
                    DecValue := FldRef.Value();
                    Values.Add(FieldKey, DecValue);
                end;
            FieldType::Date:
                begin
                    DateValue := FldRef.Value();
                    if DateValue = 0D then
                        AddNull(Values, FieldKey)
                    else
                        Values.Add(FieldKey, Format(DateValue, 0, 9));
                end;
            FieldType::Time:
                begin
                    TimeValue := FldRef.Value();
                    if TimeValue = 0T then
                        AddNull(Values, FieldKey)
                    else
                        Values.Add(FieldKey, Format(TimeValue, 0, 9));
                end;
            FieldType::DateTime:
                begin
                    DateTimeValue := FldRef.Value();
                    if DateTimeValue = 0DT then
                        AddNull(Values, FieldKey)
                    else
                        Values.Add(FieldKey, Format(DateTimeValue, 0, 9));
                end;
            FieldType::Duration:
                begin
                    DurationValue := FldRef.Value();
                    Values.Add(FieldKey, Format(DurationValue, 0, 9));
                end;
            FieldType::GUID:
                begin
                    GuidValue := FldRef.Value();
                    if IsNullGuid(GuidValue) then
                        AddNull(Values, FieldKey)
                    else
                        Values.Add(FieldKey, LowerCase(DelChr(Format(GuidValue), '=', '{}')));
                end;
            else
                // Text, Code, Option, DateFormula — format code 2 keeps option
                // members and date formulas in their invariant Business Central
                // spelling instead of the API user's display language.
                AddText(Values, FieldKey, Format(FldRef.Value(), 0, 2));
        end;
    end;

    local procedure AddText(var Values: JsonObject; FieldKey: Text; Value: Text)
    begin
        if Value = '' then
            AddNull(Values, FieldKey)
        else
            Values.Add(FieldKey, Value);
    end;

    local procedure AddNull(var Values: JsonObject; FieldKey: Text)
    var
        NullValue: JsonValue;
    begin
        NullValue.SetValueToNull();
        Values.Add(FieldKey, NullValue);
    end;
}
