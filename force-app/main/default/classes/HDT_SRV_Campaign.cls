/**
* @author Lorenzo (lorenzo.gulotta@webresults.it)
* @date 24/06/2021
* @description HDT_SRV_Campaign.cls
* @history Lorenzo – 24/06/2021 – created class
*/
public with sharing class HDT_SRV_Campaign {
    public static List<Campaign> insertCampaigns(List<Campaign> lCamp){
       
        //HDT_UTL_DatabaseService.insertSObject(lCamp);
        if (HDT_UTL_DatabaseService.checkBeforeDml(lCamp, HDT_UTL_DatabaseService.DmlOperation.DML_INSERT)) {
            return null;
        }
        Database.insert(lCamp, false);
        return lCamp;
    }
    public static List<Campaign> updateCampaigns(List<Campaign> lCamp){
       
        //HDT_UTL_DatabaseService.updateSObject(lCamp);
        if (HDT_UTL_DatabaseService.checkBeforeDml(lCamp, HDT_UTL_DatabaseService.DmlOperation.DML_UPDATE)) {
            return null;
        }
        unableToLockRowManagement(lCamp,0);
                
        return lCamp;
    }

    @testVisible
    private static void unableToLockRowManagement(List<SObject> sObjectList, Integer updateNumber) {
        try{
            Database.update(sObjectList, false);
        }catch(Exception ex){
            if (ex.getMessage().contains('UNABLE_TO_LOCK_ROW') && updateNumber < 5){
                updateNumber++;
                unableToLockRowManagement(sObjectList,updateNumber);
            }else{
                throw ex;
            }
        }
    }
}
