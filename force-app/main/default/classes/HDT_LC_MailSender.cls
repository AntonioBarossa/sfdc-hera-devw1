@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_LC_MailSender {

    @AuraEnabled
    public static HDT_WRP_MailSender.HDT_WRP_Result getMetadata(Id recordId) {

        HDT_WRP_MailSender.HDT_WRP_GenerateCaseResult generateCaseResult;
        generateCaseResult = HDT_UTL_MailSenderHelper.generateNewCase(recordId);

        if(!generateCaseResult.success){
            HDT_WRP_MailSender.HDT_WRP_Result result = new HDT_WRP_MailSender.HDT_WRP_Result();
            result.success = false;
            result.message = generateCaseResult.message;
            return result;
        }

        return HDT_UTL_MailSenderHelper.getMetadataHelper(recordId, generateCaseResult.caseId);
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