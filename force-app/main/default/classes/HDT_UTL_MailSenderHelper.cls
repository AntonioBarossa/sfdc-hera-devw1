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

        // emailMessageList = HDT_QR_MailSender.getEmailMessage(currentRecordId, comGestore);
        // return !(emailMessageList.size() == 0);
        
        List<Case> finalRecordList = HDT_QR_MailSender.getCaseById(currentRecordId);
        Set<String> allowedCasePhases = new Set<String>{'In attesa risposta Mail','Sollecito 1', 'Sollecito 2', 'Sollecito 3'};
        return (finalRecordList.size() > 0 && allowedCasePhases.contains(finalRecordList[0].Phase__c));
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

        String csNumber = '';
        
        try {
            
            Case reminderCase = new Case();
            reminderCase.Id = caseId;
            
            List<Case> detailedCases = HDT_QR_MailSender.getCaseById(caseId);
            String newPhase = '';
            if(detailedCases.size() >0){
                csNumber = detailedCases[0].Parent?.CaseNumber;
                String oldPhase = detailedCases[0].Phase__c;
                switch on oldPhase {
                    when 'In attesa risposta Mail'{
                        newPhase = 'Sollecito 1';
                    }
                    when 'Sollecito 1'{
                        newPhase = 'Sollecito 2';
                    }
                    when 'Sollecito 2'{
                        newPhase = 'Sollecito 3';
                    }
                }
            }

            if(!String.isBlank(newPhase)){
                reminderCase.Phase__c = newPhase;
            }

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
        updateCaseResult.caseNumber = csNumber;
        return updateCaseResult;

    }

    public static HDT_WRP_MailSender.HDT_WRP_GenerateCaseResult generateNewCase(Id recordId, Boolean isCaseObj){
        
        HDT_WRP_MailSender.HDT_WRP_GenerateCaseResult generateCaseResult = new HDT_WRP_MailSender.HDT_WRP_GenerateCaseResult();

        Case mailCase;
        Case caseToClone;
        String sObjectName = recordId.getSObjectType().getDescribe().getName();
        try{

            mailCase = new Case();

            if(isCaseObj){
                caseToClone = HDT_QR_MailSender.retrieveCaseForClone(recordId);
                mailCase = caseToClone.clone(false, true, false, false);
                mailCase.ParentId = recordId;
            } else if('Order'.equalsIgnoreCase(sObjectName)){
                Order orderDetail = HDT_QR_MailSender.retrieveCaseDetailsFromOrder(recordId);
                mailCase.Order__c = recordId;
                mailCase.AccountId = orderDetail.AccountId;
                mailCase.Contract__c = orderDetail.ContractId;
                mailCase.ContactId = orderDetail.BillToContactId;
                //mailCase.ContactId = orderDetail.ShipToContactId;
                //mailCase. = orderDetail.ServicePoint__c;
                mailCase.ServicePointCode__c = orderDetail.ServicePointCode__c;
                mailCase.BillingProfile__c = orderDetail.BillingProfile__c;
            }else {
                mailCase.AccountId = recordId;
            }
            HDT_QR_Account qrAccount = new HDT_QR_Account();
            Account acc= qrAccount.getRecordById(mailCase.AccountId, 'FirstName__c, LastName__c');

            mailCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_Informative').getRecordTypeId();
            mailCase.Type = 'Comunicazione con il Gestore';
            mailCase.Phase__c = 'Bozza';
            mailCase.Status = 'New';
            mailCase.Cluster__c = 'Informative';
            mailCase.ServiceRequestID__c = '';
            mailCase.PhaseStory__c = null;
            mailCase.FirstName__c = acc.FirstName__c;
            mailCase.LastName__c = acc.LastName__c;
            mailCase.NotCancellable__c = true;

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
            generateCaseResult.caseNumber = caseToClone?.CaseNumber;

        } catch (Exception e){
            generateCaseResult.success = false;
            generateCaseResult.message = e.getMessage() + ' at line [' + String.valueOf(e.getLineNumber()) + ']';
        }

        return generateCaseResult;
    }

    public static HDT_WRP_MailSender.HDT_WRP_BodyMail getBodyMailMerged(String templateName, Id templateId, Id recordId){
        
        System.debug('>>> templateName: ' + templateName + ' - ' + 'templateId: ' + templateId + ' - recordId: ' + recordId);

        HDT_WRP_MailSender.HDT_WRP_BodyMail bodyMailResult = new HDT_WRP_MailSender.HDT_WRP_BodyMail();
        Messaging.SingleEmailMessage singleEmailMessage;
        
        try {
            singleEmailMessage = Messaging.renderStoredEmailTemplate(templateId, UserInfo.getUserId(), recordId);
            bodyMailResult.success = true;
            bodyMailResult.message = '';
            bodyMailResult.bodyMail = singleEmailMessage.getHtmlBody();
            bodyMailResult.receiver = '###';///getReceiverMail(templateId);
            bodyMailResult.templateName = templateName;
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

        HDT_WRP_MailSender.HDT_WRP_GenerateCaseResult caseResult;

        try{
            
            mailStructure = (HDT_WRP_MailSender.HDT_WRP_MailStructure)JSON.deserialize(mailStructureJson, HDT_WRP_MailSender.HDT_WRP_MailStructure.class);
            Id currentId = Id.valueOf(mailStructure.recordId);
            isCaseObj = currentId.getSobjectType() == Schema.Case.SObjectType;

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

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
                //mail.setInReplyTo('<OZCJB000000000000000000000000000000000000000000000ROQDLZ0048utoRPnQK2LnoiL9jyV4A@sfdc.net>');
                //mail.setReferences('<OZCJB000000000000000000000000000000000000000000000ROQDLZ0048utoRPnQK2LnoiL9jyV4A@sfdc.net>');
                //mail.setBccAddresses(new List<String>{''});
            } else {
                subjectString = comGestore + ' - ' + mailStructure.templateName;
                List<Case> detailedCaseList = HDT_QR_MailSender.getCaseById(mailStructure.recordId);
                if(detailedCaseList.size() > 0 && 'Comunicazione con il Gestore'.equalsIgnoreCase(detailedCaseList[0].Type)){
                    caseResult = updateReminderCase(mailStructure.recordId, isCaseObj);
                }else{
                    caseResult = generateNewCase(mailStructure.recordId, isCaseObj);
                }
    
                if(!caseResult.success){
                    sendMailResult.success = false;
                    sendMailResult.message = caseResult.message;
                    return sendMailResult;
                }

                if(mailStructure.attachmentsIdList.size() > 0){
                    List<String> contentVersionIdList = new List<String>();
                    List<ContentVersion> cvList = [SELECT Id FROM ContentVersion WHERE ContentDocumentId IN :mailStructure.attachmentsIdList];
                    if(cvList.size() > 0){
                        for (ContentVersion cv : cvList) {
                            contentVersionIdList.add(cv.Id);
                        }
                        mail.setEntityAttachments(contentVersionIdList);
                        updateAttachmentsParent(mailStructure.attachmentsIdList, caseResult.caseId, currentId);
                    }
                }
            }

            String messageId = Cases.generateThreadingMessageId(caseResult.caseId);
            String stringCaseLink = '<br><br><a href="'+ URL.getSalesforceBaseUrl().toExternalForm()+ '/'+caseResult.caseId +'">Link Pratica Salesforce</a>';
            mail.setReferences(messageId);
            mail.setHtmlBody(mailStructure.bodyMail + '\n' + stringCaseLink);
            mail.setToAddresses(new String[]{mailStructure.toAddress});
            //mail.setCcAddresses(new String[]{'antonino.fugazzotto@2hy53hdpybee3yyzu1pnnhfr9jl2twp6abttuei499hjwqdemq.3n-8mj0uaa.cs128.case.sandbox.salesforce.com'});
            mail.setOrgWideEmailAddressId(Id.valueOf(mailStructure.orgWideAddId));
            //DA GESTIRE MEGLIO SELEZIONE SUBJECT, SU CASE COM AL GESTORE il CASENUMBER RISULTA NULL
            String subjectStringExtend = !String.isBlank(caseResult.caseNumber) ? ' - Case Controllante: ' + caseResult.caseNumber + ' ' + '[ thread::' + caseResult.caseId + ':: ]' : ' [ thread::' + caseResult.caseId + ':: ]';
            mail.setSubject(subjectString + subjectStringExtend);
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

        if(sendMailResult.success && !mailStructure.isReminder){
            Case caseUpdate = new Case(id=caseResult.caseId, Phase__c = 'In attesa risposta Mail',Status = 'In Lavorazione');
            HDT_UTL_DatabaseService.updateSObject(caseUpdate);
        }

        return sendMailResult;
    }

    public static List<ContentDocument> getContentDocs(Id arecordId){   
        List<ContentDocumentLink> cdLs = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :arecordId WITH SECURITY_ENFORCED];
        if (cdLs.size() < 1){
            return new List<ContentDocument>();
        }

        List <Id> cdIdList = new List <Id> ();
        for (ContentDocumentLink nextCdl : cdLs) {
            cdIdList.add(nextCdl.ContentDocumentId); }    

        //Restituisco i file che sono stati caricati negli ultimi minuti, in modo da evitare che vengano presi documenti già presenti sul case padre.
        DateTime timeNow = System.now();
        DateTime subTimeNow = timeNow.addMinutes(-2);
        return [SELECT Id, Title, FileType,CreatedDate, ContentSize FROM ContentDocument WHERE ContentDocument.Id IN :cdIdList AND createdDate <:timeNow AND createdDate >:subTimeNow WITH SECURITY_ENFORCED];
    }

    public static void updateAttachmentsParent(List<String> attachmentIdList, Id parentId, Id oldParent){

        try {
            List<ContentDocument> contDocList = [SELECT Id, parentId FROM ContentDocument WHERE Id IN :attachmentIdList];
            List<ContentDocumentLink> oldLinksList = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId IN :contDocList AND LinkedEntityId =: oldParent];

            //creazione nuovo contentDocumentLink che punta al case figlio di Comunicazione con il gestore
            List<ContentDocumentLink> newLinkList = new List<ContentDocumentLink>();
            if (contDocList.size() > 0){
                for (ContentDocument cdoc : contDocList) {
                    ContentDocumentLink  contDoc = new ContentDocumentLink ();
                    contDoc.LinkedEntityId = parentId;
                    contDoc.ContentDocumentId = cdoc.Id;
                    newLinkList.add(contDoc);
                }

                if(newLinkList.size() > 0){
                    HDT_UTL_DatabaseService.insertSObject(newLinkList);
                }
            }

            //Eliminazione vecchio contentDocumentLink che puntava al case padre (case da cui è stata innescata la comunicazione)
            if(oldLinksList.size() > 0)
            {
                HDT_UTL_DatabaseService.deleteSObject(oldLinksList);
            }

        } catch (Exception e) {
            System.debug(LoggingLevel.DEBUG, 'Throwed Exception: ' + e.getStackTraceString());
        }
    }

    //public static String getReceiverMail(Id templateId){
    //    List<EmailTemplate> emailTemplateList = new List<EmailTemplate>();
    //    emailTemplateList = HDT_QR_MailSender.getEmailTemplateById(templateId);
    //    //return HDT_QR_MailSender.getEmail(emailTemplateList[0].Name);
    //    return 'receiver@mail.com';// inserita manualmente
    //}

    public static void deletePendingFiles(List<Id> cdIdList) {
        List<ContentDocument> cdList = [SELECT Id FROM ContentDocument WHERE Id IN :cdIdList];
        if(cdList.size() > 0){
            try {
                HDT_UTL_DatabaseService.deleteSObject(cdList);
            } catch (Exception e) {
                System.debug(LoggingLevel.DEBUG, 'Throwed Error: ' + e.getStackTraceString());
            }
        }
    }

    public static Decimal getContentSizeAttachments(List<Id> cdIdList) {
        List<ContentDocument> cdList = [SELECT ContentSize FROM ContentDocument WHERE Id IN :cdIdList];
        Decimal attachmentSizeMb = 0.0;
        Long attachmentSizeBytes = 0;
        if(cdList.size() > 0){
            for (ContentDocument cd : cdList){
                attachmentSizeBytes = attachmentSizeBytes + cd.ContentSize;
            }
            //La ContentSize è in bytes, la converto in megabytes in modo da poter fare il check sulla dimensione lato js
            Decimal mb = Decimal.valueOf(attachmentSizeBytes);
            attachmentSizeMb = mb?.divide((1024*1024),2);
        }
        
        return attachmentSizeMb;
    }

}