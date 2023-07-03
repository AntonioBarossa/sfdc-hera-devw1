public with sharing class HDT_LC_RecallMeCreateForm {
   private static HDT_QR_Lead leadQr = new HDT_QR_Lead();
   private static HDT_SRV_CampaignMember campaignMemberSrv = new HDT_SRV_CampaignMember();
   private static HDT_SRV_Contact contactSrv = new HDT_SRV_Contact();
   
   @AuraEnabled
    public static Id createCampaignMemberFromLead(String leadId, String sourceAgency, String interestProduct, String campaignId, String mobilePhone){
        try {
            System.debug('Lead ID'+leadId);
        
            //Lead l = leadQr.getRecordById(leadId);
            CampaignMember campaignMember = new CampaignMember(
                LeadId = leadId,
                CampaignId = campaignId,
               PhoneNumber__c = mobilePhone
            );
           Lead updateLead = new Lead(
               Id = leadId,
               SourceAgency__c = sourceAgency,
               ContactReason__c ='Info commerciali', //HRAWRM-640 20/09/2021
               InterestProduct__c = interestProduct
           );
           HDT_SRV_Lead.updateRecord(updateLead);
 
        List<CampaignMemberLeadAssigment__c> listCampLeass = [Select id,agency__c from CampaignMemberLeadAssigment__c where InterestProduct__c = :interestProduct AND SourceAgency__c =:sourceAgency AND agency__c != null WITH SECURITY_ENFORCED];

        if(listCampLeass != null && !listCampLeass.isEmpty()){
            campaignMember.agency__c = listCampLeass[0].agency__c;
            CampaignMember res =  campaignMemberSrv.createRecord(campaignMember);
            HDT_SRV_Lead.updateRecord(updateLead);
            return res.Id;
        }else{
            return null;
        }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Id createCampaignMemberFromContact(String contactId, String sourceAgency, String interestProduct, String campaignId, String mobilePhone){
        try {
            System.debug('contact ID '+contactId);

            CampaignMember campaignMember = new CampaignMember(
                ContactId = contactId,
                CampaignId = campaignId,
                PhoneNumber__c = mobilePhone
            );
           Contact updateContact = new Contact(
               Id = contactId,
               SourceAgency__c = sourceAgency,
               ContactReason__c ='Info commerciali',
               InterestProduct__c = interestProduct
           );

            List<CampaignMemberLeadAssigment__c> listCampLeass = [Select id,agency__c from CampaignMemberLeadAssigment__c where InterestProduct__c = :interestProduct AND SourceAgency__c =:sourceAgency AND agency__c != null WITH SECURITY_ENFORCED];

            if(listCampLeass != null && !listCampLeass.isEmpty()){
                campaignMember.agency__c = listCampLeass[0].agency__c;
                CampaignMember res =  campaignMemberSrv.createRecord(campaignMember);
                contactSrv.updateRecord(updateContact);
                return res.Id;
            }else{
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<String> getActivePicklistValues(String objectapiname, String field) {
        String f = objectapiname+'.'+field;
        System.debug(f);
        List<String> splitField = f.split('\\.');
        Schema.SobjectField objField = Schema.getGlobalDescribe().get(splitField[0]).getDescribe().fields.getMap().get(splitField[1]);
        List<Schema.PicklistEntry> entries = objField.getDescribe().getPickListValues();
        List<String> activeEntries = new List<String>();
        for (Schema.PicklistEntry entry : entries) {
            if (entry.isActive()) {
                activeEntries.add(entry.getValue());
            }
        }
        return activeEntries;
    }
}