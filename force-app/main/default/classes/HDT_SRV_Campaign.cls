public with sharing class HDT_SRV_Campaign {
    public static List<Campaign> insertCampaigns(List<Campaign> lCamp){
       
        HDT_UTL_DatabaseService.insertSObject(lCamp);
        
        return lCamp;
    }
    
}
