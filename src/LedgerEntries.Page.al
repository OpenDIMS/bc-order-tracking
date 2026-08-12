// The ledgers — what actually happened, rather than what a document says.
//
// Seven flat tables, every one keyed by a single "Entry No.", so unlike the
// documents there are no lines and no document type: a caller pages through
// them and filters on posting date. They are also the largest tables in a
// Business Central company by a wide margin, which is why every page here
// exposes `postingDate` as a named column — an integration is expected to
// bound its reads with it rather than walk the whole history.
//
// Everything the entries store travels in fieldValues keyed by field number,
// named by the tableFields endpoint. The amounts are calculated columns and
// are named here; the Shortcut Dimension 3-8 flowfields are deliberately not,
// since almost no company uses them and each costs a lookup per row.
//
// GET …/itemLedgerEntries?$filter=postingDate ge 2026-01-01
page 85478 "ODS Item Ledger Entries"
{
    PageType = API;
    Caption = 'itemLedgerEntries', Locked = true;
    APIPublisher = 'opendims';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'itemLedgerEntry';
    EntitySetName = 'itemLedgerEntries';
    SourceTable = "Item Ledger Entry";
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
                field(entryNumber; Rec."Entry No.") { Caption = 'entryNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(itemNumber; Rec."Item No.") { Caption = 'itemNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(postingDate; Rec."Posting Date") { Caption = 'postingDate', Locked = true; ApplicationArea = All; Editable = false; }
                field(documentNumber; Rec."Document No.") { Caption = 'documentNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(entryType; Rec."Entry Type") { Caption = 'entryType', Locked = true; ApplicationArea = All; Editable = false; }
                field(sourceNumber; Rec."Source No.") { Caption = 'sourceNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(fieldValues; FieldValuesJson) { Caption = 'fieldValues', Locked = true; ApplicationArea = All; Editable = false; }
                field(costAmountActual; Rec."Cost Amount (Actual)") { Caption = 'costAmountActual', Locked = true; ApplicationArea = All; Editable = false; }
                field(costAmountExpected; Rec."Cost Amount (Expected)") { Caption = 'costAmountExpected', Locked = true; ApplicationArea = All; Editable = false; }
                field(costAmountNonInvtbl; Rec."Cost Amount (Non-Invtbl.)") { Caption = 'costAmountNonInvtbl', Locked = true; ApplicationArea = All; Editable = false; }
                field(salesAmountActual; Rec."Sales Amount (Actual)") { Caption = 'salesAmountActual', Locked = true; ApplicationArea = All; Editable = false; }
                field(salesAmountExpected; Rec."Sales Amount (Expected)") { Caption = 'salesAmountExpected', Locked = true; ApplicationArea = All; Editable = false; }
                field(purchaseAmountActual; Rec."Purchase Amount (Actual)") { Caption = 'purchaseAmountActual', Locked = true; ApplicationArea = All; Editable = false; }
                field(purchaseAmountExpected; Rec."Purchase Amount (Expected)") { Caption = 'purchaseAmountExpected', Locked = true; ApplicationArea = All; Editable = false; }
                field(reservedQuantity; Rec."Reserved Quantity") { Caption = 'reservedQuantity', Locked = true; ApplicationArea = All; Editable = false; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'lastModifiedDateTime', Locked = true; ApplicationArea = All; Editable = false; }
            }
        }
    }

    var
        FieldReflection: Codeunit "ODS Field Reflection";
        FieldValuesJson: Text;

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields(
            "Cost Amount (Actual)", "Cost Amount (Expected)", "Cost Amount (Non-Invtbl.)",
            "Sales Amount (Actual)", "Sales Amount (Expected)",
            "Purchase Amount (Actual)", "Purchase Amount (Expected)", "Reserved Quantity");
        FieldValuesJson := FieldReflection.DumpFields(Rec);
    end;
}

page 85479 "ODS Value Entries"
{
    PageType = API;
    Caption = 'valueEntries', Locked = true;
    APIPublisher = 'opendims';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'valueEntry';
    EntitySetName = 'valueEntries';
    SourceTable = "Value Entry";
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
                field(entryNumber; Rec."Entry No.") { Caption = 'entryNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(itemLedgerEntryNumber; Rec."Item Ledger Entry No.") { Caption = 'itemLedgerEntryNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(itemNumber; Rec."Item No.") { Caption = 'itemNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(postingDate; Rec."Posting Date") { Caption = 'postingDate', Locked = true; ApplicationArea = All; Editable = false; }
                field(documentNumber; Rec."Document No.") { Caption = 'documentNumber', Locked = true; ApplicationArea = All; Editable = false; }
                // Every amount on a value entry is stored, not calculated —
                // this is where an item's cost history actually lives.
                field(fieldValues; FieldValuesJson) { Caption = 'fieldValues', Locked = true; ApplicationArea = All; Editable = false; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'lastModifiedDateTime', Locked = true; ApplicationArea = All; Editable = false; }
            }
        }
    }

    var
        FieldReflection: Codeunit "ODS Field Reflection";
        FieldValuesJson: Text;

    trigger OnAfterGetRecord()
    begin
        FieldValuesJson := FieldReflection.DumpFields(Rec);
    end;
}

page 85480 "ODS Cust. Ledger Entries"
{
    PageType = API;
    Caption = 'customerLedgerEntries', Locked = true;
    APIPublisher = 'opendims';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'customerLedgerEntry';
    EntitySetName = 'customerLedgerEntries';
    SourceTable = "Cust. Ledger Entry";
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
                field(entryNumber; Rec."Entry No.") { Caption = 'entryNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(customerNumber; Rec."Customer No.") { Caption = 'customerNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(postingDate; Rec."Posting Date") { Caption = 'postingDate', Locked = true; ApplicationArea = All; Editable = false; }
                field(documentNumber; Rec."Document No.") { Caption = 'documentNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(open; Rec.Open) { Caption = 'open', Locked = true; ApplicationArea = All; Editable = false; }
                field(fieldValues; FieldValuesJson) { Caption = 'fieldValues', Locked = true; ApplicationArea = All; Editable = false; }
                field(amount; Rec.Amount) { Caption = 'amount', Locked = true; ApplicationArea = All; Editable = false; }
                field(amountLcy; Rec."Amount (LCY)") { Caption = 'amountLcy', Locked = true; ApplicationArea = All; Editable = false; }
                field(remainingAmount; Rec."Remaining Amount") { Caption = 'remainingAmount', Locked = true; ApplicationArea = All; Editable = false; }
                field(remainingAmountLcy; Rec."Remaining Amt. (LCY)") { Caption = 'remainingAmountLcy', Locked = true; ApplicationArea = All; Editable = false; }
                field(originalAmount; Rec."Original Amount") { Caption = 'originalAmount', Locked = true; ApplicationArea = All; Editable = false; }
                field(originalAmountLcy; Rec."Original Amt. (LCY)") { Caption = 'originalAmountLcy', Locked = true; ApplicationArea = All; Editable = false; }
                field(debitAmount; Rec."Debit Amount") { Caption = 'debitAmount', Locked = true; ApplicationArea = All; Editable = false; }
                field(creditAmount; Rec."Credit Amount") { Caption = 'creditAmount', Locked = true; ApplicationArea = All; Editable = false; }
                field(debitAmountLcy; Rec."Debit Amount (LCY)") { Caption = 'debitAmountLcy', Locked = true; ApplicationArea = All; Editable = false; }
                field(creditAmountLcy; Rec."Credit Amount (LCY)") { Caption = 'creditAmountLcy', Locked = true; ApplicationArea = All; Editable = false; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'lastModifiedDateTime', Locked = true; ApplicationArea = All; Editable = false; }
            }
        }
    }

    var
        FieldReflection: Codeunit "ODS Field Reflection";
        FieldValuesJson: Text;

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields(
            Amount, "Amount (LCY)", "Remaining Amount", "Remaining Amt. (LCY)",
            "Original Amount", "Original Amt. (LCY)", "Debit Amount", "Credit Amount",
            "Debit Amount (LCY)", "Credit Amount (LCY)");
        FieldValuesJson := FieldReflection.DumpFields(Rec);
    end;
}

page 85481 "ODS Det. Cust. Ledg. Entries"
{
    PageType = API;
    Caption = 'detailedCustomerLedgerEntries', Locked = true;
    APIPublisher = 'opendims';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'detailedCustomerLedgerEntry';
    EntitySetName = 'detailedCustomerLedgerEntries';
    SourceTable = "Detailed Cust. Ledg. Entry";
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
                field(entryNumber; Rec."Entry No.") { Caption = 'entryNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(customerLedgerEntryNumber; Rec."Cust. Ledger Entry No.") { Caption = 'customerLedgerEntryNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(customerNumber; Rec."Customer No.") { Caption = 'customerNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(postingDate; Rec."Posting Date") { Caption = 'postingDate', Locked = true; ApplicationArea = All; Editable = false; }
                field(documentNumber; Rec."Document No.") { Caption = 'documentNumber', Locked = true; ApplicationArea = All; Editable = false; }
                // Nothing on a detailed entry is calculated.
                field(fieldValues; FieldValuesJson) { Caption = 'fieldValues', Locked = true; ApplicationArea = All; Editable = false; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'lastModifiedDateTime', Locked = true; ApplicationArea = All; Editable = false; }
            }
        }
    }

    var
        FieldReflection: Codeunit "ODS Field Reflection";
        FieldValuesJson: Text;

    trigger OnAfterGetRecord()
    begin
        FieldValuesJson := FieldReflection.DumpFields(Rec);
    end;
}

page 85482 "ODS Vendor Ledger Entries"
{
    PageType = API;
    Caption = 'vendorLedgerEntries', Locked = true;
    APIPublisher = 'opendims';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'vendorLedgerEntry';
    EntitySetName = 'vendorLedgerEntries';
    SourceTable = "Vendor Ledger Entry";
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
                field(entryNumber; Rec."Entry No.") { Caption = 'entryNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(vendorNumber; Rec."Vendor No.") { Caption = 'vendorNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(postingDate; Rec."Posting Date") { Caption = 'postingDate', Locked = true; ApplicationArea = All; Editable = false; }
                field(documentNumber; Rec."Document No.") { Caption = 'documentNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(open; Rec.Open) { Caption = 'open', Locked = true; ApplicationArea = All; Editable = false; }
                field(fieldValues; FieldValuesJson) { Caption = 'fieldValues', Locked = true; ApplicationArea = All; Editable = false; }
                field(amount; Rec.Amount) { Caption = 'amount', Locked = true; ApplicationArea = All; Editable = false; }
                field(amountLcy; Rec."Amount (LCY)") { Caption = 'amountLcy', Locked = true; ApplicationArea = All; Editable = false; }
                field(remainingAmount; Rec."Remaining Amount") { Caption = 'remainingAmount', Locked = true; ApplicationArea = All; Editable = false; }
                field(remainingAmountLcy; Rec."Remaining Amt. (LCY)") { Caption = 'remainingAmountLcy', Locked = true; ApplicationArea = All; Editable = false; }
                field(originalAmount; Rec."Original Amount") { Caption = 'originalAmount', Locked = true; ApplicationArea = All; Editable = false; }
                field(originalAmountLcy; Rec."Original Amt. (LCY)") { Caption = 'originalAmountLcy', Locked = true; ApplicationArea = All; Editable = false; }
                field(debitAmount; Rec."Debit Amount") { Caption = 'debitAmount', Locked = true; ApplicationArea = All; Editable = false; }
                field(creditAmount; Rec."Credit Amount") { Caption = 'creditAmount', Locked = true; ApplicationArea = All; Editable = false; }
                field(debitAmountLcy; Rec."Debit Amount (LCY)") { Caption = 'debitAmountLcy', Locked = true; ApplicationArea = All; Editable = false; }
                field(creditAmountLcy; Rec."Credit Amount (LCY)") { Caption = 'creditAmountLcy', Locked = true; ApplicationArea = All; Editable = false; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'lastModifiedDateTime', Locked = true; ApplicationArea = All; Editable = false; }
            }
        }
    }

    var
        FieldReflection: Codeunit "ODS Field Reflection";
        FieldValuesJson: Text;

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields(
            Amount, "Amount (LCY)", "Remaining Amount", "Remaining Amt. (LCY)",
            "Original Amount", "Original Amt. (LCY)", "Debit Amount", "Credit Amount",
            "Debit Amount (LCY)", "Credit Amount (LCY)");
        FieldValuesJson := FieldReflection.DumpFields(Rec);
    end;
}

page 85483 "ODS Det. Vendor Ledg. Entries"
{
    PageType = API;
    Caption = 'detailedVendorLedgerEntries', Locked = true;
    APIPublisher = 'opendims';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'detailedVendorLedgerEntry';
    EntitySetName = 'detailedVendorLedgerEntries';
    SourceTable = "Detailed Vendor Ledg. Entry";
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
                field(entryNumber; Rec."Entry No.") { Caption = 'entryNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(vendorLedgerEntryNumber; Rec."Vendor Ledger Entry No.") { Caption = 'vendorLedgerEntryNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(vendorNumber; Rec."Vendor No.") { Caption = 'vendorNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(postingDate; Rec."Posting Date") { Caption = 'postingDate', Locked = true; ApplicationArea = All; Editable = false; }
                field(documentNumber; Rec."Document No.") { Caption = 'documentNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(fieldValues; FieldValuesJson) { Caption = 'fieldValues', Locked = true; ApplicationArea = All; Editable = false; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'lastModifiedDateTime', Locked = true; ApplicationArea = All; Editable = false; }
            }
        }
    }

    var
        FieldReflection: Codeunit "ODS Field Reflection";
        FieldValuesJson: Text;

    trigger OnAfterGetRecord()
    begin
        FieldValuesJson := FieldReflection.DumpFields(Rec);
    end;
}

page 85484 "ODS General Ledger Entries"
{
    PageType = API;
    Caption = 'generalLedgerEntries', Locked = true;
    APIPublisher = 'opendims';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'generalLedgerEntry';
    EntitySetName = 'generalLedgerEntries';
    SourceTable = "G/L Entry";
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
                field(entryNumber; Rec."Entry No.") { Caption = 'entryNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(accountNumber; Rec."G/L Account No.") { Caption = 'accountNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(accountName; Rec."G/L Account Name") { Caption = 'accountName', Locked = true; ApplicationArea = All; Editable = false; }
                field(postingDate; Rec."Posting Date") { Caption = 'postingDate', Locked = true; ApplicationArea = All; Editable = false; }
                field(documentNumber; Rec."Document No.") { Caption = 'documentNumber', Locked = true; ApplicationArea = All; Editable = false; }
                field(amount; Rec.Amount) { Caption = 'amount', Locked = true; ApplicationArea = All; Editable = false; }
                field(fieldValues; FieldValuesJson) { Caption = 'fieldValues', Locked = true; ApplicationArea = All; Editable = false; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'lastModifiedDateTime', Locked = true; ApplicationArea = All; Editable = false; }
            }
        }
    }

    var
        FieldReflection: Codeunit "ODS Field Reflection";
        FieldValuesJson: Text;

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("G/L Account Name");
        FieldValuesJson := FieldReflection.DumpFields(Rec);
    end;
}
