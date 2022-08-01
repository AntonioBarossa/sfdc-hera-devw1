@isTest
public with sharing class HDT_SCH_SendOrderToSiiTst 
{
    private static HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();

    @TestSetup
    static void setup()
    {
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        
        Id recTypeId = utlConstants.ORDER_RECORDTYPEID_SWITCHIN;
        String recTypeName = utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_SWITCHIN;
        HDT_UTL_DataFactoryTst.newPhaseTransition('Comunicazione verso Heroku','In attesa tempi di ripensamento', recTypeId, recTypeName);
        
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Contact> conList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id); 
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].id, 'In attesa tempi di ripensamento');
        ordList[0].RecordTypeId = recTypeId;
        ordList[0].Contact__c = conList[0].Id;
        ordList[0].DateSentToSII__c = System.today();
        insert ordList;
    }

    @isTest
    static void executeTst()
    {
        String cronExpr = '0 0 0 10 10 ?';
        Test.startTest();
            HDT_SCH_SendOrderToSii sendOrderToSii = new HDT_SCH_SendOrderToSii();
            String jobId = System.schedule('sendOrderToSii', cronExpr, sendOrderToSii);
            sendOrderToSii.execute(null);
        Test.stopTest();
        List<Order> orderList = [SELECT Id, Phase__c FROM order];
        System.assertEquals(true, String.isNotBlank(jobId),'Schedulazione fallita');
        System.assertEquals('Comunicazione verso Heroku', orderList[0].Phase__c, 'Fase non aggiornata correttamente');
    }       

}
