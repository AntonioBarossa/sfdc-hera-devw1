public inherited sharing class HDT_BA_ProductStObjStatusUpdate implements Database.Batchable<SObject> {

    //public List<sObject> start(Database.BatchableContext bc){
    //    List<sObject> scope = new List<sObject>();
    //    return scope;
    //} 

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String queryString = '';
        queryString += 'SELECT Id, StartDate__c, EndDate__c, Status__c ';
        queryString += 'FROM Product2 ';
        queryString += 'WHERE  (Status__c = \'Confermata\' AND StartDate__c = today) OR (Status__c = \'Vendibile\' AND EndDate__c = today)';
        return Database.getQueryLocator(queryString);
    }

    public void execute(Database.BatchableContext bc, List<Product2> chunkList){

        Date todayDate = Date.today();

        System.debug('>>> Today is: ' + String.valueOf(todayDate) + ' - chunkListSize: ' + String.valueOf(chunkList.size()));

        for(Product2 product : chunkList){
            if(!String.isEmpty(product.Status__c) && product.StartDate__c != null && product.EndDate__c != null){

                switch on product.Status__c{
                    when 'Confermata' {
                        if(product.StartDate__c >= todayDate){
                            product.Status__c = 'Vendibile';
                        }
                    }

                    when 'Vendibile' {
                        if(product.EndDate__c >= todayDate){
                            product.Status__c = 'Scaduta';
                        }
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
                    System.debug(errorString);
                }
            }
        }

    }

    public void finish(Database.BatchableContext bc){}

}