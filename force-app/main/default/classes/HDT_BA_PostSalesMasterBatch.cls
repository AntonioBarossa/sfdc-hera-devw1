public inherited sharing class HDT_BA_PostSalesMasterBatch implements Database.Batchable<SObject> {


    public List<SObject> start(Database.BatchableContext bc){

        List<SObject> scope = new List<SObject>();

        scope.addAll([SELECT ExpirationDate__c 
        FROM Knowledge__kav 
        WHERE RecordType.DeveloperName = 'HDT_RT_News' 
        WITH SECURITY_ENFORCED]);

        return scope;


    } 


    public void execute(Database.BatchableContext bc, List<SObject> scope){

        for(SObject sobj : scope){

            switch on sobj{

                when Knowledge__kav article{

                    if(article.ExpirationDate__c != null
                    && article.ExpirationDate__c >= System.today()){

                        article.PublishStatus = 'Archived';

                    }

                }

                when Case c{

                    //Case Counters

                }

            }


        }

        HDT_UTL_DatabaseService.updateSObject(scope);

    }


    public void finish(Database.BatchableContext bc){}


}