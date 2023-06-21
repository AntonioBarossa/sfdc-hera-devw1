@IsTest
public with sharing class HDT_LC_InterventionDependencyTst {
    
    @TestSetup
    static void setup(){

        HDT_UTL_DataFactoryTst.createCityTechnicalData(1, true, 'City -0', Date.today(), Date.today().addDays(30), Date.today().addDays(31), 'Error message');

        List<EquipmentAdministration__c> eas = HDT_UTL_DataFactoryTst.createEquipmentAdministrations(2, false);
        eas.get(0).City__c = 'City -0';
        eas.get(1).City__c = 'City -0';

        insert eas;
        
    }

    @IsTest
    static void generatePicklistsDataTest(){
        
        Test.startTest();

        Map<String, Object> result = HDT_LC_InterventionDependency.generatePicklistsData('City -0');

        system.assertEquals(((Map<String, Set<Object>>) result.get('materials')).isEmpty(), false, 'The list of materials was not retrieved corectly');
        
        Test.stopTest();
        
    }
}