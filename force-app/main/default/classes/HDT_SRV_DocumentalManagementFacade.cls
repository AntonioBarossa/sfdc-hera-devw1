public with sharing class HDT_SRV_DocumentalManagementFacade {
    public static String getBase64(String recordId,String context,String formParams){
        String base64 = '';
        String body='';
        String result='';
        String responseCode;
        String responseStatus;
        Map<String,String> resultMap = new Map<String,String>();
        HDT_WRP_DocumentalResponse documentalResponse = new HDT_WRP_DocumentalResponse();
        try{     
            body = HDT_SRV_DocumentalManagement.generateRequest(recordId, context, formParams);
            documentalResponse = HDT_SRV_DocumentalManagement.executeCalloutRequest(body,context);
            base64 = documentalResponse.deliverPackageResponse.composedDocument;
            result = documentalResponse.deliverPackageResponse.result;
            responseCode = String.valueOf(documentalResponse.responseCode);
            responseStatus = documentalResponse.responseStatus;
            resultMap.put('code',responseCode);
            resultMap.put('base64',base64);
            resultMap.put('result',result);
        }catch(Exception ex){
            resultMap.put('code','500');
        }
        return JSON.serialize(resultMap);
    }

    public static void sendDocument(String recordId,String context,String formParams){
        String body='';
        HDT_WRP_DocumentalResponse documentalResponse = new HDT_WRP_DocumentalResponse();
        try{
            body = HDT_SRV_DocumentalManagement.generateRequest(recordId, context, formParams);
            HDT_SRV_DocumentalManagement.executeCalloutRequestFuture(body,context);
        }catch(Exception ex){
            System.debug(ex.getMessage());
        }
    }

    public static void sendDocumentAsync(String recordId,String context,String formParams){
        System.enqueueJob(new HDT_QBL_DocumentalManagement(recordId,context,formParams));
    }

    public static void sendAdvanceDocumentation(String recordId,String context,String formParams){
        String base64 = '';
        HDT_WRP_DocumentalResponse documentalResponse = new HDT_WRP_DocumentalResponse();
        Map<String,Object> formParamsMap = formParams != null? (Map<String,Object>) JSON.deserializeUntyped(formParams) : null;
        String fileName = (String) formParamsMap.get('fileName');
        String sendMode = (String) formParamsMap.get('sendMode');
        try{
            base64 = getBase64(recordId,context,formParams);
            if(sendMode.equalsIgnoreCase('E-mail')){
                HDT_SRV_DocumentalManagement.createPublicLinkFuture(recordId,base64,fileName);
            }
        }catch(Exception ex){
            System.debug(ex.getMessage());
        }
    }
     

    public static String getSignSendMode(String processType, String source){
        String configurationJSON = '';
        try{
            configurationJSON = HDT_SRV_DocumentalManagement.getSignModeConfiguration(processType, source);
        }catch(Exception ex){
            configurationJSON = ex.getMessage();
        }
        return configurationJSON;
    }

    public static String getInfoAccountStatement(String accountId){
        Map<String,String> returnMap = new Map<String,String>();
        HDT_QR_Account accntQuery = new HDT_QR_Account();
        try {
            User userRecord = HDT_QR_UserQueries.getCurrentUser(UserInfo.getUserId());
            Account accountRecord = accntQuery.getRecordById(accountId, 'Id,PrimaryEmail__c,MobilePhone__c');
            returnMap.put('email', accountRecord.PrimaryEmail__c);
            returnMap.put('telefono', accountRecord.MobilePhone__c);
            returnMap.put('source', userRecord.LoginChannel__c);
        } catch (Exception ex) {
            
        }
        return JSON.serialize(returnMap);
    }

    // WIP
    public static String showOriginalDocument(String recordId){
        String context;
        String base64 = '';
        String body='';
        String result='';
        String responseCode;
        String responseStatus;
        Map<String,String> resultMap = new Map<String,String>();
        HDT_WRP_DocumentalResponse documentalResponse = new HDT_WRP_DocumentalResponse();
        try{     
            body = HDT_SRV_DocumentalManagement.generateRequest(recordId, context, formParams);
            documentalResponse = HDT_SRV_DocumentalManagement.executeCalloutRequest(body,context);
            base64 = documentalResponse.deliverPackageResponse.composedDocument;
            result = documentalResponse.deliverPackageResponse.result;
            responseCode = String.valueOf(documentalResponse.responseCode);
            responseStatus = documentalResponse.responseStatus;
            resultMap.put('code',responseCode);
            resultMap.put('base64',base64);
            resultMap.put('result',result);
        }catch(Exception ex){
            resultMap.put('code','500');
        }
        return JSON.serialize(resultMap);
    }

    // WIP
    public static String showArchivedAttachment(String recordId){
        String base64 = '';
        String body='';
        String result='';
        String responseCode;
        String responseStatus;
        Map<String,String> resultMap = new Map<String,String>();
        HDT_WRP_DocumentalResponse documentalResponse = new HDT_WRP_DocumentalResponse();
        try{     
            body = HDT_SRV_DocumentalManagement.generateRequest(recordId, context, formParams);
            documentalResponse = HDT_SRV_DocumentalManagement.executeCalloutRequest(body,context);
            base64 = documentalResponse.deliverPackageResponse.composedDocument;
            result = documentalResponse.deliverPackageResponse.result;
            responseCode = String.valueOf(documentalResponse.responseCode);
            responseStatus = documentalResponse.responseStatus;
            resultMap.put('code',responseCode);
            resultMap.put('base64',base64);
            resultMap.put('result',result);
        }catch(Exception ex){
            resultMap.put('code','500');
        }
        return JSON.serialize(resultMap);
    }
}