@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cost Center (Entity)'
define root view entity zp_BusinessPartner2 as projection on ZC_BusinessPartner2
{
    key ptype      as PType,
    Supplier       as supplier,
    GROUP1         as GROUP1,
    NAME1          as SupplierName,
    STCD2          as TaxNumber2,
    MEMO           as memo,
    USE_YN         as USE_YN
}
