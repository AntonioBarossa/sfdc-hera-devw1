/**
 * Header of the class "HDT_UTL_AssetStatusVasTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_UTL_AssetStatusVas"
 * @history
 * @Created 29/09/2021
 * Modified By:
 **/

@isTest
public class HDT_UTL_AssetStatusVasTst {

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
            
            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','MMS Azienda','Aziende SME');
			Id accId = accs[0].id;
            
            List<ServicePoint__c> points = HDT_UTL_DataFactoryTst.createServicePoint(1,true);
            Id pointId = points[0].id;
            
            List<Product2> products = HDT_UTL_DataFactoryTst.createProduct2(1,false);
            for(Product2 p : products){
                p.Price__c = 10;
            }
            insert products;
            Id productId = products[0].id;
            
            Id pricebookId = Test.getStandardPricebookId();
            
            List<PricebookEntry> entries = HDT_UTL_DataFactoryTst.createPricebookEntry(products,true,pricebookId);
            Id entryId = entries[0].id;
            
            List<Sale__c> sales = HDT_UTL_DataFactoryTst.createSale(1,true,accId,'Bozza');
            
            List<Order> orders = HDT_UTL_DataFactoryTst.createOrderWithPricebook(1,false,accId,sales,pricebookId);
            for(Order o : orders){
                o.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_VAS').getRecordTypeId();
            }
            insert orders;
            Id orderId = orders[0].id;
           
            List<OrderItem> orderItems = HDT_UTL_DataFactoryTst.createOrderItem(10,true,orderId,pointId,productId,entryId);
            
            
            List<Asset> assets = new List<Asset>();
            Asset asset1 = new Asset(Name = 'asset1', SBQQ__OrderProduct__c = orderItems[0].id, SBQQ__RootAsset__c = null);
            Asset asset2 = new Asset(Name = 'asset2', SBQQ__OrderProduct__c = orderItems[1].id, SBQQ__RootAsset__c = null);
            assets.add(asset1);
            assets.add(asset2);
            insert assets;
            
        }
     }

  @isTest
	static void test1(){
        
        List<Asset> assets = [Select id, SBQQ__OrderProduct__c, SBQQ__RootAsset__c, DigitalAssetStatus, VasPracticeCode__c From Asset];
		List<Order> orders = [Select id,RecordTypeId from Order];        
        Test.startTest();
        
        HDT_UTL_AssetStatusVas.processAssets(assets);
            
        Test.stopTest();
        
        System.assertNotEquals(constants.ORDER_RECORDTYPEID_DEFAULT, orders[0].RecordTypeId, 'Orders record type correctly modified');
        
        System.assertEquals('Attivo', assets[0].DigitalAssetStatus, 'Assets field value successfully modified');        
    }
}