public inherited sharing class HDT_UTL_PostSalesManager{

    private HDT_QR_Contract contractQr = new HDT_QR_Contract();
    private HDT_QR_Case caseQr = new HDT_QR_Case();
    private HDT_QR_PostSalesManager postsalesQr = new HDT_QR_PostSalesManager();
    private HDT_SRV_Order orderSrv = new HDT_SRV_Order();

    public void changeCaseValue(Sobject inputCase){

        Case currentCase = (Case) inputCase;

        currentCase.Subject = 'Il metodo ha funzionato';

    }


    public void changeQuotationType(SObject inputCase){

        Case currentCase = (Case) inputCase;

        System.debug('Amount --> '+currentCase.Amount__c);

        System.debug('Condition--> '+currentCase.Amount__c != null);

        if(currentCase.Amount__c != null){

            System.debug('QuotationType__c before --> '+currentCase.QuotationType__c);

            currentCase.QuotationType__c = 'Predeterminabile';

            System.debug('QuotationType__c after --> '+currentCase.QuotationType__c);

        }

    }

    public void closeContract(SObject inputCase){

        Case currentCase = (Case) inputCase;
        List<Contract> contractList = new List<Contract>();

        try{

            contractList = contractQr.getRecordById(currentCase.Contract__c);
            contractList[0].Status = 'Cessato';
            HDT_UTL_DatabaseService.updateSObject(contractList);
            
        }catch(Exception e){
            
            System.debug(e.getMessage());

        }


    }

    public void advanceParentCasePhase(SObject inputCase){

        Case currentCase = (Case) inputCase;
        Case parentCase = new Case();

        parentCase = caseQr.getParentCaseById(currentCase.ParentId);

        if(parentCase.Type == 'Variazione indirizzo di fornitura'){

            if(currentCase.Phase__c == 'KO definitivo'
            || postsalesQr.checkLocalDispatcher(parentCase.DistributorName__c) > 0){
                
                parentCase.Phase__c = 'Elaborazione Manuale';
            } else {

                parentCase.Phase__c = 'Completata';

            }

        }

        HDT_UTL_DatabaseService.updateSObject(parentCase);

    }

    public void handleVariazioneAnagraficaCliente(SObject inputCase) {

        if (inputCase == null) {
            System.debug('handleVariazioneAnagraficaCliente: null input case.');
            return;
        }

        Case currentCase = (Case) inputCase;
        System.debug('Gestione dati VariazioneAnagraficaCliente da case:' + currentCase.VatNumber__c);
        SObject objToUpdate = null;

        switch on currentCase.SubProcess__c {
            when 'Modifica Dati Fiscali' {
                Account acc = new Account();
                acc.Id = currentCase.AccountId;
                acc.FirstName__c = currentCase.FirstName__c;
                acc.LastName__c = currentCase.LastName__c;
                acc.Name = String.isBlank(currentCase.FirstName__c) ? currentCase.LastName__c : currentCase.FirstName__c + ' ' + currentCase.LastName__c;
                acc.FiscalCode__c = currentCase.FiscalCode__c;
                acc.VatNumber__c = currentCase.VatNumber__c;
                acc.CustomerMarking__c = currentCase.CustomerMarking__c;
                acc.BillingCity = currentCase.BillingCity__c;
                acc.BillingCityCode__c = currentCase.BillingCityCode__c;
                acc.BillingCountry = currentCase.BillingCountry__c;
                acc.BillingIsAddressVerified__c = currentCase.BillingIsAddressVerified__c;
                acc.BillingPlace__c = currentCase.BillingPlace__c;
                acc.BillingPostalCode = currentCase.BillingPostalCode__c;
                acc.BillingState = currentCase.BillingProvince__c;
                acc.BillingStreetCode__c = currentCase.BillingStreetCode__c;
                acc.BillingStreetName__c = currentCase.BillingStreetName__c;
                acc.BillingStreetNumber__c = currentCase.BillingStreetNumber__c;
                acc.BillingStreetNumberExtension__c = currentCase.BillingStreetNumberExtension__c;
                acc.BillingStreetToponym__c = currentCase.BillingStreetToponym__c;
                objToUpdate = acc;
            }
            when 'Variazione Gruppo IVA' {
                Account acc = new Account();
                acc.Id = currentCase.AccountId;
                acc.IsVATGroupJoined__c = currentCase.IsVATGroupJoined__c;
                acc.VATGroup__c = currentCase.VATGroup__c;
                acc.VATGroupStartDate__c = currentCase.VATGroupStartDate__c;
                acc.VATGroupEndDate__c = currentCase.VATGroupEndDate__c;
                objToUpdate = acc;
            }
            when 'Modifica Dati di Contatto' {
                Contact c = new Contact();
                c.Id = currentCase.ContactId;
                c.Email = currentCase.Email__c;
                c.Phone = currentCase.PhoneNumber__c;
                c.MobilePhone = currentCase.Mobile__c;
                c.CertifiedEmail__c = currentCase.CertifiedEmail__c;
                c.Fax = currentCase.Fax__c;
                objToUpdate = c;
            }
            when 'Modifica Dati di Recapito' {
                BillingProfile__c bp = new BillingProfile__c();
                bp.Id = currentCase.BillingProfile__c;
                bp.CareOf__c = currentCase.CareOf__c;
                bp.InvoiceEmailAddress__c = currentCase.InvoiceEmail__c;
                bp.BillSendingMethod__c = currentCase.BillSendingMethod__c;
                bp.InvoiceCertifiedEmailAddress__c = currentCase.InvoiceCertifiedEmailAddress__c;
                bp.SendCertifiedEmailConsentDate__c = currentCase.SendCertifiedEmailConsentDate__c;
                bp.ElectronicInvoicingMethod__c = currentCase.ElectronicInvoicingMethod__c;
                bp.ElectronicInvoiceCertifiedEmailAddress__c = currentCase.ElectronicInvoiceCertifiedEmailAddress__c;
                bp.OfficeSubjectCode__c = currentCase.OfficeSubjectCode__c;
                bp.XMLType__c = currentCase.XMLType__c;
                bp.InvoicingPostalCode__c = currentCase.InvoicingPostalCode__c;
                bp.InvoicingStreetNumber__c = currentCase.InvoicingStreetNumber__c;
                bp.InvoicingCityCode__c = currentCase.InvoicingCityCode__c;
                bp.InvoicingStreetCode__c = currentCase.InvoicingStreetCode__c;
                bp.InvoicingCity__c = currentCase.InvoicingCity__c;
                bp.InvoicingStreetNumberExtension__c = currentCase.InvoicingStreetNumberExtension__c;
                bp.InvoicingIsAddressVerified__c = currentCase.IsInvoicingVerified__c;
                bp.InvoicingPlace__c = currentCase.InvoicingPlace__c;
                bp.InvoicingStreetName__c = currentCase.InvoicingStreetName__c;
                bp.InvoicingCountry__c = currentCase.InvoicingCountry__c;
                bp.InvoicingStreetToponym__c = currentCase.InvoicingStreetToponym__c;
                bp.InvoicingProvince__c = currentCase.InvoicingProvince__c;
                objToUpdate = bp;
            }
            when else {
                System.debug('Sottoprocesso non supportato: ' + currentCase.SubProcess__c);
            }
        }

        if (objToUpdate != null) {
            HDT_UTL_DatabaseService.updateSObject(objToUpdate);
        }

        // Per tutti i sottoprocessi, tranne la Variaz. Gruppo IVA, inneschiamo il processo di Allineamento Anagrafica.
        if (!currentCase.SubProcess__c.equals('Variazione Gruppo IVA')) {
            List<Case> anagAlignCases = HDT_SRV_AnagAlignment.handleAnagAlignment(inputCase, HDT_SRV_AnagAlignment.HDT_ENU_AnagAlignmentContext.VARIAZIONE_ANAGRAFICA_CLIENTE);
            System.debug('# Case di Allineamento Anagrafica creati: ' + anagAlignCases.size());
        }
    }

    public void innescoAllineamentoAnagraficaFiscale(SObject inputCase) {
        if (inputCase == null) {
            System.debug('innescoAllineamentoAnagraficaFiscale: null input case.');
            return;
        }

        System.debug('Innesco Allineamento Anagrafica alla chiusura del Case Fiscale: ' + inputCase.Id);

        try {
            List<Case> anagAlignCases = HDT_SRV_AnagAlignment.handleAnagAlignment(inputCase, HDT_SRV_AnagAlignment.HDT_ENU_AnagAlignmentContext.VARIAZIONI_FISCALE);
            System.debug('# Case di Allineamento Anagrafica creati: ' + anagAlignCases.size());
        } catch (Exception ex) {
            System.debug('# Errore creazione Case di Allineamento Anagrafica: ' + ex.getMessage());
        }
    }

    public void evaluateEffectiveDate(SObject inputOrder){

        Order currentOrder = (Order) inputOrder;

        if(currentOrder.EffectiveDate__c != null && System.today() > currentOrder.EffectiveDate__c){

            currentOrder.EffectiveDate__c = orderSrv.addBusinessDay(System.today(), 3);

        }

    }


}