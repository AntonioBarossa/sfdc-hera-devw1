/**
 * Header of the class "HDT_BA_VasSupplierTableTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_BA_VasSupplierTable"
 * @history
 * @Created 01/10/2021
 * Modified By:
 **/

@isTest
public class HDT_BA_VasSupplierTableTst {

	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();

    @TestSetup
    static void makedata(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserPermissionsMarketingUser=true;

		insert internalUser;

        System.runAs(internalUser){
            
            HDT_UTL_DataFactoryTst.pClickInstance();
			HDT_UTL_DataFactoryTst.pClickOrderPhase();
            
            List<VasSupplierTable__c> vsTables = HDT_UTL_DataFactoryTst.createVasSupplierTable(2,false);
            vsTables[0].Status__c = 'PENDING';
            vsTables[0].VasPracticeCode__c = 'vascode';
            vsTables[1].Status__c = 'PENDING';
            insert vsTables;
            
            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','MMS Azienda','Aziende SME');
			Id accId = accs[0].id; 
            
            List<Sale__c> sales = HDT_UTL_DataFactoryTst.createSale(1,true,accId,'Bozza'); 
            
            Id pricebookId = Test.getStandardPricebookId();
            
            List<ServicePoint__c> points = HDT_UTL_DataFactoryTst.createServicePoint(1,true);
            Id pointId = points[0].id;   
            
            List<Product2> products = HDT_UTL_DataFactoryTst.createProduct2(1,true);
            Id productId = products[0].id; 
            
            List<PricebookEntry> entries = HDT_UTL_DataFactoryTst.createPricebookEntry(products,true,pricebookId);
            Id entryId = entries[0].id;
            
            List<Contract> contracts = HDT_UTL_DataFactoryTst.createContract(1,true,accId);
            Id contractId = contracts[0].id;
                        
            List<Order> orders = HDT_UTL_DataFactoryTst.createOrderWithPricebook(1,true,accId,sales,pricebookId);
            Id orderId = orders[0].id;
          
            List<OrderItem> orderItems = HDT_UTL_DataFactoryTst.createOrderItem(10,true,orderId,pointId,productId,entryId);
            Id orderItemId = orderItems[0].id;
            
            List<SBQQ__Subscription__c> subs = HDT_UTL_DataFactoryTst.createSubscription (1,false,accId,contractId,pointId);
            for(SBQQ__Subscription__c s : subs){
                s.VasPracticeCode__c = 'vascode';
                s.SBQQ__OrderProduct__c = orderItemId;
            }
            insert subs;
            
            List<Asset> assets = HDT_UTL_DataFactoryTst.createAsset(2,false);
            assets[0].SBQQ__OrderProduct__c = orderItemId;
            assets[0].VasPracticeCode__c = 'vascode';
            assets[1].SBQQ__OrderProduct__c = null;
            assets[1].VasPracticeCode__c = 'vascode';
            insert assets;
            
            List<wrts_prcgvr__FieldsTemplate__c> fieldTemplates = HDT_UTL_DataFactoryTst.createFieldsTemplate(1,false);
            fieldTemplates[0].wrts_prcgvr__Code__c = 'e88f26f9-a32f-439f-b258-db04fadd3994';
            fieldTemplates[0].wrts_prcgvr__ObjectType__c= 'Order';
            insert fieldTemplates;
			
            List<wrts_prcgvr__ActivityTemplate__c> activityTemplates = HDT_UTL_DataFactoryTst.createActivityTemplate(1,false);
            activityTemplates[0].Name = 'CBS_ATT003__KO_FORNITORE';
            activityTemplates[0].wrts_prcgvr__Code__c = 'e88f26f9-a32f-439f-b258-db04fadd3994';
            activityTemplates[0].wrts_prcgvr__FieldsTemplate__c= fieldTemplates[0].id;
            activityTemplates[0].wrts_prcgvr__ObjectType__c = 'Order';
            insert activityTemplates;
            
        }
     }
    
    @isTest
    static void testSch(){
        
        String CRON_EXP = '20 30 8 10 2 ?';
        
        Test.startTest();
        
		HDT_BA_VasSupplierTable vst = new HDT_BA_VasSupplierTable();
        String jobID = System.schedule('Label', CRON_EXP , vst);
        
        Test.stopTest();
        
        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
    	System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');
        
        List<AsyncApexJob> jobsApexBatch = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'BatchApex'];
    	System.assertEquals(1, jobsApexBatch.size(), 'expecting one apex batch job');
        
    }
}