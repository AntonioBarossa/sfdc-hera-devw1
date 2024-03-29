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
			HDT_UTL_DataFactoryTst.pClickCasePhase();
            
            Id recordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_PostSalesVAS').getRecordTypeId();
			HDT_UTL_DataFactoryTst.newPhaseTransition('In Lavorazione','Bozza',recordTypeId,'HDT_RT_PostSalesVAS');
            
            List<VasSupplierTable__c> vsTables = HDT_UTL_DataFactoryTst.createVasSupplierTable(3,false);
            vsTables[0].Status__c = 'PENDING';
            vsTables[0].VasPracticeCode__c = 'vascode';
            vsTables[0].VasSupplierStatus__c = 'INSTALLAZIONE FALLITA';
            vsTables[1].Status__c = 'PENDING';
            vsTables[1].VasPracticeCode__c = 'vascodex';
            vsTables[2].Status__c = 'PENDING';
            vsTables[2].VasPracticeCode__c = 'VasServizio';
            vsTables[2].VasSupplierStatus__c = 'KO FORNITORE';
            insert vsTables;
            
            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'HERA COMM','Azienda','Aziende Soho');
			Id accId = accs[0].id; 
            
            List<Sale__c> sales = HDT_UTL_DataFactoryTst.createSale(3,true,accId,'Bozza'); 
            
            Id pricebookId = Test.getStandardPricebookId();
            
            List<ServicePoint__c> points = HDT_UTL_DataFactoryTst.createServicePoint(1,true);
            Id pointId = points[0].id;   
            
            List<Product2> products = HDT_UTL_DataFactoryTst.createProduct2(1,false);
            products[0].family = 'VAS Servizio';
            insert products;
            Id productId = products[0].id; 
            
            List<PricebookEntry> entries = HDT_UTL_DataFactoryTst.createPricebookEntry(products,true,pricebookId);
            Id entryId = entries[0].id;
            
            List<Contract> contracts = HDT_UTL_DataFactoryTst.createContract(1,true,accId);
            Id contractId = contracts[0].id;
                        
            List<Order> orders = HDT_UTL_DataFactoryTst.createOrderWithPricebook(3,true,accId,sales,pricebookId);
            Id orderId = orders[0].id;
          
            List<OrderItem> orderItems = HDT_UTL_DataFactoryTst.createOrderItem(10,false,orderId,pointId,productId,entryId);
            orderItems[0].OrderId = orders[0].Id;
            orderItems[1].OrderId = orders[1].Id;
            orderItems[2].OrderId = orders[2].Id;
            insert orderItems;
            Id orderItemId = orderItems[0].id;
            
            List<SBQQ__Subscription__c> subs = HDT_UTL_DataFactoryTst.createSubscription (2,false,accId,contractId,pointId);
            for(SBQQ__Subscription__c s : subs){
                s.VasPracticeCode__c = 'vascode';
                s.SBQQ__OrderProduct__c = orderItemId;
            }
            subs[1].VasPracticeCode__c = 'VasServizio';
            subs[1].SBQQ__Product__c = productId;
            subs[1].SBQQ__OrderProduct__c = orderItems[1].id;
            insert subs;
            
            List<Asset> assets = HDT_UTL_DataFactoryTst.createAsset(2,false);
            assets[0].SBQQ__OrderProduct__c = orderItems[2].id;
            assets[0].VasPracticeCode__c = 'vascode';
            assets[0].AccountId = accs[0].id;
            assets[1].SBQQ__OrderProduct__c = null;
            assets[1].VasPracticeCode__c = 'vascodex';
            insert assets;
            
            List<wrts_prcgvr__FieldsTemplate__c> fieldTemplates = HDT_UTL_DataFactoryTst.createFieldsTemplate(2,false);
            fieldTemplates[0].wrts_prcgvr__Code__c = 'e88f26f9-a32f-439f-b258-db04fadd3994';
            fieldTemplates[0].wrts_prcgvr__ObjectType__c= 'Order';
            fieldTemplates[1].wrts_prcgvr__Code__c = '4dcc76d9-611a-438a-ae0f-6000d7c73ae1';
            fieldTemplates[1].wrts_prcgvr__ObjectType__c= 'Account';
            insert fieldTemplates;
			
            List<wrts_prcgvr__ActivityTemplate__c> activityTemplates = HDT_UTL_DataFactoryTst.createActivityTemplate(2,false);
            activityTemplates[0].Name = 'CBS_ATT003__KO_FORNITORE';
            activityTemplates[0].wrts_prcgvr__Code__c = 'e88f26f9-a32f-439f-b258-db04fadd3994';
            activityTemplates[0].wrts_prcgvr__FieldsTemplate__c= fieldTemplates[0].id;
            activityTemplates[0].wrts_prcgvr__ObjectType__c = 'Order';
            activityTemplates[1].Name = 'VAS001_GESTIONE_ESITI_FORNITORE';
            activityTemplates[1].wrts_prcgvr__Code__c = '4dcc76d9-611a-438a-ae0f-6000d7c73ae1';
            activityTemplates[1].wrts_prcgvr__FieldsTemplate__c= fieldTemplates[1].id;
            activityTemplates[1].wrts_prcgvr__ObjectType__c = 'Account';
            insert activityTemplates;
            
        }
     }
    
    @isTest
    static void testInstallazione(){
        
        String crono = '20 30 8 10 2 ?';
        
        Test.startTest();
        
		HDT_BA_VasSupplierTable vst = new HDT_BA_VasSupplierTable();
        String jobId = System.schedule('Label', crono , vst);
        
        Test.stopTest();

        System.AssertNotEquals(null, jobId, 'job not scheduled correctly');
        
        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
    	System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');
        
        List<AsyncApexJob> jobsApexBatch = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'BatchApex'];
    	System.assertEquals(1, jobsApexBatch.size(), 'expecting one apex batch job');
        
    }
    
    @isTest
    static void testRichiamare(){
        
        VasSupplierTable__c table = [Select id, VasSupplierStatus__c From VasSupplierTable__c where VasSupplierStatus__c = 'INSTALLAZIONE FALLITA'];
        table.VasSupplierStatus__c = 'DA RICHIAMARE';
        update table;
        
        String crono = '20 30 8 10 2 ?';
        
        Test.startTest();
        
		HDT_BA_VasSupplierTable vst = new HDT_BA_VasSupplierTable();
        String jobId = System.schedule('Label', crono , vst);
        
        Test.stopTest();

        System.AssertNotEquals(null, jobId, 'job not scheduled correctly');
        
        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
    	System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');
        
        List<AsyncApexJob> jobsApexBatch = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'BatchApex'];
    	System.assertEquals(1, jobsApexBatch.size(), 'expecting one apex batch job');

        Integer subScriptionAct = 0;
        Integer assetAct = 0;
        for (wrts_prcgvr__Activity__c act : [SELECT id, Subscription__c, Asset__c FROM wrts_prcgvr__Activity__c]){
            if (act.Asset__c != null){
                assetAct++;
            }else if (act.Subscription__c != null){
                subScriptionAct++;
            }
        }
        System.assertNotEquals(1, assetAct, 'Non si è creata l\'attività per l\'asset');
        System.assertNotEquals(1, subScriptionAct, 'Non si è creata l\'attività per la subscription');   
    }

    @isTest
    static void testOrderReferenceOnTable(){
        Test.startTest();
            Database.executeBatch(new HDT_BA_VasSupplierTable());
        Test.stopTest();
        System.assertEquals([SELECT id FROM VasSupplierTable__c WHERE OrderReference__c != null].size(), 2, 'Ordine non correttamente ribaltato sul rispettivo campo nella tabella fornitori');
    }
}