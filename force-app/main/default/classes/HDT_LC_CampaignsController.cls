public inherited sharing class HDT_LC_CampaignsController {

    private static HDT_QR_CampaignMember campaignMemberQr = new HDT_QR_CampaignMember();
    private static HDT_SRV_CampaignMember campaignMemberSrv = new HDT_SRV_CampaignMember();
    private static HDT_QR_Contact contactQr = new HDT_QR_Contact();
    private static HDT_QR_Case caseQr = new HDT_QR_Case();
    private static HDT_SRV_Case caseSrv = new HDT_SRV_Case();

    @AuraEnabled(cacheable=true)
    public static List <CampaignMember> getCampaigns(String id, String objectName, String category, String channel) {
        campaignMemberSrv.checkReadAccess('Campaign.Name,Campaign.Status,Campaign.Channel__c,Campaign.EndDate');

        if (objectName == 'Contact') {
            //return all active campaigns related to this Contact
            return  campaignMemberQr.getActiveCampaignsByContact(id);
        } else if(objectName == 'Lead') {
            //return all active campaigns related to this Lead
            return campaignMemberQr.getActiveCampaignsByLead(id);
        } else if(objectName == 'Account') {
            //return all active campaigns related to all contacts related to this Account
            List<String> contacts = contactQr.getContactsIdByAccountId(id);
            if (category != '') {
                if (channel != '') {
                    return campaignMemberQr.filterCampaignsByCategoryAndChannel(contacts, category, channel);
                }
                return campaignMemberQr.filterCampaignsByCategory(contacts, category);
            }
            return campaignMemberQr.getCampaignsFilteredByContacts(contacts);
        } else {
            return null;
        }
    }

    @AuraEnabled
    public static void updateCampaignMemberStatus(String campaignMemberId, String statusValue){
        campaignMemberSrv.updateRecord(new CampaignMember(
            Id = campaignMemberId,
            Status = statusValue
        ));
    }

    @AuraEnabled
    public static Case createNewCase(Case c){
        Case newCase = caseSrv.createRecord(c);
        system.debug(newCase);
        return newCase;
    }

    @AuraEnabled(cacheable=true)
    public static List<CampaignMember> getUnassignedCampaignMembers(String campaignId) {
        return  campaignMemberQr.getUnassignedCampaignMembers(campaignId);
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> getAccountsforCampaignMembers() {
        return  campaignMemberQr.getAccountsforCampaignMembers();
    }
}