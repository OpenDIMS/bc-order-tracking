// Buffer table behind the "ODS Table Fields" catalogue endpoint. It is only
// ever used as a temporary record (the API page sets SourceTableTemporary), so
// nothing is written to the tenant database — it exists because an API page
// needs a real table object as its source.
//
// One row per field OpenDIMS can read on a table, including fields that other
// extensions added through a tableextension. That is what lets the OpenDIMS
// connector discover a customer's custom Business Central fields instead of
// having them hard-coded here.
table 85454 "ODS Table Field"
{
    Caption = 'ODS Table Field';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = SystemMetadata;
        }
        field(2; "Field No."; Integer)
        {
            Caption = 'Field No.';
            DataClassification = SystemMetadata;
        }
        field(3; "Field Name"; Text[100])
        {
            Caption = 'Field Name';
            DataClassification = SystemMetadata;
        }
        field(4; "Field Caption"; Text[250])
        {
            Caption = 'Field Caption';
            DataClassification = SystemMetadata;
        }
        field(5; "Data Type"; Text[30])
        {
            Caption = 'Data Type';
            DataClassification = SystemMetadata;
        }
        field(6; "Field Class"; Text[20])
        {
            Caption = 'Field Class';
            DataClassification = SystemMetadata;
        }
        field(7; "Field Length"; Integer)
        {
            Caption = 'Field Length';
            DataClassification = SystemMetadata;
        }
        field(8; "Is Custom"; Boolean)
        {
            Caption = 'Is Custom';
            DataClassification = SystemMetadata;
        }
        field(9; "Option Members"; Text[2048])
        {
            Caption = 'Option Members';
            DataClassification = SystemMetadata;
        }
        field(10; "Element Name"; Text[150])
        {
            Caption = 'Element Name';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Table No.", "Field No.")
        {
            Clustered = true;
        }
    }
}
