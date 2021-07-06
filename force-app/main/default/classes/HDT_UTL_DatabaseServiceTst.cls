/**
* @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
* @date 30/06/2021
* @description Test Class for HDT_UTL_DatabaseServiceTst.cls
* @history Lucas da Silva Fernandes – 30/06/2021 – Created class
*/

@isTest
public with sharing class HDT_UTL_DatabaseServiceTst {
    
	@TestSetup
	static void setup() {

        HDT_UTL_DataFactoryTst.createLead();

        HDT_UTL_DataFactoryTst.createOpportunity(2);

    }

    @isTest
    static void testInsertSObject () {

        Test.startTest();

        //Retrieve and test a Lead
        Lead ld = new Lead();

        ld.FirstName = 'LeadNameTest';
        ld.LastName = 'LeadLastNameTest';
        ld.CompanyOwner__c = 'MMS';
        ld.Company = 'CompanyTest';
        ld.Status = 'New';
        ld.Email = 'testLead@test.com';

        Boolean insertLead = HDT_UTL_DatabaseService.insertSObject(ld);

        System.assertEquals(true, insertLead);

        System.assertNotEquals(false, insertLead);

        //Create and test an empty Lead
        Lead emptyLead = new Lead();

        Boolean insertEmptyLead;
        try {
            insertEmptyLead = HDT_UTL_DatabaseService.insertSObject(emptyLead);
        }
        catch (Exception e) {
            insertEmptyLead = false;
        }
        
        System.assertEquals(false, insertEmptyLead);

        System.assertNotEquals(true, insertEmptyLead);

        Test.stopTest();
    }

    @isTest
    static void testUpdateSObject () {

        //Retrieve and test
        Test.startTest();

        Lead ld = [SELECT Id 
                   FROM Lead
                   WHERE Email LIKE 'test@test.com'
                   LIMIT 1];
        
        ld.Email = 'test@testUpdateEmail.com';

        Boolean updateLead = HDT_UTL_DatabaseService.updateSObject(ld);
        
        System.assertEquals(true, updateLead);

        System.assertNotEquals(false, updateLead);

        Test.stopTest();
    }

    @isTest
    static void testUpsertSObject () {

        //Retrieve and test
        Test.startTest();

        Lead ld = [SELECT Id 
                   FROM Lead
                   WHERE Email LIKE 'test@test.com'
                   LIMIT 1];
        
        ld.Email = 'test@testUpsertEmail.com';

        Boolean upsertLead = HDT_UTL_DatabaseService.upsertSObject(ld);
        
        System.assertEquals(true, upsertLead);

        System.assertNotEquals(false, upsertLead);

        Test.stopTest();
    }

    @isTest
    static void testDeleteSObject () {
        
        //Retrieve and test
        Test.startTest();

        Lead ld = [SELECT Id 
                   FROM Lead
                   WHERE Email LIKE 'test@test.com'
                   LIMIT 1];

        Boolean deleteSObject = HDT_UTL_DatabaseService.deleteSObject(ld.Id);

        System.assertEquals(true, deleteSObject);

        System.assertNotEquals(false, deleteSObject);

        //Create and test an empty Lead
        Lead emptyLead = new Lead();

        Boolean deleteEmptyLead;

        try {
            deleteEmptyLead = HDT_UTL_DatabaseService.deleteSObject(emptyLead.Id);

        }

        catch (Exception e) {
            deleteEmptyLead = false;
        }
        
        System.assertEquals(false, deleteEmptyLead);

        System.assertNotEquals(true, deleteEmptyLead);
    }

    @isTest
    static void testDeleteSObjectList () {

        Test.startTest();

        //Retrieve and test Lead list
        List<Opportunity> oppList = new List<Opportunity>();

        oppList  = [SELECT Id 
                    FROM Opportunity
                    WHERE Name LIKE 'testOpportunity%'];

        Boolean deleteOppList = HDT_UTL_DatabaseService.deleteSObject(oppList);

        System.assertEquals(true, deleteOppList);
        
        System.assertNotEquals(false, deleteOppList);
        
        Test.stopTest();
    }

    @isTest
    static void testupsertSObjectExternalId() {

        Test.startTest();

        //Created a new List<Opportunity>
        List<Opportunity> oppList = new List<Opportunity>();

        for (Integer i=0; i<3; i++) {

            Opportunity opp = new Opportunity();

            opp.Name = 'testUpsertOpportunity'+ i;
            opp.CloseDate = Date.today().addDays(30);
            opp.StageName = 'Negotiation';

            oppList.add(opp);
        }   

        Boolean upsertSObjectExternalId = HDT_UTL_DatabaseService.upsertSObjectExternalId(oppList, 'Opportunity', 'Name');

        System.assertEquals(true, upsertSObjectExternalId);
        
        System.assertNotEquals(false, upsertSObjectExternalId);        

        Test.stopTest();
    }
}