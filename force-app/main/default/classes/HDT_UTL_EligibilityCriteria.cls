public inherited sharing class HDT_UTL_EligibilityCriteria {

    public static Set<Id> getEligibleProducts(SBQQ__Quote__c quote){

        Set<Id> idList = new Set<Id>();
        Set<Id> idToFilterByMunicipalities = new Set<Id>();
        List<String> familyList;
        List<String> statusList = new List<String>();
        List<LoginGroupItem__c> loginGroupItemList;
        Set<Id> loginGroupSet = new Set<Id>();
        statusList.add(Label.HDT_Sold);//'Vendibile'

        Boolean saleIsEnabled = checkIfSaleIsEnabled();
        Boolean iAmSalesforceCpqAdmin = checkIfIamAsalesforceCpqAdmin();
        Boolean iAmAsuperUser = checkIfIamAsuperUser(quote.SuperUser__c);
        familyList = getFamilyList(quote, saleIsEnabled);
        System.debug(LoggingLevel.DEBUG, '>>> iAmSalesforceCpqAdmin: ' + iAmSalesforceCpqAdmin + ' - iAmAsuperUser: ' + iAmAsuperUser);

        if(iAmSalesforceCpqAdmin && iAmAsuperUser){

            statusList.add(Label.HDT_InDevelopment);//'In Sviluppo'
            statusList.add(Label.HDT_Expired);//'Scaduta

        } else if(iAmSalesforceCpqAdmin && !iAmAsuperUser){

            statusList.add(Label.HDT_Expired);//'Scaduta

        } else if(!iAmSalesforceCpqAdmin && iAmAsuperUser){

            statusList.add(Label.HDT_Expired);//'Scaduta
            List<Product2> allAvailableProducts;
            allAvailableProducts = HDT_QR_SearchPlug.getAllAvailableProducts(allAvailableProducts, familyList, statusList);

            for(Product2 p : allAvailableProducts){
                idList.add(p.Id);
            }
            return idList;
            
        }

        System.debug(LoggingLevel.DEBUG, '>>>>> statusList ' + statusList);

        //>>> FILTER - STEP 1 > FILTER ONLY Eligible Criteria...
        System.debug(LoggingLevel.DEBUG, '>>> FILTER - STEP 1 > FILTER ONLY Eligible Criteria...');
        //  Here we filter these fields:
        //  - OriginMarket__c           - Campaign__c
        //  - Channel__c                - PromoCode__c
        //  - ClientMarker__c           - Agency__c
        //  - CategoryTypeClient__c     - UseCategory__c
        //  - CompanyOwner__c           - EquipmenType__c
        List<EligibilityCriteria__c> filteredEligibleCriteria;
        filteredEligibleCriteria = HDT_QR_SearchPlug.selectEligibleCriteria(filteredEligibleCriteria, statusList, familyList, quote);

        //  Here we filter the NUMBER & checkbox field type
        //  - ClientAgeMin__c             - ClientAgeMax__c
        //  - ConsumptionRangeEEmin__c    - ConsumptionRangeEEmax__c
        //  - ConsumptionRangeGASmin__c   - ConsumptionRangeGASmax__c
        //  - PowerRangeMin__c            - PowerRangeMax__c
        //  - ResidentDeliveryAddress__c  - NewClient__c
        //  - LoginGroup__c
        Boolean age, consumptionRangeEe, consumptionRangeGas, powerRange, residentDeliveryAddress, newClient, login;

        for(EligibilityCriteria__c criteria : filteredEligibleCriteria){
            
            age = checkDecimalCriteria(criteria.ClientAgeMin__c , criteria.ClientAgeMax__c, quote.ClientAge__c);
            consumptionRangeEe = checkDecimalCriteria(criteria.ConsumptionRangeEEmin__c , criteria.ConsumptionRangeEEmax__c, quote.ConsumptionRangeEE__c);
            consumptionRangeGas = checkDecimalCriteria(criteria.ConsumptionRangeGASmin__c , criteria.ConsumptionRangeGASmax__c, quote.ConsumptionRangeGAS__c);
            powerRange = checkDecimalCriteria(criteria.PowerRangeMin__c , criteria.PowerRangeMax__c, quote.PowerFlow__c);
            residentDeliveryAddress = checkBooleanCriteria(quote.ResidentDeliveryAddress__c, criteria.ResidentDeliveryAddress__c);
            newClient = checkBooleanCriteria(quote.NewClient__c, criteria.NewClient__c);
            login = checkLoginGroup(criteria.LoginGroup__r.NameGroup__c, quote.LoginGroup__c);

            //System.debug(LoggingLevel.DEBUG, '>>> criteria productcode: ' + criteria.product__r.productcode);
            //System.debug(LoggingLevel.DEBUG, '>>> age: ' + age);
            //System.debug(LoggingLevel.DEBUG, '>>> consumptionRangeEe: ' + consumptionRangeEe);
            //System.debug(LoggingLevel.DEBUG, '>>> consumptionRangeGas: ' + consumptionRangeGas);
            //System.debug(LoggingLevel.DEBUG, '>>> powerRange: ' + powerRange);
            //System.debug(LoggingLevel.DEBUG, '>>> residentDeliveryAddress: ' + residentDeliveryAddress);
            //System.debug(LoggingLevel.DEBUG, '>>> newClient: ' + newClient);
            //System.debug(LoggingLevel.DEBUG, '>>> login: ' + login);

            if(age && consumptionRangeEe && consumptionRangeGas && powerRange && residentDeliveryAddress && newClient && login){

                if(criteria.EligibleForAllCities__c){
                    idList.add(criteria.Product__c);
                } else {
                    idToFilterByMunicipalities.add(criteria.Id);
                }
                
            }
            
        }
        System.debug(LoggingLevel.DEBUG, '>>>> Limits.getQueries: ' + Limits.getQueries() + ' of ' + Limits.getLimitQueries());
        System.debug(LoggingLevel.DEBUG, '>>>> criteri: ' + idToFilterByMunicipalities);

        //>>> FILTER - STEP 2 > FILTER ONLY Municipalities...
        if(!String.isEmpty(quote.SupplyCity__c) && idToFilterByMunicipalities.size()>0){
            System.debug(LoggingLevel.DEBUG, '>>> FILTER - STEP 2 > FILTER ONLY Municipalities...');

            List<EligibleMunicipality__c> eligibleMunicipality;
            String supplyCity = String.valueOf(quote.SupplyCity__c);

            /* montors fix - convert old city code  - START
             * to restore previous code comment lines 130-131
            */
            System.debug('---> supplyCity: ' + supplyCity);
            supplyCity = convertSupplyCityCode(supplyCity);
            System.debug('---> supplyCity: ' + supplyCity);
            /* montors fix - convert old city code - END*/

            eligibleMunicipality = HDT_QR_SearchPlug.findEligibleMunicipality(idToFilterByMunicipalities, statusList, familyList, supplyCity.replaceFirst('^0+', ''));

            for(EligibleMunicipality__c e : eligibleMunicipality){
                idList.add(e.EligibilityCriteria__r.Product__c);
            }

        }

        //>>> FILTER - STEP 3 > FILTER ONLY prodUCT Without Criteria...
        System.debug(LoggingLevel.DEBUG, '>>> FILTER - STEP 3 > FILTER ONLY prodUCT Without Criteria...');
        List<Product2> prodWithoutCriteria;
        prodWithoutCriteria = HDT_QR_SearchPlug.getEligibilitiesCriteriaFromProduct(prodWithoutCriteria, statusList, familyList);

        for(Product2 p : prodWithoutCriteria){
            if(p.EligibilitiesCriteria__r.size() == 0){
                idList.add(p.Id);
            }
        }
        
        System.debug(LoggingLevel.DEBUG, '>>>> UFFICIAL LIST: ' + idList);

        return idList;

    }

    public static Boolean checkDecimalCriteria(Decimal min, Decimal max, Decimal value){
 
        if(min != null && max != null && value <= max && value >= min){
            return true;
        } else if(min == null && max != null && value <= max){
            return true;
        } else if(min != null && max == null && value >= min){
            return true;
        } else if(min == null && max == null){
            return true;
        }

        return false;
    }

    public static Boolean checkBooleanCriteria(String booleanQuote, String booleanCriteria){

        if(String.isEmpty(booleanQuote) || String.isEmpty(booleanCriteria)){
            return true;
        }


        if(booleanQuote.equalsIgnoreCase('Y') && booleanCriteria.equalsIgnoreCase('Si')){
            return true;
        }
        
        if(booleanQuote.equalsIgnoreCase('N') && booleanCriteria.equalsIgnoreCase('No')){
            return true;
        }     

        return false;

    }

    private static Boolean checkLoginGroup(String loginGroupName, String quoteLogin){

        if(String.isEmpty(loginGroupName)){
            return true;
        }

        return quoteLogin != null && quoteLogin.contains(loginGroupName);

    }

    private static Boolean checkIfSaleIsEnabled(){
        HDT_EnableSaleForCPQ__mdt enableSaleForCpq = HDT_EnableSaleForCPQ__mdt.getInstance('cpq');
        System.debug('>>> sale is enabled? ' + enableSaleForCpq.Enabled__c);
        return enableSaleForCpq.Enabled__c;
    }

    public static List<String> getFamilyList(SBQQ__Quote__c quote, Boolean saleIsEnabled){
        List<String> sl = new List<String>();

        if(saleIsEnabled){
            if(quote.ListPriceName__c.containsIgnoreCase('vas')){
                sl.add('VAS Prodotto');
                sl.add('VAS Servizio');
            } else {
                sl.add('Offerta commerciale');
            }
        } else {
            sl.add('Offerta commerciale');
            sl.add('VAS Prodotto');
            sl.add('VAS Servizio');
        }

        return sl;
    }

    private static Boolean checkIfIamAsuperUser(String superUser){
        //Permission set --> HDT_SuperUserCPQ
        List<PermissionSetAssignment> assignmentList;
        Boolean superUserQuote;
        Boolean superUserPermission;
        
        if(!String.isEmpty(superUser) && superUser.equalsIgnoreCase('Y')){
            System.debug(LoggingLevel.DEBUG, '>>> QUOTE IS A SUPER USER');
            superUserQuote = true;
        } else {
            System.debug(LoggingLevel.DEBUG, '>>> QUOTE IS NOT A SUPER USER');
            superUserQuote = false;
        }

        try{
            assignmentList = HDT_QR_SearchPlug.getUserPermissionSets(assignmentList, UserInfo.getUserId(), Label.HDT_SuperUserCPQ);
            System.debug(LoggingLevel.DEBUG, '>>> PermissionSetList Size: ' + String.valueOf(assignmentList.size()));
            if(assignmentList.size() > 0){
                superUserPermission = true;
            } else {
                superUserPermission = false;
            }
        } catch (Exception ex){
            System.debug(LoggingLevel.DEBUG, '>>> Exception: ' + ex.getMessage());
            superUserPermission = false;
        }

        if(superUserQuote && superUserPermission){
            return true;
        } else {
            return false;
        }

    }

    private static Boolean checkIfIamAsalesforceCpqAdmin(){
        List<PermissionSetAssignment> assignmentList;

        try{
            assignmentList = HDT_QR_SearchPlug.getUserPermissionSets(assignmentList, UserInfo.getUserId(), Label.HDT_PermissionSetNameForCPQ);
            System.debug(LoggingLevel.DEBUG, '>>> PermissionSetList Size: ' + String.valueOf(assignmentList.size()));
            if(assignmentList.size() > 0){
                return true;
            } else {
                return false;
            }
        } catch (Exception ex){
            System.debug(LoggingLevel.DEBUG, '>>> Exception: ' + ex.getMessage());
            return false;
        }
    }

    @TestVisible 
    private static String convertSupplyCityCode(String codeToSearch){
        try {
            HDT_QR_StaticResource staticResourceQr = new HDT_QR_StaticResource();
            List<StaticResource> staticResources = staticResourceQr.getRecordByName('ConvertOldCityCode');
    
            List<HDT_WRP_CodeMap> convertList = (List<HDT_WRP_CodeMap>)JSON.deserialize(staticResources.get(0).Body.toString(), List<HDT_WRP_CodeMap>.class);
    
            String supplyCity = codeToSearch.replaceFirst('^0+', '');
            String newValue = '';
    
            for(HDT_WRP_CodeMap obj : convertList){
                if(obj.oldValue.equalsIgnoreCase(supplyCity)){
                    newValue = String.valueOf(obj.newValue);
                    break;
                }
            }
    
            if(String.isNotEmpty(newValue)){
                return newValue;
            } else {
                return codeToSearch;
            }
    
        } catch (Exception e){
            System.debug('>>> ERROR on convertSupplyCityCode: ' + e.getMessage() + String.valueOf(e.getLineNumber()));
            return codeToSearch;
        }
    
    }

    public class HDT_WRP_CodeMap {
        public String oldValue;
        public String newValue;
    }

}