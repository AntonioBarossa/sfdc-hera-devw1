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
     public static String updateAllOrder(Sale__c sale){
        try {
            List<SObject> orderToUpdate = new List<SObject>();
            for(SObject ord : HDT_QR_GenericQuery.getGenericRecords('Id','Order', 'Sale__c =\''+sale.Id+'\'')){
                ord.put('Agency__c',String.isNotBlank(sale.Agency__c)? sale.Agency__c : null);
                ord.put('AgencyCode__c',String.isNotBlank(sale.AgencyCode__c) ? sale.AgencyCode__c : null);
                ord.put('VendorLastName__c',String.isNotBlank(sale.VendorLastName__c) ? sale.VendorLastName__c : null);
                ord.put('VendorFirstName__c',String.isNotBlank(sale.VendorFirstName__c) ? sale.VendorFirstName__c : null);
                ord.put('CommercialId__c',String.isNotBlank(sale.CommercialId__c) ? sale.CommercialId__c : null);
                ord.put('UpperChannelAgency__c',String.isNotBlank(sale.UpperChannelAgency__c) ? sale.UpperChannelAgency__c : null);
                ord.put('LowerChannelAgency__c',String.isNotBlank(sale.LowerChannelAgency__c) ? sale.LowerChannelAgency__c : null);
                ord.put('AreaManager__c',String.isNotBlank(sale.AreaManager__c) ? sale.AreaManager__c : null);
                orderToUpdate.add(ord);
            }
            HDT_UTL_DatabaseService.updateSObject(orderToUpdate);
        } catch (Exception e) {
            throw new AuraHandledException('Attenzione! '+e.getMessage());
        }
        return 'SUCCESS';
     }
}