/**
Header of the class "HDT_ActivityCustomTst"
@author Pooyan Ghadiri Abkenar, pooyan.ghadiriabkenar@webresults.it
@Version 1.0
@description: Apex Test Class of the relative Apex Class "HDT_ActivityCustom"
@history
@created 30/09/2021
Modified By:
**/

@isTest
public with sharing class HDT_ActivityCustomTst {

    @isTest
    public static void testActivityCustomTst() {

        HDT_UTL_DataFactoryTst.pClickInstance();
        
        List<Account> testAcc = HDT_UTL_DataFactoryTst.createAccountPartner(1,false, 'Pooyan');
        testAcc[0].CompanyOwner__c = 'HERA COMM';

        insert testAcc;

        Id acctId = testAcc[0].id;


        List<wrts_prcgvr__Activity__c> testActCust = HDT_UTL_DataFactoryTst.createActivityCustom(1,true, acctId);

        system.assertNotEquals('', testActCust[0].id , 'ActivityCustom is not created (ActivityCustom trigger)');
        system.assertEquals(true, testActCust[0].id != null,'ActivityCustom is not created (ActivityCustom trigger)' );
    }
}
