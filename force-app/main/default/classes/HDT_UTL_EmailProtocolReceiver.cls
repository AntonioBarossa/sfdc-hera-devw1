global class HDT_UTL_EmailProtocolReceiver implements Messaging.InboundEmailHandler {
	  global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
         Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
         Date d = Date.today();
         HDT_QR_Contact contactQr = new HDT_QR_Contact();
         HDT_SRV_Interaction intSrv = new HDT_SRV_Interaction();
         HDT_SRV_ActivityCustom actSrv = new HDT_SRV_ActivityCustom();
         HDT_QR_RecordType recordTypeQr = new HDT_QR_RecordType();
         Interaction__c newInter = new Interaction__c();
         newInter.Status__c = 'Bozza';
         newInter.Type__c = 'Digital';
         newInter.ReceptionDate__c = d;
         newInter.BodyEmail__c = email.plainTextBody;
         newInter.SubjectEmail__c = email.subject;
         
    
        List<Contact> contacts = contactQr.getContactByEmailAddress(email.fromAddress);
        if(contacts.size()==1){
            newInter.Account__c = contacts[0].AccountId;
            newInter.Contact__c = contacts[0].Id;
        }
        
         Interaction__c res = intSrv.createRecord(newInter);
         wrts_prcgvr__Activity__c activityCustom = new wrts_prcgvr__Activity__c();
        activityCustom.Interaction__c = res.Id;
        activityCustom.RecordTypeId = recordTypeQr.getRecordTypeIdByName('HDT_RT_RegisterActivity');
        activityCustom.Account__c = res.Account__c;
        activityCustom.Contact__c = res.Contact__c;
        Map<String,HDT_ProtocolSpecificEmail__mdt> listMet = HDT_ProtocolSpecificEmail__mdt.getAll();
        Map<String,HDT_ProtocolSpecificEmail__mdt> mapEmailObj = new Map<String,HDT_ProtocolSpecificEmail__mdt>();
        for(String s : listMet.keyset()){
            HDT_ProtocolSpecificEmail__mdt ob = listMet.get(s);
            mapEmailObj.put(ob.email__c.toUpperCase(),ob);
        }

        if(mapEmailObj.get(email.toAddresses[0].toUpperCase())!=null){
            HDT_ProtocolSpecificEmail__mdt specEmail= mapEmailObj.get(email.toAddresses[0].toUpperCase());
            activityCustom.Cluster__c= specEmail.Cluster__c;
            activityCustom.Process__c= specEmail.Process__c;
        }
        wrts_prcgvr__Activity__c resActivity = actSrv.createRecord(activityCustom);

         System.debug('Record Id: ' + res.Id);

          result.success = true;
          System.debug('************Debug:' + email);
          return result;
      }
      
  }