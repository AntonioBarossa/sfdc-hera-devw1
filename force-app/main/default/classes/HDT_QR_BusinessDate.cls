public with sharing class HDT_QR_BusinessDate {
    public static string getWorkingBusinessDateConf(){
        List<BusinessHours> bList = [SELECT Id FROM BusinessHours WHERE Name = 'workDay'];
        if(bList != null && !bList.isEmpty()){
            return bList[0].id;
        }
        else{
            return null;
        }
    }
}
