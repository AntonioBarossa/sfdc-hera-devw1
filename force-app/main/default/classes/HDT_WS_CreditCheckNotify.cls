@SuppressWarnings('PMD.AvoidDebugStatements')
@RestResource(urlMapping = '/CreditCheckNotify/*')
global with sharing class HDT_WS_CreditCheckNotify {
    

    @HttpPost
    global static void doPost(){
        String body = '';
        String crmId= '';
        try{
            body = RestContext.request.requestBody.toString();
            System.debug(LoggingLevel.DEBUG,'WS CreditCheckNotify Body Request: ' + body);
            HDT_WRP_NotifyRequest request = (HDT_WRP_NotifyRequest)JSON.deserialize(body, HDT_WRP_NotifyRequest.class);
            //Gestisco solo se non c'è un codice errore oppure non è tra quelli che devo trattare come OK
            crmId = request.crmId;
            if (String.isBlank(request.crmId)){
                throw new HDT_WS_CreditCheckException('CrmId field cannot be null.');
            }
            List<Order> orderList = HDT_QR_GenericQuery.getGenericRecords('Id, CreditCheckDescription__c, IncomingCreditCheckResult__c, OutgoingCreditCheckResult__c', 'Order', 'Id = \''+String.escapeSingleQuotes(request.crmId)+'\'');
            if (orderList.isEmpty()){
                throw new HDT_WS_CreditCheckException('Invalid crmid field: record not found.');
            }
            if (String.isBlank(request.errorCode) || !HDT_UTL_CreditCheck.managedErrorCode(request.errorCode)){
                workOrder(orderList[0],
                    String.isBlank(request.creditCheckDescription) ? '' : request.creditCheckDescription,
                    String.isBlank(request.incomingCreditCheckResult) ? '' :request.incomingCreditCheckResult,
                    String.isBlank(request.outgoingCreditCheckResult) ? '' :request.outgoingCreditCheckResult
                );
            }
            RestContext.response.statusCode=200;
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new HDT_WRP_NotifyResponse('success',null)));
            RestContext.response.headers.put('Content-Type', 'application/json');
        }catch(Exception e){
            body = String.isNotBlank(body) ? body : 'empty request...';
            System.debug(LoggingLevel.ERROR,'WS CreditCheckNotify Error ' + e.getMessage());
            RestContext.response.statusCode=400;
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new HDT_WRP_NotifyResponse('error',e.getMessage())));
            RestContext.response.headers.put('Content-Type', 'application/json');
            HDT_UTL_IntegrationLog.handleGenericErrorRequest(body,'POST', e.getMessage(), 'HDT_WS_CreditCheckNotify', crmId);  
        }
        
    }

    private static void workOrder(Order ord, String description, String incomingOutcome, String outgoingOutcome){
        //Gestione Credit Check
        HDT_UTL_CreditCheck.HDT_WRP_DataForUpdate orderData = new HDT_UTL_CreditCheck.HDT_WRP_DataForUpdate();
        orderData.orderId = ord.Id;
        orderData.outcomeDescription = description;
        orderData.outcome = (String.isNotBlank(incomingOutcome) && !incomingOutcome.equalsIgnoreCase(ord.IncomingCreditCheckResult__c)) ? incomingOutcome 
                            : (String.isNotBlank(outgoingOutcome) && !outgoingOutcome.equalsIgnoreCase(ord.OutgoingCreditCheckResult__c)) ?
                                                     outgoingOutcome : ord.IncomingCreditCheckResult__c;
        orderData.outcoming = (String.isNotBlank(incomingOutcome) && !incomingOutcome.equalsIgnoreCase(ord.IncomingCreditCheckResult__c)) ? false 
                            : (String.isNotBlank(outgoingOutcome) && !outgoingOutcome.equalsIgnoreCase(ord.OutgoingCreditCheckResult__c)) ?
                                 true : false;
        HDT_UTL_CreditCheck.updateOrder(new List<HDT_UTL_CreditCheck.HDT_WRP_DataForUpdate>{orderData});
    }

    public class HDT_WRP_NotifyResponse{
        public String status;
        public String errorDetails;
        
        public HDT_WRP_NotifyResponse(String status,String errorDetails){
            this.status = status;
            this.errorDetails = errorDetails;
        }
    }

    public class HDT_WRP_NotifyRequest{
        public String crmId;
        public String errorCode;
        public String creditCheckDescription;
        public String outgoingCreditCheckResult;
        public String incomingCreditCheckResult;
    }

    public class HDT_WS_CreditCheckException extends Exception{}
}