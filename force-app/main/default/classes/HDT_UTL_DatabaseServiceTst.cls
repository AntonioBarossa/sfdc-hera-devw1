/**
* @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
* @date 30/06/2021
* @description Test Class for HDT_UTL_DatabaseServiceTst.cls
* @history Lucas da Silva Fernandes – 13/08/2021 – Updated class to increase coverage
*/

@isTest
public with sharing class HDT_UTL_DatabaseServiceTst {

    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    
	@TestSetup
	static void setup() {

        Id minimumAccessProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.MINIMUM_ACCESS_SALESFORCE);
        User minimumAccessUser=HDT_UTL_DataFactoryTst.createInternalUser(minimumAccessProfileId, false);
        minimumAccessUser.Email = 'sales@force.com';
        insert minimumAccessUser;

        List<Lead> leads = HDT_UTL_DataFactoryTst.createLead(1, true);
        
        HDT_UTL_DataFactoryTst.createOpportunity(2, true);

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

        System.assertEquals(true, insertLead, 'Lead Inserted');

        System.assertNotEquals(false, insertLead, 'Lead Inserted');

        //Create and test an empty Lead
        Lead emptyLead = new Lead();

        Boolean insertEmptyLead;
        try {
            insertEmptyLead = HDT_UTL_DatabaseService.insertSObject(emptyLead);
        }
        catch (Exception e) {
            insertEmptyLead = false;
        }
        
        System.assertEquals(false, insertEmptyLead, 'Empty Lead Inserted');

        System.assertNotEquals(true, insertEmptyLead, 'Empty Lead Inserted');

        Test.stopTest();
    }

    @isTest
    static void testUpdateSObject () {

        //Retrieve and test
        Test.startTest();

        Lead ld = [SELECT Id 
                   FROM Lead
                   WHERE Email LIKE 'test@test.com%'
                   LIMIT 1];
        
        ld.Email = 'test@testUpdateEmail.com';

        Boolean updateLead = HDT_UTL_DatabaseService.updateSObject(ld);
        
        System.assertEquals(true, updateLead, 'Lead Updated');

        System.assertNotEquals(false, updateLead, 'Lead Updated');

        User u=[SELECT Id FROM User WHERE Email='sales@force.com' LIMIT 1];

        System.runAs(u) {

            ld.Email = 'test@salesforce.com';

            try {
                updateLead = HDT_UTL_DatabaseService.updateSObject(ld);
            }
            catch (Exception e) {
                System.debug('Exception: '+ e);
            }
        }

        Test.stopTest();
    }

    @isTest
    static void testUpsertSObject () {

        //Retrieve and test
        Test.startTest();

        Lead ld = [SELECT Id 
                   FROM Lead
                   WHERE Email LIKE 'test@test.com%'
                   LIMIT 1];
        
        ld.Email = 'test@testUpsertEmail.com';

        Boolean upsertLead = HDT_UTL_DatabaseService.upsertSObject(ld);
        
        System.assertEquals(true, upsertLead, 'Lead Upserted');

        System.assertNotEquals(false, upsertLead, 'Lead Upserted');

        Test.stopTest();
    }

    @isTest
    static void testDeleteSObject () {
        
        //Retrieve and test
        Test.startTest();

        Lead ld = [SELECT Id 
                   FROM Lead
                   WHERE Email LIKE 'test@test.com%'
                   LIMIT 1];

        User u=[SELECT Id FROM User WHERE Email='sales@force.com' LIMIT 1];

        System.runAs(u) {

            try {
                Boolean deleteTest = HDT_UTL_DatabaseService.deleteSObject(ld.Id);
            }
            catch (Exception e) {
                System.debug('Exception: '+ e);
            }
        }

        Boolean deleteSObject = HDT_UTL_DatabaseService.deleteSObject(ld.Id);

        System.assertEquals(true, deleteSObject, 'Lead Deleted');

        System.assertNotEquals(false, deleteSObject, 'Lead Deleted');

        //Create and test an empty Lead
        Lead emptyLead = new Lead();

        Boolean deleteEmptyLead;

        try {
            deleteEmptyLead = HDT_UTL_DatabaseService.deleteSObject(emptyLead.Id);

        }

        catch (Exception e) {
            deleteEmptyLead = false;
        }
        
        System.assertEquals(false, deleteEmptyLead, 'Empty Lead Deleted');

        System.assertNotEquals(true, deleteEmptyLead, 'Empty Lead Deleted');

        Test.stopTest();
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

        System.assertEquals(true, deleteOppList, 'Opportunyty List Deleted');
        
        System.assertNotEquals(false, deleteOppList, 'Opportunyty List Deleted');
        
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

        System.assertEquals(true, upsertSObjectExternalId, 'External Object Upserted');
        
        System.assertNotEquals(false, upsertSObjectExternalId, 'External Object Upserted');        

        Test.stopTest();
    }
}