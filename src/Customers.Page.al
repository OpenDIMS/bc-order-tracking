// Read-only API page over Customer (table 18) — the same treatment odsItems
// gives the item card. Standard API v2.0 publishes about 25 of the customer's
// 170 fields; the rest travel in fieldValues, keyed by Business Central field
// number, and the companion tableFields endpoint (?$filter=tableNumber eq 18)
// names them.
//
// The balances are calculated columns and cannot travel that way, so the ones
// the customer card shows are named here. They are sums over the customer
// ledger with a SIFT index behind them, which is why they can sit on the main
// page rather than on an endpoint of their own the way item statistics do.
//
// GET /api/opendims/integration/v1.0/companies({companyId})/odsCustomers
//     ?$filter=number in ('10000','20000')
page 85462 "ODS Customers"
{
    PageType = API;
    Caption = 'odsCustomers', Locked = true;
    APIPublisher = 'opendims';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'odsCustomer';
    EntitySetName = 'odsCustomers';
    SourceTable = Customer;
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
                // Every normal field of the customer, keyed by field number.
                field(fieldValues; FieldValuesJson) { Caption = 'fieldValues', Locked = true; ApplicationArea = All; Editable = false; }
                // What the customer ledger says.
                field(balance; Rec.Balance) { Caption = 'balance', Locked = true; ApplicationArea = All; Editable = false; }
                field(balanceLcy; Rec."Balance (LCY)") { Caption = 'balanceLcy', Locked = true; ApplicationArea = All; Editable = false; }
                field(balanceDue; Rec."Balance Due") { Caption = 'balanceDue', Locked = true; ApplicationArea = All; Editable = false; }
                field(balanceDueLcy; Rec."Balance Due (LCY)") { Caption = 'balanceDueLcy', Locked = true; ApplicationArea = All; Editable = false; }
                field(netChange; Rec."Net Change") { Caption = 'netChange', Locked = true; ApplicationArea = All; Editable = false; }
                field(netChangeLcy; Rec."Net Change (LCY)") { Caption = 'netChangeLcy', Locked = true; ApplicationArea = All; Editable = false; }
                field(salesLcy; Rec."Sales (LCY)") { Caption = 'salesLcy', Locked = true; ApplicationArea = All; Editable = false; }
                field(profitLcy; Rec."Profit (LCY)") { Caption = 'profitLcy', Locked = true; ApplicationArea = All; Editable = false; }
                field(invAmountsLcy; Rec."Inv. Amounts (LCY)") { Caption = 'invAmountsLcy', Locked = true; ApplicationArea = All; Editable = false; }
                field(paymentsLcy; Rec."Payments (LCY)") { Caption = 'paymentsLcy', Locked = true; ApplicationArea = All; Editable = false; }
                field(outstandingOrdersLcy; Rec."Outstanding Orders (LCY)") { Caption = 'outstandingOrdersLcy', Locked = true; ApplicationArea = All; Editable = false; }
                field(outstandingInvoicesLcy; Rec."Outstanding Invoices (LCY)") { Caption = 'outstandingInvoicesLcy', Locked = true; ApplicationArea = All; Editable = false; }
                field(shippedNotInvoicedLcy; Rec."Shipped Not Invoiced (LCY)") { Caption = 'shippedNotInvoicedLcy', Locked = true; ApplicationArea = All; Editable = false; }
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
            "Net Change", "Net Change (LCY)", "Sales (LCY)", "Profit (LCY)",
            "Inv. Amounts (LCY)", "Payments (LCY)", "Outstanding Orders (LCY)",
            "Outstanding Invoices (LCY)", "Shipped Not Invoiced (LCY)", Comment);
        FieldValuesJson := FieldReflection.DumpFields(Rec);
    end;
}
