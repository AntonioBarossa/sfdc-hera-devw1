public with sharing class HDT_UTL_Lead {
    @AuraEnabled(cacheable=true)
    public static HDT_WRP_AddressObject getAddressObject(String Id){

        Lead lead= HDT_QR_Lead.getRecordById(Id);
        System.debug(lead);
        
        HDT_WRP_AddressObject a= new HDT_WRP_AddressObject();//lead.Country,lead.State , lead.City, lead.PostalCode, lead.Street, lead.StreetNumber__c, lead.CityCode__c, lead.StreetNumberExtension__c, lead.StreetCode__c,false,false);
        
        return a;
    }
    @AuraEnabled
    public static void updateLead(Lead lead){
        // System.debug(leadId);
        // Lead l= new Lead(Id= leadId);
        // for(String k: updatedValues.keySet()){
        //     address.put(k,updatedValues.get(k));
        // }
        // for(String s: address.keySet()){
        //     System.debug(address.get(s));
        // }
        // l.put('Country', address.get('Stato'));
        // l.put('State', address.get('Provincia'));
        // l.put('City', address.get('Comune'));
        // l.put('PostalCode', address.get('CAP'));
        // l.put('Street', address.get('Via'));
        // l.put('StreetNumber__c', address.get('Civico'));
        // l.put('StreetCode__c', address.get('CodiceViaStradarioSAP'));
        // l.put('CityCode__c', address.get('CodiceComuneSAP'));
        // l.put('StreetNumberExtension__c', address.get('EstensCivico'));

        HDT_SRV_Lead.checkUpdateAccess(lead);
        HDT_SRV_Lead.updateRecord(lead);
        System.debug(lead);

    }
}