public inherited sharing class HDT_WRP_ComunicationsSearchList {

    public class HDT_WRP_WebServiceObj {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public String body;
    }

    public class HDT_WRP_ResponseObj {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public Boolean dataError;
        @AuraEnabled public String bodyBase64;
    }

}