public inherited sharing class HDT_QR_QuoteManagement {

    public static List<QuoteManagement__c> queryAddInformation(String commodity, String operationType){

        return [SELECT CausalCode__c, OperationCode__c, QuoteType__c 
        
                FROM QuoteManagement__c 
        
                WHERE 
                
                Commodity__c = :commodity 
                
                AND 
                
                Operation_type__c = :operationType

                ];

    }
	
	public static List <QuoteManagement__c> queryString(String fields, String conditions){
		String query = 'SELECT ' + fields + ' FROM QuoteManagement__c WHERE ' + conditions;
		return Database.query(query);
		 
	}
}