@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Material Daily Movement - Base View'
@Metadata.ignorePropagatedAnnotations: true

/*
 * ZI_MATL_MOVEMENT_DAILY
 * Layer 1 – Interface View (Base)
 *
 * Aggregates material document line items per
 *   Material / Plant / Storage Location / Movement Type / Posting Date
 *
 * Released CDS APIs (S/4HANA Public Cloud):
 *   I_MaterialDocumentItem   (SMAT_MATDOC_ITEM)
 *   I_MaterialDocumentHeader (SMAT_MATDOC_HDR)
 */
define view entity ZI_MATL_MOVEMENT_DAILY
  as select from I_MaterialDocumentItem as Item
  inner join    I_MaterialDocumentHeader as Hdr
    on  Hdr.MaterialDocumentYear = Item.MaterialDocumentYear
    and Hdr.MaterialDocument      = Item.MaterialDocument
{
  key Hdr.PostingDate                                        as PostingDate,
  key Item.Material                                          as Material,
  key Item.Plant                                             as Plant,
  key Item.StorageLocation                                   as StorageLocation,
  key Item.GoodsMovementType                                 as MovementType,

      Item.BaseUnit                                          as BaseUnit,
      Item.MaterialBaseUnit                                  as MaterialBaseUnit,

      /* Receipt qty – inbound movement types */
      @DefaultAggregation: #SUM
      case
        when Item.GoodsMovementType in (
               '101','105','122','161',
               '501','521','531','541',
               '561','601','641','651' )
        then Item.QuantityInBaseUnit
        else cast( 0 as abap.dec(13,3) )
      end                                                    as ReceiptQty,

      /* Issue qty – outbound movement types */
      @DefaultAggregation: #SUM
      case
        when Item.GoodsMovementType in (
               '102','106','121','162',
               '201','261','301','311',
               '551','602','642','652' )
        then Item.QuantityInBaseUnit
        else cast( 0 as abap.dec(13,3) )
      end                                                    as IssueQty,

      /* Net movement = receipts − issues */
      @DefaultAggregation: #SUM
      case
        when Item.GoodsMovementType in (
               '101','105','122','161',
               '501','521','531','541',
               '561','601','641','651' )
        then   Item.QuantityInBaseUnit
        when Item.GoodsMovementType in (
               '102','106','121','162',
               '201','261','301','311',
               '551','602','642','652' )
        then ( -1 ) * Item.QuantityInBaseUnit
        else cast( 0 as abap.dec(13,3) )
      end                                                    as NetMovementQty,

      Item.CompanyCode                                       as CompanyCode,
      Item.MaterialDocument                                  as MaterialDocument,
      Item.MaterialDocumentItem                              as MaterialDocumentItem,
      Item.MaterialDocumentYear                              as MaterialDocumentYear,
      Item.GoodsMovementTypeDesc                             as MovementTypeDesc,
      Item.DocumentItemText                                  as ItemText,
      Hdr.CreatedByUser                                      as CreatedByUser
}
