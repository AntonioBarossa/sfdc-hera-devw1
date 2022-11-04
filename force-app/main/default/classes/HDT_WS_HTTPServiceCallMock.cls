/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 31/08/2021
 * @description HDT_WS_HTTPServiceCallMock Test Class
 * @history Lucas da Silva Fernandes – 31/08/2021 – Created Class
 */
public with sharing class HDT_WS_HTTPServiceCallMock implements HttpCalloutMock {
    
    public Boolean successfullReturn = true;

    public HTTPResponse respond(HTTPRequest req) {
        // system.debug('Marketing Cloud utils Mock');
         system.debug('endpoint ' + req.getEndpoint());
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String body;

        List<HDT_WebServiceConfiguration__c> webServiceConfigurations = HDT_WebServiceConfiguration__c.getAll().values();

        for(HDT_WebServiceConfiguration__c wsc : webServiceConfigurations) {
            if(req.getEndpoint() == wsc.Endpoint__c) {
                
                switch on wsc.Name {
                    when 'TransitorioWinback' {
                        HDT_WS_TransitionWinBack.HDT_WS_TransitionWinBackResponse transitionWbResponse = new HDT_WS_TransitionWinBack.HDT_WS_TransitionWinBackResponse();
                            
                        transitionWbResponse.result = new List<HDT_WS_TransitionWinBack.HDT_WS_TransitioneObj>();
                        transitionWbResponse.result.add(new HDT_WS_TransitionWinBack.HDT_WS_TransitioneObj());
        
                        if (successfullReturn) {
                            transitionWbResponse.result.get(0).status = 'in Corso';
                            
                            body = JSON.serialize(transitionWbResponse);
                            res.setStatusCode(200);
                            res.setBody(body);
                        } else {
                            res.setStatusCode(404);
                        }
        
                    } when 'VAS.Service26' {
        
                        HDT_WS_ArrichmentDataEntityResponse arrichimentoDatiResponse = new HDT_WS_ArrichmentDataEntityResponse();
        
                        if (successfullReturn) {
                            
                            body = JSON.serialize(arrichimentoDatiResponse);
                            res.setStatusCode(200);
                            res.setBody(body);
                        } else {
                            res.setStatusCode(400);
                        }
        
                    } when 'BP_CA' {
        
                        HDT_WS_RichCreBpCaResponse dataresponse = new HDT_WS_RichCreBpCaResponse();                 
                        dataresponse.data = new HDT_WS_RichCreBpCaResponse.dataResponseWrap();
        
                        if (successfullReturn) {
                            dataresponse.status = 'success';
                            dataresponse.data.tipoAttivita = 'Errore';
                            dataresponse.data.codiceBP = 'test'+Integer.valueof((math.random() * 1000));
                            dataresponse.data.commenti = 'BP non rilevato';
                            
                            body = JSON.serialize(dataresponse);
                            res.setStatusCode(200);
                            res.setBody(body);
                            
                            
                        } else {
                            res.setStatusCode(404);
                        }
        
                    } when 'CampagenDmDmpData' {
        
                        HDT_WS_CampagenDmDmpDataResponse campDataRes = new HDT_WS_CampagenDmDmpDataResponse();               
                        // dataresponse.data = new HDT_WS_RichCreBpCaResponse.dataResponseWrap();
        
                        if (successfullReturn) {
                            // dataresponse.status = 'success';
                            // dataresponse.data.tipoAttivita = 'Errore';
                            // dataresponse.data.codiceBP = 'test';
                            // dataresponse.data.commenti = 'BP non rilevato';
                            
                            body = JSON.serialize(campDataRes);
                            res.setStatusCode(200);
                            res.setBody(body);
                            
                            
                        } else {
                            res.setStatusCode(404);
                        }
        
                    } when 'postSlotRequest' {

                        HDT_WS_RecallMeResponse dataresponse = new HDT_WS_RecallMeResponse(); 
                        List<HDT_WS_RecallMeResponse.HDT_WS_RecallMeResponseWrap> reslt= new List<HDT_WS_RecallMeResponse.HDT_WS_RecallMeResponseWrap>(); 
                        HDT_WS_RecallMeResponse.HDT_WS_RecallMeResponseWrap resWrap= new HDT_WS_RecallMeResponse.HDT_WS_RecallMeResponseWrap();  
                        resWrap.startTime = Long.valueOf(String.valueOf(System.now().getTime()));
                        resWrap.endTime = Long.valueOf(String.valueOf(System.now().getTime()));
                        resWrap.availability = 9;
                        reslt.add(resWrap);
                        dataresponse.result = reslt;
                        dataresponse.status = 'success';
                        if (successfullReturn) {
                            body = JSON.serialize(dataresponse);
                            res.setStatusCode(200);
                            res.setBody(body);
                        } else {
                            res.setStatusCode(404);
                        }

                    } when 'postAppointment' {
						HDT_WS_RecallMeResponse dataresponse = new HDT_WS_RecallMeResponse(); 
                        List<HDT_WS_RecallMeResponse.HDT_WS_RecallMeResponseWrap> reslt= new List<HDT_WS_RecallMeResponse.HDT_WS_RecallMeResponseWrap>(); 
                        HDT_WS_RecallMeResponse.HDT_WS_RecallMeResponseWrap resWrap= new HDT_WS_RecallMeResponse.HDT_WS_RecallMeResponseWrap();  
                        resWrap.startTime = Long.valueOf(String.valueOf(System.now().getTime()));
                        resWrap.endTime = Long.valueOf(String.valueOf(System.now().getTime()));
                        resWrap.availability = 9;
                        reslt.add(resWrap);
                        dataresponse.result = reslt;
                        dataresponse.status = 'success';
                        if (successfullReturn) {
                            body = JSON.serialize(dataresponse);
                            res.setStatusCode(200);
                            res.setBody(body);
                            res.setStatus('success'); 
                        }else {
                            res.setStatusCode(404);
                        }

                    } when 'ArrichDataEntity' {
                        HDT_WS_Response customResp = (HDT_WS_Response)HDT_WS_ArrichmentDataEntityResponse.class.newInstance();
                        body = JSON.serialize(customResp);
                        res.setStatusCode(200);
                        res.setStatus('success');
                        res.setBody(body); 
                    } when 'AppointmentSearch' {
                        HDT_WS_Response customResp = (HDT_WS_Response)HDT_LC_AppointmentTariAgenda.HDT_WS_AppointmentSearchResponse.class.newInstance();
                        body = JSON.serialize(customResp);
                        res.setStatusCode(200);
                        res.setStatus('success');
                        res.setBody(body); 
                    } when 'AppointmentView' {
                        HDT_WS_Response customResp = (HDT_WS_Response)HDT_LC_AppointmentTariAgenda.HDT_WS_AppointmentViewResponse.class.newInstance();
                        body = JSON.serialize(customResp);
                        res.setStatusCode(200);
                        res.setStatus('success');
                        res.setBody(body); 
                    } when 'AppointmentConfirm' {
                        HDT_WS_Response customResp = (HDT_WS_Response)HDT_LC_AppointmentTariAgenda.HDT_WS_AppointmentConfirmResponse.class.newInstance();
                        body = JSON.serialize(customResp);
                        res.setStatusCode(200);
                        res.setStatus('success');
                        res.setBody(body); 
                    } when else {
        
                        res.setStatusCode(404);
                        
                    }
                }
            }
        }

        return res;
    }
}