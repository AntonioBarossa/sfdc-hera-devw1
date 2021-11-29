public with sharing class HDT_UTL_AppointmentAgenda {
    public enum requestType {
        CANCELLATION,CONFIRM,EDIT,NEW_SLOT,FIRST_SEARCH
    }

    private static final Set<String> STATE_FOR_APPMODE = new Set<String>{'APPUNTAMENTO CONFERMATO'};
    private static HDT_WS_AppointmentAgenda wsAgenda = new HDT_WS_AppointmentAgenda();

    public static HDT_WRP_Appuntamento.HDT_WRP_RequestAppuntamento initAppointmentRequest(Id activityId,requestType requestMethod){
        HDT_WRP_Appuntamento.HDT_WRP_RequestAppuntamento appointment = new HDT_WRP_Appuntamento.HDT_WRP_RequestAppuntamento();
        wrts_prcgvr__Activity__c activity = getActivity(activityId);
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

    private static wrts_prcgvr__Activity__c getActivity(Id activityId){
        String fields = 'Id,AppointmentCode__c,wrts_prcgvr__Status__c,Case__c,Order__c,Case__r.CaseNumber, Order__r.OrderNumber,Case__r.HerokuPracticeCode__c,Order__r.HerokuPracticeCode__c';
        String objectName = 'wrts_prcgvr__Activity__c';
        List<SObject> activities = HDT_QR_GenericQuery.getGenericRecords(fields, objectName, 'Id = \''+activityId+'\'');
        return (wrts_prcgvr__Activity__c)activities[0];
    }

    public static String manageResponse(HDT_WRP_Appuntamento.HDT_WRP_ResponseAppuntamento response,Id activityId,requestType requestMethod){
        wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();
        activity.Id = activityId;
        String responseString = '';
        switch on requestMethod {
            when FIRST_SEARCH {
                HDT_WRP_Appuntamento.HDT_WRP_SlotAppuntamento appuntamento = response.appuntamento[response.appuntamento.size()-1];
                activity.AppointmentCode__c = appuntamento.codiceApp;
                activity.AppointmentTimeSlotToConfirm__c = appuntamento.appFasciaOrario;
                activity.AppointmentDateToConfirm__c = Date.valueOf(appuntamento.appData); 
                activity.wrts_prcgvr__Status__c = 'Presa appuntamento in corso';
                HDT_UTL_DatabaseService.updateSObject(activity);
                responseString = JSON.serialize(response);
            }
            when NEW_SLOT {
                responseString = JSON.serialize(response);
            }
            when EDIT {
                responseString = JSON.serialize(response);
            }
            when CONFIRM {
                HDT_WRP_Appuntamento.HDT_WRP_SlotAppuntamento appuntamento = response.appuntamento[0];
                activity.MaxTimeModificationAppointment__c = appuntamento.zLimAppOra;
                activity.MaxDateModificationAppointment__c = Date.valueOf(appuntamento.zLimApp);
                activity.AppointmentCode__c = appuntamento.codiceApp;
                activity.AppoitmentTimeSlotConfirmed__c = appuntamento.appFasciaOrario;
                activity.AppointmentDuration__c = appuntamento.zStimaDurApp;
                activity.AppointmentDate__c = Date.valueOf(appuntamento.appData);
                activity.wrts_prcgvr__Status__c = 'Appuntamento confermato';
                HDT_UTL_DatabaseService.updateSObject(activity);
                responseString = 'OK';
            }
            when CANCELLATION {
                activity.wrts_prcgvr__Status__c = 'Annullata';
                HDT_UTL_DatabaseService.updateSObject(activity);
                responseString = 'OK';
            }
        }
        return responseString;
    }
}
