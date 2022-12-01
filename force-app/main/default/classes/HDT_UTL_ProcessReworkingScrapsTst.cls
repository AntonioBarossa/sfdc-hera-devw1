@isTest
public with sharing class HDT_UTL_ProcessReworkingScrapsTst {
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    @testSetup
    static void setup(){

        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
 
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
 
        internalUser.UserPermissionsMarketingUser=true;
 
        insert internalUser;
 
        String orceNumberString = '';

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

        HDT_UTL_DataFactoryTst.pClickCasePhase();

        String rtName = 'HDT_RT_VerificheGas';
        String rtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(rtName).getRecordTypeId();
        String rtNamePianoRat = 'HDT_RT_PianoRateizzazione';
        String rtIdPianRat = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(rtNamePianoRat).getRecordTypeId();
        String rtNameAutolettura = 'HDT_RT_Autolettura';
        String rtIdAutolettura = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(rtNameAutolettura).getRecordTypeId();
        String rtNamePostSales = 'HDT_RT_Domiciliazione';
        String rtIdPostSales = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(rtNamePostSales).getRecordTypeId();
        String rtNameVolturaTecnica = 'HDT_RT_VolturaTecnica';
        String rtIdVolturaTecnica = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(rtNameVolturaTecnica).getRecordTypeId();
        String rtNameBloccoSollecitoInteressi = 'HDT_RT_AltriProcessiPagamenti';
        String rtIdBloccoSollecitoInteressi = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(rtNameBloccoSollecitoInteressi).getRecordTypeId();

        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Attesa conferma preventivo cliente', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Preventivo scaduto', 'Attesa conferma preventivo cliente', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Bozza Annullata', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Pratica In Attesa', 'Bozza', rtIdPianRat, rtNamePianoRat,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Esito KO da SAP', 'Bozza', rtIdPianRat, rtNamePianoRat,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Da Inviare', 'Pratica In Attesa', rtIdPianRat, rtNamePianoRat,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Completata', 'Pratica In Attesa', rtIdPianRat, rtNamePianoRat,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Bozza Annullata', 'Bozza', rtIdPianRat, rtNamePianoRat,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Esito KO da SAP', 'Pratica In Attesa', rtIdPianRat, rtNamePianoRat,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Bozza Annullata', 'Bozza', rtIdPostSales, rtNamePostSales,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Bozza Annullata', 'Bozza', rtIdAutolettura, rtNameAutolettura,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'In attesa Data Decorrenza','Bozza', rtIdVolturaTecnica, rtNameVolturaTecnica, 'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Da Inviare', 'In attesa Data Decorrenza', rtIdVolturaTecnica, rtNameVolturaTecnica, 'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'In attesa Data Decorrenza', 'Da Inviare', rtIdVolturaTecnica, rtNameVolturaTecnica, 'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'In Lavorazione', 'Pratica In Attesa', rtIdBloccoSollecitoInteressi, rtNameBloccoSollecitoInteressi, 'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Pratica In Attesa', 'Bozza', rtIdBloccoSollecitoInteressi, rtNameBloccoSollecitoInteressi, 'A','','','');


        List<Account> accList = [select id from account];
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(2, false, accList[0].id, 'Bozza');
        ordList[0].EffectiveDate__c = Date.today()-5;
        ordList[1].EffectiveDate__c = Date.today().addMonths(1);
        insert ordList;
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        List<BillingProfile__c> billingProfileList = HDT_UTL_DataFactoryTst.createBillingProfile(1,true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);        
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(8, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        
        Datetime oneDayAgo = Datetime.now().addDays(-5);
        Test.setCreatedDate(caseList[3].Id, oneDayAgo);

        Datetime oneMonthAgo = Datetime.now().addDays(-40);
        Test.setCreatedDate(caseList[4].Id, oneMonthAgo);

        caseList[0].BillingProfile__c = billingProfileList[0].Id;
        caseList[0].Phase__c = 'Attesa conferma preventivo cliente';
        caseList[0].QuotationValidityDate__c = Date.today()-5;
        caseList[0].Cluster__c = 'Verifiche';
        caseList[0].RecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_VerificheGas').getRecordTypeId();
        update caseList;    




        List<Case> cl = [SELECT CaseNumber FROM CASE];
        List<Order> ol = [select ordernumber from order];
        
        MassiveLoaderRequest__c request = new MassiveLoaderRequest__c();
        request.TotalRequest__c = 1;
        request.Priority__c = 1;
        request.ProcessType__c = 'RilavorazioneScarti';
        request.Status__c = 'In attesa di lavorazione';
        insert request;

        List<MassiveLoaderRequestItem__c> itemsList = new List<MassiveLoaderRequestItem__c>();
        MassiveLoaderRequestItem__c item;
    
        for(Integer n=0; n<1; n++){
            item = new MassiveLoaderRequestItem__c();
            item.MassiveLoaderRequest__c = request.Id;
            item.Status__c = 'In attesa di lavorazione';
            item.Data__c = ol[0].OrderNumber;
            itemsList.add(item);
        }

        for(Integer n=0; n<1; n++){
            item = new MassiveLoaderRequestItem__c();
            item.MassiveLoaderRequest__c = request.Id;
            item.Status__c = 'In attesa di lavorazione';
            item.Data__c = cl[0].CaseNumber;
            itemsList.add(item);
        }

        insert itemsList;

    }

    @isTest
    public static void testReworkingScraps(){
        Test.startTest();
        HDT_SRV_ProcessRequestItem r = new HDT_SRV_ProcessRequestItem();
        r.execute();
        Test.stopTest();
    }
}