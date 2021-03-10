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
        System.debug('isFilterHidden ' + fieldName);
        if(fieldName.equalsIgnoreCase('ProductCode') && quote.get('SBQQ__Status__c') == 'Approved')
            return true;
        /*else if(fieldName.equalsIgnoreCase('Comune__c')) 
            return true;*/
        else
            return false;
    }
    
    //QUESTO METODO PERMETTE DI INSERIRE PREDEFAULT SUI FILTRI
    global String getFilterDefaultValue(SObject quote, String fieldName){
        System.debug('getFilterDefaultValue ' + fieldName);
        //return fieldName == 'Family'? 'Hardware' : NULL;
        return NULL;
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

        /*
         * start ciro modification ***
         * if(fieldValuesMap.get('Family') == 'Hardware'){
            additionalFilter = 'Product2.Inventory_Level__c > 3';
        }
		*** end ciro modification ***
		*/
        
        //*** START ELIGIBLE CRITERIA IMPLEMENTATION ***
        Id currentId = String.valueOf(quote.get('Id'));

        SBQQ__Quote__c myQuote= [
            SELECT Id, SBQQ__PricebookId__c, SBQQ__PriceBook__c, SupplyCity__c
            FROM SBQQ__Quote__c
            WHERE Id =: currentId
            WITH SECURITY_ENFORCED
        ];

        Set<Id> eligibleProductsId = getEligibleProducts(myQuote);

        additionalFilter += 'PriceBook2Id = \'' + myQuote.get('SBQQ__PriceBook__c') + '\'';
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

        SBQQ__Quote__c myQuote= [
            SELECT Id, SBQQ__PricebookId__c, SBQQ__PriceBook__c, SupplyCity__c
            FROM SBQQ__Quote__c
            WHERE Id =: currentId
            WITH SECURITY_ENFORCED
        ];

        Set<Id> eligibleProductsId = getEligibleProducts(myQuote);

        whereClause += 'PriceBook2Id = \'' + myQuote.get('SBQQ__PriceBook__c') + '\'';
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

        SBQQ__Quote__c myQuote= [
            SELECT Id,SBQQ__PricebookId__c,SBQQ__PriceBook__c
            FROM SBQQ__Quote__c where Id =: currentId
            WITH SECURITY_ENFORCED
        ];
		/*if(input.equalsIgnoreCase('Comune__c'))
        	return String.valueOf(myQuote.Comune_Fornitura__c);
        else return null;*/
        return null;
    }
    
    global Boolean isSuggestCustom(SObject quote, Map<String,Object> inputValuesMap){
        //return true;
		System.debug('isSuggestCustom false');
        return false;
    }
     global List<PricebookEntry> suggest( sObject query, Map<String,Object> usg ){
                 system.debug('suggest');

        return [SELECT Id FROM PricebookEntry WITH SECURITY_ENFORCED LIMIT 1];
    }
    global String getAdditionalSuggestFilters( sObject quote, Map<String,Object> suggFilts )
    {
        system.debug('getAdditionalSuggestFilters');
        System.debug('METHOD CALLED: getAdditionalSearchFilters');
        
        // This would add an extra inventory filter if the family is Hardware
        String additionalFilter = '';

        /*
         * start ciro modification ***
         * if(fieldValuesMap.get('Family') == 'Hardware'){
            additionalFilter = 'Product2.Inventory_Level__c > 3';
        }
		*** end ciro modification ***
		*/
        
        //*** START ELIGIBLE CRITERIA IMPLEMENTATION ***
        Id currentId = String.valueOf(quote.get('Id'));
        SBQQ__Quote__c myQuote= [
            SELECT Id, SBQQ__PricebookId__c, SBQQ__PriceBook__c, SupplyCity__c
            FROM SBQQ__Quote__c
            WHERE Id =: currentId
            WITH SECURITY_ENFORCED
        ];

        Set<Id> eligibleProductsId = getEligibleProducts(myQuote);

        additionalFilter += 'PriceBook2Id = \'' + myQuote.get('SBQQ__PriceBook__c') + '\'';
        additionalFilter += ' AND Product2Id IN :eligibleProductsId';
		//*** END ELIGIBLE CRITERIA IMPLEMENTATION ***
		
        System.debug('Additional Filter Suggest: '+ additionalFilter);
        return additionalFilter;
    }

    public static Set<Id> getEligibleProducts(SBQQ__Quote__c quote){

        Set<Id> idList = new Set<Id>();
        List<String> familyList = getFamilyList();

        if(!String.isEmpty(quote.SupplyCity__c)){
            List<List<SObject>> searchList = [
                FIND :quote.SupplyCity__c
                IN ALL FIELDS
                RETURNING
                        EligibleMunicipality__c(EligibilityCriteria__r.Product__c
                                                WHERE EligibilityCriteria__r.Product__r.Status__c = 'Vendibile'
                                                AND EligibilityCriteria__r.Product__r.IsActive = true
                                                AND EligibilityCriteria__r.Product__r.Family IN :familyList
                                                )
            ];

            List<EligibleMunicipality__c> eligibleMunicipality = ((List<EligibleMunicipality__c>)searchlist[0]);

            for(EligibleMunicipality__c e : eligibleMunicipality){
                System.debug('# > Prod id: ' + e.EligibilityCriteria__r.Product__c);
                idList.add(e.EligibilityCriteria__r.Product__c);
            }
        }

        List<Product2> prodWithoutCriteria = new List<Product2>();
        prodWithoutCriteria = [
            SELECT Id, (SELECT Id FROM EligibilitiesCriteria__r)
            FROM Product2
            WHERE Status__c = 'Vendibile' AND IsActive = true AND Family IN :familyList
            WITH SECURITY_ENFORCED
        ];

        if(!String.isEmpty(quote.SupplyCity__c)){
            for(Product2 p : prodWithoutCriteria){
                if(p.EligibilitiesCriteria__r.size() == 0){
                    idList.add(p.Id);
                }
            }
        } else {
            for(Product2 p : prodWithoutCriteria){
                idList.add(p.Id);
            }            
        }

        return idList;

    }

    public static List<String> getFamilyList(){
        List<String> sl = new List<String>();
        sl.add('Offerta commerciale');
        sl.add('VAS Prodotto');
        sl.add('VAS Servizio');
        return sl;
    }

    public static void queryForEligibilitiesCriteria(){

    }

}