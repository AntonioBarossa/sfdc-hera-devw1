public inherited sharing class HDT_QR_MailSender {

    public static List<Folder> getFolderList(String folderName){
        return [
            SELECT Id
            FROM Folder
            WHERE Name = :folderName
            WITH SECURITY_ENFORCED
        ];
    }

    public static List<EmailTemplate> getEmailTemplateList(Id folderId){
        return [
            SELECT Id, Body, DeveloperName, FolderId, FolderName, IsActive, Name
            FROM EmailTemplate
            WHERE IsActive = true
            AND FolderId = :folderId
            WITH SECURITY_ENFORCED
        ];
    }

    public static List<EmailTemplate> getEmailTemplateByNameList(String templateName){
        return [
            SELECT Id, Body, DeveloperName, FolderId, FolderName, IsActive, Name, HtmlValue
            FROM EmailTemplate
            WHERE IsActive = true
            AND Name = :templateName
            WITH SECURITY_ENFORCED
        ];
    }

    public static List<OrgWideEmailAddress> getOrgWideEmailAddressList(String displayName){
        return [
            SELECT Id, Address, DisplayName
            FROM OrgWideEmailAddress
            WHERE DisplayName = :displayName
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
    }

    public static List<EmailTemplate> getEmailTemplateById(Id templateId){
        return [
            SELECT Id, Body, DeveloperName, FolderId, FolderName, IsActive, Name
            FROM EmailTemplate
            WHERE IsActive = true
            AND Id = :templateId
            WITH SECURITY_ENFORCED
        ];
    }

    public static Integer getChildCase(Id parentId){
        return [
            SELECT count()
            FROM Case
            WHERE ParentId = :parentId
            AND Type = 'Comunicazione con il Gestore'
            AND Cluster__c = 'Informative'
        ];
    }

    public static String getEmail(String emailTemplateName){
        //return [
        //    SELECT Email_Template_Name__c, Email__c, DeveloperName, MasterLabel
        //    FROM HDT_EmailComunicazioneGestore__mdt
        //    WHERE Email_Template_Name__c = :emailTemplateName
        //    WITH SECURITY_ENFORCED
        //    LIMIT 1
        //].Email__c;
        return null;
    }

    public static List<EmailMessage> getEmailMessage(Id caseId, String Subject){
        return [
            SELECT EmailTemplateId, ParentId, RelatedToId, Status, Subject, ToAddress
            FROM EmailMessage
            WHERE RelatedToId = :caseId
            AND Subject = :Subject
            WITH SECURITY_ENFORCED
        ];
    }

}