public with sharing class HDT_UTL_CalculateTransition {
    private Map<String,Object> inputMap = new Map<String,Object>();
    private Boolean isTransitionActive = true;

    public HDT_UTL_CalculateTransition(String city, String commodity) {
        this.inputMap.put('city', city);
        this.inputMap.put('commodity', commodity);
    }
    public HDT_UTL_CalculateTransition(ServicePoint__c servicePoint, Sale__c sale) {
        this.inputMap.put('servicePoint', servicePoint);
        this.inputMap.put('sale', sale);
    }
    public HDT_UTL_CalculateTransition(String city, Sale__c sale) {
        this.inputMap.put('city', city);
        this.inputMap.put('sale', sale);
    }
    public HDT_UTL_CalculateTransition(String city, String commodity, String distributorCode) {
        this.inputMap.put('city', city);
        this.inputMap.put('commodity', commodity);
        this.inputMap.put('distributorCode', distributorCode);
    }

    public Map<String,Object> calculateCompanyInfos(){
        
        Map<String,Object> companyInfosMap = new Map<String,Object>();
        Map<String,Object> calculateTransitionMap = new Map<String,Object>();

        calculateTransitionMap = this.inputMap;

        City__c city = [SELECT Name, BelfioreCode__c, MunicipalityCode__c, RegionCode__c, ProvinceName__c, 
                               RegionName__c, Province__c, SDV__c, ServiceEle__c, ServiceGas__c 
                               FROM City__c WHERE Name =: (String)calculateTransitionMap.get('city') WITH SECURITY_ENFORCED LIMIT 1];
        
        HDT_MatriceSocietaVendita__mdt matrixSaleSociety = [SELECT Id, isActive__c, SalesCompanyCode__c, Comune__c, distributor__c, Marcatura__c, Offerta__c, Service__c, SellerCompany__c 
                                                            FROM HDT_MatriceSocietaVendita__mdt 
                                                            WHERE isActive__c = true AND 
                                                                  Marcatura__c = 'ALTRO' AND 
                                                                  (distributor__c LIKE :(String)calculateTransitionMap.get('distributorCode') OR distributor__c LIKE 'ALTRO') AND 
                                                                  Comune__c =: city.SDV__c AND
                                                                  Service__c =: (String)calculateTransitionMap.get('commodity') WITH SECURITY_ENFORCED LIMIT 1];
        companyInfosMap.put('cityObj', city);
        companyInfosMap.put('SalesCompanyCode', matrixSaleSociety.SalesCompanyCode__c);

        return companyInfosMap;
    }


}
