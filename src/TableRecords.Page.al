// Any table, by number.
//
// The named endpoints in this app cover the tables OpenDIMS integrations use
// every day, with proper columns and calculated fields. This one covers the
// rest of Business Central: give it a table number and it reads that table's
// records the same way — every stored field as a fieldValues dump keyed by
// field number, with tableFields naming them.
//
// It reads nothing the API user is not already allowed to read. There is no
// tabledata permission in OPENDIMS TABLE DATA beyond this app's own buffer, so
// what a client can reach here is exactly what the permission sets it was
// granted let it reach — and a table it has no rights to comes back empty
// rather than erroring.
//
// The request travels as filters:
//
//   tableNumber   required, the BC table id (5740 = Transfer Header, …)
//   keyFieldNo    optional, a field to narrow on — how a child table is tied
//   keyValues     optional, that field's values, separated by | (max 50)
//   modifiedAfter optional, only records changed since; use it for every run
//                 after the first
//   skip / take   the window, take defaults to 100 and is capped at 1000
//
// GET …/tableRecords?$filter=tableNumber eq 5741 and keyFieldNo eq 1
//     and keyValues eq 'T-ORD-001|T-ORD-002'
//
// Deep paging costs what it costs — Business Central has no OFFSET, so a large
// skip walks the rows it skips. Prefer narrowing with keyValues or
// modifiedAfter over paging far into a big table.
page 85487 "ODS Table Records"
{
    PageType = API;
    Caption = 'tableRecords', Locked = true;
    APIPublisher = 'opendims';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'tableRecord';
    EntitySetName = 'tableRecords';
    SourceTable = "ODS Table Record";
    SourceTableTemporary = true;
    ODataKeyFields = "Table No.", "Row No.";
    DelayedInsert = true;
    Editable = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(tableNumber; Rec."Table No.") { Caption = 'tableNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(rowNumber; Rec."Row No.") { Caption = 'rowNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(entryKey; Rec."Entry Key") { Caption = 'entryKey', Locked = true; ApplicationArea = All; Editable = false; }
                field(systemId; Rec."System Id") { Caption = 'systemId', Locked = true; ApplicationArea = All; Editable = false; }
                field(fieldValues; FieldValuesJson) { Caption = 'fieldValues', Locked = true; ApplicationArea = All; Editable = false; }
                field(lastModifiedDateTime; Rec."Last Modified") { Caption = 'lastModifiedDateTime', Locked = true; ApplicationArea = All; Editable = false; }
                // Echoed request, so the caller's own $filter still matches.
                field(keyFieldNo; Rec."Key Field No.") { Caption = 'keyFieldNo', Locked = true; ApplicationArea = All; Editable = false; }
                field(keyValues; Rec."Key Values") { Caption = 'keyValues', Locked = true; ApplicationArea = All; Editable = false; }
                field(skip; Rec.Skip) { Caption = 'skip', Locked = true; ApplicationArea = All; Editable = false; }
                field(take; Rec.Take) { Caption = 'take', Locked = true; ApplicationArea = All; Editable = false; }
                field(modifiedAfter; Rec."Modified After") { Caption = 'modifiedAfter', Locked = true; ApplicationArea = All; Editable = false; }
            }
        }
    }

    var
        FieldReflection: Codeunit "ODS Field Reflection";
        FieldValuesJson: Text;

    trigger OnAfterGetRecord()
    begin
        FieldValuesJson := Rec.GetFieldValues();
    end;

    trigger OnOpenPage()
    var
        TableNo: Integer;
        KeyFieldNo: Integer;
        SkipRows: Integer;
        TakeRows: Integer;
        ModifiedAfter: DateTime;
    begin
        if not Evaluate(TableNo, Rec.GetFilter("Table No.")) then
            Error(TableNumberRequiredErr);
        if not FieldReflection.IsReadableTable(TableNo) then
            exit;

        if not Evaluate(KeyFieldNo, Rec.GetFilter("Key Field No.")) then
            KeyFieldNo := 0;
        if not Evaluate(SkipRows, Rec.GetFilter(Skip)) then
            SkipRows := 0;
        if not Evaluate(TakeRows, Rec.GetFilter(Take)) then
            TakeRows := 0;
        if not Evaluate(ModifiedAfter, Rec.GetFilter("Modified After")) then
            ModifiedAfter := 0DT;

        FieldReflection.ReadRecords(
            TableNo, KeyFieldNo, Rec.GetFilter("Key Values"),
            SkipRows, TakeRows, ModifiedAfter, Rec);
    end;

    var
        TableNumberRequiredErr: Label 'Ask for one table at a time: add "tableNumber eq <id>" to the filter.', Locked = true;
}
