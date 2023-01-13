@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_MailSenderHelper {

    private static String comGestore = 'Comunicazione dal gestore';

    public static Boolean checkForReminderMail(Id recordId){
        List<EmailMessage> emailMessageList = new List<EmailMessage>();
        Id currentRecordId;
        Boolean isCaseObj = recordId.getSobjectType() == Schema.Case.SObjectType;

        if(isCaseObj){
            currentRecordId = recordId;
        } else {
            List<Case> caseList = new List<Case>();
            caseList = HDT_QR_MailSender.getCaseByOrderId(recordId);
            if(caseList.size()==0){
                return false;
            }
            currentRecordId = caseList[0].Id;
        }

        emailMessageList = HDT_QR_MailSender.getEmailMessage(currentRecordId, comGestore);
        return !(emailMessageList.size() == 0);
    }

    public static HDT_WRP_MailSender.HDT_WRP_Result getReminderMetadataHelper(Id recordId) {

        HDT_WRP_MailSender.HDT_WRP_Result mailSenderMetaData = new HDT_WRP_MailSender.HDT_WRP_Result();
        List<EmailTemplate> emailTemplateList = new List<EmailTemplate>();
        emailTemplateList = HDT_QR_MailSender.getEmailTemplateByNameList('COM-Sollecito');
        Id currentRecordId;
        Boolean isCaseObj = recordId.getSobjectType() == Schema.Case.SObjectType;

        if(emailTemplateList.size() == 0){
            mailSenderMetaData.success = false;
            mailSenderMetaData.message = 'Non ci sono template';
            return mailSenderMetaData;
        }

        List<OrgWideEmailAddress> orgWideEmailAddressList = new List<OrgWideEmailAddress>();
        orgWideEmailAddressList = HDT_QR_MailSender.getOrgWideEmailAddressList(comGestore);

        if(orgWideEmailAddressList.size() == 0){
            mailSenderMetaData.success = false;
            mailSenderMetaData.message = 'Organization-Wide Address non è impostata';
            return mailSenderMetaData;
        }

        List<EmailMessage> emailMessageList;

        mailSenderMetaData.mailData = new HDT_WRP_MailSender.HDT_WRP_MailData();
        mailSenderMetaData.success = true;
        mailSenderMetaData.mailData.orgWideEmailAddressId = orgWideEmailAddressList[0].Id;
        mailSenderMetaData.mailData.sender = orgWideEmailAddressList[0].Address;
        mailSenderMetaData.mailData.reminderBodyMail = emailTemplateList[0].HtmlValue;

        if(isCaseObj){
            currentRecordId = recordId;
        } else {
            List<Case> caseList = new List<Case>();
            caseList = HDT_QR_MailSender.getCaseByOrderId(recordId);
            if(caseList.size()==0){
                mailSenderMetaData.success = false;
                mailSenderMetaData.message = 'Non è presente il case collegato a questo Ordine';
                return mailSenderMetaData;
            }
            currentRecordId = caseList[0].Id;
        }

        emailMessageList = new List<EmailMessage>();
        emailMessageList = HDT_QR_MailSender.getEmailMessage(currentRecordId, comGestore);
        mailSenderMetaData.mailData.receiver = emailMessageList[0].ToAddress;

        emailMessageList = new List<EmailMessage>();
        emailMessageList = HDT_QR_MailSender.getEmailMessage(currentRecordId, 'Sollecito');
        mailSenderMetaData.mailData.reminderMailCounter = emailMessageList.size();

        mailSenderMetaData.isReminder = true;
        return mailSenderMetaData;

    }

    public static HDT_WRP_MailSender.HDT_WRP_Result getMetadataHelper(Id recordId) {

        HDT_WRP_MailSender.HDT_WRP_Result mailSenderMetaData = new HDT_WRP_MailSender.HDT_WRP_Result();
        List<EmailTemplate> emailTemplateList = new List<EmailTemplate>();
        List<Folder> folderList = new List<Folder>();
        
        Integer childCase = HDT_QR_MailSender.getChildCase(recordId);
        
        if(childCase >= 1){
            mailSenderMetaData.success = false;
            mailSenderMetaData.message = 'Hai già mandato la comunicazione';
            return mailSenderMetaData;
        } 
        
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
        orgWideEmailAddressList = HDT_QR_MailSender.getOrgWideEmailAddressList(comGestore);

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

    public static HDT_WRP_MailSender.HDT_WRP_GenerateCaseResult updateReminderCase(Id caseId, Boolean isCaseObj){
        
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

        updateCaseResult.caseId = caseId;
        updateCaseResult.success = true;
        return updateCaseResult;

    }

    public static HDT_WRP_MailSender.HDT_WRP_GenerateCaseResult generateNewCase(Id recordId, Boolean isCaseObj){
        
        HDT_WRP_MailSender.HDT_WRP_GenerateCaseResult generateCaseResult = new HDT_WRP_MailSender.HDT_WRP_GenerateCaseResult();

        Case mailCase;
        Case caseToClone;

        try{

            mailCase = new Case();

            if(isCaseObj){
                caseToClone = HDT_QR_MailSender.retrieveCaseForClone(recordId);
                mailCase = caseToClone.clone(false, true, false, false);
                mailCase.ParentId = recordId;
            } else {
                Order orderDetail = HDT_QR_MailSender.retrieveCaseDetailsFromOrder(recordId);
                mailCase.Order__c = recordId;
                mailCase.AccountId = orderDetail.AccountId;
                mailCase.Contract__c = orderDetail.ContractId;
                mailCase.ContactId = orderDetail.BillToContactId;
                //mailCase.ContactId = orderDetail.ShipToContactId;
                //mailCase. = orderDetail.ServicePoint__c;
                mailCase.ServicePointCode__c = orderDetail.ServicePointCode__c;
                mailCase.BillingProfile__c = orderDetail.BillingProfile__c;
            }

            mailCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_Informative').getRecordTypeId();
            mailCase.Type = 'Comunicazione con il Gestore';
            mailCase.Phase__c = 'Bozza';
            mailCase.Status = 'New';
            mailCase.Cluster__c = 'Informative';
            mailCase.ServiceRequestID__c = '';
            mailCase.PhaseStory__c = null;

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
            bodyMailResult.receiver = '###';///getReceiverMail(templateId);
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
        String subjectString = '';
        Boolean isCaseObj;
        HDT_WRP_MailSender.HDT_WRP_MailStructure mailStructure;

        try{
            
            mailStructure = (HDT_WRP_MailSender.HDT_WRP_MailStructure)JSON.deserialize(mailStructureJson, HDT_WRP_MailSender.HDT_WRP_MailStructure.class);
            Id currentId = Id.valueOf(mailStructure.recordId);
            isCaseObj = currentId.getSobjectType() == Schema.Case.SObjectType;

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            HDT_WRP_MailSender.HDT_WRP_GenerateCaseResult caseResult;

            if(mailStructure.isReminder){

                Id currentRecordId;
        
                if(isCaseObj){
                    currentRecordId = currentId;
                } else {
                    List<Case> caseList = new List<Case>();
                    caseList = HDT_QR_MailSender.getCaseByOrderId(currentId);
                    if(caseList.size()==0){
                        sendMailResult.success = false;
                        sendMailResult.message = 'Non è stato trovato il case correlato a questo ordine';
                        return sendMailResult;
                    }
                    currentRecordId = caseList[0].Id;
                }

                caseResult = updateReminderCase(currentRecordId, isCaseObj);
                subjectString = 'Sollecito';
                //mail.setInReplyTo('<ONJvc000000000000000000000000000000000000000000000RLOZZ300FWBbGuOPTAKjJrhrqaQJkA@sfdc.net>');
                //mail.setReferences('<ONJvc000000000000000000000000000000000000000000000RLOZZ300FWBbGuOPTAKjJrhrqaQJkA@sfdc.net>');
                //mail.setBccAddresses(new List<String>{''});
            } else {
                subjectString = comGestore;
                caseResult = generateNewCase(mailStructure.recordId, isCaseObj);
    
                if(!caseResult.success){
                    sendMailResult.success = false;
                    sendMailResult.message = caseResult.message;
                    return sendMailResult;
                }
            }
            
            mail.setHtmlBody(mailStructure.bodyMail);
            mail.setToAddresses(new String[]{mailStructure.toAddress});
            mail.setOrgWideEmailAddressId(Id.valueOf(mailStructure.orgWideAddId));
            mail.setSubject(subjectString);
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

    //public static String getReceiverMail(Id templateId){
    //    List<EmailTemplate> emailTemplateList = new List<EmailTemplate>();
    //    emailTemplateList = HDT_QR_MailSender.getEmailTemplateById(templateId);
    //    //return HDT_QR_MailSender.getEmail(emailTemplateList[0].Name);
    //    return 'receiver@mail.com';// inserita manualmente
    //}

}