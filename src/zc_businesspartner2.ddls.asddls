@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cost Center (Consumption)'
define root view entity ZC_BusinessPartner2 as select from zi_businessParner2
{
  key ' '           as PType,
      Supplier      as Supplier,
      group1        as GROUP1, 
      SupplierName  as NAME1,
      TaxNumber2    as STCD2,
      memo          as MEMO,
      use_yn        as USE_YN 
    
}
