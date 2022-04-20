@isTest
public class HDT_LC_FinalConfirmationButtonTest {
    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
    
    @isTest
    private static void testOrder(){        
        
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        HDT_UTL_DataFactoryTst.newPhaseTransition('Documentazione validata', 'Bozza', constants.ORDER_RECORDTYPEID_CAMBIO_OFFERTA, 'HDT_RT_CambioOfferta');
        HDT_UTL_DataFactoryTst.newPhaseTransition('Comunicazione Verso Heroku', 'Documentazione validata', constants.ORDER_RECORDTYPEID_CAMBIO_OFFERTA, 'HDT_RT_CambioOfferta');
        
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Contact> cttList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].Id, 'Bozza');
        List<Sale__c> sales=HDT_UTL_DataFactoryTst.createSale(2, true, accList[0].Id, 'Attiva');
        orderList[0].RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_VolturaConSwitch').getRecordTypeId();
        orderList[0].Contact__c = cttList[0].Id;
        insert orderList;
        
        List<Order> childOrders=HDT_UTL_DataFactoryTst.createChildOrder(1, false, accList[0].Id, sales, orderList[0].Id, cttList[0].Id);
        insert childOrders;
        
        if(childOrders!=null && childOrders.size()>0){
            List<Order> childOrdersToUpdate=new List<Order>();
            for (order o : childOrders){
                o.RecordTypeId=Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_VolturaConSwitch').getRecordTypeId();
                childOrdersToUpdate.add(o);
            }
            if(childOrdersToUpdate!=null && childOrdersToUpdate.size()>0){
                update childOrdersToUpdate;
            }
        }
        
        List<Order> orderToUpdate = [SELECT Id, Phase__c, TecnicalPhase__c FROM Order WHERE id=:orderList[0].id];
        
        String s = HDT_LC_FinalConfirmationButtonController.updateRecord(orderToUpdate[0].Id);
        system.assertEquals('ok', s, 'ok');
    } 
}