/**
* @author Luis Bispo (luis.bispo@engdb.com.br)
* @date 12/07/2021
* @description HDT_LC_CalculateEstimatedCost for Test Classes
* @history Luis Bispo – 12/07/2021 – Created class
*/

@isTest
public with sharing class HDT_LC_CalculateEstimatedCostTst {
    
    @testSetup
        static void setup(){
            HDT_UTL_DataFactoryTst.pClickOrderPhase();
            List<Account> acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
            HDT_UTL_DataFactoryTst.createOrder(1, true, acc[0].Id, 'Bozza');
        }

    @isTest
    public static void testUpdateOrder(){
        Test.startTest();
        
        Order updateOrder = [SELECT id, Status, EstimateAmount__c, PowerQuote__c, AdministrativeBurden__c, EstimatedVAT__c, ValidityDateEstimate__c, Phase__c
                            FROM Order
                            WHERE Status = 'Draft'
                            LIMIT 1];

        HDT_LC_CalculateEstimatedCost.updateOrder(updateOrder);

        
        System.assertEquals(1000.00, updateOrder.EstimateAmount__c, 'EstimateAmount__c not correct!');

        System.assertNotEquals(2000.00, updateOrder.EstimateAmount__c);

        Test.stopTest();
    }
}