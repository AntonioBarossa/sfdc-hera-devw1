/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 17/09/2021
 * @description HDT_TRH_Order Test Class
 * @history Lucas da Silva Fernandes – 17/09/2021 – Created Class
 */
@isTest
public with sharing class HDT_TRH_OrderTst {
    
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
	
	@TestSetup
    static void setup(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
 
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
 
        internalUser.UserPermissionsMarketingUser=true;
 
        insert internalUser;
 
        System.runAs(internalUser) {
 
            HDT_UTL_DataFactoryTst.pClickInstance();
            HDT_UTL_DataFactoryTst.pClickOrderPhase();
            HDT_UTL_DataFactoryTst.newPhaseTransition('Documentazione validata', 'Bozza', constants.ORDER_RECORDTYPEID_CAMBIO_OFFERTA, 'HDT_RT_CambioOfferta');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Comunicazione Verso Heroku', 'Documentazione validata', constants.ORDER_RECORDTYPEID_CAMBIO_OFFERTA, 'HDT_RT_CambioOfferta');

            List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
            List<Contact> cttList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
            List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].Id, 'Bozza');
            orderList[0].RecordTypeId = constants.ORDER_RECORDTYPEID_CAMBIO_OFFERTA;
            orderList[0].Contact__c = cttList[0].Id;
            orderList[0].TecnicalPhase__c = 'Documentazione validata';
            insert orderList;
        }
    }
	
	@isTest
    public static void testUpdate() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<Order> orderList = [SELECT Id, Phase__c, TecnicalPhase__c FROM Order WHERE Phase__c = 'Bozza'];
            orderList[0].Phase__c = 'Documentazione validata';
            update orderList;
            System.debug('@@'+[SELECT Id, Phase__c, TecnicalPhase__c FROM Order]);
            List<Order> orders = [SELECT Id, Phase__c, TecnicalPhase__c FROM Order WHERE Phase__c = 'Comunicazione verso Heroku'];

            Test.stopTest();

            System.assertEquals(false, orders.isEmpty(), 'Order successfully updated.');
            System.assertNotEquals(true, orders.isEmpty(), 'Order update failed.');
        }
    }
}
