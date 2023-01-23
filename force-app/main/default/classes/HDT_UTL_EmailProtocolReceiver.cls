public class HDT_UTL_EmailProtocolReceiver implements Messaging.InboundEmailHandler {

    private final static String TEMPORARY_COMPANYOWNER_DEFAULT = 'HERA COMM';

    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        try {
            HDT_SRV_ContentDocumentLink contentdocumentLink = new HDT_SRV_ContentDocumentLink();
            HDT_SRV_ContentVersion contentSrv = new HDT_SRV_ContentVersion();
            String emailBody;
            Boolean bodyTruncated = false;
            String cluster;
            String type;
            String process;
            String companyOwner;
            String salesCompany;
            
            //Recupero i record del metadato HDT_ProtocolSpecificEmail__mdt
            Map<String,HDT_ProtocolSpecificEmail__mdt> mapEmailObj = new Map<String,HDT_ProtocolSpecificEmail__mdt>();
            for(HDT_ProtocolSpecificEmail__mdt specificEmail : HDT_ProtocolSpecificEmail__mdt.getAll().values()) {
                mapEmailObj.put(specificEmail.Email__c.toUpperCase(), specificEmail);
            }

            //Recupero il destinatario dell'email
            String toAddress = email.toAddresses == null || email.toAddresses.isEmpty() ? null : email.toAddresses[0];

            //Gestico la dimensione del testo dell'email e la tronco se supera i 31999 caratteri
            if(email.plainTextBody != null && email.plainTextBody.length() > 31999) {
                emailBody = email.plainTextBody.left(31999);
                bodyTruncated = true;
            } else {
                emailBody = email.plainTextBody;
            }
            //Recupero dal metadato HDT_ProtocolSpecificEmail__mdt le informazioni da riportare sull'activity e interaction in base all'email destinataria 
            if(mapEmailObj.get(toAddress.toUpperCase()) != null) {
                HDT_ProtocolSpecificEmail__mdt specificEmail = mapEmailObj.get(toAddress.toUpperCase());
                cluster = specificEmail.Cluster__c;
                process = specificEmail.Process__c;
                type = specificEmail.Type__c;
                companyOwner = specificEmail.CompanyOwner__c;
                //salesCompany = specificEmail.SalesCompany__c;
            }

            //Creo l'interaction
            String subject = (String.isNotBlank(email.subject) && email.subject.length() > 255) ? email.subject.substring(0,254) : email.subject;
            Interaction__c interaction = new Interaction__c(
                Type__c = 'Digital',
                ReceptionDate__c = DateTime.now(),
                BodyEmail__c = emailBody,
                SubjectEmail__c = subject,
                CompanyOwner__c = String.isNotBlank(companyOwner)?companyOwner:TEMPORARY_COMPANYOWNER_DEFAULT
            );
            

            // MAIL SEMPRE INOLTRATE DA ACCOUNT HERA - NECESSARIO ESTRARRE MITENTE ORIGINALE
            String senderAddress = emailBody.left(300).substringBetween(' <', '>');
            if(String.isNotBlank(senderAddress)) {
                interaction.SenderEmailAddress__c = senderAddress;
                List<Contact> contacts = [SELECT Id, AccountId FROM Contact WHERE Email =: senderAddress WITH SECURITY_ENFORCED ORDER BY CreatedDate desc LIMIT 1];
                if(contacts.size() == 1) {
                    interaction.Contact__c = contacts[0].Id;
                    interaction.Account__c = contacts[0].AccountId;
                }
            }

            interaction = new HDT_SRV_Interaction().createRecord(interaction);

            if(bodyTruncated) {
                HDT_UTL_Note.createNoteAndAssign(interaction.id, 'Testo Troncato per Superamento Limite Caratteri', '');
            }

            List<ContentVersion> listContent = new List<ContentVersion>();
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

            //Creo l'activity
            wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();
            activity.Interaction__c = interaction.Id;
            activity.RecordTypeId = new HDT_QR_RecordType().getRecordTypeIdByName('HDT_RT_RegisterActivity');
            activity.Account__c = interaction.Account__c;
            activity.Contact__c = interaction.Contact__c;
            activity.CompanyOwner__c = String.isNotBlank(companyOwner)?companyOwner:TEMPORARY_COMPANYOWNER_DEFAULT;
            activity.Cluster__c = String.isNotBlank(cluster)?cluster:'';
            activity.Process__c = String.isNotBlank(process)?process:'';
            activity.Type__c = String.isNotBlank(type)?type:'';
            
            new HDT_SRV_ActivityCustom().createRecord(activity);
        } catch (Exception e) {
            e.setMessage(e.getMessage() + ' at line ' + e.getLineNumber());
            throw e;
        }
        return null;
    }
}