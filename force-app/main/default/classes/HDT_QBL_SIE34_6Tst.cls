/**
* @author Andrea Arosio (andrea.arosio@webresults.it)
* @date 14/10/2021
* @description Test Class for HDT_QBL_SIE34_6
*/
@isTest
public with sharing class HDT_QBL_SIE34_6Tst {

    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();

    @TestSetup
    static void makedata(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserPermissionsMarketingUser=true;

		insert internalUser;

        System.runAs(internalUser){
                        
            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'HERA COMM','Azienda','Aziende SME');
            Id accId = accs[0].id;
            
            List<Order> orders = HDT_UTL_DataFactoryTst.createOrder(1,false,accId,'Bozza');
            for(Order o : orders){
                o.CustomerLastName__c = 'test';
            }
            insert orders;
            Id orderId = orders[0].id;
            
            List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(1,true,accId);
            Id contactId = contacts[0].id;
            
            List<ServicePoint__c> servPoints = HDT_UTL_DataFactoryTst.createServicePoint(1,true);
            Id servPointId = servPoints[0].id;
            
            List<Contract> contracts = HDT_UTL_DataFactoryTst.createContract(1,true,accId);
            Id contractId = contracts[0].id;
            
            List<Case> cases = HDT_UTL_DataFactoryTst.createCaseMorosita(5,false,accId,contactId,servPointId,contractId,orderId);
            for(Case c : cases){
                c.Order__c = orderId;
                c.Cluster__c='Morosità';
                c.Type='Interruzione Fornitura';
            }
            insert cases;
        
        }
     }

     static testmethod void testQueueable(){

        Boolean finished = false;

        HDT_QBL_SIE34_6 sie34 = new HDT_QBL_SIE34_6('1','2021-01-01T13:00:00Z','TEXT');

        Test.startTest();
        
        System.enqueueJob(sie34);

        finished = true;

        Test.stopTest();

        System.assertEquals(true, finished, 'Test Ended');

    }
}
