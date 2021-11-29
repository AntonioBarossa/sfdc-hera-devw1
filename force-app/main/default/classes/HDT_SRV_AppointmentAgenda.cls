public with sharing class HDT_SRV_AppointmentAgenda {
    
    public string handleFirstSearch(Id activityId, Date preferedDate, String preferedTimeSlot){
        return this.handleSearch(activityId, preferedDate, preferedTimeSlot, HDT_UTL_AppointmentAgenda.requestType.FIRST_SEARCH);
    }

    public string handleNewSlot(Id activityId, Date preferedDate, String preferedTimeSlot){
        return this.handleSearch(activityId, preferedDate, preferedTimeSlot, HDT_UTL_AppointmentAgenda.requestType.NEW_SLOT);
    }

    public string handleNewSlotModify(Id activityId, Date preferedDate, String preferedTimeSlot){
        return this.handleSearch(activityId, preferedDate, preferedTimeSlot, HDT_UTL_AppointmentAgenda.requestType.EDIT);
    }

    public string handleConfirm(Id activityId,String appointmentCode){
        HDT_WRP_Appuntamento.HDT_WRP_RequestAppuntamento request = HDT_UTL_AppointmentAgenda.initAppointmentRequest(activityId, HDT_UTL_AppointmentAgenda.requestType.CONFIRM);
        HDT_UTL_AppointmentAgenda.setAppointmentCode(request, appointmentCode);
        HDT_WRP_Appuntamento.HDT_WRP_ResponseAppuntamento response = HDT_UTL_AppointmentAgenda.executeCallout(request);
        return HDT_UTL_AppointmentAgenda.manageResponse(response, activityId, HDT_UTL_AppointmentAgenda.requestType.CONFIRM);
    }

    public string handleCancellation(Id activityId,String appointmentCode){
        HDT_WRP_Appuntamento.HDT_WRP_RequestAppuntamento request = HDT_UTL_AppointmentAgenda.initAppointmentRequest(activityId, HDT_UTL_AppointmentAgenda.requestType.CANCELLATION);
        HDT_WRP_Appuntamento.HDT_WRP_ResponseAppuntamento response = HDT_UTL_AppointmentAgenda.executeCallout(request);
        return HDT_UTL_AppointmentAgenda.manageResponse(response, activityId, HDT_UTL_AppointmentAgenda.requestType.CANCELLATION);
    }

    private string handleSearch(Id activityId, Date preferedDate, String preferedTimeSlot,HDT_UTL_AppointmentAgenda.requestType reqType){
        HDT_WRP_Appuntamento.HDT_WRP_RequestAppuntamento request = HDT_UTL_AppointmentAgenda.initAppointmentRequest(activityId, reqType);
        HDT_UTL_AppointmentAgenda.setRequestFieldsForDateSearch(request, preferedDate, preferedTimeSlot);
        HDT_WRP_Appuntamento.HDT_WRP_ResponseAppuntamento response = HDT_UTL_AppointmentAgenda.executeCallout(request);
        return HDT_UTL_AppointmentAgenda.manageResponse(response, activityId, reqType); 
    }
}
