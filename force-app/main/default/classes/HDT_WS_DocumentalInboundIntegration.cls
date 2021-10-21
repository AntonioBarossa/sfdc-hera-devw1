@RestResource(urlMapping='/DocumentalInboundServices/*')
global with sharing class HDT_WS_DocumentalInboundIntegration {
    @HttpPost
    webservice static void docusignNotify() {
        String body = RestContext.request.requestBody.toString();
        System.debug('DocumentalInboundServices input body: ' + body);

        HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyRequest requestBody = (HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyRequest) JSON.deserialize(body, HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyRequest.class);
        HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyResponse response = new HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyResponse();
        HDT_SRV_DocumentalManagementFacade.handleDocusignNotify(requestBody);
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(response));
        RestContext.response.headers.put('Content-Type', 'application/json');
    }
}