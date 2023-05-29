public inherited sharing class HDT_UTL_ProcessReworkingScraps extends HDT_UTL_ProcessExecution {

    private List<String> caseNumberSet = new List<String>();
    private List<String> orderNumberSet = new List<String>();
    private List<String> listIdOrder = new List<String>();
    private List<String> listIdCase  = new List<String>();
    public static HDT_QR_Order qrOrder = new HDT_QR_Order();
    public static HDT_QR_Case qrCase = new HDT_QR_Case();
    private List<MassiveLoaderRequestItem__c> itemsToSave;
    private List<HDT_WRP_ProcessObjects> processObjList;
    List<Order> orderList;
    List<Case> caseList;

    public override void checks(){

        System.debug(LoggingLevel.DEBUG, 'checks');

        itemsToSave = new List<MassiveLoaderRequestItem__c>();
        Integer index = mapHeaderForWrapper.get('OrderNumber/CaseNumber');

        HDT_WRP_ProcessObjects processObj;
        processObjList = new List<HDT_WRP_ProcessObjects>();
        List<String> tempSplitedFields;

        for(MassiveLoaderRequestItem__c item : requestItemList){

            tempSplitedFields = new List<String>();
            tempSplitedFields = item.Data__c.split(splitCharacter, -1);

            checkRequiredFields(item, tempSplitedFields);
            System.debug(LoggingLevel.DEBUG, '>>> itemStatus' + item.Status__c);

            if(item.Status__c.equalsIgnoreCase('Errore')){
                itemsToSave.add(item);
                continue;
            }

            processObj = new HDT_WRP_ProcessObjects();
            processObj.requestItem = item;
            processObj.csvSplitted = tempSplitedFields;
            processObj.autoNumber = processObj.csvSplitted[0];

            if(processObj.autoNumber.startsWith('O-')) {
                orderNumberSet.add(processObj.csvSplitted[0]);
            } else if(processObj.autoNumber.startsWith('C-')) {
                caseNumberSet.add(processObj.csvSplitted[0]);
            } else {
                processObj.requestItem.Status__c = 'Errore';
                processObj.requestItem.StatusDescription__c = 'Formato non corretto';
                itemsToSave.add(processObj.requestItem);
                continue;
            }

            processObjList.add(processObj);

        }

    }

    public override void getRecords(){

        System.debug(LoggingLevel.DEBUG, '>>> getRecords...');

        orderList = new List<Order>();
        caseList = new List<Case>();
        Map<String, Case> caseMap = new Map<String, Case>();
        Map<String, Order> orderMap = new Map<String, Order>();

        if(orderNumberSet.size()>0){

            orderList = [
                SELECT Id, OrderNumber, ProcessType__c, Phase__c
                FROM Order
                WHERE Ordernumber IN :orderNumberSet
                WITH SECURITY_ENFORCED
            ];

            if(orderList.size()>0){
                System.debug(LoggingLevel.DEBUG, '>>> set order map...');
                for(Order o : orderList){
                    orderMap.put(o.OrderNumber, o);
                }
            }
        }
        
        if(caseNumberSet.size()>0){
            caseList = [
                SELECT Id, CaseNumber,Type
                FROM Case
                WHERE CaseNumber IN :caseNumberSet
                WITH SECURITY_ENFORCED
            ];

            if(caseList.size()>0){
                System.debug(LoggingLevel.DEBUG, '>>> set case map...');
                for(Case c : caseList){
                    caseMap.put(c.CaseNumber, c);
                }
            }
        }

        for(HDT_WRP_ProcessObjects processObj : processObjList){

            if(processObj.autoNumber.startsWith('O-') && orderMap.containsKey(processObj.autoNumber)) {
                processObj.currOrder = orderMap.get(processObj.autoNumber);
            } else if(processObj.autoNumber.startsWith('C-') && caseMap.containsKey(processObj.autoNumber)) {
                processObj.currCase = caseMap.get(processObj.autoNumber);
            } else {
                processObj.requestItem.Status__c = 'Errore';
                processObj.requestItem.StatusDescription__c = 'Record non presente nel database';
                itemsToSave.add(processObj.requestItem);
                continue;
            }

        }
        
    }

    public override void registryCreation(){

        System.debug(LoggingLevel.DEBUG, '>>> registryCreation...');

        List<MassiveLoaderRequestItem__c> requestItemForOrder = new List<MassiveLoaderRequestItem__c>();
        List<MassiveLoaderRequestItem__c> requestItemForCase = new List<MassiveLoaderRequestItem__c>();
        List<Case> caseToUpdate = new List<Case>();
        List<Order> orderToUpdate = new List<Order>();

        List<MassiveLoaderRequestItem__c> requestItemForUpsert;
        requestItemForUpsert = new List<MassiveLoaderRequestItem__c>();

        for(HDT_WRP_ProcessObjects processObj : processObjList){

            if(processObj.requestItem.Status__c.equalsIgnoreCase('Errore')){
                continue;
            }

            if(processObj.autoNumber.startsWith('O-')) {
                // set fields for update here
                processObj.currOrder = setOrder(processObj.currOrder);
                System.debug('>>> ORDER -> ' + String.valueOf(processObj.currOrder));
                requestItemForOrder.add(processObj.requestItem);
                orderToUpdate.add(processObj.currOrder);
            } else if(processObj.autoNumber.startsWith('C-')) {
                // set fields for update here
                processObj.currCase = setCase(processObj.currCase);
                System.debug('>>> CASE -> ' + String.valueOf(processObj.currCase));
                requestItemForCase.add(processObj.requestItem);
                caseToUpdate.add(processObj.currCase);
            }

        }

        HDT_WRP_SaveResponse saveCaseResponse;
        saveCaseResponse = databaseUpsert(caseToUpdate, requestItemForCase, 'Case');

        if(saveCaseResponse.reponseItemList.size() > 0){
            itemsToSave.addAll(saveCaseResponse.reponseItemList);
            System.debug('>>> CASE itemsToSave -> ' + String.valueOf(itemsToSave));
        }

        HDT_WRP_SaveResponse saveOrderResponse;
        saveOrderResponse = databaseUpsert(orderToUpdate, requestItemForOrder, 'Order');

        if(saveOrderResponse.reponseItemList.size() > 0){
            itemsToSave.addAll(saveOrderResponse.reponseItemList);
            System.debug('>>> ORDER itemsToSave -> ' + String.valueOf(itemsToSave));
        }

        for(HDT_WRP_ProcessObjects processObj : processObjList){

            if(processObj.requestItem.Status__c.equalsIgnoreCase('Errore')){
                continue;
            }
            processObj.requestItem.Result__c = 'Aggiornato';
        }
    }

    public override void finalUpdate(){
        System.debug(LoggingLevel.DEBUG, 'finalUpdate');

        if(itemsToSave.size() > 0){
            update itemsToSave;
        }
    }

    //private void mapFieldsObject(){
    //    mapWrapperFields = new Map<String, String>();
    //    mapWrapperFields.put(temp.labelField__c, temp.nameField__c);
    //}

    public static Case setCase(Case caseToSet){
        switch on caseToSet.Type {
            when 'Consumo Anomalo Idrico' {
                caseToSet.Phase__c=System.Label.consumoAnomaloIdricoDefaultPhase;
            }
            when else {
                caseToSet.Phase__c = 'Da Inviare';
            }
        }

        return caseToSet;
    }

    public static Order setOrder(Order orderToSet){

        String fase = 'Comunicazione verso Heroku';
        switch on orderToSet.ProcessType__c {
            when  'Voltura' {
                fase = 'Documentazione Validata';
            }
            when 'VAS' {
                fase = 'Comunicazione Motore VAS';
            }
        }
        if ('Caricamento Siebel KO'.equalsIgnoreCase(orderToSet.Phase__c)){
            fase = 'Esportazione VS Siebel';
        }

        orderToSet.Phase__c = fase;
        orderToSet.DiscardReason__c = null;
        orderToSet.HerokuPracticeCode__c = null;
        orderToSet.DistributorPracticeCode__c = null;
        return orderToSet;
    }

    private class HDT_WRP_ProcessObjects {
        private String autoNumber;
        private Case currCase;
        private Order currOrder;
        private MassiveLoaderRequestItem__c requestItem;
        private List<String> csvSplitted;
    }

}