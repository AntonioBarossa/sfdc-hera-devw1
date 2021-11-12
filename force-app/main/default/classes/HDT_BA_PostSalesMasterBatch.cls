public inherited sharing class HDT_BA_PostSalesMasterBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {


    public List<SObject> start(Database.BatchableContext bc){

        HDT_QR_PostSalesMasterBatch postsalesQr = new HDT_QR_PostSalesMasterBatch();

        List<SObject> scope = new List<SObject>();


        scope.addAll(postsalesQr.getExpiredArticle());
        scope.addAll(postsalesQr.getExpiredCase());
        scope.addAll(postsalesQr.getQuotationCase());
        scope.addAll(postsalesQr.getNonReqContract());
        scope.addAll(postsalesQr.getAutoletturaBozzaCase());
        scope.addAll(postsalesQr.getPostSalesBozzaCase());


        return scope;


    } 

    /*
    @Author:        Francesco Vitiello
    CreatedDate:    19/10/2021
    Reason: Avoid Debug Statements
    */
    @SuppressWarnings('PMD.AvoidDebugStatements')
    public void execute(Database.BatchableContext bc, List<SObject> scope){

        Sobject mySobj2;
        Sobject mySobj3;

        Try{
            //Get Data for source Custom Setting
            String whereConditionFieldValue1 = 'Autolettura';
            String queryString1 = 'SELECT id, Type__c, NumberOfDays__c FROM CS_DaysToExpiration__c where Type__c = \'' + String.escapeSingleQuotes(whereConditionFieldValue1) + '\'';
            mySobj2 = database.query(queryString1);

            String whereConditionFieldValue2 = 'PostSales';
            String queryString2 = 'SELECT id, Type__c, NumberOfDays__c FROM CS_DaysToExpiration__c where Type__c = \'' + String.escapeSingleQuotes(whereConditionFieldValue2) + '\'';
            mySobj3 = database.query(queryString2);

        }catch(Exception e){
            System.debug(LoggingLevel.DEBUG, 'Exception: ' + e.getMessage() + '. At Line: ' + e.getLineNumber());
        }

        List<Case> myCurrentCaseList = new List<Case>();

        for(SObject sobj : scope){

            switch on sobj{

                when Case currentCase{
                    
                    //ANNULLAMENTO CASE BOZZA AUTOLETTURA OLTRE SCADENZA
                    if(currentCase.Phase__c.equalsIgnoreCase('Bozza') && mySobj2 != null && mySobj3 != null){

                        if(currentCase.Cluster__c.equalsIgnoreCase('Autolettura')){
                            //Get data from Days to Expiration Custom Setting
                            CS_DaysToExpiration__c myCS1 = (CS_DaysToExpiration__c)mySobj2;
                            Integer strNumberOfDays = integer.valueof(myCS1.NumberOfDays__c);

                            if(currentCase.CreatedDate < (System.today() - strNumberOfDays)){
                                currentCase.Phase__c = 'Bozza Annullata';
                                myCurrentCaseList.add(currentCase);
                                continue;
                            }
                        } else {
                            //Get data from Days to Expiration Custom Setting
                            CS_DaysToExpiration__c myCS2 = (CS_DaysToExpiration__c)mySobj3;
                            Integer strNumberOfDays = integer.valueof(myCS2.NumberOfDays__c);
                            
                            if(currentCase.CreatedDate < (System.today() - strNumberOfDays)){
                                currentCase.Phase__c = 'Bozza Annullata';
                                myCurrentCaseList.add(currentCase);
                                continue;
                            }
                        }
                    }
                    
                    
                    if(currentCase.Type.equalsIgnoreCase('Piano Rateizzazione') || currentCase.Type.equalsIgnoreCase('Blocco Sollecito/Interessi')){
                        SObject transition;
                        SObject action;
                        String method = currentCase.Type.equalsIgnoreCase('Piano Rateizzazione') ? 'HDT_InstallmentPlans' : 'HDT_ReminderBlock';
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
                        myCurrentCaseList.add(newCase);
                    }else if(currentCase.Cluster__c.equalsIgnoreCase('Preventivi') || currentCase.Cluster__c.equalsIgnoreCase('Verifiche')){
                        currentCase.Phase__c = 'Preventivo scaduto';
                        HDT_PEV_NonReqContract__e event = new HDT_PEV_NonReqContract__e();
                        event.SerializedCase__c = JSON.serialize(currentCase);
                        Database.SaveResult sr = EventBus.publish(event);
                        if (sr.isSuccess()) {
                            System.debug(LoggingLevel.DEBUG, 'Successfully published event.');
                        } else {
                            for (Database.Error err : sr.getErrors()) {
                                System.debug(LoggingLevel.DEBUG, 'Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
                            }
                        }
                    }else if(currentCase.Type.equalsIgnoreCase('Contratto Non Richiesto')){
                        HDT_QR_PostSalesMasterBatch postsalesQr = new HDT_QR_PostSalesMasterBatch();
                        Order relatedOrder = postsalesQr.getRelatedOrder(currentCase.Order__c);
                        if(relatedOrder!= null){
                            if(relatedOrder.EffectiveDate__c < System.today()){
                                currentCase.Phase__c = 'Da Inviare';
                                //Fire del platform event per inviare il flusso ad Heroku
                                //System.debug('# case da delegare ad un altro evento: ' + currentCase.size());
                                HDT_PEV_NonReqContract__e event = new HDT_PEV_NonReqContract__e();
                                event.SerializedCase__c = JSON.serialize(currentCase);
                                Database.SaveResult sr = EventBus.publish(event);
                                if (sr.isSuccess()) {
                                    System.debug(LoggingLevel.DEBUG, 'Successfully published event.');
                                } else {
                                    for (Database.Error err : sr.getErrors()) {
                                        System.debug(LoggingLevel.DEBUG, 'Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
                                    }
                                }
                            }
                        }
                    }                    
                }
                when Knowledge__kav article{
                    if(article.ExpirationDate__c != null){
                        KbManagement.PublishingService.archiveOnlineArticle(article.KnowledgeArticleId,null);
                    }
                }
            }
        }
        if(!myCurrentCaseList.isEmpty()){
            HDT_UTL_DatabaseService.updateSObject(myCurrentCaseList);
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
        System.debug(LoggingLevel.DEBUG, 'HDT_BA_PostSalesMasterBatch - finished job: ' + a);
        
    }


}