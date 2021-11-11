/**
 * Header of the class "HDT_UTL_ActivityCustomProcessTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_UTL_ActivityCustomProcess"
 * @history
 * @Created 25/10/2021
 * Modified By:
 **/
@isTest
public class HDT_UTL_ActivityCustomProcessTst {
    
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    
    @TestSetup static void makedata(){
        
        Id adminUserProfileId = HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser = HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, true);

        System.runAs(internalUser){
                
            HDT_UTL_DataFactoryTst.pClickInstanceActivityIntegration();
            HDT_UTL_DataFactoryTst.pClickOrderPhase();
            HDT_UTL_DataFactoryTst.createWebServiceConfiguration('CreditCheck','https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/data-management/files','POST','MulesoftSalesforceUser');
           
            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'HERA COMM','Azienda','Aziende SME');
            
            List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(1,true,accs[0].id);
            
            List<ServicePoint__c> points = HDT_UTL_DataFactoryTst.createServicePoint(1, false);
            points[0].Account__c = accs[0].id;
            points[0].CommoditySector__c = 'Gas';
            points[0].AnnualConsumptionStandardM3__c = 1.1;
            insert points;
            
            List<Order> orders = HDT_UTL_DataFactoryTst.createOrder(1, false, accs[0].id, 'Bozza');
            orders[0].RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_Subentro').getRecordTypeId();
            orders[0].OutgoingCreditCheckResult__c = 'ye';
            orders[0].ServicePoint__c = points[0].id;
            orders[0].CreditCheckDescription__c = 'long description';
            orders[0].Contact__c = contacts[0].id;
            orders[0].CommentForDL__c = 'comment';
            orders[0].ownerId = userinfo.getuserid();
            orders[0].CvpId__c = 'test';
            orders[0].CvpCgs__c = 'test';
            orders[0].CvpErrorCode__c = 'test';
            orders[0].CvpErrorDescription__c = 'test';
            orders[0].CvpErrorSource__c = 'test';
            orders[0].CvpRiskRating__c = 'test';
            insert orders;
            
            List<wrts_prcgvr__Activity__c> activities =  HDT_UTL_DataFactoryTst.createActivityCustom(1, false, accs[0].id);
            activities[0].RecordTypeId = Schema.SObjectType.wrts_prcgvr__Activity__c.getRecordTypeInfosByDeveloperName().get('HDT_RT_VisitaD2D').getRecordTypeId();
            activities[0].Contact__c = contacts[0].id;
            activities[0].Order__c = orders[0].id;
            insert activities;
        }                
    }
    
    @isTest static void updateActivity(){
        
        wrts_prcgvr__Activity__c myActivity = [SELECT id FROM wrts_prcgvr__Activity__c WHERE Account__r.Name = 'test account0'];
        
        Test.startTest();
        
        myActivity.ownerId = userinfo.getuserid();
        update myActivity;
        
        Test.stopTest();
        
        myActivity = [SELECT id, ownerId FROM wrts_prcgvr__Activity__c WHERE Account__r.Name = 'test account0'];
        
        System.assertEquals(userinfo.getuserid(), myActivity.ownerId, 'Activity not updated correctly');
        System.assertNotEquals(null, myActivity, 'Activity not updated correctly');        
    }
    
    @isTest static void createActivityForCreditCheck(){
        
        String msg;
        
        Order oldCustomer = [SELECT id, OutgoingCreditCheckResult__c, ServicePoint__r.Account__c, CreditCheckDescription__c, Contact__c, CommentForDL__c, 
                             OwnerId, CvpId__c, CvpCgs__c, CvpErrorCode__c, CvpErrorDescription__c, CvpErrorSource__c, CvpRiskRating__c, IncomingCreditCheckResult__c, AccountId
                             FROM Order];
        List<Order> oldCustomers = new List<Order>();
        oldCustomers.add(oldCustomer);
        
        Map<String,List<Order>> mapp = new Map<String,List<Order>>();
        mapp.put('oldCustomer', oldCustomers);
        mapp.put('newCustomer', oldCustomers);
        
        try{
        
        	HDT_UTL_ActivityCustomProcess.createActivityForCreditCheck(mapp);
        }catch(Exception e){
            msg = e.getMessage();
        }
        
        System.assertEquals('Script-thrown exception', msg, 'createActivityForCreditCheck did not work correctly');
        System.assertNotEquals(null, msg, 'createActivityForCreditCheck did not work correctly');        
    }
    
    @isTest static void recheckCreditCheck(){
        
        Exception ex;
        
        /*Order myOrder = [SELECT id FROM Order];
        myOrder.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_VAS').getRecordTypeId();
        update myOrder;*/
        
        List<wrts_prcgvr__Activity__c> myActivity = [SELECT id, Order__r.ServicePoint__r.CommoditySector__c, Order__r.RecordType.DeveloperName,
                                                     Order__r.Account.RecordType.DeveloperName, Order__r.ServicePoint__r.Account__r.VATNumber__c,
                                                     Order__r.ServicePoint__r.AnnualConsumptionStandardM3__c, Order__r.OrderNumber, Order__r.CreatedById,
                                                     Order__r.Channel__c, Order__r.Account.CustomerCode__c, Order__r.SalesCompany__c, Order__r.Account.FiscalCode__c,
                                                     Order__r.Account.VATNumber__c, Order__r.Account.CustomerMarking__c, Order__r.Account.Category__c, 
                                                     Order__r.Account.CustomerType__c, Order__r.ProcessType__c, Order__r.Market__c, Order__r.Catalog__c,
                                                     Order__r.ServicePoint__r.Account__r.CustomerCode__c
                                                     FROM wrts_prcgvr__Activity__c WHERE Account__r.Name = 'test account0'];
        
        
        try{
        	HDT_UTL_ActivityCustomProcess.recheckCreditCheck(myActivity);
        }catch(Exception e){
            ex = e;
        }
        
        System.assertNotEquals(0, myActivity.size(), 'Activity not found');
        System.assertEquals(null, ex, 'recheckCreditCheck did not work correctly');
    }
    
    @isTest static void closeActivityCheck(){
        
        wrts_prcgvr__Activity__c myActivity = [SELECT id FROM wrts_prcgvr__Activity__c];
        
        wrts_prcgvr__Activity__c updatedActivity = HDT_UTL_ActivityCustomProcess.closeActivityCheck(myActivity);
        
        System.assertEquals('Chiusa', updatedActivity.Status__c, 'closeActivityCheck did not work correctly');  
        System.assertNotEquals(null, updatedActivity, 'closeActivityCheck did not work correctly');      
    }
    
    @isTest static void updateCreditCheckActivity(){
        
        List<wrts_prcgvr__Activity__c> myActivity = [SELECT id FROM wrts_prcgvr__Activity__c];
        
        myActivity[0].CausalError__c = 'new string';
        
        HDT_UTL_ActivityCustomProcess.updateCreditCheckActivity(myActivity);
        
        wrts_prcgvr__Activity__c updatedActivity = [SELECT id, CausalError__c FROM wrts_prcgvr__Activity__c];
        
        System.assertEquals('new string', updatedActivity.CausalError__c, 'updateCreditCheckActivity did not work correctly');  
        System.assertNotEquals(null, updatedActivity.CausalError__c, 'updateCreditCheckActivity did not work correctly');      
    }
}