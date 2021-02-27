public inherited sharing class HDT_LC_CampaignsController {

    private static HDT_QR_CampaignMember campaignMemberQr = new HDT_QR_CampaignMember();
    private static HDT_SRV_CampaignMember campaignMemberSrv = new HDT_SRV_CampaignMember();
    private static HDT_QR_Contact contactQr = new HDT_QR_Contact();

    @AuraEnabled(cacheable=true)
    public static List <CampaignMember> getCampaigns(String id, String objectName) {
        String objIdField;

        campaignMemberSrv.checkReadAccess('Campaign.Name,Campaign.Status,Campaign.Channel__c,Campaign.EndDate');

        if (objectName == 'Contact') {
            //return all active campaigns related to this Contact
            return  campaignMemberQr.getActiveCampaignsByContact(id);
        } else if(objectName == 'Lead') {
            //return all active campaigns related to this Lead
            return campaignMemberQr.getActiveCampaignsByLead(id);
        } else if(objectName == 'Account') {
            //return all active campaigns related to all contacts related to this Account
            List<Contact> contacts = contactQr.getContactsByAccount(id);
            return campaignMemberQr.getActiveCampaignsByContacts(contacts);
        } else {
            return null;
        }
    }
}
