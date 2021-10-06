/**
* @author Lorenzo (lorenzo.gulotta@webresults.it)
* @date 23/06/2021
* @description HDT_QR_BusinessDate.cls
* @history Lorenzo – 23/06/2021 – created class
*/
public with sharing class HDT_QR_BusinessDate {
    public static string getWorkingBusinessDateConf(){
        List<BusinessHours> bList = [SELECT Id FROM BusinessHours WHERE Name = 'workDay' WITH SECURITY_ENFORCED];
        if(bList != null && !bList.isEmpty()){
            return bList[0].id;
        }
        else{
            return null;
        }
    }
}
