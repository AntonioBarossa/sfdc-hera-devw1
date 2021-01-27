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
    public static  HDT_WRP_AddressObject getInstanceWrapAddressObject (ServicePoint__c s ){
    System.debug('HDT_UTL_ServicePoint - getInstanceWrapAddressObject START');
    //Map<string,string> result = new Map<string,string>();
    HDT_WRP_AddressObject result = new HDT_WRP_AddressObject();
    if(s!= null){
        System.debug('HDT_UTL_ServicePoint - getInstanceWrapAddressObject END');
        return  result =   mapFieldsAddressWithWrapObject(s);
    }else{     
    

        result = new HDT_WRP_AddressObject('','','','','','','','','',false,false);

        System.debug('result:' +  result);
    }
    System.debug('HDT_UTL_ServicePoint - getInstanceWrapAddressObject END');
    return result;

    }


   /* @AuraEnabled(cacheable=true)
    public static HDT_WRP_AddressObject getServicePointToContract(string s){
        system.debug(' HDT_UTL_ServicePoint getServicePointToContract - START');
        ServicePoint__c servicePoint = new ServicePoint__c();
        HDT_WRP_AddressObject res = new HDT_WRP_AddressObject();

        servicePoint = [Select  SupplyCity__c, SupplyCountry__c,  SupplyPostalCode__c, SupplyProvince__c, SupplySAPCityCode__c, SupplySAPStreetCode__c, SupplyStreetNumberExtension__c, SupplyStreetNumber__c, SupplyStreet__c,supplyIsAddressVerified__c  FROM ServicePoint__c where Name = :s LIMIT 1 ]; 
        
        
        res = mapFieldsAddressWithWrapObject(servicePoint);
    
        system.debug(' HDT_UTL_ServicePoint getServicePointToContract - END');
        return res;
<<<<<<< HEAD
    }*/
=======

    }
>>>>>>> c17507a2dde9b39a4df2afa29868a5bd0b3772c5

    @AuraEnabled(cacheable=true)
    public static HDT_WRP_AddressObject mapFieldsAddressWithWrapObject(ServicePoint__c s){
        System.debug('HDT_UTL_ServicePoint - mapFieldsAddressWithWrapObject START');
        HDT_WRP_AddressObject h = new HDT_WRP_AddressObject();

        if(s.SupplyPostalCode__c==null){
            h.CAP= '';
        }else{
            h.CAP= s.SupplyPostalCode__c;
        }
        if(s.SupplyCity__c==null){
            h.Comune='';

        }else{
            h.Comune=s.SupplyCity__c;

        }
        if(s.SupplyStreet__c==null){
            h.Via='';

        }else{
            h.Via=s.SupplyStreet__c;

        }
        if(s.SupplyStreetNumber__c==null){
            h.Civico= '';

        }else{
            h.Civico= s.SupplyStreetNumber__c;

        }
        if(s.SupplyStreetNumberExtension__c==null){
            h.EstensCivico='';

        }else{
            h.EstensCivico=s.SupplyStreetNumberExtension__c;

        }
        if(s.SupplyProvince__c==null){
            h.Provincia='';

        }else{
            h.Provincia=s.SupplyProvince__c;

        }
        if(s.SupplyCountry__c==null){
            h.Stato='';

        }else{
            h.Stato=s.SupplyCountry__c;

        }
        if(s.SupplySAPStreetCode__c == null){
            h.CodiceViaStradarioSAP='';

        }else{
            h.CodiceViaStradarioSAP=s.SupplySAPStreetCode__c;

        }
        if(s.SupplySAPCityCode__c == null){
            h.CodiceComuneSAP= '';
        }else{
            h.CodiceComuneSAP= s.SupplySAPCityCode__c;
        }
 
            h.FlagVerificato = s.supplyIsAddressVerified__c;
        

        System.debug('HDT_UTL_ServicePoint - mapFieldsAddressWithWrapObject END');
        return h;
        
    }
}
