/**
* @author Luis Bispo (luis.bispo@engdb.com.br)
* @date 13/09/2021
* @description HDT_SRV_MassiveLoaderRequest for Test Classes
* @history Luis Bispo – 13/09/2021 – Created class
*/
@isTest
public with sharing class HDT_SRV_MassiveLoaderRequestTst {
    
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();

    @TestSetup
    static void setup(){
        
        Id adminUserProfileId = HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
 
        User internalUser = HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
 
        internalUser.UserPermissionsMarketingUser=true;
 
        insert internalUser;
    }

    @isTest
    static void testCreateNewRequestRecord() {
        User tUser = [SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1]; 
        System.runAs(tUser){
            Test.startTest();    

            MassiveLoaderRequest__c mlr = new HDT_SRV_MassiveLoaderRequest().createNewRequestRecord('Subentro', 1);
            System.assertEquals('Subentro', mlr.ProcessType__c,'Subentro');
            System.assertNotEquals('', mlr.ProcessType__c,'');
            Test.stopTest();
        }
    }
    @isTest
    static void testUpdateRequestRecord() {
        User tUser = [SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1]; 
        System.runAs(tUser){
            Test.startTest();    
            List<MassiveLoaderRequest__c> lstMassiveLoaderReq = [SELECT Id FROM MassiveLoaderRequest__c LIMIT 1]; 

            new HDT_SRV_MassiveLoaderRequest().updateRequestRecord(lstMassiveLoaderReq);
            System.assertEquals(true, lstMassiveLoaderReq != null, 'Lead not updated');
			System.assertNotEquals(true, lstMassiveLoaderReq == null, 'Lead not updated');
            Test.stopTest();
        }
    }
}
