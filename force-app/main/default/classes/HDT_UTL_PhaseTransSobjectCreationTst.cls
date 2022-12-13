/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 20-10-2022
 * @last modified by  : Giacinto Florio
**/
@isTest
public with sharing class HDT_UTL_PhaseTransSobjectCreationTst {
    
    public static HDT_UTL_PhaseTransSobjectCreation myObjectToTest = new HDT_UTL_PhaseTransSobjectCreation();
    
    @TestSetup
    static void myData(){
      	HDT_UTL_DataFactoryTst.pClickCasePhase();
        List<Account> accounts = HDT_UTL_DataFactoryTst.createAccountResidenziale(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
        HDT_UTL_DataFactoryTst.createOrder(1, true, accounts[0].Id, 'Bozza');
    }

    @isTest
    public static void testPhaseTransSobjectCreation(){
        List<Order> ord            = [SELECT Id,Phase__c,PhaseStory__c,OrderReference__c FROM Order WHERE Phase__c = 'Annullato'];
        Map<String,Object> argsMap = new Map<String,Object>{'parameter' => new Map<String, Object>{'records'=> ord }};
        argsMap.put('method', 'FacilityApproval');

        Test.startTest();
        Object result = myObjectToTest.execute(argsMap);
        HDT_UTL_PhaseTransSobjectCreation.insertBulkSobjects();
        Test.stopTest();
        System.assertEquals(null, result=null, 'The result should  be null!');
    }
}