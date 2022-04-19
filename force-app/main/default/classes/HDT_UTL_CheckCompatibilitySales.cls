@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_CheckCompatibilitySales {

    private List<MassiveLoaderRequestItem__c> itemsToUpdate;
    private List<MassiveLoaderRequestItem__c> requestItemList;
    private List<HDT_WRP_ProcessObject> processObjectList;
    private List<Id> parentOrderIdList;
    private Map<Id, Order> orderOffCommMap;
    private Map<Id, Order> orderAnalisiConsMap;

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

        // Per ogni ordine padre creato estrarre gli ordini figli con offerta commerciale quindi con ProcessType__c != 'VAS'
        HDT_WRP_ProcessObject processObject;
        for(MassiveLoaderRequestItem__c singleItem : requestItemList){

            processObject = new HDT_WRP_ProcessObject();

            if(!String.isEmpty(singleItem.NextStepData__c)){
                processObject.nextDataObj = (HDT_UTL_ProcessSales.HDT_WRP_NextDataObj)JSON.deserialize(singleItem.NextStepData__c, HDT_UTL_ProcessSales.HDT_WRP_NextDataObj.class);
                parentOrderIdList.add(processObject.nextDataObj.parentOrderId);
                System.debug(LoggingLevel.DEBUG, '>>> parentOrderIdList ' + parentOrderIdList);
            }

            processObject.requestItem = singleItem;
        }
        processObjectList.add(processObject);
    }

    public void getRecords(){

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

    public void runCheckCompatibilitySales(){
        System.debug(LoggingLevel.DEBUG, '# runCheckCompatibilitySales #');

        List<Order> orderToUpdate = new List<Order>();
        List<ServiceRequest__c> serviceRequestToInsert = new List<ServiceRequest__c>();

        Order orderToCheck;
        Order analisiConsumiOrder;
        Map<String, Object> servReq;
        Map<String, Object> checkResponse;
        for(HDT_WRP_ProcessObject processObj : processObjectList){

            System.debug('>>> parentOrderId ' + processObj.nextDataObj.parentOrderId);
            
            if(orderOffCommMap.containsKey(processObj.nextDataObj.parentOrderId)){
                orderToCheck = orderOffCommMap.get(processObj.nextDataObj.parentOrderId);
            }
            
            if(orderAnalisiConsMap.containsKey(processObj.nextDataObj.parentOrderId)){
                analisiConsumiOrder = orderAnalisiConsMap.get(processObj.nextDataObj.parentOrderId);
            }

            servReq = new Map<String, Object>();
            servReq.put('servicePointCode', orderToCheck.ServicePoint__r.ServicePointCode__c);
            servReq.put('commoditySector', orderToCheck.ServicePoint__r.CommoditySector__c);
            servReq.put('type', 'Order');
            servReq.put('servicePoint', orderToCheck.ServicePoint__c);
            servReq.put('processType', orderToCheck.processType__c); 

            System.debug('>>> servReq ' + String.valueOf(servReq));

            checkResponse = HDT_UTL_MatrixCompatibility.checkCompatibilitySales(servReq, false);

            Object o = checkResponse.get('compatibility');

            System.debug('>>> checkResponse ' + o);

            if(o == null){
                // Se il risultato del metodo mappa.get('compatibility') è blank allora è necessario chiamare
                processObj.nextDataObj.orderCompatible = true;

                //ordine analisi consumi -->
                analisiConsumiOrder.Phase__c = 'Comunicazione verso Heroku';

            } else {
                // Se il risultato del metodo mappa.get('compatibility') != null allora è necessario annullare l'ordine e gli altri order figli
                processObj.nextDataObj.orderCompatible = false;
                orderToCheck.Phase__c = 'Annullato';
                orderToCheck.Status = 'Annullato';
                //orderToCheck.CancellationReasonDescription__c = 'Processi incompatibili: ' ;//+ mappa

                //annullare ordine analisi consumi
                analisiConsumiOrder.Phase__c = 'Annullato';
                analisiConsumiOrder.Status = 'Annullato';
                //analisiConsumiOrder.CancellationReasonDescription__c = 'Processi incompatibili: ' ;//+ mappa
                analisiConsumiOrder.Phase__c = 'Comunicazione verso Heroku'; //// ??? 
                orderToUpdate.add(orderToCheck);
            }

            orderToUpdate.add(analisiConsumiOrder);

            // per analisi consumi creare solo ServiceRequest
            ServiceRequest__c srRequest;
            srRequest = setServiceRequest(srRequest, analisiConsumiOrder);
            serviceRequestToInsert.add(srRequest);

            processObj.nextDataObj.orderCompatible = false;
            processObj.requestItem.NextStepData__c = JSON.serialize(processObj.nextDataObj);
            itemsToUpdate.add(processObj.requestItem);
        }
        
        update orderToUpdate;
        insert serviceRequestToInsert;

    }

    private static ServiceRequest__c setServiceRequest(ServiceRequest__c srRequest, Order analisiConsumiOrder){
        srRequest = new ServiceRequest__c();
        srRequest.ServicePointCode__c = analisiConsumiOrder.ServicePoint__r.ServicePointCode__c;
        srRequest.Status__c = 'Bozza';
        srRequest.Order__c = analisiConsumiOrder.Id;
        srRequest.CommoditySector__c = analisiConsumiOrder.ServicePoint__r.CommoditySector__c;
        srRequest.Type__c = 'Order';
        srRequest.ServicePoint__c = analisiConsumiOrder.ServicePoint__c;
        //srRequest.ProcessType__c = (srRequest.CommoditySector__c == 'Energia Elettrica') ? 'Aggiunta Sconti o Bonus VAS Ele' : 'Aggiunta Sconti o Bonus VAS Gas';
        srRequest.ProcessType__c = (srRequest.CommoditySector__c == 'Energia Elettrica') ? 'Sconti e bonus - EE' : 'Sconti e bonus - GAS';
        //srRequest.Phase__c = 'Comunicazione verso Heroku';
        System.debug('>>> srRequest ' + srRequest);
        return srRequest;
    }

    public void updateItems(){
        update itemsToUpdate;
    }

    private class HDT_WRP_ProcessObject {
        private MassiveLoaderRequestItem__c requestItem;
        private HDT_UTL_ProcessSales.HDT_WRP_NextDataObj nextDataObj;
    }


}