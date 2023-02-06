@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_CreditCheckSales {

    private List<MassiveLoaderRequestItem__c> requestItemList;
    private List<MassiveLoaderRequestItem__c> itemsToUpdate;
    private List<HDT_WRP_ProcessObject> processObjectList;
    private List<Id> parentOrderIdList;
    private Map<Id, Order> orderOffCommMap;
    private Map<Id, Order> orderAnalisiConsMap;
    private String process;

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
        this.process = requestItemList[0].MassiveLoaderRequest__r.ProcessType__c;
        processObjectList.add(processObject);
    }

    public void getRecords(){
        System.debug(LoggingLevel.DEBUG, '# getRecords #');

        System.debug(LoggingLevel.DEBUG, '# getRecords #');

        orderOffCommMap = new Map<Id, Order>();
        orderAnalisiConsMap = new Map<Id, Order>();

        List<Order> orderOffCommList = [
            SELECT Id, OrderNumber, ParentOrder__c, processType__c, Phase__c, CancellationReasonDescription__c,
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
        List<Order> orderToUpdate = new List<Order>();
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
                processObject.requestItem.Result__c = orderToCheck.OrderNumber;

                System.debug(LoggingLevel.DEBUG, '>>> createRequestFromOrderId');
                if(!this.process.equalsIgnoreCase('CambioOfferta') && !this.process.equalsIgnoreCase('MUC') && !this.process.equalsIgnoreCase('CambioUso')){
                    creditCheckRequest = HDT_UTL_CreditCheck.createRequestFromOrderId(orderToCheck.Id);
                    creditCheckResponse = HDT_WS_CreditCheck.callService(creditCheckRequest);

                    if(creditCheckResponse.statusCode != 200 && creditCheckResponse.statusCode != 201){
                        //processObject.requestItem.Status__c = 'Errore';
                        //processObject.requestItem.StatuDsescription__c = 'Errore nella chiamata al servizio di Credit Check';
                        orderToCheck.Phase__c = 'Credit Check KO';
                        processObject.requestItem.Status__c = 'Chiuso';
                        orderToUpdate.add(orderToCheck);
                    } else {
                        processObject.requestItem.Status__c = 'Chiuso';
                    }
                }else {
                    processObject.requestItem.Status__c = 'Chiuso';
                }

            } catch(Exception ex){
                processObject.requestItem.Status__c = 'Errore';
                processObject.requestItem.StatusDescription__c = (ex.getMessage() + ' linea: ' + String.valueOf(ex.getLineNumber())).abbreviate(250);
            }

            itemsToUpdate.add(processObject.requestItem);

        }

        if(orderToUpdate.size() > 0){
            update orderToUpdate;
        }

    }
        
    public void updateItems(){
        update itemsToUpdate;
    }

    public static HDT_WS_Response sendRequest(String namedCredential, String path, String method, HDT_WS_Request request){
               
        HTTP http = new Http();
        HTTPRequest req = new HTTPRequest();
        HDT_WS_Response resp = new HDT_WS_Response();
        req.setTimeout(120000); 
        req.setHeader('Content-type', 'application/json');
        req.setEndpoint('Callout:' + namedCredential + path);
        req.setMethod(method);        
        req.setBody(JSON.serialize(request));

        try{
            HTTPResponse res = http.send(req);
            resp.body = res.getBody();
            resp.statusCode = res.getStatusCode();
        } catch(Exception e){
            resp.exceptionMessage = e.getMessage();
        }
        return resp;
    }

    private class HDT_WRP_ProcessObject {
        private MassiveLoaderRequestItem__c requestItem;
        private HDT_UTL_ProcessSales.HDT_WRP_NextDataObj nextDataObj;
    }
    
}