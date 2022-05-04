/**
 * @author alessandro.picchiri@eng.it
 * @date 28/05/2021
 * @description  Classe che si occuperà di effettuare le chiamate al servizio esposto da mulesoft per la chiamata di EVALUATION CRM 
                 La classe popolerà l’input con i parametri del servizio di riferimento, recupererà l’endpoint specifico ed effettuerà la 
                 chiamata al servizio attraverso la classe “HDT_WS_HTTPServiceCall”. 
*/
@SuppressWarnings('PMD.AvoidDebugStatements')
public class HDT_WS_CreditCheck {
    private static final String REQUEST_PATH = '/credit-check/evaluations';

    @AuraEnabled
    public static HDT_WS_CreditCheckResponse callService(HDT_WS_CreditCheckRequest req){
        
        //HDT_WS_CreditCheckRequest req = (HDT_WS_CreditCheckRequest)json.deserialize(wrpVals, HDT_WS_CreditCheckRequest.class);
        
        System.debug(LoggingLevel.DEBUG, 'HDT_WS_CreditCheck - HDT_WS_CreditCheckResponse - callService: req ----> ');
        if (String.isNotEmpty(req.bpClass) && req.bpClass.containsIgnoreCase('Marcatura nulla')){
            req.bpClass = '';
        }
        System.debug(LoggingLevel.DEBUG, JSON.serializepretty(req));
        
        HDT_WS_CreditCheckResponse res = (HDT_WS_CreditCheckResponse)HDT_WS_HTTPServiceCall.sendRequest('MulesoftBasePath',REQUEST_PATH,'POST', req,HDT_WS_CreditCheckResponse.class);
        
        System.debug(LoggingLevel.DEBUG, 'HDT_WS_CreditCheck - HDT_WS_CreditCheckResponse - callService: res ----> ' + JSON.serialize(res));

        try{
            HDT_UTL_CreditCheck.HDT_WRP_DataForUpdate orderData = new HDT_UTL_CreditCheck.HDT_WRP_DataForUpdate();
            orderData.outcomeDescription = '';
            if ('failed'.equalsIgnoreCase(res.status) && res.errorDetails != null) {
                Set<String> errorMessageList = new Set<String>();
                for (HDT_WS_CreditCheckResponse.HDT_WRP_errorResponseObject item : res.errorDetails){
                    if (!item.message.isEmpty()){
                        for (String singleMessage : item.message.values()){
                            if (String.isNotBlank(singleMessage)){
                                errorMessageList.add(singleMessage);
                            }
                        }
                    }
                }
                if (!errorMessageList.isEmpty()){
                    orderData.outcomeDescription = 'KO Tecnico - ' + String.join((Iterable<String>)errorMessageList, ' \n');
                    orderData.outcome = 'KO';
                }
            }else if (String.isNotBlank(res.exceptionMessage)){
                orderData.outcomeDescription =  'KO Tecnico - ' + res.exceptionMessage;
                orderData.outcome = 'KO';
            }

            if ('KO'.equalsIgnoreCase(orderData.outcome)){
                orderData.orderId = req.crmId;
                HDT_UTL_CreditCheck.updateOrder(new List<HDT_UTL_CreditCheck.HDT_WRP_DataForUpdate>{orderData});
            }
        }catch(Exception e){
            System.debug(LoggingLevel.DEBUG, 'HDT_WS_CreditCheck - HDT_WS_CreditCheckResponse - callService: exception ----> ' + e.getMessage());
        }
        
        return res;
    }

}