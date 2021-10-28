/**
 * Header of the class "HDT_LC_ActivityDetailTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_LC_ActivityDetail"
 * @history
 * @Created 05/10/2021
 * Modified By:
 * 27/10/2021 Luca Belometti WR [luca.belometti@webresults.it] - (BugFix - 171) 
 **/

@isTest
public class HDT_LC_ActivityDetailTst {
    
    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
    
	@TestSetup
    static void makedata(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.HERA_SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserPermissionsMarketingUser=true;

		insert internalUser;

        System.runAs(internalUser){

            HDT_UTL_DataFactoryTst.pClickInstance();
		    HDT_UTL_DataFactoryTst.pClickCasePhase();
            
            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','MMS Azienda','Aziende SME');
			Id accId = accs[0].id;

			List<Order> orders = HDT_UTL_DataFactoryTst.createOrder(1,true,accId,'Bozza');
            
            List<wrts_prcgvr__FieldsTemplate__c> fieldTemplates = HDT_UTL_DataFactoryTst.createFieldsTemplate(2,false);
            fieldTemplates[0].wrts_prcgvr__ObjectType__c = 'Order';
            insert fieldTemplates;
            
            List<wrts_prcgvr__ActivityTemplate__c> activityTemplates = HDT_UTL_DataFactoryTst.createActivityTemplate(1,false);
            activityTemplates[0].wrts_prcgvr__ObjectType__c = 'Order';
            activityTemplates[0].wrts_prcgvr__FieldsTemplate__c = fieldTemplates[0].id;
            insert activityTemplates;
            
            List<wrts_prcgvr__Activity__c> activities = HDT_UTL_DataFactoryTst.createActivityCustom(2,false,accId);
            activities[0].wrts_prcgvr__IsClosed__c  = true;
            activities[0].wrts_prcgvr__ActivityTemplate__c = activityTemplates[0].id;
            activities[1].wrts_prcgvr__IsClosed__c  = true;
            activities[1].wrts_prcgvr__ActivityTemplate__c = activityTemplates[0].id;
            activities[1].Order__c = orders[0].id;            
            insert activities;
            
            List<wrts_prcgvr__DynamicSection__c> dynamicSections = HDT_UTL_DataFactoryTst.createDynamicSection(1,false,fieldTemplates[0].id);
            dynamicSections[0].wrts_prcgvr__Order__c = 2.2;
            insert dynamicSections;
            
            List<wrts_prcgvr__DynamicField__c> dynamicFields = HDT_UTL_DataFactoryTst.createDynamicField(2,false,dynamicSections[0].id);
            dynamicFields[0].wrts_prcgvr__ObjectName__c = 'wrts_prcgvr__Activity__c';
            dynamicFields[1].wrts_prcgvr__ObjectName__c = 'Order';
            insert dynamicFields;
            
        }
    }
    
    @isTest
    static void test1(){
        
        Id actId = [Select id From wrts_prcgvr__Activity__c Where Order__c = null].id;
        
        Test.startTest();
        
        Map <String, Object> mapp = HDT_LC_ActivityDetail.getObjectFields(actId);
        
        Test.stopTest();
        
        System.assertEquals(2, mapp.size(), 'getObjectFields did not work correctly');
        
        System.assertNotEquals(null, mapp, 'getObjectFields did not work correctly');
        
    }
    
    @isTest
    static void test2(){
        
        Id actId = [Select id From wrts_prcgvr__Activity__c Where Order__c != null].id;
               
        Test.startTest();
        
        Map <String, Object> mapp = HDT_LC_ActivityDetail.getObjectFields(actId);
        
        Test.stopTest();
        
        System.assertEquals(2, mapp.size(), 'getObjectFields did not work correctly');
        
        System.assertNotEquals(null, mapp, 'getObjectFields did not work correctly');
        
    }
}