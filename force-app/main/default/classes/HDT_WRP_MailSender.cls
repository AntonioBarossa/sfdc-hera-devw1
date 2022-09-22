@SuppressWarnings('PMD.ExcessivePublicCount')
public class HDT_WRP_MailSender {

    public class HDT_WRP_Result {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public HDT_WRP_MailData mailData;
        @AuraEnabled public List<HDT_WRP_PicklistObj> templateList;
    }

    public class HDT_WRP_MailData {
        @AuraEnabled public String orgWideEmailAddressId;
        @AuraEnabled public Id caseId;
        @AuraEnabled public String sender;
        @AuraEnabled public String receiver;
    }

    public class HDT_WRP_PicklistObj {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }

    public class HDT_WRP_BodyMail {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public String bodyMail;
        @AuraEnabled public String receiver;
    }

    public class HDT_WRP_SendMailResult {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
    }

    public class HDT_WRP_MailStructure {
        public String orgWideAddId;
        public String bodyMail;
        public String toAddress;
    }

    public class HDT_WRP_GenerateCaseResult {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public Id caseId;
    }

}