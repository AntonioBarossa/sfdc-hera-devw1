@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_SRV_MeterSearch {
    public static HDT_WRP_MeterSearchResponse executeCalloutRequest(String body){

        //DEBUG
		String debugString = 'HDT_SRV_MeterSearch - executeCalloutRequest';
		System.debug(LoggingLevel.DEBUG, debugString);

        HDT_WRP_MeterSearchResponse response = new HDT_WRP_MeterSearchResponse();

        try {
            
            response = HDT_WS_MeterSearch.submitRequest(body);
            System.debug(LoggingLevel.DEBUG, 'response: ' + JSON.serialize(response));

        } catch (Exception e) {
            System.debug(LoggingLevel.DEBUG, 'Exception: ' + e.getStackTraceString());
        }

        return response;
    }
}
