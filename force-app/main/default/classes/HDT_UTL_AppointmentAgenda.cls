/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 25-05-2022
 * @last modified by  : Giacinto Florio
**/
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
        String stato = String.isBlank(activity.wrts_prcgvr__Status__c)? '' : activity.wrts_prcgvr__Status__c;
        switch on requestMethod {
            when FIRST_SEARCH {
                codFlusso = '0160';
            }
            when NEW_SLOT {
                codFlusso = '0170';
                esito = '1';
                codApp = activity.AppointmentCode__c;
                modApp = STATE_FOR_APPMODE.contains(stato.toUpperCase()) ? 'X' : '';
            }
            when EDIT {
                codFlusso = '0185';
                codApp = activity.AppointmentCode__c;
            }
            when CONFIRM {
                codFlusso = '0170';
                esito = '0';
                modApp = STATE_FOR_APPMODE.contains(stato.toUpperCase()) ? 'X' : '';
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
            //formattedAppointment = appointmentDate.year()+'-'+month+'-'+day;
            formattedAppointment = day+'/'+month+'/'+appointmentDate.year();
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
        List<SObject> activities = HDT_QR_GenericQuery.getGenericRecords(fields, objectName, 'Id = \''+String.escapeSingleQuotes(activityId)+'\'');
        return (wrts_prcgvr__Activity__c)activities[0];
    }

    public static Case getCase(Id caseId,String fields){
        String objectName = 'Case';
        List<SObject> cases = HDT_QR_GenericQuery.getGenericRecords(fields, objectName, 'Id = \''+String.escapeSingleQuotes(caseId)+'\'');
        return (Case)cases[0];
    }

    public static wrts_prcgvr__Activity__c getCryptoActivity(String cryptedId,String fields){
        String objectName = 'wrts_prcgvr__Activity__c';
        List<SObject> activities = HDT_QR_GenericQuery.getGenericRecords(fields, objectName, 'CustomRecordId__c = \''+String.escapeSingleQuotes(cryptedId)+'\'');
        return (wrts_prcgvr__Activity__c)activities[0];
    }

    public static String manageResponse(HDT_WRP_Appuntamento.HDT_WRP_ResponseAppuntamento response,Id activityId,requestType requestMethod){
        return manageResponse(response,activityId,requestMethod,null);
    }

    public static String manageResponse(HDT_WRP_Appuntamento.HDT_WRP_ResponseAppuntamento response,Id activityId,requestType requestMethod,HDT_WRP_Appuntamento.HDT_WRP_SlotAppuntamento appointment){
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
                        activity.AppointmentDateToConfirm__c = Date.valueOf(formatDate(appuntamento.appData)); 
                        activity.wrts_prcgvr__Status__c = 'Presa appuntamento in corso';
                        activity.AppointmentCompetence__c = 'Vendita';
                        /* Verificare se vengono inviati
                        activity.MaxTimeModificationAppointment__c = appuntamento.zLimAppOra;
                        activity.MaxDateModificationAppointment__c = Date.valueOf(formatDate(appuntamento.zLimApp));
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
                    activity = getActivity(activityId,'Id,wrts_prcgvr__Status__c');
                    activity.MaxTimeModificationAppointment__c = appointment.zLimAppOra;
                    activity.MaxDateModificationAppointment__c = Date.valueOf(formatDate(appointment.zLimApp));
                    activity.AppointmentCode__c = appointment.codiceApp;
                    activity.AppoitmentTimeSlotConfirmed__c = appointment.appFasciaOrario;
                    activity.AppointmentDuration__c = appointment.zStimaDurApp;
                    activity.AppointmentDate__c = Date.valueOf(formatDate(appointment.appData));
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

    public static String handleEventOutcome(String appCode, String outcome, String note){
        String response = '';
        Id rtId = Schema.SObjectType.wrts_prcgvr__Activity__c.getRecordTypeInfosByDeveloperName().get('HDT_RT_DistributorAppointment').getRecordTypeId();
        String condition = 'AppointmentCode__c = \''+appCode+'\' AND RecordTypeId = \''+rtId+'\' AND wrts_prcgvr__Status__c NOT IN (\'Annullata\')';
        String fields = 'Id,wrts_prcgvr__Description__c,Order__c,Case__c,Distributor__c,ServicePoint__c,Account__c,Contact__c,isAtoa__c,RecordTypeId';
        List<SObject> activities = HDT_QR_GenericQuery.getGenericRecords(fields, 'wrts_prcgvr__Activity__c', condition);
        if (activities != null && !activities.isEmpty()){
            wrts_prcgvr__Activity__c activity = (wrts_prcgvr__Activity__c)activities[0];
            Boolean activtyToCloneInCreated = false;
            switch on outcome {
                when '0'{
                    //Chiudo quella vecchia e ne apro una nuova nel Queueable
                    activity.wrts_prcgvr__Status__c = 'Annullata';
                    activtyToCloneInCreated = true;
                }
                when '1','2','3'{
                    activity.AppointmentCompetence__c = 'Distributore';
                    activity.wrts_prcgvr__Status__c = 'Appuntamento di competenza Distributore';
                }
                when '4'{
                    activity.wrts_prcgvr__Status__c = 'Appuntamento eseguito';
                }
                when else {
                    activity = null;
                    response = 'Codice esito non valido. (Valore ricevuto: \''+outcome+'\', valori consentiti: \'0\',\'1\',\'2\',\'3\',\'4\')';
                }
            }
            if (activity != null){
                activity.AppointmentResultCode__c  = Integer.valueOf(outcome);
                if (String.isNotEmpty(activity.wrts_prcgvr__Description__c)){
                    activity.wrts_prcgvr__Description__c += ' '+note;
                }else{
                    activity.wrts_prcgvr__Description__c = note;
                }
                System.enqueueJob(new HDT_QBL_AppointmentActivityUpdate(activity,activtyToCloneInCreated));
            }
        }else{
            response = 'Appuntamento con codice \''+appCode+'\' non trovato.';
        }
        return response;
    }

    public static String handleSecondAppointmentConfirms(String processType, String codDistr, String appSlot, String appDate, String appCode){
        String response = '';
        wrts_prcgvr__Activity__c activity;
        String condition = '';
        switch on processType.toUpperCase() {
            when 'SALES' {
                condition = 'Order__r.DistributorPracticeCode__c = \''+codDistr+'\'';
            }
            when 'POSTSALES' {
                condition = 'Case__r.DistributorPracticeCode__c = \''+codDistr+'\'';
            }
            when else {
                response = 'Tipo processo non gestito. (Valore ricevuto: \''+processType+'\', valori consentiti: \'sales\',\'postSales\')';
            }
        }
        if (String.isNotEmpty(condition)){
            try{
                Id rtId = Schema.SObjectType.wrts_prcgvr__Activity__c.getRecordTypeInfosByDeveloperName().get('HDT_RT_DistributorAppointment').getRecordTypeId();
                List<SObject> activities = HDT_QR_GenericQuery.getGenericRecords('Id', 'wrts_prcgvr__Activity__c', condition + 'AND RecordTypeId = \''+rtId+'\' AND wrts_prcgvr__Status__c NOT IN (\'Completed\',\'Annullata\',\'Chiusa\',\'Appuntamento eseguito\',\'Appuntamento non eseguito\')');
                if (activities != null && !activities.isEmpty()){
                    activity = (wrts_prcgvr__Activity__c)activities[0];
                    activity.AppointmentDate__c = Date.valueOf(formatDate(appDate));
                    activity.AppoitmentTimeSlotConfirmed__c = appSlot;
                    activity.wrts_prcgvr__Status__c = 'Appuntamento confermato';
                    activity.AppointmentCode__c=appCode;
                    System.enqueueJob(new HDT_QBL_AppointmentActivityUpdate(activity));
                }else {
                    response = 'Nessun appuntamento associato al codice distributore \''+codDistr+'\'.';
                }
                
            }catch(Exception e){
                response = e.getMessage();
            }
        }
        return response;
    }

    public static Map<String,String> herokuRequestConverter(Map<String,String> herokuRequestMap){
        Map<String,String> newRequestMap = new Map<String,String>();
        Map<String,String> herokuKeysMap = HDT_UTL_AppointmentSetting.getResponseKeysMap();
        for (String oldKey : herokuKeysMap.keySet()){
            if (herokuRequestMap.containsKey(oldKey) && String.isNotBlank(herokuRequestMap.get(oldKey))){
                newRequestMap.put(herokuKeysMap.get(oldKey), herokuRequestMap.get(oldKey));
            }
        }
        return newRequestMap;
    }

    public static String updateActivity(wrts_prcgvr__Activity__c activity){
        String response = '';
        boolean isCommunity = false;
        if(activity != null){
            if (UserInfo.getUserType().toUpperCase().contains('GUEST')){
                isCommunity = true;
            }
            try{
                if (isCommunity) {
                    HDT_PEV_AppointmentAgenda__e activityEvent = new HDT_PEV_AppointmentAgenda__e();
                    activityEvent.Activity_JSON__c = JSON.serialize(activity);
                    Database.SaveResult sr = EventBus.publish(activityEvent);
                    if (!sr.isSuccess()) {
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

    public static void setContactData(wrts_prcgvr__Activity__c activity,Contact cont){
        if (cont != null){
            String fiscalCode = (cont.FiscalCode__c != null && cont.FiscalCode__c.startsWithIgnoreCase('it'))? cont.FiscalCode__c.substring(2) : cont.FiscalCode__c;
            if (String.isNotBlank(fiscalCode) && fiscalCode.isNumeric()){
                activity.VATNumber__c = fiscalCode;
            }else{
                activity.VATNumber__c = (String.isNotBlank(cont.VATNumber__c) && cont.VATNumber__c.startsWithIgnoreCase('it'))? cont.VATNumber__c.substring(2) : cont.VATNumber__c;
                activity.FiscalCode__c = cont.FiscalCode__c;
            }
        }
    }

    public static Blob criptId(Id idToCript){
        Blob key = Crypto.generateAesKey(128);
        Blob data = Blob.valueOf((String)idToCript);
        return Crypto.encryptWithManagedIV('AES128', key, data);
    }

    public static void updateExtraSystemAppointment(String nextPhase,Id recordId, String note, Map<String,String> mapActivityField){
        String objectName = 'wrts_prcgvr__Activity__c';
        String stato;
        if (nextPhase != null){
            switch on nextPhase.toLowerCase() {
                when 'esito ok da dl'{
                    stato = 'Appuntamento eseguito';
                }
                when 'esito ko da dl'{
                    stato = 'Appuntamento non eseguito';
                }
                when else {
                    return;
                }
            }
            string queryString = '';
            if(!note.containsIgnoreCase('SCADENZA TEMPI FISSAZIONE APPUNTAMENTO')){
                queryString = 'AND isAtoA__c = false ';
            }
            Id rtId = Schema.SObjectType.wrts_prcgvr__Activity__c.getRecordTypeInfosByDeveloperName().get('HDT_RT_DistributorAppointment').getRecordTypeId();
            List<SObject> activities = HDT_QR_GenericQuery.getGenericRecords('Id', objectName, '(Case__c = \''+recordId+'\' OR Order__c = \''+recordId+'\') AND RecordTypeId = \''+rtId+'\' '+queryString+'AND wrts_prcgvr__Status__c NOT IN (\'Chiusa\',\'Annullata\',\'Appuntamento eseguito\',\'Appuntamento non eseguito\')');
            if (!activities.isEmpty()){
                String endDate = mapActivityField.get('DATA_ELABORAZIONE');
                String cmp = mapActivityField.get('CMP');
                String utenza = mapActivityField.get('UTENZA');
                Date endDateVal = null;
                if(String.isNotBlank(endDate)){
                    endDateVal = Date.valueOf(endDate);
                }
                Datetime endDatetimeVal = null;
                if(String.isNotBlank(endDate)){
                    endDatetimeVal = Datetime.valueOf(endDate);
                }
                for (Sobject activity : activities){
                    activity.put('wrts_prcgvr__Status__c',stato);
                    activity.put('IsAppointmentToEdit__c',false);
                    activity.put('EndDate__c',endDateVal);
                    activity.put('ActivityEndTime__c',endDatetimeVal);
                    activity.put('ClosedByUsername__c',utenza);
                    activity.put('UserCompany__c',cmp);
                }
                System.enqueueJob(new HDT_QBL_AppointmentActivityUpdate(activities));
            }
        }
    }

    public static String dateConverter(String dateWrongFormat){
        String responseDate = dateWrongFormat;
        if (String.isNotEmpty(dateWrongFormat) && Pattern.matches('[0-9]{4}[-](0?[1-9]|[1][0-2])[-](0?[1-9]|[1-2][0-9]|[3][0-1])',dateWrongFormat)){
            List<String> dataArray = dateWrongFormat.split('-');
            responseDate = dataArray.get(2)+'/'+dataArray.get(1)+'/'+dataArray.get(0);
        }
        return responseDate;
    }
    
    private static String formatDate(String dateToWork){
        String newDate = dateToWork;
        if (String.isNotEmpty(dateToWork) && Pattern.matches('(0?[1-9]|[1-2][0-9]|[3][0-1])[//](0?[1-9]|[1][0-2])[//]\\d{4}', newDate)){
            List<String> dateInArray = newDate.split('/');
            String m = dateInArray[1].length() == 1? '0'+dateInArray[1]:dateInArray[1];
            String g = dateInArray[0].length() == 1? '0'+dateInArray[0]:dateInArray[0];
            newDate = dateInArray[2]+'-'+m+'-'+g;
        }
        return newDate;
    }

    private static void formatResponse(HDT_WRP_Appuntamento.HDT_WRP_ResponseAppuntamento response){
        if (response != null && response.appuntamento != null){
            for (HDT_WRP_Appuntamento.HDT_WRP_SlotAppuntamento appuntamento : response.appuntamento){
                appuntamento.appData = formatDate(appuntamento.appData);
                appuntamento.zLimApp = formatDate(appuntamento.zLimApp);
            }
        }
    }
}