/**
 * @author alessandro.picchiri@eng.it
 * @date 28/05/2021
 * @description  Classe che si occuperà di effettuare le chiamate al servizio esposto da mulesoft per la chiamata di EVALUATION CRM 
                 La classe popolerà l’input con i parametri del servizio di riferimento, recupererà l’endpoint specifico ed effettuerà la 
                 chiamata al servizio attraverso la classe “HDT_WS_HTTPServiceCall”. 
*/
public class HDT_WS_CreditCheck {
    private static final String REQUEST_PATH = '/credit-check/evaluations';

    @AuraEnabled
    public static HDT_WS_CreditCheckResponse callService(HDT_WS_CreditCheckRequest req){
        
        //HDT_WS_CreditCheckRequest req = (HDT_WS_CreditCheckRequest)json.deserialize(wrpVals, HDT_WS_CreditCheckRequest.class);
        
        System.debug(LoggingLevel.DEBUG, 'HDT_WS_CreditCheck - HDT_WS_CreditCheckResponse - callService: req ----> ');
        System.debug(LoggingLevel.DEBUG, JSON.serializepretty(req));
        
        HDT_WS_CreditCheckResponse res = (HDT_WS_CreditCheckResponse)HDT_WS_HTTPServiceCall.sendRequest('MulesoftBasePath',REQUEST_PATH,'POST', req,HDT_WS_CreditCheckResponse.class);
        
        System.debug(LoggingLevel.DEBUG, 'HDT_WS_CreditCheck - HDT_WS_CreditCheckResponse - callService: res ----> ' + JSON.serialize(res));
        
        return res;
    }

}