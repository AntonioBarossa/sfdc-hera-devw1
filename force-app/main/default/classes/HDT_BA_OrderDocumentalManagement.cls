public with sharing class HDT_BA_OrderDocumentalManagement implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts {
    public Set<String> orderScartatiSet = new Set<String>();
    public Integer counterKo = 0;
    public Integer counterOk = 0;
    Boolean calloutSyncOrder = false;
    Boolean calloutSyncCase = false;
    Datetime start = null;
    private static HDT_SRV_BatchExecutionKpi srvBatchEx = new HDT_SRV_BatchExecutionKpi();
    BatchExecutionKpiConfiguration__mdt kpiMeta = BatchExecutionKpiConfiguration__mdt.getInstance('HDT_BA_OrderDocumentalManagement');
    BatchExecutionKpi__c kpiTrack=new BatchExecutionKpi__c();
    public String caseQuery;
    public String orderQuery;

    public void handleBuildQuery(){
        EnvelopeReminderConfiguration__c cs = EnvelopeReminderConfiguration__c.getInstance();
        Boolean enableCaseQuery = cs.EnableCaseQuery__c;
        Boolean enableOrderQuery = cs.EnableOrderQuery__c;
        calloutSyncOrder = cs.CalloutSyncOrder__c;
        calloutSyncCase = cs.CalloutSyncCase__c;
        String caseCommodity = cs.CaseCommodity__c;
        String orderCommodity = cs.OrderCommodity__c;
        Integer caseLastNdays = Integer.valueOf(cs.CaseLastnDay__c);
        Integer orderLastNdays = Integer.valueOf(cs.OrderLastnDay__c);
        String casePhase = cs.CasePhase__c;
        String orderPhase = cs.OrderPhase__c;
        String caseType = cs.CaseType__c;
        String orderType = cs.OrderType__c;
        
        if(enableCaseQuery){
            caseQuery = 'SELECT Id,DeliveryAddress__c,SignMode__c FROM Case WHERE ';
            String[] caseConditions = new List<String>();
            if(String.isNotBlank(caseCommodity)){
                caseConditions.add('Commodity__c IN ('+caseCommodity+')'); 
            }
            if(String.isNotBlank(casePhase)){
                caseConditions.add('Phase__c IN ('+casePhase+')');
            }
            if(String.isNotBlank(caseType)){
                caseConditions.add('Type IN ('+caseType+')');
            }
            if(caseLastNdays > 0){
                DateTime caseLimitDate = (DateTime.now()).addDays(- caseLastNdays);
                caseConditions.add('CreatedDate < LAST_N_DAYS:' + String.valueOf(caseLastNdays));
            }
            String caseConditionQuery = String.join(caseConditions, ' AND ');
            caseQuery = caseQuery + caseConditionQuery + ' AND DocumentalPhase__c != \'Plico sollecitato\'';
            System.debug('Case Query ' + caseQuery);
        }
        if(enableOrderQuery){
            orderQuery = 'SELECT Id,ParentOrder__c FROM Order WHERE ';
            String[] orderConditions = new List<String>();
            if(String.isNotBlank(orderCommodity)){
                orderConditions.add('CommodityFormula__c IN ('+orderCommodity+')'); 
            }
            if(String.isNotBlank(orderPhase)){
                orderConditions.add('Phase__c IN ('+orderPhase+')');
            }
            if(String.isNotBlank(orderType)){
                orderConditions.add('ProcessType__c IN ('+orderType+')');
            }
            if(orderLastNdays > 0){
                DateTime orderLimitDate = (DateTime.now()).addDays(- orderLastNdays);
                orderConditions.add('CreatedDate < LAST_N_DAYS:' + String.valueOf(orderLastNdays));
            }
            String orderConditionQuery = String.join(orderConditions, ' AND ');
            orderQuery = orderQuery + orderConditionQuery + ' AND ParentOrder__c != null AND ParentOrder__r.DocumentalPhase__c != \'Plico sollecitato\'';
            System.debug('Order Query ' + orderQuery);
        }
    }

    public List<SObject> start(Database.BatchableContext bc) {
        if(kpiMeta!=null && kpiMeta.EnableTracking__c){
            kpiTrack = srvBatchEx.createRecord(Datetime.now(),'HDT_BA_OrderDocumentalManagement');
        }
        handleBuildQuery();
        List<Order> orderParentList = new List<Order>();
        List<Case> caseList = new List<Case>();
        if(String.isNotBlank(caseQuery)){
            caseList = Database.query(caseQuery);
        }
        if(String.isNotBlank(orderQuery)){
            List<Order> orderList = Database.query(orderQuery);
            Set<Id> orderIdSet = new Set<Id>();
            for(Order ord: orderList){
                orderIdSet.add(ord.ParentOrder__c);
            }
            String queryParentOrder = 'SELECT Id,DocSendingMethod__c,SignatureMethod__c,ShippingAddressFormula__c FROM Order WHERE Id IN:orderIdSet';
            orderParentList = Database.query(queryParentOrder);
        }
        List<SObject> sObjectList = new List<SObject>();
        if(!orderParentList.isEmpty()){
            sObjectList.addAll(orderParentList);
        }
        if(!caseList.isEmpty()){
            sObjectList.addAll(caseList);
        }
        return sObjectList;
    }
    public void execute(Database.BatchableContext bc, List<sObject> scope){
       SObject singleRecord = scope[0];
       Id recordId = (Id)singleRecord.get('Id');
       String objectType = String.valueOf(recordId.getSObjectType());
       String signMode = '';
       if(objectType.equalsIgnoreCase('Order')){
            if(String.isBlank((String)singleRecord.get('ShippingAddressFormula__c'))){
                counterKo++;
                return;
            }
       }else {
            if(String.isBlank((String)singleRecord.get('DeliveryAddress__c'))){
                counterKo++;
                return;
            }
       }
        Map<String,String> params = new Map<String,String>();
        params.put('signMode', '');
        params.put('sendMode', 'Posta Cartacea');
        params.put('Contesto', objectType);
        params.put('mode', 'Print');
        params.put('Archiviato', 'Y');
        params.put('TipoPlico', 'Sollecito');
        if((objectType.equalsIgnoreCase('Order') && calloutSyncOrder) || (objectType.equalsIgnoreCase('Case') && calloutSyncCase)){
            HDT_SRV_DocumentalManagementFacade.sendDocumentSync(recordId, objectType,JSON.serialize(params));
        }else {
            HDT_SRV_DocumentalManagementFacade.sendDocumentAsync(recordId, 'Order',JSON.serialize(params));
        }        
        counterOk++;
}
    public void finish(Database.BatchableContext bc){
        if(kpiMeta!=null && kpiMeta.EnableEmailSend__c){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            list <EmailSetting__mdt> email=[SELECT DeveloperName, Email__c FROM EmailSetting__mdt WHERE DeveloperName='Elaborazione_Archivio_FUB' limit 1];
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress LIMIT 1];
            mail.setOrgWideEmailAddressId(owea[0].Id);
            mail.setToAddresses(new String[]{kpiMeta.DesiredEmail__c});
            mail.setSubject('Batch HDT_BA_OrderDocumentalManagement execution KPI');
            String body='number of records: ' + (counterKo+counterOk) + '\nsuccessful send to e1: ' + counterOk + '\nunsuccessful deletions ' + counterKo ;
            mail.setPlainTextBody (body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }

        if(kpiMeta!=null && kpiMeta.EnableTracking__c){
            srvBatchEx.updateRecord(kpiTrack.Id,counterOk, counterKo, counterKo + counterOk);
        }
    }
}
