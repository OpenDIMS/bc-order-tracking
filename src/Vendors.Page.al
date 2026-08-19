// Read-only API page over Vendor (table 23) — the buying side's counterpart to
// odsCustomers. 75 of the vendor's 141 fields travel in fieldValues keyed by
// Business Central field number, named by the tableFields endpoint
// (?$filter=tableNumber eq 23); the balances the vendor card shows are
// calculated columns and are named here.
//
// GET /api/opendims/integration/v1.0/companies({companyId})/odsVendors
//     ?$filter=number in ('30000','40000')
page 85469 "ODS Vendors"
{
    PageType = API;
    Caption = 'odsVendors', Locked = true;
    APIPublisher = 'opendims';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'odsVendor';
    EntitySetName = 'odsVendors';
    SourceTable = Vendor;
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
                field(number; Rec."No.") { Caption = 'number', Locked = true; ApplicationArea = All; Editable = false; }
                field(displayName; Rec.Name) { Caption = 'displayName', Locked = true; ApplicationArea = All; Editable = false; }
                field(fieldValues; FieldValuesJson) { Caption = 'fieldValues', Locked = true; ApplicationArea = All; Editable = false; }
                // What the vendor ledger says.
                field(balance; Rec.Balance) { Caption = 'balance', Locked = true; ApplicationArea = All; Editable = false; }
                field(balanceLcy; Rec."Balance (LCY)") { Caption = 'balanceLcy', Locked = true; ApplicationArea = All; Editable = false; }
                field(balanceDue; Rec."Balance Due") { Caption = 'balanceDue', Locked = true; ApplicationArea = All; Editable = false; }
                field(balanceDueLcy; Rec."Balance Due (LCY)") { Caption = 'balanceDueLcy', Locked = true; ApplicationArea = All; Editable = false; }
                field(netChange; Rec."Net Change") { Caption = 'netChange', Locked = true; ApplicationArea = All; Editable = false; }
                field(netChangeLcy; Rec."Net Change (LCY)") { Caption = 'netChangeLcy', Locked = true; ApplicationArea = All; Editable = false; }
                field(purchasesLcy; Rec."Purchases (LCY)") { Caption = 'purchasesLcy', Locked = true; ApplicationArea = All; Editable = false; }
                field(invAmountsLcy; Rec."Inv. Amounts (LCY)") { Caption = 'invAmountsLcy', Locked = true; ApplicationArea = All; Editable = false; }
                field(paymentsLcy; Rec."Payments (LCY)") { Caption = 'paymentsLcy', Locked = true; ApplicationArea = All; Editable = false; }
                field(outstandingOrders; Rec."Outstanding Orders") { Caption = 'outstandingOrders', Locked = true; ApplicationArea = All; Editable = false; }
                field(outstandingOrdersLcy; Rec."Outstanding Orders (LCY)") { Caption = 'outstandingOrdersLcy', Locked = true; ApplicationArea = All; Editable = false; }
                field(amtRcdNotInvoiced; Rec."Amt. Rcd. Not Invoiced") { Caption = 'amtRcdNotInvoiced', Locked = true; ApplicationArea = All; Editable = false; }
                field(amtRcdNotInvoicedLcy; Rec."Amt. Rcd. Not Invoiced (LCY)") { Caption = 'amtRcdNotInvoicedLcy', Locked = true; ApplicationArea = All; Editable = false; }
                field(hasComment; Rec.Comment) { Caption = 'hasComment', Locked = true; ApplicationArea = All; Editable = false; }
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
            Balance, "Balance (LCY)", "Balance Due", "Balance Due (LCY)",
            "Net Change", "Net Change (LCY)", "Purchases (LCY)", "Inv. Amounts (LCY)",
            "Payments (LCY)", "Outstanding Orders", "Outstanding Orders (LCY)",
            "Amt. Rcd. Not Invoiced", "Amt. Rcd. Not Invoiced (LCY)", Comment);
        FieldValuesJson := FieldReflection.DumpFields(Rec);
    end;
}
