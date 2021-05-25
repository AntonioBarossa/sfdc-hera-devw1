public with sharing class HDT_UTL_Lead {
    public static HDT_QR_Lead leadqr = new HDT_QR_Lead();
    
    @AuraEnabled
    public static HDT_WRP_AddressObject getAddressObject(String id){

        Lead lead= leadqr.getRecordById(Id);
        System.debug('HOLAHOLA:' + lead);
        
        HDT_WRP_AddressObject a= new HDT_WRP_AddressObject(lead.Country,lead.State , lead.City, lead.PostalCode, lead.StreetName__c, lead.StreetNumber__c, lead.CityCode__c, lead.StreetNumberExtension__c, lead.StreetCode__c,false,false);
        
        return a;
    }

    @AuraEnabled(cacheable=true)
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
    @AuraEnabled
    public static boolean updateLeadAddress(String recordid, Map<String,String> lead){
        // System.debug(leadId);
         Lead l= new Lead(Id= recordId);
         System.debug('HOLAEntry:'+ lead);
        // for(String k: updatedValues.keySet()){
        //     address.put(k,updatedValues.get(k));
        // }
        // for(String s: address.keySet()){
        //     System.debug(address.get(s));
        // }
        l.Country = lead.get('Stato');
        l.State = lead.get('Provincia');
        l.City = lead.get('Comune');
        l.PostalCode = lead.get('CAP');
        l.Street = lead.get('Via');
        l.StreetNumber__c = lead.get('Civico');
        l.StreetCode__c = lead.get('Codice Via Stradario SAP');
        l.CityCode__c = lead.get('Codice Comune SAP');
        l.StreetNumberExtension__c = lead.get('Estens.Civico');

        //HDT_SRV_Lead.checkUpdateAccess(l);
        HDT_SRV_Lead.updateRecord(l);
        System.debug(l);
        return true;
    }
}