/**
* @author Andrei Necsulescu (andrei.necsulescu@webresults.it)
* @date 13/04/2021
* @description HDT_SRV_SalesHandler - Class that holds business logic for MrrRequest Webservice
* @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
*/

public with sharing class HDT_SRV_SalesHandler {

    /**​
    * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)​
    * @date 13/04/2021
    * @description HDT_SRV_SalesHandler.manageSalesProcessCategory() – manage the requests of process category "sales"
    * @param request The request to be processed
    * @param mrrResponseItem the already initialized response item that needs to be returned at the end of the execution
    * @return the response item containing the result of the executed operations
    */

    public  HDT_WRP_MrrResponse.HDT_WRP_Response manageSalesProcessCategory(HDT_WRP_MrrRequest.HDT_WRP_Request request, HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem) {
        
        HDT_WRP_MrrResponse.HDT_WRP_Object responseObject = new HDT_WRP_MrrResponse.HDT_WRP_Object();

        HDT_WRP_MrrResponse.HDT_WRP_Field responseField = new HDT_WRP_MrrResponse.HDT_WRP_Field();
        HDT_WRP_MrrResponse.HDT_WRP_Field responseFieldError = new HDT_WRP_MrrResponse.HDT_WRP_Field();

        HDT_QR_Order orderQr = new HDT_QR_Order();
        HDT_SRV_Order orderSrv = new HDT_SRV_Order();
        HDT_WRP_MrrRequest.HDT_WRP_Header header = request.header;
		Map<String,String> mapRequestFields = new Map<String,String>();

        switch on header.requestType {
            when 'NOTIF_ES'{

                if (request.objects.get(0).fields.get(0) != null) {
				
                    For(HDT_WRP_MrrRequest.HDT_WRP_Field field : request.objects.get(0).fields){
                        if(mapRequestFields.get(field.name) == null){
                            mapRequestFields.put(field.name,field.value);
                        }
                        
                    }
                    
                    if(mapRequestFields.get('RECORD_ID')!= null && mapRequestFields.get('FASE')!= null){
                        
                        Order ordRetrieved = orderQr.getRecordByOrderNumber(mapRequestFields.get('RECORD_ID'))[0];

                        Order ord = new Order();
                        ord.Id = ordRetrieved.Id;
                        ord.Phase__c = mapRequestFields.get('FASE');

                        switch on mapRequestFields.get('FASE') {
                            when 'Ammissibilità KO' {
                                ord.DiscardReason__c = mapRequestFields.get('DES_ERR_AEEG');
                                ord.CausalCode__c = mapRequestFields.get('CODERR');
                                ord.HerokuPracticeCode__c = mapRequestFields.get('COD_PRAT_UTENTE');
                            }
                            when 'Ammissibilità OK' {
                                ord.HerokuPracticeCode__c = mapRequestFields.get('COD_PRAT_UTENTE');
                            }
                            when 'Esito KO da DL' {
                                ord.ReasonDL__c = mapRequestFields.get('TESTO_ERRR');
                                ord.HerokuPracticeCode__c = mapRequestFields.get('COD_PRAT_UTENTE');
                            }
                            when 'Esito OK da DL' {
                                ord.DistributorPracticeCode__c = mapRequestFields.get('COD_PRAT_DISTR');
                                ord.SapContractActivationDate__c = mapRequestFields.get('DT_INIZIO_VERT') != null ? Date.parse(mapRequestFields.get('DT_INIZIO_VERT')) : null;
                                ord.HerokuPracticeCode__c = mapRequestFields.get('COD_PRAT_UTENTE');
                            }
                            when 'Esito KO da SII' {
                                ord.PrecheckReasonSII__c = mapRequestFields.get('TESTO_ERRR');
                            }
                            when 'Esito OK da SII' {
                                if (ordRetrieved.PrecheckResultSII__c != null || ordRetrieved.PrecheckResultSII__c == '') {
                                    ord.PrecheckResultSII__c = 'OK';
                                }
                            }
                            when 'Errore lavorazione SAP' {
                                ord.DiscardReason__c = mapRequestFields.get('NOTE_ERR');
                                ord.HerokuPracticeCode__c = mapRequestFields.get('COD_PRAT_UTENTE');
                            }
                            when 'Completata' {
                                ord.Description = mapRequestFields.get('NOTA_HK');
                                ord.SAPImplantCode__c = mapRequestFields.get('ANLAGE');
                                ord.OrderODV__c = mapRequestFields.get('VBELN');
                                ord.SapContractCode__c = mapRequestFields.get('VERTRAG');
                                ord.HerokuPracticeCode__c = mapRequestFields.get('COD_PRAT_UTENTE');
                                
                                if(mapRequestFields.get('VKONT') != null) {
                                    ord.ContractAccountCode__c = mapRequestFields.get('VKONT');

                                    BillingProfile__c billingProfile = new BillingProfile__c();
                                    billingProfile.Id = ordRetrieved.BillingProfile__c;
                                    billingProfile.ContractAccountCode__c = mapRequestFields.get('VKONT');
                                    
                                    HDT_SRV_BillingProfile billingProfileSrv = new HDT_SRV_BillingProfile();
                                    billingProfileSrv.updateRecord(billingProfile);
                                }
                            }
                        }

                        orderSrv.updateRecord(ord);
                    	responseField.fieldType = 'TEXT';
                    	responseField.name = 'ESITO';
                    	responseField.value = 'OK';    
                    }else{
                        responseField.fieldType = 'TEXT';
                    	responseField.name = 'ESITO';
                    	responseField.value = 'OK';
                    }

                    responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField};
                    mrrResponseItem.objects.add(responseObject);
                    
                    RestContext.response.statusCode = 200;
                    
                } else {

                    responseField.fieldType = 'TEXT';
                    responseField.name = 'ESITO';
                    responseField.value = 'KO';

                    responseFieldError.fieldType = 'TEXT';
                    responseFieldError.name = 'ERROR_MESSAGE';
                    responseFieldError.value = 'There was an issue with your request message';

                    responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField, responseFieldError};
                    mrrResponseItem.objects.add(responseObject);

                    RestContext.response.statusCode = 400;

                }                        

            }
            when 'RICH_PASS' {

                if (request.objects.get(0).fields.get(0) != null){

                    responseField.fieldType = 'TEXT';
                    responseField.name = 'ESITO';
                    responseField.value = 'OK';
                    responseField.rds = '';
                    responseField.rdo = '';

                    responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField};
                    mrrResponseItem.objects.add(responseObject);
                    
                    RestContext.response.statusCode = 200;
                    
                } else {

                    responseField.fieldType = 'TEXT';
                    responseField.name = 'ESITO';
                    responseField.value = 'KO';

                    responseFieldError.fieldType = 'TEXT';
                    responseFieldError.name = 'ERROR_MESSAGE';
                    responseFieldError.value = 'There was an issue with your request message';

                    responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField, responseFieldError};
                    mrrResponseItem.objects.add(responseObject);

                    RestContext.response.statusCode = 400;

                }

            }
            when else {

                responseField.fieldType = 'TEXT';
                responseField.name = 'ESITO';
                responseField.value = 'KO';

                responseFieldError.fieldType = 'TEXT';
                responseFieldError.name = 'ERROR_MESSAGE';
                responseFieldError.value = 'Unsupported requestType';

                responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField, responseFieldError};
                mrrResponseItem.objects.add(responseObject);

                RestContext.response.statusCode = 400;

            }
        }

        return mrrResponseItem;
    }

}
