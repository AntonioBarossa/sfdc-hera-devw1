/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 19-07-2022
 * @last modified by  : Giacinto Florio
**/
@SuppressWarnings('PMD.ExcessiveParameterList, PMD.IfStmtsMustUseBraces, PMD.IfElseStmtsMustUseBraces, PMD.pmdAvoidDebugStatements, PMD.CyclomaticComplexity')
public with sharing class HDT_LC_AppointmentTariAgenda {
    
    private static HDT_SRV_AppointmentAgenda srvAgenda = new HDT_SRV_AppointmentAgenda();
    private static final String FIELDS_FOR_QUERY_CASE = 'Id, CaseNumber';

    public enum requestType {
        CANCELLATION,CONFIRM,EDIT,NEW_SLOT,FIRST_SEARCH
    }

    @AuraEnabled(cacheable=true)
    public static String getCase(String caseId,List<String> fields){
        String response = '';
        try{
            response = JSON.serialize(HDT_UTL_AppointmentAgenda.getCase(caseId,String.join(fields,',')));
        }catch (exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return response;
    }

    @AuraEnabled
    public static String handleConfirm(String caseId,String appointmentJson) { //questo
        String response = '';
        try{
            // HDT_WRP_Appuntamento.HDT_WRP_RequestAppuntamento request = initAppointmentRequestCase(caseId, requestType.CONFIRM);
            // Map<String,String> mapAppointment = (Map<String,String>) JSON.deserialize(appointmentJson, Map<String,String>.class);
            // HDT_WRP_Appuntamento.HDT_WRP_SlotAppuntamento appointment = new HDT_WRP_Appuntamento.HDT_WRP_SlotAppuntamento();
            // appointment.codiceApp = mapAppointment.get('codice');
            // appointment.appData = HDT_UTL_AppointmentAgenda.dateConverter(mapAppointment.get('data'));
            // appointment.appFasciaOrario = mapAppointment.get('fascia');
            // appointment.zLimApp= mapAppointment.get('dataLimite');
            // appointment.zLimAppOra = mapAppointment.get('oraLimite');
            // appointment.zStimaDurApp = mapAppointment.get('stima');
            // request.appData = appointment.appData;
            // request.appFasciaOrario = appointment.appFasciaOrario;
            // HDT_UTL_AppointmentAgenda.setAppointmentCode(request, appointment.codiceApp);

            //HDT_WRP_Appuntamento.HDT_WRP_ResponseAppuntamento response = HDT_UTL_AppointmentAgenda.executeCallout(request);
            // response = '{"data" : "31/12/2022","fascia" : "15:00/16:00","codice" : "2222","dataLimite" : "28/12/2021","oraLimite" : "19:00","stima" :"00:30:00"}';
            response = 'OK';
            return response;
        }catch (exception e){
            throw new AuraHandledException(e.getMessage());
        }
        // return response;
    }
    
    @AuraEnabled
    public static void handleNewActivityCreationAndCaseUpdate(String caseId, String caseFields, String templateName, String activityFields){    
        System.debug('caseId -> ' + caseId);
        System.debug('activityFields -> ' + JSON.deserializeUntyped(activityFields));
        System.debug('caseFields -> ' + JSON.deserializeUntyped(caseFields));

        Map<String,Object> activityObj = (Map<String,Object>)JSON.deserializeUntyped(activityFields);
        Map<String,Object> caseObj = (Map<String,Object>)JSON.deserializeUntyped(caseFields);

        System.debug('templateName ->' + templateName); 
        List<wrts_prcgvr__Activity__c> activitiesToInsert = null;
        
        if(templateName!=null){
            activitiesToInsert = HDT_UTL_Scarti.createActivityByObjectIdAndTemplateNameBulk(new List<String>{caseId}, templateName);
            for(wrts_prcgvr__Activity__c activity : activitiesToInsert){
                activity.wrts_prcgvr__IsRequired__c=true;
                if(JSON.deserializeUntyped(activityFields)!= null){
                    activity.AppointmentCode__c = (String) activityObj.get('appointmentCode');
                    activity.JobCenterCode__c = (String) activityObj.get('jobCenterCode');
                    activity.SotCode__c = (String) activityObj.get('sotCode');
                    activity.StartAppointment__c = Date.parse((String) activityObj.get('startAppointment'));
                    activity.EndAppointment__c = Date.parse((String) activityObj.get('endAppointment'));
                }
            }
        }

        if(JSON.deserializeUntyped(caseFields)!=null){
            Case theCase = [SELECT Id FROM Case WHERE Id =:caseId];
            if(theCase!=null){
                System.debug('theCase ->' + theCase);
                if((String) caseObj.get('appointmentCode') !=null)  theCase.AppointmentCode__c = (String) caseObj.get('appointmentCode');
                if((String) caseObj.get('jobCenterCode') !=null) theCase.JobCenterCode__c = (String) caseObj.get('jobCenterCode');
                if((String) caseObj.get('sotCode') !=null) theCase.SotCode__c = (String) caseObj.get('sotCode');
                if((String) caseObj.get('startAppointment') != null) theCase.StartAppointment__c = Date.parse((String) caseObj.get('startAppointment'));
                if((String) caseObj.get('endAppointment') != null) theCase.EndAppointment__c = Date.parse((String) caseObj.get('endAppointment'));
                if((String) caseObj.get('phase') != null) theCase.Phase__c = (String) caseObj.get('phase');
                if((String) caseObj.get('note') != null) theCase.Note__c = (String) caseObj.get('note');
                if((String) caseObj.get('outcome') != null) theCase.Outcome__c = (String) caseObj.get('outcome');
                
                HDT_UTL_DatabaseService.updateSObject(theCase);
            }
        }

        if(activitiesToInsert?.size()>0){
            System.debug('activitiesToInsert.size ->' + activitiesToInsert.size());
            HDT_UTL_DatabaseService.insertSObject(activitiesToInsert);
        }
    }

    @AuraEnabled
    public static void updateCase(List<Case> cases){ 
        if(cases?.size()>0){
            System.debug('cases.size ->' + cases.size());
            HDT_UTL_DatabaseService.insertSObject(cases);
        }
    }

    @AuraEnabled
    public static String handleView(String caseId) { //questo
        String response = '';
        try{
                //response = srvAgenda.handleFirstSearch(caseId,preferedDate,preferedTimeSlot);
                // return handleSearc(caseId, preferedDate, preferedTimeSlot, requestType.FIRST_SEARCH);
                // return '{"codCaus" : "test" ,"codFlusso" : "0160" ,"desEsitoConf" : "1" ,"documentkey" : "test" ,"errInvioDis" : "TEST MESSAGGIO DI ERRORE" ,"extAnnotazioni" : "test" ,"rifExt" : "xxx" ,"rifRich" : "x" ,"zCodCausApp" : "x" ,"zGestApp" : "0" ,"appuntamento" : [{"appData" : "2022-12-31","appFasciaOrario" : "15:00/16:00","codiceApp" : "2222","zLimApp" : "2022-12-28","zLimAppOra" : "19:00:00","zStimaDurApp" :"00:30:00"}]}';
                return '{"appuntamento" : {"id" : "1","tipo" : "Primo Appuntamento","inizio" : "2022-12-31","fine" : "2022-12-31"}}';
               
        }catch (exception e){
            throw new AuraHandledException(e.getMessage());
        }
        // return response;
    }

    @AuraEnabled
    public static String handleSearch(String caseId, String searchType, Date preferedDate, String preferedTimeSlot) { //questo
        String response = '';
        try{
                //response = srvAgenda.handleFirstSearch(caseId,preferedDate,preferedTimeSlot);
                // return handleSearc(caseId, preferedDate, preferedTimeSlot, requestType.FIRST_SEARCH);
                
                // Nessun Appuntamento Restituito
                //return '{"codCaus" : "test" ,"codFlusso" : "0160" ,"desEsitoConf" : "1" ,"documentkey" : "test" ,"errInvioDis" : "TEST MESSAGGIO DI ERRORE" ,"extAnnotazioni" : "test" ,"rifExt" : "xxx" ,"rifRich" : "x" ,"zCodCausApp" : "x" ,"zGestApp" : "0" ,"appuntamento" : []}';
               
                return '{"codCaus" : "test" ,"codFlusso" : "0160" ,"desEsitoConf" : "1" ,"documentkey" : "test" ,"errInvioDis" : "TEST MESSAGGIO DI ERRORE" ,"extAnnotazioni" : "test" ,"rifExt" : "xxx" ,"rifRich" : "x" ,"zCodCausApp" : "x" ,"zGestApp" : "0" ,"appuntamento" : [{"appData" : "2022-12-31","appFasciaOrario" : "15:00/16:00","codiceApp" : "2222","zLimApp" : "2022-12-28","zLimAppOra" : "19:00:00","zStimaDurApp" :"00:30:00"},{"appData" : "2022-12-31","appFasciaOrario" : "16:00/17:00","codiceApp" : "3333","zLimApp" : "2022-12-28","zLimAppOra" : "19:00:00","zStimaDurApp" :"00:30:00"},{"appData" : "2022-12-31","appFasciaOrario" : "17:00/18:00","codiceApp" : "4444","zLimApp" : "2022-12-28","zLimAppOra" : "19:00:00","zStimaDurApp" :"00:30:00"},{"appData" : "2022-12-31","appFasciaOrario" : "18:00/19:00","codiceApp" : "5555","zLimApp" : "2022-12-28","zLimAppOra" : "19:00:00","zStimaDurApp" :"00:30:00"},{"appData" : "2022-12-31","appFasciaOrario" : "19:00/20:00","codiceApp" : "6666","zLimApp" : "2022-12-28","zLimAppOra" : "19:00:00","zStimaDurApp" :"00:30:00"}]}';

        }catch (exception e){
            throw new AuraHandledException(e.getMessage());
        }
        // return response;
    }

    private static String handleSearc(Id caseId, Date preferedDate, String preferedTimeSlot,requestType reqType){ // MOCK
        HDT_WRP_Appuntamento.HDT_WRP_RequestAppuntamento request = initAppointmentRequestCase(caseId, reqType);
        HDT_UTL_AppointmentAgenda.setRequestFieldsForDateSearch(request, preferedDate, preferedTimeSlot);
        System.debug('request -> ' + request);
        // HDT_WRP_Appuntamento.HDT_WRP_ResponseAppuntamento response = HDT_UTL_AppointmentAgenda.executeCallout(request);
        // return manageResponse(response, caseId, reqType); 
       
       
        String bodyString = '{"codCaus" : "test" ,"codFlusso" : "0160" ,"desEsitoConf" : "1" ,"documentkey" : "test" ,"errInvioDis" : "TEST MESSAGGIO DI ERRORE" ,"extAnnotazioni" : "test" ,"rifExt" : "xxx" ,"rifRich" : "x" ,"zCodCausApp" : "x" ,"zGestApp" : "0" ,"appuntamento" : [{"appData" : "2022-12-31","appFasciaOrario" : "15:00/16:00","codiceApp" : "2222","zLimApp" : "2022-12-28","zLimAppOra" : "19:00:00","zStimaDurApp" :"00:30:00"},{"appData" : "2022-12-31","appFasciaOrario" : "16:00/17:00","codiceApp" : "3333","zLimApp" : "2022-12-28","zLimAppOra" : "19:00:00","zStimaDurApp" :"00:30:00"},{"appData" : "2022-12-31","appFasciaOrario" : "17:00/18:00","codiceApp" : "4444","zLimApp" : "2022-12-28","zLimAppOra" : "19:00:00","zStimaDurApp" :"00:30:00"},{"appData" : "2022-12-31","appFasciaOrario" : "18:00/19:00","codiceApp" : "5555","zLimApp" : "2022-12-28","zLimAppOra" : "19:00:00","zStimaDurApp" :"00:30:00"},{"appData" : "2022-12-31","appFasciaOrario" : "19:00/20:00","codiceApp" : "6666","zLimApp" : "2022-12-28","zLimAppOra" : "19:00:00","zStimaDurApp" :"00:30:00"}]}';
         Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(bodyString);
        // HDT_WRP_Appuntamento.HDT_WRP_ResponseAppuntamento response = new HDT_WRP_Appuntamento.HDT_WRP_ResponseAppuntamento();
        //return JSON.deserialize(JSON.serialize(responseBodyMap.get('responseAppuntamento')));
        return bodyString;
    }


    public static HDT_WRP_Appuntamento.HDT_WRP_RequestAppuntamento initAppointmentRequestCase(Id caseId,requestType requestMethod){
        HDT_WRP_Appuntamento.HDT_WRP_RequestAppuntamento appointment = new HDT_WRP_Appuntamento.HDT_WRP_RequestAppuntamento();
        Case caso = HDT_UTL_AppointmentAgenda.getCase(caseId,FIELDS_FOR_QUERY_CASE);
        appointment.documentkey = 'test';
        appointment.rifRich = 'test';
        String modApp = 'test';
        String codApp = 'test';
        String codFlusso = '0160';
        String esito = 'test';
        //String stato = 'test';
        
        appointment.codFlusso = codFlusso;
        appointment.modApp = modApp;
        appointment.codiceApp = codApp;
        appointment.desEsitoAttivita = esito;
        appointment.self = '';
        return appointment;
    }

    public static String manageResponse(HDT_WRP_Appuntamento.HDT_WRP_ResponseAppuntamento response,Id activityId,requestType requestMethod){
        return '';
    }

}