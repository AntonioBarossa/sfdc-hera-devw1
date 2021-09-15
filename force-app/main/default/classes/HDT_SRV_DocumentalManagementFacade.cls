public with sharing class HDT_SRV_DocumentalManagementFacade {
    public static String getBase64(String recordId,String context,String formParams){
        String baseSixtyFour = '';
        String body='';
        String result='';
        String responseCode;
        String responseStatus;
        String message;
        Map<String,String> resultMap = new Map<String,String>();
        HDT_WRP_DocumentalResponse documentalResponse = new HDT_WRP_DocumentalResponse();
        try{     
            body = HDT_SRV_DocumentalManagement.generateRequest(recordId, context, formParams);
            documentalResponse = HDT_SRV_DocumentalManagement.executeCalloutRequest(body,context);
            baseSixtyFour = documentalResponse.deliverPackageResponse.composedDocument;
            result = documentalResponse.deliverPackageResponse.result;
            responseCode = String.valueOf(documentalResponse.responseCode);
            responseStatus = documentalResponse.responseStatus;
            message = documentalResponse.deliverPackageResponse.message;
            resultMap.put('code',responseCode);
            resultMap.put('base64',baseSixtyFour);
            resultMap.put('result',result);
            resultMap.put('message',message);
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
        String baseSixtyFour = '';
        HDT_WRP_DocumentalResponse documentalResponse = new HDT_WRP_DocumentalResponse();
        Map<String,Object> formParamsMap = formParams != null? (Map<String,Object>) JSON.deserializeUntyped(formParams) : null;
        String tipoPlico = (String) formParamsMap.get('TipoPlico');
        String result = '';
        try{
            baseSixtyFour = getBase64(recordId,context,formParams);
            Map<String,Object> respMap = (Map<String,Object>) JSON.deserializeUntyped(baseSixtyFour);
            baseSixtyFour = (String) respMap.get('base64');
            result = (String) respMap.get('result');
            if(result == '000'){
                HDT_SRV_DocumentalManagement.createPublicLinkFuture(recordId,baseSixtyFour,tipoPlico);
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

    public static String showOriginalDocument(String recordId){
        String context;
        String baseSixtyFour = '';
        String body='';
        String result='';
        String responseCode;
        String responseStatus;
        Map<String,String> resultMap = new Map<String,String>();
        HDT_WRP_DocumentalResponse.HDT_WRP_PostelResponse postelResponse = new HDT_WRP_DocumentalResponse.HDT_WRP_PostelResponse();
        try{
            SObject documentalObject = HDT_QR_DocumentalConfiguration.getDocumentalObjectById(recordId);
            String documentType = HDT_SRV_DocumentalManagement.getDocumentType(documentalObject);
            body = HDT_SRV_DocumentalManagement.generateGetEnvelopeRequest(documentalObject);
            postelResponse = HDT_SRV_DocumentalManagement.executeGetEnvelopeCalloutRequest(body, documentType);
            baseSixtyFour = postelResponse.content;
            resultMap.put('outcome','OK');
            resultMap.put('base64',baseSixtyFour);
            resultMap.put('type',  documentType);
        }catch(Exception ex){
            resultMap.put('outcome','KO');
            resultMap.put('errorMessage', ex.getMessage());
        }
        return JSON.serialize(resultMap);
    }

    public static String showArchivedAttachment(String recordId){
        String baseSixtyFour = '';
        String body='';
        String result='';
        String responseCode;
        String responseStatus;
        Map<String,String> resultMap = new Map<String,String>();
        HDT_WRP_DocumentalResponse.HDT_WRP_PostelResponse postelResponse = new HDT_WRP_DocumentalResponse.HDT_WRP_PostelResponse();
        try{
            body = HDT_SRV_DocumentalManagement.generateGetAttachmentRequest(recordId);
            postelResponse = HDT_SRV_DocumentalManagement.executeGetAttachmentCalloutRequest(body);
            baseSixtyFour = postelResponse.content;
            resultMap.put('outcome','OK');
            resultMap.put('base64', baseSixtyFour);
        }catch(Exception ex){
            resultMap.put('outcome','KO');
            resultMap.put('errorMessage', ex.getMessage());
        }
        return JSON.serialize(resultMap);
    }

    public static String resendDocusignEnvelope(String recordId){
        String body='';
        String result='';
        String responseCode;
        String responseStatus;
        Map<String,String> resultMap = new Map<String,String>();
        HDT_WRP_DocumentalResponse.HDT_WRP_IntesaResponse responseWrap = new HDT_WRP_DocumentalResponse.HDT_WRP_IntesaResponse();
        try{
            body = HDT_SRV_DocumentalManagement.generateResendDocusignEnvelopeRequest(recordId);
            responseWrap = HDT_SRV_DocumentalManagement.executeResendDocusignEnvelopeCalloutRequest(body);
            resultMap.put('outcome','OK');
        }catch(Exception ex){
            resultMap.put('outcome','KO');
            resultMap.put('errorMessage', ex.getMessage());
        }
        return JSON.serialize(resultMap);
    }

    public static String discardDocusignEnvelope(String recordId){
        String body='';
        String result='';
        String responseCode;
        String responseStatus;
        Map<String,String> resultMap = new Map<String,String>();
        HDT_WRP_DocumentalResponse.HDT_WRP_IntesaResponse responseWrap = new HDT_WRP_DocumentalResponse.HDT_WRP_IntesaResponse();
        try{
            body = HDT_SRV_DocumentalManagement.generateDiscardDocusignEnvelopeRequest(recordId);
            responseWrap = HDT_SRV_DocumentalManagement.executeDiscardDocusignEnvelopeCalloutRequest(body);
            resultMap.put('outcome','OK');
        }catch(Exception ex){
            resultMap.put('outcome','KO');
            resultMap.put('errorMessage', ex.getMessage());
        }
        return JSON.serialize(resultMap);
    }

    public static void handleDocusignNotify(HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyRequest requestBody){
        String status;
        String envelopeId;
        String transactionId;
        String outcome;
        try {
            if(requestBody != null){
                status = requestBody.status;
                envelopeId = requestBody.envelopeId;
                outcome = requestBody.outcome;
                transactionId = HDT_SRV_DocumentalManagement.getTransactionId(envelopeId);
                SObject recordToUpdate = HDT_SRV_DocumentalManagement.getSobjectFromTransactionId(transactionId);
                if (outcome == 'KO'){
                    HDT_SRV_DocumentalManagement.logDocusignError(recordToUpdate, requestBody);
                } else {
                    HDT_SRV_DocumentalManagement.updateSobjectFromDocusign(recordToUpdate,requestBody);
                }
            }
        } catch (Exception ex) {
            System.debug('Error in method handleDocusignNotify ' + ex.getMessage());
        }
    }
}