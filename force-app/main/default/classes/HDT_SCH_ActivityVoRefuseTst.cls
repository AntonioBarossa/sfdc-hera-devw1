@isTest
public with sharing class HDT_SCH_ActivityVoRefuseTst 
{

    private static HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();

    @TestSetup
    static void setup()
    {   
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();

        CS_DaysToExpiration__c daysExpirationVo = new CS_DaysToExpiration__c();
        daysExpirationVo.Name = 'ValidazioneVO';
        daysExpirationVo.Type__c = 'ValidazioneVO';
        daysExpirationVo.NumberOfDays__c = '-1';
        insert daysExpirationVo;

        String dossierRecTypeName = utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_ORDERDOSSIER;
        String dossierRecTypeId = utlConstants.ORDER_RECORDTYPEID_ORDERDOSSIER;
        String switchRecTypeName = utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_SWITCHIN;
        String switchRecTypeId = utlConstants.ORDER_RECORDTYPEID_SWITCHIN;

        HDT_UTL_DataFactoryTst.newPhaseTransition('Annullato','Bozza', dossierRecTypeId, dossierRecTypeName);
        HDT_UTL_DataFactoryTst.newPhaseTransition('Annullato','Bozza', switchRecTypeId, switchRecTypeName);

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Contact> conList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id); 
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(2, false, accList[0].id, 'Bozza');
        ordList[0].RecordTypeId = dossierRecTypeId;
        ordList[0].Contact__c = conList[0].Id;
        ordList[1].RecordTypeId = switchRecTypeId;
        ordList[1].Contact__c = conList[0].Id;
        insert ordList;
        List<wrts_prcgvr__Activity__c> activityVo = HDT_UTL_DataFactoryTst.createActivityCustom(1,false, accList[0].Id);
        activityVo[0].Type__c = 'Validazione Vocal Order';
        activityVo[0].Order__c = ordList[0].Id;
        insert activityVo;
        ordList[1].ParentOrder__c = ordList[0].Id;
        update ordList;



    }
    @isTest
    static void executeTst()
    {
        String cronExpr = '0 0 0 10 10 ?';
        Test.startTest();
            HDT_SCH_ActivityVoRefuse activityVoRefuse = new HDT_SCH_ActivityVoRefuse();
            String jobId = System.schedule('sendOrderToSii', cronExpr, activityVoRefuse);
            activityVoRefuse.execute(null);
        Test.stopTest();
        List<Order> orderList = [SELECT Id, Phase__c FROM Order WHERE ParentOrder__c != NULL];
        System.assertEquals(true, String.isNotBlank(jobId),'Schedulazione fallita');
        System.assertEquals('Annullato', orderList[0].Phase__c, 'Fase non aggiornata correttamente');
    }    
}
