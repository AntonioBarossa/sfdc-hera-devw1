@SuppressWarnings('PMD.AvoidDebugStatements')
@RestResource(urlMapping = '/CreditCheckNotify/*')
global with sharing class HDT_WS_CreditCheckNotify {
    

    @HttpPost
    global static void doPost(){
        try{
            String body = RestContext.request.requestBody.toString();
            System.debug(LoggingLevel.DEBUG,'WS CreditCheckNotify Body Request: ' + body);
            HDT_WRP_NotifyRequest request = (HDT_WRP_NotifyRequest)JSON.deserialize(body, HDT_WRP_NotifyRequest.class);
            //Gestisco solo se non c'è un codice errore oppure non è tra quelli che devo trattare come OK
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
            System.debug(LoggingLevel.ERROR,'WS CreditCheckNotify Error ' + e.getMessage());
            RestContext.response.statusCode=400;
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new HDT_WRP_NotifyResponse('error',e.getMessage())));
            RestContext.response.headers.put('Content-Type', 'application/json');
        }
        
    }

    private static void workOrder(Order ord, String description, String incomingOutcome, String outgoingOutcome){
        if ((!description.equalsIgnoreCase(description) && (String.isBlank(ord.CreditCheckDescription__c) || !ord.CreditCheckDescription__c.containsIgnoreCase(description))) 
            || !incomingOutcome.equalsIgnoreCase(ord.IncomingCreditCheckResult__c)
            || !outgoingOutcome.equalsIgnoreCase(ord.OutgoingCreditCheckResult__c)
        ){
            Order orderToUpdate = new Order();
            orderToUpdate.Id = ord.Id;
            orderToUpdate.CreditCheckDescription__c = description;
            orderToUpdate.OutgoingCreditCheckResult__c = outgoingOutcome;
            orderToUpdate.IncomingCreditCheckResult__c = incomingOutcome;
            HDT_UTL_DatabaseService.updateSObject(orderToUpdate);
        }
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