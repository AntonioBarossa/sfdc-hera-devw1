public inherited sharing class HDT_LC_SystemCapacityConversion {

    @AuraEnabled
    public static String getSystemCapacity(String field, String value){

        return HDT_QR_SystemCapacityConversion.querySystemCapacity(field,value);

    }


}