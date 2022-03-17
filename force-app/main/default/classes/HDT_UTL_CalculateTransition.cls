public with sharing class HDT_UTL_CalculateTransition {
    private Map<String,Object> inputMap = new Map<String,Object>();
    private Boolean isTransitionActive = true;

    public HDT_UTL_CalculateTransition(String city, String commodity) {
        this.inputMap.put('servicePoint', null);
        this.inputMap.put('sale', null);
        this.inputMap.put('city', city.toUpperCase());
        this.inputMap.put('commodity', commodity);
        this.inputMap.put('distributorCode', '');
    }
    public HDT_UTL_CalculateTransition(ServicePoint__c servicePoint, Sale__c sale) {
        this.inputMap.put('servicePoint', servicePoint);
        this.inputMap.put('sale', sale);
        this.inputMap.put('city', (servicePoint.SupplyCity__c).toUpperCase());
        this.inputMap.put('commodity', servicePoint.CommoditySector__c);
        this.inputMap.put('distributorCode', '');

    }
    public HDT_UTL_CalculateTransition(String city, Sale__c sale) {
        this.inputMap.put('city', city.toUpperCase());
        this.inputMap.put('sale', sale);
        this.inputMap.put('servicePoint', null);
        this.inputMap.put('commodity', '');
        this.inputMap.put('distributorCode', '');

    }
    public HDT_UTL_CalculateTransition(String city, String commodity, String distributorCode) {
        this.inputMap.put('servicePoint', null);
        this.inputMap.put('sale', null);
        this.inputMap.put('city', city.toUpperCase());
        this.inputMap.put('commodity', commodity);
        this.inputMap.put('distributorCode', distributorCode);
    }

    public Map<String,Object> calculateCompanyInfos(){
        
        Map<String,Object> companyInfosMap = new Map<String,Object>();
        Map<String,Object> calculateTransitionMap = new Map<String,Object>();

        calculateTransitionMap = this.inputMap;
        City__c city = [SELECT Name, BelfioreCode__c, MunicipalityCode__c, RegionCode__c, ProvinceName__c, 
                               RegionName__c, Province__c, SDV__c, ServiceEle__c, ServiceGas__c, IsNotTransition__c 
                               FROM City__c WHERE Name =: (String)calculateTransitionMap.get('city') WITH SECURITY_ENFORCED LIMIT 1];
        
        
        if((String)calculateTransitionMap.get('distributorCode') != null && (String)calculateTransitionMap.get('distributorCode') != ''){
            HDT_MatriceSocietaVendita__mdt matrixSaleSociety = [SELECT Id, isActive__c, SalesCompanyCode__c, Comune__c, distributor__c, Marcatura__c, Offerta__c, Service__c, SellerCompany__c 
                                                                FROM HDT_MatriceSocietaVendita__mdt 
                                                                WHERE isActive__c = true AND 
                                                                    Marcatura__c = 'ALTRO' AND 
                                                                    (distributor__c LIKE :(String)calculateTransitionMap.get('distributorCode') OR distributor__c LIKE 'ALTRO') AND 
                                                                    Comune__c =: city.SDV__c AND
                                                                    Service__c =: (String)calculateTransitionMap.get('commodity') WITH SECURITY_ENFORCED LIMIT 1];
            companyInfosMap.put('SalesCompanyCode', matrixSaleSociety.SalesCompanyCode__c);
        }
        else{
            companyInfosMap.put('SalesCompanyCode', '');
        }
        companyInfosMap.put('cityObj', city);
        

        return companyInfosMap;
    }

    public Boolean calculateTransition(){

       Map<String,Object> companyInfosMap = this.calculateCompanyInfos();
       Map<String,Object> calculateTransitionMap = new Map<String,Object>();

       City__c city = (City__c)companyInfosMap.get('cityObj');
       ServicePoint__c servicePoint = new ServicePoint__c();
       Sale__c sale = new Sale__c();
       calculateTransitionMap = this.inputMap;      

       if(city.IsNotTransition__c){
            if(calculateTransitionMap.get('servicePoint') != null){
                servicePoint = [SELECT Id, IsReseller__c FROM ServicePoint__c WHERE Id =: ((ServicePoint__c)calculateTransitionMap.get('servicePoint')).Id WITH SECURITY_ENFORCED LIMIT 1];
                if(servicePoint == null){
                    servicePoint = (ServicePoint__c)calculateTransitionMap.get('servicePoint');
                }
            }
            if(calculateTransitionMap.get('sale') != null){
                sale = [SELECT Id, Account__r.CompanyOwner__c, Account__r.Category__c FROM Sale__c WHERE Id =: ((Sale__c)calculateTransitionMap.get('sale')).Id WITH SECURITY_ENFORCED LIMIT 1];
            }
           
            if(servicePoint.IsReseller__c == true || 
               sale.Account__r.CompanyOwner__c == 'Reseller' || 
               (sale.Account__r.Category__c != 'Famiglie' && 
               sale.Account__r.Category__c != 'Aziende Soho' && 
               sale.Account__r.Category__c != 'Piccoli Condomini') || 
               (city.SDV__c == 'HC' && 
               (String)calculateTransitionMap.get('commodity') == 'Gas')){
                return true;
            }
            else{
                return false;
            }
       }
       else{
            return true;
       }


    }


}
