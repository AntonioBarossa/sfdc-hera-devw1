@SuppressWarnings('PMD.CyclomaticComplexity, PMD.NcssMethodCount,PMD.AvoidDebugStatements')
public with sharing class HDT_BA_OrderQualityCallManagement implements Database.Batchable<sObject>, Database.Stateful{
    
    //il keySet sono tutti gli ordini che hanno activity assegnate e la relativa activity
    private Map<Id,wrts_prcgvr__Activity__c> actMap;
    private Set<Id> childsId;
    private Set<Id> parentsId;
    private List<String> isMonitoringList;
    private List<ComfortQualityCall__c> docValidList;
    private Map<String,Boolean> mapOrderToManage;
    private HDT_UTL_QualityCall qCall;



    public HDT_BA_OrderQualityCallManagement(Set<Id> childsId, Set<Id> parentsId, Map<Id,wrts_prcgvr__Activity__c> actToParentOrderMap){
        this.childsId = childsId;
        this.parentsId = parentsId;
        this.actMap = actToParentOrderMap;
        this.isMonitoringList = HDT_UTL_AgentMatrix.agentCodeIsMonitoringList();
        this.docValidList = HDT_QR_ComfortQualityCall.getRecordsWithDocumentValidationAndQualityEnabled();
        this.mapOrderToManage = new Map<String,Boolean>();
        this.qCall = new HDT_UTL_QualityCall();
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        //Da verificare
        if (this.parentsId.isEmpty()){
            return Database.getQueryLocator([
                SELECT Id,Status,Skip_Callout__c, OrderNumber, IsVAS__c, Phase__c, PhaseStory__c, Channel__c, CustomerCategory__c, SignatureMethod__c, RecordType.DeveloperName, WizardCompletedDate__c, ParentOrder__c, QualityCall__c, QualityCallUnique__c, Contact__c, PhoneNumber__c, AccountId, CommercialId__c, ActivatedDate, LoginChannel__c, VASType__c, Account.CompanyOwner__c, isTransition__c, QualityCallStatus__c, HerokuPracticeCode__c, ProcessType__c
                FROM ORDER 
                WHERE Id IN: this.childsId AND Phase__c NOT IN ('In attesa conferma cliente') AND QualityCall__c = true AND VasSubtype__c != 'Analisi Consumi' AND ComfortCallDaysDue__c = null AND QualityCallStatus__c != :HDT_UTL_QualityCall.HANDLE_DEADLINE
            ]);
        }
        if (this.childsId.isEmpty()){
            return Database.getQueryLocator([
                SELECT Id,Status,Skip_Callout__c, OrderNumber, IsVAS__c, Phase__c, PhaseStory__c, Channel__c, CustomerCategory__c, SignatureMethod__c, RecordType.DeveloperName, WizardCompletedDate__c, ParentOrder__c, QualityCall__c, QualityCallUnique__c, Contact__c, PhoneNumber__c, AccountId, CommercialId__c, ActivatedDate, LoginChannel__c, VASType__c, Account.CompanyOwner__c, isTransition__c, QualityCallStatus__c, HerokuPracticeCode__c, ProcessType__c
                FROM ORDER 
                WHERE ParentOrder__c IN :this.parentsId AND Phase__c NOT IN ('In attesa conferma cliente') AND QualityCall__c = true AND VasSubtype__c != 'Analisi Consumi' AND ComfortCallDaysDue__c = null AND QualityCallStatus__c != :HDT_UTL_QualityCall.HANDLE_DEADLINE
            ]);
        }
        return Database.getQueryLocator([
            SELECT Id,Status,Skip_Callout__c, OrderNumber, IsVAS__c, Phase__c, PhaseStory__c, Channel__c, CustomerCategory__c, SignatureMethod__c, RecordType.DeveloperName, WizardCompletedDate__c, ParentOrder__c, QualityCall__c, QualityCallUnique__c, Contact__c, PhoneNumber__c, AccountId, CommercialId__c, ActivatedDate, LoginChannel__c, VASType__c, Account.CompanyOwner__c, isTransition__c, QualityCallStatus__c, HerokuPracticeCode__c, ProcessType__c
            FROM ORDER 
            WHERE (Id IN: this.childsId OR ParentOrder__c IN :this.parentsId) AND Phase__c NOT IN ('In attesa conferma cliente') AND QualityCall__c = true AND VasSubtype__c != 'Analisi Consumi' AND ComfortCallDaysDue__c = null AND QualityCallStatus__c != :HDT_UTL_QualityCall.HANDLE_DEADLINE
        ]);    
    }

    public void execute(Database.BatchableContext bc, List<Order> orders){
        HDT_SRV_LogService logs = new HDT_SRV_LogService('HDT_BA_QualityCall');
        try{
            Id rtId = (new  HDT_QR_RecordType()).getRecordType('HDT_RT_AttivitaGestionali', 'wrts_prcgvr__Activity__c').Id;
            List<Order> ordersToUpdate = new List<Order>();
            Map<Id,wrts_prcgvr__Activity__c> activitiesToInsert = new Map<Id,wrts_prcgvr__Activity__c>();
            Set<String> orderToCancel = new Set<String>();
            Set<Id> orderWithActivity = new Set<Id>();
            Set<String> pOrdersId = new Set<String>();
            List<String> allOrdersId = new List<String>();
            for (Order o : orders){
                pOrdersId.add(o.ParentOrder__c); 
                allOrdersId.add(o.Id);
            }

            Map<String, List<OrderItem>> orderToItemMap = new Map<String, List<OrderItem>>();
            for(OrderItem item : HDT_QR_OrderItem.getItemFromOrderIdList(allOrdersId)){
                if(!orderToItemMap.containsKey(item.OrderId)){
                    orderToItemMap.put(item.OrderId, new List<OrderItem>());
                }
                orderToItemMap.get(item.OrderId).add(item);
            }

            allOrdersId.addAll(pOrdersId);
            for (wrts_prcgvr__Activity__c act : HDT_QR_ActivityCustom.getContractActivityQualityBatch(allOrdersId)){
                orderWithActivity.add(act.Order__c); //Verifico quali ordini hanno già l'activity Contratto da gestire in SFDC/Siebel o QC scaduta
            }
            this.getChildOrderInfo(pOrdersId,orderWithActivity); // creare le informazioni, per vedere se un ordine è da gestire (solo relativamente agli stati) e con quale data.
            List<wrts_prcgvr__Activity__c> actToUpdate = new List<wrts_prcgvr__Activity__c>();
            for (Order o : orders){
                if (this.mapOrderToManage.containsKey(o.ParentOrder__c) && !this.mapOrderToManage.get(o.ParentOrder__c)){
                    this.actMap.remove(o.ParentOrder__c);
                    continue;
                }
                Integer newSkipCall = o.Skip_Callout__c == null ? -1 : null; 
                Order ordToUpd = new Order(Id = o.Id, QualityCallStatus__c = HDT_UTL_QualityCall.HANDLE_DEADLINE, Skip_Callout__c = newSkipCall);
                
                Boolean hasCancellableProduct = false;
                if(orderToItemMap.get(o.Id) != null){
                    for(OrderItem item : orderToItemMap.get(o.Id)){
                        if(item.Product2.CancelableQC__c){
                            hasCancellableProduct= true;
                            break;
                        }
                    }
                }
                if (this.actMap.containsKey(o.ParentOrder__c)){
                    actToUpdate.add(this.actMap.remove(o.ParentOrder__c));
                }
                String result = qCall.checkOrderPhase(o.Phase__c);
                if ('CLOSE_PHASE'.equalsIgnoreCase(result)){
                    if (!'Activated'.equalsIgnoreCase(o.Status)){
                        ordersToUpdate.add(ordToUpd);
                    }
                    continue;
                }
                Boolean canDeleteOrder = !qCall.notCancellableOrder(o);
                Boolean needsActivity = false;
                
                if ('CANCEL'.equalsIgnoreCase(result) && canDeleteOrder 
                    && (isMonitoringList.contains(o.CommercialId__c) || hasCancellableProduct || 'In attesa di quality call'.equalsIgnoreCase(o.Phase__c))) {
                        ordToUpd.Phase__c = 'Annullato';
                        ordToUpd.Status = 'Annullato';         
                        orderToCancel.add(ordToUpd.Id);
                        ordersToUpdate.add(ordToUpd);
                        continue;     
                }else if (isMonitoringList.contains(o.CommercialId__c) || hasCancellableProduct){
                    needsActivity = true;
                }
                if (!'Activated'.equalsIgnoreCase(o.Status)){
                    ordersToUpdate.add(ordToUpd);
                }
                if (orderWithActivity.contains(o.Id) || orderWithActivity.contains(o.ParentOrder__c)){
                    continue;
                }
                
                if (needsActivity && ((!canDeleteOrder || (o.VASType__c != 'VAS Fatturabili' && ('NO_CANCEL_NO_BILL'.equals(result) || 'NO_CANCEL'.equals(result))) || ((o.VASType__c == 'VAS Fatturabili' || !o.IsVAS__c) && ('NO_CANCEL'.equals(result) || 'NO_CANCEL_BILL'.equals(result)))))) {
                    Id orderId = o.QualityCallUnique__c ? o.ParentOrder__c : o.Id;
                    activitiesToInsert.put(orderId, new wrts_prcgvr__Activity__c(
                        RecordTypeId = rtId,
                        Account__c = o.AccountId,
                        Order__c = orderId,
                        Type__c = 'Quality Scaduta',
                        wrts_prcgvr__Status__c = 'Aperta',
                        wrts_prcgvr__Description__c = 'Non è stato possibile procedere all\'annullamento allo scadere dei 50 giorni di quality call, verificare la richiesta e procedere tramite ripensamento o tramite il case di post sales Disattivazione VAS',
                        OpeningNote__c = 'Errore invio a DL/SII'.equalsIgnoreCase(o.Phase__c)? 'Attività creata perchè l\'ordine era in fase Errore invio a DL/SII' : ''
                    ));
                }
            }
            this.closeActivities(actToUpdate);
            if (!orderToCancel.isEmpty()){
                HDT_QR_Order qrOrder = new HDT_QR_Order();
                for (wrts_prcgvr__Activity__c activity: qrOrder.getOpenActivitiesByListOrderId(orderToCancel)){
                    if (!'Eseguire Gestione Manuale SAP'.equalsIgnoreCase(activity.Type__c)&& !'Quality Scaduta'.equalsIgnoreCase(activity.Type__c) && !'Quality Call'.equalsIgnoreCase(activity.Type__c)){
                        actToUpdate.add(
                            new wrts_prcgvr__Activity__c(
                                Id = activity.Id,
                                wrts_prcgvr__Status__c = 'Annullata'
                            )
                        );
                    }
                }
            }

            if (!actToUpdate.isEmpty()){
                List<Database.SaveResult> srList = Database.update(actToUpdate, false);
                qCall.setLogRecord(srList, actToUpdate, logs, 'update activities second batch');
            }

            if (!ordersToUpdate.isEmpty()){
                List<Database.SaveResult> srList = Database.update(ordersToUpdate, false);
                qCall.setLogRecord(srList, ordersToUpdate, logs, 'update order second batch');
            }

            if (!activitiesToInsert.isEmpty()){
                List<Database.SaveResult> srList = Database.insert(activitiesToInsert.values(), false);
                qCall.setLogRecord(srList, activitiesToInsert.values(), logs, 'insert activities second batch');
            }

        }catch (Exception ex){
            logs.addLog('HDT_BA_OrderQualityCallManagement', 'execute', orders != null ? JSON.serialize(orders) : null , null, ex.getStackTraceString() + ' Error Message: ' + ex.getMessage(), null, null, null);
        }
        logs.saveMassiveRecords();
    }

    private void closeActivities(List<wrts_prcgvr__Activity__c> activities){
        for (wrts_prcgvr__Activity__c act : activities){
            act.wrts_prcgvr__Status__c = 'Chiusa';
            act.ContactResult__c='Chiusa Per Fine Intervallo';
        }
    }


    private void getChildOrderInfo(Set<String> pOrdersId, Set<Id> orderWithActivity){
        Date dueDate = Date.today();
        Map<Id,Date> mapStartDate = new Map<Id,Date>();
        Map<Id,Integer> mapDaysToWork = new Map<Id,Integer>();
        /* Set<String> notValidPhase = new Set<String>{
            'in attesa validazione',
            'accettazione voltura',
            'da inviare',
            'bozza',
            'in attesa conferma cliente',
            'credit check ko',
            'attesa credit check'
        }; */
        //La query è necessaria perchè potrebbe crearsi la situazione in cui i figli di un ordine sono separati da un esecuzione di un batch ed un altro.
        //Infatti elimino quelli già creati nelle precedenti esecuzioni
        pOrdersId.removeAll(this.mapOrderToManage.keySet());
        if (pOrdersId.isEmpty()){
            return;
        }
        for (Order o : HDT_QR_Order.getChildOrdersFromParentId(pOrdersId)){
            if (this.mapOrderToManage.containsKey(o.ParentOrder__c) && !this.mapOrderToManage.get(o.ParentOrder__c) 
            ||(!this.childsId.contains(o.Id) && !this.parentsId.contains(o.ParentOrder__c))){
                continue;
            }
            if ((orderWithActivity.contains(o.Id) && this.childsId.contains(o.Id)) || orderWithActivity.contains(o.ParentOrder__c) || HDT_UTL_QualityCall.HANDLE_DEADLINE.equalsIgnoreCase(o.QualityCallStatus__c)){
                this.mapOrderToManage.put(o.ParentOrder__c,true);
                continue;
            }
            //a meno che non è stato già gestito, se l'order è in una fase non consentita non gestire l'activity
            if (!HDT_UTL_QualityCall.HANDLE_DEADLINE.equalsIgnoreCase(o.QualityCallStatus__c) && (String.isBlank(o.Phase__c) || 'in attesa conferma cliente'.equalsIgnoreCase(o.Phase__c.toLowerCase()))){
                this.mapOrderToManage.put(o.ParentOrder__c,false);
                mapStartDate.remove(o.ParentOrder__c);
                continue;
            }
            Date startDate = this.actMap.get(o.ParentOrder__c).QualityCallStartDate__c;
            if (startDate == null){
                for (ComfortQualityCall__c cqc : docValidList) {
                    if (
                        String.isNotBlank(o.PhaseStory__c) && o.PhaseStory__c.containsIgnoreCase('Documentazione Validata') && cqc.Process__c == o.RecordType.DeveloperName && cqc.Channel__c == o.Channel__c && cqc.CustomerType__c == o.CustomerCategory__c && cqc.QualitySignatureMethod__c == o.SignatureMethod__c
                    ) {
                        startDate = HDT_UTL_Utils.exctrPhaseTransDateFromStory(o.PhaseStory__c, 'Documentazione Validata');
                        break;
                    }
                }
                if (startDate == null){
                    startDate = o.WizardCompletedDate__c;
                }
            }
            if (!mapStartDate.containsKey(o.ParentOrder__c) || mapStartDate.get(o.ParentOrder__c) < startDate){
                mapDaysToWork.put(o.ParentOrder__c,HDT_UTL_QualityCall.getDeadlineDays(this.actMap.get(o.ParentOrder__c)?.CreatedDate.date()));
                mapStartDate.put(o.ParentOrder__c,startDate);
            }
            this.mapOrderToManage.put(o.ParentOrder__c,true);
        }
        for (Id parentId : mapStartDate.keySet()){
            if (mapStartDate.get(parentId).daysBetween(dueDate) <= mapDaysToWork.get(parentId)){
                this.mapOrderToManage.put(parentId,false);
            }
        }
    }

    public void finish(Database.BatchableContext bc){
        HDT_SRV_LogService logs = new HDT_SRV_LogService('HDT_UTL_QualityCall');
        try{
            if (!this.actMap.isEmpty()){
                this.closeActivities(this.actMap.values());
                List<Database.SaveResult> srList = Database.update(this.actMap.values(), false);
                qCall.setLogRecord(srList, this.actMap.values(), logs, 'update activities');
            }
        }catch(exception ex){
            logs.addLog('HDT_BA_QualityCall', 'OrderQualityCallManagementfinish', JSON.serialize(this.actMap),null, ex.getStackTraceString() + ' Error Message: ' + ex.getMessage(), null, null, null);
        }
        logs.saveMassiveRecords();
        System.debug(LoggingLevel.DEBUG,'HDT_BA_OrderQualityCallManagement - finish');
    }
}