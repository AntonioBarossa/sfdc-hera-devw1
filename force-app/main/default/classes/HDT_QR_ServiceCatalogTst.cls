/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 01/09/2021
 * @description HDT_QR_ServiceCatalog Test Class
 * @history Lucas da Silva Fernandes – 01/09/2021 – Created Class
 */

 @isTest
public with sharing class HDT_QR_ServiceCatalogTst {

    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    
    @TestSetup
    static void setup(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);

		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);

		internalUser.UserPermissionsMarketingUser=true;

		insert internalUser;

        System.runAs(internalUser) {

            List<wrts_prcgvr__ServiceLink__c> slList = HDT_UTL_DataFactoryTst.createServiceLink(1, false);
            slList[0].wrts_prcgvr__Subcategory__c = 'Subcategory 1';
            slList[0].wrts_prcgvr__Label__c = 'Subcategory 1';
            insert slList;

            List<wrts_prcgvr__ServiceLinkItem__c> sliList = HDT_UTL_DataFactoryTst.createServiceLinkItem(1, false, slList[0].Id);
            sliList[0].wrts_prcgvr__Label__c = 'testLabel';
            sliList[0].wrts_prcgvr__LightningActionParams__c = 'testLightningActParams';
            sliList[0].wrts_prcgvr__LightningAction__c = 'createRecord';
            sliList[0].wrts_prcgvr__ObjectType__c = 'Account';
            sliList[0].wrts_prcgvr__URL__c = 'http://www.pudim.com.br';

            insert sliList;
        }
    }

    @isTest
    public static void testGetServiceLinkItemAccountRedirectUrlByCategory() {

        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];

        System.runAs(u){

            Test.startTest();

            wrts_prcgvr__ServiceLinkItem__c sl = [SELECT Id, wrts_prcgvr__URL__c, wrts_prcgvr__ServiceLink__r.wrts_prcgvr__Subcategory__c
                                                  FROM wrts_prcgvr__ServiceLinkItem__c 
                                                  WHERE wrts_prcgvr__LightningAction__c = 'createRecord'];
            
            String result = HDT_QR_ServiceCatalog.getServiceLinkItemAccountRedirectUrlByCategory('', sl.wrts_prcgvr__ServiceLink__r.wrts_prcgvr__Subcategory__c);

            System.assertEquals(sl.wrts_prcgvr__URL__c, result, 'ServiceLinkItem URL is correct');
            System.assertNotEquals(null, result, 'ServiceLinkItem URL is wrong');
            
            String resultFalse = HDT_QR_ServiceCatalog.getServiceLinkItemAccountRedirectUrlByCategory('', '');

            System.assertEquals(null, resultFalse, 'ServiceLinkItem URL is correct');
            System.assertNotEquals('http://pudim.com.br', resultFalse, 'ServiceLinkItem URL is wrong');

            Test.stopTest();
        }
    }
}
