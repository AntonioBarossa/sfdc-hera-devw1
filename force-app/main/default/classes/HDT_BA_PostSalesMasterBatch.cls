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

                    SObject transition;
                    SObject action;
                    String method = 'HDT_InstallmentPlans';
                    SOBject sender = c;
                    Map<String, Object> args = new Map<String,Object>();
                    args.put('transition', transition);
                    args.put('action', action);
                    args.put('method',method);
                    args.put('sender', sender);

                    HDT_WS_Payments paymentsWs = new HDT_WS_Payments();
                    wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse responseReturn = new wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse();
                    responseReturn = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse) paymentsWs.execute(args);

                }

            }


        }

        HDT_UTL_DatabaseService.updateSObject(scope);

    }


    public void finish(Database.BatchableContext bc){}


}