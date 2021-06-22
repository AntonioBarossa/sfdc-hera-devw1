/**
* @author Sabina Levonja (sabina.levonja@dunegroup.it)
* @date 10/03/2021
* @description HDT_QR_CampaignMemberStatus_mdt – Contains queries for HDT_CampaignMemberStatus__mdt
* @history Sabina Levonja – 10/03/2021 – created class 
*/

public inherited sharing class HDT_QR_CampaignMemberStatusMetadata {
    /**
     * @author Sabina Levonja (sabina.levonja@dunegroup.it)
     * @description Get HDT_CampaignMemberStatus_mdt records
     * @return List<HDT_CampaignMemberStatus__mdt>
     */
    public static List<HDT_CampaignMemberStatus__mdt> getRecords(){

        String query = 'SELECT Id, DeveloperName, MasterLabel, Category__c,Channel__c, HasResponded__c, Default__c FROM HDT_CampaignMemberStatus__mdt';
        List<HDT_CampaignMemberStatus__mdt> campaignStatuses = Database.query(query);

        return campaignStatuses;
    }
}
