public with sharing class HDT_SRV_AppointmentAgenda {
    
    public String getActivity(Id activityId,List<String> fields){
        return JSON.serialize(HDT_UTL_AppointmentAgenda.getActivity(activityId,String.join(fields,',')));
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

    public String handleConfirm(Id activityId,String appointmentCode){
        HDT_WRP_Appuntamento.HDT_WRP_RequestAppuntamento request = HDT_UTL_AppointmentAgenda.initAppointmentRequest(activityId, HDT_UTL_AppointmentAgenda.requestType.CONFIRM);
        HDT_UTL_AppointmentAgenda.setAppointmentCode(request, appointmentCode);
        HDT_WRP_Appuntamento.HDT_WRP_ResponseAppuntamento response = HDT_UTL_AppointmentAgenda.executeCallout(request);
        return HDT_UTL_AppointmentAgenda.manageResponse(response, activityId, HDT_UTL_AppointmentAgenda.requestType.CONFIRM);
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
        System.debug('@@@@@input Map '+ JSON.serialize(inputMap));
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
                    response = HDT_UTL_AppointmentAgenda.handleSecondAppointmentConfirms(processType, codDistr, appSlot, appDate);
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
}
