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
        NotAJsonObjectErr: Label 'setFieldValues must be a JSON object keyed by field number.';
        NotAFieldNumberErr: Label 'The key "%1" in setFieldValues is not a field number.', Comment = '%1 = the key';
        NoSuchFieldErr: Label 'Field %1 does not exist on table %2.', Comment = '%1 = field number, %2 = table number';
        NotWritableErr: Label 'Field %1 (%2) cannot be written through setFieldValues: only normal fields of the plain data types can.', Comment = '%1 = field name, %2 = field number';
        BadValueErr: Label 'The value "%1" is not valid for field %2.', Comment = '%1 = the value, %2 = field name';

    /// <summary>
    /// Dump every readable, normal (non-calculated) field of a record as a JSON
    /// object keyed by field number. Empty values are written as null so that
    /// clearing a value in Business Central also clears it in OpenDIMS.
    /// </summary>
    procedure DumpFields(RecordVariant: Variant): Text
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(RecordVariant);
        exit(DumpRecordRef(RecRef));
    end;

    /// <summary>Same, for a record already open as a RecordRef.</summary>
    procedure DumpRecordRef(var RecRef: RecordRef): Text
    var
        FldRef: FieldRef;
        Values: JsonObject;
        Result: Text;
        Index: Integer;
    begin
        for Index := 1 to RecRef.FieldCount() do begin
            FldRef := RecRef.FieldIndex(Index);
            if IsReadable(FldRef) then
                AddFieldValue(Values, FldRef);
        end;
        Values.WriteTo(Result);
        exit(Result);
    end;

    /// <summary>
    /// Write values into a record from a JSON object keyed by field number — the
    /// same shape DumpFields produces — validating each through the field's own
    /// OnValidate. Only normal fields of the readable types are accepted; a key
    /// naming anything else, or a value the field refuses, raises an error the
    /// API caller sees as a 400 with the message.
    /// </summary>
    procedure ApplyFields(var RecRef: RecordRef; ValuesJson: Text)
    var
        Values: JsonObject;
        Keys: List of [Text];
        FieldKey: Text;
        FieldNo: Integer;
        Token: JsonToken;
        FldRef: FieldRef;
    begin
        if ValuesJson = '' then
            exit;
        if not Values.ReadFrom(ValuesJson) then
            Error(NotAJsonObjectErr);
        Keys := Values.Keys();
        foreach FieldKey in Keys do begin
            if not Evaluate(FieldNo, FieldKey) then
                Error(NotAFieldNumberErr, FieldKey);
            if not RecRef.FieldExist(FieldNo) then
                Error(NoSuchFieldErr, FieldNo, RecRef.Number());
            FldRef := RecRef.Field(FieldNo);
            if not IsReadable(FldRef) then
                Error(NotWritableErr, FldRef.Name(), FieldNo);
            Values.Get(FieldKey, Token);
            SetFieldValue(FldRef, Token);
        end;
    end;

    local procedure SetFieldValue(var FldRef: FieldRef; Token: JsonToken)
    var
        TextValue: Text;
        BoolValue: Boolean;
        IntValue: Integer;
        BigIntValue: BigInteger;
        DecValue: Decimal;
        DateValue: Date;
        TimeValue: Time;
        DateTimeValue: DateTime;
        GuidValue: Guid;
        DateFormulaValue: DateFormula;
        Ordinal: Integer;
    begin
        if Token.AsValue().IsNull() then begin
            ClearFieldValue(FldRef);
            exit;
        end;
        case FldRef.Type() of
            FieldType::Boolean:
                begin
                    // AsText() reads a JSON true/false as "true"/"false" and a string as itself.
                    TextValue := Token.AsValue().AsText();
                    BoolValue := TextValue in ['1', 'true', 'True', 'TRUE', 'yes', 'Yes'];
                    FldRef.Validate(BoolValue);
                end;
            FieldType::Integer:
                begin
                    if not Evaluate(IntValue, Token.AsValue().AsText(), 9) then
                        Error(BadValueErr, Token.AsValue().AsText(), FldRef.Name());
                    FldRef.Validate(IntValue);
                end;
            FieldType::BigInteger:
                begin
                    if not Evaluate(BigIntValue, Token.AsValue().AsText(), 9) then
                        Error(BadValueErr, Token.AsValue().AsText(), FldRef.Name());
                    FldRef.Validate(BigIntValue);
                end;
            FieldType::Decimal:
                begin
                    if not Evaluate(DecValue, Token.AsValue().AsText(), 9) then
                        Error(BadValueErr, Token.AsValue().AsText(), FldRef.Name());
                    FldRef.Validate(DecValue);
                end;
            FieldType::Date:
                begin
                    if not Evaluate(DateValue, Token.AsValue().AsText(), 9) then
                        Error(BadValueErr, Token.AsValue().AsText(), FldRef.Name());
                    FldRef.Validate(DateValue);
                end;
            FieldType::Time:
                begin
                    if not Evaluate(TimeValue, Token.AsValue().AsText(), 9) then
                        Error(BadValueErr, Token.AsValue().AsText(), FldRef.Name());
                    FldRef.Validate(TimeValue);
                end;
            FieldType::DateTime:
                begin
                    if not Evaluate(DateTimeValue, Token.AsValue().AsText(), 9) then
                        Error(BadValueErr, Token.AsValue().AsText(), FldRef.Name());
                    FldRef.Validate(DateTimeValue);
                end;
            FieldType::GUID:
                begin
                    if not Evaluate(GuidValue, Token.AsValue().AsText()) then
                        Error(BadValueErr, Token.AsValue().AsText(), FldRef.Name());
                    FldRef.Validate(GuidValue);
                end;
            FieldType::DateFormula:
                begin
                    // Angle-bracketed formulas are language-independent, so no format code is needed.
                    if not Evaluate(DateFormulaValue, Token.AsValue().AsText()) then
                        Error(BadValueErr, Token.AsValue().AsText(), FldRef.Name());
                    FldRef.Validate(DateFormulaValue);
                end;
            FieldType::Option:
                begin
                    // Either the member's invariant name, as DumpFields writes it, or its ordinal.
                    TextValue := Token.AsValue().AsText();
                    Ordinal := OptionOrdinal(FldRef, TextValue);
                    if Ordinal < 0 then
                        Error(BadValueErr, TextValue, FldRef.Name());
                    FldRef.Validate(Ordinal);
                end;
            else begin
                // Text and Code. Too long is refused by BC with its own message rather
                // than cut short here — a caller should know its value did not fit.
                TextValue := Token.AsValue().AsText();
                FldRef.Validate(TextValue);
            end;
        end;
    end;

    local procedure ClearFieldValue(var FldRef: FieldRef)
    var
        EmptyRecRef: RecordRef;
        EmptyFldRef: FieldRef;
    begin
        // The field's own blank: open a fresh record of the same table and copy
        // the untouched value across, so every type clears to what BC calls empty.
        EmptyRecRef.Open(FldRef.Record().Number());
        EmptyRecRef.Init();
        EmptyFldRef := EmptyRecRef.Field(FldRef.Number());
        FldRef.Validate(EmptyFldRef.Value());
    end;

    local procedure OptionOrdinal(var FldRef: FieldRef; Value: Text): Integer
    var
        Members: Text;
        MemberCount: Integer;
        Index: Integer;
        Ordinal: Integer;
    begin
        Members := FldRef.OptionMembers();
        MemberCount := StrLen(Members) - StrLen(DelChr(Members, '=', ',')) + 1;
        for Index := 1 to MemberCount do
            if SelectStr(Index, Members) = Value then
                exit(Index - 1);
        if Evaluate(Ordinal, Value) and (Ordinal >= 0) and (Ordinal < MemberCount) then
            exit(Ordinal);
        exit(-1);
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
    /// Whether this API user may read a table at all. Virtual and system tables
    /// are refused outright; for everything else Business Central's own
    /// permissions decide, which is what keeps the generic endpoint honest.
    /// </summary>
    procedure IsReadableTable(TableNo: Integer): Boolean
    var
        RecRef: RecordRef;
        Readable: Boolean;
    begin
        if (TableNo <= 0) or (TableNo >= 2000000000) then
            exit(false);
        if not TryOpen(TableNo, RecRef) then
            exit(false);
        Readable := RecRef.ReadPermission();
        RecRef.Close();
        exit(Readable);
    end;

    [TryFunction]
    local procedure TryOpen(TableNo: Integer; var RecRef: RecordRef)
    begin
        RecRef.Open(TableNo);
    end;

    /// <summary>
    /// Read a window of an arbitrary table into the buffer: one row per record,
    /// every stored field dumped by number. Narrowing on a key field is how a
    /// child table is tied to the record OpenDIMS already has.
    /// </summary>
    procedure ReadRecords(
        TableNo: Integer;
        KeyFieldNo: Integer;
        KeyValues: Text;
        SkipRows: Integer;
        TakeRows: Integer;
        ModifiedAfter: DateTime;
        var Buffer: Record "ODS Table Record")
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        RowNo: Integer;
    begin
        // A page of 100 by default; 1000 is as much as one request may ask for,
        // because every row costs a full field dump.
        if TakeRows <= 0 then
            TakeRows := 100;
        if TakeRows > 1000 then
            TakeRows := 1000;
        if SkipRows < 0 then
            SkipRows := 0;

        if not TryOpen(TableNo, RecRef) then
            exit;
        if not RecRef.ReadPermission() then begin
            RecRef.Close();
            exit;
        end;

        if (KeyFieldNo > 0) and (KeyValues <> '') then begin
            FldRef := RecRef.Field(KeyFieldNo);
            // '|' is Business Central's own OR in a filter expression, which is
            // why the caller separates values with it.
            FldRef.SetFilter(KeyValues);
        end;
        if ModifiedAfter <> 0DT then begin
            FldRef := RecRef.Field(RecRef.SystemModifiedAtNo());
            FldRef.SetFilter('>%1', ModifiedAfter);
        end;

        if RecRef.FindSet() then begin
            // Business Central has no OFFSET; skipping means walking.
            if SkipRows > 0 then
                if RecRef.Next(SkipRows) = 0 then begin
                    RecRef.Close();
                    exit;
                end;
            repeat
                RowNo += 1;
                Buffer.Init();
                Buffer."Table No." := TableNo;
                Buffer."Row No." := RowNo;
                Buffer."Entry Key" := CopyStr(PrimaryKeyOf(RecRef), 1, MaxStrLen(Buffer."Entry Key"));
                Buffer."System Id" := CopyStr(LowerCase(DelChr(Format(RecRef.Field(RecRef.SystemIdNo()).Value()), '=', '{}')), 1, MaxStrLen(Buffer."System Id"));
                Buffer."Last Modified" := RecRef.Field(RecRef.SystemModifiedAtNo()).Value();
                Buffer."Key Field No." := KeyFieldNo;
                Buffer."Key Values" := CopyStr(KeyValues, 1, MaxStrLen(Buffer."Key Values"));
                Buffer.Skip := SkipRows;
                Buffer.Take := TakeRows;
                Buffer."Modified After" := ModifiedAfter;
                Buffer.SetFieldValues(DumpRecordRef(RecRef));
                if Buffer.Insert() then;
            until (RowNo >= TakeRows) or (RecRef.Next() = 0);
        end;
        RecRef.Close();
    end;

    /// The record's primary key fields, joined — enough to identify a row of a
    /// table OpenDIMS knows nothing else about.
    local procedure PrimaryKeyOf(var RecRef: RecordRef): Text
    var
        KeyRef: KeyRef;
        Index: Integer;
        Result: Text;
    begin
        KeyRef := RecRef.KeyIndex(1);
        for Index := 1 to KeyRef.FieldCount() do begin
            if Result <> '' then
                Result += '|';
            Result += Format(KeyRef.FieldIndex(Index).Value(), 0, 2);
        end;
        exit(Result);
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
            FieldType::Option:
                begin
                    IntValue := FldRef.Value();
                    AddText(Values, FieldKey, OptionMemberName(FldRef, IntValue));
                end;
            else
                // Text, Code, DateFormula — format code 2 keeps date formulas in
                // their invariant Business Central spelling instead of the API
                // user's display language.
                AddText(Values, FieldKey, Format(FldRef.Value(), 0, 2));
        end;
    end;

    /// <summary>
    /// The invariant name of an option or enum member.
    /// </summary>
    /// <remarks>
    /// FieldRef.Value() on an option hands back the ordinal as an Integer, and
    /// formatting an Integer only gives the number back — a BC 28.3 tenant sent
    /// Costing Method as "2" and Replenishment System as "3" rather than
    /// "Specific" and "Assembly". So the name is picked out of the member list
    /// instead. Members may legitimately be blank (Item's Replenishment System
    /// has a hole where Transfer used to sit), which reads as no value.
    /// </remarks>
    local procedure OptionMemberName(var FldRef: FieldRef; Ordinal: Integer): Text
    var
        Members: Text;
        MemberCount: Integer;
    begin
        Members := FldRef.OptionMembers();
        if Members = '' then
            exit('');
        MemberCount := StrLen(Members) - StrLen(DelChr(Members, '=', ',')) + 1;
        if (Ordinal < 0) or (Ordinal >= MemberCount) then
            exit('');
        exit(SelectStr(Ordinal + 1, Members));
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
