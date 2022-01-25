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
        Set<Id> eligibleProductsId = HDT_UTL_EligibilityCriteria.getEligibleProducts(myQuote);

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
        Set<Id> eligibleProductsId = HDT_UTL_EligibilityCriteria.getEligibleProducts(myQuote);

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
		Set<Id> eligibleProductsId = HDT_UTL_EligibilityCriteria.getEligibleProducts(myQuote);

        //additionalFilter += 'PriceBook2Id = \'' + myQuote.get('SBQQ__PriceBook__c') + '\'';
        additionalFilter += 'PriceBook2Id = \'' + quote.get('SBQQ__PriceBookId__c') + '\'';
        //additionalFilter += ' AND Product2Id IN :eligibleProductsId';

        List<String> idStrs = (List<String>)JSON.deserialize(JSON.serialize(eligibleProductsId), List<String>.class);
        additionalFilter += ' AND Product2Id IN (\'' + String.join(idStrs, '\',\'') + '\')';
		//*** END ELIGIBLE CRITERIA IMPLEMENTATION ***
		
        System.debug(LoggingLevel.DEBUG, 'Additional Filter Suggest: '+ additionalFilter);
        return additionalFilter;
    }

}