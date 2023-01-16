@SuppressWarnings('PMD.ExcessivePublicCount')
public class HDT_WRP_MailSender {

    public class HDT_WRP_Result {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public Boolean isReminder;
        @AuraEnabled public HDT_WRP_MailData mailData;
        @AuraEnabled public List<HDT_WRP_PicklistObj> templateList;
    }

    public class HDT_WRP_MailData {
        @AuraEnabled public String orgWideEmailAddressId;
        @AuraEnabled public String sender;
        @AuraEnabled public String receiver;
        @AuraEnabled public String reminderBodyMail;
        @AuraEnabled public Integer reminderMailCounter;
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
        @AuraEnabled public Id caseId;
    }

    public class HDT_WRP_MailStructure {
        public Id recordId;
        public Boolean isReminder;
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