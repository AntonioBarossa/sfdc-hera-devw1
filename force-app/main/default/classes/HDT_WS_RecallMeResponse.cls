public with sharing class HDT_WS_RecallMeResponse extends HDT_WS_Response {
    @AuraEnabled Public List<HDT_WS_RecallMeResponseWrap> result {get;set;}

   public class HDT_WS_RecallMeResponseWrap{
        @AuraEnabled public Long startTime {get;set;}
        @AuraEnabled public Long endTime {get;set;}
        @AuraEnabled public Integer availability {get;set;}
    }
}