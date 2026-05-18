@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Material Day-Wise Opening & Closing Stock Report'

@OData.entityType.name:     'MatlDayStockType'
@OData.publish:             true

@Analytics.dataCategory:    #CUBE
@Analytics.dataExtraction.enabled: true

@Search.searchable: true

@UI.headerInfo: {
  typeName:       'Day-Wise Stock',
  typeNamePlural: 'Day-Wise Stocks',
  title:          { type: #STANDARD, value: 'Material' },
  description:    { type: #STANDARD, value: 'MaterialDescription' }
}

/*
 * ZC_MATL_DAYWISE_STOCK_RPT
 * Layer 3 – Consumption View (Analytical / Query)
 *
 * Exposure:
 *   • Embedded Analytics (Fiori Analytical List Page / SAC)
 *   • Custom Fiori app via OData V4
 *   • BW extraction via CDS extraction framework
 */
define view entity ZC_MATL_DAYWISE_STOCK_RPT
  as select from ZI_MATL_STOCK_DAILY as Stock

  left outer join I_MaterialText as MatTxt
    on  MatTxt.Material = Stock.Material
    and MatTxt.Language = $session.system_language

  left outer join I_Plant as PlantT
    on  PlantT.Plant = Stock.Plant

  left outer join I_StorageLocation as SLocT
    on  SLocT.Plant           = Stock.Plant
    and SLocT.StorageLocation = Stock.StorageLocation
{
  /* ─── KEY DIMENSIONS ─────────────────────────────────────────────────── */

  @UI.lineItem:       [{ position: 10, label: 'Posting Date' }]
  @UI.selectionField: [{ position: 10 }]
  @UI.fieldGroup:     [{ qualifier: 'KeyFields', position: 10 }]
  @EndUserText.label: 'Posting Date'
  @Semantics.businessDate.at: true
  key Stock.PostingDate                                     as PostingDate,

  @UI.lineItem:       [{ position: 20, label: 'Material' }]
  @UI.selectionField: [{ position: 20 }]
  @UI.fieldGroup:     [{ qualifier: 'KeyFields', position: 20 }]
  @EndUserText.label: 'Material'
  @ObjectModel.text.element: ['MaterialDescription']
  @Search.defaultSearchElement: true
  key Stock.Material                                        as Material,

  @UI.lineItem:       [{ position: 30, label: 'Plant' }]
  @UI.selectionField: [{ position: 30 }]
  @UI.fieldGroup:     [{ qualifier: 'KeyFields', position: 30 }]
  @EndUserText.label: 'Plant'
  @ObjectModel.text.element: ['PlantDescription']
  key Stock.Plant                                           as Plant,

  @UI.lineItem:       [{ position: 40, label: 'Storage Location' }]
  @UI.selectionField: [{ position: 40 }]
  @UI.fieldGroup:     [{ qualifier: 'KeyFields', position: 40 }]
  @EndUserText.label: 'Storage Location'
  @ObjectModel.text.element: ['StorageLocationDescription']
  key Stock.StorageLocation                                 as StorageLocation,

  /* ─── DESCRIPTIVE ATTRIBUTES ─────────────────────────────────────────── */

  @UI.lineItem:  [{ position: 25 }]
  @EndUserText.label: 'Material Description'
  @Search.defaultSearchElement: true
  MatTxt.MaterialName                                       as MaterialDescription,

  @EndUserText.label: 'Plant Description'
  PlantT.PlantName                                          as PlantDescription,

  @EndUserText.label: 'Storage Location Description'
  SLocT.StorageLocationName                                 as StorageLocationDescription,

  @EndUserText.label: 'Company Code'
  @UI.selectionField: [{ position: 50 }]
  Stock.CompanyCode                                         as CompanyCode,

  @EndUserText.label: 'Base Unit of Measure'
  @Semantics.unitOfMeasure: true
  Stock.BaseUnit                                            as BaseUnit,

  /* ─── KEY MEASURES ───────────────────────────────────────────────────── */

  @UI.lineItem:    [{ position: 50, label: 'Opening Stock' }]
  @UI.fieldGroup:  [{ qualifier: 'StockFigures', position: 10 }]
  @EndUserText.label: 'Opening Stock'
  @Semantics.quantity.unitOfMeasure: 'BaseUnit'
  @DefaultAggregation: #SUM
  @Analytics.measure: true
  Stock.OpeningStock                                        as OpeningStock,

  @UI.lineItem:    [{ position: 60, label: 'Receipts' }]
  @UI.fieldGroup:  [{ qualifier: 'StockFigures', position: 20 }]
  @EndUserText.label: 'Receipts (Day)'
  @Semantics.quantity.unitOfMeasure: 'BaseUnit'
  @DefaultAggregation: #SUM
  @Analytics.measure: true
  Stock.DayReceiptQty                                       as ReceiptQty,

  @UI.lineItem:    [{ position: 70, label: 'Issues' }]
  @UI.fieldGroup:  [{ qualifier: 'StockFigures', position: 30 }]
  @EndUserText.label: 'Issues (Day)'
  @Semantics.quantity.unitOfMeasure: 'BaseUnit'
  @DefaultAggregation: #SUM
  @Analytics.measure: true
  Stock.DayIssueQty                                         as IssueQty,

  @UI.lineItem:    [{ position: 80, label: 'Net Movement' }]
  @UI.fieldGroup:  [{ qualifier: 'StockFigures', position: 40 }]
  @EndUserText.label: 'Net Movement (Day)'
  @Semantics.quantity.unitOfMeasure: 'BaseUnit'
  @DefaultAggregation: #SUM
  @Analytics.measure: true
  Stock.DayNetMovQty                                        as NetMovementQty,

  @UI.lineItem:    [{ position: 90, label: 'Closing Stock' }]
  @UI.fieldGroup:  [{ qualifier: 'StockFigures', position: 50 }]
  @EndUserText.label: 'Closing Stock'
  @Semantics.quantity.unitOfMeasure: 'BaseUnit'
  @DefaultAggregation: #SUM
  @Analytics.measure: true
  Stock.ClosingStock                                        as ClosingStock,

  @UI.lineItem:    [{ position: 100, label: 'Current Stock' }]
  @UI.fieldGroup:  [{ qualifier: 'StockFigures', position: 60 }]
  @EndUserText.label: 'Current Unrestricted Stock'
  @Semantics.quantity.unitOfMeasure: 'BaseUnit'
  @DefaultAggregation: #SUM
  @Analytics.measure: true
  Stock.CurrentStock                                        as CurrentStock
}
