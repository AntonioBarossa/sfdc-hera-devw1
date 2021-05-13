public with sharing class HDT_QR_City {
    public static String getCityCode(String city){

        String query = 'SELECT BelfioreCode__c FROM City__c WHERE Name = :city WITH SECURITY_ENFORCED';
        List<City__c>  municipalities= Database.query(query);
        if(municipalities.size()>0){
            return municipalities[0].BelfioreCode__c;
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
}