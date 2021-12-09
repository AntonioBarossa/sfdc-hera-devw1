public with sharing class HDT_LC_AppointmentAgenda {
    
    private static HDT_SRV_AppointmentAgenda srvAgenda = new HDT_SRV_AppointmentAgenda();
    
    @AuraEnabled
    public static String handleConfirm(String activityId,String appointmentCode) {
        String response = '';
        try{
            response = srvAgenda.handleConfirm(activityId,appointmentCode);
        }catch (exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return response;
    }

    @AuraEnabled
    public static String handleCancellation(String activityId,String appointmentCode) {
        String response = '';
        try{
            response = srvAgenda.handleCancellation(activityId,appointmentCode);
        }catch (exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return response;
    }

    @AuraEnabled
    public static String handleSearch(String activityId, String searchType, Date preferedDate, String preferedTimeSlot) {
        String response = '';
        try{
            switch on searchType {
                when  'FirstSearch'{
                    response = srvAgenda.handleFirstSearch(activityId,preferedDate,preferedTimeSlot);
                }
                when  'NewSlot'{
                    response = srvAgenda.handleNewSlot(activityId,preferedDate,preferedTimeSlot);
                }
                when 'NewSlotModify' {
                    response = srvAgenda.handleNewSlotModify(activityId,preferedDate,preferedTimeSlot);
                }
            }
        }catch (exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return response;
    }

}
