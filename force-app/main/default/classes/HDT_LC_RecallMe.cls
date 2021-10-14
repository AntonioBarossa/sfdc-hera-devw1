public with sharing class HDT_LC_RecallMe {
    public static HDT_QR_CampaignMember campaignMemberQr = new HDT_QR_CampaignMember();

    @AuraEnabled
    public static List<wrapReturn> postSlotRequest(String startRange, String campaignMemberId){
        system.debug(campaignMemberId);
        
        DateTime start = Datetime.valueOfGMT(startRange + ' 00:00:00');
        System.debug('******:' + start);
        CampaignMember cm = campaignMemberQr.getEcidById(campaignMemberId);
        system.debug(cm.Ecid__c);
        return postSlotRequestEcid(start,null,cm.reitekAgentUserId__c,cm.Ecid__c);
    }

    @AuraEnabled
    public static List<wrapReturn> postSlotRequestEcid(DateTime startRange, Long idUser, String username, String ecid){
        String nomeApi = 'postSlotRequest';
        Long startDate = startRange.getTime();
        Long endDate = startRange.addDays(1).getTime();
        String appointmentType = 'PERSONAL_PHONECALL';
        Datetime dt = Datetime.now();
      //  Long l = dt.getTime();
      //  system.debug(l);
      //  system.debug(DateTime.newInstance(l));
        Datetime myNow = Datetime.now();
        Long gettimeMyNow = myNow.getTime();
       // DateTime myDateTimeStandard = DateTime.newInstance(1970, 1, 1, 0, 0, 0);
       // Long gettimeMyDateTimeStandard = myDateTimeStandard.getTime();
        Long token=967*(gettimeMyNow);
        //system.debug(Token);

       // Long token;
       HDT_WS_RecallMeRequest req = new HDT_WS_RecallMeRequest();
       req.startRange = startDate;
       req.endRange= endDate;
       req.appointmentType= appointmentType;
       req.idUser=idUser ;
       req.username= username;
       req.ecid= ecid;
      // req.token= token + '';
     //   String body = '{"startRange":"'+startRange+'", "token":"'+token+'","endRange":"'+endRange+'", "appointmentType":"'+appointmentType+'", "idUser":"'+idUser+'", "username":"'+username+'", "ecid":"'+ecid+'"}';
        HDT_WS_RecallMeResponse wsCall = (HDT_WS_RecallMeResponse)HDT_WS_RecallMe.postRecallMe(nomeApi, req);
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
    public static boolean postAppointment(DateTime appointment, String appointmentType,String campaignMemberId){
        CampaignMember cm = campaignMemberQr.getEcidById(campaignMemberId);
        System.debug('HOAHOAHOAO:' + campaignMemberId);
        try{
            postAppointmentEcid(appointment,appointmentType, null, cm.reitekAgentUserId__c,cm.Ecid__c,campaignMemberId);
            return true;
        }catch(exception e){
            return false;
        }
    }
  // String campaignMemberId
    @AuraEnabled
    public static String postAppointmentEcid(DateTime appointment, String appointmentType, Long idUser, String username, String ecid,String campaignId){
        String nomeApi = 'postAppointment';
        Long timestamp = appointment.getTime();
       // Long endDate = endRange.getTime();

        HDT_WS_RecallMeConfirmRequest req = new HDT_WS_RecallMeConfirmRequest();
        req.timestamp = timestamp;
        req.appointmentType= appointmentType;
        req.idUser=idUser ;
        req.username= username;
        req.ecid= ecid;
        req.communicationType = 'CALL_AUTOMATIC';

        System.debug('HOLAAQUI' + req);
       HDT_WS_Response wsCall = HDT_WS_RecallMe.postRecallMeAppointment(nomeApi, req);

        if (wsCall.status == 'success') {
          System.debug('- - - - - ' + wsCall.status);
          CampaignMember cm = new CampaignMember();
          cm.id = campaignId;
          cm.status = 'Appuntamento telefonico personale';
          cm.isToSendStatusReitek__c = true;
          update cm;
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