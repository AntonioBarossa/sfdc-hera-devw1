/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 15-09-2022
 * @last modified by  : Giacinto Florio
**/
@isTest
public with sharing class HDT_UTL_ActivityTemplateTst {
    
    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();

    @TestSetup
    static void makedata(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
        internalUser.UserPermissionsMarketingUser=true;

        insert internalUser;

        System.runAs(internalUser){
            
            HDT_UTL_DataFactoryTst.pClickInstance();
            HDT_UTL_DataFactoryTst.createActivityTemplate(1,true);
        }
    }
    
    @isTest 
    public static void activityCreationTest(){		
        HDT_UTL_ActivityTemplate activityTemplate = new HDT_UTL_ActivityTemplate();
        activityTemplate.sobjType = 'Case';
        HDT_UTL_ActivityTemplate.HDT_WRP_Infos info = new HDT_UTL_ActivityTemplate.HDT_WRP_Infos('testActivityTemplate', false, 'Bozza');
        Case caso = new Case();
        insert caso;
        wrts_prcgvr__ActivityTemplate__c template = [SELECT Id,wrts_prcgvr__Subject__c,wrts_prcgvr__ObjectType__c FROM wrts_prcgvr__ActivityTemplate__c LIMIT 1];
        template.Name='testActivityTemplate';
        template.wrts_prcgvr__ObjectType__c='Case';
        update template;
        wrts_prcgvr__ActivityAction__c action = new wrts_prcgvr__ActivityAction__c();
        action.wrts_prcgvr__ActivityTemplate__c=template.Id;
        action.wrts_prcgvr__Field__c='field';
        action.wrts_prcgvr__Value__c='value';
        insert action;

        wrts_prcgvr__Activity__c activity = activityTemplate.createActivity(caso, template, info);
        Map<Id, HDT_UTL_ActivityTemplate.HDT_WRP_Infos> sobjectToNewActivityType = new Map<Id, HDT_UTL_ActivityTemplate.HDT_WRP_Infos>();
        sobjectToNewActivityType.put(caso.Id,info);
        
        Test.startTest();
        activityTemplate.handleNewActivityCreation(sobjectToNewActivityType);
        System.assertEquals(activity.wrts_prcgvr__Phase__c, 'Bozza', 'test');
        Test.stopTest();
    }

}