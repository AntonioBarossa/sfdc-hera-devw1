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
    public static CampaignMember updateCampaignMemberStatus(String campaignMemberId, String statusValue){
        try {
            CampaignMember cm = new CampaignMember(
                Id = campaignMemberId,
                Status = statusValue
            );
            campaignMemberSrv.updateRecord(cm);
            return cm;
        } catch (Exception e) {
            System.debug(e.getMessage());
            return null;
        }
    }

    @AuraEnabled
    public static Case createNewCase(Case c){
        Case newCase = caseSrv.createRecord(c);
        system.debug(newCase);
        return newCase;
    }
    @AuraEnabled
    public static List<CampaignMember> getUnassignedCampaignMembers(String campaignId) {
        return  campaignMemberQr.getUnassignedCampaignMembers(campaignId);
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> getAccountsforCampaignMembers() {
        return  campaignMemberQr.getAccountsforCampaignMembers();
    }

    @AuraEnabled
    public static CampaignMember getAccountAndCampaign(String campaignMemberId) {
        campaignMemberSrv.checkReadAccess('ContactId,LeadId,CampaignId,GenericField1__c');
        return  campaignMemberQr.getAccountAndCampaign(campaignMemberId);
    }

    @AuraEnabled
    public static List<CampaignMember> assignCampaignMemberAgency(String campaignId, List<Id> toAssignObj){
        List<CampaignMember> allUnassignedMembers = campaignMemberQr.getUnassignedCampaignMembers(campaignId);
        List<CampaignMember> assignedMembers = new List<CampaignMember>();
        for (Id agencyId : toAssignObj) {
            CampaignMember cm = allUnassignedMembers[0];
            cm.Agency__c = agencyId;
            assignedMembers.add(cm);
            allUnassignedMembers.remove(0);            
        }

        campaignMemberSrv.updateRecords(assignedMembers);
        return assignedMembers;
    }

    @AuraEnabled
    public static CampaignMember updateCampaignMemberSurveyResponse(String campaignMemberId, String surveyResponseId){
        try {
            CampaignMember cm = new CampaignMember(
                Id = campaignMemberId,
                SurveyResponse__c = surveyResponseId
            );
            campaignMemberSrv.updateRecord(cm);
            return cm;
        } catch (Exception e) {
            System.debug(e.getMessage());
            return null;
        }
    }
}