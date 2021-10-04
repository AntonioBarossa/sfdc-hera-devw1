public inherited sharing class HDT_QR_QuoteManagement {

    public static QuoteManagement__c queryAddInformation(String commodity, String operationType){

        return [SELECT CausalCode__c, OperationCode__c, QuoteType__c 
        
                FROM QuoteManagement__c 
        
                WHERE 
                
                Commodity__c = :commodity 
                
                AND 
                
                Operation_type__c = :operationType

                WITH SECURITY_ENFORCED

                LIMIT 1

                ];

    }
	
	public static QuoteManagement__c queryString(String fields, String conditions){
        QuoteManagement__c quoteConfig = new QuoteManagement__c();
		String query = 'SELECT ' + fields + ' FROM QuoteManagement__c WHERE ' + conditions + ' WITH SECURITY_ENFORCED LIMIT 1';
        System.debug(LoggingLevel.DEBUG,'Query--> '+query);
        try{
            quoteConfig = Database.query(String.escapeSingleQuotes(query));
        } catch(Exception e){
            quoteConfig = null;
            //System.debug('Config Not Found -> ' + e.getMessage());
        }
		return quoteConfig;
		 
	}
}