/*
* @Author: Salvatore A. Sarà 21/10/2021
* Risoluzione "Debug Should Use Logging Level"
* Risoluzione "Avoid debug statements since they impact on performance"
*/

@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_PostSalesManager{

    private HDT_QR_Contract contractQr = new HDT_QR_Contract();
    private HDT_QR_Case caseQr = new HDT_QR_Case();
    private HDT_QR_Order orderQr = new HDT_QR_Order();
    private HDT_QR_PostSalesManager postsalesQr = new HDT_QR_PostSalesManager();
    private HDT_SRV_Order orderSrv = new HDT_SRV_Order();

    private final Map<String,String> APPOINTMENT_METHOD = new Map<String,String>{
        'Consegna copia chiave GdM' => 'ConsegnaCopiaChiaveGdM',
        'Sost. contatore cliente' => 'Sost.Contatorec/cliente',
        'Verifica GDM' => 'VerificaGdM',
        'Verifica Tensione - Pressione' => 'VerificaPressione'
    };

    public void changeCaseValue(Sobject inputCase){

        Case currentCase = (Case) inputCase;

        currentCase.Subject = 'Il metodo ha funzionato';

    }

    public void submitForApproval(SObject inputCase)
    {
        Case currentCase = (Case) inputCase;
        System.enqueueJob(new HDT_QBL_VoltureChangeManager(new List<Case>{currentCase}));
    }

    public void changeQuotationType(SObject inputCase){

        Case currentCase = (Case) inputCase;

        System.debug(LoggingLevel.DEBUG,'Amount --> '+currentCase.Amount__c);

        System.debug(LoggingLevel.DEBUG,'Condition--> '+currentCase.Amount__c != null);

        if(currentCase.Amount__c != null){

            System.debug(LoggingLevel.DEBUG,'QuotationType__c before --> '+currentCase.QuotationType__c);

            currentCase.QuotationType__c = 'Predeterminabile';

            System.debug(LoggingLevel.DEBUG,'QuotationType__c after --> '+currentCase.QuotationType__c);

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
            
            System.debug(LoggingLevel.DEBUG,e.getMessage());

        }


    }

    public void advanceParentCasePhase(SObject inputCase){

        Case currentCase = (Case) inputCase;
        Case parentCase = new Case();

        try{
            parentCase = caseQr.getParentCaseById(currentCase.ParentId);
        }catch(Exception e){
            System.debug(LoggingLevel.DEBUG,e.getMessage());
        }
        if(parentCase != null){

            if(parentCase.Type == 'Variazione indirizzo di fornitura'){

                if(currentCase.Phase__c == 'KO definitivo'
                || postsalesQr.checkLocalDispatcher(parentCase.DistributorName__c) == 0){
                    parentCase.Phase__c = 'Elaborazione Manuale';
                } else {
                    parentCase.Phase__c = 'Completata';
                }
            }else if(parentCase.Type.equalsIgnoreCase('Modifica Tariffa Residente/Non Residente') || parentCase.Type.equalsIgnoreCase('Marcatura/Uso PdR')){
                parentCase.Phase__c = 'Elaborazione Manuale';
            }
             else if(parentCase.Type.equalsIgnoreCase('Allineamento Canone Rai')){
                if(currentCase.Phase__c.equalsIgnoreCase('KO definitivo')){
                    wrts_prcgvr__Activity__c activity = createActivity('Gestione Manuale');
                    activity.Case__c = parentCase.Id;
                    HDT_UTL_DatabaseService.insertSObject(activity);
                } else {
                    parentCase.Phase__c = 'Completata';
                }
            } else if(parentCase.Type.equalsIgnoreCase('Gestione Disalimentabilità')){
                wrts_prcgvr__Activity__c activity = createActivity('Gestione Manuale SAP');
                activity.Case__c = parentCase.Id;
                activity.wrts_prcgvr__IsRequired__c	= true;
                HDT_UTL_DatabaseService.insertSObject(activity);
            } else if (parentCase.Type.equalsIgnoreCase('Consumo Anomalo Idrico') && currentCase.Type.equalsIgnoreCase('Verifica Fuga Idrica') && (currentCase.Commodity__c.equalsIgnoreCase('Acqua') || currentCase.CommodityFormula__c.equalsIgnoreCase('Acqua'))) {
                wrts_prcgvr__Activity__c actElabManuale = [SELECT Id, ActivityOutcome__c FROM wrts_prcgvr__Activity__c WHERE Case__c =: currentCase.Id AND Type__c = 'Elaborazione Manuale' AND wrts_prcgvr__Status__c = 'Chiusa' WITH SECURITY_ENFORCED LIMIT 1];
                if (actElabManuale != null && 'Negativo'.equalsIgnoreCase(actElabManuale.ActivityOutcome__c)){
                    parentCase.Phase__c = 'KO Definitivo';
                    parentCase.Status = 'Closed';
                }else if (actElabManuale != null && 'Positivo'.equalsIgnoreCase(actElabManuale.ActivityOutcome__c)){
                    parentCase.Phase__c = 'Documentazione validata';
                    parentCase.Status = 'In Lavorazione';
                }
            } else if ('Ricostruzione Consumi'.equalsIgnoreCase(parentCase.Type) && !'Completata'.equalsIgnoreCase(parentCase.Phase__c) && 'Acqua'.equalsIgnoreCase(parentCase.Commodity__c) &&'Completata'.equalsIgnoreCase(currentCase.Phase__c)){
                parentCase.Phase__c = 'Completata';
                parentCase.Status = 'Closed';
            }

            HDT_UTL_DatabaseService.updateSObject(parentCase);
        }


    }

    public void handleVariazioneAnagraficaCliente(SObject inputCase) {

        if (inputCase == null) {
            System.debug(LoggingLevel.DEBUG,'handleVariazioneAnagraficaCliente: null input case.');
            return;
        }

        Case currentCase = (Case) inputCase;
        System.debug(LoggingLevel.DEBUG,'Gestione dati VariazioneAnagraficaCliente da case:' + currentCase.Id);
        List<SObject> objToUpdate = new List<SObject>();

        List<String> phasesOrder = new List<String>{'Bozza','Da Inviare','In Lavorazione'};
        List<Order> orderToUpdate = orderQr.getRecordsByAccountIdInPhases(currentCase.AccountId, phasesOrder);

        List<String> phasesCase = new List<String>{'Bozza','Da Inviare'};
        List<Case> caseToUpdate = caseQr.getRecordsByAccountIdInPhases(currentCase.AccountId, phasesCase);

        System.debug(LoggingLevel.DEBUG,'currentCase.SubProcess__c:' + currentCase.SubProcess__c);
        switch on currentCase.SubProcess__c {
            when 'Modifica Dati Fiscali' {
                Account acc = new Account();
                acc.Id = currentCase.AccountId;
                acc.FirstName__c = currentCase.FirstName__c;
                acc.LastName__c = currentCase.LastName__c;
                acc.Name = String.isBlank(currentCase.FirstName__c) ? currentCase.LastName__c : currentCase.FirstName__c + ' ' + currentCase.LastName__c;
                acc.FiscalCode__c = currentCase.FiscalCode__c;
                acc.VatNumber__c = currentCase.VatNumber__c;
                acc.BillingCity = currentCase.BillingCity__c;
                acc.BillingCityCode__c = currentCase.BillingCityCode__c;
                acc.BillingCountry = currentCase.BillingCountry__c;
                /* Gestione indirizzo Estero */
                Boolean isAddressVerified = (currentCase.BillingCountry__c != null && currentCase.BillingCountry__c.equalsIgnoreCase('Italia')) ? currentCase.BillingIsAddressVerified__c : true;
                acc.BillingIsAddressVerified__c = isAddressVerified;
                acc.BillingPlace__c = currentCase.BillingPlace__c;
                acc.BillingPostalCode = currentCase.BillingPostalCode__c;
                acc.BillingState = currentCase.BillingProvince__c;
                acc.BillingStreetCode__c = currentCase.BillingStreetCode__c;
                acc.BillingStreetName__c = currentCase.BillingStreetName__c;
                acc.BillingStreetNumber__c = currentCase.BillingStreetNumber__c;
                acc.BillingStreetNumberExtension__c = currentCase.BillingStreetNumberExtension__c;
                acc.IsWrongFiscalData__c = false;
                objToUpdate.add(acc);

                for ( Case c : caseToUpdate )
                {
                    if( c.Id != currentCase.Id ){
                        c.FirstName__c = currentCase.FirstName__c;
                        c.LastName__c = currentCase.LastName__c;
                        c.FiscalCode__c = currentCase.FiscalCode__c;
                        c.VatNumber__c = currentCase.VatNumber__c;
                        c.BillingCity__c = currentCase.BillingCity__c;
                        c.BillingCityCode__c = currentCase.BillingCityCode__c;
                        c.BillingCountry__c = currentCase.BillingCountry__c;
                        c.BillingIsAddressVerified__c = currentCase.BillingIsAddressVerified__c;
                        c.BillingPlace__c = currentCase.BillingPlace__c;
                        c.BillingPostalCode__c = currentCase.BillingPostalCode__c;
                        c.BillingProvince__c = currentCase.BillingProvince__c;
                        c.BillingStreetCode__c = currentCase.BillingStreetCode__c;
                        c.BillingStreetName__c = currentCase.BillingStreetName__c;
                        c.BillingStreetNumber__c = currentCase.BillingStreetNumber__c;
                        c.BillingStreetNumberExtension__c = currentCase.BillingStreetNumberExtension__c;
                        objToUpdate.add(c);
                    }
                }

                for ( Order o : orderToUpdate )
                {
                    o.BankAccountSignatoryFirstName__c = currentCase.FirstName__c;
                    o.BankAccountSignatoryLastName__c = currentCase.LastName__c;
                    o.BankAccountSignatoryFiscalCode__c = currentCase.FiscalCode__c;
                    o.CustomerVATNumber__c = currentCase.VatNumber__c;
                    o.BillingCity = currentCase.BillingCity__c;
                    o.BillingCityCode__c = currentCase.BillingCityCode__c;
                    o.BillingCountry = currentCase.BillingCountry__c;
                    o.BillingIsAddressVerified__c = currentCase.BillingIsAddressVerified__c;
                    o.BillingPlace__c = currentCase.BillingPlace__c;
                    o.BillingPostalCode = currentCase.BillingPostalCode__c;
                    o.BillingState = currentCase.BillingProvince__c;
                    o.BillingStreetName__c = currentCase.BillingStreetName__c;
                    o.BillingStreetNumber__c = currentCase.BillingStreetNumber__c;
                    o.BillingStreetNumberExtension__c = currentCase.BillingStreetNumberExtension__c;
                    objToUpdate.add(o);
                }
            }
            when 'Variazione Gruppo IVA' {
                Account acc = new Account();
                acc.Id = currentCase.AccountId;
                acc.IsVATGroupJoined__c = currentCase.IsVATGroupJoined__c;
                acc.VATGroup__c = currentCase.VATGroup__c;
                acc.VATGroupStartDate__c = currentCase.VATGroupStartDate__c;
                acc.VATGroupEndDate__c = currentCase.VATGroupEndDate__c;
                objToUpdate.add(acc);

                for ( Case c : caseToUpdate )
                {
                    if( c.Id != currentCase.Id ){
                        c.IsVATGroupJoined__c = currentCase.IsVATGroupJoined__c;
                        c.VATGroup__c = currentCase.VATGroup__c;
                        c.VATGroupStartDate__c = currentCase.VATGroupStartDate__c;
                        c.VATGroupEndDate__c = currentCase.VATGroupEndDate__c;
                        objToUpdate.add(c);
                    }
                }
            }
            when 'Modifica Dati di Contatto' {
                Contact c = new Contact();
                c.Id = currentCase.ContactId;
                c.Email = currentCase.Email__c;
                c.Phone = currentCase.PhoneNumber__c;
                c.MobilePhone = currentCase.Mobile__c;
                c.CertifiedEmail__c = currentCase.CertifiedEmail__c;
                c.Fax = currentCase.Fax__c;
                objToUpdate.add(c);

                Account acc = new Account();
                acc.Id = currentCase.AccountId;
                acc.CustomerMarking__c = currentCase.CustomerMarking__c;
                objToUpdate.add(acc);

                for ( Case cs : caseToUpdate )
                {
                    if( cs.Id != currentCase.Id ){
                        cs.Email__c = currentCase.Email__c;
                        cs.PhoneNumber__c = currentCase.PhoneNumber__c;
                        cs.Mobile__c = currentCase.Mobile__c;
                        cs.CertifiedEmail__c = currentCase.CertifiedEmail__c;
                        cs.Fax__c = currentCase.Fax__c;
                        cs.CustomerMarking__c = currentCase.CustomerMarking__c;
                        objToUpdate.add(cs);
                    }
                }

                for ( Order o : orderToUpdate )
                {
                    o.Email__c = currentCase.Email__c;
                    o.PhoneNumber__c = currentCase.Mobile__c;
                    o.InvoiceCertifiedEmailAddress__c = currentCase.CertifiedEmail__c;
                    objToUpdate.add(o);
                }
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
                bp.InvoicingProvince__c = currentCase.InvoicingProvince__c;
                bp.ReminderFlag__c = currentCase.ReminderFlag__c;
                bp.ReminderCertifiedEmailAddress__c = currentCase.ReminderCertifiedEmailAddress__c;
                objToUpdate.add(bp);
                
                for ( Case c : caseToUpdate )
                {
                    if( c.Id != currentCase.Id ){
                        c.CareOf__c = currentCase.CareOf__c;
                        c.InvoiceEmail__c = currentCase.InvoiceEmail__c;
                        c.BillSendingMethod__c = currentCase.BillSendingMethod__c;
                        c.InvoiceCertifiedEmailAddress__c = currentCase.InvoiceCertifiedEmailAddress__c;
                        c.SendCertifiedEmailConsentDate__c = currentCase.SendCertifiedEmailConsentDate__c;
                        c.ElectronicInvoicingMethod__c = currentCase.ElectronicInvoicingMethod__c;
                        c.ElectronicInvoiceCertifiedEmailAddress__c = currentCase.ElectronicInvoiceCertifiedEmailAddress__c;
                        c.OfficeSubjectCode__c = currentCase.OfficeSubjectCode__c;
                        c.XMLType__c = currentCase.XMLType__c;
                        c.InvoicingPostalCode__c = currentCase.InvoicingPostalCode__c;
                        c.InvoicingStreetNumber__c = currentCase.InvoicingStreetNumber__c;
                        c.InvoicingCityCode__c = currentCase.InvoicingCityCode__c;
                        c.InvoicingStreetCode__c = currentCase.InvoicingStreetCode__c;
                        c.InvoicingCity__c = currentCase.InvoicingCity__c;
                        c.InvoicingStreetNumberExtension__c = currentCase.InvoicingStreetNumberExtension__c;
                        c.IsInvoicingVerified__c = currentCase.IsInvoicingVerified__c;
                        c.InvoicingPlace__c = currentCase.InvoicingPlace__c;
                        c.InvoicingStreetName__c = currentCase.InvoicingStreetName__c;
                        c.InvoicingCountry__c = currentCase.InvoicingCountry__c;
                        c.InvoicingProvince__c = currentCase.InvoicingProvince__c;
                        c.ReminderFlag__c = currentCase.ReminderFlag__c;
                        c.ReminderCertifiedEmailAddress__c = currentCase.ReminderCertifiedEmailAddress__c;
                        objToUpdate.add(c);
                    }
                }

                for ( Order o : orderToUpdate )
                {
                    o.InvoiceEmailAddress__c = currentCase.InvoiceEmail__c;
                    o.BillSendMode__c = currentCase.BillSendingMethod__c;
                    o.InvoiceCertifiedEmailAddress__c = currentCase.InvoiceCertifiedEmailAddress__c;
                    o.SendCertifiedEmailConsentDate__c = currentCase.SendCertifiedEmailConsentDate__c;
                    o.ElectronicInvoicingMethod__c = currentCase.ElectronicInvoicingMethod__c;
                    o.XMLType__c = currentCase.XMLType__c;
                    o.ShippingPostalCode = currentCase.InvoicingPostalCode__c;
                    o.ShippingPostalCode__c = currentCase.InvoicingPostalCode__c;
                    o.ShippingStreetNumber__c = currentCase.InvoicingStreetNumber__c;
                    o.ShippingCityCode__c = currentCase.InvoicingCityCode__c;
                    o.ShippingStreetCode__c = currentCase.InvoicingStreetCode__c;
                    o.ShippingCity__c = currentCase.InvoicingCity__c;
                    o.ShippingStreetNumberExtension__c = currentCase.InvoicingStreetNumberExtension__c;
                    o.ShippingIsAddressVerified__c = currentCase.IsInvoicingVerified__c;
                    o.ShippingPlace__c = currentCase.InvoicingPlace__c;
                    o.ShippingStreetName__c = currentCase.InvoicingStreetName__c;
                    o.ShippingCountry__c = currentCase.InvoicingCountry__c;
                    o.ShippingProvince__c = currentCase.InvoicingProvince__c;
                    objToUpdate.add(o);
                }
            }
            when else {
                System.debug(LoggingLevel.DEBUG,'Sottoprocesso non supportato: ' + currentCase.SubProcess__c);
            }
        }

        if (objToUpdate != null) {
            HDT_UTL_DatabaseService.updateSObject(objToUpdate);
        }

        // Per tutti i sottoprocessi, tranne la Variaz. Gruppo IVA, inneschiamo il processo di Allineamento Anagrafica.
        /* 2022-11-28 @frpanico TK 930699C Dato che la modifica dati di recapito varia solo dati di fatturazione non e' necessario trasmettere le variazioni al SII */
        if (!currentCase.SubProcess__c.equals('Variazione Gruppo IVA') && !currentCase.SubProcess__c.equalsIgnoreCase('Modifica Dati di Recapito')) {
            List<Case> anagAlignCases = HDT_SRV_AnagAlignment.handleAnagAlignment(inputCase, HDT_SRV_AnagAlignment.HDT_ENU_AnagAlignmentContext.VARIAZIONE_ANAGRAFICA_CLIENTE);
            System.debug(LoggingLevel.DEBUG,'# Case di Allineamento Anagrafica creati: ' + anagAlignCases.size());
        }
    }

    public void handleVariazioneAmministratore(SObject inputCase) {

        if (inputCase == null) {
            System.debug(LoggingLevel.DEBUG,'handleVariazioneAmministratore: null input case.');
            return;
        }

        Case currentCase = (Case) inputCase;
        System.debug(LoggingLevel.DEBUG,'Gestione dati VariazioneAmministratore da case: ' + currentCase.Id);

        switch on currentCase.SubProcess__c {
            when 'Cambio Amministratore' {
                String accountId = currentCase.AccountId;
                String newAdministratorId = currentCase.ContactId;
                HDT_QR_AccountContactRelation queryHandler = new HDT_QR_AccountContactRelation();
                AccountContactRelation currentAdminAcr = queryHandler.getActiveAdministratorRelation(accountId);
                if (currentAdminAcr != null) {
                    System.debug(LoggingLevel.DEBUG,'Disassociazione Account ' + accountId + ' da Amministratore di condominio: ' + currentAdminAcr.ContactId);
                    currentAdminAcr.IsActive = False;
                    currentAdminAcr.EndDate = Date.today();
                    HDT_UTL_DatabaseService.updateSObject(currentAdminAcr);
                }
                
                AccountContactRelation newAdminAcr = new AccountContactRelation();
                newAdminAcr.AccountId = accountId;
                newAdminAcr.ContactId = newAdministratorId;
                newAdminAcr.IsActive = True;
                newAdminAcr.StartDate = Date.today();
                newAdminAcr.Roles = 'Amministratore condominio';
                System.debug(LoggingLevel.DEBUG,'Associazione Account ' + accountId + ' ad Amministratore di condominio: ' + newAdministratorId);
                HDT_UTL_DatabaseService.insertSObject(newAdminAcr);
            }
            when 'Cambio Intest/Indirizzo Amministratore' {
                Contact c = new Contact();
                c.Id = currentCase.ContactId;
                c.MailingCityCode__c = currentCase.BillingCityCode__c;
                c.MailingCity = currentCase.BillingCity__c;

                c.MailingCountry = currentCase.BillingCountry__c;
                c.MailingIsAddressVerified__c = currentCase.BillingIsAddressVerified__c;
                c.MailingPlace__c = currentCase.BillingPlace__c;
                c.MailingPostalCode = currentCase.BillingPostalCode__c;
                c.MailingState = currentCase.BillingProvince__c;
                c.MailingStreetCode__c = currentCase.BillingStreetCode__c;
                c.MailingStreetName__c = currentCase.BillingStreetName__c;
                c.MailingStreetNumberExtension__c = currentCase.BillingStreetNumberExtension__c;
                c.MailingStreetNumber__c = currentCase.BillingStreetNumber__c;

                HDT_UTL_DatabaseService.updateSObject(c);
            }
            when else {
                System.debug(LoggingLevel.DEBUG,'Sottoprocesso non supportato: ' + currentCase.SubProcess__c);
            }
        }
    }

    public void innescoAllineamentoAnagraficaFiscale(SObject inputCase) {
        if (inputCase == null) {
            System.debug(LoggingLevel.DEBUG,'innescoAllineamentoAnagraficaFiscale: null input case.');
            return;
        }

        System.debug(LoggingLevel.DEBUG,'Innesco Allineamento Anagrafica alla chiusura del Case Fiscale: ' + inputCase.Id);

        try {
            List<Case> anagAlignCases = HDT_SRV_AnagAlignment.handleAnagAlignment(inputCase, HDT_SRV_AnagAlignment.HDT_ENU_AnagAlignmentContext.VARIAZIONI_FISCALE);
            System.debug(LoggingLevel.DEBUG,'# Case di Allineamento Anagrafica creati: ' + anagAlignCases.size());
        } catch (Exception ex) {
            System.debug(LoggingLevel.DEBUG,'# Errore creazione Case di Allineamento Anagrafica: ' + ex.getMessage());
        }
    }

    public void innescoAllineamentoAnagraficaCanoneRai(SObject inputCase) {
        if (inputCase == null) {
            System.debug(LoggingLevel.DEBUG,'innescoAllineamentoAnagraficaCanoneRai: null input case.');
            return;
        }

        System.debug(LoggingLevel.DEBUG,'Innesco Allineamento Anagrafica alla chiusura del Case di Allineamento Canone RAI: ' + inputCase.Id);

        try {
            List<Case> anagAlignCases = HDT_SRV_AnagAlignment.handleAnagAlignment(inputCase, HDT_SRV_AnagAlignment.HDT_ENU_AnagAlignmentContext.ALLINEAMENTO_CANONE_RAI);
            System.debug(LoggingLevel.DEBUG,'# Case di Allineamento Anagrafica creati: ' + anagAlignCases.size());
        } catch (Exception ex) {
            System.debug(LoggingLevel.DEBUG,'# Errore creazione Case di Allineamento Anagrafica: ' + ex.getMessage());
        }
    }

    public void innescoAllineamentoAnagraficaGestioneDisalimentabilita(SObject inputCase) {
        if (inputCase == null) {
            System.debug(LoggingLevel.DEBUG,'innescoAllineamentoGestioneDisalimentabilita: null input case.');
            return;
        }

        System.debug(LoggingLevel.DEBUG,'Innesco Allineamento Anagrafica alla chiusura del Case di Gestione Disalimentabilità: ' + inputCase.Id);

        try {
            List<Case> anagAlignCases = HDT_SRV_AnagAlignment.handleAnagAlignment(inputCase, HDT_SRV_AnagAlignment.HDT_ENU_AnagAlignmentContext.GESTIONE_DISALIMENTABILITA);
            System.debug(LoggingLevel.DEBUG,'# Case di Allineamento Anagrafica creati: ' + anagAlignCases.size());
        } catch (Exception ex) {
            System.debug(LoggingLevel.DEBUG,'# Errore creazione Case di Allineamento Anagrafica: ' + ex.getMessage());
        }
    }

    public void evaluateEffectiveDate(SObject inputOrder){

        Order currentOrder = (Order) inputOrder;

        if(currentOrder.EffectiveDate__c != null && System.today() > currentOrder.EffectiveDate__c){

            currentOrder.EffectiveDate__c = orderSrv.addBusinessDay(System.today(), 3);

        }

    }

    public void recalculateVoltureEffectiveDate(SObject inputSobj)
    {
        if(inputSobj.get('EffectiveDate__c') != null && System.today() > (Date)inputSobj.get('EffectiveDate__c'))
        {
            inputSobj.put('EffectiveDate__c', HDT_UTL_Case.addBusinessDay(System.today(), 3));
        }
    }

    public void sbloccoVoltura(SObject inputCase){

        Case currentCase = (Case) inputCase;

        wrts_prcgvr__Activity__c activity = createActivity('Sblocco Voltura');
        if(currentCase.VulturePracticeReference__c != null){
            //wrts_prcgvr__Activity__c activity = createActivity('Sblocco Voltura');
            activity.Order__c = currentCase.VulturePracticeReference__c;
            //HDT_UTL_DatabaseService.insertSObject(activity);
            HDT_UTL_DatabaseService.insertSObject(activity);
        }
    }

    public void changePaymentMethod(SObject inputCase){

        Case currentCase = (Case) inputCase;
        BillingProfile__c billingProfile = new BillingProfile__c();

        billingProfile.Id = currentCase.BillingProfile__c;
        billingProfile.PaymentMethod__c = 'RID';

        HDT_UTL_DatabaseService.updateSObject(billingProfile);

    }

    public void advanceRelatedCase(SObject inputOrder){

        Order currentOrder = (Order) inputOrder;
        Case relatedCase = postsalesQr.getCaseByServicePoint('Allineamento Canone Rai', currentOrder.ServicePoint__c);
        if(relatedCase != null){
            if(!(currentOrder.PhaseStory__c.containsIgnoreCase('Errore Lavorazione SAP'))){
                relatedCase.Phase__c = 'Completata';
                HDT_UTL_DatabaseService.updateSObject(relatedCase);
            }else{
                wrts_prcgvr__Activity__c activity = createActivity('Elaborazione Manuale');
                activity.Case__c = relatedCase.Id;
                HDT_UTL_DatabaseService.insertSObject(activity);
            }
        }
    }

    public void updateServicePoint(SObject inputCase){

        Case currentCase = (Case) inputCase;
        ServicePoint__c servPoint = new ServicePoint__c();
        servPoint.Id             = currentCase.ServicePoint__c;

        if(currentCase.Type.equalsIgnoreCase('Marcatura/Uso PdR')){
            servPoint.UseCategory__c = currentCase.UseCategory__c;
            servPoint.SupplyType__c  = currentCase.SupplyType__c;
            servPoint.ImplantType__c	= currentCase.ServicePointType__c;
        }

        switch on currentCase.Type {
            when  'Sospensione Fornitura'{
                servPoint.MeterStatus__c = 'Inattivo';
            }
        }

        HDT_UTL_DatabaseService.updateSObject(servPoint);
    }

    //returns activity and has to be created inside the caller methdo because it has to be linked to an entity first
    private static wrts_prcgvr__Activity__c createActivity(String templateName){
        HDT_QR_PostSalesManager postsalesQr = new HDT_QR_PostSalesManager();
        wrts_prcgvr__ActivityTemplate__c template = postsalesQr.getActivityTemplate(templateName);
        wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();
        activity.wrts_prcgvr__ActivityTemplate__c = template.Id;
        activity.wrts_prcgvr__Description__c = template.wrts_prcgvr__Subject__c;
        activity.Type__c = templateName;
        return activity;
    }

    public void sendDocumentFile(SObject inputRecord){


        Id recordId = (Id)inputRecord.get('Id');
        

        if('Verifiche'.equalsIgnoreCase((String)inputRecord.get('Cluster__c')) && 
            APPOINTMENT_METHOD.containsKey((String)inputRecord.get('Type'))){

            Map<String, Object> inputMap = new Map<String,Object>();
            HDT_UTL_GestAppAutomaticCreationCase gestAppAutomaticCreationCase = new HDT_UTL_GestAppAutomaticCreationCase();
        
            inputMap.put('method', APPOINTMENT_METHOD.get((String)inputRecord.get('Type')));
            inputMap.put('sender', new Case(Id = (Id)inputRecord.get('Id')));
            gestAppAutomaticCreationCase.execute(inputMap);
         }

        if(recordId.getSobjectType().getDescribe().getName() == 'Order')
        {
            recordId = (Id)inputRecord.get('ParentOrder__c');
        }
        Map<String,String> formParams = new Map<String,String>();
        formParams.put('mode', 'Print');
        formParams.put('Archiviato', 'Y');
        String sObjectName = recordId.getSObjectType().getDescribe().getName();
        HDT_LC_DocumentSignatureManager.sendDocumentFile(recordId, sObjectName, JSON.serialize(formParams));
    }

    public void closeRiattivazione(SObject inputCase)
    {
        Case currentCase = (Case)inputCase;
        Case caseToUdpate = new Case();
        caseToUdpate.Id = currentCase.Id;
        if(currentCase.Type.equalsIgnoreCase('Riattivazione Fornitura') && (currentCase.HerokuPracticeCode__c == null || currentCase.HerokuPracticeCode__c == ''))
        {
            caseToUdpate.Phase__c = 'Annullato';
            caseToUdpate.Status = 'Closed';
        }
        HDT_PEV_NonReqContract__e event = new HDT_PEV_NonReqContract__e();
        event.SerializedCase__c = JSON.serialize(caseToUdpate);
        EventBus.publish(event);
    }    
    
    public void updateDataFineContratto(SObject inputCase){

        Case myCase = (Case) inputCase;
        Contract myContract = new Contract();
        myContract.Id = myCase.Contract__c;
        myContract.EndDate = myCase.TemporaryConnectionEndDate__c;

        HDT_UTL_DatabaseService.updateSObject(myContract);

    }

    public void closeAnnullamentoExtraSistema(SObject inputCase)
    {
        Case currentCase = new Case();
        currentCase.Id = inputCase.Id;
        currentCase.Phase__c = 'Annullato';
        currentCase.Status = 'Closed';
        updateFuture(JSON.serialize(currentCase));
    }

    /**
     * Crea l'associazione SOL per il processo di Associazione Utente Web.
     * Nota: si assume che il contatto SOL sia salvato su Case.SecondaryContact__c e non Case.ContactId
     */
    public void createSolAcr(SObject inputCase) {
        Case currentCase = (Case) inputCase;
        String accountId = currentCase.AccountId;
        String contactId = currentCase.SecondaryContact__c;
        HDT_QR_AccountContactRelation queryHandler = new HDT_QR_AccountContactRelation();
        List<AccountContactRelation> currentAcr = queryHandler.getSolContactRelation(accountId, contactId);
        if (!currentAcr.isEmpty()) {
            AccountContactRelation solAcr = currentAcr[0];
            solAcr.IsActive = True;
            HDT_UTL_DatabaseService.updateSObject(solAcr);
        } else {
            AccountContactRelation solAcr = new AccountContactRelation();
            solAcr.AccountId = accountId;
            solAcr.ContactId = contactId;
            solAcr.IsActive = True;
            solAcr.IsManagerSOL__c = True;
            solAcr.Roles = 'Referente SOL-APP';
            HDT_UTL_DatabaseService.insertSObject(solAcr);
        }
    }

    public void setContractAccountCode(SObject inputCase)
    {
        Case currentCase = (Case) inputCase;
        List<BillingProfile__c> billingProfiles = [SELECT Id,ContractAccountCode__c FROM BillingProfile__c WHERE Id = :currentCase.BillingProfile__c WITH SECURITY_ENFORCED];
        if(!billingProfiles.isEmpty())
        {
            currentCase.ContractAccountCode__c = billingProfiles[0].ContractAccountCode__c;
        }
    }

    public void advanceInstallmentPlan(SObject inputCase)
    {
        Case currentCase = (Case) inputCase;
        if(currentCase.TypeInstallmentPlan__c.equalsIgnoreCase('Personalizzato') && (currentCase.InstallmentNumberRequired__c > 3 || currentCase.AmountToPayInInstallments__c > 2000 || currentCase.Reason__c.containsIgnoreCase('Disoccupato/Cassintegrato')))
        {
            currentCase.Phase__c = 'Attesa Modulo Firmato';
        }
    }

    public void handleSelfReadings(SObject inputCase)
    {
        Set<String> fasiKo = new Set<String>{'Annullato', 'Validazione KO da DL', 'Esito KO da DBO'};
        Set<String> fasiOk = new Set<String>{'Validazione OK da DL', 'Validazione OK DL simulata', 'Esito OK da DBO'};
        Case currentCase = (Case) inputCase;
        
        try {
            if(currentCase.ParentId != null){
                Case parentCase = [SELECT Id, Type, Subprocess__c FROM Case where Id =: currentCase.ParentId WITH SECURITY_ENFORCED LIMIT 1];
                if('Errore Stima Consumi'.equals(parentCase.Subprocess__c) && fasiKo.contains(currentCase.Phase__c)){
                    HDT_UTL_Case.createActivity(currentCase.Id, '', 'CBS_CRP002__CONTATTARE_IL_CLIENTE_POSTSALES', 'Contattare il cliente');
                }else if('Errore Stima Consumi'.equals(parentCase.Subprocess__c) && fasiOk.contains(currentCase.Phase__c)){
                    parentCase.Phase__c = 'Da Inviare';
                    update parentCase;
                }
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.DEBUG,'Exception--> '+e.getMessage());
        }
    }

    //metodo che aggiorna le unità abitative su SP al completamento del case di Modifica unità immobiliari - Acqua
    @SuppressWarnings('PMD.ApexCRUDViolation')
    public void handleUpdateUnitServicePoint(SObject inputCase){
        Case currentCase = (Case) inputCase;

        if(!String.isBlank(currentCase.ServicePoint__c) && 'Modifica Unita Immobiliari Componenti'.equalsIgnoreCase(currentCase.Type) && ('Acqua'.equalsIgnoreCase(currentCase.Commodity__c) || 'Acqua'.equalsIgnoreCase(currentCase.CommodityFormula__c))){
            try {
                ServicePoint__c sp = [SELECT NotDomesticHousingUnit__c, NotResidentDomesticHousingUnit__c, ResidentDomesticHousingUnit__c, CommercialHousingUnit__c FROM ServicePoint__c WHERE Id =: currentCase.ServicePoint__c WITH SECURITY_ENFORCED];
                if(sp != null && !'ACDOMRESP0'.equalsIgnoreCase(currentCase.RateCategory__c)){
                    sp.NotDomesticHousingUnit__c = currentCase.Unita_Abitative__c;
                    sp.NotResidentDomesticHousingUnit__c = currentCase.NotResidentDomesticHousingUnit__c;
                    sp.ResidentDomesticHousingUnit__c = currentCase.ResidentDomesticHousingUnit__c;
                    sp.NumberOfFamilyMembers__c = currentCase.ResidentMembers__c;
                    sp.CommercialHousingUnit__c = currentCase.CommercialHousingUnit__c;
                    update sp;
                }else if (sp != null && 'ACDOMRESP0'.equalsIgnoreCase(currentCase.RateCategory__c)){
                    sp.NumberOfFamilyMembers__c = currentCase.ResidentMembers__c;
                    update sp;
                }
            } catch (Exception e) {
                System.debug(LoggingLevel.DEBUG, 'Throwed Exception: ' + e.getStackTraceString());
            }
            
        }
    }

    //metodo che gestisce la creazione di una activity per una determinata casistica del processo di Modifica Unità Immobiliari Acqua
    @SuppressWarnings('PMD.ApexCRUDViolation, PMD.CyclomaticComplexity')
    public void handleCreazioneActivityVariazioni(SObject inputCase){
        Case currentCase = (Case) inputCase;
        try {
            if('Modifica Unita Immobiliari Componenti'.equalsIgnoreCase(currentCase.Type) &&('Acqua'.equalsIgnoreCase(currentCase.Commodity__c) || 'Acqua'.equalsIgnoreCase(currentCase.CommodityFormula__c))){
                if(!'ACDOMRESP0'.equalsIgnoreCase(currentCase.RateCategory__c)){ //in caso di Promiscuo faccio il check di variazione totale unità abitative
                    ServicePoint__c sp = [SELECT NotDomesticHousingUnit__c, NotResidentDomesticHousingUnit__c, ResidentDomesticHousingUnit__c FROM ServicePoint__c WHERE Id =: currentCase.ServicePoint__c WITH SECURITY_ENFORCED];
                    if(sp != null){
                        Integer spUnitDomRes = (sp.ResidentDomesticHousingUnit__c != null) ? Integer.valueOf(sp.ResidentDomesticHousingUnit__c) : 0;
                        Integer spUnitDomNonRes = (sp.NotResidentDomesticHousingUnit__c != null) ? Integer.valueOf(sp.NotResidentDomesticHousingUnit__c) : 0;
                        Integer caseUnitDomRes = (currentCase.ResidentDomesticHousingUnit__c != null) ? Integer.valueOf(currentCase.ResidentDomesticHousingUnit__c) : 0;
                        Integer caseUnitDomNonRes = (currentCase.NotResidentDomesticHousingUnit__c != null) ? Integer.valueOf(currentCase.NotResidentDomesticHousingUnit__c) : 0;
        
                        Integer totaleUnitServicePoint = spUnitDomRes + spUnitDomNonRes;
                        Integer totaleUnitCase = caseUnitDomRes + caseUnitDomNonRes;
                        if(totaleUnitServicePoint != totaleUnitCase){
                            HDT_UTL_Case.createActivity(currentCase.Id, '', 'Elaborazione Manuale', 'Elaborazione Manuale');
                        }else{ //se non viene variato il totale delle unità abitative, alla ricezione dell'Esito OK da DBO imposto fase Completata
                            currentCase.Phase__c = 'Completata';
                            currentCase.Status = 'Closed';
                            updateFuture(JSON.serialize(currentCase));
                        }
                    }
                }else{ //in caso di Domestico alla ricezione dell'Esito OK da DBO imposto fase Completata
                    currentCase.Phase__c = 'Completata';
                    currentCase.Status = 'Closed';
                    updateFuture(JSON.serialize(currentCase));
                }
            }else if ('Esenzione Modifica Fognatura Depurazione'.equalsIgnoreCase(currentCase.Type) && 'Modifica Fognatura e Depurazione'.equalsIgnoreCase(currentCase.Subprocess__c) && ('Acqua'.equalsIgnoreCase(currentCase.Commodity__c) || 'Acqua'.equalsIgnoreCase(currentCase.CommodityFormula__c)) && 'Esito OK da DBO'.equalsIgnoreCase(currentCase.Phase__c)){
                //BBP W2 4.0 pg. 601 - Creazione Activity Gestione Rimborso in caso di Esito Positivo e Data Retroattiva valorizzata
                if(currentCase.RetroactiveDate__c != null) {
                    HDT_UTL_Case.createActivity(currentCase.Id, '', 'Gestione Rimborso', 'Gestione Rimborso');
                }else{
                    currentCase.Phase__c = 'Completata';
                    currentCase.Status = 'Closed';
                    updateFuture(JSON.serialize(currentCase));
                }
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.DEBUG, 'Throwed Exception: ' + e.getStackTraceString());
        }
    }

    @SuppressWarnings('PMD.ApexCRUDViolation')
    public void handleChiusuraActivitiesPending(SObject inputCase){
        Case currentCase = (Case) inputCase;

        try {
            if ('Ricostruzione Consumi'.equalsIgnoreCase(currentCase.Type) && 'Acqua'.equalsIgnoreCase(currentCase.Commodity__c)) {
                List<wrts_prcgvr__Activity__c> actToCloseList = [SELECT Id, wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c WHERE Case__c =: currentCase.Id AND wrts_prcgvr__Status__c <> 'Chiusa'];
                List<wrts_prcgvr__Activity__c> actToUpdate = new List<wrts_prcgvr__Activity__c>();
                if(actToCloseList.size() > 0){
                    for (wrts_prcgvr__Activity__c act : actToCloseList){
                        act.wrts_prcgvr__Status__c = 'Chiusa';
                        actToUpdate.add(act);
                    }
    
                    update actToUpdate;
                }
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.DEBUG, 'Throwed Exception: ' + e.getStackTraceString());
        }
        
    }

    @Future
    private static void updateFuture(String serializedCase)
    {
        Case currentCase  = (Case) JSON.deserialize(serializedCase, Case.class);
        HDT_UTL_DatabaseService.updateSobject(currentCase);
    }
    public void closeCaseLetturaInseritaInSap(SObject inputCase){

        Case currentCase = (Case) inputCase;

        currentCase.Phase__c = 'Completata';
        currentCase.Status = 'Closed';

        HDT_UTL_DatabaseService.updateSObject(currentCase);

    }
}