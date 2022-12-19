public with sharing class HDT_BA_OrderDocumentalManagement implements Database.Batchable<sObject>, Database.Stateful {
    public Set<String> orderScartatiSet = new Set<String>();
    public Integer counterKo = 0;
    public Integer counterOk = 0;
    Datetime start = null;
    private static HDT_SRV_BatchExecutionKpi srvBatchEx = new HDT_SRV_BatchExecutionKpi();
    BatchExecutionKpiConfiguration__mdt kpiMeta = BatchExecutionKpiConfiguration__mdt.getInstance('HDT_BA_OrderDocumentalManagement');
    BatchExecutionKpi__c kpiTrack=new BatchExecutionKpi__c();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        if(kpiMeta!=null && kpiMeta.EnableTracking__c){
            kpiTrack = srvBatchEx.createRecord(Datetime.now(),'HDT_BA_OrderDocumentalManagement');
        }
        String query = 'select ParentOrder__c from Order where Phase__c = \'In attesa validazione\' and CommodityFormula__c = \'Ambiente\'';
        List<Order> ordList = Database.query(query);
        Set<Id> orderIdSet = new Set<Id>();
        for(Order ord: ordList){
            orderIdSet.add(ord.ParentOrder__c);
        }
        String queryOrder = 'SELECT Id,DocSendingMethod__c,SignatureMethod__c,ShippingAddressFormula__c FROM Order WHERE Id IN:orderIdSet';
        return Database.getQueryLocator(queryOrder);
    }
    public void execute(Database.BatchableContext bc, List<Order> scope){
        Order singleOrder = (Order) scope[0];
        if(String.isBlank(singleOrder.ShippingAddressFormula__c)){
            orderScartatiSet.add(singleOrder.Id);
            counterKo++;
            return;
        }
        Map<String,String> params = new Map<String,String>();
        String modInvio = singleOrder.DocSendingMethod__c == 'Stampa Cartacea'? 'Sportello':singleOrder.DocSendingMethod__c;
        params.put('signMode', singleOrder.SignatureMethod__c);
        params.put('sendMode', 'Posta Cartacea');
        params.put('Contesto', 'Order');
        params.put('mode', 'Print');
        params.put('Archiviato', 'Y');
        params.put('TipoPlico', 'Sollecito');
        HDT_SRV_DocumentalManagementFacade.sendDocumentAsync(singleOrder.Id, 'Order',JSON.serialize(params));
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
