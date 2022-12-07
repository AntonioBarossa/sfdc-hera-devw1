@SuppressWarnings('PMD.AvoidDebugStatements,PMD.CyclomaticComplexity')
public without sharing class HDT_UTL_ActivityCustomProcess {

    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_SRV_ActivityCustom activitySrv = new HDT_SRV_ActivityCustom();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();

    public static void changeAssignRelatedRecord(List<wrts_prcgvr__Activity__c> triggernew , List<wrts_prcgvr__Activity__c> triggerold){
        HDT_QR_Recordtype recQr = new HDT_QR_Recordtype();
        String recordtypeid = recQr.getRecordTypeIdByName('HDT_RT_VisitaD2D', 'wrts_prcgvr__Activity__c');
        HDT_QR_Contact contactQr = new HDT_QR_Contact();
        HDT_SRV_Account accountSrv = new HDT_SRV_Account();
        Map<id,String> mapIdOwnerIdBef = new Map<Id,String>();
        //Map<id,String> mapIdOwnerIdAfter = new Map<Id,String>();
        Map<id,String> mapContactIdOwner = new Map<Id,String>();
        String userId = userinfo.getuserid();
        List<Lead> listLead = new List<Lead>();
        List<String> listContactId = new List<String>();
        List<Account> listAccount = new List<Account>();
		system.debug(LoggingLevel.DEBUG, 'DENTRO HANDLER HANDLER: ' + triggernew);
        List<wrts_prcgvr__Activity__c> listActD2DBef = filterByD2D(triggerold,recordtypeid);
        for(wrts_prcgvr__Activity__c art : listActD2DBef){
            system.debug(LoggingLevel.DEBUG, 'DENTRO HANDLER HANDLER2:' + art);
            mapIdOwnerIdBef.put(art.id,art.ownerId);
        } 
        List<wrts_prcgvr__Activity__c> listActD2DAfter = filterByD2D(triggernew,recordtypeid);
       /* for(wrts_prcgvr__Activity__c art : listActD2DBef){
            mapIdOwnerIdAfter.put(art.id,art.ownerId);
        }*/
        for(wrts_prcgvr__Activity__c art : listActD2DAfter){
            if(mapIdOwnerIdBef.get(art.id)!= null && art.ownerId == userId && mapIdOwnerIdBef.get(art.id) != art.ownerId){
                if(art.lead__c != null){
                    listLead.add(new Lead(id=art.lead__c,ownerId=art.ownerId));
                }
                else if(art.Contact__c != null){
                    listContactId.add(art.Contact__c);
                    mapContactIdOwner.put(art.contact__c,art.OwnerId);
                }
            }
        }
        if(listLead != null && !listLead.isEmpty()){
            HDT_SRV_Lead.updateRecord(listLead);
        }
        if(!listContactId.isEmpty()){
            List<Contact> contactList = contactQr.getRecordsById(listContactId);
            List<AccountShare> lAccSh = new List<AccountShare>();
            for(Contact c : contactList){
                if(mapContactIdOwner.get(c.id)!= null && c.AccountId != null){
                    system.debug(LoggingLevel.DEBUG, '************:'+c.AccountId);
                    lAccSh.add(HDT_UTL_RecordShare.accountShareEditCreate(c.AccountId,mapContactIdOwner.get(c.id)));
                    listAccount.add(new Account(id=c.AccountId,ownerId=mapContactIdOwner.get(c.id)));
                }
            }
            /*if(lAccSh != null && !lAccSh.isEmpty()){
                system.debug(LoggingLevel.DEBUG, 'PROVAPROVA:' + lAccSh);
                HDT_SRV_RecordShare.createRecordWithout(lAccSh);
            }*/            
            if(listAccount != null && !listAccount.isEmpty()){
                accountSrv.updateRecordsNoShare(listAccount);
            }
        }
    }

    private static List<wrts_prcgvr__Activity__c> filterByD2d(List<wrts_prcgvr__Activity__c> li,String recordtypeid){
        List<wrts_prcgvr__Activity__c> rep = new List<wrts_prcgvr__Activity__c>();
        system.debug(LoggingLevel.DEBUG, 'DENTRO HANDLER HANDLER4:');
        for(wrts_prcgvr__Activity__c act : li){
            if(recordtypeid.equalsIgnoreCase(act.recordtypeid)){
                system.debug(LoggingLevel.DEBUG, 'DENTRO HANDLER HANDLER5:');
                rep.add(act);
            }
        }
        return rep;
    }

    // @Picchiri 08.06.21 Credit Check Annullamento Ordine
    // Alla ricezione di un esito KO, verrà creata su Salesforce un Activities
    public static void createActivityForCreditCheck(Map<String,List<Order>> orderMap){        

        system.debug(LoggingLevel.DEBUG, 'HDT_UTL_ActivityProcess createActivity --> orderMap : ' + JSON.serializePretty(orderMap));
        
        List<wrts_prcgvr__Activity__c> listActivity = new List<wrts_prcgvr__Activity__c>();
        //Id rtOldCustomer = [SELECT Id FROM RecordType WHERE DeveloperName = 'HDT_RT_KoPrecedeteCliente' limit 1].id;
        //Id rtNewCustomer = [SELECT Id FROM RecordType WHERE DeveloperName = 'HDT_RT_CreditCheckKO' limit 1].id;
        Map<String, Schema.RecordTypeInfo> activityRtInfos = ((SObject)Type.forName('Schema','wrts_prcgvr__Activity__c').newInstance()).getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName();
        Id rtOldCustomer = activityRTInfos.get('HDT_RT_KoPrecedeteCliente').getRecordTypeId();
        Id rtNewCustomer = activityRTInfos.get('HDT_RT_CreditCheckKO').getRecordTypeId();
        Set<Id> oldCustOrderIds = new Set<Id>();

        for(Order o : orderMap.get('oldCustomer')){ 
            oldCustOrderIds.add(o.id);
        }
        Map<id, Order> ordersToGetOldCustomer = new Map<Id,Order>([SELECT AccountId, ServicePoint__r.Account__c FROM Order WHERE ID IN :oldCustOrderIds ]);

        for(String typeCustomer : orderMap.keyset()){
            for(Order order : orderMap.get(typeCustomer)){
                wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();

                if(typeCustomer == 'oldCustomer'){ // Precedente cliente // uscente // vecchio cliente
                    activity.RecordTypeId = rtOldCustomer;                     
                    activity.CreditCheckResults__c = order.OutgoingCreditCheckResult__c;
                    activity.Account__c = order.ServicePoint__r.Account__c; 
                    activity.OldCustomerAccount__c=ordersToGetOldCustomer.get(order.Id).ServicePoint__r?.Account__c;
                    activity.Type__c = 'KO Precedente Cliente';
                }
                        
                if(typeCustomer == 'newCustomer'){ // Nuovo cliente // entrante
                    activity.RecordTypeId = rtNewCustomer;                     
                    activity.CreditCheckResults__c = order.IncomingCreditCheckResult__c;
                    activity.Account__c = order.AccountId; 
                    activity.Type__c = 'KO Credit Check';
                }

                activity.CreditCheckReason__c = order.CreditCheckDescription__c;
                activity.wrts_prcgvr__Description__c = order.CreditCheckDescription__c;
                activity.Order__c = order.Id;                
                activity.Contact__c = order.Contact__c;                                
                activity.wrts_prcgvr__Status__c = 'Aperta';                
                //activity.Note__c = order.CommentForDL__c;
                activity.OwnerId = order.OwnerId;
                activity.CvpId__c= order.CvpId__c;
                activity.CvpCgs__c=order.CvpCgs__c;

                activity.CvpErrorCode__c=order.CvpErrorCode__c;
                activity.CvpErrorDescription__c=order.CvpErrorDescription__c;
                activity.CvpErrorSource__c=order.CvpErrorSource__c;
                activity.CvpRiskRating__c=order.CvpRiskRating__c;

                listActivity.add(activity);
            }

        }

        if(!listActivity.isEmpty()){   
            activitySrv.createRecordWithFieldCheck(listActivity);    
            //insert listActivity;
        }
        
    
    }

    
    public static void updateCreditCheckActivity(List<wrts_prcgvr__Activity__c> actListToUpdate){        
        if(!actListToUpdate.isEmpty()){
            system.debug(LoggingLevel.DEBUG, 'Start updateCreditCheckActivity -----> ' + json.serializePretty(actListToUpdate));
            activitySrv.updateRecords(actListToUpdate);
            //update actListToUpdate;
        }
    }

    // @Picchiri 08.06.21 Credit Check 
    // Annullamento Activity di Credit Check e annullamento Ordine in caso di KO Definitvo dell'activity
    public static void annullamentoActivityCustom(List<wrts_prcgvr__Activity__c> newActList, Map<Id,wrts_prcgvr__Activity__c> oldMap){

        Set<Id> orderIdToAnnullamento = new Set<Id>();        
        for(wrts_prcgvr__Activity__c act : newActList){
            if('KO Definitivo'.equalsIgnoreCase(act.wrts_prcgvr__Status__c) && act.wrts_prcgvr__Status__c!= oldMap.get(act.Id).wrts_prcgvr__Status__c){
                orderIdToAnnullamento.add(act.Order__c);                 
            }
        }
        if(!orderIdToAnnullamento.isEmpty()){
            system.debug(LoggingLevel.DEBUG, 'orderIdToAnnullamento ----> ' + orderIdToAnnullamento);        
            List<Order> orderToAnnullamento = [SELECT id,Status, RecordType.DeveloperName FROM Order WHERE id IN :orderIdToAnnullamento WITH SECURITY_ENFORCED];
            for(Order order : orderToAnnullamento){        
                if(order.RecordType.DeveloperName.equalsIgnoreCase('HDT_RT_Voltura')){
                    order.Phase__c = 'Accettazione Voltura';
                }        
                else {
                    order.Status = 'Annullato';     
                    order.Phase__c = 'Annullato'; 
                    order.CancellationReason__c = 'Gestione Scarto';  
                }                             
            }
            orderSrv.updateRecords(orderToAnnullamento);
            //update orderToAnnullamento;
        }
    }


    /**
    * @description 
    * @author federico.defelice@webresults.it | 29-09-2021 
    * @param newActMap 
    * @param oldActMap 
    **/
    public static void closeSobjectOnActivityClosing(List<wrts_prcgvr__Activity__c> newActList, List<wrts_prcgvr__Activity__c> oldActList){
        //Proroga connessione temporanea
        Set<Id> sobjsId = new Set<Id>();
        Map<Id, wrts_prcgvr__Activity__c> oldActMap = new Map<Id, wrts_prcgvr__Activity__c>(oldActList);
        for(wrts_prcgvr__Activity__c act : newActList){
            if(act.wrts_prcgvr__Status__c=='Chiusa' && oldActMap.get(act.id).wrts_prcgvr__Status__c=='Aperta'){
                sobjsId.add((ID)act.wrts_prcgvr__ObjectId__c);
            }
        }

        Map<Id, Case> casesToUpdate = new Map<Id, Case>([Select id, Phase__c from Case where RecordType.DeveloperName='HDT_RT_ProrogaTemporanea' AND Phase__c='In Lavorazione' AND Id IN :sobjsId WITH SECURITY_ENFORCED]);
        if(!casesToUpdate.isEmpty()){
            for(Case c : casesToUpdate.values()){
                c.Phase__c='Completata';
            }
        }
        new HDT_SRV_Case().updateRecords(casesToUpdate.values());
    }

    // @Picchiri 15.06.21 Credit Check Gestione Esiti ed eventuali invocazione a chiamata Mulesoft
    public static wrts_prcgvr__Activity__c closeActivityCheck(wrts_prcgvr__Activity__c act){
        act.wrts_prcgvr__Status__c = 'Chiusa'; 
        return act;       
    }

    // @Picchiri 14.06.21 Credit Check Gestione Esiti ed eventuali invocazione a chiamata Mulesoft
    public static void creditCheckKoPrecedenteCliente(List<wrts_prcgvr__Activity__c> newActList, List<wrts_prcgvr__Activity__c> oldActList){
        system.debug(LoggingLevel.DEBUG, 'Start creditCheckKoPrecedenteCliente --->');

        HDT_QR_Recordtype recQr = new HDT_QR_Recordtype();
        Id recordtypeOutgoing = recQr.getRecordTypeIdByName('HDT_RT_KoPrecedeteCliente', 'wrts_prcgvr__Activity__c');
        Id recordtypeIncoming = recQr.getRecordTypeIdByName('HDT_RT_CreditCheckKO', 'wrts_prcgvr__Activity__c');
        
        List<Id> actListToRecheck = new List<Id>();
        for(Integer i = 0; i < newActList.size(); i++){
            wrts_prcgvr__Activity__c act = newActList[i];
            wrts_prcgvr__Activity__c actOld = oldActList[i];
            if((act.recordtypeid == recordtypeOutgoing && actOld.CreditCheckResults__c == 'KO' && act.CreditCheckResults__c == 'OK' && (act.Reason__c == 'Dimostrata Estraneità' || act.Reason__c == 'Saldo Pagato') && act.wrts_prcgvr__Status__c == 'KO Risolto')
            || (act.recordTypeId == recordtypeIncoming && 'KO Risolto'.equalsIgnoreCase(act.wrts_prcgvr__Status__c) && 'Saldo debito cattivo pagatore'.equalsIgnoreCase(act.CreditCheckResolutionReason__c) && !act.CreditCheckResolutionReason__c.equalsIgnoreCase(actOld.CreditCheckResolutionReason__c))){                    
                actListToRecheck.add(act.Id);                    
            }
        }

        system.debug(LoggingLevel.DEBUG, 'actListToRecheck' + JSON.serializePretty(actListToRecheck));

        /* if(!actListToRecheck.isEmpty()){
            recheckCreditCheck(actListToRecheck);
        } */

        Boolean limitQueueablesOk = Limits.getQueueableJobs() < Limits.getLimitQueueableJobs();
        if(!actListToRecheck.isEmpty() && limitQueueablesOk){
            System.enqueueJob(new HDT_QBL_CreditCheckCall(actListToRecheck));
        }
    
    }

    // @Picchiri 15.06.21 chiamata Mulesoft
    public static void recheckCreditCheck(List<Id> actIdListToRecheck){
        system.debug(LoggingLevel.DEBUG, 'Start recheckCreditCheck --->');
        
        
        List<wrts_prcgvr__Activity__c> actListToRecheck = HDT_QR_ActivityCustom.getActivityKoPrecedenteClienteByIds(actIdListToRecheck);
        for(wrts_prcgvr__Activity__c act : actListToRecheck){  
        
            String typeOfCommodity = act.Order__r.ServicePoint__r.CommoditySector__c;
            String fiscalData = null;
            String bpClass = null;
            
            if (act.Order__r != null && act.Order__r.Account != null && String.isNotBlank(act.Order__r.Account.CustomerMarking__c) && Pattern.matches('[D][0-9][ ]+[-][ ]+[a-z A-Z]+', act.Order__r.Account.CustomerMarking__c)){
                bpClass = act.Order__r.Account.CustomerMarking__c.replaceFirst('[D][0-9][ ]+[-][ ]+','');
            }else if (act.Order__r != null && act.Order__r.Account != null && String.isNotBlank(act.Order__r.Account.CustomerMarking__c)){
                bpClass = act.Order__r.Account.CustomerMarking__c;
            }
            //Boolean precedenteCliente = null;

            if(act.Order__r.RecordType.DeveloperName == 'HDT_RT_Subentro' || act.Order__r.RecordType.DeveloperName == 'HDT_RT_Voltura'){
            
                if(act.Order__r.Account.RecordType.DeveloperName == 'HDT_RT_Residenziale'){
                    fiscalData = act.Order__r.ServicePoint__r.Account__r.FiscalCode__c;
                }else if(act.Order__r.ServicePoint__r.Account__r.VATNumber__c != null){
                    fiscalData = act.Order__r.ServicePoint__r.Account__r.VATNumber__c;
                }
                //precedenteCliente = true;                
            }
                
            if(typeOfCommodity == 'Energia Elettrica'){
                typeOfCommodity = 'ENERGIAELETTRICA';
            }
            if(typeOfCommodity == 'Gas'){
                typeOfCommodity = 'GAS';
            }
            
            HDT_WS_CreditCheckRequest.HDT_WRP_InputWrapperDetail iwd = new HDT_WS_CreditCheckRequest.HDT_WRP_InputWrapperDetail();
            if(act.Order__r.ServicePoint__c != null && act.Order__r.ServicePoint__r.AnnualConsumption__c != null){
                iwd.annualConsumption = String.valueOf(act.Order__r.ServicePoint__r.AnnualConsumption__c);
            }            
            iwd.commodity = typeOfCommodity;
            
            system.debug(LoggingLevel.DEBUG, 'HDT_VFC_InputWrapperDetail ---> ' + JSON.serialize(iwd)); 

            List<HDT_WS_CreditCheckRequest.HDT_WRP_InputWrapperDetail> l = new List<HDT_WS_CreditCheckRequest.HDT_WRP_InputWrapperDetail>();
            l.add(iwd);

            // da testare 18/6/21 @Picchiri
            if(act.Order__r.RecordType.DeveloperName == 'HDT_RT_VAS' ){
                l.remove(0);
                l.remove(1);
            }

            system.debug(LoggingLevel.DEBUG, 'HDT_VFC_InputWrapperDetail 2 ---> ' + JSON.serialize(iwd)); 
            String separator =  String.isBlank(act.Order__r.Account?.CustomerCode__c)? ',':' ';
            
            HDT_WS_CreditCheckRequest iw = new HDT_WS_CreditCheckRequest();
            iw.sistema = 'eEnergy';
            iw.caso = 'Transazionale';
            iw.crmEntity = 'Order';
            iw.crmId = String.valueOf(act.Order__c).substring(0,15);
            iw.userId = act.Order__r.CreatedById;
            iw.activationUser = 'AccountCommercialePRM';
            iw.account = 'AccountCommercialePRM';
            iw.jobTitle = act.Order__r.ChannelTransCode__c;
            iw.internalCustomerId = String.isNotBlank(act.Order__r.Account?.CustomerCode__c)? act.Order__r.Account.CustomerCode__c : act.Order__r.Account != null? '1-'+String.valueOf(act.Order__r.Account.Id).substring(7,15):'';
            iw.companyName = String.isNotBlank(act.Order__r.Account?.FirstName__c)? act.Order__r.Account.FirstName__c+separator+act.Order__r.Account.LastName__c : act.Order__r.Account?.LastName__c;
            iw.externalCustomerId = String.isNotBlank(act.Order__r.Account?.FiscalCode__c)? act.Order__r.Account.FiscalCode__c : act.Order__r.Account?.VATNumber__c;
            iw.secondaryCustomerId = act.Order__r.Account.VATNumber__c;
            /**
             * FIX TK 914861C
             * Description: Atos ha richiesto di inviare la marcatura per esteso. In precedenza veniva inviata la marcatura AS-IS Siebel.
             * Azioni: Commentata riga 316 e aggiunta riga 317
             * **/
            //iw.bpClass =  bpClass;
            iw.bpClass =  act.Order__r.Account?.CustomerMarking__c;
            iw.bpCategory = act.Order__r.Account.Category__c; 
            iw.bpType = act.Order__r.Account.CustomerType__c;
            iw.customerType = 'CT0';
            if(act.Order__r.RecordType.DeveloperName != 'HDT_RT_VAS' ){
                iw.address = act.Order__r.ServicePoint__r.SupplyStreetName__c;
                iw.municipality = act.Order__r.ServicePoint__r.SupplyCity__c;
                iw.district = act.Order__r.ServicePoint__r.SupplyProvince__c;
                iw.postCode = act.Order__r.ServicePoint__r.SupplyPostalCode__c;
            }            
            iw.operation =  act.Order__r.ProcessType__c;
            iw.companyGroup = act.Order__r.SalesCompany__c;
            iw.market = act.Order__r.Market__c;
            iw.offerType = act.Order__r.Catalog__c;
            iw.details = l;
            /*if(precedenteCliente == true){
                iw.bpAlternative = act.Order__r.ServicePoint__r.Account__r.CustomerCode__c;
                iw.alternativeCustomerId = fiscalData;            
            }*/
            system.debug(LoggingLevel.DEBUG, 'request ' + JSON.serialize(iw)); 
            HDT_WS_CreditCheck.callService(iw);
        }
    }
    // END @Picchiri 15.06.21 

    // @Alessio Murru 
    // public static void manageStatusChangeCrediCheck(List<wrts_prcgvr__Activity__c> triggernew , List<wrts_prcgvr__Activity__c> triggerold){
    //     HDT_QR_Recordtype recQr = new HDT_QR_Recordtype();
    //     String recordtypeid = recQr.getRecordTypeIdByName('HDT_RT_CreditCheckKO');
    //     Map<id,wrts_prcgvr__Activity__c> mapActivityNew = new Map<Id,wrts_prcgvr__Activity__c>();
    //     Map<id,wrts_prcgvr__Activity__c> mapActivityOld = new Map<Id,wrts_prcgvr__Activity__c>();
    //     List<wrts_prcgvr__Activity__c> actListToRecheck = new List<wrts_prcgvr__Activity__c>();

	// 	system.debug(LoggingLevel.DEBUG, 'manageStatusChangeCrediCheck: Creating map of HDT_RT_CreditCheckKO recordtype');
    //     List<wrts_prcgvr__Activity__c> listActD2DBef = filterByD2D(triggerold,recordtypeid);

    //     for(Integer i = 0; i < triggernew.size(); i++){
    //         if(triggernew[i].recordtypeid == recordtypeid && triggerold[i].recordtypeid == recordtypeid){
    //             mapActivityNew.put(triggernew[i].id, triggernew[i]);
    //             mapActivityOld.put(triggerold[i].id, triggerold[i]);
    //         }
    //     }

    //     Set<Id> listOrderBadPayer = new Set<Id>();
    //     // mapActivityOld e mapActivityNew contengono solo le attività di tipo credicCheck KO (filtrando per recordtype)
    //     /*
    //         KO Cattivo Pagatore 
    //         Aspettare da SAP l’esito di avvenuta estinzione del debito: Se entro 60 gg SAP notifica l’OK , 
    //         in automatico verrà chiusa l’atctivity con Stato Lavorazione “KO Risolto” e causale “Saldo debito cattivo pagatore”.  
    //         La chiusura dell’activity scatenerà di nuovo il credit check per verificare problemi successivi. 
    //     */
    //     for(Id actId: mapActivityNew.keySet()){
    //         wrts_prcgvr__Activity__c actNew =  mapActivityNew.get(actId);
    //         wrts_prcgvr__Activity__c actOld =  mapActivityOld.get(actId);

    //         // esegue il creditcheck su una singola activity
    //         if(actOld.wrts_prcgvr__Status__c != actNew.wrts_prcgvr__Status__c && 'KO Forzato'.equalsIgnoreCase(actNew.wrts_prcgvr__Status__c)){ //il KO Forzato vale come chiusura? devo annullare anche l'order?                
    //             actListToRecheck.add(actNew);
    //             listOrderBadPayer.add(actOld.Order__c);
    //         }
    //     }

    //     recheckCreditCheck(actListToRecheck);


    //     // setto a true il campo badPayer per tutte le attività forzate ko
    //     List<Order> orderBadP = [SELECT Id, BadPayer__c FROM Order WHERE Id =:listOrderBadPayer];
    //     for(Order ord : orderBadP){
    //         ord.BadPayer__c = true;
    //     }
    //     update orderBadP;




        
    // }
    
    public static void cancelQualityNoResult(List<wrts_prcgvr__Activity__c> triggernew , List<wrts_prcgvr__Activity__c> triggerold){

        system.debug(LoggingLevel.DEBUG, '>>cancelQualityNoResult start');

        try {
            Set<id> activityIdSet = Trigger.newMap.keySet();
            List<Id> activityIdList = new List<Id>();
            activityIdList.addAll(activityIdSet);

            List<AgentMatrix__c> agentMatrixList = HDT_QR_AgentMatrix.getAgentMatrixIsMonitoringTrue();
            List<String> isMonitoringList = new List<String>();
            for (AgentMatrix__c agentMatrix : agentMatrixList) {
                isMonitoringList.add(agentMatrix.AgencyCode__c);
            }

            List<wrts_prcgvr__Activity__c> activities = HDT_QR_ActivityCustom.getRecordsForCancelQualityNoResult(activityIdList);

            HDT_QR_Recordtype recQr = new HDT_QR_Recordtype();
            String recordtypeid = recQr.getRecordTypeIdByName('HDT_RT_ComfortQualityCall', 'wrts_prcgvr__Activity__c');
            List<Order> ordersToUpdate = new List<Order>();
            for (wrts_prcgvr__Activity__c activity : activities) {
                if (activity.RecordTypeId == recordtypeid 
                    && activity.wrts_prcgvr__Status__c == 'Non Esitata'
                    && isMonitoringList.contains(activity.Order__r.AgencyCode__c)) {
                    ordersToUpdate.add(new Order(
                        Id = activity.Order__c,
                        Status = 'Annullato', //Chiuso
                        Phase__c = 'Annullato'
                    ));
                }
            }

            if (!ordersToUpdate.isEmpty()) {
                HDT_SRV_Order orderSrv = new HDT_SRV_Order();
                orderSrv.updateRecords(ordersToUpdate);
            }
        } catch (Exception e) {
            system.debug(LoggingLevel.DEBUG, 'HDT_TRH_ActivityCustom - afterUpdate - cancelQualityNoResult: ' + e.getMessage());
        }

        system.debug(LoggingLevel.DEBUG, '>>cancelQualityNoResult end');

    }

    public static void sendCloseNotification(List<wrts_prcgvr__Activity__c> newTriggerList , Map<Id,SObject> oldTriggerMap){
        List<wrts_prcgvr__Activity__c> activityToSendNotify = new List<wrts_prcgvr__Activity__c>();
        Set<Id> userIdSet = new Set<Id>();
        for (wrts_prcgvr__Activity__c activity : newTriggerList){
            wrts_prcgvr__Activity__c oldActivity = (wrts_prcgvr__Activity__c)oldTriggerMap.get(activity.Id);
            if ('Manuale'.equalsIgnoreCase(activity.DiscardCategory__c) && 'Chiusa'.equalsIgnoreCase(activity.wrts_prcgvr__Status__c) && !activity.wrts_prcgvr__Status__c.equalsIgnoreCase(oldActivity.wrts_prcgvr__Status__c)){
                activityToSendNotify.add(activity);
                userIdSet.add(activity.CreatedById);
            }
        }

        if (!activityToSendNotify.isEmpty()){
            List<User> userList = HDT_QR_UserQueries.getUsersStatus(userIdSet);
            Map<Id, User> idUserMap = new Map<Id, User>(userList);
            HDT_QR_Knowledge qrKb = new HDT_QR_Knowledge();
            CustomNotificationType notificationType = qrKb.getCustomNotificationType();
            for (wrts_prcgvr__Activity__c activity : activityToSendNotify){
                try{
                    if(idUserMap.get(activity.CreatedById).IsActive){
                        Messaging.CustomNotification notification = new Messaging.CustomNotification();
                        notification.setTitle('Chiusura Attività');
                        notification.setBody('L\'attività manuale ' + activity.Name + ' è stata chiusa');
                        notification.setNotificationTypeId(notificationType.Id);
                        notification.setTargetId(activity.Id);
                        notification.send(new Set<String>{activity.CreatedById});
                    }else {
                        continue;
                    }
                   
                } catch(Exception e){
                    System.debug(LoggingLevel.DEBUG, 'Impossibile inviare notifica: ' + e.getMessage() + '. Error at line: ' + e.getLineNumber());
                }
            }
        } 
    }

    public static void shareRecordAppointmentSelf(List<wrts_prcgvr__Activity__c> newTriggerList , Map<Id,SObject> oldTriggerMap){
        HDT_QR_Recordtype recQr = new HDT_QR_Recordtype();
        String recordtypeid = recQr.getRecordTypeIdByName('HDT_RT_DistributorAppointment', 'wrts_prcgvr__Activity__c');
        List<String> accountIdToShare = new List<String>();
        List<String> caseIdToShare = new List<String>();
        for (wrts_prcgvr__Activity__c newActivity : newTriggerList){
            wrts_prcgvr__Activity__c oldActivity = (wrts_prcgvr__Activity__c)oldTriggerMap.get(newActivity.Id);
            if (newActivity.RecordTypeId == recordtypeid && newActivity.isSelfAppointment__c && newActivity.isSelfAppointment__c != oldActivity.isSelfAppointment__c ){
                setSobjectId(newActivity, accountIdToShare, caseIdToShare);    
            }
        }

        setShareForAppointment(accountIdToShare, 'Account');
        setShareForAppointment(caseIdToShare, 'Case');
    }

    private static void setSobjectId(wrts_prcgvr__Activity__c activity,List<String> accountIdToShare,List<String> caseIdToShare){
        if (activity.Case__c != null && !caseIdToShare.contains('\'' + activity.Case__c + '\'')){
            caseIdToShare.add('\'' + activity.Case__c + '\'');
        }else if (activity.Order__c != null && !accountIdToShare.contains('\'' + activity.Account__c + '\'')){
            accountIdToShare.add('\'' + activity.Account__c + '\'');
        }
    }

    private static void setShareForAppointment(List<String> sbojectIdList,String objectName){
        if (!sbojectIdList.isEmpty()){
            String conditions = 'Id IN (' + String.join(sbojectIdList, ',')+') AND ShareForAppointment__c = false';
            List<SObject> objectsToWork = HDT_QR_GenericQuery.getGenericRecords('Id, ShareForAppointment__c', objectName, conditions);
            for (SObject obj : objectsToWork){
                obj.put('ShareForAppointment__c',true);
            }
            if (!objectsToWork.isEmpty()){
                HDT_UTL_DatabaseService.updateSObject(objectsToWork);
            }
        }

    }
}