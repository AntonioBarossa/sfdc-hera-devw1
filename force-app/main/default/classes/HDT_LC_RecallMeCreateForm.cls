public with sharing class HDT_LC_RecallMeCreateForm {
   private static HDT_QR_Lead leadQr = new HDT_QR_Lead();
   private static HDT_SRV_CampaignMember campaignMemberSrv = new HDT_SRV_CampaignMember();
   
   @AuraEnabled
    public static Id createCampaignMemberFromLead(String leadId, String sourceAgency, String interestProduct, String campaignId, String mobilePhone){
        try {
            System.debug('Lead ID'+leadId);
        
            Lead l = leadQr.getRecordById(leadId);
            CampaignMember campaignMember = new CampaignMember(
                LeadId = leadId,
                CampaignId = campaignId,
               PhoneNumber__c = mobilePhone
            );
           CampaignMember res =  campaignMemberSrv.createRecord(campaignMember);
           Lead updateLead = new Lead(
               Id = leadId,
               SourceAgency__c = sourceAgency,
               InterestProduct__c = interestProduct
           );
           HDT_SRV_Lead.updateRecord(updateLead);
           return res.Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}