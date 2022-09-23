public inherited sharing class HDT_QR_MailSender {

    public static List<Folder> getFolderList(String folderName){
        return [
            SELECT Id
            FROM Folder
            WHERE Name = :folderName
        ];
    }

    public static List<EmailTemplate> getEmailTemplateList(Id folderId){
        return [
            SELECT Id, Body, DeveloperName, FolderId, FolderName, IsActive, Name
            FROM EmailTemplate
            WHERE IsActive = true
            AND FolderId = :folderId
        ];
    }

    public static List<EmailTemplate> getEmailTemplateByNameList(String templateName){
        return [
            SELECT Id, Body, DeveloperName, FolderId, FolderName, IsActive, Name
            FROM EmailTemplate
            WHERE IsActive = true
            AND Name = :templateName
        ];
    }

    public static List<OrgWideEmailAddress> getOrgWideEmailAddressList(String displayName){
        return [
            SELECT Id, Address, DisplayName
            FROM OrgWideEmailAddress
            WHERE DisplayName = :displayName
            LIMIT 1
        ];
    }

    public static List<EmailTemplate> getEmailTemplateById(Id templateId){
        return [
            SELECT Id, Body, DeveloperName, FolderId, FolderName, IsActive, Name
            FROM EmailTemplate
            WHERE IsActive = true
            AND Id = :templateId
        ];
    }

    public static String getEmail(String emailTemplateName){
        //return [
        //    SELECT Email_Template_Name__c, Email__c, DeveloperName, MasterLabel
        //    FROM HDT_EmailComunicazioneGestore__mdt
        //    WHERE Email_Template_Name__c = :emailTemplateName
        //    LIMIT 1
        //].Email__c;
        return null;
    }

    public static List<EmailMessage> getEmailMessageByCaseId(Id caseId){
        return [
            SELECT EmailTemplateId, ParentId, RelatedToId, Status, Subject
            FROM EmailMessage
            WHERE RelatedToId = :caseId
            AND Subject = 'Comunicazione dal gestore'
        ];
    }

}