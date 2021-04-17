public with sharing class HDT_SRV_DocumentalManagementFacade {
    public static String getBase64(String recordId,String context,String formParams){
        String base64 = '';
        HDT_WRP_DocumentalResponse documentalResponse = new HDT_WRP_DocumentalResponse();
        try{
            documentalResponse = HDT_SRV_DocumentalManagement.generateRequest(recordId, context, formParams);
            base64 = documentalResponse.deliverPackageResponse.composedDocument;
        }catch(Exception ex){
            base64 = ex.getMessage();
        }
        return base64;
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