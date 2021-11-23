@SuppressWarnings('PMD.AvoidDebugStatements, PMD.AvoidGlobalModifier')
global inherited sharing class HDT_UTL_SearchPlug implements SBQQ.ProductSearchPlugin{
    //Costruttore -- può essere null
    global HDT_UTL_SearchPlug(){
        System.debug(LoggingLevel.DEBUG, 'HDT_UTL_SearchPlug used ( constructor )');        
    }
    
    //Per ogni field permette di nascondere il filtro a video
    global Boolean isFilterHidden(SObject quote, String fieldName){
        //inserire in IF quali filtri nascondere a video.
        System.debug(LoggingLevel.DEBUG, 'isFilterHidden: ' + fieldName);
        return null;
        //return false;
        //if(fieldName.equalsIgnoreCase('ProductCode') && quote.get('SBQQ__Status__c') == 'Approved'){
        //    return true;
        //} else {
        //    return false;
        //}
        
    }
    
    //QUESTO METODO PERMETTE DI INSERIRE PREDEFAULT SUI FILTRI
    global String getFilterDefaultValue(SObject quote, String fieldName){
        System.debug(LoggingLevel.DEBUG, 'getFilterDefaultValue ' + fieldName);
        //return fieldName == 'Family'? 'Hardware' : NULL;
        return null;
    }
    
    //SE TRUE, richiama il metodo Search
    global Boolean isSearchCustom(SObject quote, Map<String,Object> fieldValuesMap){
        System.debug(LoggingLevel.DEBUG, 'METHOD CALLED: isSearchCustom');
        /*
        // This would use CUSTOM mode if a Search field for sorting was defined and used
        return fieldValuesMap.get('Sort_By__c') != '';
        */
        return true;
        //return false;
    }
    
    //RICHIAMATO QUANDO isSearchCustom è FALSE. Aggiunge filtri alla query
    global String getAdditionalSearchFilters(SObject quote, Map<String,Object> fieldValuesMap){
        System.debug(LoggingLevel.DEBUG, 'METHOD CALLED: getAdditionalSearchFilters');

        // This would add an extra inventory filter if the family is Hardware
        String additionalFilter = '';
        
        //*** START ELIGIBLE CRITERIA IMPLEMENTATION ***
        Id currentId = String.valueOf(quote.get('Id'));

        SBQQ__Quote__c myQuote;
        myQuote = HDT_QR_SearchPlug.selectQuoteFromId(currentId, myQuote);

        /*
            @Author: Davide Viola - 20/10/2021
            Description: PMD -> Commentata variabile non utilizzata.
        */
        Set<Id> eligibleProductsId = getEligibleProducts(myQuote);

        //additionalFilter += 'PriceBook2Id = \'' + myQuote.get('SBQQ__PriceBook__c') + '\'';
        additionalFilter += 'PriceBook2Id = \'' + quote.get('SBQQ__PriceBookId__c') + '\'';
        //additionalFilter += ' AND Product2Id IN :eligibleProductsId';

        List<String> idStrs = (List<String>)JSON.deserialize(JSON.serialize(eligibleProductsId), List<String>.class);
        additionalFilter += ' AND Product2Id IN (\'' + String.join(idStrs, '\',\'') + '\')';

		//*** END ELIGIBLE CRITERIA IMPLEMENTATION ***
		
        System.debug(LoggingLevel.DEBUG, 'Additional Filter: '+ additionalFilter);
        return additionalFilter;

    }

    global List<PriceBookEntry> search(SObject quote, Map<String,Object> fieldValuesMap){
        System.debug(LoggingLevel.DEBUG, 'METHOD CALLED: search');

        System.debug('>>> fieldValuesMap ' + fieldValuesMap);

        //GET ALL POSSIBLE FILTER FIELDS FROM THE SEARCH FILTER FIELD SET
        List<Schema.FieldSetMember> searchFilterFieldSetFields = SObjectType.Product2.FieldSets.SBQQ__SearchFilters.getFields();

        //GET ALL POSSIBLE FIELDS FROM THE SEARCH RESULTS FIELD SET
        List<Schema.FieldSetMember> searchResultFieldSetFields = SObjectType.Product2.FieldSets.SBQQ__SearchResults.getFields();

        //BUILD THE SELECT STRING
        String selectClause = 'SELECT ';

        for(Schema.FieldSetMember field : searchResultFieldSetFields){
            selectClause += 'Product2.' + field.getFieldPath() + ', ';
        }
        selectClause += 'Id, UnitPrice, PriceBook2Id, Product2Id, Product2.Id';

        //BUILD THE WHERE CLAUSE
        String whereClause = '';

        for(Schema.FieldSetMember field : searchFilterFieldSetFields){
            if(!fieldValuesMap.containsKey(field.getFieldPath())){
                continue;
            }

            if(field.getType() == Schema.DisplayType.String || field.getType() == Schema.DisplayType.Picklist || field.getType() == Schema.DisplayType.TextArea){
                whereClause += 'Product2.' + field.getFieldPath() + ' LIKE \'%' + fieldValuesMap.get(field.getFieldPath()) + '%\' AND ';
            }
        }
        
        //*** START ELIGIBLE CRITERIA IMPLEMENTATION ***
        Id currentId = String.valueOf(quote.get('Id'));

        SBQQ__Quote__c myQuote;
        myQuote = HDT_QR_SearchPlug.selectQuoteFromId(currentId, myQuote);

        /*
            @Author: Davide Viola - 20/10/2021
            Description: PMD -> Commentata variabile non utilizzata.
        */
        Set<Id> eligibleProductsId = getEligibleProducts(myQuote);

        //whereClause += 'PriceBook2Id = \'' + myQuote.get('SBQQ__PriceBook__c') + '\'';
        whereClause += 'PriceBook2Id = \'' + quote.get('SBQQ__PriceBookId__c') + '\'';
        whereClause += ' AND Product2Id IN :eligibleProductsId';
        //*** END ELIGIBLE CRITERIA IMPLEMENTATION ***

        System.debug(LoggingLevel.DEBUG, '# whereClause -> ' + whereClause);

        //BUILD THE QUERY
        String query = selectClause + ' FROM PriceBookEntry WHERE ' + whereClause;

        //DO THE QUERY
        List<PriceBookEntry> pbes = new List<PriceBookEntry>();
        pbes = Database.query(query);

        return pbes;
    }
    
    //Metodo per nascondere i field di input per la guided Selling
    global Boolean isInputHidden(SObject quote, String input){
        System.debug(LoggingLevel.DEBUG, 'METHOD CALLED: isInputHidden');
        
        // This would hide an Input called 'Urgent Shipment' on Fridays.
        return (input == 'Comune__c')? true : false;

    }

    global String getInputDefaultValue(SObject quote, String input){
        System.debug(LoggingLevel.DEBUG, 'METHOD CALLED: getInputDefaultValue ' + input);

        Id currentId = String.valueOf(quote.get('Id'));

        SBQQ__Quote__c myQuote;
        myQuote = HDT_QR_SearchPlug.selectQuoteFromId(currentId, myQuote);

        return null;
    }
    
    global Boolean isSuggestCustom(SObject quote, Map<String,Object> inputValuesMap){
        //return true;
		System.debug(LoggingLevel.DEBUG, 'isSuggestCustom false');
        return false;
    }

    global List<PricebookEntry> suggest( sObject query, Map<String,Object> usg ){
        System.debug(LoggingLevel.DEBUG, 'suggest');
        return [SELECT Id FROM PricebookEntry WITH SECURITY_ENFORCED LIMIT 1];
    }

    global String getAdditionalSuggestFilters( sObject quote, Map<String,Object> suggFilts ){
        System.debug(LoggingLevel.DEBUG, 'getAdditionalSuggestFilters');
        System.debug(LoggingLevel.DEBUG, 'METHOD CALLED: getAdditionalSearchFilters');
        
        String additionalFilter = '';
        
        //*** START ELIGIBLE CRITERIA IMPLEMENTATION ***
        Id currentId = String.valueOf(quote.get('Id'));

        SBQQ__Quote__c myQuote;
        myQuote = HDT_QR_SearchPlug.selectQuoteFromId(currentId, myQuote);

        /*
			@Author: Davide Viola - 20/10/2021
			Description: PMD -> Commentata variabile non utilizzata.
		*/
		Set<Id> eligibleProductsId = getEligibleProducts(myQuote);

        //additionalFilter += 'PriceBook2Id = \'' + myQuote.get('SBQQ__PriceBook__c') + '\'';
        additionalFilter += 'PriceBook2Id = \'' + quote.get('SBQQ__PriceBookId__c') + '\'';
        //additionalFilter += ' AND Product2Id IN :eligibleProductsId';

        List<String> idStrs = (List<String>)JSON.deserialize(JSON.serialize(eligibleProductsId), List<String>.class);
        additionalFilter += ' AND Product2Id IN (\'' + String.join(idStrs, '\',\'') + '\')';
		//*** END ELIGIBLE CRITERIA IMPLEMENTATION ***
		
        System.debug(LoggingLevel.DEBUG, 'Additional Filter Suggest: '+ additionalFilter);
        return additionalFilter;
    }

    public static Set<Id> getEligibleProducts(SBQQ__Quote__c quote){

        Set<Id> idList = new Set<Id>();
        Set<Id> idToFilterByMunicipalities = new Set<Id>();
        List<String> familyList;
        List<String> statusList = new List<String>();
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

        //if(iAmSalesforceCpqAdmin()){
        //    statusList.add(Label.HDT_InDevelopment);//'In Sviluppo'
        //}

        //if(checkIfIamAsuperUser(quote.SuperUser__c)){
        //    //List<String> statusList = new List<String>{'Vendibile', 'Scaduta'};
        //    statusList.add(Label.HDT_Expired);//'Scaduta
        //    List<Product2> allAvailableProducts;
        //    allAvailableProducts = HDT_QR_SearchPlug.getAllAvailableProducts(allAvailableProducts, familyList, statusList);

        //    for(Product2 p : allAvailableProducts){
        //        idList.add(p.Id);
        //    }
        //    return idList;
        //}

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
            login = checkLoginGroup(criteria.LoginGroup__c);

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

        System.debug(LoggingLevel.DEBUG, '>>>> criteri: ' + idToFilterByMunicipalities);

        //>>> FILTER - STEP 2 > FILTER ONLY Municipalities...
        if(!String.isEmpty(quote.SupplyCity__c) && idToFilterByMunicipalities.size()>0){
            System.debug(LoggingLevel.DEBUG, '>>> FILTER - STEP 2 > FILTER ONLY Municipalities...');

            List<EligibleMunicipality__c> eligibleMunicipality;
            String supplyCity = String.valueOf(quote.SupplyCity__c);
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

        /*if(!String.isEmpty(quote.SupplyCity__c)){
            for(Product2 p : prodWithoutCriteria){
                if(p.EligibilitiesCriteria__r.size() == 0){
                    idList.add(p.Id);
                }
            }
        } else {
            for(Product2 p : prodWithoutCriteria){
                if(p.EligibilitiesCriteria__r.size() == 0){
                    idList.add(p.Id);
                }
            }            
        }*/
        
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

    public static Boolean checkLoginGroup(Id loginGroupId){

        if(String.isEmpty(loginGroupId)){
            return true;
        }

        Integer userPresence = HDT_QR_SearchPlug.getUserForLoginGroup(UserInfo.getUserId(), loginGroupId);

        if(userPresence == 0){
            return false;
        } else {
            return true;
        }
    }

    private static Boolean checkIfSaleIsEnabled(){
        HDT_EnableSaleForCPQ__mdt enableSaleForCPQ = HDT_EnableSaleForCPQ__mdt.getInstance('cpq');
        System.debug('>>> sale is enabled? ' + enableSaleForCPQ.Enabled__c);
        return enableSaleForCPQ.Enabled__c;
        //return false;
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

}