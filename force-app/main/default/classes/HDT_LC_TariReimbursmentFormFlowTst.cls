/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 24-03-2023
 * @last modified by  : Giacinto Florio
**/
@isTest
public with sharing class HDT_LC_TariReimbursmentFormFlowTst {
    @IsTest
    static void testGetRimborsoOptionsByCity(){
    
        CityReimbursmentType__c city = new CityReimbursmentType__c();
        city.City__c = 'ROMA';
        city.ReimbursmentType__c = 'Assegno';
        city.BeneficiaryType__c = 'Stesso Sottoscrittore;Erede;Beneficiario Alternativo';
        insert city;

        Test.startTest();
        List<HDT_LC_TariReimbursmentFormFlow.RimborsoOptionsByCity> results = HDT_LC_TariReimbursmentFormFlow.getRimborsoOptionsByCity();
        System.assertNotEquals(null, results, 'results not null');
        Test.stopTest();
    }
}