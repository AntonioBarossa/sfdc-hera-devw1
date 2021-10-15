/**@frpanico 12/10/2021
 * Test Class for the class HDT_UTL_VoltureCHangeUtilities
 */
@IsTest
public with sharing class HDT_UTL_VoltureChangeUtilitiesTst {

    private static HDT_UTL_VoltureChangeUtilities voltureChangeUtilities = new HDT_UTL_VoltureChangeUtilities();

    @TestSetup
    static void setup()
    {
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();

        List<Account> accList=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');	
		List<Order> orderList =HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].Id, 'Bozza');
        List<Contact> contactList=HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id); 

        String recordTypeNameVolturaConSwitch = 'HDT_RT_VolturaConSwitch';
        String recordTypeIdVolturaConSwitch = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(recordTypeNameVolturaConSwitch).getRecordTypeId();

        orderList[0].RecordTypeId = recordTypeIdVolturaConSwitch;
        orderList[0].Contact__c = contactList[0].Id;
        update orderList;

        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Comunicazione verso Heroku', 'Bozza', recordTypeIdVolturaConSwitch, recordTypeNameVolturaConSwitch,'A','','','');

    }

    @IsTest
    static void updateOrderFutureTst()
    {
        List<Order> orderToUpdate = [SELECT Id, Phase__c FROM Order];
        orderToUpdate[0].Phase__c = 'Comunicazione verso Heroku';
        Test.startTest();
        HDT_UTL_VoltureChangeUtilities.updateOrderFuture(JSON.serialize(orderToUpdate[0]));
        Test.stopTest();
        List<Order> orderUpdated = [SELECT Id, Phase__c FROM Order];
        System.assertEquals('Comunicazione verso Heroku', orderUpdated[0].Phase__c,'Fase non correttamente aggiornata');
    }

    @IsTest
    static void nextPhaseBusinessAccountTst()
    {
        HDT_WRP_VoltureChangeManager.HDT_WRP_AccountCheck accountCheck = new HDT_WRP_VoltureChangeManager.HDT_WRP_AccountCheck();
        List<Order> orderToUpdate = [SELECT Id, Phase__c FROM Order];
        Test.startTest();
        accountCheck = voltureChangeUtilities.nextPhaseBusinessAccount(System.today(), '', orderToUpdate[0].Id);
        Test.stopTest();
        System.assertEquals(HDT_UTL_VoltureChangeUtilities.communicationPhase, accountCheck.nextPhase, 'Fase non correttamente calcolata');
    }

    @IsTest
    static void nextPhaseBusinessAccountWaitingTst()
    {
        HDT_WRP_VoltureChangeManager.HDT_WRP_AccountCheck accountCheck = new HDT_WRP_VoltureChangeManager.HDT_WRP_AccountCheck();
        List<Order> orderToUpdate = [SELECT Id, Phase__c FROM Order];
        Test.startTest();
        accountCheck = voltureChangeUtilities.nextPhaseBusinessAccount(System.today().addDays(1), '', orderToUpdate[0].Id);
        Test.stopTest();
        System.assertEquals(HDT_UTL_VoltureChangeUtilities.waitingPhase, accountCheck.nextPhase, 'Fase non correttamente calcolata');
    }

}
