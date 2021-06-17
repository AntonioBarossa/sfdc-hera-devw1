public inherited sharing class HDT_BA_PostSalesMasterBatch implements Database.Batchable<SObject> {


    public List<SObject> start(Database.BatchableContext bc){

        HDT_QR_PostSalesMasterBatch postsalesQr = new HDT_QR_PostSalesMasterBatch();

        List<SObject> scope = new List<SObject>();


        scope.addAll(postsalesQr.getExpiredArticle());
        scope.addAll(postsalesQr.getExpiredCase());

        return scope;


    } 


    public void execute(Database.BatchableContext bc, List<SObject> scope){

        for(SObject sobj : scope){

            switch on sobj{

                when Knowledge__kav article{

                    if(article.ExpirationDate__c != null){

                        //ADD PUBLISHMANAGEMENT CLASS TO ARCHIVE

                    }

                }

                when Case c{

                    //CREATE THE ARGS MAP FOR THE EXECUTE METHOD OF WS_PAYMENTS
                    //CALL THE EXECUTE METHOD

                }

            }


        }

        HDT_UTL_DatabaseService.updateSObject(scope);

    }


    public void finish(Database.BatchableContext bc){}


}