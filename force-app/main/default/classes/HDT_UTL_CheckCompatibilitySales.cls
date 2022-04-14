@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_CheckCompatibilitySales {

    private List<MassiveLoaderRequestItem__c> itemsToUpdate;
    private List<MassiveLoaderRequestItem__c> requestItemList;
    private List<HDT_WRP_ProcessObject> processObjectList;
    private List<Id> parentOrderIdList;
    private List<Id> servicePointIdList;
    private Map<Id, Order> orderMap;
    private Map<Id, ServicePoint__c> servicePointMap;

    public HDT_UTL_CheckCompatibilitySales() {
        System.debug(LoggingLevel.DEBUG, 'HDT_UTL_ProcessSalesOutboundWs');
    }

    public void setRequestItemList(List<MassiveLoaderRequestItem__c> requestItemList){
        this.requestItemList = requestItemList;
    }

    public void generateWrapperMap(){

        System.debug(LoggingLevel.DEBUG, '# setRequestItemList #');

        itemsToUpdate = new List<MassiveLoaderRequestItem__c>();
        processObjectList = new List<HDT_WRP_ProcessObject>();
        parentOrderIdList = new List<Id>();
        servicePointIdList = new List<Id>();

        // Per ogni ordine padre creato estrarre gli ordini figli con offerta commerciale quindi con ProcessType__c != 'VAS'
        HDT_WRP_ProcessObject processObject;
        for(MassiveLoaderRequestItem__c singleItem : requestItemList){

            processObject = new HDT_WRP_ProcessObject();

            if(!String.isEmpty(singleItem.NextStepData__c)){
                processObject.nextDataObj = (HDT_UTL_ProcessSales.HDT_WRP_NextDataObj)JSON.deserialize(singleItem.NextStepData__c, HDT_UTL_ProcessSales.HDT_WRP_NextDataObj.class);
                parentOrderIdList.add(processObject.nextDataObj.servPointId);
                servicePointIdList.add(processObject.nextDataObj.parentOrderId);
            }

            processObject.requestItem = singleItem;
        }
        processObjectList.add(processObject);
    }

    public void getRecords(){

        System.debug(LoggingLevel.DEBUG, '# getRecords #');

        orderMap = new Map<Id, Order>();
        servicePointMap = new Map<Id, ServicePoint__c>();
        List<Order> orderList = [
            SELECT Id, processType__c
            FROM Order
            WHERE ParentOrder__c IN :parentOrderIdList
            AND processType__c != 'VAS'
            WITH SECURITY_ENFORCED
        ];

        List<ServicePoint__c> servicePointList = [
            SELECT Id
            FROM ServicePoint__c
            WHERE Id IN :servicePointIdList
            WITH SECURITY_ENFORCED
        ];

        for(Order o : orderList){
            orderMap.put(o.ParentOrder__c, o);
        }

        servicePointMap = new Map<Id, ServicePoint__c>(servicePointList);

    }

    public void runCheckCompatibilitySales(){
        System.debug(LoggingLevel.DEBUG, '# runCheckCompatibilitySales #');

        for(HDT_WRP_ProcessObject processObj : processObjectList){
            
            Order currentOrder = orderMap.get(processObj.nextDataObj.parentOrderId);
            ServicePoint__c sp = servicePointMap.get(processObj.nextDataObj.servPointId);

            Map<String, Object> servReq = new Map<String, Object>();

            // servReq.put('servicePointCode', sr.ServicePointCode__c);
            // servReq.put('commoditySector', sr.CommoditySector__c);
            // servReq.put('type', sr.Type__c);
            // servReq.put('servicePoint', sr.ServicePoint__c);
            // servReq.put('processType', currentOrder.processType__c);//'Sospensione Fornitura');   

            //Map<String, Object> checkResponse = HDT_UTL_MatrixCompatibility.checkCompatibilitySales(servReq, false);

            //Object o = checkResponse.get('compatibility');

            //if(o == null){
            //    // Se il risultato del metodo mappa.get('compatibility') è blanl allora è necessario chiamare
            //    processObj.nextDataObj.orderCompatible = true;
            //} else {
            //    // Se il risultato del metodo mappa.get('compatibility') != null allora è necessario annullare l'ordine e gli altri order figli
            //    processObj.nextDataObj.orderCompatible = false;
            //}
            processObj.nextDataObj.orderCompatible = false;
            processObj.requestItem.NextStepData__c = JSON.serialize(processObj.nextDataObj);
            itemsToUpdate.add(processObj.requestItem);
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