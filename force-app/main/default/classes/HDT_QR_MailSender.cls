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
            AND Name <> 'COM-Sollecito'
            WITH SECURITY_ENFORCED
            ORDER BY Name
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
        // FP: i profili no-admin non riescono ad accedere a questo metadato
        return [
            SELECT Id, Address, DisplayName
            FROM OrgWideEmailAddress
            WHERE DisplayName = :displayName
            // WITH SECURITY_ENFORCED
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
            AND Phase__c <> 'Completata'
            AND Status <> 'Closed'
            WITH SECURITY_ENFORCED
        ];
    }

    public static String getEmail(String emailTemplateName){
       return [
           SELECT Email_Template_Name__c, Email__c, DeveloperName, MasterLabel
           FROM HDT_EmailComunicazioneGestore__mdt
           WHERE Email_Template_Name__c = :emailTemplateName
           WITH SECURITY_ENFORCED
           LIMIT 1
       ]?.Email__c;
    }

    public static List<EmailMessage> getEmailMessage(Id caseId, String Subject){
        String subj = Subject + '%';
        return [
            SELECT EmailTemplateId, ParentId, RelatedToId, Status, Subject, ToAddress
            FROM EmailMessage
            WHERE RelatedToId = :caseId
            AND Subject LIKE :subj
            WITH SECURITY_ENFORCED
        ];
    }

    public static Case retrieveCaseForClone(Id caseIdToClone){

        List<String> sObjectFields = new List<String>{};
        List<Case> caseList = new List<Case>();
        SObjectType objtype = Schema.getGlobalDescribe().get('Case');
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();
        sObjectFields.addAll(objtype.getDescribe().fields.getMap().keySet());

        String queryString = '';
        queryString += 'SELECT ' + sObjectFields.get(0);

        for (Integer i=1 ; i < sObjectFields.size() ; i++){
            if(!'Reason__c'.equalsIgnoreCase(sObjectFields.get(i))){
                queryString += ', ' + sObjectFields.get(i);
            }
        }

        queryString += ' FROM Case ';
        queryString += 'WHERE Id = \'' + caseIdToClone + '\'';

        if(objRes.isAccessible()){
            caseList = Database.query(queryString);
        }

        return caseList[0];
    }

    public static Order retrieveCaseDetailsFromOrder(Id orderId){
        return [
            SELECT AccountId, ContractId, BillToContactId,
                   ShipToContactId, ServicePoint__c, ServicePointCode__c, BillingProfile__c
            FROM Order
            WHERE Id = :orderId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ]; 
    }

    public static List<Case> getCaseByOrderId(Id orderId){
        return [
            SELECT Id
            FROM Case
            WHERE Order__c = :orderId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
    }

    public static List<Case> getCaseById(Id caseId){
        return [
            SELECT Id, Type, Phase__c, CaseNumber, Parent.CaseNumber
            FROM Case
            WHERE Id =: caseId
            WITH SECURITY_ENFORCED
            LIMIT 1 ];
    }

}