// What the item ledger says about an item: how much has been bought, sold,
// adjusted and transferred, what is reserved, and what it has cost.
//
// These are all calculated (FlowField) columns, which cannot travel in the
// odsItems fieldValues dump — Business Central has to compute each one per item
// — so they live on their own endpoint that is only read when an integration
// maps one of them. Unfiltered, they are the totals over the item's whole life;
// the item card shows the same figures.
//
// GET /api/opendims/integration/v1.0/companies({companyId})/itemStatistics
//     ?$filter=number in ('A','B')
page 85461 "ODS Item Statistics"
{
    PageType = API;
    Caption = 'itemStatistics', Locked = true;
    APIPublisher = 'opendims';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'itemStatistic';
    EntitySetName = 'itemStatistics';
    SourceTable = Item;
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
                // Movements
                field(netChange; Rec."Net Change") { Caption = 'netChange', Locked = true; ApplicationArea = All; Editable = false; }
                field(netInvoicedQty; Rec."Net Invoiced Qty.") { Caption = 'netInvoicedQty', Locked = true; ApplicationArea = All; Editable = false; }
                field(purchasesQty; Rec."Purchases (Qty.)") { Caption = 'purchasesQty', Locked = true; ApplicationArea = All; Editable = false; }
                field(salesQty; Rec."Sales (Qty.)") { Caption = 'salesQty', Locked = true; ApplicationArea = All; Editable = false; }
                field(positiveAdjmtQty; Rec."Positive Adjmt. (Qty.)") { Caption = 'positiveAdjmtQty', Locked = true; ApplicationArea = All; Editable = false; }
                field(negativeAdjmtQty; Rec."Negative Adjmt. (Qty.)") { Caption = 'negativeAdjmtQty', Locked = true; ApplicationArea = All; Editable = false; }
                field(transferredQty; Rec."Transferred (Qty.)") { Caption = 'transferredQty', Locked = true; ApplicationArea = All; Editable = false; }
                // Amounts, in the company's local currency
                field(purchasesLcy; Rec."Purchases (LCY)") { Caption = 'purchasesLcy', Locked = true; ApplicationArea = All; Editable = false; }
                field(salesLcy; Rec."Sales (LCY)") { Caption = 'salesLcy', Locked = true; ApplicationArea = All; Editable = false; }
                field(positiveAdjmtLcy; Rec."Positive Adjmt. (LCY)") { Caption = 'positiveAdjmtLcy', Locked = true; ApplicationArea = All; Editable = false; }
                field(negativeAdjmtLcy; Rec."Negative Adjmt. (LCY)") { Caption = 'negativeAdjmtLcy', Locked = true; ApplicationArea = All; Editable = false; }
                field(transferredLcy; Rec."Transferred (LCY)") { Caption = 'transferredLcy', Locked = true; ApplicationArea = All; Editable = false; }
                field(cogsLcy; Rec."COGS (LCY)") { Caption = 'cogsLcy', Locked = true; ApplicationArea = All; Editable = false; }
                // What is spoken for
                field(reservedQtyOnInventory; Rec."Reserved Qty. on Inventory") { Caption = 'reservedQtyOnInventory', Locked = true; ApplicationArea = All; Editable = false; }
                field(reservedQtyOnSalesOrders; Rec."Reserved Qty. on Sales Orders") { Caption = 'reservedQtyOnSalesOrders', Locked = true; ApplicationArea = All; Editable = false; }
                field(reservedQtyOnPurchOrders; Rec."Reserved Qty. on Purch. Orders") { Caption = 'reservedQtyOnPurchOrders', Locked = true; ApplicationArea = All; Editable = false; }
                field(qtyAssignedToShip; Rec."Qty. Assigned to ship") { Caption = 'qtyAssignedToShip', Locked = true; ApplicationArea = All; Editable = false; }
                field(qtyPicked; Rec."Qty. Picked") { Caption = 'qtyPicked', Locked = true; ApplicationArea = All; Editable = false; }
                // Elsewhere in the business
                field(qtyOnServiceOrder; Rec."Qty. on Service Order") { Caption = 'qtyOnServiceOrder', Locked = true; ApplicationArea = All; Editable = false; }
                field(qtyOnProdOrder; Rec."Qty. on Prod. Order") { Caption = 'qtyOnProdOrder', Locked = true; ApplicationArea = All; Editable = false; }
                field(qtyOnComponentLines; Rec."Qty. on Component Lines") { Caption = 'qtyOnComponentLines', Locked = true; ApplicationArea = All; Editable = false; }
                field(noOfSubstitutes; Rec."No. of Substitutes") { Caption = 'noOfSubstitutes', Locked = true; ApplicationArea = All; Editable = false; }
                field(lastPhysInvtDate; Rec."Last Phys. Invt. Date") { Caption = 'lastPhysInvtDate', Locked = true; ApplicationArea = All; Editable = false; }
                field(hasComment; Rec.Comment) { Caption = 'hasComment', Locked = true; ApplicationArea = All; Editable = false; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'lastModifiedDateTime', Locked = true; ApplicationArea = All; Editable = false; }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields(
            "Net Change", "Net Invoiced Qty.", "Purchases (Qty.)", "Sales (Qty.)",
            "Positive Adjmt. (Qty.)", "Negative Adjmt. (Qty.)", "Transferred (Qty.)",
            "Purchases (LCY)", "Sales (LCY)", "Positive Adjmt. (LCY)", "Negative Adjmt. (LCY)",
            "Transferred (LCY)", "COGS (LCY)", "Reserved Qty. on Inventory",
            "Reserved Qty. on Sales Orders", "Reserved Qty. on Purch. Orders",
            "Qty. Assigned to ship", "Qty. Picked", "Qty. on Service Order",
            "Qty. on Prod. Order", "Qty. on Component Lines", "No. of Substitutes",
            "Last Phys. Invt. Date", Comment);
    end;
}
