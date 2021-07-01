public with sharing class HDT_SRV_Campaign {
    public static List<Campaign> insertCampaigns(List<Campaign> lCamp){
       
        HDT_UTL_DatabaseService.insertSObject(lCamp);
        
        return lCamp;
    }
    public static List<Campaign> updateCampaigns(List<Campaign> lCamp){
       
        HDT_UTL_DatabaseService.updateSObject(lCamp);
        
        return lCamp;
    }
}
