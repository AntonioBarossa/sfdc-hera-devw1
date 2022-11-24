@isTest
public with sharing class HDT_BA_UpdateActivitiesStatusTst {

        private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
    
        @TestSetup
        static void makedata(){
            HDT_UTL_DataFactoryTst.pClickInstanceActivityIntegration();

            HDT_UTL_DataFactoryTst.pClickInstance();
            Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.HERA_SYSTEM_ADMINISTRATOR_NAME);
    
            User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
    
            internalUser.UserPermissionsMarketingUser=true;
    
            insert internalUser;  
            System.runAs(internalUser){
                List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','MMS Azienda','Aziende SME');
                Id accId = accs[0].id;
                List<wrts_prcgvr__Activity__c> activity = HDT_UTL_DataFactoryTst.createActivityCustom(1,false,accId);
                activity[0].Type__c='Chiamata inbound';
                activity[0].wrts_prcgvr__Status__c = 'Aperta' ;
                insert activity;
                Datetime yesterday = Datetime.now().addDays(-1);
                Test.setCreatedDate(activity[0].Id, yesterday);
            }
        }


    @isTest
    static void test(){
        wrts_prcgvr__Activity__c acBefore = [SELECT id,wrts_prcgvr__Status__c from wrts_prcgvr__Activity__c WHERE wrts_prcgvr__Status__c = 'Aperta' LIMIT 1];
        
        Test.startTest();
		HDT_BA_UpdateActivitiesStatus cc = new HDT_BA_UpdateActivitiesStatus();     
        Database.executeBatch(cc,200);
        Test.stopTest();
        
        wrts_prcgvr__Activity__c acAfter = [SELECT id,wrts_prcgvr__Status__c from wrts_prcgvr__Activity__c WHERE id = :acBefore.id];
        System.assertNotEquals(acBefore.wrts_prcgvr__Status__c, acAfter.wrts_prcgvr__Status__c,'Activity Custom field Status not updated by the batch'); 
    }
}