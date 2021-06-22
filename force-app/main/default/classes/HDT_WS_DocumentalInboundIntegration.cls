@RestResource(urlMapping='/DocumentalInboundServices/*')
global with sharing class HDT_WS_DocumentalInboundIntegration {
    @HttpPost
    webservice static void docusignNotify() {
        String body = RestContext.request.requestBody.toString();

        HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyRequest requestBody = (HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyRequest) JSON.deserialize(body, HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyRequest.class);
        
    }
}