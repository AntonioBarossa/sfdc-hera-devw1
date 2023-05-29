/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 24-05-2022
 * @last modified by  : Giacinto Florio
**/
public with sharing class HDT_SRV_AppointmentAgenda {
    
    public String getActivity(Id activityId,List<String> fields){
        return JSON.serialize(HDT_UTL_AppointmentAgenda.getActivity(activityId,String.join(fields,',')));
    }

    public String getCase(Id caseId,List<String> fields){
        return JSON.serialize(HDT_UTL_AppointmentAgenda.getCase(caseId,String.join(fields,',')));
    }
    
    public String handleFirstSearch(Id activityId, Date preferedDate, String preferedTimeSlot){
        return this.handleSearch(activityId, preferedDate, preferedTimeSlot, HDT_UTL_AppointmentAgenda.requestType.FIRST_SEARCH);
    }

    public String handleNewSlot(Id activityId, Date preferedDate, String preferedTimeSlot){
        return this.handleSearch(activityId, preferedDate, preferedTimeSlot, HDT_UTL_AppointmentAgenda.requestType.NEW_SLOT);
    }

    public String handleNewSlotModify(Id activityId, Date preferedDate, String preferedTimeSlot){
        return this.handleSearch(activityId, preferedDate, preferedTimeSlot, HDT_UTL_AppointmentAgenda.requestType.EDIT);
    }

    public String handleConfirm(Id activityId,String appointmentJson){
        HDT_WRP_Appuntamento.HDT_WRP_RequestAppuntamento request = HDT_UTL_AppointmentAgenda.initAppointmentRequest(activityId, HDT_UTL_AppointmentAgenda.requestType.CONFIRM);
        Map<String,String> mapAppointment = (Map<String,String>) JSON.deserialize(appointmentJson, Map<String,String>.class);
        HDT_WRP_Appuntamento.HDT_WRP_SlotAppuntamento appointment = new HDT_WRP_Appuntamento.HDT_WRP_SlotAppuntamento();
        appointment.codiceApp = mapAppointment.get('codice');
        appointment.appData = HDT_UTL_AppointmentAgenda.dateConverter(mapAppointment.get('data'));
        appointment.appFasciaOrario = mapAppointment.get('fascia');
        appointment.zLimApp= mapAppointment.get('dataLimite');
        appointment.zLimAppOra = mapAppointment.get('oraLimite');
        appointment.zStimaDurApp = mapAppointment.get('stima');
        request.appData = appointment.appData;
        request.appFasciaOrario = appointment.appFasciaOrario;
        HDT_UTL_AppointmentAgenda.setAppointmentCode(request, appointment.codiceApp);
        HDT_WRP_Appuntamento.HDT_WRP_ResponseAppuntamento response = HDT_UTL_AppointmentAgenda.executeCallout(request);
        return HDT_UTL_AppointmentAgenda.manageResponse(response, activityId, HDT_UTL_AppointmentAgenda.requestType.CONFIRM,appointment);
    }


    public String handleCancellation(Id activityId,String appointmentCode){
        HDT_WRP_Appuntamento.HDT_WRP_RequestAppuntamento request = HDT_UTL_AppointmentAgenda.initAppointmentRequest(activityId, HDT_UTL_AppointmentAgenda.requestType.CANCELLATION);
        HDT_WRP_Appuntamento.HDT_WRP_ResponseAppuntamento response = HDT_UTL_AppointmentAgenda.executeCallout(request);
        return HDT_UTL_AppointmentAgenda.manageResponse(response, activityId, HDT_UTL_AppointmentAgenda.requestType.CANCELLATION);
    }

    private String handleSearch(Id activityId, Date preferedDate, String preferedTimeSlot,HDT_UTL_AppointmentAgenda.requestType reqType){
        HDT_WRP_Appuntamento.HDT_WRP_RequestAppuntamento request = HDT_UTL_AppointmentAgenda.initAppointmentRequest(activityId, reqType);
        HDT_UTL_AppointmentAgenda.setRequestFieldsForDateSearch(request, preferedDate, preferedTimeSlot);
        HDT_WRP_Appuntamento.HDT_WRP_ResponseAppuntamento response = HDT_UTL_AppointmentAgenda.executeCallout(request);
        return HDT_UTL_AppointmentAgenda.manageResponse(response, activityId, reqType); 
    }

    public String handleAppointmentUpdate(Map<String,String> inputMap){
        inputMap = HDT_UTL_AppointmentAgenda.herokuRequestConverter(inputMap);
        String response = '';
        if (inputMap.containsKey('flowCode')){
            String codFlusso = inputMap.get('flowCode');
            switch on codFlusso {
                when  '0200' {
                    String processType = inputMap.get('processType');
                    String codDistr = inputMap.get('distributorCode');
                    String appSlot = inputMap.get('appointmentSlot');
                    String appDate = inputMap.get('appointmentDate');
                    String appCode = inputMap.get('appointmentCode');
                    response = HDT_UTL_AppointmentAgenda.handleSecondAppointmentConfirms(processType, codDistr, appSlot, appDate, appCode);
                }
                when  '0210' {
                    String appCode = inputMap.get('appointmentCode');
                    String outcome = inputMap.get('outcome');
                    String note = inputMap.get('note');
                    response = HDT_UTL_AppointmentAgenda.handleEventOutcome(appCode, outcome, note);
                }
                when else {
                    response = 'Codice flusso non riconosciuto.';
                }
            }
        }else{
            response = 'Codice flusso obbligatorio.';
        }
        return response;  
    }

    public String criptId(Id idToCript){
        return EncodingUtil.base64Encode(HDT_UTL_AppointmentAgenda.criptId(idToCript));
    }

    public String getCryptoActivity(String encryptedId,List<String> fields){
        try{
            return JSON.serialize(HDT_UTL_AppointmentAgenda.getCryptoActivity(encryptedId,String.join(fields, ',')));
        }
        catch (Exception e){
            throw new HDT_UTL_HeraException('Appuntamento non trovato');        
        }
    }

    public void setContactData(wrts_prcgvr__Activity__c activity,Contact cont){
        HDT_UTL_AppointmentAgenda.setContactData(activity, cont);
    }

    public void updateExtraSystemAppointment(String nextPhase,Id recordId, String note, Map<String,String> mapActivityField){
        HDT_UTL_AppointmentAgenda.updateExtraSystemAppointment(nextPhase,recordId,note,mapActivityField);
    }

    public String getCommunityLink(){
        return HDT_UTL_AppointmentSetting.getCommunityLink(UserInfo.getOrganizationId());
    }
}
