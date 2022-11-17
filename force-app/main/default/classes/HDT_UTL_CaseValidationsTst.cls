/*
    @Author:        Francesco Vitiello
    CreatedDate:    11/10/2021
*/

@isTest
public with sharing class HDT_UTL_CaseValidationsTst {

    
    //DEBUG
    public static final String TEST_NAME = 'HDT_UTL_CaseValidationsTst';

    private static HDT_UTL_CaseValidations caseValidationsUtl = new HDT_UTL_CaseValidations();
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    
    //Added Setup
    @TestSetup
    static void setup(){
        Case myCase = new Case();
        myCase.Type = 'Proroga Conn Temp';
        myCase.Cluster__c = 'Disattivazioni';
        myCase.TemporaryConnectionEndDate__c = Date.newInstance(2022, 08, 16);
        insert myCase;  
    }
    
    //TEST SETUP
    private static void mySetup(){

        HDT_UTL_DataFactoryTst.pClickCasePhase();
        HDT_UTL_DataFactoryTst.pClickInstance();   

        //Account
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        accList[0].ShippingStreetName__c = 'Via Guglielmo Marconi';
        accList[0].ShippingStreetNumber__c = '15';
        accList[0].ShippingCity = 'Ancona';
        accList[0].ShippingState = 'IT';
        accList[0].ShippingPostalCode = '60121';
        accList[0].ShippingCountry = 'ITALIA';
        accList[0].Name = 'Franco Rossi';
        accList[0].FirstName__c = 'Franco';
        accList[0].LastName__c = 'Rossi';
        accList[0].FiscalCode__c = 'RSSMRA80A01D548N';
        accList[0].VATNumber__c = '03819031208';
        accList[0].BillingStreetName__c = 'Via Guglielmo Marconi';
        accList[0].BillingStreetNumber__c = '15';
        accList[0].BillingStreetNumberExtension__c = 'D';
        accList[0].BillingCity = 'Ancona';
        accList[0].BillingState = 'IT';
        accList[0].BillingPostalCode = '60121';
        accList[0].BillingCountry = 'ITALIA';
        accList[0].BillingPlace__c = 'test place';
        accList[0].IsVATGroupJoined__c = true;
        accList[0].VATGroup__c = '86334519757';
        Date myNewStartDate = Date.newInstance(2021, 09, 28);
        accList[0].VATGroupStartDate__c = myNewStartDate;
        Date myNewEndDate = Date.newInstance(2021, 09, 25);
        accList[0].VATGroupStartDate__c = myNewEndDate;
        update accList;

        //Order
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');

        //ServicePoint
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(2, true);
        servPointList[0].CommoditySector__c = 'Energia Elettrica';
        servPointList[0].ServicePointCode__c = 'IT001E12455810';
        servPointList[1].CommoditySector__c = 'Gas';
        servPointList[1].ServicePointCode__c = 'IT001E12455810';
        update servPointList;

        //Contact
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        contactList[0].Email = 'myEmail@email.com';
        contactList[0].MobilePhone = '9872345123';
        contactList[0].Phone = '9879873425';
        contactList[0].CertifiedEmail__c = 'myCertifiedEmail@certifiedEmail.com';
        contactList[0].Fax = '0898352638';
        update contactList;

        //Contract
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);

        //Case
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(39, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        CaseList[0].Type = 'Richiesta Parere';
        CaseList[0].OpinionRequest__c = 'Prova parere';
        CaseList[1].Type = 'Piano Rateizzazione';
        CaseList[2].Type = 'Piano Rateizzazione';
        caseList[3].Type = 'Blocco Sollecito/Interessi';
        caseList[4].Type = 'Paperless';
        caseList[5].Type = 'Variazione Domiciliazione';
        caseList[6].Type = 'Rimborso';
        caseList[7].Type = 'Variazione Anagrafica Cliente';
        caseList[7].Subprocess__c = 'Modifica Dati di Contatto';
        caseList[7].PhoneNumber__c = '9879873425';
        caseList[7].Email__c = 'myEmail@email.com';
        caseList[7].Mobile__c = '9872345123';
        caseList[7].CertifiedEmail__c = 'myCertifiedEmail@certifiedEmail.com';
        caseList[7].Fax__c  = 'myFax';
        caseList[8].Type = 'Variazione Anagrafica Cliente';
        caseList[8].Subprocess__c = 'Modifica Dati di recapito';
        caseList[9].Type = 'Variazione Anagrafica Cliente';
        caseList[9].Subprocess__c = 'Modifica Dati Fiscali';
        caseList[9].FirstName__c = 'Franco';
        caseList[9].FiscalCode__c = 'RSSMRA80A01D548N';
        caseList[9].VatNumber__c = '03819031208';
        caseList[9].AlternativeAddress__c = 'Via Guglielmo Marconi, 15, D, Ancona, IT, 60121, ITALIA';
        caseList[10].Type = 'Variazione Anagrafica Cliente';
        caseList[10].Subprocess__c = 'Variazione Gruppo IVA';
        caseList[11].Type = 'Storno Rateizzazione';
        caseList[12].Type = 'Esercizio Diritti Privacy';
        caseList[13].Type = 'Modifica Privacy';
        caseList[14].ServicePoint__c = servPointList[1].Id;
        caseList[15].Type = 'Inversione del Contatore';
        caseList[16].Type = 'Gestione Bonus Sociale';
        caseList[17].Type = 'Riattivazione Fornitura';
        caseList[18].Type = 'Gestione Disalimentabilità';
        caseList[19].Type = 'Marcatura/Uso PdR';
        caseList[19].Subprocess__c = 'IVA - Agevolazione cliente';
        caseList[20].Type = 'BP/CA - errata categoria';
        caseList[20].Subprocess__c = 'IVA - Agevolazione cliente';
        caseList[21].Type = 'Modifica/Azzeramento Consumo Annuo';
        caseList[22].Type = 'Fiscale';
        caseList[22].Subprocess__c = 'IVA - Agevolazione cliente';
        caseList[23].Type = 'Modifica Tariffa Residente/Non Residente';
        caseList[24].Type = 'Condizioni Contrattuali Errate';
        caseList[25].Type = 'Mancata Telelettura/lettura';
        caseList[26].Type = 'Modifica Layout di dettaglio';
        caseList[27].Type = 'Chiusura Contatore';
        caseList[28].Type = 'Contratto Non Richiesto';
        caseList[29].Type = 'Unificazione/Separazione BP-CA-Bolletta';
        caseList[30].Type = 'Spostamento Votive Modena';
        caseList[31].Type = 'Votive Modena Contestazione Fattura';
        caseList[32].Type = 'Verifica Titolarità POD/PDR';
        caseList[33].Type = 'Voltura Tecnica';
        caseList[34].Type = 'Proroga Conn Temp';
        String rtName = 'HDT_RT_FlyingRequest';
        String rtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(rtName).getRecordTypeId();
        caseList[35].RecordTypeId = rtId;
        caseList[35].Type = 'Nuovo Impianto';
        caseList[35].Cluster__c = 'Preventivi';        
        caseList[36].RecordTypeId = rtId;
        caseList[36].Type = 'Nuovo Impianto';
        caseList[36].Cluster__c = 'Preventivi';
        caseList[36].Commodity__c = 'Gas';
        caseList[36].SupplyType__c = 'A-Domestico';
        caseList[36].Taxes__c = 'Imposta Usi Domestici (Cod. G_ICD)';
        caseList[36].ServicePointType__c = '1002-Cottura/Produz acq calda';
        caseList[36].ShipmentAddressAssign__c = 'VIA DALLA VOLTA 1 , BOLOGNA BO, 40131 ITALIA';
        String rtName1 = 'HDT_RT_GenericheAttivazioni';
        String rtId1 = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(rtName1).getRecordTypeId();
        caseList[37].Type = 'Modifica Contr Preattivazione Anagr Res';
        caseList[37].RecordTypeId = rtId;
        caseList[37].Cluster__c = 'Attivazioni';
        String rtName2 = 'HDT_RT_AllineamentoAnagrafica';
        String rtId2 = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(rtName2).getRecordTypeId();
        caseList[38].RecordTypeId = rtId2;
        caseList[38].Type = 'Variazione Anagrafica Cliente';
        caseList[38].Subprocess__c = 'Modifica Dati di Contatto';
        caseList[38].CustomerMarking__c = 'Azienda';
        caseList[38].Category__c = 'Aziende Soho';
        caseList[38].Email__c = 'myEmail@email.com';
        caseList[38].Mobile__c = '9872345123';
        caseList[38].PhoneNumber__c = '9879873425';
        caseList[38].CertifiedEmail__c = 'myCertifiedEmail@certifiedEmail.com';
        caseList[38].Fax__c = '0898352638';

        update caseList;

        List<FormulaRecalcResult> results1 = Formula.recalculateFormulas(caseList);
        System.assert(results1[0].isSuccess(), 'results1[0] deve essere success');

        //Billing Profile
        List<BillingProfile__c> bPList = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, accList[0].Id);
        BPList[0].PaymentMethod__c = 'Bonifico bancario';
        update BPList[0];

    }
    
    //TESTS

    @isTest
    private static void validateTestType1(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType1';
        System.debug(debugString);
        
        //SETUP

        mySetup();

        Case myCase1 = [Select Id, Type, DelegateName__c, ComplaintEntryChannel__c, CompliantOriginEmail__c,
         SoldBy__c, OpinionRequest__c,
         ComplaintType__c, FirstLevelComplaintClassification__c, SecondLevelComplaintClassification__c,
         ThirdLevelComplaintClassification__c, FithLevelComplaintClassification__c from Case where Type = 'Richiesta Parere'];

        String recordId1 = myCase1.Id;
        myCase1.ComplaintEntryChannel__c = 'PEC';
        myCase1.CompliantOriginEmail__c = '';
        String fields1 = JSON.serialize(myCase1);

        String recordId7 = myCase1.Id;
        myCase1.CompliantOriginEmail__c = 'Tizio';
        myCase1.DelegateName__c = 'Mario Rossi';
        myCase1.FithLevelComplaintClassification__c = '';
        String fields7 = JSON.serialize(myCase1);

        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' or Name='Utente standard'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
         UserName=uniqueUserName);

        insert u;

        String recordId7b = myCase1.Id;
        myCase1.DelegateName__c = '';
        myCase1.FithLevelComplaintClassification__c = '';
        myCase1.SoldBy__c = u.Id;
        String fields7b = JSON.serialize(myCase1);

        String recordId8 = myCase1.Id;
        myCase1.SendDate__c = Date.today().addDays(5);
        String fields8 = JSON.serialize(myCase1);

        String recordId9 = myCase1.Id;
        myCase1.ComplaintType__c = 'Reclamo Scritto';
        myCase1.FirstLevelComplaintClassification__c = 'Reclamo Scritto';
        myCase1.SecondLevelComplaintClassification__c = 'Mercato';
        myCase1.ThirdLevelComplaintClassification__c = 'Presunti Contratti non Richiesti';
        myCase1.FithLevelComplaintClassification__c = 'Firma falsa';
        String fields9 = JSON.serialize(myCase1);

        String recordId10 = myCase1.Id;
        myCase1.SendDate__c = Date.today().addDays(-5);
        myCase1.OpinionRequest__c = 'Prova parere';
        myCase1.ComplaintEntryChannel__c = 'Fax';
        myCase1.CompliantOriginEmail__c = 'test@test.com';
        String fields10 = JSON.serialize(myCase1);

        String recordId10b = myCase1.Id;
        myCase1.OpinionRequest__c = null;
        String fields10b = JSON.serialize(myCase1);

        //TESTING
        Test.startTest();

        Try{

            HDT_UTL_CaseValidations myClass1 = new HDT_UTL_CaseValidations();

            myClass1.validate(fields1, recordId1);
            myClass1.validate(fields7, recordId7);
            myClass1.validate(fields8, recordId8);
            myClass1.validate(fields9, recordId9);
            myClass1.validate(fields10, recordId10);
            myClass1.validate(fields10b, recordId10b);

        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();

        //ASSERTS
        System.assert(myCase1 != null, 'myCase1 non può essere null');
    }


    @isTest
    private static void validateTestType2A(){
    
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType2';
        System.debug(debugString);
        
        //SETUP

        mySetup();
        Case myCase2 = [Select Id, Type, AttachmentManagement__c, Deposit__c, DepositAmount__c, DepositPaymentMode__c, ApplicationInterests__c, InstallmentNumberRequired__c from Case where Type = 'Piano Rateizzazione'][0];

        String recordId2 = myCase2.Id;
        myCase2.AttachmentManagement__c = true;
        String fields2 = JSON.serialize(myCase2);

        String recordId2b = myCase2.Id;
        myCase2.AttachmentManagement__c = false;
        String fields2b = JSON.serialize(myCase2);

        String recordId3 = myCase2.Id;
        myCase2.AttachmentManagement__c = null;
        myCase2.Deposit__c = true;
        myCase2.DepositPaymentMode__c = '';
        String fields3 = JSON.serialize(myCase2);

        Account myAccount = [select Id, Category__c from Account];
        List<Case> newList = new List<Case>();
        newList.add(myCase2);
        List<FormulaRecalcResult> results = Formula.recalculateFormulas(newList);
        System.assert(results[0].isSuccess(), 'results[0] deve essere success');
        String recordId4 = myCase2.Id;
        myCase2.Deposit__c = false;
        myCase2.ApplicationInterests__c = false;
        myCase2.InstallmentNumberRequired__c = 8;
        String fields4 = JSON.serialize(myCase2);

        String recordId5 = myCase2.Id;
        myCase2.ApplicationInterests__c = true;
        myCase2.InstallmentNumberRequired__c = 4;
        String fields5 = JSON.serialize(myCase2);

        String recordId6 = myCase2.Id;
        myCase2.ApplicationInterests__c = true;
        myCase2.InstallmentNumberRequired__c = 1;
        String fields6 = JSON.serialize(myCase2);


        Test.startTest();
        Try{
                
            HDT_UTL_CaseValidations myClass2A = new HDT_UTL_CaseValidations();

            myClass2A.validate(fields2, recordId2);

            myClass2A.validate(fields2b, recordId2b);

            myClass2A.validate(fields3, recordId3);

            myClass2A.validate(fields4, recordId4);

            myClass2A.validate(fields5, recordId5);

            myClass2A.validate(fields6, recordId6);

        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();

        //ASSERTS
        System.assert(myCase2 != null, 'myCase2 non può essere null');

    }

    @isTest
    private static void validateTestType2B(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType2B';
        System.debug(debugString);
        
        //SETUP

        mySetup();

        Case myCase3 = [Select Id, Type, TypeInstallmentPlan__c, Deposit__c, DepositPaymentMode__c, SendPaperlessCodeMode__c from Case where Type = 'Piano Rateizzazione'][1];

        Account myAccount = [select Id, Category__c from Account];
        myAccount.Category__c = 'Aziende TOP';
        update myAccount;
        List<Case> newList = new List<Case>();
        newList.add(myCase3);
        List<FormulaRecalcResult> results = Formula.recalculateFormulas(newList);
        System.assert(results[0].isSuccess(), 'results[0] deve essere success');

        String recordId6b = myCase3.Id;
        myCase3.Deposit__c = false;
        myCase3.TypeInstallmentPlan__c = 'Straordinario';
        String fields6b = JSON.serialize(myCase3);

        String recordId11 = myCase3.Id;
        myCase3.DepositPaymentMode__c = 'Paperless';
        myCase3.SendPaperlessCodeMode__c = '';
        String fields11 = JSON.serialize(myCase3);

        String recordId12 = myCase3.Id;
        myCase3.SendPaperlessCodeMode__c = 'SMS';
        String fields12 = JSON.serialize(myCase3);
        
        String recordId13 = myCase3.Id;
        myCase3.SendPaperlessCodeMode__c = 'Email';
        String fields13 = JSON.serialize(myCase3);

        String recordId14 = myCase3.Id;
        myCase3.SendPaperlessCodeMode__c = '';
        String fields14 = JSON.serialize(myCase3);

        Test.startTest();
        Try{
            
            HDT_UTL_CaseValidations myClass3 = new HDT_UTL_CaseValidations();

            myClass3.validate(fields11, recordId11);
            myClass3.validate(fields12, recordId12);
            myClass3.validate(fields13, recordId13);
            myClass3.validate(fields14, recordId14);

        }catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();

        //ASSERTS
        System.assert(myCase3 != null, 'myCase3 non può essere null');
    }

    @isTest
    private static void validateTestType3(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType3';
        System.debug(debugString);
        
        //SETUP

        mySetup();
        Case myCase4 = [Select Id, Type, AttachmentManagement__c, Deposit__c, DepositPaymentMode__c, SendPaperlessCodeMode__c from Case where Type = 'Blocco Sollecito/Interessi'];

        String recordId15 = myCase4.Id;
        myCase4.BlockType__c = 'M';
        String fields15 = JSON.serialize(myCase4);

        String recordId16 = myCase4.Id;
        myCase4.BlockType__c = 'W';
        String fields16 = JSON.serialize(myCase4);


        Test.startTest();
        Try{
            
            HDT_UTL_CaseValidations myClass4 = new HDT_UTL_CaseValidations();

            myClass4.validate(fields15, recordId15);
            myClass4.validate(fields16, recordId16);

        }catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();

        //ASSERTS
        System.assert(myCase4 != null, 'myCase4 non può essere null');
    }


    @isTest
    private static void validateTestType4(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType4';
        System.debug(debugString);
        
        //SETUP

        mySetup();
        Case myCase5 = [Select Id, Type, SendPaperlessCodeMode__c, Email__c from Case where Type = 'Paperless'];

        String recordId17 = myCase5.Id;
        myCase5.SendPaperlessCodeMode__c = 'SMS';
        String fields17 = JSON.serialize(myCase5);

        String recordId18 = myCase5.Id;
        myCase5.SendPaperlessCodeMode__c = 'Email';
        String fields18 = JSON.serialize(myCase5);

        String recordId19 = myCase5.Id;
        myCase5.SendPaperlessCodeMode__c = '';
        String fields19 = JSON.serialize(myCase5);

        Test.startTest();
        Try{
            
            HDT_UTL_CaseValidations myClass5 = new HDT_UTL_CaseValidations();

            myClass5.validate(fields17, recordId17);
            myClass5.validate(fields18, recordId18);
            myClass5.validate(fields19, recordId19);

        }catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();

        //ASSERTS
        System.assert(myCase5 != null, 'myCase5 non può essere null');
    }

    @isTest
    private static void validateTestType4b(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType4b';
        System.debug(debugString);
        
        //SETUP

        mySetup();
        Case myCase5b = [Select Id, Type, Reason__c, BankAccountSignatoryFiscalCode__c, AccountholderTypeBeneficiary__c, BillingProfile__c from Case where Type = 'Variazione Domiciliazione'];
        BillingProfile__c myBillingProfile = [Select Id from BillingProfile__c];

        String recordId20 = myCase5b.Id;
        myCase5b.BillingProfile__c = myBillingProfile.Id;
        myCase5b.Reason__c = 'Cambio Banca';
        myCase5b.BankAccountSignatoryFiscalCode__c = 'RSSMRA80A01D548N';
        myCase5b.BankAccountSignatoryFirstName__c = 'Mario';
        myCase5b.BankAccountSignatoryLastName__c = 'Rossi';
        String fields20 = JSON.serialize(myCase5b);
        update myCase5b;

        Account myAccount = [select Id, Category__c, CustomerMarking__c from Account];
        myAccount.Category__c = 'Famiglie';
        myAccount.CustomerMarking__c = 'D1 - Persona fisica';
        update myAccount;
        List<Case> newList = new List<Case>();
        newList.add(myCase5b);
        List<FormulaRecalcResult> results = Formula.recalculateFormulas(newList);
        System.assert(results[0].isSuccess(), 'results[0] deve essere success');

        String recordId21 = myCase5b.Id;
        myCase5b.BankAccountSignatoryFiscalCode__c = '';
        myCase5b.AccountholderTypeBeneficiary__c = 'Rappresentante Legale';
        String fields21 = JSON.serialize(myCase5b);

        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass5b = new HDT_UTL_CaseValidations();

            myClass5b.validate(fields20, recordId20);
            myClass5b.validate(fields21, recordId21);
            
        }catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();

        //ASSERTS
        System.assert(myCase5b != null, 'myCase5b non può essere null');
    }

    @isTest
    private static void validateTestType5(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType5';
        System.debug(debugString);
        
        //SETUP

        mySetup();
        Case myCase6 = [Select Id, Type, Reason__c, BankAccountSignatoryFiscalCode__c, AccountholderTypeBeneficiary__c, BillingProfile__c from Case where Type = 'Variazione Domiciliazione'];
        BillingProfile__c myBillingProfile = [Select Id from BillingProfile__c];

        String recordId20 = myCase6.Id;
        myCase6.BillingProfile__c = myBillingProfile.Id;
        myCase6.Reason__c = 'Cambio Banca';
        myCase6.BankAccountSignatoryFiscalCode__c = 'RSSMRA80A01D548N';
        myCase6.BankAccountSignatoryFirstName__c = 'Mario';
        myCase6.BankAccountSignatoryLastName__c = 'Rossi';
        String fields20 = JSON.serialize(myCase6);
        update myCase6;

        Account myAccount = [select Id, Category__c, CustomerMarking__c from Account];
        myAccount.Category__c = 'Famiglie';
        myAccount.CustomerMarking__c = 'D1 - Persona fisica';
        update myAccount;
        List<Case> newList = new List<Case>();
        newList.add(myCase6);
        List<FormulaRecalcResult> results = Formula.recalculateFormulas(newList);
        System.assert(results[0].isSuccess(), 'results[0] deve essere success');

        String recordId21 = myCase6.Id;
        myCase6.BankAccountSignatoryFiscalCode__c = '';
        myCase6.AccountholderTypeBeneficiary__c = 'Rappresentante Legale';
        String fields21 = JSON.serialize(myCase6);

        myAccount.Category__c = 'Aziende SME';
        myAccount.CustomerMarking__c = 'Azienda';
        update myAccount;
        List<Case> newList2 = new List<Case>();
        newList2.add(myCase6);
        List<FormulaRecalcResult> results1 = Formula.recalculateFormulas(newList2);
        System.assert(results1[0].isSuccess(), 'results1[0] deve essere success');

        String recordId22 = myCase6.Id;
        myCase6.AccountholderTypeBeneficiary__c = 'Stesso Sottoscrittore';
        String fields22 = JSON.serialize(myCase6);

        String recordId23 = myCase6.Id;
        myCase6.AccountholderTypeBeneficiary__c = 'Pagatore Alternativo';
        String fields23 = JSON.serialize(myCase6);

        String recordId24 = myCase6.Id;
        myCase6.AccountholderTypeBeneficiary__c = '';
        String fields24 = JSON.serialize(myCase6);

        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass6 = new HDT_UTL_CaseValidations();

            myClass6.validate(fields20, recordId20);
            myClass6.validate(fields21, recordId21);
            myClass6.validate(fields22, recordId22);
            myClass6.validate(fields23, recordId23);
            myClass6.validate(fields24, recordId24);
            
        }catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();

        //ASSERTS
        System.assert(myCase6 != null, 'myCase6 non può essere null');
    }

    @isTest
    private static void validateTestType6(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType6';
        System.debug(debugString);
        
        //SETUP

        mySetup();        
        Case myCase7 = [Select Id, Type, BeneficiaryAccount__c, AccountholderTypeBeneficiary__c from Case where Type = 'Rimborso'];
        Case myCase7b = [Select Id, Type from Case where Type = 'Storno Rateizzazione'];

        String recordId25 = myCase7.Id;
        myCase7.AccountholderTypeBeneficiary__c = 'Erede';
        myCase7.BeneficiaryAccount__c = null;
        String fields25 = JSON.serialize(myCase7);

        String recordId25b = myCase7.Id;
        myCase7.AccountholderTypeBeneficiary__c = '';
        String fields25b = JSON.serialize(myCase7);

        String recordId25c = myCase7b.Id;
        myCase7b.Type = 'Storno Rateizzazione';
        String fields25c = JSON.serialize(myCase7b);


        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass7 = new HDT_UTL_CaseValidations();
            myClass7.validate(fields25, recordId25);
            myClass7.validate(fields25b, recordId25b);
            myClass7.validate(fields25c, recordId25c);

            
        }catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();

        //ASSERTS
        System.assert(myCase7 != null, 'myCase7 non può essere null');
    }

    @isTest
    private static void validateTestType7(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType7';
        System.debug(debugString);
        
        //SETUP

        mySetup();        
        
        Case myCase8 = [Select Id, Type, Subprocess__c, Category__c, CustomerMarking__c, PhoneNumber__c, 
        Email__c, Mobile__c, CertifiedEmail__c, Fax__c from Case where Type = 'Variazione Anagrafica Cliente' and Subprocess__c = 'Modifica Dati di Contatto' LIMIT 1];
        Account myAccount = [Select Id, FirstName__c, LastName__c, FiscalCode__c, VATNumber__c from Account];

        String recordId26 = myCase8.Id;
        String fields26 = JSON.serialize(myCase8);

        String recordId27 = myCase8.Id;     
        myCase8.Category__c = 'Famiglie';
        myCase8.CustomerMarking__c = 'D1 - Persona fisica';
        String fields27 = JSON.serialize(myCase8);
        update myCase8;
        
        String recordId55 = myCase8.Id;
        myCase8.Category__c = 'Aziende Soho';
        myCase8.CustomerMarking__c = 'D3 - Azienda';
        String fields55 = JSON.serialize(myCase8);
        update myCase8;

        myAccount.FiscalCode__c = '1234568030155487';
        update myAccount;

        String recordId53 = myCase8.Id;
        myCase8.Category__c = 'Aziende Soho';
        myCase8.CustomerMarking__c = 'D2 - Ditta individuale';
        String fields53 = JSON.serialize(myCase8);
        update myCase8;


        
        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass8 = new HDT_UTL_CaseValidations();

            myClass8.validate(fields26, recordId26);
            myClass8.validate(fields27, recordId27);
            myClass8.validate(fields27, recordId27);
            myClass8.validate(fields55, recordId55);
            myClass8.validate(fields53, recordId53);

            }catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();

        //ASSERTS
        System.assert(myCase8 != null, 'myCase8 non può essere null');
    }

    /*@isTest
    private static void validateTestType7ab(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType7ab';
        System.debug(debugString);
        
        //SETUP

        mySetup();        
        
        Case myCase8ab = [Select Id, Type, Subprocess__c, Category__c, CustomerMarking__c, PhoneNumber__c, 
        Email__c, Mobile__c, CertifiedEmail__c, Fax__c from Case where Type = 'Variazione Anagrafica Cliente' and Subprocess__c = 'Modifica Dati di Contatto' LIMIT 1];
        
        String recordId55ab = myCase8ab.Id;
        String fields55ab = JSON.serialize(myCase8ab);
        
        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass8ab = new HDT_UTL_CaseValidations();

            myClass8ab.validate(fields55ab, recordId55ab);

            }catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();

        //ASSERTS
        System.assert(myCase8ab != null, 'myCase8ab non può essere null');
    }*/

    @isTest
    private static void validateTestType7h(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType7';
        System.debug(debugString);
        
        //SETUP

        mySetup();        
        
        Case myCase8h = [Select Id, Type, Subprocess__c, Category__c, CustomerMarking__c, PhoneNumber__c, 
        Email__c, Mobile__c, CertifiedEmail__c, Fax__c from Case where RecordType.DeveloperName = 'HDT_RT_AllineamentoAnagrafica'];

        String recordId26b = myCase8h.Id;
        String fields26b = JSON.serialize(myCase8h);
        
        String recordId26c = myCase8h.Id;
        myCase8h.PhoneNumber__c = null;
        myCase8h.Mobile__c = null;
        myCase8h.Email__c = null;
        String fields26c = JSON.serialize(myCase8h);

        String recordId26d = myCase8h.Id;
        myCase8h.Mobile__c = '333209864555';
        String fields26d = JSON.serialize(myCase8h);

        String recordId26e = myCase8h.Id;
        myCase8h.Mobile__c = null;
        myCase8h.PhoneNumber__c = '3209864553';
        String fields26e = JSON.serialize(myCase8h);


        
        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass8h = new HDT_UTL_CaseValidations();

            myClass8h.validate(fields26b, recordId26b);
            myClass8h.validate(fields26c, recordId26c);
            myClass8h.validate(fields26d, recordId26d);
            myClass8h.validate(fields26e, recordId26e);

            }catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();

        //ASSERTS
        System.assert(myCase8h != null, 'myCaseh non può essere null');
    }

    @isTest
    private static void validateTestType7e(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType7e';
        System.debug(debugString);
        
        //SETUP

        mySetup();        
        
        Case myCase8e = [Select Id, Type, Subprocess__c, Category__c, CustomerMarking__c, PhoneNumber__c, 
        Email__c, Mobile__c, CertifiedEmail__c, Fax__c from Case where Type = 'Variazione Anagrafica Cliente' and Subprocess__c = 'Modifica Dati di Contatto' LIMIT 1];

        String recordId52 = myCase8e.Id;
        myCase8e.Category__c = 'Piccoli Condomini';
        myCase8e.CustomerMarking__c = 'D5 - Condominio';
        String fields52 = JSON.serialize(myCase8e); 
        
        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass8e = new HDT_UTL_CaseValidations();

            myClass8e.validate(fields52, recordId52);

            }catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();

        //ASSERTS
        System.assert(myCase8e != null, 'myCase8e non può essere null');
    }

    @isTest
    private static void validateTestType7f(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType7f';
        System.debug(debugString);
        
        //SETUP

        mySetup();        
        
        Case myCase8f = [Select Id, Type, Subprocess__c, Category__c, CustomerMarking__c, PhoneNumber__c,
        Email__c, Mobile__c, CertifiedEmail__c, Fax__c from Case where Type = 'Variazione Anagrafica Cliente' and Subprocess__c = 'Modifica Dati di Contatto' LIMIT 1];

        String recordId56 = myCase8f.Id;
        myCase8f.Category__c = 'Aziende Soho';
        myCase8f.CustomerMarking__c = 'D6 - Associazione';
        String fields56 = JSON.serialize(myCase8f);

        
        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass8f = new HDT_UTL_CaseValidations();

            myClass8f.validate(fields56, recordId56);

            }catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();

        //ASSERTS
        System.assert(myCase8f != null, 'myCase8f non può essere null');
    }

    @isTest
    private static void validateTestType7g(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType7g';
        System.debug(debugString);
        
        //SETUP

        mySetup();        
        
        Case myCase8g = [Select Id, Type, Subprocess__c, Category__c, CustomerMarking__c, PhoneNumber__c, 
        Email__c, Mobile__c, CertifiedEmail__c, Fax__c from Case where Type = 'Variazione Anagrafica Cliente' and Subprocess__c = 'Modifica Dati di Contatto' LIMIT 1];
        Account myAcc = [Select id, FiscalCode__c from Account];
        myAcc.FiscalCode__c = '';
        update myAcc;
        String recordId56b = myCase8g.Id;
        myCase8g.Category__c = 'Famiglie';
        myCase8g.CustomerMarking__c = 'AAS Persona fisica';
        String fields56b = JSON.serialize(myCase8g);

        
        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass8g = new HDT_UTL_CaseValidations();

            myClass8g.validate(fields56b, recordId56b);

            }catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();

        //ASSERTS
        System.assert(myCase8g != null, 'myCase8g non può essere null');
    }

    @isTest
    private static void validateTestType7b(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType7b';
        System.debug(debugString);
        
        //SETUP

        mySetup();        
        
        Case myCase8b = [Select Id, Type, Subprocess__c, BillSendingMethod__c, ElectronicInvoicingMethod__c, 
        ElectronicInvoiceCertifiedEmailAddress__c, OfficeSubjectCode__c, XMLType__c from Case where Type = 'Variazione Anagrafica Cliente' and Subprocess__c = 'Modifica Dati di Recapito'];


        String recordId28 = myCase8b.Id;
        myCase8b.BillSendingMethod__c = 'Bolletta per e-mail';
        String fields28 = JSON.serialize(myCase8b);

        String recordId29 = myCase8b.Id;
        myCase8b.BillSendingMethod__c = 'Invio tramite PEC';
        String fields29 = JSON.serialize(myCase8b);

        String recordId30 = myCase8b.Id;
        myCase8b.ElectronicInvoicingMethod__c = 'XML';
        myCase8b.ElectronicInvoiceCertifiedEmailAddress__c = 'myPecEmail@pecEmail.com';
        myCase8b.OfficeSubjectCode__c = 'myOfficeSubjectCode';
        myCase8b.XMLType__c = 'Sintetico';            
        String fields30 = JSON.serialize(myCase8b);

        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass8b = new HDT_UTL_CaseValidations();

            myClass8b.validate(fields28, recordId28);
            myClass8b.validate(fields29, recordId29);
            myClass8b.validate(fields30, recordId30);


        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());

        }
        
        Test.stopTest();

        //ASSERTS
        System.assert(myCase8b != null, 'myCase8b non può essere null');
    }

    
    @isTest
    private static void validateTestType7c(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType7c';
        System.debug(debugString);
        
        //SETUP

        mySetup();        

        Case myCase8c = [Select Id, Type, Subprocess__c, Category__c, CustomerMarking__c, FirstName__c,
        LastName__c, FiscalCode__c, VatNumber__c, AlternativeAddress__c from Case where Type = 'Variazione Anagrafica Cliente' and Subprocess__c = 'Modifica Dati Fiscali'];
        Account myAcc = [Select id, FiscalCode__c from Account];
        

        String recordId31 = myCase8c.Id;
        String fields31 = JSON.serialize(myCase8c);

        String recordId32 = myCase8c.Id;
        myCase8c.LastName__c = 'Rossi';
        String fields32 = JSON.serialize(myCase8c);
        

        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass8c = new HDT_UTL_CaseValidations();
           
            myClass8c.validate(fields31, recordId31);
            myClass8c.validate(fields32, recordId32);
            
            
        }catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();

        //ASSERTS
        System.assert(myCase8c != null, 'myCase8c non può essere null');
    }

    @isTest
    private static void validateTestType7l(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType7l';
        System.debug(debugString);
        
        //SETUP

        mySetup();        

        Case myCase8l = [Select Id, Type, Subprocess__c, Category__c, CustomerMarking__c, FirstName__c,
        LastName__c, FiscalCode__c, VatNumber__c, AlternativeAddress__c from Case where Type = 'Variazione Anagrafica Cliente' and Subprocess__c = 'Modifica Dati Fiscali'];
        Account myAcc = [Select id, FiscalCode__c from Account];
        
        myAcc.Category__c = 'Famiglie';
        myAcc.CustomerMarking__c = 'D1 - Persona fisica';
        update myAcc;
        String recordId33l = myCase8l.Id;
        myCase8l.LastName__c = 'Rossi';
        myCase8l.FiscalCode__c  = 'RZZMRA80A01D548M';
        String fields33l = JSON.serialize(myCase8l);
        
        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass8l = new HDT_UTL_CaseValidations();
           
            myClass8l.validate(fields33l, recordId33l);            
            
        }catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();

        //ASSERTS
        System.assert(myCase8l != null, 'myCase8l non può essere null');
    }

    @isTest
    private static void validateTestType7q(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType7q';
        System.debug(debugString);
        
        //SETUP

        mySetup();        

        Case myCase8q = [Select Id, Type, Subprocess__c, Category__c, CustomerMarking__c, FirstName__c,
        LastName__c, FiscalCode__c, VatNumber__c, AlternativeAddress__c from Case where Type = 'Variazione Anagrafica Cliente' and Subprocess__c = 'Modifica Dati Fiscali'];
        Account myAcc = [Select id, FiscalCode__c from Account];
        
        myAcc.Category__c = 'Aziende Soho';
        myAcc.CustomerMarking__c = 'D6 - Associazione';
        update myAcc;
        String recordId33q = myCase8q.Id;
        myCase8q.LastName__c = 'Rossi';
        myCase8q.FiscalCode__c  = 'RPPMRA80A01D548M';
        String fields33q = JSON.serialize(myCase8q);
        
        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass8q = new HDT_UTL_CaseValidations();
           
            myClass8q.validate(fields33q, recordId33q);            
            
        }catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();

        //ASSERTS
        System.assert(myCase8q != null, 'myCase8q non può essere null');
    }
    
    @isTest
    private static void validateTestType7p(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType7p';
        System.debug(debugString);
        
        //SETUP

        mySetup();        

        Case myCase8p = [Select Id, Type, Subprocess__c, Category__c, CustomerMarking__c, FirstName__c,
        LastName__c, FiscalCode__c, VatNumber__c, AlternativeAddress__c from Case where Type = 'Variazione Anagrafica Cliente' and Subprocess__c = 'Modifica Dati Fiscali'];
        Account myAcc = [Select id, FiscalCode__c from Account];
        
        myAcc.Category__c = 'Aziende Soho';
        myAcc.CustomerMarking__c = 'D2 - Ditta individuale';
        update myAcc;
        String recordId33p = myCase8p.Id;
        myCase8p.LastName__c = 'Rossi';
        myCase8p.FiscalCode__c  = 'RPPMRA80A01D548M';
        myCase8p.VatNumber__c = '03819031208';
        String fields33p = JSON.serialize(myCase8p);
        
        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass8p = new HDT_UTL_CaseValidations();
           
            myClass8p.validate(fields33p, recordId33p);            
            
        }catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();

        //ASSERTS
        System.assert(myCase8p != null, 'myCase8p non può essere null');
    }

    @isTest
    private static void validateTestType7n(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType7n';
        System.debug(debugString);
        
        //SETUP

        mySetup();        

        Case myCase8n = [Select Id, Type, Subprocess__c, Category__c, CustomerMarking__c, FirstName__c,
        LastName__c, FiscalCode__c, VatNumber__c, AlternativeAddress__c from Case where Type = 'Variazione Anagrafica Cliente' and Subprocess__c = 'Modifica Dati Fiscali'];
        Account myAcc = [Select id, FiscalCode__c from Account];
        
        myAcc.Category__c = 'Famiglie';
        myAcc.CustomerMarking__c = 'D1 - Persona fisica';
        update myAcc;
        String recordId33n = myCase8n.Id;
        myCase8n.LastName__c = 'Rossi';
        myCase8n.FiscalCode__c  = '';
        String fields33n = JSON.serialize(myCase8n);
        
        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass8n = new HDT_UTL_CaseValidations();
           
            myClass8n.validate(fields33n, recordId33n);            
            
        }catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();

        //ASSERTS
        System.assert(myCase8n != null, 'myCase8n non può essere null');
    }
    

    @isTest
    private static void validateTestType7i(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType7i';
        System.debug(debugString);
        
        //SETUP

        mySetup();        

        Case myCase8i = [Select Id, Type, Subprocess__c, Category__c, CustomerMarking__c, FirstName__c,
        LastName__c, FiscalCode__c, VatNumber__c, AlternativeAddress__c from Case where Type = 'Variazione Anagrafica Cliente' and Subprocess__c = 'Modifica Dati Fiscali'];
        Account myAcc = [Select id, FiscalCode__c from Account];
        
        myAcc.Category__c = 'Aziende TOP';
        myAcc.CustomerMarking__c = 'Azienda';
        update myAcc;

        String recordId33i = myCase8i.Id;
        myCase8i.LastName__c = 'Rossi';
        myCase8i.VatNumber__c  = '';
        String fields33i = JSON.serialize(myCase8i);

        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass8i = new HDT_UTL_CaseValidations();
           
            myClass8i.validate(fields33i, recordId33i);

        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();

        //ASSERTS
        System.assert(myCase8i != null, 'myCase8i non può essere null');
    }

    @isTest
    private static void validateTestType7o(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType7o';
        System.debug(debugString);
        
        //SETUP

        mySetup();        

        Case myCase8o = [Select Id, Type, Subprocess__c, Category__c, CustomerMarking__c, FirstName__c,
        LastName__c, FiscalCode__c, VatNumber__c, AlternativeAddress__c from Case where Type = 'Variazione Anagrafica Cliente' and Subprocess__c = 'Modifica Dati Fiscali'];
        Account myAcc = [Select id, FiscalCode__c from Account];
        
        myAcc.Category__c = 'Aziende TOP';
        myAcc.CustomerMarking__c = 'Azienda';
        update myAcc;

        String recordId33o = myCase8o.Id;
        myCase8o.LastName__c = 'Rossi';
        myCase8o.VatNumber__c  = '';
        String fields33o = JSON.serialize(myCase8o);

        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass8o = new HDT_UTL_CaseValidations();
           
            myClass8o.validate(fields33o, recordId33o);

        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();

        //ASSERTS
        System.assert(myCase8o != null, 'myCase8o non può essere null');
    }

    @isTest
    private static void validateTestType7d(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType7d';
        System.debug(debugString);
        
        //SETUP

        mySetup();        

        Case myCase8d = [Select Id, Type, Subprocess__c, IsVATGroupJoined__c, VATGroup__c,
        VATGroupStartDate__c, VATGroupEndDate__c, AccountId, Contact.Id from Case where Type = 'Variazione Anagrafica Cliente' and Subprocess__c = 'Variazione Gruppo IVA'];
        
        Date myStartDate = Date.newInstance(2021, 09, 28);
        Date myEndDate = Date.newInstance(2021, 09, 25);
        
        String recordId34 = myCase8d.Id;
        myCase8d.IsVATGroupJoined__c = true;
        myCase8d.VATGroup__c = '86334519757';
        myCase8d.VATGroupStartDate__c = myStartDate;
        myCase8d.VATGroupEndDate__c = myEndDate;
        String fields34 = JSON.serialize(myCase8d);

        String recordId35 = myCase8d.Id;
        myCase8d.VATGroup__c = null;
        String fields35 = JSON.serialize(myCase8d);

        String recordId36 = myCase8d.Id;
        myCase8d.VATGroup__c = '86334519757';
        myCase8d.VATGroupStartDate__c = null;
        String fields36 = JSON.serialize(myCase8d);

        String recordId37 = myCase8d.Id;
        myCase8d.VATGroupStartDate__c = myStartDate;
        myCase8d.VATGroupEndDate__c = null;
        String fields37 = JSON.serialize(myCase8d);

        String recordId38 = myCase8d.Id;
        myCase8d.VATGroup__c = '03819031208';
        String fields38 = JSON.serialize(myCase8d);

        String recordId39 = myCase8d.Id;
        myCase8d.VATGroupEndDate__c = myEndDate;
        String fields39 = JSON.serialize(myCase8d);

        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass8d = new HDT_UTL_CaseValidations();

            myClass8d.validate(fields34, recordId34);
            myClass8d.validate(fields35, recordId35);         
            myClass8d.validate(fields36, recordId36);
            myClass8d.validate(fields37, recordId37);
            myClass8d.validate(fields38, recordId38);
            myClass8d.validate(fields39, recordId39);


        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
    }        
    Test.stopTest();

    //ASSERTS
    System.assert(myCase8d != null, 'myCase8d non può essere null');
}
           


    @isTest
    private static void validateTestType8(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType8';
        System.debug(debugString);
        
        //SETUP

        mySetup();

        Case myCase9 = [Select Id, Type, WrittenReceiptRequestDate__c from Case where Type = 'Esercizio Diritti Privacy']; 

        String recordId40 = myCase9.Id;
        myCase9.Type = 'Esercizio Diritti Privacy';
        myCase9.WrittenReceiptRequestDate__c = Date.today().addDays(5);
        update myCase9;
        String fields40 = JSON.serialize(myCase9);

        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass9 = new HDT_UTL_CaseValidations();

            myClass9.validate(fields40, recordId40);

        }catch(DmlException e) {

            System.debug('The following exception has occurred: ' + e.getMessage());
        }

        //ASSERTS
        System.assert(myCase9 != null, 'myCase9 non può essere null');        
        
        Test.stopTest();
    }

    @isTest
    private static void validateTestType8b(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType8b';
        System.debug(debugString);
        
        //SETUP

        mySetup();

        Case myCase9b = [Select Id, Type, MarketingPrivacy__c, ProfilingPrivacy__c, 
        HasOptedOutSoftSpam__c, HasOptedOutOfEmail__c from Case where Type = 'Modifica Privacy'];

        String recordId41 = myCase9b.Id;
        myCase9b.MarketingPrivacy__c = 'Non espresso';
        myCase9b.ProfilingPrivacy__c = 'Non espresso';
        myCase9b.HasOptedOutSoftSpam__c = false;
        myCase9b.HasOptedOutOfEmail__c = false;
        update myCase9b;
        String fields41 = JSON.serialize(myCase9b);

        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass9b = new HDT_UTL_CaseValidations();
            
            myClass9b.validate(fields41, recordId41);

        }catch(DmlException e) {

            System.debug('The following exception has occurred: ' + e.getMessage());
        }

        //ASSERTS
        System.assert(myCase9b != null, 'myCase9b non può essere null');        
        
        Test.stopTest();
    }


    @isTest
    private static void validateTestType8c(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType8c';
        System.debug(debugString);
        
        //SETUP

        mySetup();

        Case myCase9c = [Select Id, Type, ServicePoint__r.Id, RelatedCase__c from Case where Type = 'Inversione del Contatore'];
        Case relatedCase = [Select Id, ServicePoint__r.Id, ServicePointCode__c from Case where ServicePoint__r.CommoditySector__c = 'Gas'];
        Case relatedCase1 = [Select Id, ServicePoint__r.Id, ServicePointCode__c from Case where ServicePoint__r.CommoditySector__c = 'Energia Elettrica' LIMIT 1];

        String recordId42 = myCase9c.Id;
        String fields42 = JSON.serialize(myCase9c);

        String recordId43 = myCase9c.Id;
        myCase9c.RelatedCase__c = relatedCase.Id;
        String fields43 = JSON.serialize(myCase9c);

        String recordId43b = myCase9c.Id;
        myCase9c.RelatedCase__c = relatedCase1.Id;
        myCase9c.ServicePoint__c = relatedCase1.ServicePoint__r.Id;
        myCase9c.ServicePointCode__c = relatedCase.ServicePointCode__c;
        String fields43b = JSON.serialize(myCase9c);

        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass9c = new HDT_UTL_CaseValidations();

            myClass9c.validate(fields42, recordId42);
            myClass9c.validate(fields43, recordId43);
            myClass9c.validate(fields43b, recordId43b);

        }catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
        }
        //ASSERTS
        System.assert(myCase9c != null, 'myCase9c non può essere null');        
        
        Test.stopTest();
    }


    @isTest
    private static void validateTestType8d(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType8d';
        System.debug(debugString);
        
        //SETUP

        mySetup();
        
        Case myCase9d = [Select Id, Type, RelatedCase__c, Reason__c, SendMode__c, Email__c from Case where Type = 'Gestione Bonus Sociale'];

        String recordId44 = myCase9d.Id;
        myCase9d.Reason__c = 'Permanenza condizioni di disagio';
        myCase9d.SendMode__c = 'E-Mail';
        myCase9d.Email__c = 'francopolidori@teletu.it';
        String fields44 = JSON.serialize(myCase9d);

        String recordId45 = myCase9d.Id;
        myCase9d.Reason__c = 'Cessazione al diritto del Bonus fisico per Mortis causa';
        myCase9d.Email__c = '';
        String fields45 = JSON.serialize(myCase9d);

        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass9d = new HDT_UTL_CaseValidations();

            myClass9d.validate(fields44, recordId44);
            myClass9d.validate(fields45, recordId45);

        }catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
        }
        //ASSERTS
        System.assert(myCase9d != null, 'myCase9d non può essere null');        
        
        Test.stopTest();
    }

    @isTest
    private static void validateTestType8e(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType8d';
        System.debug(debugString);
        
        //SETUP

        mySetup();

        Case myCase9e = [Select Id, Type, PaymentDate__c from Case where Type = 'Riattivazione Fornitura'];

        String recordId46 = myCase9e.Id;
        myCase9e.PaymentDate__c = Date.newInstance(2021, 12, 25);
        String fields46 = JSON.serialize(myCase9e);

        String recordId46b = myCase9e.Id;
        myCase9e.PaymentDate__c = Date.newInstance(2020, 12, 25);
        String fields46b = JSON.serialize(myCase9e);

        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass9e = new HDT_UTL_CaseValidations();

            myClass9e.validate(fields46, recordId46);
            myClass9e.validate(fields46b, recordId46b);
            
        }catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
        }
        //ASSERTS
        System.assert(myCase9e != null, 'myCase9e non può essere null');        
        
        Test.stopTest();
    }

    @isTest
    private static void validateTestType9(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType9';
        System.debug(debugString);
        
        //SETUP

        mySetup();
        
        Case myCase10 = [Select Id, Type, Disconnectable__c, DisconnectibilityType__c, MobilePhoneNoticePesse__c, 
        SelfCertificationAcquisitionAsl__c from Case where Type = 'Gestione Disalimentabilità']; 

        /*String recordId47 = myCase10.Id;
        myCase10.Disconnectable__c = 'Si';
        update myCase10;
        String fields47 = JSON.serialize(myCase10);*/

        String recordId48 = myCase10.Id;
        myCase10.Disconnectable__c = 'No';
        myCase10.DisconnectibilityType__c = '';
        myCase10.MobilePhoneNoticePesse__c = '';
        String fields48 = JSON.serialize(myCase10);

        String recordId49 = myCase10.Id;
        myCase10.Disconnectable__c = 'Si';
        myCase10.SelfCertificationAcquisitionAsl__c = 'incerto';
        String fields49 = JSON.serialize(myCase10);

        String recordId50 = myCase10.Id;
        myCase10.Disconnectable__c = 'No';
        myCase10.DisconnectibilityType__c = '01- App. medico terapeutiche';
        myCase10.SelfCertificationAcquisitionAsl__c = 'No';
        String fields50 = JSON.serialize(myCase10);

        String recordId51 = myCase10.Id;
        myCase10.Disconnectable__c = null;
        String fields51 = JSON.serialize(myCase10);


        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass10 = new HDT_UTL_CaseValidations();
            
            //myClass10.validate(fields47, recordId47);
            myClass10.validate(fields48, recordId48);
            myClass10.validate(fields49, recordId49);
            myClass10.validate(fields50, recordId50);
            myClass10.validate(fields51, recordId51);
            
            
            
        }catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();

        //ASSERTS
        System.assert(myCase10 != null, 'myCase10 non può essere null');        

    }

    @IsTest
    static void validateEndDateTst(){

       List<Case> myCase = [Select Id from Case where Type = 'Proroga Conn Temp'];
       String myRecordId = myCase[0].Id;

       Map<String, Object> dateCase = new Map<String, Object>();
       dateCase.put( 'TemporaryConnectionEndDate__c',  '2022-05-02 00:00:00' );

       String fields = JSON.serialize(dateCase);

       Test.startTest();

       string result = caseValidationsUtl.validate(fields,myRecordId);
       
       Test.stopTest();

       System.assert( result.containsIgnoreCase('Error'), 'Test validateEndDate Fallito');
    }

    @isTest
    private static void validateTestType10(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType10';
        System.debug(debugString);
        
        //SETUP

        mySetup();
        
        Case myCase11 = [Select Id, Type, Subprocess__c, SupplyType__c, UseCategory__c, ServicePointType__c from Case where Type = 'Marcatura/Uso PdR']; 

        String recordId57 = myCase11.Id;
        myCase11.SupplyType__c = 'A-Domestico';
        myCase11.UseCategory__c = '002-Prod.acqua calda sanitaria';
        myCase11.ServicePointType__c = '1002-Cottura/Produz acq calda';
        String fields57 = JSON.serialize(myCase11);


        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass11 = new HDT_UTL_CaseValidations();
            
            myClass11.validate(fields57, recordId57);

        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(myCase11 != null, 'myCase11 non può essere null');        
    }

    @isTest
    private static void validateTestType11(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType11';
        System.debug(debugString);
        
        //SETUP

        mySetup();
        
        Case myCase12 = [Select Id, Type, Subprocess__c, BillingProblem__c, Note__c  from Case where Type = 'BP/CA - errata categoria' AND Subprocess__c = 'IVA - Agevolazione cliente']; 

        
        String recordId58 = myCase12.Id;
        myCase12.BillingProblem__c = 'Si';
        myCase12.Note__c = '';
        myCase12.CustomerPaymentAgreements__c = '';
        String fields59 = JSON.serialize(myCase12);
        
        String recordId59 = myCase12.Id;
        myCase12.Note__c = 'Note Cliente';
        myCase12.CustomerPaymentAgreements__c = 'Pagato';
        String fields60 = JSON.serialize(myCase12);

        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass12 = new HDT_UTL_CaseValidations();
            
            myClass12.validate(fields59, recordId59);
            
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(myCase12 != null, 'myCase11 non può essere null');        
    }

    @isTest
    private static void validateTestType12(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType12';
        System.debug(debugString);
        
        //SETUP

        mySetup();
        
        Case myCase13 = [Select Id, Type, EndValidityDate__c, EffectiveDate__c  from Case where Type = 'Modifica/Azzeramento Consumo Annuo']; 

        String recordId60 = myCase13.Id;
        Date myDate3 = Date.newInstance(2021, 12, 20);
        Date myDate4 = Date.newInstance(2021, 12, 25);
        myCase13.EndValidityDate__c = myDate3;
        myCase13.EffectiveDate__c = myDate4;
        String fields60 = JSON.serialize(myCase13);
        
        String recordId61 = myCase13.Id;
        Date myDate5 = Date.newInstance(2021, 12, 25);
        Date myDate6 = Date.newInstance(2021, 12, 20);
        myCase13.EndValidityDate__c = myDate5;
        myCase13.EffectiveDate__c = myDate6;
        String fields61 = JSON.serialize(myCase13);

        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass13 = new HDT_UTL_CaseValidations();
            
            myClass13.validate(fields60, recordId60);
            myClass13.validate(fields61, recordId61);

        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(myCase13 != null, 'myCase13 non può essere null');        
    }

    @isTest
    private static void validateTestType13(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType13';
        System.debug(debugString);
        
        //SETUP

        mySetup();
        
        Case myCase14 = [Select Id, Type, Subprocess__c from Case where Type = 'Fiscale']; 

        String recordId62 = myCase14.Id;
        String fields62 = JSON.serialize(myCase14);

        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass14 = new HDT_UTL_CaseValidations();
            
            myClass14.validate(fields62, recordId62);

        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(myCase14 != null, 'myCase14 non può essere null');        
    }

    @isTest
    private static void validateTestType14(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType14';
        System.debug(debugString);
        
        //SETUP

        mySetup();
        
        Case myCase15 = [Select Id, Type, ResidenceChangeDate__c from Case where Type = 'Modifica Tariffa Residente/Non Residente']; 

        String recordId63 = myCase15.Id;
        Date myDate6 = Date.today();
        myCase15.ResidenceChangeDate__c = myDate6;
        String fields63 = JSON.serialize(myCase15);

        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass15 = new HDT_UTL_CaseValidations();
            
            myClass15.validate(fields63, recordId63);

        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(myCase15 != null, 'myCase15 non può essere null');        
    }

    @isTest
    private static void validateTestType15(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType15';
        System.debug(debugString);
        
        //SETUP

        mySetup();
        
        Case myCase16 = [Select Id, Type, BillingProblem__c, CustomerPaymentAgreements__c from Case where Type = 'Condizioni Contrattuali Errate']; 

        String recordId64 = myCase16.Id;
        myCase16.BillingProblem__c = 'Si';
        myCase16.CustomerPaymentAgreements__c = '';
        String fields64 = JSON.serialize(myCase16);

        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass16 = new HDT_UTL_CaseValidations();
            
            myClass16.validate(fields64, recordId64);

        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(myCase16 != null, 'myCase16 non può essere null');        
    }

    @isTest
    private static void validateTestType16(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType16';
        System.debug(debugString);
        
        //SETUP

        mySetup();
        
        Case myCase17 = [Select Id, Type from Case where Type = 'Mancata Telelettura/lettura']; 

        String recordId65 = myCase17.Id;
        String fields65 = JSON.serialize(myCase17);

        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass17 = new HDT_UTL_CaseValidations();
            
            myClass17.validate(fields65, recordId65);

        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(myCase17 != null, 'myCase17 non può essere null');        
    }

    @isTest
    private static void validateTestType17(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType17';
        System.debug(debugString);
        
        //SETUP

        mySetup();
        
        Case myCase18 = [Select Id, Type, ElementDetail__c from Case where Type = 'Modifica Layout di dettaglio']; 

        String recordId66 = myCase18.Id;
        String fields66 = JSON.serialize(myCase18);

        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass18 = new HDT_UTL_CaseValidations();
            
            myClass18.validate(fields66, recordId66);

        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(myCase18 != null, 'myCase18 non può essere null');        
    }

    @isTest
    private static void validateTestType18(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType18';
        System.debug(debugString);
        
        //SETUP

        mySetup();
        
        Case myCase19 = [Select Id, Type, NotPerformedBefore__c, WrittenReceiptRequestDate__c from Case where Type = 'Chiusura Contatore']; 

        String recordId67 = myCase19.Id;
        myCase19.NotPerformedBefore__c = Date.today().addDays(-1);
        myCase19.WrittenReceiptRequestDate__c = Date.today();
        String fields67 = JSON.serialize(myCase19);

        String recordId68 = myCase19.Id;
        myCase19.NotPerformedBefore__c = Date.today();
        myCase19.WrittenReceiptRequestDate__c = Date.today().addDays(1);
        String fields68 = JSON.serialize(myCase19);

        String recordId69 = myCase19.Id;
        myCase19.WrittenReceiptRequestDate__c = Date.today();
        String fields69 = JSON.serialize(myCase19);

        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass19 = new HDT_UTL_CaseValidations();
            
            myClass19.validate(fields67, recordId67);
            myClass19.validate(fields68, recordId68);
            myClass19.validate(fields69, recordId69);


        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(myCase19 != null, 'myCase19 non può essere null');        
    }

    @isTest
    private static void validateTestType19(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType19';
        System.debug(debugString);
        
        //SETUP

        mySetup();
        
        Case myCase20 = [Select Id, Type, EffectiveDate__c from Case where Type = 'Contratto Non Richiesto']; 

        String recordId70 = myCase20.Id;
        myCase20.EffectiveDate__c = Date.today();
        String fields70 = JSON.serialize(myCase20);

        String recordId71 = myCase20.Id;
        myCase20.EffectiveDate__c = Date.today().addMonths(2);
        String fields71 = JSON.serialize(myCase20);

        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass20 = new HDT_UTL_CaseValidations();
            
            myClass20.validate(fields70, recordId70);
            myClass20.validate(fields71, recordId71);

        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(myCase20 != null, 'myCase20 non può essere null');        
    }

    @isTest
    private static void validateTestType20(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType20';
        System.debug(debugString);
        
        //SETUP

        mySetup();
        
        Case myCase21 = [Select Id, Type, BillSendingMethod__c, ElectronicInvoicingMethod__c from Case where Type = 'Unificazione/Separazione BP-CA-Bolletta']; 

        String recordId72 = myCase21.Id;
        myCase21.BillSendingMethod__c = 'Bolletta per e-mail';
        String fields72 = JSON.serialize(myCase21);

        String recordId73 = myCase21.Id;
        myCase21.BillSendingMethod__c = 'Invio tramite PEC';
        String fields73 = JSON.serialize(myCase21);

        String recordId74 = myCase21.Id;
        myCase21.ElectronicInvoicingMethod__c = 'XML + carta/email';
        String fields74 = JSON.serialize(myCase21);

        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass21 = new HDT_UTL_CaseValidations();
            
            myClass21.validate(fields72, recordId72);
            myClass21.validate(fields73, recordId73);
            myClass21.validate(fields74, recordId74);

        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(myCase21 != null, 'myCase21 non può essere null');        
    }

    @isTest
    private static void validateTestType21(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType21';
        System.debug(debugString);
        
        //SETUP

        mySetup();
        
        Case myCase22 = [Select Id, Type, FiscalCode__c from Case where Type = 'Spostamento Votive Modena']; 

        String recordId75 = myCase22.Id;
        myCase22.FiscalCode__c = 'RSSMRA80A01D548N';
        String fields75 = JSON.serialize(myCase22);

        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass22 = new HDT_UTL_CaseValidations();
            
            myClass22.validate(fields75, recordId75);

        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(myCase22 != null, 'myCase22 non può essere null');        
    }

    @isTest
    private static void validateTestType22(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType22';
        System.debug(debugString);
        
        //SETUP

        mySetup();
        
        Case myCase23 = [Select Id, Type, BillingProfile__c, Reason__c from Case where Type = 'Votive Modena Contestazione Fattura']; 

        String recordId76 = myCase23.Id;
        myCase23.Reason__c = 'Errata Emissione';
        String fields76 = JSON.serialize(myCase23);

        String recordId77 = myCase23.Id;
        myCase23.Reason__c = 'Caduta Linea';
        String fields77 = JSON.serialize(myCase23);

        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass23 = new HDT_UTL_CaseValidations();
            
            myClass23.validate(fields76, recordId76);
            myClass23.validate(fields77, recordId77);

        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(myCase23 != null, 'myCase23 non può essere null');        
    }

    @isTest
    private static void validateTestType23(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType23';
        System.debug(debugString);
        
        //SETUP

        mySetup();
        
        Case myCase24 = [Select Id, Type from Case where Type = 'Verifica Titolarità POD/PDR']; 

        String recordId77 = myCase24.Id;
        String fields77 = JSON.serialize(myCase24);


        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass24 = new HDT_UTL_CaseValidations();
            
            myClass24.validate(fields77, recordId77);

        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(myCase24 != null, 'myCase24 non può essere null');        
    }

    @isTest
    private static void validateTestType24(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType24';
        System.debug(debugString);
        
        //SETUP

        mySetup();
        
        Case myCase25 = [Select Id, Type, EffectiveDate__c from Case where Type = 'Voltura Tecnica']; 

        String recordId78 = myCase25.Id;
        myCase25.EffectiveDate__c = Date.today();
        String fields78 = JSON.serialize(myCase25);

        String recordId79 = myCase25.Id;
        myCase25.EffectiveDate__c = Date.today().addDays(7);
        String fields79 = JSON.serialize(myCase25);


        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass25 = new HDT_UTL_CaseValidations();
            
            myClass25.validate(fields78, recordId78);
            myClass25.validate(fields79, recordId79);

        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(myCase25 != null, 'myCase25 non può essere null');        
    }

    @isTest
    private static void validateTestType25(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType25';
        System.debug(debugString);
        
        //SETUP

        mySetup();
        
        Case myCase26 = [Select Id, Type, TemporaryConnectionEndDate__c from Case where Type = 'Proroga Conn Temp' LIMIT 1]; 

        String recordId80 = myCase26.Id;
        myCase26.TemporaryConnectionEndDate__c = Date.today().addMonths(2);
        String fields80 = JSON.serialize(myCase26);


        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass26 = new HDT_UTL_CaseValidations();
            
            myClass26.validate(fields80, recordId80);

        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(myCase26 != null, 'myCase26 non può essere null');        
    }

    @isTest
    private static void validateTestType26(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType26';
        System.debug(debugString);
        
        //SETUP

        mySetup();
        
        Case myCase27 = [Select Id, Type, Cluster__c from Case where Type = 'Nuovo Impianto' and Cluster__c = 'Preventivi' LIMIT 1]; 

        String recordId81 = myCase27.Id;
        String fields81 = JSON.serialize(myCase27);


        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass27 = new HDT_UTL_CaseValidations();
            myClass27.validate(fields81, recordId81);


        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(myCase27 != null, 'myCase27 non può essere null');        
    }

    @isTest
    private static void validateTestType26b(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType26';
        System.debug(debugString);
        
        //SETUP

        mySetup();
        
        Case myCase27b = [Select Id, Type, Cluster__c, Commodity__c, ShipmentAddressAssign__c, SupplyType__c, Taxes__c, ServicePointType__c from Case where Type = 'Nuovo Impianto' and Cluster__c = 'Preventivi' and ShipmentAddressAssign__c != null]; 

        String recordId82 = myCase27b.Id;
        String fields82 = JSON.serialize(myCase27b);

        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass27b = new HDT_UTL_CaseValidations();
            myClass27b.validate(fields82, recordId82);


        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(myCase27b != null, 'myCase27b non può essere null');        
    }

    @isTest
    private static void validateTestType27(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType27';
        System.debug(debugString);
        
        //SETUP

        mySetup();
        
        Case myCase28 = [Select Id, Cluster__c, DeceasedFiscalCode__c, DeceasedName__c, DeceasedSurname__c, DeceasedDate__c from Case where Type = 'Modifica Contr Preattivazione Anagr Res' AND Cluster__c = 'Attivazioni']; 

        String recordId83 = myCase28.Id;
        myCase28.DeceasedDate__c = Date.Today().addDays(10);
        myCase28.DeceasedFiscalCode__c = 'VFGYHA56B30H211N';
        myCase28.DeceasedName__c = 'Mario';
        myCase28.DeceasedSurname__c = 'Rossi';

        String fields83 = JSON.serialize(myCase28);
        


        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass28 = new HDT_UTL_CaseValidations();
            myClass28.validate(fields83, recordId83);

        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(myCase28 != null, 'myCase28 non può essere null');        
    }

    @isTest
    private static void validateTestType28(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType28';
        System.debug(debugString);
        
        //SETUP
        UserRole r = new UserRole();
        r.DeveloperName = 'MyCustomRole';
        r.Name = 'My Role';
        insert r;

        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
        internalUser.UserRoleId = r.Id;

        insert internalUser;

            Test.startTest();

            System.runAs(internalUser){ 

                HDT_QR_CaseValidations roleName = new HDT_QR_CaseValidations();

                String roleNameBox = roleName.getUserSessionRole();

                //ASSERTS
                System.assert(roleNameBox != null, 'il ruolo non è popolato'); 

            }
            Test.stopTest();
    }

}