@isTest
public with sharing class HDT_UTL_CaseValidationsTst {

    
    //DEBUG
    public static final String TEST_NAME = 'HDT_UTL_CaseValidationsTst';
    
    
    //TEST SETUP
    
    
    //TESTS

    @isTest
    private static void validateTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTest';
        System.debug(debugString);
        
        //SETUP

        HDT_UTL_DataFactoryTst.pClickCasePhase();        

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
        accList[0].IsVATGroupJoined__c = false;
        accList[0].VATGroup__c = '86334519757';
        Date myNewStartDate = Date.newInstance(2021, 09, 25);
        accList[0].VATGroupStartDate__c = myNewStartDate;
        Date myNewEndDate = Date.newInstance(2021, 09, 28);
        accList[0].VATGroupStartDate__c = myNewEndDate;    
        update accList;
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        servPointList[0].CommoditySector__c = 'Energia Elettrica';
        update servPointList;
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        contactList[0].Email = 'myEmail@email.com';
        contactList[0].MobilePhone = '9872345123';
        contactList[0].Phone = '9879873425';
        contactList[0].CertifiedEmail__c = 'myCertifiedEmail@certifiedEmail.com';
        contactList[0].Fax = 'myFax';
        update contactList;
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(70, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        
        List<FormulaRecalcResult> results1 = Formula.recalculateFormulas(caseList);

        String recordId1 = caseList[0].Id;
        caseList[0].Type = 'Richiesta Parere';
        caseList[0].DelegateName__c = '';
        caseList[0].ComplaintEntryChannel__c = 'PEC';
        caseList[0].CompliantOriginEmail__c = '';
        String fields1 = JSON.serialize(caseList[0]);

        String recordId7 = caseList[6].Id;
        caseList[6].Type = 'Richiesta Parere';
        caseList[6].DelegateName__c = 'Mario Rossi';
        String fields7 = JSON.serialize(caseList[6]);

        String recordId8 = caseList[7].Id;
        caseList[7].Type = 'Richiesta Parere';
        caseList[7].SendDate__c = Date.newInstance(2025, 10, 10);
        String fields8 = JSON.serialize(caseList[7]);

        String recordId9 = caseList[8].Id;
        caseList[8].Type = 'Richiesta Parere';
        caseList[8].OpinionRequest__c = 'Prova parere';
        String fields9 = JSON.serialize(caseList[8]);

        String recordId10 = caseList[9].Id;
        caseList[9].Type = 'Richiesta Parere';
        String fields10 = JSON.serialize(caseList[9]);
        
        String recordId2 = caseList[1].Id;
        caseList[1].Type = 'Piano Rateizzazione';
        caseList[1].AttachmentManagement__c = true;
        String fields2 = JSON.serialize(caseList[1]);

        String recordId3 = caseList[2].Id;
        caseList[2].Type = 'Piano Rateizzazione';
        caseList[2].Deposit__c = true;
        caseList[2].DepositAmount__c = 43;
        caseList[2].DepositPaymentMode__c = '';
        String fields3 = JSON.serialize(caseList[2]);

        String recordId4 = caseList[3].Id;
        caseList[3].Type = 'Piano Rateizzazione';
        caseList[3].Deposit__c = true;
        caseList[3].DepositAmount__c = 43;
        caseList[3].DepositPaymentMode__c = 'Bollettino postale';
        caseList[3].ApplicationInterests__c = false;
        caseList[3].InstallmentNumberRequired__c = 8;
        String fields4 = JSON.serialize(caseList[3]);

        String recordId5 = caseList[4].Id;
        caseList[4].Type = 'Piano Rateizzazione';
        caseList[4].Deposit__c = true;
        caseList[4].DepositAmount__c = 43;
        caseList[4].DepositPaymentMode__c = 'Bollettino postale';
        caseList[4].ApplicationInterests__c = true;
        caseList[4].InstallmentNumberRequired__c = 4;
        String fields5 = JSON.serialize(caseList[4]);

        String recordId6 = caseList[5].Id;
        caseList[5].Type = 'Piano Rateizzazione';
        caseList[5].Deposit__c = true;
        caseList[5].DepositAmount__c = 43;
        caseList[5].DepositPaymentMode__c = 'Bollettino postale';
        String fields6 = JSON.serialize(caseList[5]);

        List<BillingProfile__c> bPList = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, accList[0].Id);
        BPList[0].PaymentMethod__c = 'Bonifico bancario';
        update BPList[0];

        update caseList;
        
        //TESTING
        Test.startTest();
        Try{
            
            HDT_UTL_CaseValidations myClass = new HDT_UTL_CaseValidations();
            myClass.validate(fields1, recordId1);

            myClass.validate(fields2, recordId2);

            myClass.validate(fields3, recordId3);

            myClass.validate(fields4, recordId4);

            myClass.validate(fields5, recordId5);

            myClass.validate(fields6, recordId6);

            myClass.validate(fields7, recordId7);

            myClass.validate(fields8, recordId8);

            myClass.validate(fields9, recordId9);

            myClass.validate(fields10, recordId10);

            
            accList[0].Category__c = 'Aziende TOP';
            update accList[0];
            List<FormulaRecalcResult> results2 = Formula.recalculateFormulas(caseList);
            System.assert(results2[0].isSuccess(), 'results2[0] deve essere success');

            String recordId11 = caseList[10].Id;
            caseList[10].Type = 'Piano Rateizzazione';
            caseList[10].Deposit__c = false;
            caseList[10].DepositPaymentMode__c = 'Paperless';
            caseList[10].SendPaperlessCodeMode__c = '';
            String fields11 = JSON.serialize(caseList[10]);

            String recordId12 = caseList[11].Id;
            caseList[11].Type = 'Piano Rateizzazione';
            caseList[11].Deposit__c = false;
            caseList[11].SendPaperlessCodeMode__c = 'SMS';
            String fields12 = JSON.serialize(caseList[11]);
            
            String recordId13 = caseList[12].Id;
            caseList[12].Type = 'Piano Rateizzazione';
            caseList[12].Deposit__c = false;
            caseList[12].SendPaperlessCodeMode__c = 'Email';
            String fields13 = JSON.serialize(caseList[12]);

            String recordId14 = caseList[13].Id;
            caseList[13].Type = 'Piano Rateizzazione';
            caseList[13].Deposit__c = false;
            String fields14 = JSON.serialize(caseList[13]);

            String recordId15 = caseList[14].Id;
            caseList[14].Type = 'Blocco Sollecito/Interessi';
            caseList[14].BlockType__c = 'M';
            String fields15 = JSON.serialize(caseList[14]);

            String recordId16 = caseList[15].Id;
            caseList[15].Type = 'Blocco Sollecito/Interessi';
            caseList[15].BlockType__c = 'W';
            String fields16 = JSON.serialize(caseList[15]);

            String recordId17 = caseList[16].Id;
            caseList[16].Type = 'Paperless';
            caseList[16].SendPaperlessCodeMode__c = 'SMS';
            String fields17 = JSON.serialize(caseList[16]);

            String recordId18 = caseList[17].Id;
            caseList[17].Type = 'Paperless';
            caseList[17].SendPaperlessCodeMode__c = 'Email';
            String fields18 = JSON.serialize(caseList[17]);

            String recordId19 = caseList[18].Id;
            caseList[18].Type = 'Paperless';
            caseList[18].SendPaperlessCodeMode__c = 'Email';
            caseList[18].Email__c = 'myMail@mail.com';
            String fields19 = JSON.serialize(caseList[18]);

            String recordId20 = caseList[19].Id;
            caseList[19].Type = 'Variazione Domiciliazione';
            caseList[19].BillingProfile__c = BPList[0].Id;
            caseList[19].Reason__c = 'Cambio Banca';
            caseList[19].BankAccountSignatoryFiscalCode__c = 'RSSMRA80A01D548N';
            String fields20 = JSON.serialize(caseList[19]);

            accList[0].CustomerMarking__c = 'D1 - Persona fisica';
            accList[0].Category__c = 'Famiglie';
            update accList[0];
            List<FormulaRecalcResult> results3 = Formula.recalculateFormulas(caseList);
            System.assert(results3[0].isSuccess(), 'result3[0] deve essere success');

            String recordId21 = caseList[20].Id;
            caseList[20].Type = 'Variazione Domiciliazione';
            caseList[20].BillingProfile__c = BPList[0].Id;
            caseList[20].Reason__c = 'Cambio Banca';
            caseList[20].AccountholderTypeBeneficiary__c = 'Rappresentante Legale';
            String fields21 = JSON.serialize(caseList[20]);

            String recordId22 = caseList[21].Id;
            caseList[21].Type = 'Variazione Domiciliazione';
            caseList[21].BillingProfile__c = BPList[0].Id;
            caseList[21].Reason__c = 'Cambio Banca';
            caseList[21].AccountholderTypeBeneficiary__c = 'Stesso Sottoscrittore';
            String fields22 = JSON.serialize(caseList[21]);

            String recordId23 = caseList[22].Id;
            caseList[22].Type = 'Variazione Domiciliazione';
            caseList[22].BillingProfile__c = BPList[0].Id;
            caseList[22].Reason__c = 'Cambio Banca';
            caseList[22].AccountholderTypeBeneficiary__c = 'Pagatore Alternativo';
            String fields23 = JSON.serialize(caseList[22]);

            String recordId24 = caseList[23].Id;
            caseList[23].Type = 'Variazione Domiciliazione';
            caseList[23].BillingProfile__c = BPList[0].Id;
            caseList[23].Reason__c = 'Cambio Banca';
            String fields24 = JSON.serialize(caseList[23]);

            String recordId25 = caseList[24].Id;
            caseList[24].Type = 'Rimborso';
            String fields25 = JSON.serialize(caseList[24]);

            String recordId26 = caseList[25].Id;
            caseList[25].Type = 'Variazione Anagrafica Cliente';
            caseList[25].Subprocess__c = 'Modifica Dati di Contatto';
            String fields26 = JSON.serialize(caseList[25]);

            String recordId27 = caseList[26].Id;
            caseList[26].Type = 'Variazione Anagrafica Cliente';
            caseList[26].Subprocess__c = 'Modifica Dati di Contatto';
            caseList[26].Category__c = 'Famiglie';
            caseList[26].CustomerMarking__c = 'D1 - Persona fisica';
            caseList[26].PhoneNumber__c = '9879873425';
            caseList[26].Email__c = 'myEmail@email.com';
            caseList[26].Mobile__c = '9872345123';
            caseList[26].CertifiedEmail__c = 'myCertifiedEmail@certifiedEmail.com';
            caseList[26].Fax__c  = 'myFax';
            String fields27 = JSON.serialize(caseList[26]);

            /*accList[0].FiscalCode__c = '';
            update accList;
            String recordId52 = caseList[51].Id;
            caseList[51].Type = 'Variazione Anagrafica Cliente';
            caseList[51].Subprocess__c = 'Modifica Dati di Contatto';
            caseList[51].Category__c = 'Piccoli Condomini';
            caseList[51].CustomerMarking__c = 'D5 - Condominio';
            String fields52 = JSON.serialize(caseList[51]);*/
            
            String recordId55 = caseList[54].Id;
            caseList[54].Type = 'Variazione Anagrafica Cliente';
            caseList[54].Subprocess__c = 'Modifica Dati di Contatto';
            caseList[54].Category__c = 'Aziende Soho';
            caseList[54].CustomerMarking__c = 'D3 - Azienda';
            String fields55 = JSON.serialize(caseList[54]);


            accList[0].FiscalCode__c = '1234568030155487';
            update accList;

            String recordId53 = caseList[52].Id;
            caseList[52].Type = 'Variazione Anagrafica Cliente';
            caseList[52].Subprocess__c = 'Modifica Dati di Contatto';
            caseList[52].Category__c = 'Aziende Soho';
            caseList[52].CustomerMarking__c = 'D2 - Ditta individuale';
            String fields53 = JSON.serialize(caseList[52]);

            String recordId54 = caseList[53].Id;
            caseList[53].Type = 'Variazione Anagrafica Cliente';
            caseList[53].Subprocess__c = 'Modifica Dati di Contatto';
            caseList[53].Category__c = 'Piccoli Condomini';
            caseList[53].CustomerMarking__c = 'D4 - Parti Comuni';
            String fields54 = JSON.serialize(caseList[53]);
            
            /*String recordId56 = caseList[55].Id;
            caseList[55].Type = 'Variazione Anagrafica Cliente';
            caseList[55].Subprocess__c = 'Modifica Dati di Contatto';
            caseList[55].Category__c = 'Aziende Soho';
            caseList[55].CustomerMarking__c = 'D6 - Associazione';
            String fields56 = JSON.serialize(caseList[55]);*/

            

            String recordId28 = caseList[27].Id;
            caseList[27].Type = 'Variazione Anagrafica Cliente';
            caseList[27].Subprocess__c = 'Modifica Dati di Recapito';
            caseList[27].BillSendingMethod__c = 'Bolletta per e-mail';
            String fields28 = JSON.serialize(caseList[27]);

            String recordId29 = caseList[28].Id;
            caseList[28].Type = 'Variazione Anagrafica Cliente';
            caseList[28].Subprocess__c = 'Modifica Dati di Recapito';
            caseList[28].BillSendingMethod__c = 'Invio tramite PEC';
            String fields29 = JSON.serialize(caseList[28]);

            String recordId30 = caseList[29].Id;
            caseList[29].Type = 'Variazione Anagrafica Cliente';
            caseList[29].Subprocess__c = 'Modifica Dati di Recapito';
            caseList[29].ElectronicInvoicingMethod__c = 'XML';
            caseList[29].BillSendingMethod__c = 'Invio tramite PEC';
            caseList[29].ElectronicInvoiceCertifiedEmailAddress__c = 'myPecEmail@pecEmail.com';
            caseList[29].OfficeSubjectCode__c = 'myOfficeSubjectCode';
            caseList[29].XMLType__c = 'Sintetico';            
            String fields30 = JSON.serialize(caseList[29]);

            String recordId31 = caseList[30].Id;
            caseList[30].Type = 'Variazione Anagrafica Cliente';
            caseList[30].Subprocess__c = 'Modifica Dati Fiscali';
            String fields31 = JSON.serialize(caseList[30]);

            String recordId32 = caseList[31].Id;
            caseList[31].Type = 'Variazione Anagrafica Cliente';
            caseList[31].Subprocess__c = 'Modifica Dati Fiscali';
            caseList[31].FirstName__c = 'Franco';
            caseList[31].LastName__c = 'Rossi';
            caseList[31].FiscalCode__c = 'RSSMRA80A01D548N';
            caseList[31].VatNumber__c = '03819031208';
            caseList[31].AlternativeAddress__c = 'Via Guglielmo Marconi, 15, , Ancona, IT, 60121, ITALIA';
            String fields32 = JSON.serialize(caseList[31]);

            String recordId33 = caseList[32].Id;
            caseList[32].Type = 'Variazione Anagrafica Cliente';
            caseList[32].Subprocess__c = 'Modifica Dati Fiscali';
            caseList[32].FirstName__c = 'Franco';
            caseList[32].LastName__c = 'Rossi';
            caseList[32].FiscalCode__c = 'RSSMRA80A01D548N';
            //caseList[32].VatNumber__c = '03819031208';
            caseList[32].AlternativeAddress__c = 'Via Guglielmo Marconi, 15, , Ancona, IT, 60121, ITALIA';
            String fields33 = JSON.serialize(caseList[32]);

            Date myStartDate = Date.newInstance(2021, 09, 25);
            Date myEndDate = Date.newInstance(2021, 09, 26);
            
            String recordId34 = caseList[33].Id;
            caseList[33].Type = 'Variazione Anagrafica Cliente';
            caseList[33].Subprocess__c = 'Variazione Gruppo IVA';
            caseList[33].IsVATGroupJoined__c = true;
            String fields34 = JSON.serialize(caseList[33]);

            String recordId35 = caseList[34].Id;
            caseList[34].Type = 'Variazione Anagrafica Cliente';
            caseList[34].Subprocess__c = 'Variazione Gruppo IVA';
            caseList[34].IsVATGroupJoined__c = true;
            caseList[34].VATGroup__c = '86334519757';
            String fields35 = JSON.serialize(caseList[34]);

            String recordId36 = caseList[35].Id;
            caseList[35].Type = 'Variazione Anagrafica Cliente';
            caseList[35].Subprocess__c = 'Variazione Gruppo IVA';
            caseList[35].IsVATGroupJoined__c = true;
            caseList[35].VATGroup__c = '86334519757';
            caseList[35].VATGroupStartDate__c = myStartDate;
            String fields36 = JSON.serialize(caseList[35]);

            String recordId37 = caseList[36].Id;
            caseList[36].Type = 'Variazione Anagrafica Cliente';
            caseList[36].Subprocess__c = 'Variazione Gruppo IVA';
            caseList[36].IsVATGroupJoined__c = true;
            caseList[36].VATGroup__c = '86334519757';
            caseList[36].VATGroupStartDate__c = myStartDate;
            caseList[36].VATGroupEndDate__c = myEndDate;
            String fields37 = JSON.serialize(caseList[36]);

            String recordId38 = caseList[37].Id;
            caseList[37].Type = 'Variazione Anagrafica Cliente';
            caseList[37].Subprocess__c = 'Variazione Gruppo IVA';
            caseList[37].IsVATGroupJoined__c = true;
            caseList[37].VATGroup__c = '86334519757';
            caseList[37].VATGroupStartDate__c = myStartDate;
            caseList[37].VATGroupEndDate__c = myEndDate;
            caseList[37].VatNumber__c = '03819031208';
            String fields38 = JSON.serialize(caseList[37]);

            String recordId39 = caseList[38].Id;
            caseList[38].Type = 'Variazione Anagrafica Cliente';
            caseList[38].Subprocess__c = 'Variazione Gruppo IVA';
            caseList[38].IsVATGroupJoined__c = true;
            caseList[38].VATGroup__c = '86334519757';
            caseList[38].VATGroupStartDate__c = myStartDate;
            caseList[38].VATGroupEndDate__c = myEndDate;
            caseList[38].VatNumber__c = '03819031208';
            String fields39 = JSON.serialize(caseList[38]);

            String recordId40 = caseList[39].Id;
            caseList[39].Type = 'Esercizio Diritti Privacy';
            Date myDate = Date.newInstance(2021, 12, 25);
            caseList[39].WrittenReceiptRequestDate__c = myDate;
            String fields40 = JSON.serialize(caseList[39]);

            String recordId41 = caseList[40].Id;
            caseList[40].Type = 'Modifica Privacy';
            caseList[40].MarketingPrivacy__c = 'Non espresso';
            caseList[40].ProfilingPrivacy__c = 'Non espresso';
            caseList[40].HasOptedOutSoftSpam__c = false;
            caseList[40].HasOptedOutOfEmail__c = false;
            String fields41 = JSON.serialize(caseList[40]);

            String recordId42 = caseList[41].Id;
            caseList[41].Type = 'Inversione del Contatore';
            String fields42 = JSON.serialize(caseList[41]);

            String recordId43 = caseList[42].Id;
            caseList[42].Type = 'Inversione del Contatore';
            caseList[42].RelatedCase__c = caseList[43].Id;
            String fields43 = JSON.serialize(caseList[42]);

            String recordId44 = caseList[43].Id;
            caseList[43].Type = 'Gestione Bonus Sociale';
            caseList[43].Reason__c = 'Permanenza condizioni di disagio';
            caseList[43].SendMode__c = 'E-Mail';
            caseList[43].Email__c = 'francopolidori@teletu.it';
            String fields44 = JSON.serialize(caseList[43]);

            String recordId45 = caseList[44].Id;
            caseList[44].Type = 'Gestione Bonus Sociale';
            caseList[44].SendMode__c = 'E-Mail';
            caseList[44].Email__c = '';
            String fields45 = JSON.serialize(caseList[44]);

            String recordId46 = caseList[45].Id;
            caseList[45].Type = 'Riattivazione Fornitura';
            Date myDate2 = Date.newInstance(2021, 12, 25);
            caseList[45].PaymentDate__c = myDate;
            String fields46 = JSON.serialize(caseList[45]);

            String recordId47 = caseList[46].Id;
            caseList[46].Type = 'Gestione Disalimentabilità';
            caseList[46].Disconnectable__c = 'Si';
            String fields47 = JSON.serialize(caseList[46]);

            String recordId48 = caseList[47].Id;
            caseList[47].Type = 'Gestione Disalimentabilità';
            caseList[47].Disconnectable__c = 'No';
            caseList[47].DisconnectibilityType__c = '';
            caseList[47].MobilePhoneNoticePesse__c = '';
            String fields48 = JSON.serialize(caseList[47]);

            String recordId49 = caseList[48].Id;
            caseList[48].Type = 'Gestione Disalimentabilità';
            caseList[48].Disconnectable__c = 'Si';
            caseList[48].SelfCertificationAcquisitionAsl__c = 'Ni';
            String fields49 = JSON.serialize(caseList[48]);

            String recordId50 = caseList[49].Id;
            caseList[49].Type = 'Gestione Disalimentabilità';
            caseList[49].Disconnectable__c = 'No';
            caseList[49].DisconnectibilityType__c = '01- App. medico terapeutiche';
            caseList[48].SelfCertificationAcquisitionAsl__c = 'No';
            String fields50 = JSON.serialize(caseList[49]);

            String recordId51 = caseList[50].Id;
            caseList[50].Type = 'Gestione Disalimentabilità';
            String fields51 = JSON.serialize(caseList[50]);

            String recordId57 = caseList[56].Id;
            caseList[56].Type = 'Marcatura/Uso PdR';
            caseList[56].SupplyType__c = 'A-Domestico';
            caseList[56].UseCategory__c = '002-Prod.acqua calda sanitaria';
            caseList[56].ServicePointType__c = '1002-Cottura/Produz acq calda';
            String fields57 = JSON.serialize(caseList[56]);

            String recordId58 = caseList[57].Id;
            caseList[57].Type = 'Marcatura/Uso PdR';
            caseList[57].SupplyType__c = 'A-Domestico';
            caseList[57].UseCategory__c = '002-Prod.acqua calda sanitaria';
            caseList[57].ServicePointType__c = '1002-Cottura/Produz acq calda';
            caseList[57].Taxes__c = 'Imposta Usi Domestici (Cod. G_ICD)';
            String fields58 = JSON.serialize(caseList[57]);

            String recordId59 = caseList[58].Id;
            caseList[58].Type = 'BP/CA - errata categoria';
            caseList[58].BillingProblem__c = 'Si';
            caseList[58].Note__c = '';
            caseList[58].CustomerPaymentAgreements__c = '';
            String fields59 = JSON.serialize(caseList[58]);

            String recordId60 = caseList[59].Id;
            caseList[59].Type = 'BP/CA - errata categoria';
            caseList[59].BillingProblem__c = 'Si';
            caseList[59].Note__c = 'Note Cliente';
            caseList[59].CustomerPaymentAgreements__c = 'Pagato';
            String fields60 = JSON.serialize(caseList[59]);

            String recordId61 = caseList[60].Id;
            caseList[60].Type = 'Modifica/Azzeramento Consumo Annuo';
            Date myDate3 = Date.newInstance(2021, 12, 20);
            Date myDate4 = Date.newInstance(2021, 12, 25);
            caseList[60].EndValidityDate__c = myDate3;
            caseList[60].EffectiveDate__c = myDate4;
            String fields61 = JSON.serialize(caseList[60]);
            
            String recordId62 = caseList[61].Id;
            caseList[61].Type = 'Modifica/Azzeramento Consumo Annuo';
            Date myDate5 = Date.newInstance(2021, 12, 25);
            Date myDate6 = Date.newInstance(2021, 12, 20);
            caseList[61].EndValidityDate__c = myDate3;
            caseList[61].EffectiveDate__c = myDate4;
            String fields62 = JSON.serialize(caseList[61]);





            update caseList;

            myClass.validate(fields11, recordId11);
            myClass.validate(fields12, recordId12);
            myClass.validate(fields13, recordId13);
            myClass.validate(fields14, recordId14);
            myClass.validate(fields15, recordId15);
            myClass.validate(fields16, recordId16);
            myClass.validate(fields17, recordId17);
            myClass.validate(fields18, recordId18);
            myClass.validate(fields19, recordId19);
            myClass.validate(fields20, recordId20);
            myClass.validate(fields21, recordId21);
            myClass.validate(fields22, recordId22);
            myClass.validate(fields23, recordId23);
            myClass.validate(fields24, recordId24);
            myClass.validate(fields25, recordId25);
            myClass.validate(fields26, recordId26);
            //myClass.validate(fields27, recordId27);
            //myClass.validate(fields52, recordId52);
            myClass.validate(fields55, recordId55);
            myClass.validate(fields53, recordId53);
            //myClass.validate(fields54, recordId54);
            //myClass.validate(fields56, recordId56);
            myClass.validate(fields28, recordId28);
            myClass.validate(fields29, recordId29);
            myClass.validate(fields30, recordId30);
            myClass.validate(fields31, recordId31);
            myClass.validate(fields32, recordId32);
            //myClass.validate(fields33, recordId33);
            myClass.validate(fields34, recordId34);
            myClass.validate(fields35, recordId35);
            myClass.validate(fields36, recordId36);
            myClass.validate(fields37, recordId37);
            //myClass.validate(fields38, recordId38);
            myClass.validate(fields39, recordId39);
            myClass.validate(fields40, recordId40);
            myClass.validate(fields41, recordId41);
            myClass.validate(fields42, recordId42);
            myClass.validate(fields43, recordId43);
            myClass.validate(fields44, recordId44);
            myClass.validate(fields45, recordId45);
            myClass.validate(fields46, recordId46);
            myClass.validate(fields47, recordId47);
            myClass.validate(fields48, recordId47);
            myClass.validate(fields49, recordId48);
            myClass.validate(fields50, recordId48);
            myClass.validate(fields51, recordId50);
            myClass.validate(fields57, recordId57);
            myClass.validate(fields58, recordId58);
            myClass.validate(fields59, recordId59);
            myClass.validate(fields60, recordId60);
            //myClass.validate(fields61, recordId61);
            //myClass.validate(fields62, recordId62);
            








        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(caseList != null, 'caseList non può essere null');
        System.assert(results1[0].isSuccess(), 'results1[0] deve essere success');        
    }


}