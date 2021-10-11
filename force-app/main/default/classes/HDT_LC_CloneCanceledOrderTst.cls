/*
 * @author Laureta Demishaj (laureta.demishaj@dunegroup.it)
 * @date 29/09/2021
 * @description HDT_LC_CloneCanceledOrder for Test Classes
 * @history Laureta Demishaj – 29/09/2021 – Created class
*/
@isTest
public with sharing class HDT_LC_CloneCanceledOrderTst {
    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
    private static final String CLONE_PERMISSION = 'HDT_CP_CloneCanceledOrder';
    @TestSetup
    static void myData(){
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(4, false, accList[0].Id, 'Bozza' );
        Date tod = Date.today();
        Date canDate0 = tod.addDays(10);
        Date canDate1 = tod.addDays(-100);
        Date canDate2 = tod.addDays(60);
        Date canDate3 = tod.addDays(50);
        orderList[0].CancellationRequestDate__c = canDate0;
        orderList[1].CancellationRequestDate__c = canDate1;
        orderList[2].CancellationRequestDate__c = canDate2;        
        orderList[3].CancellationRequestDate__c = canDate3;    
        insert orderList;
        List<ServiceRequest__c> serReq = HDT_UTL_DataFactoryTst.createServiceRequest(1, false);
        serReq[0].Order__c = orderList[2].Id;
        insert serReq;
        List<Sale__c> salesList = HDT_UTL_DataFactoryTst.createSale(1, true, accList[0].Id, 'Attiva');
    }
    @isTest
    public static void cloneOrderServiceRequestNotEmptyTest(){
            
    Id adminUserProfileId = HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
    User internalUser     = HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, true);
    PermissionSet ps      = new PermissionSet();
    ps.Name  = 'Test';
    ps.Label = 'Test';
    insert ps;
    SetupEntityAccess sea = new SetupEntityAccess();
    sea.ParentId      = ps.Id;
    sea.SetupEntityId = [select Id from CustomPermission where DeveloperName ='HDT_CP_CloneCanceledOrder'][0].Id;
    insert sea;
    PermissionSetAssignment psa = new PermissionSetAssignment();
    psa.AssigneeId      = internalUser.Id;
    psa.PermissionSetId = ps.Id;
    insert psa;
        System.runAs(internalUser){
        Boolean hasCustomPermission = FeatureManagement.checkPermission('HDT_CP_CloneCanceledOrder');
        Date tod = Date.today();
        Date canDate2 = tod.addDays(60);
        List<Order> orderList = [SELECT Id, IsCloned__c FROM Order WHERE CancellationRequestDate__c = :canDate2 LIMIT 1];
        Test.startTest();
        HDT_LC_CloneCanceledOrder.cloneOrder(orderList[0].Id);
        Test.stopTest();
        List<Order> orderd = [SELECT Id, IsCloned__c FROM Order WHERE IsCloned__c=true LIMIT 1];
        Boolean isCloned = orderd[0].IsCloned__c ;
       System.assertEquals(true, isCloned, 'The order should be cloned!');
}}

    @isTest
    public static void cloneOrderExpiredCancellationDaysTest(){
    Id adminUserProfileId = HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
    User internalUser     = HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, true);
    PermissionSet ps      = new PermissionSet();
    ps.Name = 'Test';
    ps.Label = 'Test';
    insert ps;
    SetupEntityAccess sea = new SetupEntityAccess();
    sea.ParentId      = ps.Id;
    sea.SetupEntityId = [select Id from CustomPermission where DeveloperName ='HDT_CP_CloneCanceledOrder'][0].Id;
    insert sea;
    PermissionSetAssignment psa = new PermissionSetAssignment();
    psa.AssigneeId      = internalUser.Id;
    psa.PermissionSetId = ps.Id;
    insert psa;
        System.runAs(internalUser){
            try{
        Boolean hasCustomPermission = FeatureManagement.checkPermission('HDT_CP_CloneCanceledOrder');
        Date tod = Date.today();
        Date canDate1 = tod.addDays(-100);
        List<Order> orderList = [SELECT Id FROM Order WHERE CancellationRequestDate__c = :canDate1 LIMIT 1];
        Test.startTest();
        HDT_LC_CloneCanceledOrder.cloneOrder(orderList[0].Id);
        Test.stopTest();
            }
            catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getmessage(),'An order can be cloned only in the first 60 days from the cancelation!' );
            }
        }
    }
    @isTest
    public static void noClonePermissionTest() {
        List<Order> orderList = [SELECT Id FROM Order];
        try{
        Test.startTest();
        HDT_LC_CloneCanceledOrder.cloneOrder(orderList[0].Id);
        Test.stopTest();
        } catch(Exception e ){
             System.assertEquals('Script-thrown exception', e.getMessage(), 'The user has not the permission to clone an order!');
        }
    }
     @isTest
    public static void  controllerInitTest(){
        List<Sale__c> salesList = [SELECT Id FROM Sale__c];
        Test.startTest();
        Map<string,object> response = HDT_LC_CloneCanceledOrder.controllerInit(salesList[0].Id);
        Test.stopTest();
        System.assertNotEquals(null, response, 'The response should not be null!');
    }
       @isTest
    public static void controllerInitRedirectTest(){
        List<Order> orderList = [SELECT Id FROM Order];
        Test.startTest();
        Map<string,object> response = HDT_LC_CloneCanceledOrder.controllerInitRedirect(orderList[0].Id);
        Test.stopTest();
        System.assertNotEquals(null, response, 'The response should not be null!');
    }
        @isTest
    public static void isCommunityTest(){
        Test.startTest();
        Map<string,object> response = HDT_LC_CloneCanceledOrder.isCommunity();
        Test.stopTest();
         System.assertNotEquals(null, response, 'The response should not be null!');
    }
}