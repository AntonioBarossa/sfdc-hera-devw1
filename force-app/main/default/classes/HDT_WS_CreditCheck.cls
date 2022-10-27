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
        if(System.isBatch()){
            req.userId = 'Caricatore.Massivo';
        }else {
            req.userId = UserInfo.getName()?.replace(' ','.');
        }
        
        //req.sistema = 'Standard'.equalsIgnoreCase(UserInfo.getUserType())? 'SFDC' : 'COMMUNITY';
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
            if ('failed'.equalsIgnoreCase(res?.status)) {
                orderData.orderId = req.crmId;
                Set<String> errorMessageList = new Set<String>();
                String codiceErrore = '';
                Boolean isOk = false;
                List<HDT_WS_CreditCheckResponse.HDT_WRP_errorResponseObject> items = res.errorDetails != null ? res.errorDetails : new List<HDT_WS_CreditCheckResponse.HDT_WRP_errorResponseObject>();
                for (HDT_WS_CreditCheckResponse.HDT_WRP_errorResponseObject item : items){
                    if (item != null && item.message != null && !item.message.isEmpty()){
                        for (String keyMessage : item.message.keySet()){
                            String message = String.isBlank(item.message.get(keyMessage))? '' : item.message.get(keyMessage);
                            switch on keyMessage?.toUpperCase() {
                                when  'ERROR_CODE'{
                                    isOk = HDT_UTL_CreditCheck.managedErrorCode(message);
                                    codiceErrore = message+' - ';
                                }
                                when else {
                                    errorMessageList.add(message); 
                                }
                            }
                        }
                    }
                }
                errorMessageList.remove('');
                if (!errorMessageList.isEmpty()){
                    String testMessage = codiceErrore + String.join((Iterable<String>)errorMessageList, ' \n');
                    orderData.outcomeDescription = (isOk) ? testMessage : 'KO Tecnico - ' + testMessage;
                    orderData.outcome = (isOK)? 'OK' : 'KO';
                }
            }else if (String.isNotBlank(res?.exceptionMessage)){
                orderData.orderId = req.crmId;
                orderData.outcomeDescription =  'KO Tecnico - Errore Generico - ' + res.exceptionMessage;
                orderData.outcome = 'OK';
                HDT_UTL_CreditCheck.insertCalloutLog(JSON.serialize(req), JSON.serialize(res));
            }else{
                //Gestione Credit Check In Progress 
                HDT_UTL_DatabaseService.updateSObject(new Order(Id = req.crmId, CreditCheckInProgress__c = true));
            }

            if (!orderData.isEmpty()){
                HDT_UTL_CreditCheck.updateOrder(new List<HDT_UTL_CreditCheck.HDT_WRP_DataForUpdate>{orderData});
            }
        }catch(Exception e){
            System.debug(LoggingLevel.DEBUG, 'HDT_WS_CreditCheck - HDT_WS_CreditCheckResponse - callService: exception ----> ' + e.getMessage());
        }
        
        return res;
    }

}