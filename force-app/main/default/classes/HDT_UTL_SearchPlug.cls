global inherited sharing class HDT_UTL_SearchPlug implements SBQQ.ProductSearchPlugin
{
    //Costruttore -- può essere null
    global HDT_UTL_SearchPlug()
    {
        System.debug('HDT_UTL_SearchPlug used ( constructor )');        
    }
    
    //Per ogni field permette di nascondere il filtro a video
    global Boolean isFilterHidden(SObject quote, String fieldName){
        //inserire in IF quali filtri nascondere a video.
        System.debug('isFilterHidden: ' + fieldName);
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
        System.debug('getFilterDefaultValue ' + fieldName);
        //return fieldName == 'Family'? 'Hardware' : NULL;
        return null;
    }
    
    //SE TRUE, richiama il metodo Search
    global Boolean isSearchCustom(SObject quote, Map<String,Object> fieldValuesMap){
        System.debug('METHOD CALLED: isSearchCustom');
        /*
        // This would use CUSTOM mode if a Search field for sorting was defined and used
        return fieldValuesMap.get('Sort_By__c') != '';
        */
        return true;
        //return false;
    }
    
    //RICHIAMATO QUANDO isSearchCustom è FALSE. Aggiunge filtri alla query
    global String getAdditionalSearchFilters(SObject quote, Map<String,Object> fieldValuesMap){
        System.debug('METHOD CALLED: getAdditionalSearchFilters');
        
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
        /*Set<Id> eligibleProductsId = */getEligibleProducts(myQuote);

        //additionalFilter += 'PriceBook2Id = \'' + myQuote.get('SBQQ__PriceBook__c') + '\'';
        additionalFilter += 'PriceBook2Id = \'' + quote.get('SBQQ__PriceBookId__c') + '\'';
        additionalFilter += ' AND Product2Id IN :eligibleProductsId';
		//*** END ELIGIBLE CRITERIA IMPLEMENTATION ***
		
        System.debug('Additional Filter: '+ additionalFilter);
        return additionalFilter;

    }

    global List<PriceBookEntry> search(SObject quote, Map<String,Object> fieldValuesMap){
        System.debug('METHOD CALLED: search');

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

            if(field.getType() == Schema.DisplayType.String || field.getType() == Schema.DisplayType.Picklist){
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
        /*Set<Id> eligibleProductsId = */getEligibleProducts(myQuote);

        //whereClause += 'PriceBook2Id = \'' + myQuote.get('SBQQ__PriceBook__c') + '\'';
        whereClause += 'PriceBook2Id = \'' + quote.get('SBQQ__PriceBookId__c') + '\'';
        whereClause += ' AND Product2Id IN :eligibleProductsId';
        //*** END ELIGIBLE CRITERIA IMPLEMENTATION ***

        System.debug('# whereClause -> ' + whereClause);

        //BUILD THE QUERY
        String query = selectClause + ' FROM PriceBookEntry WHERE ' + whereClause;

        //DO THE QUERY
        List<PriceBookEntry> pbes = new List<PriceBookEntry>();
        pbes = Database.query(query);

        return pbes;
    }
    
    //Metodo per nascondere i field di input per la guided Selling
    global Boolean isInputHidden(SObject quote, String input){
        System.debug('METHOD CALLED: isInputHidden');
        
        // This would hide an Input called 'Urgent Shipment' on Fridays.
        return (input == 'Comune__c')? true : false;

    }

    global String getInputDefaultValue(SObject quote, String input){
        System.debug('METHOD CALLED: getInputDefaultValue ' + input);

        Id currentId = String.valueOf(quote.get('Id'));

        SBQQ__Quote__c myQuote;
        myQuote = HDT_QR_SearchPlug.selectQuoteFromId(currentId, myQuote);

        return null;
    }
    
    global Boolean isSuggestCustom(SObject quote, Map<String,Object> inputValuesMap){
        //return true;
		System.debug('isSuggestCustom false');
        return false;
    }

    global List<PricebookEntry> suggest( sObject query, Map<String,Object> usg ){
        System.debug('suggest');
        return [SELECT Id FROM PricebookEntry WITH SECURITY_ENFORCED LIMIT 1];
    }

    global String getAdditionalSuggestFilters( sObject quote, Map<String,Object> suggFilts )
    {
        system.debug('getAdditionalSuggestFilters');
        System.debug('METHOD CALLED: getAdditionalSearchFilters');
        
        String additionalFilter = '';
        
        //*** START ELIGIBLE CRITERIA IMPLEMENTATION ***
        Id currentId = String.valueOf(quote.get('Id'));

        SBQQ__Quote__c myQuote;
        myQuote = HDT_QR_SearchPlug.selectQuoteFromId(currentId, myQuote);

        /*
			@Author: Davide Viola - 20/10/2021
			Description: PMD -> Commentata variabile non utilizzata.
		*/
		/*Set<Id> eligibleProductsId = */getEligibleProducts(myQuote);

        //additionalFilter += 'PriceBook2Id = \'' + myQuote.get('SBQQ__PriceBook__c') + '\'';
        additionalFilter += 'PriceBook2Id = \'' + quote.get('SBQQ__PriceBookId__c') + '\'';
        additionalFilter += ' AND Product2Id IN :eligibleProductsId';
		//*** END ELIGIBLE CRITERIA IMPLEMENTATION ***
		
        System.debug('Additional Filter Suggest: '+ additionalFilter);
        return additionalFilter;
    }

    public static Set<Id> getEligibleProducts(SBQQ__Quote__c quote){

        Set<Id> idList = new Set<Id>();
        Set<Id> idToFilterByMunicipalities = new Set<Id>();
        List<String> familyList = getFamilyList();
        List<String> statusList = new List<String>();
        statusList.add(Label.HDT_Sold);//'Vendibile'

        Boolean iAmSalesforceCpqAdmin = checkIfIamAsalesforceCpqAdmin();
        Boolean iAmAsuperUser = checkIfIamAsuperUser(quote.SuperUser__c);
        System.debug('>>> iAmSalesforceCpqAdmin: ' + iAmSalesforceCpqAdmin + ' - iAmAsuperUser: ' + iAmAsuperUser);

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

        System.debug('>>>>> statusList ' + statusList);

        //>>> FILTER - STEP 1 > FILTER ONLY Eligible Criteria...
        System.debug('>>> FILTER - STEP 1 > FILTER ONLY Eligible Criteria...');
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

            System.debug('>>> criteria productcode: ' + criteria.product__r.productcode);
            System.debug('>>> age: ' + age);
            System.debug('>>> consumptionRangeEe: ' + consumptionRangeEe);
            System.debug('>>> consumptionRangeGas: ' + consumptionRangeGas);
            System.debug('>>> powerRange: ' + powerRange);
            System.debug('>>> residentDeliveryAddress: ' + residentDeliveryAddress);
            System.debug('>>> newClient: ' + newClient);
            System.debug('>>> login: ' + login);

            if(age && consumptionRangeEe && consumptionRangeGas && powerRange && residentDeliveryAddress && newClient && login){

                if(criteria.EligibleForAllCities__c){
                    idList.add(criteria.Product__c);
                } else {
                    idToFilterByMunicipalities.add(criteria.Id);
                }
                
            }
            
        }

        System.debug('>>>> criteri: ' + idToFilterByMunicipalities);

        //>>> FILTER - STEP 2 > FILTER ONLY Municipalities...
        if(!String.isEmpty(quote.SupplyCity__c) && idToFilterByMunicipalities.size()>0){
            System.debug('>>> FILTER - STEP 2 > FILTER ONLY Municipalities...');

            List<EligibleMunicipality__c> eligibleMunicipality;
            String supplyCity = String.valueOf(quote.SupplyCity__c);
            eligibleMunicipality = HDT_QR_SearchPlug.findEligibleMunicipality(idToFilterByMunicipalities, statusList, familyList, supplyCity.replaceFirst('^0+', ''));

            for(EligibleMunicipality__c e : eligibleMunicipality){
                idList.add(e.EligibilityCriteria__r.Product__c);
            }

        }

        //>>> FILTER - STEP 3 > FILTER ONLY prodUCT Without Criteria...
        System.debug('>>> FILTER - STEP 3 > FILTER ONLY prodUCT Without Criteria...');
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
        
        System.debug('>>>> UFFICIAL LIST: ' + idList);

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

    public static List<String> getFamilyList(){
        List<String> sl = new List<String>();
        sl.add('Offerta commerciale');
        sl.add('VAS Prodotto');
        sl.add('VAS Servizio');
        return sl;
    }

    private static Boolean checkIfIamAsuperUser(String superUser){
        //Permission set --> HDT_SuperUserCPQ
        List<PermissionSetAssignment> assignmentList;
        Boolean superUserQuote;
        Boolean superUserPermission;
        
        if(!String.isEmpty(superUser) && superUser.equalsIgnoreCase('Y')){
            System.debug('>>> QUOTE IS A SUPER USER');
            superUserQuote = true;
        } else {
            System.debug('>>> QUOTE IS NOT A SUPER USER');
            superUserQuote = false;
        }

        try{
            assignmentList = HDT_QR_SearchPlug.getUserPermissionSets(assignmentList, UserInfo.getUserId(), Label.HDT_SuperUserCPQ);
            System.debug('>>> PermissionSetList Size: ' + String.valueOf(assignmentList.size()));
            if(assignmentList.size() > 0){
                superUserPermission = true;
            } else {
                superUserPermission = false;
            }
        } catch (Exception ex){
            System.debug('>>> Exception: ' + ex.getMessage());
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
            System.debug('>>> PermissionSetList Size: ' + String.valueOf(assignmentList.size()));
            if(assignmentList.size() > 0){
                return true;
            } else {
                return false;
            }
        } catch (Exception ex){
            System.debug('>>> Exception: ' + ex.getMessage());
            return false;
        }
    }

}