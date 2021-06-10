public with sharing class HDT_SRV_DocumentalManagementFacade {
    public static String getBase64(String recordId,String context,String formParams){
        String base64 = '';
        String body='';
        HDT_WRP_DocumentalResponse documentalResponse = new HDT_WRP_DocumentalResponse();
        try{     
            body = HDT_SRV_DocumentalManagement.generateRequest(recordId, context, formParams);
            documentalResponse = HDT_SRV_DocumentalManagement.executeCalloutRequest(body,context);
            base64 = documentalResponse.deliverPackageResponse.composedDocument;
        }catch(Exception ex){
            base64 = ex.getMessage();
        }
        return base64;
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
}