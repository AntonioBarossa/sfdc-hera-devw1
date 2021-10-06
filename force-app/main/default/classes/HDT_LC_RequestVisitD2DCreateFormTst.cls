/**
 * Header of the class "HDT_LC_RequestVisitD2DCreateFormTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_LC_RequestVisitD2DCreateForm"
 * @history
 * @Created 29/09/2021
 * Modified By:
 **/
@isTest
public class HDT_LC_RequestVisitD2DCreateFormTst {
    
    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
    
    @TestSetup
    static void makedata(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserPermissionsMarketingUser=true;

		insert internalUser;

        System.runAs(internalUser){
            
            HDT_UTL_DataFactoryTst.pClickInstance();
            
            List<Lead> leads = HDT_UTL_DataFactoryTst.createLead(1,true);
            
            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,false,'MMS','MMS Azienda','Aziende SME');
            for(Account a : accs){
                a.Name = 'test00';
            }
            insert accs;
            Id accId = accs[0].id;
        
            List<VisitAssignmentRules__c> visits = HDT_UTL_DataFactoryTst.createVisitAssignmentRules(1,false);
            for(VisitAssignmentRules__c v : visits){
                v.cap__c = '12345';
                v.Category__c = 'Azienda'; 
                v.Consumption__c = 'TOP: oltre i valori del MEDIUM';
            }
            insert visits;
            Id visitId = visits[0].id;
            
            
            List<PercentageRulesForAssigningVisits__c> percentages = HDT_UTL_DataFactoryTst.createPercentageRulesForAssigningVisits(1,false,'testname',visitId);
            for(PercentageRulesForAssigningVisits__c p : percentages){
                p.Agency__c = accId;
                p.PercentageOfAssignment__c = 10;
                p.VisitAssignmentRules__c = visitId;
            }
            insert percentages;
            
            Group g = new Group();
            g.Name = 'testgroup';
            g.developername= 'HDT_QUE_test00';
            g.Type = 'Queue';
            insert g;
            
            List<wrts_prcgvr__Activity__c> activity = HDT_UTL_DataFactoryTst.createActivityCustom(1,false,accId);
            for(wrts_prcgvr__Activity__c ac : activity){
                ac.Approved__c = 'Si';
                ac.OwnerId = g.id;
            }
            insert activity;
            
            QueueSobject mappingObject = new QueueSobject(QueueId = g.Id, SobjectType = 'wrts_prcgvr__Activity__c');
            insert mappingObject;
            
            List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(1,false,accId);
            for(Contact c : contacts)
                c.Company__c='MMS';
            insert contacts;

        }
    }
    
	@isTest
    static void testCreateActivityFromLead(){
        
        String leadId = [SELECT id from Lead].id;
        String zipCode = '12345';
        String category = 'Azienda';
        String consumption = 'TOP: oltre i valori del MEDIUM';
        
        Test.startTest();
        
        Id result = HDT_LC_RequestVisitD2DCreateForm.createActivityFromLead(leadId,zipCode,category,consumption);
        
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'An activity was not created');
        
        System.assertEquals(1,[SELECT id, consumption__c FROM Lead where consumption__c =: consumption].size(), 'One Lead not correctly updated');

    }
    
    @isTest
    static void createActivityFromContact(){
        
        String contactId = [SELECT id from Contact].id;
        String zipCode = '12345';
        String category = 'Azienda';
        String consumption = 'TOP: oltre i valori del MEDIUM';
        
        Test.startTest();
        
        Id result = HDT_LC_RequestVisitD2DCreateForm.createActivityFromContact(contactId,zipCode,category,consumption);
        
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'An activity was not created');
        
        System.assertEquals(1,[SELECT id, consumption__c FROM Contact where consumption__c =: consumption].size(), 'One Contact not correctly updated');

    }
}