public class HDT_WS_RecallMeConfirmRequest extends HDT_WS_Request {
    @AuraEnabled Public Long timestamp;
    @AuraEnabled Public String appointmentType;
    @AuraEnabled Public Long idUser;
    @AuraEnabled Public String username;
    @AuraEnabled Public String ecid;
   // @AuraEnabled Public Integer phoneNumber;
    @AuraEnabled Public String communicationType;
   // @AuraEnabled Public String token;

   /* public HDT_WS_RecallMeRequest(String body){
        Map<String, Object> obj = (Map<String, Object>) JSON.deserializeUntyped(body);
        this.startRange = obj.get('startRange');
        this.endRange = obj.get('endRange');
        this.appointmentType = obj.get('appointmentType');
        this.idUser = obj.get('idUser');
        this.username = obj.get('username');
        this.ecid = obj.get('ecid');
        this.token = obj.get('token');
    }*/
}