public with sharing class HDT_LC_SoldByController {
     @AuraEnabled
     public static string getSaleChannel(Id saleId){
        String channel = '';
        try {
            channel = (String) HDT_QR_GenericQuery.getGenericRecords('Id,Channel__c', 'Sale__c', 'Id =\''+String.escapeSingleQuotes(saleId)+'\'').get(0).get('Channel__c');
        } catch (Exception e) {
            throw new AuraHandledException('Attenzione! '+e.getMessage());
        }
        return channel;
     }

     @AuraEnabled
     public static string updateAllOrder(Sale__c sale){
        try {
            List<SObject> orderToUpdate = new List<SObject>();
            for(SObject ord : HDT_QR_GenericQuery.getGenericRecords('Id','Order', 'Sale__c =\''+sale.Id+'\'')){
                ord.put('Agency__c',sale.Agency__c);
                ord.put('AgencyCode__c',sale.AgencyCode__c);
                ord.put('VendorLastName__c',sale.VendorLastName__c);
                ord.put('VendorFirstName__c',sale.VendorFirstName__c);
                ord.put('CommercialId__c',sale.CommercialId__c);
                ord.put('UpperChannelAgency__c',sale.UpperChannelAgency__c);
                ord.put('LowerChannelAgency__c',sale.LowerChannelAgency__c);
                ord.put('AreaManager__c',sale.AreaManager__c);
                orderToUpdate.add(ord);
            }
            HDT_UTL_DatabaseService.updateSObject(orderToUpdate);
        } catch (Exception e) {
            throw new AuraHandledException('Attenzione! '+e.getMessage());
        }
        return 'SUCCESS';
     }
}