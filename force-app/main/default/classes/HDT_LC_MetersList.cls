public inherited sharing class HDT_LC_MetersList {

    @AuraEnabled
    public static Object getDatatableStructure(){
        return HDT_SRV_MetersList.getDatatableStructure();
    }

    @AuraEnabled(continuation=true cacheable=true)
    public static Object startRequest(String recordId) {
        return HDT_SRV_MetersList.startRequest(recordId);
    }

    @AuraEnabled(cacheable=true)
    public static Object processResponse(List<String> labels, Object state) {
        System.debug(LoggingLevel.DEBUG, '>>> processResponse controller');
        HttpResponse response = Continuation.getResponse(labels[0]);
        return response.getBody();
    }

}