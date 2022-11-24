@isTest
public with sharing class HDT_QR_SelfReadingsTst {
    
    @isTest
    public static void getConfigurationByNameTest(){
        HDT_QR_SelfReadings qr = new HDT_QR_SelfReadings();
        List<HDT_SelfReadings__mdt> config =  qr.getConfigurationByName('Name');
        System.assert(config.size() == 0, 'Problema con la query');
    }

    @isTest
    public static void getDiscardConfigurationsTest(){
        HDT_QR_SelfReadings qr = new HDT_QR_SelfReadings();
        List<DiscardAnnullmentRule__c> config =  qr.getDiscardConfigurations(new Set<String>{'Name'});
        System.assert(config.size() == 0, 'Problema con la query');
    }

    @isTest
    public static void getReadingIdTest(){
        HDT_QR_SelfReadings qr = new HDT_QR_SelfReadings();
        Id recordId =  qr.getReadingId('Case', null, 'Gas');
        System.assert(recordId == null, 'Problema con la query');
    }

    @isTest
    public static void getReadingTest(){
        HDT_QR_SelfReadings qr = new HDT_QR_SelfReadings();
        Boolean exc = false;
        try{
            qr.getReading('Case', null, 'Gas','ReadingDigitNumberCorrector__c');
        }catch(Exception e){
            exc = true;
        }
        
        System.assert(exc, 'Problema con la query');
    }

    @isTest
    public static void getContractBySapCodeTest(){
        HDT_QR_SelfReadings qr = new HDT_QR_SelfReadings();
        Contract record =  qr.getContractBySapCode('12355458');
        System.assert(record == null, 'Problema con la query');
    }

    @isTest
    public static void accountOrdersCodeTest(){
        HDT_QR_SelfReadings qr = new HDT_QR_SelfReadings();
        List<Order> records =  qr.accountOrders('accountId', 'servicePointId', new List<Id>{Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_Autolettura').getRecordTypeId()}, new List<String> {'badPhases'}, new List<String> {'badStates'});
        System.assert(records.isEmpty(), 'Problema con la query');
    }
}
