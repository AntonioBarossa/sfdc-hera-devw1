/*
    @Author:        Francesco Vitiello
    CreatedDate:    12/11/2021
    Reason: Modifica per gestione Annullamento Case con Phase "In Bozza", Case con Type "Blocco Sollecito/Interessi" e inversione porzioni di codice Case/Knowledge Article
*/
public inherited sharing class HDT_BA_PostSalesMasterBatch implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {


    public List<SObject> start(Database.BatchableContext bc){

        HDT_QR_PostSalesMasterBatch postsalesQr = new HDT_QR_PostSalesMasterBatch();

        List<SObject> scope = new List<SObject>();


        scope.addAll(postsalesQr.getExpiredCase());
        scope.addAll(postsalesQr.getQuotationCase());
        scope.addAll(postsalesQr.getNonReqContract());
        scope.addAll(postsalesQr.getAutoletturaBozzaCase());
        scope.addAll(postsalesQr.getPostSalesBozzaCase());
        scope.addAll(postsalesQr.getCaseVolturaTecnica());
        scope.addAll(postsalesQr.getExpiredArticle());


        return scope;


    } 

    /*
    @Author:        Francesco Vitiello
    CreatedDate:    19/10/2021
    Reason: Avoid Debug Statements
    */
    @SuppressWarnings('PMD.AvoidDebugStatements')
    public void execute(Database.BatchableContext bc, List<SObject> scope){

        List<Case> myCurrentCaseList = new List<Case>();
        //List<HDT_PEV_NonReqContract__e> eventsToPublish = new List<HDT_PEV_NonReqContract__e>();

        for(SObject sobj : scope){

            try{
                switch on sobj{

                    when Case currentCase{
                        
                        //ANNULLAMENTO CASE BOZZA AUTOLETTURA OLTRE SCADENZA
                        if(currentCase.Phase__c.equalsIgnoreCase('Bozza')){
                            currentCase.Phase__c = 'Bozza Annullata';
                            currentCase.Status = 'Closed';
                            myCurrentCaseList.add(currentCase);
                            /*if(currentCase.Cluster__c.equalsIgnoreCase('Autolettura')){
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
                            }*/
                        }
                        
                        if( currentCase.Type.equalsIgnoreCase('Piano Rateizzazione') && currentCase.Phase__c.equalsIgnoreCase('Pratica In Attesa') ){

                            currentCase.Phase__c = 'Da Inviare';
                            myCurrentCaseList.add(currentCase);

                        }else if( currentCase.Type.equalsIgnoreCase('Blocco Sollecito/Interessi') && currentCase.Phase__c.equalsIgnoreCase('Pratica In Attesa') ){

                            currentCase.Phase__c = 'In Lavorazione';
                            myCurrentCaseList.add(currentCase);

                        }else if( (currentCase.Cluster__c.equalsIgnoreCase('Preventivi') || currentCase.Cluster__c.equalsIgnoreCase('Verifiche')) && currentCase.Phase__c.equalsIgnoreCase('Attesa conferma preventivo cliente') ){

                            currentCase.Phase__c = 'Preventivo scaduto';
                            myCurrentCaseList.add(currentCase);

                        }else if(currentCase.Type.equalsIgnoreCase('Contratto Non Richiesto') && currentCase.Phase__c.equalsIgnoreCase('Pratica In Attesa') ){
                            HDT_QR_PostSalesMasterBatch postsalesQr = new HDT_QR_PostSalesMasterBatch();
                            Order relatedOrder = postsalesQr.getRelatedOrder(currentCase.Order__c);
                            if(relatedOrder!= null){
                                if(relatedOrder.EffectiveDate__c < System.today()){
                                    currentCase.Phase__c = 'Da Inviare';
                                    myCurrentCaseList.add(currentCase);
                                }
                            }
                        }else if( currentCase.Type.equalsIgnoreCase('Voltura Tecnica') && currentCase.Phase__c.equalsIgnoreCase('In attesa Data Decorrenza') ){
                            Boolean recalculatedDate = false;
                            if(currentCase.Order__c != null && currentCase.Order__r.EffectiveDate__c != null && currentCase.EffectiveDate__c < currentCase.Order__r.EffectiveDate__c)
                            {
                                recalculatedDate = true;
                                currentCase.SuspensionDate__c = System.today();
                                currentCase.SuspensionDays__c = currentCase.SuspensionDate__c.daysBetween(currentCase.Order__r.EffectiveDate__c);
                            }
                            currentCase.EffectiveDate__c = recalculatedDate ? HDT_UTL_Case.addBusinessDay(currentCase.Order__r.EffectiveDate__c,3) : HDT_UTL_Case.addBusinessDay(System.today(),3);
                            currentCase.Phase__c = recalculatedDate ? 'In attesa Data Decorrenza' : 'Da Inviare';
                            myCurrentCaseList.add(currentCase);
                        }               
                    }
                    when Knowledge__kav article{
                        if(article.ExpirationDate__c != null){
                            KbManagement.PublishingService.archiveOnlineArticle(article.KnowledgeArticleId,null);
                        }
                    }
                }
            }
            catch(Exception e)
            {
                System.debug(LoggingLevel.DEBUG, 'Exception: ' + e.getMessage() + '. At line: ' + e.getLineNumber());
                continue;
            }
        }
        // if(!eventsToPublish.isEmpty()){
        //     //EventBus.publish(eventsToPublish);
        //     List<Database.SaveResult> srList = EventBus.publish(eventsToPublish);
        //     for (Database.SaveResult sr : srList ) {
        //         if (sr.isSuccess()) {
        //             System.debug(LoggingLevel.DEBUG, 'Successfully published events.');
        //         } else {
        //             for (Database.Error err : sr.getErrors()) {
        //                 System.debug(LoggingLevel.DEBUG, 'Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
        //             }
        //         }
        //     }
        // }        
        if(!myCurrentCaseList.isEmpty()){
            updateObjectList(myCurrentCaseList);
            //HDT_UTL_DatabaseService.updateSObject(myCurrentCaseList);
        }
    }

    public void updateObjectList(List<SObject> caseToUpdate){
        if (HDT_UTL_DatabaseService.checkBeforeDml(caseToUpdate, HDT_UTL_DatabaseService.DmlOperation.DML_UPDATE)){
            System.debug(LoggingLevel.DEBUG, 'Update not performed for the following records: ' + JSON.serialize(caseToUpdate));
        }else{
            Database.SaveResult[] srList = Database.update(caseToUpdate, false);
            for (Database.SaveResult sr : srList){
                if (!sr.isSuccess()){
                    for (Database.Error err : sr.getErrors()){
                        System.debug(LoggingLevel.DEBUG, 'Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
                    }
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
        System.debug(LoggingLevel.DEBUG, 'HDT_BA_PostSalesMasterBatch - finished job: ' + a);
        
    }
}