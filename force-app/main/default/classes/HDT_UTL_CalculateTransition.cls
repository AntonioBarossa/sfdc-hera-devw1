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
            string queryCity = String.isNotBlank(city.SDV__c) ? city.SDV__c : 'ALTRO';

            HDT_MatriceSocietaVendita__mdt matrixSaleSociety = [SELECT Id, isActive__c, SalesCompanyCode__c, Comune__c, distributor__c, Marcatura__c, Offerta__c, Service__c, SellerCompany__c 
                                                                FROM HDT_MatriceSocietaVendita__mdt 
                                                                WHERE isActive__c = true AND 
                                                                    Marcatura__c = 'ALTRO' AND 
                                                                    (distributor__c LIKE :(String)calculateTransitionMap.get('distributorCode') OR distributor__c LIKE 'ALTRO') AND 
                                                                    Comune__c =: queryCity AND
                                                                    Service__c =: (String)calculateTransitionMap.get('commodity') WITH SECURITY_ENFORCED LIMIT 1];
            companyInfosMap.put('SalesCompanyCode', matrixSaleSociety.SalesCompanyCode__c);
            companyInfosMap.put('SalesCompany', matrixSaleSociety.SellerCompany__c);
        }
        else{
            companyInfosMap.put('SalesCompanyCode', '');
            companyInfosMap.put('SalesCompany', '');
        }
        companyInfosMap.put('cityObj', city);
        

        return companyInfosMap;
    }

    public Boolean calculateTransition(){

       //Map<String,Object> companyInfosMap = this.calculateCompanyInfos();
       Map<String,Object> calculateTransitionMap = new Map<String,Object>();
       Set<String> stabbedData = new Set<String>{'AQ', 'CH', 'PE', 'TE', 'AN', 'AP', 'FM', 'MC', 'PU'};
       //City__c city = (City__c)companyInfosMap.get('cityObj');
       ServicePoint__c servicePoint = new ServicePoint__c();
       ServicePoint__c servicePointRetrieved = new ServicePoint__c();
       Sale__c sale = new Sale__c();
       calculateTransitionMap = this.inputMap;
       string[] markerConverted;

       City__c city = [SELECT Name, Province__c 
                       FROM City__c 
                       WHERE Name =: (String)calculateTransitionMap.get('city') WITH SECURITY_ENFORCED LIMIT 1];

       //if(city.IsNotTransition__c){
            if(calculateTransitionMap.get('servicePoint') != null){
                servicePointRetrieved = ((ServicePoint__c)calculateTransitionMap.get('servicePoint'));
                String servicePointRetrievedId = ((ServicePoint__c)calculateTransitionMap.get('servicePoint')).Id;
                if(servicePointRetrieved != null && servicePointRetrievedId != null && servicePointRetrievedId != '')
                    servicePoint = [SELECT Id, IsReseller__c FROM ServicePoint__c WHERE Id =: servicePointRetrievedId WITH SECURITY_ENFORCED LIMIT 1];
                // if(servicePoint == null){
                else{
                    servicePoint = servicePointRetrieved;
                }
            }
            if(calculateTransitionMap.get('sale') != null){
                sale = [SELECT Id, Account__r.CustomerCode__c, Account__r.CompanyOwner__c, Account__r.Category__c, Account__r.CustomerMarking__c, Account__c FROM Sale__c WHERE Id =: ((Sale__c)calculateTransitionMap.get('sale')).Id WITH SECURITY_ENFORCED LIMIT 1];
                if(sale.Account__r.CustomerMarking__c != null && sale.Account__r.CustomerMarking__c != ''){
                    markerConverted = sale.Account__r.CustomerMarking__c.split('');
                }
                if(markerConverted[0] == ''){
                    markerConverted.remove(0);
                }
            }
           
            // if(servicePoint.IsReseller__c == true || 
            //    sale.Account__r.CompanyOwner__c == 'Reseller' || 
            //    (sale.Account__r.Category__c != 'Famiglie' && 
            //    sale.Account__r.Category__c != 'Aziende Soho' && 
            //    sale.Account__r.Category__c != 'Piccoli Condomini') || 
            //    (city.SDV__c == 'HC' && 
            //    (String)calculateTransitionMap.get('commodity') == 'Gas')){
             String regex = '^[DG][0-9] - .*';
            Pattern regexPattern = Pattern.compile(regex);
            /** Check comune, punto reseller, categoria Account, Codice cliente non valorizzato o Codice cliente valorizzato e marcatura nuovo modello */
            if(stabbedData.contains(city.Province__c) 
                && (servicePoint == null || (servicePoint != null && !servicePoint.IsReseller__c)) 
                && (sale.Account__r.CompanyOwner__c != 'Reseller') 
                && (sale.Account__r.Category__c == 'Famiglie' || sale.Account__r.Category__c == 'Aziende Soho' || sale.Account__r.Category__c == 'Piccoli Condomini')
                && (sale.Account__r.CustomerCode__c == null || (sale.Account__r.CustomerCode__c != null && regexPattern.matcher(sale.Account__r.CustomerMarking__c).matches()))
               ){
                /** Check se Gas HC --> Transitorio */
                /** infrawave: non più richiesto controllo*/
 /*                   if((String)calculateTransitionMap.get('commodity') == 'Gas' && !markerConverted.isEmpty() && markerConverted != null && !(markerConverted[0] == 'D' && markerConverted[1].isNumeric())){
                        List<City__c> cityList = [SELECT Name, BelfioreCode__c, ProvinceName__c, Province__c, SDV__c, ServiceEle__c, ServiceGas__c 
                        FROM City__c WHERE Name =: (String)calculateTransitionMap.get('city') AND ServiceGas__c = true WITH SECURITY_ENFORCED];
                        if(cityList.isEmpty()){
                            return true;
                        }
                   } */
                   /** Check se ci sono altri ordini a transitorio --> Transitorio */
                   List<Order> ordList = [SELECT Id, isTransition__c, Status, AccountId FROM Order WHERE isTransition__c = true AND Status = 'In Lavorazione' AND AccountId =: sale.Account__c WITH SECURITY_ENFORCED];
                   if(!ordList.isEmpty()){
                       return true;
                   }
                   /* Se vengono passati tutti i check --> Non transitorio */
                   return false;
            }
            else{
                system.debug('TRANSITORIO 3');
                return true;
            }
    //    }
    //    else{
    //         return true;
    //    }


    }


}
