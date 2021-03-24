public with sharing class HDT_UTL_ServicePoint {

    public HDT_UTL_ServicePoint() {

    }
    @AuraEnabled
    public static List<String> objectToList(HDT_WRP_AddressObject Wrap){
        System.debug('HDT_UTL_ServicePoint objectToList START');

        List<String> listFields = new List<String>();
        String stringWrap = JSON.serialize(Wrap);
        listFields = (List<String>)JSON.deserializeUntyped(stringWrap);

        System.debug('HDT_UTL_ServicePoint objectToList END');
        return listFields;

    }
 

    @AuraEnabled(cacheable=true)
    public static  HDT_WRP_AddressObject getInstanceWrapAddressObject(sObject s){
    System.debug('HDT_UTL_ServicePoint - getInstanceWrapAddressObject START');

    Map<String,String> mapApiName = new map<String,String>{	
        'SupplyPostalCode__c' => 'CAP',
        'SupplyStreetNumber__c' => 'Civico',
        'SupplyCountry__c' => 'Stato',
        'SupplySAPCityCode__c' => 'CodiceComuneSAP',
        'SupplyCity__c' => 'Comune',
        'SupplyStreet__c' => 'Via',
        'SupplyStreetNumberExtension__c' => 'EstensCivico',
        'SupplySAPStreetCode__c' => 'CodiceViaStradarioSAP',
        'SupplyIsAddressVerified__c' => 'IndirizzoVerificato',
        'SupplyProvince__c' => 'Provincia',
        'SupplyIsAddressVerified__c' => 'FlagVerificato'
        };

   
    HDT_WRP_AddressObject result = new HDT_WRP_AddressObject();

    if(s!= null){
        System.debug('HDT_UTL_ServicePoint - getInstanceWrapAddressObject END');
        List<sObject> listObject = new  List<sObject>();
        listObject.add((sObject)s);
        String type = listObject.get(0).getSObjectType().getDescribe().getName();
        Map<String,Boolean> mapBooleanObject = new Map<String,Boolean>();
        Map<String,String> mapObject = new Map<String,String>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objectSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap();
    
        for (String fieldName: fieldMap.keySet()) 
        {
            //System.debug('Field API Name='+fieldName+'label :'+fieldMap.get(fieldName).getDescribe().getLabel());
            Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
            if(fielddataType.name().toUpperCase() == 'STRING' || fielddataType.name().toUpperCase() == 'TEXTAREA'|| fielddataType.name().toUpperCase() == 'TEXT')
            {
                mapObject.put(fieldMap.get(fieldName).getDescribe().getName(),(String)(s.get(fieldName)));
            }
            if(fielddataType.name().toUpperCase() == 'BOOLEAN'||fielddataType.name().toUpperCase() == 'CHECKBOX' ){
                mapBooleanObject.put(fieldMap.get(fieldName).getDescribe().getName(),(Boolean)(s.get(fieldName)));
            }                
        }
        system.debug('mapObject*************'+mapObject);
        system.debug('mapBooleanObject*************'+mapBooleanObject);
        return  result =   mapFieldsAddressWithWrapObject(mapObject,mapBooleanObject,mapApiName);

    }else{     
    
        result = new HDT_WRP_AddressObject('','','','','','','','','',false,false);
        System.debug('result:' +  result);
    }

	
    System.debug('HDT_UTL_ServicePoint - getInstanceWrapAddressObject END');
    return result;
    }
	
	
	
	@AuraEnabled(cacheable=true)
    public static HDT_WRP_AddressObject mapFieldsAddressWithWrapObject(Map<String,String> mapObject,Map<String,Boolean> mapBooleanObject,Map<String,String> mapApiName){
        System.debug('HDT_UTL_ServicePoint - mapFieldsAddressWithWrapObject START');
        HDT_WRP_AddressObject h = new HDT_WRP_AddressObject();
		
		if(!mapObject.isEmpty()){
            for(String s :mapObject.keySet()){
                system.debug('stringa *****************' + s);
                
                if(mapApiName.containsKey(s) && s == 'SupplyPostalCode__c'){
                    System.debug('CAP :' + mapObject.get(s));
                    h.CAP = mapObject.get(s);
                }
                if(mapApiName.containsKey(s) && s == 'SupplyCity__c'){
                    System.debug('Comune :' + mapObject.get(s));
                    h.Comune= mapObject.get(s);
                }
                if(mapApiName.containsKey(s) && s == 'SupplyStreet__c'){
                    System.debug('Via :' + mapObject.get(s));
                    h.Via= mapObject.get(s);
                }
                if(mapApiName.containsKey(s) && s == 'SupplyStreetNumber__c'){
                    System.debug('Civico :' + mapObject.get(s));
                    h.Civico= mapObject.get(s);
                }
                if(mapApiName.containsKey(s) && s == 'SupplyStreetNumberExtension__c'){
                    System.debug('EstensCivico :' + mapObject.get(s));
                    h.EstensCivico= mapObject.get(s);
                }
                if(mapApiName.containsKey(s) && s == 'SupplyProvince__c'){
                    System.debug('Provincia :' + mapObject.get(s));
                    h.Provincia= mapObject.get(s);
                }
                if(mapApiName.containsKey(s) && s == 'SupplyCountry__c'){
                    System.debug('Stato :' + mapObject.get(s));
                    h.Stato= mapObject.get(s);
                }
                if(mapApiName.containsKey(s) && s == 'SupplySAPCityCode__c'){
                    System.debug('CodiceComuneSAP :' + mapObject.get(s));
                    h.CodiceComuneSAP= mapObject.get(s);
                }
                if(mapApiName.containsKey(s) && s == 'SupplySAPStreetCode__c'){
                    System.debug('CodiceViaStradarioSAP :' + mapObject.get(s));
                    h.CodiceViaStradarioSAP= mapObject.get(s);
                }
            }
        }

        if(!mapBooleanObject.isEmpty())
        {
            for(String b :mapBooleanObject.keySet())
            {
                if(mapApiName.containsKey(b)&& b == 'SupplyIsAddressVerified__c')
                {
                    System.debug('flagVerificato :' + mapBooleanObject.get(b));
                    h.flagVerificato= mapBooleanObject.get(b);
                }
            }
        }
        system.debug('wrapObject: ***************' + h);

          
        System.debug('HDT_UTL_ServicePoint - mapFieldsAddressWithWrapObject END');
        return h;
        
    }
}
