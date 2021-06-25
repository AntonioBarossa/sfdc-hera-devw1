public inherited sharing class HDT_BA_PostSalesMasterBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {


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

                        KbManagement.PublishingService.archiveOnlineArticle(article.KnowledgeArticleId,null);

                    }

                }

                when Case currentCase{

                    SObject transition;
                    SObject action;
                    String method = 'HDT_InstallmentPlans';
                    Map<String, Object> args = new Map<String,Object>();
                    Case newCase = new Case();
                    newCase.Id = currentCase.Id;
                    args.put('transition', transition);
                    args.put('action', action);
                    args.put('method',method);
                    args.put('sender', currentCase);

                    HDT_WS_Payments paymentsWs = new HDT_WS_Payments();
                    wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse responseReturn = new wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse();
                    responseReturn = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse) paymentsWs.execute(args);

                    //TO trigger Technical Phase
                    HDT_UTL_DatabaseService.updateSObject(newCase);

                }

            }


        }

    }


    public void finish(Database.BatchableContext bc){}


}