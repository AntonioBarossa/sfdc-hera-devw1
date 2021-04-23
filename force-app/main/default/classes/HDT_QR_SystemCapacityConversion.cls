public with sharing class HDT_QR_SystemCapacityConversion {

    public static String querySystemCapacity(String field, String value){

        String query;

        String fieldToQuery = field == 'CaliberClass' ? 'SystemCapacity__c' : 'CaliberRequested__c';

        String fieldToFilter = field == 'CaliberClass' ? 'CaliberRequested__c' : 'SystemCapacity__c';

        String result;

        if(Schema.SObjectType.HDT_SystemCapacityConfiguration__mdt.isAccessible() &&
        Schema.SObjectType.HDT_SystemCapacityConfiguration__mdt.fields.CaliberRequested__c.isAccessible() &&
        Schema.SObjectType.HDT_SystemCapacityConfiguration__mdt.fields.SystemCapacity__c.isAccessible()){

            if(fieldToFilter == 'SystemCapacity__c'){

                value = value.replace('.', ',');

            }
            
            query = 'SELECT ' + fieldToQuery + ' FROM HDT_SystemCapacityConfiguration__mdt WHERE ' + fieldToFilter + ' = \'' + value + '\'';            


            List<HDT_SystemCapacityConfiguration__mdt> listResult = Database.query(query);
            
            result = field == 'CaliberClass' ? listResult[0].SystemCapacity__c : listResult[0].CaliberRequested__c;

        } else {

            return 'Impossibile accedere al Metadato';

        }

        return result;

    }

}
