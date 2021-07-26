public with sharing class HDT_LC_RecallMe {
    @AuraEnabled
    public static List<wrapReturn> postSlotRequest(DateTime startRange, String idUser, String username, String ecid){
        String nomeApi = 'postSlotRequest';
        Long startDate = startRange.getTime();
        Long endDate = startRange.addDays(1).getTime();
        String appointmentType = 'PERSONAL_PHONECALL';
        Datetime myNow = Datetime.now();
        Long gettimeMyNow = myNow.getTime();
        DateTime myDateTimeStandard = DateTime.newInstance(1970, 1, 1, 0, 0, 0);
        Long gettimeMyDateTimeStandard = myDateTimeStandard.getTime();
        Long token=967*(gettimeMyNow-gettimeMyDateTimeStandard);
        system.debug(Token);

       // Long token;
       HDT_WS_RecallMeRequest req = new HDT_WS_RecallMeRequest();
       req.startRange = startDate;
       req.endRange= endDate;
       req.appointmentType= appointmentType;
       req.idUser=idUser ;
       req.username= username;
       req.ecid= ecid;
     //  req.token= token + ;
     //   String body = '{"startRange":"'+startRange+'", "token":"'+token+'","endRange":"'+endRange+'", "appointmentType":"'+appointmentType+'", "idUser":"'+idUser+'", "username":"'+username+'", "ecid":"'+ecid+'"}';
        HDT_WS_RecallMeResponse wsCall = HDT_WS_RecallMe.postRecallMe(nomeApi, req);
        if (wsCall.status == 'success') {
            List<wrapReturn> resList = new List<wrapReturn>();
            
            for(HDT_WS_RecallMeResponse.HDT_WS_RecallMeResponseWrap r : wsCall.result){
                wrapReturn w = new wrapReturn();
                w.startDate = DateTime.newInstance(r.startTime);
                w.endDate = DateTime.newInstance(r.endTime);
                w.availability = r.availability;
                resList.add(w);
            }

            System.debug('- - - - - ' + wsCall.status); 
            return resList;
        } else {
            System.debug('Error: ' + wsCall.errorDetails);
            return null;
        }
        
        /*String nomeApi = 'postSlotRequest';
        String body = '{"startRange":"'+startRange+'", "endRange":"'+endRange+'", "appointmentType":"'+appointmentType+'", "idUser":"'+idUser+'", "username":"'+username+'", "ecid":"'+ecid+'"}';
        HDT_WS_Response wsCall = HDT_WS_RecallMe.postRecallMe(nomeApi, body);
        if (wsCall.status == 'success') {
            //System.debug('- - - - - ' + wsCall.body);
            return wsCall.status;
        } else {
            System.debug('Error: ' + wsCall.errorDetails);
            return ((String) wsCall.errorDetails);
        }*/
    }

    public class wrapReturn{
        @AuraEnabled public datetime startDate;
        @AuraEnabled public datetime endDate;
        @AuraEnabled public Integer availability;
    }
    
    @AuraEnabled
    public static String postAppointment(DateTime appointment, String appointmentType, Long idUser, String username, String ecid){
        String nomeApi = 'postAppointment';
        Long timestamp = appointment.getTime();
       // Long endDate = endRange.getTime();

        HDT_WS_RecallMeConfirmRequest req = new HDT_WS_RecallMeConfirmRequest();
        req.timestamp = Long.valueOf('1626798600000');//timestamp;
        req.appointmentType= appointmentType;
        req.idUser=idUser ;
        req.username= username;
        req.ecid= ecid;
        req.communicationType = 'CALL_AUTOMATIC';

        HDT_WS_Response wsCall = HDT_WS_RecallMe.postRecallMeAppointment(nomeApi, req);

        if (wsCall.status == 'success') {
            System.debug('- - - - - ' + wsCall.status); 
            return wsCall.status;
        } else {
            System.debug('Error: ' + wsCall.errorDetails);
            return ((String) wsCall.errorDetails);
        }
       // Long token;
       // String body = '{"startRange":"'+startRange+'", "token":"'+token+'","endRange":"'+endRange+'", "appointmentType":"'+appointmentType+'", "idUser":"'+idUser+'", "username":"'+username+'", "ecid":"'+ecid+'"}';
      /*  HDT_WS_Response wsCall = HDT_WS_RecallMe.postRecallMe(nomeApi, body);
        if (wsCall.status == 'success') {
            System.debug('- - - - - ' + wsCall.status);
            return wsCall.status;
        } else {
            System.debug('Error: ' + wsCall.errorDetails);
            return ((String) wsCall.errorDetails);
        }*/
    }
}