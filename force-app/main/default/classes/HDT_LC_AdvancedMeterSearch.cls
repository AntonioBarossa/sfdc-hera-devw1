@SuppressWarnings('PMD.ExcessiveParameterList, PMD.AvoidDebugStatements')
public with sharing class HDT_LC_AdvancedMeterSearch {
    
    @AuraEnabled
    public static String searchMeterOnSap(String matricola, String servizio, String comune, String silos){
        try {

            HDT_WRP_MeterSearchRequest request = new HDT_WRP_MeterSearchRequest();
            request.commodity = servizio;
            request.matricola = matricola;
            request.location = comune;
            request.silos = silos;

            HDT_WRP_MeterSearchResponse response = new HDT_WRP_MeterSearchResponse();
            String body = JSON.serialize(request);
            response = HDT_SRV_MeterSearch.executeCalloutRequest(body);
            System.debug(LoggingLevel.DEBUG, JSON.serialize(response.data.etOut));
            return JSON.serialize(response.data.etOut);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
