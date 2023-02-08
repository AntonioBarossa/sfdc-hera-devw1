@SuppressWarnings('PMD.ExcessiveParameterList, PMD.AvoidDebugStatements')
public with sharing class HDT_LC_AdvancedMeterSearch {
    
    @AuraEnabled
    public static String searchMeterOnSap(String matricola, String servizio, String comune, String silos){
        try {

            String commodityCode = '';
            switch on servizio {
                when 'Gas' {
                    commodityCode = '10';
                }
                when 'Acqua' {
                    commodityCode = '11';
                }
                when 'Ambiente' {
                    commodityCode = '12';
                }
                when 'Energia Elettrica' {
                    commodityCode = '13';
                }
                when 'Teleriscaldamento' {
                    commodityCode = '14';
                }
            }

            HDT_WRP_MeterSearchRequest request = new HDT_WRP_MeterSearchRequest();
            request.commodity = commodityCode;
            request.matricola = matricola;
            request.location = comune;
            request.silos = silos;

            HDT_WRP_MeterSearchResponse response = new HDT_WRP_MeterSearchResponse();
            System.debug(LoggingLevel.DEBUG, 'Request: ' + json.serialize(request));
            String body = JSON.serialize(request);
            response = HDT_SRV_MeterSearch.executeCalloutRequest(body);
            if ('KO'.equalsIgnoreCase(response.data.esito)){
                throw newMessageException(response.data.responseMsg);
            }else{
                return JSON.serialize(response.data.etOut);
            }

        } catch (Exception e) {
            throw newMessageException(e.getMessage());
        }
    }

    private static AuraHandledException newMessageException(String message) {
        AuraHandledException e = new AuraHandledException(message);
        e.setMessage(message);
        return e;
    }
}
