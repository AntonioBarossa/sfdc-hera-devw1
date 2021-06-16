public without sharing class HDT_UTL_ActivityCustomProcess {

    private static HDT_QR_Order orderQr = new HDT_QR_Order();

    public static void changeAssignRelatedRecord(List<wrts_prcgvr__Activity__c> triggernew , List<wrts_prcgvr__Activity__c> triggerold){
        HDT_QR_Recordtype recQR = new HDT_QR_Recordtype();
        String recordtypeid = recQR.getRecordTypeIdByName('HDT_RT_VisitaD2D');
        HDT_QR_Contact contactQr = new HDT_QR_Contact();
        HDT_SRV_Account accountSrv = new HDT_SRV_Account();
        Map<id,String> mapIdOwnerIdBef = new Map<Id,String>();
        Map<id,String> mapIdOwnerIdAfter = new Map<Id,String>();
        Map<id,String> mapContactIdOwner = new Map<Id,String>();
        String userId = userinfo.getuserid();
        List<Lead> listLead = new List<Lead>();
        List<String> listContactId = new List<String>();
        List<Account> listAccount = new List<Account>();
		System.debug('DENTRO HANDLER HANDLER: ' + triggernew);
        List<wrts_prcgvr__Activity__c> listActD2DBef = filterByD2D(triggerold,recordtypeid);
        for(wrts_prcgvr__Activity__c art : listActD2DBef){
            System.debug('DENTRO HANDLER HANDLER2:' + art);
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
        List<Contact> contactList = contactQr.getRecordsById(listContactId);
        List<AccountShare> lAccSh = new List<AccountShare>();
        for(Contact c : contactList){
            if(mapContactIdOwner.get(c.id)!= null && c.AccountId != null){
                System.debug('************:'+c.AccountId);
                lAccSh.add(HDT_UTL_RecordShare.accountShareEditCreate(c.AccountId,mapContactIdOwner.get(c.id)));
                listAccount.add(new Account(id=c.AccountId,ownerId=mapContactIdOwner.get(c.id)));
            }
        }
        /*if(lAccSh != null && !lAccSh.isEmpty()){
            System.debug('PROVAPROVA:' + lAccSh);
            HDT_SRV_RecordShare.createRecordWithout(lAccSh);
        }*/
        if(listLead != null && !listLead.isEmpty()){
            HDT_SRV_Lead.updateRecord(listLead);
        }
        if(listAccount != null && !listAccount.isEmpty()){
            accountSrv.updateRecordsNoShare(listAccount);
        }
    }

    private static List<wrts_prcgvr__Activity__c> filterByD2d(List<wrts_prcgvr__Activity__c> li,String recordtypeid){
        List<wrts_prcgvr__Activity__c> rep = new List<wrts_prcgvr__Activity__c>();
        System.debug('DENTRO HANDLER HANDLER4:');
        for(wrts_prcgvr__Activity__c act : li){
            if(recordtypeid.equalsIgnoreCase(act.recordtypeid)){
                System.debug('DENTRO HANDLER HANDLER5:');
                rep.add(act);
            }
        }
        return rep;
    }

    // @Picchiri 08.06.21 Credit Check Annullamento Ordine
    // Alla ricezione di un esito KO, verrà creata su Salesforce un Activities
    public static void createActivityForCreditCheck(Map<String,List<Order>> orderMap){        

        system.debug('HDT_UTL_ActivityProcess createActivity --> orderMap : ' + JSON.serializePretty(orderMap));
        
        List<wrts_prcgvr__Activity__c> listActivity = new List<wrts_prcgvr__Activity__c>();
        Id rtOldCustomer = [SELECT Id FROM RecordType WHERE DeveloperName = 'HDT_RT_KoPrecedeteCliente' limit 1].id;
        Id rtNewCustomer = [SELECT Id FROM RecordType WHERE DeveloperName = 'HDT_RT_CreditCheckKO' limit 1].id;

        for(String typeCustomer : orderMap.keyset()){
            for(Order order : orderMap.get(typeCustomer)){
                wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();

                if(typeCustomer == 'oldCustomer'){ // Precedente cliente // uscente // vecchio cliente
                    activity.RecordTypeId = rtOldCustomer;                     
                    activity.CreditCheckResults__c = order.OutgoingCreditCheckResult__c;
                    activity.Account__c = order.ServicePoint__r.Account__c; 
                }
                        
                if(typeCustomer == 'newCustomer'){ // Nuovo cliente // entrante
                    activity.RecordTypeId = rtNewCustomer;                     
                    activity.CreditCheckResults__c = order.IncomingCreditCheckResult__c;
                    activity.Account__c = order.AccountId; 
                }
        
                activity.CreditCheckReason__c = order.CreditCheckDescription__c;
                activity.Order__c = order.Id;                
                activity.Contact__c = order.Contact__c;                                
                activity.Status__c = 'Creata';                
                activity.Note__c = order.CommentForDL__c;
                activity.OwnerId = order.OwnerId;

                listActivity.add(activity);
            }

        }

        insert listActivity;
    
    }

    // @Picchiri 08.06.21 Credit Check 
    // Annullamento Activity di Credit Check e annullamento Ordine in caso di KO Definitvo dell'activity
    public static void annullamentoActivityCustom(List<wrts_prcgvr__Activity__c> newActList, List<wrts_prcgvr__Activity__c> oldActList){
                
        Set<Id> orderIdToAnnullamento = new Set<Id>();        
        for(wrts_prcgvr__Activity__c act : newActList){
            if(act.Status__c == 'KO Definitivo'){
                orderIdToAnnullamento.add(act.Order__c);                
            }
        }

        System.debug('orderIdToAnnullamento ----> ' + orderIdToAnnullamento);        
        List<Order> orderToAnnullamento = [SELECT id,Status FROM Order WHERE id IN :orderIdToAnnullamento];
        for(Order order : orderToAnnullamento){        
            order.Status = 'Annullato';                
        }
        update orderToAnnullamento;
    }


    // @Picchiri 15.06.21 Credit Check Gestione Esiti ed eventuali invocazione a chiamata Mulesoft
    public static wrts_prcgvr__Activity__c closeActivityCheck(wrts_prcgvr__Activity__c act){
        act.Status__c = 'Chiusa'; 
        return act;       
    }

    // @Picchiri 14.06.21 Credit Check Gestione Esiti ed eventuali invocazione a chiamata Mulesoft
    public static void creditCheckEsitiManager(List<wrts_prcgvr__Activity__c> newActList, List<wrts_prcgvr__Activity__c> oldActList){
        
        Boolean recheck = false; // Se true eseguire la chiamata

        List<String> causaleCattivoPagatore = new List<String>{'Cattivo Pagatore', 'Andamentale KO, Cattivo Pagatore', 'Black List, Cattivo Pagatore', 'Black List, Andamentale KO, Cattivo Pagatore' };
        List<wrts_prcgvr__Activity__c> actListToUpdate = new List<wrts_prcgvr__Activity__c>();
        List<wrts_prcgvr__Activity__c> actListToRecheck = new List<wrts_prcgvr__Activity__c>();
        List<Id> orderIdListToCleanCreditCheck = new List<Id>();
        Set<Id> listOrderBadPayer = new Set<Id>();
        
        for(Integer i = 0; i < newActList.size(); i++){

                wrts_prcgvr__Activity__c act = newActList[i];
                wrts_prcgvr__Activity__c actOld = oldActList[i];
                // Gestione KO - Punto 1
                // Se il nuovo cliente dimostrerà che l’importo dovuto non è legalmente attribuibile a lui (dimostrazione di estraneità al debito), 
                // L’activity verrà chiusa con Stato Lavorazione “KO Risolto” e Motivo “Dimostrata Estraneità”. 
                // La chiusura dell’activity scatenerà di nuovo il credit check ma sul Nuovo Cliente 
                // Gestione KO - Punto 2
                // Se il nuovo cliente dimostrerà comunque di aver pagato il debito del precedente cliente), 
                // L’activity verrà chiusa con Stato Lavorazione “KO Risolto” e Motivo “Saldo Pagato”.  
                // La chiusura dell’activity scatenerà di nuovo il credit check ma sul Nuovo Cliente. 
                if( act.RecordType.DeveloperName == 'HDT_RT_CreditCheckKO' &&  (act.Status__c == 'KO Risolto' && act.Reason__c == 'Dimostrata Estraneità' ) || (act.Status__c == 'KO Forzato' && act.Reason__c == 'Saldo pagato' )){                    
                    actListToRecheck.add(act);
                }

                // punto 2 KO Cattivo Pagatore  ancora in analisi
                if(act.Status__c == 'KO Forzato' && causaleCattivoPagatore.contains(act.CreditCheckReason__c)){
                    actListToRecheck.add(act);
                    listOrderBadPayer.add(act.Order__c);
                } 
                // ko uscente e poi ok . chiudere l'activity e rimandare il credict check
                if(act.RecordType.DeveloperName == 'HDT_RT_KoPrecedeteCliente' && actOld.CreditCheckResults__c == 'KO' && act.CreditCheckResults__c == 'OK'){
                    actListToUpdate.add(closeActivityCheck(act));
                    actListToRecheck.add(act);
                }

                //ko entrante poi ok con causale "Saldo debito cattivo pagatore" verficare l'activity e riportare esito e causale su activity e sbiancare l'esito su order e reinviare la chiamata
                if(act.RecordType.DeveloperName == 'HDT_RT_CreditCheckKO' && actOld.CreditCheckResults__c == 'KO' && act.CreditCheckResults__c == 'OK' && act.CreditCheckReason__c == 'Saldo debito cattivo pagatore'){                    
                    actListToUpdate.add(closeActivityCheck(act));
                    actListToRecheck.add(act);
                    orderIdListToCleanCreditCheck.add(act.Order__c);
                    
                }
                // in altri casi in cui arriva un ok chiudere l'activity ma non mandare la chiamata a sap
                if(act.RecordType.DeveloperName != 'HDT_RT_KoPrecedeteCliente' && actOld.CreditCheckResults__c == 'KO' && act.CreditCheckResults__c == 'OK' && act.CreditCheckReason__c != 'Saldo debito cattivo pagatore'){
                    actListToUpdate.add(closeActivityCheck(act));                     
                    recheck = false;
                }                
            
        }

        if(!orderIdListToCleanCreditCheck.isEmpty()){
            HDT_UTL_OrderProcess.cleanCreditCheckOnOrder(orderIdListToCleanCreditCheck);
        }
        if(!actListToUpdate.isEmpty()){
            update actListToUpdate;
        }
        if(!actListToRecheck.isEmpty()){
            recheckCreditCheck(actListToRecheck);
        }
        if(!listOrderBadPayer.isEmpty()){
            List<Order> orderBadP = [SELECT Id, BadPayer__c FROM Order WHERE Id =:listOrderBadPayer];
            for(Order ord : orderBadP){
                ord.BadPayer__c = true;
            }
            update orderBadP;           
        }

        
                
    }
    // END @Picchiri 14.06.21 Credit Check Richiamata a Mulesoft

    // @Picchiri 15.06.21 chiamata Mulesoft
    public static void recheckCreditCheck(List<wrts_prcgvr__Activity__c> actListToRecheck){

        for(wrts_prcgvr__Activity__c act : actListToRecheck){  
        
            String typeOfCommodity = act.Order__r.ServicePoint__r.CommoditySector__c;
            String fiscalData = null;
            Boolean precedenteCliente = null;
                
            if(act.Order__r.RecordType.DeveloperName == 'HDT_RT_Subentro' || act.Order__r.RecordType.DeveloperName == 'HDT_RT_Voltura'){
            
                if(act.Order__r.Account.RecordType.DeveloperName == 'HDT_RT_Residenziale'){
                    fiscalData = act.Order__r.ServicePoint__r.Account__r.FiscalCode__c;
                }else if(act.Order__r.ServicePoint__r.Account__r.VATNumber__c != null){
                    fiscalData = act.Order__r.ServicePoint__r.Account__r.VATNumber__c;
                }
                precedenteCliente = true;                
            }
                
            if(typeOfCommodity == 'Energia Elettrica'){
                typeOfCommodity = 'ENERGIAELETTRICA';
            }
            if(typeOfCommodity == 'Gas'){
                typeOfCommodity = 'GAS';
            }
            
            HDT_WS_CreditCheck.HDT_VFC_InputWrapperDetail iwd = new HDT_WS_CreditCheck.HDT_VFC_InputWrapperDetail();
            iwd.annualConsumption = String.valueOf(act.Order__r.ServicePoint__r.AnnualConsumptionStandardM3__c.format());
            iwd.commodity = typeOfCommodity;
            

            List<HDT_WS_CreditCheck.HDT_VFC_InputWrapperDetail> l = new List<HDT_WS_CreditCheck.HDT_VFC_InputWrapperDetail>();
            l.add(iwd);

            HDT_WS_CreditCheck.HDT_VFC_InputWrapper iw = new HDT_WS_CreditCheck.HDT_VFC_InputWrapper();
            iw.sistema = 'eEnergy';
            iw.caso = 'Transazionale';
            iw.crmEntity = 'Order';
            iw.crmId = act.Order__r.OrderNumber;
            iw.userId = act.Order__r.CreatedById;
            iw.activationUser = 'AccountCommercialePRM';
            iw.account = 'AccountCommercialePRM';
            iw.jobTitle = act.Order__r.Channel__c;
            iw.internalCustomerId = act.Order__r.Account.CustomerCode__c;
            iw.companyName = act.Order__r.SalesCompany__c;
            iw.externalCustomerId = act.Order__r.Account.FiscalCode__c;
            iw.secondaryCustomerId = act.Order__r.Account.VATNumber__c;
            iw.bpClass =  act.Order__r.Account.CustomerMarking__c;
            iw.bpCategory = act.Order__r.Account.Category__c; 
            iw.bpType = act.Order__r.Account.CustomerType__c;
            iw.customerType = 'CT0';
            iw.address = act.Order__r.ServicePoint__r.SupplyStreetName__c;
            iw.municipality = act.Order__r.ServicePoint__r.SupplyCity__c;
            iw.district = act.Order__r.ServicePoint__r.SupplyProvince__c;
            iw.postCode = act.Order__r.ServicePoint__r.SupplyPostalCode__c;
            iw.operation =  act.Order__r.ProcessType__c;
            iw.companyGroup = 'Hera S.p.A.';
            iw.market = act.Order__r.Market__c;
            iw.offerType = act.Order__r.Catalog__c;
            iw.details = l;
            if(precedenteCliente == true){
                iw.bpAlternative = act.Order__r.ServicePoint__r.Account__r.CustomerCode__c;
                iw.alternativeCustomerId = fiscalData;            
            }
            
            HDT_WS_CreditCheck.callService(json.serialize(iw));
        }
    }
    // END @Picchiri 15.06.21 

    // @Alessio Murru 
    // public static void manageStatusChangeCrediCheck(List<wrts_prcgvr__Activity__c> triggernew , List<wrts_prcgvr__Activity__c> triggerold){
    //     HDT_QR_Recordtype recQR = new HDT_QR_Recordtype();
    //     String recordtypeid = recQR.getRecordTypeIdByName('HDT_RT_CreditCheckKO');
    //     Map<id,wrts_prcgvr__Activity__c> mapActivityNew = new Map<Id,wrts_prcgvr__Activity__c>();
    //     Map<id,wrts_prcgvr__Activity__c> mapActivityOld = new Map<Id,wrts_prcgvr__Activity__c>();
    //     List<wrts_prcgvr__Activity__c> actListToRecheck = new List<wrts_prcgvr__Activity__c>();

	// 	System.debug('manageStatusChangeCrediCheck: Creating map of HDT_RT_CreditCheckKO recordtype');
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
    //         if(actOld.Status__c != actNew.Status__c && 'KO Forzato'.equalsIgnoreCase(actNew.Status__c)){ //il KO Forzato vale come chiusura? devo annullare anche l'order?                
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

}