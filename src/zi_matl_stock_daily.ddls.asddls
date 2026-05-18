@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Material Opening & Closing Stock – Day Wise'
@Metadata.ignorePropagatedAnnotations: true

/*
 * ZI_MATL_STOCK_DAILY
 * Layer 2 – Interface View (Calculation)
 *
 * Strategy
 * ─────────
 * Closing Stock (D)  = CurrentStock
 *                    − SUM( NetMovement for dates > D )
 *
 * Opening Stock (D)  = Closing Stock (D) − NetMovement (D)
 *
 * Current stock is sourced from I_MaterialStock (unrestricted).
 * A window function ordered descending by date lets us accumulate
 * "future" rows to roll back the balance to any given day.
 *
 * Released CDS APIs used:
 *   ZI_MATL_MOVEMENT_DAILY  – Layer 1 (this package)
 *   I_MaterialStock          – current unrestricted stock
 */
define view entity ZI_MATL_STOCK_DAILY
  as select from (
    select from ZI_MATL_MOVEMENT_DAILY as Mov

    inner join I_MaterialStock as Stk
      on  Stk.Material        = Mov.Material
      and Stk.Plant           = Mov.Plant
      and Stk.StorageLocation = Mov.StorageLocation

    {
      Mov.PostingDate,
      Mov.Material,
      Mov.Plant,
      Mov.StorageLocation,
      Mov.BaseUnit,
      Mov.CompanyCode,

      @DefaultAggregation: #SUM
      Mov.ReceiptQty                             as DayReceiptQty,

      @DefaultAggregation: #SUM
      Mov.IssueQty                               as DayIssueQty,

      @DefaultAggregation: #SUM
      Mov.NetMovementQty                         as DayNetMovQty,

      Stk.MatlWrhsStkQtyInMatlBaseUnit           as CurrentStock,

      /*──────────────────────────────────────────────────────────────────
       * CLOSING STOCK
       * = CurrentStock − SUM(future NetMovements excluding current day)
       *
       * ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING with DESC order
       * selects all rows with a later date than the current partition row.
       *──────────────────────────────────────────────────────────────────*/
      @DefaultAggregation: #SUM
      Stk.MatlWrhsStkQtyInMatlBaseUnit
        - SUM( Mov.NetMovementQty )
            OVER ( PARTITION BY Mov.Material,
                                Mov.Plant,
                                Mov.StorageLocation
                   ORDER BY Mov.PostingDate DESCENDING
                   ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING )
                                                 as ClosingStock,

      /*──────────────────────────────────────────────────────────────────
       * OPENING STOCK = ClosingStock − DayNetMovQty
       *──────────────────────────────────────────────────────────────────*/
      @DefaultAggregation: #SUM
      (   Stk.MatlWrhsStkQtyInMatlBaseUnit
          - SUM( Mov.NetMovementQty )
              OVER ( PARTITION BY Mov.Material,
                                  Mov.Plant,
                                  Mov.StorageLocation
                     ORDER BY Mov.PostingDate DESCENDING
                     ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING )
      ) - Mov.NetMovementQty                     as OpeningStock
    }
  ) as DailyStk
