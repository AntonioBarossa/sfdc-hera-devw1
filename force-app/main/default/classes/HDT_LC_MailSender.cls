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
    public static HDT_WRP_MailSender.HDT_WRP_BodyMail getBodyMailMerged(String templateName, Id templateId, Id recordId){
        return HDT_UTL_MailSenderHelper.getBodyMailMerged(templateName, templateId, recordId);
    }

    @AuraEnabled
    public static HDT_WRP_MailSender.HDT_WRP_SendMailResult sendMail(String mailStructure){
        return HDT_UTL_MailSenderHelper.sendMailHelper(mailStructure);
    }

    @AuraEnabled
    public static List<ContentDocument> getContentDocs(Id arecordId){
        return HDT_UTL_MailSenderHelper.getContentDocs(arecordId);
    }

    @AuraEnabled
    public static void deletePendingFiles(List<Id> cdIdList){
        HDT_UTL_MailSenderHelper.deletePendingFiles(cdIdList);
    }

    @AuraEnabled
    public static Decimal getContentSizeAttachments(List<Id> cdIdList){
        return HDT_UTL_MailSenderHelper.getContentSizeAttachments(cdIdList);
    }

}