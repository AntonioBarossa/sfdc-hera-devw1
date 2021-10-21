/*
 * @author Laureta Demishaj (laureta.demishaj@dunegroup.it)
 * @date 23/09/2021
 * @description HDT_LC_ActivityChildCreationController for Test Classes
 * @history Laureta Demishaj – 23/09/2021 – Created class
*/
@IsTest
public with sharing class HDT_LC_ActivityChildCreationCntTst {

    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    @IsTest
    public static void createActivityChildTst() {
    List<Account> accList                             = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
    List<wrts_prcgvr__Activity__c> customActivityList = HDT_UTL_DataFactoryTst.createActivityCustom(1, false, accList[0].Id);
    customActivityList[0].Type__c                     = 'Approvazione Offerte';
    insert customActivityList[0];

    Test.startTest();
    Id response                                              = HDT_LC_ActivityChildCreationController.createActivityChild(customActivityList[0].Id, customActivityList[0].Type__c);
    List<wrts_prcgvr__Activity__c> activityChildCreatedIdRet = [SELECT Id FROM wrts_prcgvr__Activity__c WHERE ParentActivity__c = :customActivityList[0].Id LIMIT 1];
    System.assertEquals(activityChildCreatedIdRet[0].Id, response, 'The method creates a child given a right Id of the Activity(Custom)');
    System.assertNotEquals(null, response, 'This method worked, the retured Id is not null');
    Test.stopTest();
    }
    @IsTest
    public static void createActivityChildElseTst(){
    Test.startTest();
    Id response = HDT_LC_ActivityChildCreationController.createActivityChild(null,null);
    System.assertEquals(null, response, 'The method cant create a child given a null(or empty) parameter as Id ');
    System.assertNotEquals('', response, 'Given a null(or empty) parameter as Id the returned result of the method is null');
    Test.stopTest();
    }
    @IsTest
    public static void createActivityChildNegativeTst(){
        Id minimumAccessProfileId = HDT_UTL_DataFactoryTst.getProfileId(constants.MINIMUM_ACCESS_SALESFORCE);
        User minimumAccessUser    = HDT_UTL_DataFactoryTst.createInternalUser(minimumAccessProfileId, false);
        minimumAccessUser.Email   = 'sales@force.com';
        insert minimumAccessUser;
        System.runAs(minimumAccessUser) {
        Test.startTest();
   try {
            Id response  = HDT_LC_ActivityChildCreationController.createActivityChild(null,null);
        System.debug(response);
        } catch(Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'As expected, if the logged user has minimum access the method cant run');
            System.assertNotEquals('', e.getMessage(), 'The exception throws an error message');
        }
        Test.stopTest();}
    }
}