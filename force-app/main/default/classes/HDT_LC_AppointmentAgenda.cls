/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 28-06-2022
 * @last modified by  : Giacinto Florio
**/
public with sharing class HDT_LC_AppointmentAgenda {
    
    private static HDT_SRV_AppointmentAgenda srvAgenda = new HDT_SRV_AppointmentAgenda();
    
    @AuraEnabled(cacheable=true)
    public static String getActivity(String activityId,List<String> fields){
        String response = '';
        try{
            response = srvAgenda.getActivity(activityId,fields);
        }catch (exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return response;
    }

    @AuraEnabled(cacheable=true)
    public static String getCommunityBaseUrl(){
        return srvAgenda.getCommunityLink();
    }
    
    @AuraEnabled
    public static String handleConfirm(String activityId,String appointmentJson) {
        String response = '';
        try{
            response = srvAgenda.handleConfirm(activityId,appointmentJson);
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

    @AuraEnabled
    public static String getEncryptedId(String activityId) {
        String response = '';
        try{
            response = srvAgenda.criptId(activityId);
        }catch (exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return response;
    }

    @AuraEnabled
    public static String getDecryptedId(String cryptedId,List<String> fields) {
        String response = '';
        try{
            response = srvAgenda.getCryptoActivity(cryptedId,fields);
        }catch (exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return response;
    }

}
