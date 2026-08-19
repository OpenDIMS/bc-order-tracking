// Read-only roll-up of an assembly BOM's cost.
//
// Business Central's own "Calculate Standard Cost" writes the result back onto
// the item, which an API GET must not do — so this recomputes the same figure
// in memory and leaves the database untouched. The stored, last-calculated
// figure is still available as the item's Standard Cost field.
//
// A component contributes (its own rolled-up cost, or its unit cost when it has
// no BOM) x (quantity per) x (qty. per unit of measure of the line's UoM).
codeunit 85456 "ODS BOM Cost"
{
    Access = Public;

    var
        MaxDepth: Integer;

    trigger OnRun()
    begin
    end;

    procedure CalculateBomCost(ItemNo: Code[20]): Decimal
    begin
        if MaxDepth = 0 then
            MaxDepth := 10;
        exit(RollUp(ItemNo, 0));
    end;

    procedure ComponentLineCount(ItemNo: Code[20]): Integer
    var
        BOMComponent: Record "BOM Component";
    begin
        BOMComponent.SetRange("Parent Item No.", ItemNo);
        exit(BOMComponent.Count());
    end;

    local procedure RollUp(ItemNo: Code[20]; Depth: Integer): Decimal
    var
        BOMComponent: Record "BOM Component";
        ComponentItem: Record Item;
        ComponentResource: Record Resource;
        Total: Decimal;
        LineCost: Decimal;
    begin
        // Guards against a BOM that (incorrectly) contains itself.
        if Depth >= MaxDepth then
            exit(0);

        BOMComponent.SetRange("Parent Item No.", ItemNo);
        if not BOMComponent.FindSet() then
            exit(0);

        repeat
            LineCost := 0;
            case BOMComponent.Type of
                BOMComponent.Type::Item:
                    if ComponentItem.Get(BOMComponent."No.") then
                        LineCost := ComponentUnitCost(ComponentItem, Depth) *
                            QtyPerUnitOfMeasure(BOMComponent."No.", BOMComponent."Unit of Measure Code");
                BOMComponent.Type::Resource:
                    if ComponentResource.Get(BOMComponent."No.") then
                        LineCost := ComponentResource."Unit Cost";
            end;
            Total += LineCost * BOMComponent."Quantity per";
        until BOMComponent.Next() = 0;

        exit(Total);
    end;

    local procedure ComponentUnitCost(var ComponentItem: Record Item; Depth: Integer): Decimal
    var
        SubAssemblyCost: Decimal;
    begin
        ComponentItem.CalcFields("Assembly BOM");
        if ComponentItem."Assembly BOM" then begin
            SubAssemblyCost := RollUp(ComponentItem."No.", Depth + 1);
            if SubAssemblyCost <> 0 then
                exit(SubAssemblyCost);
        end;
        if ComponentItem."Unit Cost" <> 0 then
            exit(ComponentItem."Unit Cost");
        exit(ComponentItem."Standard Cost");
    end;

    local procedure QtyPerUnitOfMeasure(ItemNo: Code[20]; UnitOfMeasureCode: Code[10]): Decimal
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        if UnitOfMeasureCode = '' then
            exit(1);
        if ItemUnitOfMeasure.Get(ItemNo, UnitOfMeasureCode) then
            if ItemUnitOfMeasure."Qty. per Unit of Measure" <> 0 then
                exit(ItemUnitOfMeasure."Qty. per Unit of Measure");
        exit(1);
    end;
}
