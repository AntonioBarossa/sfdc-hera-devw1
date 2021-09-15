/**
* @author Lorenzo (lorenzo.gulotta@webresults.it)
* @date 24/06/2021
* @description HDT_SRV_Campaign.cls
* @history Lorenzo – 24/06/2021 – created class
*/
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
