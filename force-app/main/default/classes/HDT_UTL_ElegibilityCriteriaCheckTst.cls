/*
    @Author:            Davide Viola
    LAstModifiedDate:   29/06/2022
*/

@isTest
public class HDT_UTL_ElegibilityCriteriaCheckTst {

    @testSetup
    static void setupData() {
        
        List<Account> residAccList = HDT_UTL_DataFactoryTst.createAccountResidenziale(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Famiglie');
        List<Contact> contList = HDT_UTL_DataFactoryTst.createContact(1, true, residAccList[0].Id);
        
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, false);
        ServicePoint__c mySp = servPointList[0];
        mySp.Account__c = residAccList[0].Id;
        insert mySp;

        List<BillingProfile__c> billProfList = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, residAccList[0].Id);

        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, false, residAccList[0].Id);
        Contract myContr = contractList[0];
        myContr.BillingProfile__c = billProfList[0].Id;
        insert myContr;
        
        List<Product2> prodList = HDT_UTL_DataFactoryTst.createProduct2(1, false);        
        Product2 myProd = prodList[0];
        myProd.Family = 'Offerta commerciale';
        insert myProd;

        List<SBQQ__Subscription__c> subscriptList = HDT_UTL_DataFactoryTst.createSubscription(1, false, residAccList[0].Id, contractList[0].Id, mySp.Id);
        SBQQ__Subscription__c mySubScript = subscriptList[0];
        mySubScript.SBQQ__Product__c = myProd.Id;
        insert mySubScript;

        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(6, false, residAccList[0].Id, contList[0].Id, mySp.Id, null, null);
        Case varAnagClientCase = caseList[0];
        varAnagClientCase.Cluster__c = 'Modifiche Anagrafiche';
        varAnagClientCase.Type = 'Variazione Anagrafica Cliente';
        varAnagClientCase.Subprocess__c = 'Modifica Dati di Recapito';
        varAnagClientCase.Phase__c = 'Bozza';
        varAnagClientCase.Status = 'New';
        varAnagClientCase.BillSendingMethod__c = 'Cartaceo';
        varAnagClientCase.BillingProfile__c = billProfList[0].Id;

        Case modTarResid = caseList[1];
        modTarResid.Cluster__c = 'Modifiche Anagrafiche';
        modTarResid.Type = 'Modifica Tariffa Residente/Non Residente';
        modTarResid.Phase__c = 'Bozza';
        modTarResid.Status = 'New';
        modTarResid.Resident__c = true;
        modTarResid.BillingProfile__c = billProfList[0].Id;
        
        Case marcatUsoPdr = caseList[2];
        marcatUsoPdr.Cluster__c = 'Modifiche Anagrafiche';
        marcatUsoPdr.Type = 'Marcatura/Uso PdR';
        marcatUsoPdr.Phase__c = 'Bozza';
        marcatUsoPdr.Status = 'New';
        marcatUsoPdr.UseCategory__c = '001-Uso cottura cibi';
        marcatUsoPdr.BillingProfile__c = billProfList[0].Id;
        
        Case varPotenza = caseList[3];
        varPotenza.Cluster__c = 'Modifiche Anagrafiche';
        varPotenza.Type = 'Variazione Potenza';
        varPotenza.Phase__c = 'Bozza';
        varPotenza.Status = 'New';
        varPotenza.PowerRequested__c = 10;
        varPotenza.BillingProfile__c = billProfList[0].Id;
        
        Case richDomiciliaz = caseList[4];
        richDomiciliaz.Cluster__c = 'Modifiche Anagrafiche';
        richDomiciliaz.Type = 'Richiesta Domiciliazione';
        richDomiciliaz.Phase__c = 'Bozza';
        richDomiciliaz.Status = 'New';
        richDomiciliaz.BillingProfile__c = billProfList[0].Id;
        
        Case revocaDomic = caseList[5];
        revocaDomic.Cluster__c = 'Modifiche Anagrafiche';
        revocaDomic.Type = 'Revoca Domiciliazione';
        revocaDomic.Phase__c = 'Bozza';
        revocaDomic.Status = 'New';
        revocaDomic.BillingProfile__c = billProfList[0].Id;

        insert caseList;

        List<EligibilityCriteria__c> eligibCriteriaList = HDT_UTL_DataFactoryTst.createEligibilityCriteria(1, false, myProd.Id);
        EligibilityCriteria__c eligibCriteria = eligibCriteriaList[0];
        eligibCriteria.ResidentDeliveryAddress__c = 'No';
        eligibCriteria.UseCategory__c = '002-Prod.acqua calda sanitaria';
        eligibCriteria.PowerRangeMax__c = 3;
        eligibCriteria.PaymentMode__c = 'Bollettino postale';
        insert eligibCriteria;

        HDT_UTL_DataFactoryTst.createConfigurationAttribute(1, true, 'SendingBillMode__c', myProd.Id);
        HDT_UTL_DataFactoryTst.createConfigurationAttribute(1, true, 'PaymentMode__c', myProd.Id);
    }
    
    @isTest
    public static void checkCriterioElegibilitaOkTest(){
        
        Case myCase = [SELECT Id FROM Case WHERE Type = 'Variazione Anagrafica Cliente' WITH SECURITY_ENFORCED LIMIT 1];

        HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckInput input = new HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckInput();
        input.caseId = myCase.Id;

        List<HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckInput> inputList = new List<HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckInput>{input};
        List<HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckOutput> outputList = new List<HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckOutput>();

        outputList = HDT_UTL_ElegibilityCriteriaCheck.execute(inputList);

        System.assertEquals(outputList[0].abortProcess, null, 'Caso Variazione Anagrafica Cliente in Successo!');
    }
    
    @isTest
    public static void checkCriterioElegibilitaKoTest(){
        
        SBQQ__ConfigurationAttribute__c configAttrib = [SELECT Id, SBQQ__ShownValues__c FROM SBQQ__ConfigurationAttribute__c WHERE SBQQ__TargetField__c = 'SendingBillMode__c' WITH SECURITY_ENFORCED LIMIT 1];
        configAttrib.SBQQ__ShownValues__c = 'Variazione non ammessa';
        update configAttrib;
        
        Case myCase = [SELECT Id FROM Case WHERE Type = 'Variazione Anagrafica Cliente' WITH SECURITY_ENFORCED LIMIT 1];

        HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckInput input = new HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckInput();
        input.caseId = myCase.Id;

        List<HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckInput> inputList = new List<HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckInput>{input};
        List<HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckOutput> outputList = new List<HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckOutput>();

        outputList = HDT_UTL_ElegibilityCriteriaCheck.execute(inputList);

        System.assertEquals(outputList[0].abortProcess, true, 'Processo Abortito dal Sistema');
        System.assertEquals(
            outputList[0].abortProcessWarning, 
            'L\'offerta attiva sul contratto selezionato è incompatibile con la variazione del campo Modalità Invio Bolletta. Per poter procedere è necessario eseguire un cambio offerta.',
            'Caso Variazione Anagrafica Cliente Abortita!'
        );
    }
    
    @isTest
    public static void abortModificaTariffaResidenteTest(){
        
        Case myCase = [SELECT Id FROM Case WHERE Type = 'Modifica Tariffa Residente/Non Residente' WITH SECURITY_ENFORCED LIMIT 1];

        HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckInput input = new HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckInput();
        input.caseId = myCase.Id;

        List<HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckInput> inputList = new List<HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckInput>{input};
        List<HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckOutput> outputList = new List<HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckOutput>();

        outputList = HDT_UTL_ElegibilityCriteriaCheck.execute(inputList);

        System.assertEquals(outputList[0].abortProcess, true, 'Processo Abortito dal Sistema');
        System.assertEquals(
            outputList[0].abortProcessWarning, 
            'L\'offerta attiva sul contratto selezionato è incompatibile con la variazione del campo Residente. Per poter procedere è necessario eseguire un cambio offerta.',
            'Caso Modifica Tariffa Residente/Non Residente Abortita!'
        );
    }
    
    @isTest
    public static void abortMarcaturaPdrTest(){
        
        Case myCase = [SELECT Id FROM Case WHERE Type = 'Marcatura/Uso PdR' WITH SECURITY_ENFORCED LIMIT 1];

        HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckInput input = new HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckInput();
        input.caseId = myCase.Id;

        List<HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckInput> inputList = new List<HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckInput>{input};
        List<HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckOutput> outputList = new List<HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckOutput>();

        outputList = HDT_UTL_ElegibilityCriteriaCheck.execute(inputList);

        System.assertEquals(outputList[0].abortProcess, true, 'Processo Abortito dal Sistema');
        System.assertEquals(
            outputList[0].abortProcessWarning, 
            'L\'offerta attiva sul contratto selezionato è incompatibile con la variazione del campo Tipologia Uso. Per poter procedere è necessario eseguire un cambio offerta.',
            'Caso Marcatura/Uso PdR Abortita!'
        );
    }
    
    @isTest
    public static void abortVariazionePotenzaTest(){
        
        Case myCase = [SELECT Id FROM Case WHERE Type = 'Variazione Potenza' WITH SECURITY_ENFORCED LIMIT 1];

        HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckInput input = new HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckInput();
        input.caseId = myCase.Id;

        List<HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckInput> inputList = new List<HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckInput>{input};
        List<HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckOutput> outputList = new List<HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckOutput>();

        outputList = HDT_UTL_ElegibilityCriteriaCheck.execute(inputList);

        System.assertEquals(outputList[0].abortProcess, true, 'Processo Abortito dal Sistema');
        System.assertEquals(
            outputList[0].abortProcessWarning, 
            'L\'offerta attiva sul contratto selezionato è incompatibile con l\'aumento di potenza richiesto. Per poter procedere è necessario eseguire un cambio offerta.',
            'Caso Variazione Potenza Abortita!'
        );
    }
    
    @isTest
    public static void revocaDomiciliazioneOk(){
        
        Case myCase = [SELECT Id FROM Case WHERE Type = 'Revoca Domiciliazione' WITH SECURITY_ENFORCED LIMIT 1];

        HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckInput input = new HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckInput();
        input.caseId = myCase.Id;

        List<HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckInput> inputList = new List<HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckInput>{input};
        List<HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckOutput> outputList = new List<HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckOutput>();

        outputList = HDT_UTL_ElegibilityCriteriaCheck.execute(inputList);

        System.assertEquals(outputList[0].abortProcess, null, 'Processo Abortito dal Sistema');
    }
    
    @isTest
    public static void abortRevocaDomiciliazioneTest(){
        
        Case myCase = [SELECT Id FROM Case WHERE Type = 'Revoca Domiciliazione' WITH SECURITY_ENFORCED LIMIT 1];

        SBQQ__ConfigurationAttribute__c configAttrib = [SELECT Id, SBQQ__ShownValues__c FROM SBQQ__ConfigurationAttribute__c WHERE SBQQ__TargetField__c = 'PaymentMode__c' WITH SECURITY_ENFORCED LIMIT 1];
        configAttrib.SBQQ__ShownValues__c = 'Variazione non ammessa';
        update configAttrib;

        HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckInput input = new HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckInput();
        input.caseId = myCase.Id;

        List<HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckInput> inputList = new List<HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckInput>{input};
        List<HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckOutput> outputList = new List<HDT_UTL_ElegibilityCriteriaCheck.HDT_WRP_ElegibilityCriteriaCheckOutput>();

        outputList = HDT_UTL_ElegibilityCriteriaCheck.execute(inputList);

        System.assertEquals(outputList[0].abortProcess, true, 'Processo Abortito dal Sistema');
        System.assertEquals(
            outputList[0].abortProcessWarning, 
            'L\'offerta attiva sul contratto selezionato è incompatibile con la revoca della Domiciliazione. Per poter procedere è necessario eseguire un cambio offerta.',
            'Caso Revoca Domiciliazione Abortita!'
        );
    }
}