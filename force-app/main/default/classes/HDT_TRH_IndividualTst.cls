/**
* @author Luis Bispo (luis.bispo@engdb.com.br)
* @date 10/09/2021
* @description HDT_TRH_IndividualTst for Test Classes
* @history Luis Bispo – 10/09/2021 – Created class
*/
@isTest
public with sharing class HDT_TRH_IndividualTst {

    @isTest
    static void testBeforeInsert() {
        User tUser = [SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1]; 
        System.runAs(tUser){
            Test.startTest();
            List<Individual> idv = HDT_UTL_DataFactoryTst.createIndividual(1, true);

            System.assertEquals(true, idv != null,'Individual is not created');
            System.assertNotEquals(null, idv, 'Individual is not created');
            Test.stopTest();
        }
    }
}
