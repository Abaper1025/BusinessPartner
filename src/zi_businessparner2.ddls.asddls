@AbapCatalog.sqlViewName: 'ZI_BIZP'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cost Center (Interface View)'
define view zi_businessParner2 as select from I_SupplierCompany as A
  inner join I_Supplier as B 
  on A.Supplier = B.Supplier
  left outer join I_BusinessPartner as C 
  on B.Supplier = C.BusinessPartner
  left outer join zljhdbt003 as D 
  on A.Supplier = D.supplier
{
  key A.Supplier as Supplier,
  B.DeletionIndicator,
  C.BusinessPartnerDeathDate,
  D.group1,
  B.SupplierName,
  B.TaxNumber2,
  D.memo,
  D.use_yn
}
where 1 <> 1;
