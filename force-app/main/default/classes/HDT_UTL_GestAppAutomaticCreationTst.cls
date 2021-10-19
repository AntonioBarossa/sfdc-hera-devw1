/**
 * Header of the class "HDT_UTL_GestAppAutomaticCreationTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_UTL_GestAppAutomaticCreation"
 * @history
 * @Created 05/10/2021
 * Modified By:
 **/

@isTest
public class HDT_UTL_GestAppAutomaticCreationTst {

    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();

    @TestSetup
    static void makedata(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
        internalUser.UserPermissionsMarketingUser=true;

        insert internalUser;

        System.runAs(internalUser){
            
            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','MMS Azienda','Aziende SME');
            Id accId = accs[0].id;
            
                        
            List<ServicePoint__c> points = HDT_UTL_DataFactoryTst.createServicePoint(1,false);
            points[0].CommoditySector__c = 'Gas';
            insert points;

            List<Order> orders = HDT_UTL_DataFactoryTst.createOrder(1,false,accId,'Bozza');
            orders[0].ServicePoint__c = points[0].id;
            insert orders;
            
        }
     }
    
    @isTest
    static void test1(){
        
        Order ord = [Select id From Order];
        
        Map<String,Object> argsMap = new Map<String,Object>();
        argsMap.put('method','Modificaimpianto');
        argsMap.put('sender',ord);
        
        Test.startTest();

        HDT_UTL_GestAppAutomaticCreation gestore = new HDT_UTL_GestAppAutomaticCreation();
        Object b = gestore.execute(argsMap);
        
        Test.stopTest();
        

    	System.assertEquals(1, [Select id From wrts_prcgvr__Activity__c].size(), 'HDT_UTL_GestAppAutomaticCreation.execute did not work correctly');
        
		System.assertNotEquals(false, b, 'HDT_UTL_GestAppAutomaticCreation.execute did not work correctly');
        
    }
}