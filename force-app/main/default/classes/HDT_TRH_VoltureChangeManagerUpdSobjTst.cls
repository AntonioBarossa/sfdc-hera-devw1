/**@frpanico 19/10/2021
 * Test class for the class HDT_TRH_VoltureChangeManagerUpdateSobj
 */
@IsTest
public with sharing class HDT_TRH_VoltureChangeManagerUpdSobjTst 
{
    @TestSetup
    static void setup()
    {
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();

        List<Order> orderList = new List<Order>();

        List<Account> accList=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');	
		orderList=HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].Id, 'Bozza');
        String recordTypeNameVolturaConSwitch = 'HDT_RT_VolturaConSwitch';
        String recordTypeIdVolturaConSwitch = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(recordTypeNameVolturaConSwitch).getRecordTypeId();
        List<Contact> contactList=HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id); 
        orderList[0].RecordTypeId = recordTypeIdVolturaConSwitch;
        orderList[0].Contact__c = contactList[0].Id;
        update orderList;
        
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Comunicazione verso Heroku', 'Bozza', recordTypeIdVolturaConSwitch, recordTypeNameVolturaConSwitch,'A','','','');        
    }

    @IsTest
    static void runTst()
    {
        List<Order> orderList = [SELECT Id, Phase__c FROM Order];
        orderList[0].Phase__c = HDT_SRV_VoltureChangeManager.publishUpdatePhase;

        HDT_PEV_VoltureChangeManagerUpdateSObj__e platformEvt = new HDT_PEV_VoltureChangeManagerUpdateSObj__e();
        platformEvt.SerializedSobj__c = JSON.serialize(orderList[0]);
        
        Test.startTest();
        Eventbus.publish(platformEvt);
        Test.stopTest();

        List<Order> orderListUpdated = [SELECT Id, Phase__c FROM Order];
        System.assertEquals(HDT_SRV_VoltureChangeManager.publishUpdatePhase, orderListUpdated[0].Phase__c,'Fase non correttamente aggiornata');
    }
}
