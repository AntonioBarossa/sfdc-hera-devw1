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
        SObject objToUpdate = null;

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

                Account acc = new Account();
                acc.Id = currentCase.AccountId;
                acc.CustomerMarking__c = currentCase.CustomerMarking__c;
                HDT_UTL_DatabaseService.updateSObject(acc);
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
                objToUpdate = bp;
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

    public void sbloccoVoltura(SObject inputCase){

        Case currentCase = (Case) inputCase;

        wrts_prcgvr__Activity__c activity = createActivity('Sblocco Voltura');
        if(currentCase.VulturePracticeReference__c != null){
            //wrts_prcgvr__Activity__c activity = createActivity('Sblocco Voltura');
            activity.Order__c = currentCase.VulturePracticeReference__c;
            //HDT_UTL_DatabaseService.insertSObject(activity);
        }
        HDT_UTL_DatabaseService.insertSObject(activity);

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

    public void submitForApproval(SObject inputCase)
    {
        Case currentCase = (Case) inputCase;
        System.enqueueJob(new HDT_QBL_VoltureChangeManager(new List<Case>{currentCase}));
    }

    @Future
    private static void updateFuture(String serializedCase)
    {
        Case currentCase  = (Case) JSON.deserialize(serializedCase, Case.class);
        HDT_UTL_DatabaseService.updateSobject(currentCase);
    }

}