public class HDT_UTL_EmailProtocolReceiver implements Messaging.InboundEmailHandler {

    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        try {
            HDT_SRV_ContentDocumentLink contentdocumentLink = new HDT_SRV_ContentDocumentLink();
            HDT_SRV_ContentVersion contentSrv = new HDT_SRV_ContentVersion();
            String emailBody;
            Boolean bodyTruncated = false;

            if(email.plainTextBody != null && email.plainTextBody.length() > 31999) {
                emailBody = email.plainTextBody.left(31999);
                bodyTruncated = true;
            } else {
                emailBody = email.plainTextBody;
            }

            Map<String,HDT_ProtocolSpecificEmail__mdt> mapEmailObj = new Map<String,HDT_ProtocolSpecificEmail__mdt>();
            for(HDT_ProtocolSpecificEmail__mdt specificEmail : HDT_ProtocolSpecificEmail__mdt.getAll().values()) {
                mapEmailObj.put(specificEmail.Email__c.toUpperCase(), specificEmail);
            }
            HDT_ProtocolSpecificEmail__mdt specificEmail = mapEmailObj.get(toAddress.toUpperCase());

            Interaction__c interaction = new Interaction__c(
                Type__c = 'Digital',
                ReceptionDate__c = Date.today(),
                BodyEmail__c = emailBody,
                SubjectEmail__c = email.subject,
                SenderEmailAddress__c = email.fromAddress,
                CompanyOwner__c =  specificEmail.CompanyOwner__c
            );

            List<ContentVersion> listContent = new List<ContentVersion>();
            List<Contact> contacts = new HDT_QR_Contact().getContactByEmailAddress(email.fromAddress);
            if(contacts.size() == 1) {
                interaction.Contact__c = contacts[0].Id;
                interaction.Account__c = contacts[0].AccountId;
            }
            interaction = new HDT_SRV_Interaction().createRecord(interaction);

            if(bodyTruncated) {
                HDT_UTL_Note.createNoteAndAssign(interaction.id, 'Testo Troncato per Superamento Limite Caratteri', '');
            }

            if(email.textAttachments != null) {
                for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
                    ContentVersion content = contentSrv.createRecordNoInsert(tAttachment.fileName,tAttachment.fileName,tAttachment.body);
                    //content.ParentId = interaction.Id;
                    listContent.add(content);
                }
            }
            if(email.binaryAttachments != null) {
                for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                    ContentVersion content = contentSrv.createRecordNoInsert(bAttachment.fileName,bAttachment.fileName,bAttachment.body);
                    //content.ParentId = interaction.Id;
                    listContent.add(content);
                }
            }
            if(!listContent.isEmpty()) {
                listContent = contentSrv.insertRecords(listContent);
            }
            List<ContentDocumentLink> contentDocumentList = new List<ContentDocumentLink>();
            List<String> idContentVersion = new List<String>();
            for(ContentVersion cv : listContent) {
                idContentVersion.add(cv.id);
            }
            if(!listContent.isEmpty()) {
                List<ContentVersion> contentWithDocument = new HDT_QR_ContentVersion().getRecordByIds(idContentVersion);
                for(ContentVersion cv : contentWithDocument) {
                    contentDocumentList.add(contentdocumentLink.createRecordNoInsert(interaction.Id, cv.ContentDocumentId, 'I'));
                }
                contentdocumentLink.insertRecords(contentDocumentList);
            }

            String toAddress = email.toAddresses == null || email.toAddresses.isEmpty() ? null : email.toAddresses[0];
            EmailMessage newEmail = new EmailMessage(
                FromAddress = email.fromAddress,
                FromName = email.fromName,
                ToAddress = toAddress,
                Subject = email.subject,
                TextBody = emailBody,
                //HtmlBody = email.htmlBody,
                relatedToId = interaction.Id ,
                status = '0'
            );
            HDT_SRV_EmailMessage.insertEmailMessage(newEmail);

            wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c(
                Interaction__c = interaction.Id,
                RecordTypeId = new HDT_QR_RecordType().getRecordTypeIdByName('HDT_RT_RegisterActivity'),
                Account__c = interaction.Account__c,
                Contact__c = interaction.Contact__c,
                Type__c = specificEmail.Type__c,
                CompanyOwner__c = specificEmail.CompanyOwner__c
            );

            if(activity.Account__c == null) {
                activity.Type__c = 'Protocollo - Da tipizzare';
            }

            new HDT_SRV_ActivityCustom().createRecord(activity);
        } catch (Exception e) {
            e.setMessage(e.getMessage() + ' at line ' + e.getLineNumber());
            throw e;
        }
        return null;
    }
}