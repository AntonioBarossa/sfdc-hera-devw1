@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_MailSenderHelper {


    public static Boolean checkForReminderMail(Id recordId){
        List<EmailMessage> emailMessageList = new List<EmailMessage>();
        emailMessageList = HDT_QR_MailSender.getEmailMessageByCaseId(recordId);
        //return !(emailMessageList.size() == 0);
        return true;
    }

    public static HDT_WRP_MailSender.HDT_WRP_Result getReminderMetadataHelper(Id recordId) {

        HDT_WRP_MailSender.HDT_WRP_Result mailSenderMetaData = new HDT_WRP_MailSender.HDT_WRP_Result();
        List<EmailTemplate> emailTemplateList = new List<EmailTemplate>();
        emailTemplateList = HDT_QR_MailSender.getEmailTemplateByNameList('COM-Sollecito');

        if(emailTemplateList.size() == 0){
            mailSenderMetaData.success = false;
            mailSenderMetaData.message = 'Non ci sono template';
            return mailSenderMetaData;
        }

        List<OrgWideEmailAddress> orgWideEmailAddressList = new List<OrgWideEmailAddress>();
        orgWideEmailAddressList = HDT_QR_MailSender.getOrgWideEmailAddressList('Comunicazione dal gestore');

        if(orgWideEmailAddressList.size() == 0){
            mailSenderMetaData.success = false;
            mailSenderMetaData.message = 'Organization-Wide Address non è impostata';
            return mailSenderMetaData;
        }

        mailSenderMetaData.mailData = new HDT_WRP_MailSender.HDT_WRP_MailData();
        mailSenderMetaData.success = true;
        mailSenderMetaData.mailData.orgWideEmailAddressId = orgWideEmailAddressList[0].Id;
        mailSenderMetaData.mailData.sender = orgWideEmailAddressList[0].Address;
        mailSenderMetaData.mailData.reminderBodyMail = emailTemplateList[0].HtmlValue;
        mailSenderMetaData.mailData.receiver = 'example@mail.com';
        mailSenderMetaData.isReminder = true;
        return mailSenderMetaData;

    }

    public static HDT_WRP_MailSender.HDT_WRP_Result getMetadataHelper(Id recordId) {

        HDT_WRP_MailSender.HDT_WRP_Result mailSenderMetaData = new HDT_WRP_MailSender.HDT_WRP_Result();
        List<EmailTemplate> emailTemplateList = new List<EmailTemplate>();
        List<Folder> folderList = new List<Folder>();
        folderList = HDT_QR_MailSender.getFolderList('COM-Comunicazioni Gestore');

        if(folderList.size() == 0){
            mailSenderMetaData.success = false;
            mailSenderMetaData.message = 'Non ci sono folder';
            return mailSenderMetaData;
        }

        emailTemplateList = HDT_QR_MailSender.getEmailTemplateList(folderList[0].Id);

        if(emailTemplateList.size() == 0){
            mailSenderMetaData.success = false;
            mailSenderMetaData.message = 'Non ci sono template';
            return mailSenderMetaData;
        }

        mailSenderMetaData.templateList = new List<HDT_WRP_MailSender.HDT_WRP_PicklistObj>();
        HDT_WRP_MailSender.HDT_WRP_PicklistObj pickElement;
        for(EmailTemplate template : emailTemplateList){
            pickElement = new HDT_WRP_MailSender.HDT_WRP_PicklistObj();
            pickElement.label = template.Name;
            pickElement.value = template.Id;
            mailSenderMetaData.templateList.add(pickElement);
        }

        List<OrgWideEmailAddress> orgWideEmailAddressList = new List<OrgWideEmailAddress>();
        orgWideEmailAddressList = HDT_QR_MailSender.getOrgWideEmailAddressList('Comunicazione dal gestore');

        if(orgWideEmailAddressList.size() == 0){
            mailSenderMetaData.success = false;
            mailSenderMetaData.message = 'Organization-Wide Address non è impostata';
            return mailSenderMetaData;
        }

        mailSenderMetaData.mailData = new HDT_WRP_MailSender.HDT_WRP_MailData();
        mailSenderMetaData.success = true;
        mailSenderMetaData.mailData.orgWideEmailAddressId = orgWideEmailAddressList[0].Id;
        mailSenderMetaData.mailData.sender = orgWideEmailAddressList[0].Address;
        mailSenderMetaData.isReminder = false;
        return mailSenderMetaData;

    }

    public static HDT_WRP_MailSender.HDT_WRP_GenerateCaseResult updateReminderCase(Id caseId){
        
        HDT_WRP_MailSender.HDT_WRP_GenerateCaseResult updateCaseResult = new HDT_WRP_MailSender.HDT_WRP_GenerateCaseResult();

        try {

            Case reminderCase = new Case();
            reminderCase.Id = caseId;
            //reminderCase.Phase__c = '';

            SObjectType objtype = Schema.getGlobalDescribe().get('Case');
            Schema.DescribeSObjectResult objRes = objtype.getDescribe();
     
            if(objRes.isCreateable()){
                HDT_UTL_DatabaseService.updateSObject(reminderCase);
            } else {
                updateCaseResult.success = false;
                updateCaseResult.message = 'No access to Case';
                return updateCaseResult;
            }

        } catch(Exception e){
            updateCaseResult.success = false;
            updateCaseResult.message = e.getMessage() + ' at line [' + String.valueOf(e.getLineNumber()) + ']';
            return updateCaseResult;
        }

        updateCaseResult.success = true;
        return updateCaseResult;

    }

    public static HDT_WRP_MailSender.HDT_WRP_GenerateCaseResult generateNewCase(Id caseId){
        
        HDT_WRP_MailSender.HDT_WRP_GenerateCaseResult generateCaseResult = new HDT_WRP_MailSender.HDT_WRP_GenerateCaseResult();

        Case mailCase;
        Case caseToClone;

        try{

            mailCase = new Case();
            caseToClone = retrieveCaseForClone(caseId);
            mailCase = caseToClone.clone(false, true, false, false);
            mailCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_Informative').getRecordTypeId();
            mailCase.Type = 'Comunicazione con il Gestore';
            mailCase.Phase__c = 'Bozza';
            mailCase.Status = 'New';
            mailCase.Cluster__c = null;
            mailCase.ParentId = null;
            mailCase.ServiceRequestID__c = '';

            SObjectType objtype = Schema.getGlobalDescribe().get('Case');
            Schema.DescribeSObjectResult objRes = objtype.getDescribe();
     
            if(objRes.isCreateable()){
                HDT_UTL_DatabaseService.insertSObject(mailCase);
            } else {
                generateCaseResult.success = false;
                generateCaseResult.message = 'No access to Case';
                return generateCaseResult;
            }

            generateCaseResult.success = true;
            generateCaseResult.message = 'Case created';
            generateCaseResult.caseId = mailCase.Id;

        } catch (Exception e){
            generateCaseResult.success = false;
            generateCaseResult.message = e.getMessage() + ' at line [' + String.valueOf(e.getLineNumber()) + ']';
        }

        return generateCaseResult;
    }

    public static HDT_WRP_MailSender.HDT_WRP_BodyMail getBodyMailMerged(Id templateId, Id recordId){
        
        System.debug('>>> templateId: ' + templateId + ' - recordId: ' + recordId);

        HDT_WRP_MailSender.HDT_WRP_BodyMail bodyMailResult = new HDT_WRP_MailSender.HDT_WRP_BodyMail();
        Messaging.SingleEmailMessage singleEmailMessage;
        
        try {
            singleEmailMessage = Messaging.renderStoredEmailTemplate(templateId, UserInfo.getUserId(), recordId);
            bodyMailResult.success = true;
            bodyMailResult.message = '';
            bodyMailResult.bodyMail = singleEmailMessage.getHtmlBody();
            bodyMailResult.receiver = getReceiverMail(templateId);
        } catch(Exception e){
            bodyMailResult.success = false;
            bodyMailResult.message = e.getMessage() + ' - linea [' + String.valueOf(e.getLineNumber()) + ']';
            bodyMailResult.bodyMail = '';
        }

        System.debug('>>> bodyMailResult ' + bodyMailResult);

        return bodyMailResult;

    }

    public static HDT_WRP_MailSender.HDT_WRP_SendMailResult sendMailHelper(String mailStructureJson){

        HDT_WRP_MailSender.HDT_WRP_SendMailResult sendMailResult = new HDT_WRP_MailSender.HDT_WRP_SendMailResult();

        try{			

            HDT_WRP_MailSender.HDT_WRP_MailStructure mailStructure;
            mailStructure = (HDT_WRP_MailSender.HDT_WRP_MailStructure)JSON.deserialize(mailStructureJson, HDT_WRP_MailSender.HDT_WRP_MailStructure.class);

            HDT_WRP_MailSender.HDT_WRP_GenerateCaseResult caseResult;

            if(mailStructure.isReminder){
                //caseResult = updateReminderCase(mailStructure.caseId);
            } else {
                caseResult = generateNewCase(mailStructure.caseId);
    
                if(!caseResult.success){
                    sendMailResult.success = false;
                    sendMailResult.message = caseResult.message;
                    return sendMailResult;
                }
            }

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setOrgWideEmailAddressId(Id.valueOf(mailStructure.orgWideAddId));
            mail.setToAddresses(new String[]{mailStructure.toAddress});
			mail.setSubject('Comunicazione dal gestore');
            mail.setHtmlBody(mailStructure.bodyMail);
            mail.setWhatId(caseResult.caseId);
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

            sendMailResult.success = true;
            sendMailResult.message = 'La mail è stata inviata correttamente.';
            sendMailResult.caseId = caseResult.caseId;

        }catch(Exception e){
            System.debug(LoggingLevel.DEBUG, 'Send Email Error: ' + e.getMessage());
            sendMailResult.success = false;
            sendMailResult.message = e.getMessage() + ' linea [' + String.valueOf(e.getLineNumber()) + ']';
        }

        return sendMailResult;
    }

    public static Case retrieveCaseForClone(Id caseIdToClone){

        List<String> sObjectFields = new List<String>{};
        SObjectType objtype = Schema.getGlobalDescribe().get('Case');
        sObjectFields.addAll(objtype.getDescribe().fields.getMap().keySet());

        String queryString = '';
        queryString += 'SELECT ' + sObjectFields.get(0);

        for (Integer i=1 ; i < sObjectFields.size() ; i++){
            queryString += ', ' + sObjectFields.get(i);
        }

        queryString += ' FROM Case ';
        queryString += 'WHERE Id = \'' + caseIdToClone + '\'';

        List<Case> caseList = Database.query(queryString);

        return caseList[0];
    }

    public static String getReceiverMail(Id templateId){
        List<EmailTemplate> emailTemplateList = new List<EmailTemplate>();
        emailTemplateList = HDT_QR_MailSender.getEmailTemplateById(templateId);
        //return HDT_QR_MailSender.getEmail(emailTemplateList[0].Name);
        return 'receiver@mail.com';
    }

}