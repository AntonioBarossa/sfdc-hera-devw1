@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_CreditCheckSales {

    private List<MassiveLoaderRequestItem__c> requestItemList;
    private List<MassiveLoaderRequestItem__c> itemsToUpdate;
    private List<HDT_WRP_ProcessObject> processObjectList;
    private List<Id> parentOrderIdList;
    private Map<Id, Order> orderOffCommMap;
    private Map<Id, Order> orderAnalisiConsMap;

    public HDT_UTL_CreditCheckSales() {
        System.debug(LoggingLevel.DEBUG, 'HDT_UTL_CreditCheckSales');
    }

    public void setRequestItemList(List<MassiveLoaderRequestItem__c> requestItemList){
        this.requestItemList = requestItemList;
    }

    public void generateWrapperMap(){

        System.debug(LoggingLevel.DEBUG, '# setRequestItemList #');

        itemsToUpdate = new List<MassiveLoaderRequestItem__c>();
        processObjectList = new List<HDT_WRP_ProcessObject>();
        parentOrderIdList = new List<Id>();

        // Per ogni ordine padre creato estrarre gli ordini figli con offerta commerciale quindi con ProcessType__c != 'VAS'
        HDT_WRP_ProcessObject processObject;
        for(MassiveLoaderRequestItem__c singleItem : requestItemList){

            processObject = new HDT_WRP_ProcessObject();

            if(!String.isEmpty(singleItem.NextStepData__c)){
                processObject.nextDataObj = (HDT_UTL_ProcessSales.HDT_WRP_NextDataObj)JSON.deserialize(singleItem.NextStepData__c, HDT_UTL_ProcessSales.HDT_WRP_NextDataObj.class);
                
                if(processObject.nextDataObj.orderCompatible){
                    parentOrderIdList.add(processObject.nextDataObj.parentOrderId);
                }
                System.debug(LoggingLevel.DEBUG, '>>> parentOrderIdList ' + parentOrderIdList);
            }

            processObject.requestItem = singleItem;
        }
        processObjectList.add(processObject);
    }

    public void getRecords(){
        System.debug(LoggingLevel.DEBUG, '# getRecords #');

        System.debug(LoggingLevel.DEBUG, '# getRecords #');

        orderOffCommMap = new Map<Id, Order>();
        orderAnalisiConsMap = new Map<Id, Order>();

        List<Order> orderOffCommList = [
            SELECT Id, ParentOrder__c, processType__c, Phase__c, CancellationReasonDescription__c,
                   ServicePoint__c, ServicePoint__r.ServicePointCode__c, ServicePoint__r.CommoditySector__c
            FROM Order
            WHERE ParentOrder__c IN :parentOrderIdList
            AND processType__c != 'VAS'
            AND VasSubtype__c != 'Analisi Consumi'
            WITH SECURITY_ENFORCED
        ];

        System.debug(LoggingLevel.DEBUG, '>>> orderOffCommList ' + orderOffCommList.size());

        List<Order> orderAnalisiConsList = [
            SELECT Id, ParentOrder__c, processType__c, Phase__c, CancellationReasonDescription__c,
                   ServicePoint__c, ServicePoint__r.ServicePointCode__c, ServicePoint__r.CommoditySector__c
            FROM Order
            WHERE ParentOrder__c IN :parentOrderIdList
            AND VasSubtype__c = 'Analisi Consumi'
            WITH SECURITY_ENFORCED
        ];

        System.debug(LoggingLevel.DEBUG, '>>> orderAnalisiConsList ' + orderAnalisiConsList.size());

        for(Order o : orderOffCommList){
            orderOffCommMap.put(o.ParentOrder__c, o);
        }

        for(Order o : orderAnalisiConsList){
            orderAnalisiConsMap.put(o.ParentOrder__c, o);
        }

    }

    public void runCreditCheckSales(){
        System.debug(LoggingLevel.DEBUG, '# runCreditCheckSales #');

        HDT_WS_CreditCheckRequest creditCheckRequest;
        HDT_WS_CreditCheckResponse creditCheckResponse;
        Order orderToCheck;
        for(HDT_WRP_ProcessObject processObject : processObjectList){
            try{

                System.debug(LoggingLevel.DEBUG, '>>> orderToCheck ' + processObject.nextDataObj.parentOrderId);

                if(!processObject.nextDataObj.orderCompatible){
                    continue;
                }

                if(!orderOffCommMap.containsKey(processObject.nextDataObj.parentOrderId)){
                    continue;
                }

                orderToCheck = orderOffCommMap.get(processObject.nextDataObj.parentOrderId);

                System.debug(LoggingLevel.DEBUG, '>>> createRequestFromOrderId');
                creditCheckRequest = HDT_UTL_CreditCheck.createRequestFromOrderId(orderToCheck.Id);

                System.debug(LoggingLevel.DEBUG, '>>> callService');
                creditCheckResponse = HDT_WS_CreditCheck.callService(creditCheckRequest);

                System.debug(LoggingLevel.DEBUG, '>>> creditCheckResponse: ' + creditCheckResponse.statusCode);
                //System.debug(LoggingLevel.DEBUG, '>>> creditCheckResponse: ' + creditCheckResponse.status);

                if(creditCheckResponse.statusCode != 200){
                    processObject.requestItem.Status__c = 'Errore';
                    processObject.requestItem.StatusDescription__c = 'Errore nel web service';
                } else {
                    processObject.requestItem.Status__c = 'Chiuso';
                }

            } catch(Exception ex){
                processObject.requestItem.Status__c = 'Errore';
                processObject.requestItem.StatusDescription__c = ex.getMessage() + ' linea: ' + String.valueOf(ex.getLineNumber());
            }

            itemsToUpdate.add(processObject.requestItem);

        }

    }
        
    public void updateItems(){
        update itemsToUpdate;
    }

    private class HDT_WRP_ProcessObject {
        private MassiveLoaderRequestItem__c requestItem;
        private HDT_UTL_ProcessSales.HDT_WRP_NextDataObj nextDataObj;
    }
    
}