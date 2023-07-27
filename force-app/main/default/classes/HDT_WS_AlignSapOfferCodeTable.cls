public with sharing class HDT_WS_AlignSapOfferCodeTable {
    
    public static String PATH = '';
    public static String NAMEDCREDENTIAL = 'MulesoftBasePath';

    public static HDT_WRP_AlignSapOfferCodeTable.HDT_WRP_AlignSapOfferCodeTableResponse doCallout (HDT_WRP_AlignSapOfferCodeTable.HDT_WRP_AlignSapOfferCodeTableRequest req){

        HDT_WRP_AlignSapOfferCodeTable.HDT_WRP_AlignSapOfferCodeTableResponse response = new HDT_WRP_AlignSapOfferCodeTable.HDT_WRP_AlignSapOfferCodeTableResponse();
        HTTP h = new Http();
        HTTPRequest reqToSend = new HTTPRequest();
        reqToSend.setTimeout(120000); 
        reqToSend.setHeader('Content-type', 'application/json');
        reqToSend.setEndpoint('Callout:'+NAMEDCREDENTIAL+PATH);
        reqToSend.setMethod('POST');
        reqToSend.setBody(JSON.serialize(req));

        String body = '';
        Integer statusCode = 0;
        try{
            HTTPResponse res = h.send(reqToSend);
            if (res != null){
                body = res.getBody();
                statusCode = res.getStatusCode();
                response = (HDT_WRP_AlignSapOfferCodeTable.HDT_WRP_AlignSapOfferCodeTableResponse)JSON.deserialize(body, HDT_WRP_AlignSapOfferCodeTable.HDT_WRP_AlignSapOfferCodeTableResponse.class);
            }
            return response;
        }catch(Exception ex){
            HDT_UTL_IntegrationLog.handleGenericErrorRequest(JSON.serialize(req), 'doCallout', 'Exception send callout', 'HDT_WS_AlignSapOfferCodeTable', '');
            return response;
        }
    }
}