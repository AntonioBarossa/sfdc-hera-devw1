/*
    @Author:        Francesco Vitiello
    CreatedDate:    11/10/2021
*/

@isTest
public with sharing class HDT_UTL_CaseValidationsTst {

    
    //DEBUG
    public static final String TEST_NAME = 'HDT_UTL_CaseValidationsTst';
    
    
    //TEST SETUP
    private static void mySetup(){

        HDT_UTL_DataFactoryTst.pClickCasePhase();        

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
        accList[0].BillingCity = 'Ancona';
        accList[0].BillingState = 'IT';
        accList[0].BillingPostalCode = '60121';
        accList[0].BillingCountry = 'ITALIA';
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
        contactList[0].Fax = 'myFax';
        update contactList;

        //Contract
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);

        //Case
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(19, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        CaseList[0].Type = 'Richiesta Parere';
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
        caseList[9].AlternativeAddress__c = 'Via Guglielmo Marconi, 15, , Ancona, IT, 60121, ITALIA';
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
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
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
        myCase1.SendDate__c = Date.newInstance(2025, 10, 10);
        String fields8 = JSON.serialize(myCase1);

        String recordId9 = myCase1.Id;
        myCase1.ComplaintType__c = 'Reclamo Scritto';
        myCase1.FirstLevelComplaintClassification__c = 'Reclamo Scritto';
        myCase1.SecondLevelComplaintClassification__c = 'Mercato';
        myCase1.ThirdLevelComplaintClassification__c = 'Presunti Contratti non Richiesti';
        myCase1.FithLevelComplaintClassification__c = 'Firma falsa';
        String fields9 = JSON.serialize(myCase1);

        /*String recordId10 = myCase1.Id;
        myCase1.SendDate__c = Date.newInstance(2015, 10, 10);
        myCase1.OpinionRequest__c = 'Prova parere';
        String fields10 = JSON.serialize(myCase1);

        String recordId10b = myCase1.Id;
        myCase1.SendDate__c = Date.newInstance(2015, 10, 10);
        myCase1.OpinionRequest__c = '';
        String fields10b = JSON.serialize(myCase1);*/

        //TESTING
        Test.startTest();

        Try{

            HDT_UTL_CaseValidations myClass1 = new HDT_UTL_CaseValidations();

            myClass1.validate(fields1, recordId1);
            myClass1.validate(fields7, recordId7);
            myClass1.validate(fields8, recordId8);
            myClass1.validate(fields9, recordId9);
            //myClass1.validate(fields10, recordId10);
            //myClass1.validate(fields10b, recordId10b);

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
        Email__c, Mobile__c, CertifiedEmail__c, Fax__c from Case where Type = 'Variazione Anagrafica Cliente' and Subprocess__c = 'Modifica Dati di Contatto'];
        Account myAccount = [Select Id, FirstName__c, LastName__c, FiscalCode__c, VATNumber__c from Account];
        Contact myContact = [Select Id, Email, MobilePhone, Phone, CertifiedEmail__c, Fax from Contact];

        String recordId26 = myCase8.Id;
        String fields26 = JSON.serialize(myCase8);

        String recordId27 = myCase8.Id;     
        myCase8.Category__c = 'Famiglie';
        myCase8.CustomerMarking__c = 'D1 - Persona fisica';
        String fields27 = JSON.serialize(myCase8);
        update myCase8;

        /*myAccount.FiscalCode__c = null;
        update myAccount;
        String recordId52 = myCase8.Id;
        myCase8.Category__c = 'Piccoli Condomini';
        myCase8.CustomerMarking__c = 'D5 - Condominio';
        String fields52 = JSON.serialize(myCase8);
        update myCase8;*/
        
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

        /*myAccount.FiscalCode__c = null;
        update myAccount;
        String recordId54 = myCase8.Id;
        myCase8.Category__c = 'Piccoli Condomini';
        myCase8.CustomerMarking__c = 'D4 - Parti Comuni';
        String fields54 = JSON.serialize(myCase8);
        update myCase8;*/
        
        /*String recordId56 = myCase8.Id;
        myCase8.Category__c = 'Aziende Soho';
        myCase8.CustomerMarking__c = 'D6 - Associazione';
        String fields56 = JSON.serialize(myCase8);
        update myCase8;*/        

        
        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass8 = new HDT_UTL_CaseValidations();

            myClass8.validate(fields26, recordId26);
            myClass8.validate(fields27, recordId27);
            //myClass8.validate(fields52, recordId52);
            myClass8.validate(fields55, recordId55);
            myClass8.validate(fields53, recordId53);
            //myClass8.validate(fields54, recordId54);
            //myClass8.validate(fields56, recordId56);

            }catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();

        //ASSERTS
        System.assert(myCase8 != null, 'myCase8 non può essere null');
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
        Account myAccount = [Select Id, FirstName__c, LastName__c, FiscalCode__c, VATNumber__c, BillingAddressFormula__c from Account];

        String recordId31 = myCase8c.Id;
        String fields31 = JSON.serialize(myCase8c);

        String recordId32 = myCase8c.Id;
        myCase8c.LastName__c = 'Rossi';
        String fields32 = JSON.serialize(myCase8c);

        String recordId33 = myCase8c.Id;
        myCase8c.Category__c = 'Aziende Soho';
        myCase8c.CustomerMarking__c = 'D3 - Azienda';
        String fields33 = JSON.serialize(myCase8c);
        update myCase8c;

        

        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass8c = new HDT_UTL_CaseValidations();
           
            myClass8c.validate(fields31, recordId31);
            myClass8c.validate(fields32, recordId32);
            myClass8c.validate(fields33, recordId33);
            
            
        }catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();

        //ASSERTS
        System.assert(myCase8c != null, 'myCase8c non può essere null');
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
        myCase9.WrittenReceiptRequestDate__c = Date.newInstance(2021, 12, 25);
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

        Case myCase9c = [Select Id, Type, ServicePoint__C, RelatedCase__c from Case where Type = 'Inversione del Contatore'];

        Case relatedCase = [Select Id, ServicePoint__C from Case where ServicePoint__r.CommoditySector__c = 'Gas'];

        String recordId42 = myCase9c.Id;
        String fields42 = JSON.serialize(myCase9c);

        String recordId43 = myCase9c.Id;
        myCase9c.RelatedCase__c = relatedCase.Id;
        String fields43 = JSON.serialize(myCase9c);

        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass9c = new HDT_UTL_CaseValidations();

            myClass9c.validate(fields42, recordId42);
            myClass9c.validate(fields43, recordId43);

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

    /*@isTest
    private static void validateTestType10(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTestType10';
        System.debug(debugString);
        
        //SETUP

        mySetup();
        
        Case myCase11 = [Select Id, Type, SupplyType__c, UseCategory__c, ServicePointType__c, Taxes__c,
        BillingProblem__c, Note__c, CustomerPaymentAgreements__c, EndValidityDate__c, EffectiveDate__c  from Case where Type = '']; 

        String recordId57 = myCase11.Id;
        myCase11.Type = 'Marcatura/Uso PdR';
        myCase11.SupplyType__c = 'A-Domestico';
        myCase11.UseCategory__c = '002-Prod.acqua calda sanitaria';
        myCase11.ServicePointType__c = '1002-Cottura/Produz acq calda';
        String fields57 = JSON.serialize(myCase11);

        String recordId58 = myCase11.Id;
        myCase11.Taxes__c = 'Imposta Usi Domestici (Cod. G_ICD)';
        String fields58 = JSON.serialize(myCase11);

        String recordId59 = myCase11.Id;
        myCase11.Type = 'BP/CA - errata categoria';
        myCase11.BillingProblem__c = 'Si';
        myCase11.Note__c = '';
        myCase11.CustomerPaymentAgreements__c = '';
        String fields59 = JSON.serialize(myCase11);

        String recordId60 = myCase11.Id;
        myCase11.Note__c = 'Note Cliente';
        myCase11.CustomerPaymentAgreements__c = 'Pagato';
        String fields60 = JSON.serialize(myCase11);

        String recordId61 = myCase11.Id;
        myCase11.Type = 'Modifica/Azzeramento Consumo Annuo';
        Date myDate3 = Date.newInstance(2021, 12, 20);
        Date myDate4 = Date.newInstance(2021, 12, 25);
        myCase11.EndValidityDate__c = myDate3;
        myCase11.EffectiveDate__c = myDate4;
        String fields61 = JSON.serialize(myCase11);
        
        String recordId62 = myCase11.Id;
        Date myDate5 = Date.newInstance(2021, 12, 25);
        Date myDate6 = Date.newInstance(2021, 12, 20);
        myCase11.EndValidityDate__c = myDate5;
        myCase11.EffectiveDate__c = myDate6;
        String fields62 = JSON.serialize(myCase11);


        Test.startTest();

        Try{
            
            HDT_UTL_CaseValidations myClass11 = new HDT_UTL_CaseValidations();
            
            myClass11.validate(fields57, recordId57);
            myClass11.validate(fields58, recordId58);
            myClass11.validate(fields59, recordId59);
            myClass11.validate(fields60, recordId60);
            myClass11.validate(fields61, recordId61);
            myClass11.validate(fields62, recordId62);

        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(myCase11 != null, 'myCase11 non può essere null');        
    }*/


}