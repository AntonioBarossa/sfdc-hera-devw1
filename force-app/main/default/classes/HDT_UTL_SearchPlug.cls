global class HDT_UTL_SearchPlug implements SBQQ.ProductSearchPlugin
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
        
        //*** start ciro modification ***
        List<String> sl = new List<String>();
        sl.add('Offerta commerciale');
        sl.add('VAS Prodotto');
        
        Id QuoteId = String.valueOf(quote.get('Id'));
        SBQQ__Quote__c quote2= [SELECT Id,SBQQ__PricebookId__c,SBQQ__PriceBook__c from SBQQ__Quote__c where Id =: QuoteId];
        additionalFilter += 'PriceBook2Id = \'' + quote2.get('SBQQ__PriceBook__c') + '\'';
        additionalFilter +=' AND Product2.Family IN :sl';
	    //additionalFilter +=' AND (Product2.Family = \'Offerta commerciale\')';
        //additionalFilter +=' AND (Product2.Family = \'VAS Prodotto\')';
        //additionalFilter += ' AND Product2.Comune__c = \''+ quote2.Comune_Fornitura__c+'\'';
        //additionalFilter +=' AND (NOT Product2.Family like \'Bonus%\') and (NOT Product2.Family like \'Contri%\')';
        //additionalFilter +=' AND (NOT Product2.Family like \'Opzione VAS%\') AND (NOT Product2.Family like \'Scont%VAS%\')';
        additionalFilter +=' AND Product2.Status__c=\'Vendibile\'';
		additionalFilter +=' AND Product2.IsActive = true';
		//*** end ciro modification ***
		
        System.debug('Additional Filter: '+ additionalFilter);
        return additionalFilter;
        
        //return NULL;
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
        
        //*** start ciro modification ***
        
        List<String> sl = new List<String>();
        sl.add('Offerta commerciale');
        sl.add('VAS Prodotto');
        
        Id QuoteId = String.valueOf(quote.get('Id'));
        SBQQ__Quote__c quote2= [SELECT Id,SBQQ__PricebookId__c,SBQQ__PriceBook__c  from SBQQ__Quote__c where Id =: QuoteId];
        whereClause += 'PriceBook2Id = \'' + quote2.get('SBQQ__PriceBook__c') + '\'';
		whereClause += ' AND Product2.Family IN :sl';
        //whereClause +=' AND (Product2.Family = \'Offerta commerciale\')';
        //whereClause +=' AND (Product2.Family = \'VAS Prodotto\')';
		whereClause +=' AND Product2.Status__c=\'Vendibile\'';
		whereClause +=' AND Product2.IsActive = true';
		
        //whereClause += ' AND Product2.Comune__c = \''+ quote2.Comune_Fornitura__c+'\'';

        //modifica montors
        //whereClause += ' AND Product2Id IN (SELECT Product2Id__c FROM CityEligible__c WHERE Name = \'' + quote2.Comune_Fornitura__c + '\')';
        //whereClause +=' AND (NOT Product2.Family like \'Bonus%\') and (NOT Product2.Family like \'Contri%\')';
        //whereClause +=' AND (NOT Product2.Family like \'Opzione VAS%\') AND (NOT Product2.Family like \'Scont%VAS%\')';
        //whereClause +=' AND Product2.Status__c=\'Vendibile\'';
        //*** end ciro modification ***
        System.debug('Query Ciro '+ whereClause);
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
        Id QuoteId = String.valueOf(quote.get('Id'));
        SBQQ__Quote__c quote2= [SELECT Id,SBQQ__PricebookId__c,SBQQ__PriceBook__c from SBQQ__Quote__c where Id =: QuoteId];
		/*if(input.equalsIgnoreCase('Comune__c'))
        	return String.valueOf(quote2.Comune_Fornitura__c);
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

        return [SELECT Id FROM PricebookEntry LIMIT 1];
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
        
        List<String> sl = new List<String>();
        sl.add('Offerta commerciale');
        sl.add('VAS Prodotto');
        
        //*** start ciro modification ***
        Id QuoteId = String.valueOf(quote.get('Id'));
        SBQQ__Quote__c quote2= [SELECT Id,SBQQ__PricebookId__c,SBQQ__PriceBook__c from SBQQ__Quote__c where Id =: QuoteId];
        additionalFilter += 'PriceBook2Id = \'' + quote2.get('SBQQ__PriceBook__c') + '\'';
        additionalFilter += ' AND Product2.Family :IN sl';
		//additionalFilter +=' AND (Product2.Family = \'Offerta commerciale\')';
        //additionalFilter +=' AND (Product2.Family = \'VAS Prodotto\')';
        /*additionalFilter += ' AND Product2.Comune__c = \''+ quote2.Comune_Fornitura__c+'\'';
        additionalFilter +=' AND (NOT Product2.Family like \'Bonus%\') and (NOT Product2.Family like \'Contri%\')';
        additionalFilter +=' AND (NOT Product2.Family like \'Opzione VAS%\') AND (NOT Product2.Family like \'Scont%VAS%\')';*/
        additionalFilter +=' AND Product2.Status__c=\'Vendibile\'';
		additionalFilter +=' AND Product2.IsActive = true';
		//*** end ciro modification ***
		
        System.debug('Additional Filter Suggest: '+ additionalFilter);
        return additionalFilter;
    }
}