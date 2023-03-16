@isTest
public class HDT_LC_AlertPrivacyTst {
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();

    @TestSetup
    static void makedata(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserPermissionsMarketingUser=true;

		insert internalUser;

        System.runAs(internalUser){
           
            List<Individual> inds = HDT_UTL_DataFactoryTst.createIndividual(1,false);
    
            inds[0].PrivacyProfilingChoiceDate__c=System.today();
            inds[0].MarketingPrivacy__c='Non espresso';
            inds[0].ProfilingPrivacy__c='Non espresso';   
            
            insert inds;
            
            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','G3 - MMS Azienda','Aziende SME');
            Id accId = accs[0].id;
            List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(1,false,accId);
            
            contacts[0].Email='email@test.it';
            contacts[0].Company__c='MMS';
            contacts[0].IndividualId=inds[0].Id;
            insert contacts;

            List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, false, accId, 'Bozza');
			ordList[0].Contact__c = contacts[0].Id;
            ordList[0].Name = 'test';
            insert ordList;
           
        }
    }


    @isTest
    static void handleShowAlertTest(){
        List<Order> ordList = [SELECT Id FROM Order WITH SECURITY_ENFORCED LIMIT 1] ;
        Boolean res = HDT_LC_AlertPrivacy.handleShowAlert(ordList[0].Id);
        system.assertEquals(true, res,'The result is not what expected' );
    }



}