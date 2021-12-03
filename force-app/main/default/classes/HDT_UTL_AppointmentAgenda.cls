public with sharing class HDT_UTL_AppointmentAgenda {
    public enum requestType {
        CANCELLATION,CONFIRM,EDIT,NEW_SLOT,FIRST_SEARCH
    }

    private static final String FIELDS_FOR_QUERY = 'Id,AppointmentCode__c,wrts_prcgvr__Status__c,Case__c,Order__c,Case__r.CaseNumber, Order__r.OrderNumber,Case__r.HerokuPracticeCode__c,Order__r.HerokuPracticeCode__c';
    private static final Set<String> STATE_FOR_APPMODE = new Set<String>{'APPUNTAMENTO CONFERMATO'};
    private static HDT_WS_AppointmentAgenda wsAgenda = new HDT_WS_AppointmentAgenda();

    public static HDT_WRP_Appuntamento.HDT_WRP_RequestAppuntamento initAppointmentRequest(Id activityId,requestType requestMethod){
        HDT_WRP_Appuntamento.HDT_WRP_RequestAppuntamento appointment = new HDT_WRP_Appuntamento.HDT_WRP_RequestAppuntamento();
        wrts_prcgvr__Activity__c activity = getActivity(activityId,FIELDS_FOR_QUERY);
        appointment.documentkey = activity.Case__c!= null ? activity.Case__r.HerokuPracticeCode__c : activity.Order__r.HerokuPracticeCode__c;
        appointment.rifRich = activity.Case__c!= null ? activity.Case__r.CaseNumber : activity.Order__r.OrderNumber;
        String modApp = '';
        String codApp = '';
        String codFlusso = '';
        String esito = '';
        String stato = String.isEmpty(activity.wrts_prcgvr__Status__c)? '' : activity.wrts_prcgvr__Status__c.toUpperCase();
        switch on requestMethod {
            when FIRST_SEARCH {
                codFlusso = '0160';
            }
            when NEW_SLOT {
                codFlusso = '0170';
                esito = '1';
                codApp = activity.AppointmentCode__c;
                modApp = STATE_FOR_APPMODE.contains(activity.wrts_prcgvr__Status__c) ? 'X' : '';
            }
            when EDIT {
                codFlusso = '0185';
                codApp = activity.AppointmentCode__c;
            }
            when CONFIRM {
                codFlusso = '0170';
                esito = '0';
                modApp = STATE_FOR_APPMODE.contains(activity.wrts_prcgvr__Status__c) ? 'X' : '';
            }
            when CANCELLATION {
                codFlusso = '0170';
                esito = '2';
                codApp = activity.AppointmentCode__c;
                modApp = 'X';
            }
        }
        appointment.codFlusso = codFlusso;
        appointment.modApp = modApp;
        appointment.codiceApp = codApp;
        appointment.desEsitoAttivita = esito;
        appointment.self = '';
        return appointment;
    }

    public static void setRequestFieldsForDateSearch(HDT_WRP_Appuntamento.HDT_WRP_RequestAppuntamento appointment,Date appointmentDate, String timeSlot){
        String formattedAppointment;
        if (appointmentDate != null){
            String day = (appointmentDate.day() > 9)? String.valueOf(appointmentDate.day()) : '0'+String.valueOf(appointmentDate.day());
            String month = (appointmentDate.month() > 9 )? String.valueOf(appointmentDate.month()) : '0'+ String.valueOf(appointmentDate.month());
            formattedAppointment = appointmentDate.year()+'-'+month+'-'+day;
        }
        appointment.appData = formattedAppointment;
        appointment.appFasciaOrario = timeSlot;
    }

    public static void setAppointmentCode(HDT_WRP_Appuntamento.HDT_WRP_RequestAppuntamento appointment, String appCode){
        appointment.codiceApp = appCode;
    }

    public static HDT_WRP_Appuntamento.HDT_WRP_ResponseAppuntamento executeCallout(HDT_WRP_Appuntamento.HDT_WRP_RequestAppuntamento appointment){
        HDT_WRP_Appuntamento.HDT_WRP_RequestAppuntamentoRoot request = new HDT_WRP_Appuntamento.HDT_WRP_RequestAppuntamentoRoot();
        request.requestAppuntamento = appointment;
        String body = JSON.serialize(request);
        HDT_WRP_Appuntamento.HDT_WRP_ResponseAppuntamento response = wsAgenda.executeRequest(body);
        return response;
    }

    public static wrts_prcgvr__Activity__c getActivity(Id activityId,String fields){
        String objectName = 'wrts_prcgvr__Activity__c';
        List<SObject> activities = HDT_QR_GenericQuery.getGenericRecords(fields, objectName, 'Id = \''+activityId+'\'');
        return (wrts_prcgvr__Activity__c)activities[0];
    }

    public static String manageResponse(HDT_WRP_Appuntamento.HDT_WRP_ResponseAppuntamento response,Id activityId,requestType requestMethod){
        wrts_prcgvr__Activity__c activity;
        String responseString = '';
        formatResponse(response);
        if (requestMethod.equals(requestType.CANCELLATION)){
            activity = new wrts_prcgvr__Activity__c();
            activity.Id = activityId;
            activity.wrts_prcgvr__Status__c = 'Annullata';
            responseString = 'OK';
        }else if ('0165'.equals(response.codFlusso)){
            responseString = JSON.serialize(response);
            if (requestMethod.equals(requestType.FIRST_SEARCH)){
                activity = new wrts_prcgvr__Activity__c();
                activity.Id = activityId;
                switch on response.zGestApp {
                    when '0' {
                        HDT_WRP_Appuntamento.HDT_WRP_SlotAppuntamento appuntamento = response.appuntamento[response.appuntamento.size()-1];
                        activity.AppointmentCode__c = appuntamento.codiceApp;
                        activity.AppointmentTimeSlotToConfirm__c = appuntamento.appFasciaOrario;
                        activity.AppointmentDateToConfirm__c = Date.valueOf(appuntamento.appData); 
                        activity.wrts_prcgvr__Status__c = 'Presa appuntamento in corso';
                        activity.AppointmentCompetence__c = 'Vendita';
                        /* Verificare se vengono inviati
                        activity.MaxTimeModificationAppointment__c = appuntamento.zLimAppOra;
                        activity.MaxDateModificationAppointment__c = Date.valueOf(appuntamento.zLimApp);
                        activity.AppointmentDuration__c = appuntamento.zStimaDurApp;
                        */
                            
                    }
                    when '1' {
                        responseString = 'COMPETENZA DISTRIBUTORE';
                        activity.AppointmentCompetence__c = 'Distributore';
                        activity.wrts_prcgvr__Status__c = 'Appuntamento di competenza Distributore';
                    }
                }
            }
        }else if ('0175'.equals(response.codFlusso)){
            switch on response.desEsitoConf {
                when '1' {
                    HDT_WRP_Appuntamento.HDT_WRP_SlotAppuntamento appuntamento = response.appuntamento[0];
                    activity = getActivity(activityId,'Id,wrts_prcgvr__Status__c');
                    activity.MaxTimeModificationAppointment__c = appuntamento.zLimAppOra;
                    activity.MaxDateModificationAppointment__c = Date.valueOf(appuntamento.zLimApp);
                    activity.AppointmentCode__c = appuntamento.codiceApp;
                    activity.AppoitmentTimeSlotConfirmed__c = appuntamento.appFasciaOrario;
                    activity.AppointmentDuration__c = appuntamento.zStimaDurApp;
                    activity.AppointmentDate__c = Date.valueOf(appuntamento.appData);
                    activity.wrts_prcgvr__Status__c = 'Appuntamento confermato'.equalsIgnoreCase(activity.wrts_prcgvr__Status__c)? 'Modifica confermata' : 'Appuntamento confermato';
                    responseString = 'OK'; 
                }
                when '0' {
                    responseString = 'ERRORE CONFERMA';
                }
            }
        }else if ('0190'.equals(response.codFlusso)){
            switch on response.desEsitoConf {
                when '1' {
                    responseString = JSON.serialize(response);
                }
                when '0' {
                    responseString = 'ERRORE MODIFICA';
                }
            }
        }
        String esitoUpdate = updateActivity(activity);
        if (String.isNotEmpty(esitoUpdate)){
            responseString = esitoUpdate;
        }
        return responseString;
    }

    private static String updateActivity(wrts_prcgvr__Activity__c activity){
        String response = '';
        boolean isCommunity = false;
        if(activity != null){
            system.debug('@@@@@Utenza community : ' + UserInfo.getUserType());
            if (UserInfo.getUserType().toUpperCase().contains('GUEST')){
                isCommunity = true;
            }
            try{
                if (isCommunity) {
                    HDT_PEV_AppointmentAgenda__e activityEvent = new HDT_PEV_AppointmentAgenda__e();
                    activityEvent.Activity_JSON__c = JSON.serialize(activity);
                    Database.SaveResult sr = EventBus.publish(activityEvent);
                    if (sr.isSuccess()) {
                        System.debug('Successfully published event.');
                    } else {
                        response = 'Error returned: ';
                        for(Database.Error err : sr.getErrors()) {
                            response += err.getStatusCode() +' - ' +err.getMessage()+'; ';
                        }
                    } 
                }else{
                    HDT_UTL_DatabaseService.updateSObject(activity);
                }
            }catch(Exception e){
                response = e.getMessage();
            }
        }
        return response;
    }

    private static void formatResponse(HDT_WRP_Appuntamento.HDT_WRP_ResponseAppuntamento response){
        if (response != null && response.appuntamento != null){
            for (HDT_WRP_Appuntamento.HDT_WRP_SlotAppuntamento appuntamento : response.appuntamento){
                if (String.isNotBlank(appuntamento.zLimApp)){
                    List<String> dataToWork = appuntamento.zLimApp.split('/');
                    appuntamento.zLimApp = dataToWork[2]+'-'+dataToWork[1]+'-'+dataToWork[0];
                }
                if (String.isNotBlank(appuntamento.appData)){
                    List<String> dataToWork = appuntamento.appData.split('/');
                    appuntamento.appData = dataToWork[2]+'-'+dataToWork[1]+'-'+dataToWork[0];
                }
            }
        }
    }
}
