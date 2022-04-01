public with sharing class HDT_WS_PaperProcessingFlowPost {
    public class PaperProcessingRequest extends HDT_WS_Request {
        public PaperProcessingRequest(String paperProcessingId) {
            this.paperProcessingId = paperProcessingId;
        }

        String paperProcessingId;
    }

    @InvocableMethod(callout=true description='Sends a single PaperProcessingId to MuleSoft, that will generate and forward the Sosel file.')
    public static List<String> sendPaperProcessing(List<String> paperProcessingId) {
        HDT_WS_Response res = HDT_WS_HTTPServiceCall.sendRequest(
            'MulesoftBasePath',
            '/paper-communications/files',
            'POST',
            new PaperProcessingRequest(paperProcessingId.get(0)),
            HDT_WS_Response.class 
        );

        return new List<String>{
            String.valueOf(res.statusCode) + ' ' + res.errorDetails + ' ' + res.exceptionMessage + ' ' + res.body
        };
    }
}