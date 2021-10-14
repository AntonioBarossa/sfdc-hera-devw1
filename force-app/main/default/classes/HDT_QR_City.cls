/**
 * @author Lorenzo Gulotta (lorenzo.gulotta@webresults.it)
 * @date 12/05/2021
 * @description HDT_QR_ServiceCatalog Class
 * @history Lorenzo Gulotta – 12/05/2021 – Created Class
 */

public with sharing class HDT_QR_City {
    public static String getCityCode(String city){

        String query = 'SELECT BelfioreCode__c FROM City__c WHERE Name = :city AND BelfioreCode__c != null WITH SECURITY_ENFORCED';
        List<City__c>  municipalities= Database.query(query);
        if(municipalities.size()>0){
            return municipalities[0].BelfioreCode__c;
        }else{
            return '';
        }
    }
    public static String getCitySDVEle(String city){

        String query = 'SELECT SDV__c FROM City__c WHERE Name = :city AND ServiceEle__c = true AND SDV__c != null WITH SECURITY_ENFORCED';
        List<City__c>  municipalities= Database.query(query);
        if(municipalities.size()>0){
            return municipalities[0].SDV__c;
        }else{
            return '';
        }
    }
    public static List<City__c> getCitySDVList(List<String> city){

        String query = 'SELECT Name,SDV__c,ServiceGas__c,ServiceEle__c FROM City__c WHERE Name IN :city  AND SDV__c != null WITH SECURITY_ENFORCED';
        return Database.query(query);
    }
    public static String getCitySDVGas(String city){

        String query = 'SELECT SDV__c FROM City__c WHERE Name = :city AND ServiceGas__c = true AND SDV__c != null WITH SECURITY_ENFORCED';
        List<City__c>  municipalities= Database.query(query);
        if(municipalities.size()>0){
            return municipalities[0].SDV__c;
        }else{
            return '';
        }
    }
    public static Map<String,String> getCityFromCode(List<String> codes){
        Map<String,String> cities= new Map<String,String>();
        String query = 'SELECT Name, BelfioreCode__c FROM City__c WHERE BelfioreCode__c IN :codes WITH SECURITY_ENFORCED';
        List<City__c>  municipalities= Database.query(query);
        for(City__c c:municipalities){
            cities.put(c.BelfioreCode__c, c.Name);
        }
        return cities;
    }
    public static List<City__c> getRecordByComune(String comune){
       
        String query = 'SELECT Name, BelfioreCode__c, Province__c FROM City__c WHERE Name = :comune WITH SECURITY_ENFORCED';
        List<City__c>  municipalities= Database.query(query);
       
        return municipalities;
    }
}