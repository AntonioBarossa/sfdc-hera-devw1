@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_SRV_DocumentalManagementFacade {
    
    public static String getBase64(String recordId, String context, String formParams){
        
        String baseSixtyFour = '';
        String body='';
        String result='';
        String responseCode;
        String responseStatus;
        String message;
        String status;
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
            status = documentalResponse.responseStatus;
            resultMap.put('code',responseCode);
            resultMap.put('base64',baseSixtyFour);
            resultMap.put('result',result);
            resultMap.put('message',message);
            resultMap.put('status',status);
            HDT_SRV_DocumentalManagement.traceRequest(resultMap, body,recordId);
            /*
            system.debug(LoggingLevel.DEBUG,'body --> '+body);
            system.debug(LoggingLevel.DEBUG,'documentalResponse --> '+documentalResponse);
            system.debug(LoggingLevel.DEBUG,'baseSixtyFour --> '+baseSixtyFour);
            system.debug(LoggingLevel.DEBUG,'result --> '+result);
            system.debug(LoggingLevel.DEBUG,'responseCode --> '+responseCode);
            system.debug(LoggingLevel.DEBUG,'responseStatus --> '+responseStatus);
            system.debug(LoggingLevel.DEBUG,'message --> '+message);
            system.debug(LoggingLevel.DEBUG,'status --> '+status);
            system.debug(LoggingLevel.DEBUG,'recordId --> '+recordId);
            system.debug(LoggingLevel.DEBUG,'context --> '+context);
            system.debug(LoggingLevel.DEBUG,'formParams --> '+formParams);
            system.debug(LoggingLevel.DEBUG,'resultMap --> '+JSON.serialize(resultMap));
            */
        }
        catch(LimitException limitEx)
        {
            resultMap.put('result','000');
            resultMap.put('message','La dimesione del plico è superiore al limite consentito per la preview. Procedere con l\'invio dei documenti al cliente');
            resultMap.put('status','sizeLimit');
        }
        catch(Exception ex){
            resultMap.put('code','500');
        }

        if (recordId != null && (result != '000' || resultMap.get('code') == '500')) {
            System.debug(LoggingLevel.DEBUG, 'preview failed: ' + message);
            HDT_SRV_DocumentalManagement.logDiscardPhase(recordId);
        }

        return JSON.serialize(resultMap);
    }
    
    /*
    Invia Documento

    recordId: id record di cui si vuole [GESTIRE] la documentazione.
    context: utilizzato per determinare contesto documentale
    formParams: (serializzato) mappa di parametri utilizzata in vari punti.
    */
    public static void sendDocument(String recordId, String context, String formParams){
        
		//DEBUG
		String debugString = 'HDT_SRV_DocumentalManagementFacade - sendDocument';
		System.debug(LoggingLevel.DEBUG, debugString);
        
        String body='';
        /*
            @Author: Davide Viola - 19/10/2021
            Description: PMD -> Commentata variabile non utilizzata.
        */
        //HDT_WRP_DocumentalResponse documentalResponse = new HDT_WRP_DocumentalResponse();
        
        try{
            body = HDT_SRV_DocumentalManagement.generateRequest(recordId, context, formParams);
            if (context == 'EC' || context == 'GC') {
                HDT_SRV_DocumentalManagement.logEmailForAccountStatement(recordId, formParams);
            }
            HDT_SRV_DocumentalManagement.executeCalloutRequestFuture(body, context);

        } catch (Exception ex) {
            System.debug(LoggingLevel.DEBUG, 'exception at line ' + ex.getLineNumber() + ' ' + ex.getMessage());
        }
    }

    public static void sendDocumentAsync(String recordId, String context, String formParams){
        
		//DEBUG
		String debugString = 'HDT_SRV_DocumentalManagementFacade - sendDocumentAsync';
		System.debug(LoggingLevel.DEBUG, debugString);
        
        System.enqueueJob(new HDT_QBL_DocumentalManagement(recordId,context,formParams));
    }

    public static void sendAdvanceDocumentation(String recordId, String context, String formParams){
        
		//DEBUG
		String debugString = 'HDT_SRV_DocumentalManagementFacade - sendAdvanceDocumentation';
		System.debug(LoggingLevel.DEBUG, debugString);
        
        String baseSixtyFour = '';
        /*
            @Author: Davide Viola - 19/10/2021
            Description: PMD -> Commentata variabile non utilizzata.
        */
        //HDT_WRP_DocumentalResponse documentalResponse = new HDT_WRP_DocumentalResponse();
        Map<String,Object> formParamsMap = formParams != null? (Map<String,Object>) JSON.deserializeUntyped(formParams) : null;
        String tipoPlico = (String) formParamsMap.get('TipoPlico');
        String result = '';
        try{
            baseSixtyFour = getBase64(recordId, context, formParams);
            Map<String,Object> respMap = (Map<String,Object>) JSON.deserializeUntyped(baseSixtyFour);
            baseSixtyFour = (String) respMap.get('base64');
            result = (String) respMap.get('result');
            if(result == '000'){
                HDT_SRV_DocumentalManagement.createPublicLinkFuture(recordId,baseSixtyFour,tipoPlico);
            }
            
        } catch (Exception ex) {
            System.debug(LoggingLevel.DEBUG, ex.getMessage());
        }
    }
     

    public static String getSignSendMode(String processType, String source){
        String configurationJson = '';
        try{
            configurationJson = HDT_SRV_DocumentalManagement.getSignModeConfiguration(processType, source);
        }catch(Exception ex){
            configurationJson = ex.getMessage();
        }
        return configurationJson;
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
            System.debug(LoggingLevel.DEBUG, 'getInfoAccountStatement Exception TypeName: ' + ex.getTypeName());
            System.debug(LoggingLevel.DEBUG, 'getInfoAccountStatement Exception Message: ' + ex.getMessage());
            System.debug(LoggingLevel.DEBUG, 'getInfoAccountStatement Exception StackTraceString: ' + ex.getStackTraceString());
            return null;
            
        }
        return JSON.serialize(returnMap);
    }

    public static String showOriginalDocument(String recordId){
        String baseSixtyFour = '';
        String body='';
        /*
            @Author: Davide Viola - 19/10/2021
            Description: PMD -> Commentate variabili non utilizzate.
        */
        /*String context;
        String result='';
        String responseCode;
        String responseStatus;*/
        Map<String,String> resultMap = new Map<String,String>();
        HDT_WRP_DocumentalResponse.HDT_WRP_PostelResponse postelResponse = new HDT_WRP_DocumentalResponse.HDT_WRP_PostelResponse();
        try{
            SObject documentalObject = HDT_QR_DocumentalConfiguration.getDocumentalObjectById(recordId);
            String documentType = HDT_SRV_DocumentalManagement.getDocumentType(documentalObject);
            body = HDT_SRV_DocumentalManagement.generateGetEnvelopeRequest(documentalObject, documentType);
            postelResponse = HDT_SRV_DocumentalManagement.executeGetEnvelopeCalloutRequest(body, documentType);
            baseSixtyFour = postelResponse.content;
            List<String> baseSixtyFourList = postelResponse.contentList;
            resultMap.put('outcome','OK');
            resultMap.put('base64',baseSixtyFour);
            resultMap.put('type',  documentType);
            if ('zip'.equalsIgnoreCase(documentType) && baseSixtyFourList != null){
                resultMap.put('base64List', JSON.serialize(baseSixtyFourList));
            }
        }catch(Exception ex){
            resultMap.put('outcome','KO');
            resultMap.put('errorMessage', ex.getMessage());
        }
        return JSON.serialize(resultMap);
    }

    public static String showArchivedAttachment(String recordId){
        String baseSixtyFour = '';
        String body='';
        /*
            @Author: Davide Viola - 19/10/2021
            Description: PMD -> Commentate variabili non utilizzate.
        */
        /*String result='';
        String responseCode;
        String responseStatus;*/
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
        /*
            @Author: Davide Viola - 19/10/2021
            Description: PMD -> Commentate variabili non utilizzate.
        */
        /*String result='';
        String responseCode;
        String responseStatus;*/
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

    public static void checkEnvelopeForDiscard(String recordId, String formParams){
        //DEBUG
		String debugString = 'HDT_SRV_DocumentalManagementFacade - checkEnvelopeForDiscard';
		System.debug(LoggingLevel.DEBUG, debugString);
        Map<String,Object> formParamsMap = formParams != null? (Map<String,Object>) JSON.deserializeUntyped(formParams) : new Map<String,Object>();
        if (formParamsMap.containsKey('DiscardOldEnvelope') && (Boolean)formParamsMap.get('DiscardOldEnvelope')){
            String queryString = 'SELECT Id,Case__c,Order__c FROM DocumentSendTracking__c WHERE (Case__c = \''+recordId+'\' OR Order__c = \''+recordId+'\')';
            String objectName = 'DocumentSendTracking__c';
            List<SObject> documentSendTrackingList = HDT_QR_GenericQuery.getGenericRecords(queryString, objectName);
            if (documentSendTrackingList != null && documentSendTrackingList.size() > 0){
                System.enqueueJob(new HDT_QBL_DiscardDocusignEnvManagement((String)documentSendTrackingList[0].get('Id'),(String)documentSendTrackingList[0].get('Case__c'),(String)documentSendTrackingList[0].get('Order__c')));
            }
        }
    }

    public static String discardDocusignEnvelope(String recordId){
        String body='';
        /*
            @Author: Davide Viola - 19/10/2021
            Description: PMD -> Commentate variabili non utilizzate.
        */
        /*String result='';
        String responseCode;
        String responseStatus;*/
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
                // I KO da mulesoft contengono direttamente il transactionId di Engage1 nel body.
                if (String.isBlank(transactionId) && String.isNotBlank(envelopeId)){
                    transactionId = envelopeId;
                }
                SObject recordToUpdate = HDT_SRV_DocumentalManagement.getSobjectFromTransactionId(transactionId);
                if ((outcome == 'KO') || (outcome == 'OK' && requestBody.status == 'voided')){
                    HDT_SRV_DocumentalManagement.logDocusignError(recordToUpdate, requestBody);
                } else {
                    HDT_SRV_DocumentalManagement.updateSobjectFromDocusign(recordToUpdate,requestBody, transactionId);
                    // creazione act documentale spostata in updateSobjectFromDocusign
                    //HDT_SRV_DocumentalManagement.createIntesaDocumentalActivity(recordToUpdate,requestBody,transactionId);
                }
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.DEBUG, 'Error in method handleDocusignNotify ' + ex.getMessage());
        }
    }

    public static String handleContactPoint(String email,String phone, String contactId,String mode){
        if(String.isBlank(mode) || String.isBlank(contactId))return'KO';
        String result;
        switch on mode {
            when 'query' {
                result = HDT_SRV_DocumentalManagement.queryContactPoint(email,phone,contactId);
            }
            when else {
                result = HDT_SRV_DocumentalManagement.createContactPoint(email,phone,contactId);
            }
        }
        return result;
    }
}