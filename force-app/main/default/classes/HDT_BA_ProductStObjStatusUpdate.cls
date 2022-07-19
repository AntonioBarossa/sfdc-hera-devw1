public inherited sharing class HDT_BA_ProductStObjStatusUpdate implements Database.Batchable<SObject> {

    //public List<sObject> start(Database.BatchableContext bc){
    //    List<sObject> scope = new List<sObject>();
    //    return scope;
    //} 

    public Database.QueryLocator start(Database.BatchableContext bc) {

        String queryString = '';
        queryString += 'SELECT Id, StartDate__c, EndDate__c, Status__c ';
        queryString += 'FROM Product2 ';

        if(!Test.isRunningTest()){
            queryString += 'WHERE  (Status__c = \'' + Label.HDT_Confirmed + '\' AND StartDate__c = today) ';
            queryString += 'OR (Status__c = \'' + Label.HDT_Sold + '\' AND EndDate__c = yesterday)';
        }
        
        return Database.getQueryLocator(queryString);
    }

    /*
    @Author:        Francesco Vitiello
    CreatedDate:    19/10/2021
    Reason: Avoid Debug Statements
    */
    @SuppressWarnings('PMD.AvoidDebugStatements')
    public void execute(Database.BatchableContext bc, List<Product2> chunkList){

        Date todayDate = Date.today();
        Date yesterday = Date.today().addDays(-1);

        System.debug(LoggingLevel.DEBUG, '>>> Today is: ' + String.valueOf(todayDate) + ' - chunkListSize: ' + String.valueOf(chunkList.size()));

        for(Product2 product : chunkList){
            if(!String.isEmpty(product.Status__c) && product.StartDate__c != null && product.EndDate__c != null){

                if(product.Status__c.equalsIgnoreCase(Label.HDT_Confirmed)){
                    if(product.StartDate__c >= todayDate){
                        product.Status__c = Label.HDT_Sold;
                    }
                } else if(product.Status__c.equalsIgnoreCase(Label.HDT_Sold)){
                    if(product.EndDate__c == yesterday){
                        product.Status__c = Label.HDT_Expired;
                    }
                }

            }

        }

        SObjectType objtype = Schema.getGlobalDescribe().get('Product2');
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();
 
        if(objRes.isUpdateable()){
            
            List<Database.SaveResult> updateResults = Database.update(chunkList, false);

            for(Integer n=0; n < updateResults.size(); n++){
                Database.SaveResult sr = updateResults[n];

                if (!sr.isSuccess()) {
                    // Operation failed
                    String errorString = '';
                    for(Database.Error err : sr.getErrors()) {
                        errorString += ' [' + err.getStatusCode() + ': ' + err.getMessage() + ' on field: ' + err.getFields() + ']';
                    }
                    System.debug(LoggingLevel.DEBUG, errorString);
                }
            }
        }

    }

    /*
    @Author:        Francesco Vitiello
    CreatedDate:    19/10/2021
    Reason: Avoid Debug Statements
    */
    @SuppressWarnings('PMD.AvoidDebugStatements')
    public void finish(Database.BatchableContext bc){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        System.debug(LoggingLevel.DEBUG, 'HDT_BA_ProductStObjStatusUpdate - finished job: ' + a);
        
    }

}