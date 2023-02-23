@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_CarMassPredefaultValues {
    
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    private static HDT_QR_AnagAlignment regionalAdditionalQr = new HDT_QR_AnagAlignment();
    private static HDT_QR_VoltureChangeManager  voltureChangeQr = new HDT_QR_VoltureChangeManager();
    private static List<AmministrazioneSottotipologiaUso__c> subTypList = new List<AmministrazioneSottotipologiaUso__c>();
    private static Map<String, String> companyCodeMap = new Map<String, String>();
    private ServicePoint__c servicePoint;
    private Contract contr;
    private List<String> salesCompList;
    private List<String> prodCodeList;

    public HDT_UTL_CarMassPredefaultValues() {
        salesCompList = new List<String>();
        prodCodeList = new List<String>();
    }

    public void setServicePoint(ServicePoint__c servicePoint){
        this.servicePoint = servicePoint;
    }

    public void setContract(Contract contr){
        this.contr = contr;
    }

    public void setMetadataLists(Order orderToSet){
        if(String.isNotEmpty(orderToSet.SalesCompany__c)){
            salesCompList.add(orderToSet.SalesCompany__c);
        }

        if(String.isNotEmpty(orderToSet.RateCategory__c)){
            prodCodeList.add(orderToSet.RateCategory__c);
        }
    }

    public void getMetadataList(){
        getHeraCompanyMap();
        getAdminSubtypeList();
    }

    public Order setDefaultOrderValues(Order orderToSet){

        if(orderToSet.ProcessType__c.equalsIgnoreCase('Voltura')){

            String tax = orderToSet.CommodityFormula__c == 'Energia Elettrica' ? orderToSet.ExciseEle__c : orderToSet.ExciseGAS__c;

            /*ALTRI DEFAULT*/
            orderToSet.Subprocess__c = (String.isEmpty(orderToSet.Subprocess__c)) ? 'Standard' : orderToSet.Subprocess__c;
            orderToSet.VoltureType__c = (String.isEmpty(orderToSet.VoltureType__c)) ? 'Ordinaria' : orderToSet.VoltureType__c;
            orderToSet.EffectiveDate__c = orderToSet.ProcessCode__c != 'MA1' ? orderSrv.addBusinessDay(System.today(), 3) : System.today();
            orderToSet.SapContractCode__c = (String.isEmpty(orderToSet.SapContractCode__c)) ? contr.SAPContractCode__c : orderToSet.SapContractCode__c;

            // query on custom metadata does't count against query limits
            orderToSet.RegionalAdditional__c = (orderToSet.RegionalAdditional__c==null) ? regionalAdditionalQr.findRegionalAdditional(tax, orderToSet.SupplyCity__c, '') : orderToSet.RegionalAdditional__c;
            orderToSet.ExciseRate__c = (orderToSet.ExciseRate__c==null) ? voltureChangeQr.getExciseTranscode(tax)[0].Excise__c : orderToSet.ExciseRate__c;

            //Inizio: Predefault valido per tutti i processi
            AmministrazioneSottotipologiaUso__c ammSubType = handleSubTypeBulkMethod(orderToSet.SalesCompany__c, orderToSet.RateCategory__c);

            orderToSet.UseSubCategory__c = (String.isEmpty(orderToSet.UseSubCategory__c)) ? ammSubType?.SottotipologiaUso__c : orderToSet.UseSubCategory__c;
            orderToSet.IntendedUse__c = (String.isEmpty(orderToSet.IntendedUse__c)) ? ammSubType?.IntendedUse__c : orderToSet.IntendedUse__c;
            orderToSet.ContractExpenses__c = (String.isEmpty(orderToSet.ContractExpenses__c)) ? 'Nessuno sconto' : orderToSet.ContractExpenses__c;
            orderToSet.SecurityDepositExcluded__c = (String.isEmpty(orderToSet.SecurityDepositExcluded__c)) ? 'N' : orderToSet.SecurityDepositExcluded__c;
            orderToSet.ATO__c = (String.isEmpty(orderToSet.ATO__c)) ? servicePoint.ATO__c : orderToSet.ATO__c;
            orderToSet.VAT__c = (String.isEmpty(orderToSet.VAT__c)) ? 'Iva 10% (Cod. 01)' : orderToSet.VAT__c;
            orderToSet.PayPurification__c = (String.isEmpty(orderToSet.PayPurification__c)) ? servicePoint.PayPurification__c : orderToSet.PayPurification__c;
            orderToSet.PaySewer__c = (String.isEmpty(orderToSet.PayPurification__c)) ? servicePoint.PaySewer__c : orderToSet.PaySewer__c;
            orderToSet.AggregateBilling__c = (String.isEmpty( orderToSet.AggregateBilling__c)) ? 'No' :  orderToSet.AggregateBilling__c;
            orderToSet.EffectiveDate__c = (orderToSet.EffectiveDate__c==null) ? System.Today() : orderToSet.EffectiveDate__c;
            //Fine: Predefault valido per tutti i processi
            //Inizio: Predefault secondo RateCategory
            for (List<String> fieldToPredefault : HDT_LC_ChildOrderProcessPrecheck.predefaultRatecategories) {
                if( fieldToPredefault.contains(orderToSet.RateCategory__c) ){
                    String defaultValue = fieldToPredefault.get(1);
                    if (defaultValue.isNumeric()){
                        orderToSet.put( fieldToPredefault.get(0), Integer.valueof(defaultValue) );
                    } 
                    else {
                        orderToSet.put( fieldToPredefault.get(0), defaultValue );
                    }
                }
            }
            //Update RateCategory sul Service Point
            //order.ServicePoint__r.RateCategory__c = order.RateCategory__c;todo????
        }
        return orderToSet;
    }

    public void getHeraCompanyMap(){

        List <HDT_HeraCompany__mdt> compCodeMdtList = [
            SELECT CompanyCode__c, MasterLabel
            FROM HDT_HeraCompany__mdt 
            WHERE MasterLabel IN :salesCompList
            WITH SECURITY_ENFORCED
        ];
  
        for(HDT_HeraCompany__mdt cd : compCodeMdtList){
            companyCodeMap.put(cd.MasterLabel, cd.CompanyCode__c);
        }
        
    }

    public void getAdminSubtypeList(){
        List<String> salesCompValuesList = companyCodeMap.values();
        subTypList = [
            SELECT SottotipologiaUso__c, IntendedUse__c, CodiceCategoriaTariffa__c, Societa__c
            FROM AmministrazioneSottotipologiaUso__c
            WHERE Societa__c IN :salesCompValuesList
            AND CodiceCategoriaTariffa__c IN :prodCodeList 
            AND Attivo__c = true
            WITH SECURITY_ENFORCED
        ];

    }

    public static AmministrazioneSottotipologiaUso__c handleSubTypeBulkMethod(String salesComp, String prodCode) {

        String salesCompCode = companyCodeMap.get(salesComp);

        for(AmministrazioneSottotipologiaUso__c rec : subTypList){
            if(rec.Societa__c.equalsIgnoreCase(salesCompCode) && rec.CodiceCategoriaTariffa__c.equalsIgnoreCase(prodCode)){
                return rec;
            }
        }

        return null;
    }

}