/**
 * Header of the class "HDT_LC_SendCertificationRequestTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_LC_SendCertificationRequest"
 * @history
 * @Created 28/09/2021
 * Modified By:
 **/

@isTest
public class HDT_LC_SendCertificationRequestTst {

	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();

    @TestSetup
    static void makedata(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserPermissionsMarketingUser=true;

		insert internalUser;

        System.runAs(internalUser){
            
            List<Individual> inds = HDT_UTL_DataFactoryTst.createIndividual(1,true);
            Id individualId = inds[0].id;
            
            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(2,false,'HERA COMM','Azienda','Aziende SME');
            insert accs;
            Id accId = accs[0].id;
            
            HDT_UTL_DataFactoryTst.createContactPointPhone(1,true,individualId);
            
            List<ContactPointEmail> emailsInd = HDT_UTL_DataFactoryTst.createContactPointEmail(1,false,individualId);
            for (ContactPointEmail c : emailsInd){
                c.EmailAddress = 'test1@force.com';
            }
            insert emailsInd;
            
            List<ContactPointEmail> emailsAcc = HDT_UTL_DataFactoryTst.createContactPointEmail(1,false,accId);
            for (ContactPointEmail c : emailsAcc){
                c.EmailAddress = 'test4@force.com';
            }
            insert emailsAcc;
            
            List<ContactPointEmail> emails5 = HDT_UTL_DataFactoryTst.createContactPointEmail(1,false,individualId);
            for (ContactPointEmail c : emails5){
                c.Status__c = constants.CONTACTPOINT_STATUS_VERIFICATO;
                c.EmailAddress = 'test5@force.com';
            }
            insert emails5;
            
            List<ContactPointEmail> emails6 = HDT_UTL_DataFactoryTst.createContactPointEmail(1,false,individualId);
            for (ContactPointEmail c : emails6){
                c.SendToMarketingCloud__c = true;
                c.EmailAddress = 'test6@force.com';
            }
            insert emails6;
            
			List<Lead> leads = HDT_UTL_DataFactoryTst.createLead(1,false);  
            for(Lead l : leads){
                l.IndividualId=IndividualId;
            }
            insert leads;
            
        }
     }

  @isTest
	static void test1(){
        
        String recordId = [SELECT id from ContactPointEmail where EmailAddress = 'test1@force.com'].id;
        String objectapiname = 'ContactPointEmail';
        
        Test.startTest();
        
        Map<String, Object> mapp = HDT_LC_SendCertificationRequest.initialize(objectapiname,recordId);

        Test.stopTest();
        
        System.assertEquals(false, mapp.get('error'), 'Certification not created');
        
        System.assertNotEquals(null, mapp, 'Map not returned');
        
    }
    
  @isTest
	static void test2(){
        
        String recordId = [SELECT id from Account limit 1].id;
        String objectapiname = 'Account';
        
        Test.startTest();
        
        Map<String, Object> mapp = HDT_LC_SendCertificationRequest.initialize(objectapiname,recordId);
        
        Test.stopTest();
        
        System.assertEquals(true, mapp.get('error'), 'The map does not contain the exception data');
        
        System.assertNotEquals(null, mapp, 'The map is not returned correctly');
        
    }
    
  @isTest
	static void test3(){
        
        String recordId = [SELECT id from ContactPointPhone].id;
        String objectapiname = 'ContactPointPhone';
        
        Test.startTest();
        
        Map<String, Object> mapp = HDT_LC_SendCertificationRequest.initialize(objectapiname,recordId);
        
        Test.stopTest();
        
        System.assertEquals(false, mapp.get('error'), 'Certification not created');
        
        System.assertNotEquals(null, mapp, 'Map  not returned');
        
    }
    
  @isTest
	static void test4(){
        
        String recordId = [SELECT id from ContactPointEmail where EmailAddress = 'test4@force.com'].id;
        String objectapiname = 'ContactPointEmail';
        
        Test.startTest();
        
        Map<String, Object> mapp = HDT_LC_SendCertificationRequest.initialize(objectapiname,recordId);
        
        Test.stopTest();

        System.assertEquals(true, mapp.get('error'), 'Certification created when the Account is not a Customer Account');
        
        System.assertNotEquals(null, mapp, 'Map not returned');
        
    }
  @isTest
	static void test5(){
        
        String recordId = [SELECT id from ContactPointEmail where EmailAddress = 'test5@force.com'].id;
        String objectapiname = 'ContactPointEmail';
        
        Test.startTest();
        
        Map<String, Object> mapp = HDT_LC_SendCertificationRequest.initialize(objectapiname,recordId);
        
        Test.stopTest();
        
        System.assertEquals(true, mapp.get('error'), 'Certification created when the Contact Point was already certified');
        
        System.assertNotEquals(null, mapp, 'Map not returned');
        
    }
    
  @isTest
	static void test6(){
        
        String recordId = [SELECT id from ContactPointEmail where EmailAddress = 'test6@force.com'].id;
        String objectapiname = 'ContactPointEmail';
        
        Test.startTest();
        
        Map<String, Object> mapp = HDT_LC_SendCertificationRequest.initialize(objectapiname,recordId);
        
        Test.stopTest();
        
        System.assertEquals(true, mapp.get('error'), 'Certification created when the field SendToMarketingCloud__c was true');
        
        System.assertNotEquals(null, mapp, 'Map not returned');
        
    }
  @isTest
	static void test7(){
        
        List<Individual> indivs = [select id from individual];
        List <Lead> leads = [select id from lead];
        leads[0].IndividualId = indivs[0].id;
        update leads;
        
        String recordId = [SELECT id from ContactPointEmail where EmailAddress = 'test1@force.com'].id;
        String objectapiname = 'ContactPointEmail';
        
        Test.startTest();
        
        Map<String, Object> mapp = HDT_LC_SendCertificationRequest.initialize(objectapiname,recordId);
        
        Test.stopTest();

        System.assertEquals(true, mapp.get('error'), 'Certification created when a Lead with same parentId was found');
        
        System.assertNotEquals(null, mapp, 'Map not returned');
        
        
    }
}