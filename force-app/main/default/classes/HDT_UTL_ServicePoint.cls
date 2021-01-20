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
    @AuraEnabled
    public static string methodName(){
      Mapz<string,string> mapNumberFields = new Map<string,string>();
    }
    
    @AuraEnabled(cacheable=true)
    public static  HDT_WRP_AddressObject getInstanceWrapAddressObject (ServicePoint__c s ){
    System.debug('HDT_UTL_ServicePoint - getInstanceWrapAddressObject START');
    //Map<string,string> result = new Map<string,string>();
    HDT_WRP_AddressObject result = new HDT_WRP_AddressObject();
    if(s!= null){
        System.debug('HDT_UTL_ServicePoint - getInstanceWrapAddressObject END');
        return  result =   mapFieldsAddressWithWrapObject(s);
    }else{     
    
        result = new HDT_WRP_AddressObject('','','','','','','','','');
        System.debug('result:' +  result);
    }
    System.debug('HDT_UTL_ServicePoint - getInstanceWrapAddressObject END');
    return result;

    
    }

    @AuraEnabled(cacheable=true)
    public static HDT_WRP_AddressObject mapFieldsAddressWithWrapObject(ServicePoint__c s){
        System.debug('HDT_UTL_ServicePoint - mapFieldsAddressWithWrapObject START');
        HDT_WRP_AddressObject h = new HDT_WRP_AddressObject();
        
        h.CAP= s.SupplyPostalCode__c;
        h.Comune=s.SupplyCity__c;
        h.Via=s.SupplyStreet__c;
        h.Civico= s.SupplyStreetNumber__c;
        h.EstensCivico=s.SupplyStreetNumberExtension__c;
        h.Provincia=s.SupplyProvince__c;
        h.Stato=s.SupplyCountry__c;
        h.CodiceComuneSAP= s.SupplySAPCityCode__c;
        h.CodiceViaStradarioSAP=s.SupplySAPStreetCode__c;
        
        
        System.debug('HDT_UTL_ServicePoint - mapFieldsAddressWithWrapObject END');
        return h;
        
    }
}
