@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_LC_MailSender {

    @AuraEnabled
    public static HDT_WRP_MailSender.HDT_WRP_Result getMetadata(Id recordId) {
        Boolean isReminder = HDT_UTL_MailSenderHelper.checkForReminderMail(recordId);
        if(isReminder){
            return HDT_UTL_MailSenderHelper.getReminderMetadataHelper(recordId);
        }
        return HDT_UTL_MailSenderHelper.getMetadataHelper(recordId);
        
    }

    @AuraEnabled
    public static HDT_WRP_MailSender.HDT_WRP_BodyMail getBodyMailMerged(Id templateId, Id recordId){
        return HDT_UTL_MailSenderHelper.getBodyMailMerged(templateId, recordId);
    }

    @AuraEnabled
    public static HDT_WRP_MailSender.HDT_WRP_SendMailResult sendMail(String mailStructure){
        return HDT_UTL_MailSenderHelper.sendMailHelper(mailStructure);
    }

}