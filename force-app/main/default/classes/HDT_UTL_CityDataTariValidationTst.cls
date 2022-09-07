/**
 * @author Marco Arci (marco.arci@webresults.it)
 * @date 06/09/2022
 * @description Test Classe HDT_UTL_CityDataTariValidation
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */

@isTest
public with sharing class HDT_UTL_CityDataTariValidationTst {
    
    @TestSetup
    static void createData(){

        List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','MMS Azienda','Aziende SME');
        Id accId = accs[0].id;

        List<CityTechnicalData__c> cityData =  HDT_UTL_DataFactoryTst.createCityTechnicalData(1, true, 'Comune',convertDdMmYyyy('2022-08-01'), convertDdMmYyyy('2022-08-31'), convertDdMmYyyy('2022-09-05'),'Error Test');
        

        List<Case> listFakeCases = HDT_UTL_DataFactoryTst.createCase(4, false, accId, null, null, null, null);
        listFakeCases[0].SupplyCity__c = 'Comune';
        listFakeCases[0].Amount__c = 1;
        listFakeCases[0].EffectiveDate__c = convertDdMmYyyy('2022-08-15');
        listFakeCases[0].DeclarationDate__c = convertDdMmYyyy('2022-09-02');
        listFakeCases[1].SupplyCity__c = 'Comune';
        listFakeCases[1].Amount__c = 2;
        listFakeCases[1].EffectiveDate__c = convertDdMmYyyy('2022-08-15');
        listFakeCases[1].DeclarationDate__c = convertDdMmYyyy('2022-09-06');
        listFakeCases[2].SupplyCity__c = 'Comune';
        listFakeCases[2].Amount__c = 3;
        listFakeCases[2].EffectiveDate__c = convertDdMmYyyy('2022-07-25');
        listFakeCases[2].DeclarationDate__c = convertDdMmYyyy('2022-09-02');
        listFakeCases[3].SupplyCity__c = 'Comune';
        listFakeCases[3].Amount__c = 4;
        insert listFakeCases;



    }

    @isTest
    static void test_1(){
        
        Map<String, Object> mapFields = new Map<String, Object>();
        mapFields.put('DeclarationDate__c','2022-09-02');
        mapFields.put('EffectiveDate__c','2022-08-15');

        String serializeMap = JSON.serialize(mapFields);

        HDT_UTL_CityDataTariValidation CityDataTariValidation = new HDT_UTL_CityDataTariValidation();

        Test.startTest();
            String result = CityDataTariValidation.validate(serializeMap, [SELECT Id 
                                                                           FROM Case 
                                                                           WHERE SupplyCity__c = 'Comune' 
                                                                           AND Amount__c = 1
                                                                           Limit 1].Id);        
        Test.stopTest();

        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);

        system.assertEquals('Success', resultMap.get('outcomeDescription'));
    }

    @isTest
    static void test_2(){
        
        Map<String, Object> mapFields = new Map<String, Object>();
        mapFields.put('DeclarationDate__c','2022-09-06');
        mapFields.put('EffectiveDate__c','2022-08-15');

        String serializeMap = JSON.serialize(mapFields);

        HDT_UTL_CityDataTariValidation CityDataTariValidation = new HDT_UTL_CityDataTariValidation();

        Test.startTest();
            String result = CityDataTariValidation.validate(serializeMap, [SELECT Id 
                                                                           FROM Case 
                                                                           WHERE SupplyCity__c = 'Comune' 
                                                                           AND Amount__c = 2
                                                                           Limit 1].Id);        
        Test.stopTest();

        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);

        system.assertEquals('La data di contatto è successiva a quella di fine cut-over!', resultMap.get('outcomeDescription'));

    }

    @isTest
    static void test_3(){
        
        Map<String, Object> mapFields = new Map<String, Object>();
        mapFields.put('DeclarationDate__c','2022-09-02');
        mapFields.put('EffectiveDate__c','2022-07-25');

        String serializeMap = JSON.serialize(mapFields);

        HDT_UTL_CityDataTariValidation CityDataTariValidation = new HDT_UTL_CityDataTariValidation();

        Test.startTest();
            String result = CityDataTariValidation.validate(serializeMap, [SELECT Id 
                                                                           FROM Case 
                                                                           WHERE SupplyCity__c = 'Comune' 
                                                                           AND Amount__c = 3
                                                                           Limit 1].Id);
        Test.stopTest();

        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);

        system.assertEquals('La Data di decorrenza è precedente alla data inizio o successiva alla data fine del servizio ambiente.', resultMap.get('outcomeDescription'));

    }

    @isTest
    static void test_4(){
        
        Map<String, Object> mapFields = new Map<String, Object>();
        mapFields.put('DeclarationDate__c',null);
        mapFields.put('EffectiveDate__c',null);

        String serializeMap = JSON.serialize(mapFields);

        HDT_UTL_CityDataTariValidation CityDataTariValidation = new HDT_UTL_CityDataTariValidation();

        Test.startTest();
            String result = CityDataTariValidation.validate(serializeMap, [SELECT Id 
                                                                           FROM Case 
                                                                           WHERE SupplyCity__c = 'Comune' 
                                                                           AND Amount__c = 4 
                                                                           Limit 1].Id);
        Test.stopTest();

        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);

        system.assertEquals('Error Test', resultMap.get('outcomeDescription'));

    }

    public Static Date convertDdMmYyyy(String ddmmyyyy)
    {
        if(String.isNotBlank(ddmmyyyy)){
            List<String> listToConvert = ddmmyyyy.split('-');
            return Date.newInstance(Integer.valueOf(listToConvert[0]), Integer.valueOf(listToConvert[1]), Integer.valueOf(listToConvert[2]));
        }
        return null;
    }
}
