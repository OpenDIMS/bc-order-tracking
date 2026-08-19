// Buffer behind the "ODS Table Records" endpoint — one row per record read out
// of an arbitrary Business Central table. Only ever used as a temporary record,
// so nothing is written to the tenant database; it exists because an API page
// needs a real table object as its source.
//
// The request itself travels on every row (Table No., Skip, Take, the key
// filter) so that OData can apply the caller's $filter to the rows we produce
// without dropping them.
table 85486 "ODS Table Record"
{
    Caption = 'ODS Table Record';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = SystemMetadata;
        }
        field(2; "Row No."; Integer)
        {
            Caption = 'Row No.';
            DataClassification = SystemMetadata;
        }
        field(3; "Entry Key"; Text[250])
        {
            Caption = 'Entry Key';
            DataClassification = SystemMetadata;
        }
        field(4; "System Id"; Text[50])
        {
            Caption = 'System Id';
            DataClassification = SystemMetadata;
        }
        field(5; "Field Values"; Blob)
        {
            Caption = 'Field Values';
            DataClassification = SystemMetadata;
        }
        // The request, echoed so the caller's own filter still matches the rows.
        field(10; "Key Field No."; Integer)
        {
            Caption = 'Key Field No.';
            DataClassification = SystemMetadata;
        }
        field(11; "Key Values"; Text[250])
        {
            Caption = 'Key Values';
            DataClassification = SystemMetadata;
        }
        field(12; Skip; Integer)
        {
            Caption = 'Skip';
            DataClassification = SystemMetadata;
        }
        field(13; Take; Integer)
        {
            Caption = 'Take';
            DataClassification = SystemMetadata;
        }
        field(14; "Modified After"; DateTime)
        {
            Caption = 'Modified After';
            DataClassification = SystemMetadata;
        }
        field(15; "Last Modified"; DateTime)
        {
            Caption = 'Last Modified';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Table No.", "Row No.")
        {
            Clustered = true;
        }
    }

    procedure SetFieldValues(Values: Text)
    var
        OutStr: OutStream;
    begin
        Clear("Field Values");
        "Field Values".CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(Values);
    end;

    procedure GetFieldValues(): Text
    var
        InStr: InStream;
        Chunk: Text;
        Result: Text;
    begin
        CalcFields("Field Values");
        if not "Field Values".HasValue() then
            exit('');
        "Field Values".CreateInStream(InStr, TextEncoding::UTF8);
        while not InStr.EOS() do begin
            InStr.ReadText(Chunk);
            Result += Chunk;
        end;
        exit(Result);
    end;
}
