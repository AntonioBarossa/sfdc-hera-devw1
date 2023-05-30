/**@frpanico 2022-09-23
 * Test Covered by HDT_WS_BpCaCreateTst
 * This class contains all logic for the BP CA Module
 * It exposes public methods that perform operations
 * To create request, rearrange Sobjects to update
 */
public with sharing class HDT_UTL_BpCaCreate
{

    private HDT_QR_BpCaCreate bpCaQuery = new HDT_QR_BpCaCreate();
    public final String SOBJ_KEY = 'sobj';
    public final String EVT_KEY = 'evt';
    /** This method simply calls the private method
     * To generate the request
     */
    public String generateRequest(Order inputOrder, String causalCode)
    {
        return generateBpCaCreateRequest(inputOrder);
    }
    public String generateRequest(Id billingId, Id accountId)
    {
        return generateBpCaCreateRequest(billingId,accountId);
    }
    /** This method is responsible of instancing Sobjects to be updated if the response is successful (Check the private method handleSobjectToUpdate)
     * Create the KO Activity if the response fails
     */
    public List<SObject> handleResponse(HttpResponse response, Order inputOrder)
    {
        List<SObject> result = new List<Order>();
        
        String bodyResponse = response.getBody();
        HDT_WRP_BpCaCreateResponse responseWrp = (HDT_WRP_BpCaCreateResponse) JSON.deserialize(bodyResponse, HDT_WRP_BpCaCreateResponse.class);

        if(responseWrp.data != null && !responseWrp.data.tipoAttivita.containsIgnoreCase('Errore'))
        {
            result = handleSobjectToUpdate(inputOrder, responseWrp);
        }
        else
        {
            String descrizioneScarto = responseWrp.data != null ? tryParse(responseWrp.data.commenti) 
                : (responseWrp.errorDetails != null && !responseWrp.errorDetails.isEmpty())? tryParse(responseWrp.errorDetails[0].message) : 'Errore Creazione BP CA';
            createActivityKo(inputOrder, descrizioneScarto);
        }

        return result;
    }
    /** This method rearrange SObjects for the update
     * The method returns a Map<String, List<Object>> where the keys are the public variables SOBJ_KEY and EVT_KEY
     * Since Account and Billing Profile need to be updated via the simple dml statement 
     * And Orders need to be updated through a Platform Event 
     * They are separated in order to be handled differently
     */
    public Map<String, List<Object>> handleUpdate(List<SObject> sobjList)
    {
        Map<String, List<Object>> result = new Map<String, List<Object>>();
        List<SObject> sobjToUpdate = new List<SObject>();
        List<HDT_PEV_VoltureChangeManagerUpdateSObj__e> platEvents = new  List<HDT_PEV_VoltureChangeManagerUpdateSObj__e>();
        for(SObject sobj : sobjList)
        {
            if(sobj.getSObjectType().getDescribe().getName().equalsIgnoreCase('Order'))
            {
                HDT_PEV_VoltureChangeManagerUpdateSObj__e evt = new HDT_PEV_VoltureChangeManagerUpdateSObj__e();
                Order newOrder = new Order();
                newOrder.Id = (Id) sobj.get('Id');
                if(sobj.get('Phase__c') != null)
                {
                    newOrder.Phase__c = (String) sobj.get('Phase__c');
                }
                if(sobj.get('CustomerCode__c') != null)
                {
                    newOrder.CustomerCode__c = (String) sobj.get('CustomerCode__c');
                }
                if(sobj.get('ContractAccountCode__c') != null)
                {
                    newOrder.ContractAccountCode__c = (String) sobj.get('ContractAccountCode__c');
                }
                evt.SerializedSobj__c = JSON.serialize(newOrder);
                platEvents.add(evt);
            }
            else
            {
                sobjToUpdate.add(sobj);
            }
        }
        if(!sobjToUpdate.isEmpty())
        {
            result.put(SOBJ_KEY, sobjToUpdate);
        }
        if(!platEvents.isEmpty())
        {
            result.put(EVT_KEY, platEvents);
        }

        return result;
    }
    /** This method generates the request
     * Queries all the information necessary to create the request from the HDT_QR_BpCaCreate class (check for field details)
     * And then starts creating the request
     * To create the request several methods have been created in order to handle every single JSONObject of the request
     */
    private String generateBpCaCreateRequest(Order inputOrder)
    {
        String result = '';
        List<Order> infoOrder = bpCaQuery.getRequestInformation(inputOrder.Id);
        if(!infoOrder.isEmpty())
        {
            HDT_WRP_BpCaVariation request = generateMainBodyRequest(infoOrder[0]);
            result = JSON.serialize(request);
        }
        System.debug('Request JSON Body ' + result);
        return result;
    }
    private String generateBpCaCreateRequest(Id billingId,Id accountId)
    {
        String result = '';
        List<BillingProfile__c> billingInfo = bpCaQuery.getBillingProfileFromId(billingId);
        if(!billingInfo.isEmpty())
        {
            HDT_WRP_BpCaVariation request = generateMainBodyRequest(billingInfo[0]);
            result = JSON.serialize(request);
        }
        System.debug('Request JSON Body ' + result);
        return result;
    }
    /* This method creates the main JSONObject of the request */
    private HDT_WRP_BpCaVariation generateMainBodyRequest(Order infoOrder)
    {
        HDT_WRP_BpCaVariation request = new HDT_WRP_BpCaVariation();
        request.numeroSR = infoOrder.ParentOrder__c;
        request.codiceCausale = '';
        request.dataCreazione = String.valueOf(System.today()).Substring(0,4)+ String.valueOf(System.today()).Substring(5,7) + String.valueOf(System.today()).Substring(8,10);
        request.cancellaBpAlternativo = '';
        request.nomeContatto = '';
        request.account = generateAccountBodyRequest(infoOrder);
        request.ordine = generateBillingProfileBodyRequest(infoOrder);

        return request;
    }
    private HDT_WRP_BpCaVariation generateMainBodyRequest(BillingProfile__c billing)
    {
        HDT_WRP_BpCaVariation request = new HDT_WRP_BpCaVariation();
        request.numeroSR = billing.Id;
        request.codiceCausale = '';
        request.dataCreazione = String.valueOf(System.today()).Substring(0,4)+ String.valueOf(System.today()).Substring(5,7) + String.valueOf(System.today()).Substring(8,10);
        request.cancellaBpAlternativo = '';
        request.nomeContatto = '';
        request.account = generateAccountBodyRequest(billing);
        request.ordine = generateBillingProfileBodyRequest(billing);

        return request;
    }
    /* This method creates the Account JSONObject of the request */
    private HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationAccount generateAccountBodyRequest(Order infoOrder)
    {
        HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationAccount request = new HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationAccount();
        request.nome = tryParse(infoOrder.Account.FirstName__c);
        request.alias = tryParse(infoOrder.Account.LastName__c);
        request.partner = tryParse(infoOrder.Account.CustomerCode__c);
        request.tipoAccount =  transcodeCustomerType(tryParse(infoOrder.Account.CustomerType__c));
        request.categoria = tryParse(infoOrder.Account.Category__c);
        request.cellulare = tryParse(infoOrder.Contact__r.MobilePhone);
        request.fax = tryParse(infoOrder.Contact__r.Fax);
        request.telefono = tryParse(infoOrder.Contact__r.Phone);
        request.email = tryParse(infoOrder.Account.PrimaryEmail__c);
        request.emailCont = tryParse(infoOrder.Contact__r.Email);
        request.marcaturaCliente = tryParse(infoOrder.Account.CustomerMarking__c);
        request.codiceFiscale = tryParse(infoOrder.Account.FiscalCode__c);
        request.partitaIva = tryParse(infoOrder.Account.VATNumber__c);
        request.modelloCA = tryParse(infoOrder.Account.Category__c);
        request.indirizzo = generateAccountAddressBodyRequest(infoOrder);
        request.gruppoIva = generateAccountVatBodyRequest(infoOrder);

        return request;
    }
    /* This method creates the Account JSONObject of the request */
    private HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationAccount generateAccountBodyRequest(BillingProfile__c billing)
    {
        HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationAccount request = new HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationAccount();
        request.nome = tryParse(billing.Account__r.FirstName__c);
        request.alias = tryParse(billing.Account__r.LastName__c);
        request.partner = tryParse(billing.Account__r.CustomerCode__c);
        request.tipoAccount =  transcodeCustomerType(tryParse(billing.Account__r.CustomerType__c));
        request.categoria = tryParse(billing.Account__r.Category__c);
        //request.cellulare = tryParse(infoOrder.Contact__r.MobilePhone);
        //request.fax = tryParse(infoOrder.Contact__r.Fax);
        //request.telefono = tryParse(infoOrder.Contact__r.Phone);
        request.email = tryParse(billing.Account__r.PrimaryEmail__c);
        //request.emailCont = tryParse(infoOrder.Contact__r.Email);
        request.marcaturaCliente = tryParse(billing.Account__r.CustomerMarking__c);
        request.codiceFiscale = tryParse(billing.Account__r.FiscalCode__c);
        request.partitaIva = tryParse(billing.Account__r.VATNumber__c);
        request.modelloCA = tryParse(billing.Account__r.Category__c);
        //request.indirizzo = generateAccountAddressBodyRequest(billing);
        //request.gruppoIva = generateAccountVatBodyRequest(billing);

        return request;
    }
    /* This method creates the body for the Account Address JSONObject */
    private HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationIndirizzo generateAccountAddressBodyRequest(Order infoOrder)
    {
        HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationIndirizzo request = new HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationIndirizzo();
        request.comune =  tryParse(infoOrder.Account.BillingCity);
        request.nazione =  tryParse(infoOrder.Account.BillingCountry?.Substring(0,2)).toUpperCase();
        request.toponimo =  '';
        request.frazione =  '';
        request.piano =  tryParse(infoOrder.Account.BuildingFloor__c);
        request.civico =  tryParse(infoOrder.Account.BillingStreetNumber__c);
        request.suffissoCivico =  tryParse(infoOrder.Account.BillingStreetNumberExtension__c);
        request.cap =  tryParse(infoOrder.Account.BillingPostalCode);
        request.provincia =  tryParse(infoOrder.Account.BillingState).substring(0,2).toUpperCase();
        request.via =  tryParse(infoOrder.Account.BillingStreetName__c);
        
        return request;
    }
    private HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationGruppoIva generateAccountVatBodyRequest(Order infoOrder)
    {
        HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationGruppoIva request = new HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationGruppoIva();
        request.adesione = transcodeVatGroupJoined(tryParse(infoOrder.Account.IsVATGroupJoined__c));
        request.partitaIva = tryParse(infoOrder.Account.VATGroup__c);
        //request.dataInizio = tryParse(infoOrder.Account.VATGroupStartDate__c);
        //request.dataFine = tryParse(infoOrder.Account.VATGroupEndDate__c);

        return request;
    }
    /* This method creates the body for the Billing Profile JSONObject*/
    private HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationOrdine generateBillingProfileBodyRequest(Order infoOrder)
    {
        HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationOrdine request = new  HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationOrdine();
        request.idOggetto = '';
        request.contoContrattuale = tryParse(infoOrder.BillingProfile__r.ContractAccountCode__c);
        request.emailInvioBolletta = tryParse(infoOrder.BillingProfile__r.InvoiceEmailAddress__c);
        //SE CREA NUOVO CA E' FALSE VIENE PASSATO IL VALORE VUOTO PERCHè SAP SE RICEVE IL TAG CON QUALSIASI VALORE LO INTERPRETA COME Y
        request.creaNuovoCA = infoOrder.BillingProfile__r.CreateContractAccount__c?'Y':'';
        request.cup = tryParse(infoOrder.BillingProfile__r.CUP__c);
        request.cig = tryParse(infoOrder.BillingProfile__r.CIG__c);
        request.pecInvioBolletta = tryParse(infoOrder.BillingProfile__r.InvoiceCertifiedEmailAddress__c);
        request.modInvioBolletta = tryParse(infoOrder.BillingProfile__r.BillSendingMethod__c);
        request.emailPec = tryParse(infoOrder.BillingProfile__r.ElectronicInvoiceCertifiedEmailAddress__c);
        request.flagAttivazPec = transcodeFlagAttivazPec(tryParse(infoOrder.BillingProfile__r.ContractAccountCode__c));
        request.datiBancari = generateBillingProfileBankBodyRequest(infoOrder);
        request.indirizzo = generateBillingProfileAddressBodyRequest(infoOrder);
        request.destinatarioDivergente = generateBillingProfileDivergenteSubjectRequest(infoOrder);
        request.fattura = generateBillingProfileFatturaRequest(infoOrder);

        return request;
    }
    /* This method creates the body for the Billing Profile JSONObject*/
    private HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationOrdine generateBillingProfileBodyRequest(BillingProfile__c billing)
    {
        HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationOrdine request = new  HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationOrdine();
        request.idOggetto = '';
        request.contoContrattuale = tryParse(billing.ContractAccountCode__c);
        request.emailInvioBolletta = tryParse(billing.InvoiceEmailAddress__c);
        //SE CREA NUOVO CA E' FALSE VIENE PASSATO IL VALORE VUOTO PERCHè SAP SE RICEVE IL TAG CON QUALSIASI VALORE LO INTERPRETA COME Y
        request.creaNuovoCA = billing.CreateContractAccount__c?'Y':'';
        request.cup = tryParse(billing.CUP__c);
        request.cig = tryParse(billing.CIG__c);
        request.pecInvioBolletta = tryParse(billing.InvoiceCertifiedEmailAddress__c);
        request.modInvioBolletta = tryParse(billing.BillSendingMethod__c);
        request.emailPec = tryParse(billing.ElectronicInvoiceCertifiedEmailAddress__c);
        request.flagAttivazPec = transcodeFlagAttivazPec(tryParse(billing.ContractAccountCode__c));
        request.datiBancari = generateBillingProfileBankBodyRequest(billing);
        request.indirizzo = generateBillingProfileAddressBodyRequest(billing);
        request.destinatarioDivergente = generateBillingProfileDivergenteSubjectRequest(billing);
        request.fattura = generateBillingProfileFatturaRequest(billing);

        return request;
    }
    /* This method creates the body for the bank information of the Billing Profile JSONObject */
    private HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationBancari generateBillingProfileBankBodyRequest(Order infoOrder)
    {
        HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationBancari request = new HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationBancari();
        request.abi = tryParse(infoOrder.BillingProfile__r.IbanABI__c);
        request.cab = tryParse(infoOrder.BillingProfile__r.IbanCAB__c);
        request.contoCorrente = tryParse(infoOrder.BillingProfile__r.IbanCodeNumber__c);
        request.codiceFiscale = tryParse(infoOrder.BillingProfile__r.BankAccountSignatoryFiscalCode__c);
        request.cin = tryParse(infoOrder.BillingProfile__r.IbanCIN__c);
        request.iban = tryParse(infoOrder.BillingProfile__r.IbanCIN_IBAN__c);
        request.cognome = tryParse(infoOrder.BillingProfile__r.BankAccountSignatoryLastName__c);
        request.nome = tryParse(infoOrder.BillingProfile__r.BankAccountSignatoryFirstName__c);
        request.terminiPagamento = tryParse(infoOrder.BillingProfile__r.PaymentConditions__c);
        request.metodoPagamento = '';//tryParse(infoOrder.BillingProfile__r.PaymentMethod__c);
        request.metodoPagamentoAlternativo = '';//tryParse(infoOrder.BillingProfile__r.IbanABI__c);
        request.banca.nazione = tryParse(infoOrder.BillingProfile__r.IbanCountry__c).toUpperCase();
        request.banca.nazione = String.isNotBlank(request.contoCorrente) && String.isBlank(request.banca.nazione)?'IT': request.banca.nazione;
        return request;
    }
    private HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationBancari generateBillingProfileBankBodyRequest(BillingProfile__c billing)
    {
        HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationBancari request = new HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationBancari();
        request.abi = tryParse(billing.IbanABI__c);
        request.cab = tryParse(billing.IbanCAB__c);
        request.contoCorrente = tryParse(billing.IbanCodeNumber__c);
        request.codiceFiscale = tryParse(billing.BankAccountSignatoryFiscalCode__c);
        request.cin = tryParse(billing.IbanCIN__c);
        request.iban = tryParse(billing.IbanCIN_IBAN__c);
        request.cognome = tryParse(billing.BankAccountSignatoryLastName__c);
        request.nome = tryParse(billing.BankAccountSignatoryFirstName__c);
        request.terminiPagamento = tryParse(billing.PaymentConditions__c);
        request.metodoPagamento = '';//tryParse(billing.PaymentMethod__c);
        request.metodoPagamentoAlternativo = '';//tryParse(billing.IbanABI__c);
        request.banca.nazione = tryParse(billing.IbanCountry__c).toUpperCase();
        request.banca.nazione = String.isNotBlank(request.contoCorrente) && String.isBlank(request.banca.nazione)?'IT': request.banca.nazione;
        return request;
    }
    /* This method creates the body for the Address information of the Billing Profile JSONObject */
    private HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationIndirizzoIndirizzoAlt generateBillingProfileAddressBodyRequest(Order infoOrder)
    {
        HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationIndirizzoIndirizzoAlt request = new HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationIndirizzoIndirizzoAlt();
        request.comune = tryParse(infoOrder.BillingProfile__r.InvoicingCity__c);
        request.nazione = tryParse(infoOrder.BillingProfile__r.InvoicingCountry__c?.Substring(0,2)).toUpperCase();
        request.piano = '';
        request.civico = tryParse(infoOrder.BillingProfile__r.InvoicingStreetNumber__c);
        request.suffissoCivico = tryParse(infoOrder.BillingProfile__r.InvoicingStreetNumberExtension__c);
        request.cap = tryParse(infoOrder.BillingProfile__r.InvoicingPostalCode__c);
        request.provincia = tryParse(infoOrder.BillingProfile__r.InvoicingProvince__c).substring(0,2).toUpperCase();
        request.via = tryParse(infoOrder.BillingProfile__r.InvoicingStreetName__c);
        request.presso = tryParse(infoOrder.BillingProfile__r.CareOf__c);

        return request;
    }
    private HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationIndirizzoIndirizzoAlt generateBillingProfileAddressBodyRequest(BillingProfile__c billing)
    {
        HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationIndirizzoIndirizzoAlt request = new HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationIndirizzoIndirizzoAlt();
        request.comune = tryParse(billing.InvoicingCity__c);
        request.nazione = tryParse(billing.InvoicingCountry__c?.Substring(0,2)).toUpperCase();
        request.piano = '';
        request.civico = tryParse(billing.InvoicingStreetNumber__c);
        request.suffissoCivico = tryParse(billing.InvoicingStreetNumberExtension__c);
        request.cap = tryParse(billing.InvoicingPostalCode__c);
        request.provincia = tryParse(billing.InvoicingProvince__c).substring(0,2).toUpperCase();
        request.via = tryParse(billing.InvoicingStreetName__c);
        request.presso = tryParse(billing.CareOf__c);

        return request;
    }
     /* This method creates the body for the Divergent Subject information of the Billing Profile JSONObject */
    private HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationDestinatarioDivergente generateBillingProfileDivergenteSubjectRequest(Order infoOrder)
    {
        HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationDestinatarioDivergente request = new HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationDestinatarioDivergente();
        if(infoOrder.BillingProfile__r.DivergentSubject__c == null)
        {
            return request;
        }
        request.nome = tryParse(infoOrder.BillingProfile__r.DivergentSubject__r.FirstName);
        request.codiceFiscale = tryParse(infoOrder.BillingProfile__r.DivergentSubject__r.FiscalCode__c);
        request.fax = tryParse(infoOrder.BillingProfile__r.DivergentSubject__r.Fax);
        request.email = tryParse(infoOrder.BillingProfile__r.DivergentSubject__r.Email);
        request.partitaIva = tryParse(infoOrder.BillingProfile__r.DivergentSubject__r.VATNumber__c);
        request.telefono = transcodeDivergentSubjectPhone(tryParse(infoOrder.BillingProfile__r.DivergentSubject__r.MobilePhone), tryParse(infoOrder.BillingProfile__r.DivergentSubject__r.Phone)); 
        request.idIntegrazione = tryParse(infoOrder.BillingProfile__r.DivergentSubject__r.ContactCode__c);
        request.cognome = tryParse(infoOrder.BillingProfile__r.DivergentSubject__r.LastName);
        request.indirizzo = generateBillingProfileDivergenteSubjectAddressRequest(infoOrder);

        return request;
    }
    private HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationDestinatarioDivergente generateBillingProfileDivergenteSubjectRequest(BillingProfile__c billing)
    {
        HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationDestinatarioDivergente request = new HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationDestinatarioDivergente();
        if(billing.DivergentSubject__c == null)
        {
            return request;
        }
        request.nome = tryParse(billing.DivergentSubject__r.FirstName);
        request.codiceFiscale = tryParse(billing.DivergentSubject__r.FiscalCode__c);
        request.fax = tryParse(billing.DivergentSubject__r.Fax);
        request.email = tryParse(billing.DivergentSubject__r.Email);
        request.partitaIva = tryParse(billing.DivergentSubject__r.VATNumber__c);
        request.telefono = transcodeDivergentSubjectPhone(tryParse(billing.DivergentSubject__r.MobilePhone), tryParse(billing.DivergentSubject__r.Phone)); 
        request.idIntegrazione = tryParse(billing.DivergentSubject__r.ContactCode__c);
        request.cognome = tryParse(billing.DivergentSubject__r.LastName);
        request.indirizzo = generateBillingProfileDivergenteSubjectAddressRequest(billing);

        return request;
    }
     /* This method creates the body for the Divergent Subject Address information of the Billing Profile JSONObject */
    private HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationIndirizzoIndirizzoAlt generateBillingProfileDivergenteSubjectAddressRequest(Order infoOrder)
    {
        HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationIndirizzoIndirizzoAlt request = new HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationIndirizzoIndirizzoAlt();
        request.comune = tryParse(infoOrder.BillingProfile__r.DivergentSubject__r.MailingCity);
        request.nazione = tryParse(infoOrder.BillingProfile__r.DivergentSubject__r.MailingCountry?.Substring(0,2)).toUpperCase();
        request.piano = '';
        request.civico = tryParse(infoOrder.BillingProfile__r.DivergentSubject__r.MailingStreetNumber__c);
        request.suffissoCivico = tryParse(infoOrder.BillingProfile__r.DivergentSubject__r.MailingStreetNumberExtension__c);
        request.cap = tryParse(infoOrder.BillingProfile__r.DivergentSubject__r.MailingPostalCode);
        request.provincia = tryParse(infoOrder.BillingProfile__r.DivergentSubject__r.MailingState).substring(0,2).toUpperCase();
        request.via = tryParse(infoOrder.BillingProfile__r.DivergentSubject__r.MailingStreetName__c);
        request.comune = '';

        return request;
    }
    private HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationIndirizzoIndirizzoAlt generateBillingProfileDivergenteSubjectAddressRequest(BillingProfile__c billing)
    {
        HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationIndirizzoIndirizzoAlt request = new HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationIndirizzoIndirizzoAlt();
        request.comune = tryParse(billing.DivergentSubject__r.MailingCity);
        request.nazione = tryParse(billing.DivergentSubject__r.MailingCountry?.Substring(0,2)).toUpperCase();
        request.piano = '';
        request.civico = tryParse(billing.DivergentSubject__r.MailingStreetNumber__c);
        request.suffissoCivico = tryParse(billing.DivergentSubject__r.MailingStreetNumberExtension__c);
        request.cap = tryParse(billing.DivergentSubject__r.MailingPostalCode);
        request.provincia = tryParse(billing.DivergentSubject__r.MailingState).substring(0,2).toUpperCase();
        request.via = tryParse(billing.DivergentSubject__r.MailingStreetName__c);
        request.comune = '';

        return request;
    }
     /* This method creates the body for the Billing information of the Billing Profile JSONObject */
    private HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationFattura generateBillingProfileFatturaRequest(Order infoOrder)
    {
        HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationFattura request = new HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationFattura();
        request.codiceUfficio = tryParse(infoOrder.BillingProfile__r.SubjectCode__c);
        request.fatturaXml = transcodeFatturaXml(tryParse(infoOrder.BillingProfile__r.XMLType__c));
        request.mailPec = tryParse(infoOrder.BillingProfile__r.ElectronicInvoiceCertifiedEmailAddress__c);
        request.modello = transcodeModelloFattura(tryParse(infoOrder.BillingProfile__r.ElectronicInvoicingMethod__c));

        return request;

    }
    private HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationFattura generateBillingProfileFatturaRequest(BillingProfile__c billing)
    {
        HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationFattura request = new HDT_WRP_BpCaVariation.HDT_WRP_BpCaVariationFattura();
        request.codiceUfficio = tryParse(billing.SubjectCode__c);
        request.fatturaXml = transcodeFatturaXml(tryParse(billing.XMLType__c));
        request.mailPec = tryParse(billing.ElectronicInvoiceCertifiedEmailAddress__c);
        request.modello = transcodeModelloFattura(tryParse(billing.ElectronicInvoicingMethod__c));

        return request;

    }
    /* This method allow to safely parse into string fields passed to create the request */
    private String tryParse(Object field)
    {
        return field != null ? String.valueOf(field) : '';
    }
    /* Custom transcodification: Since on the Org the picklist value has been created as "Persona Fisica" 
    * while the web service requires "Persona fisica" 
    * a transcondification is necessary 
    */
    private String transcodeCustomerType(String customerType)
    {
        return customerType.equalsIgnoreCase('Persona Fisica') ? 'Persona fisica' : customerType;
    }
    /* Custom transcodification: Since on the Org the picklist value has been created as Boolean
    * while the web service requires 1 (if true) or blank 
    * a transcondification is necessary 
    */
    private String transcodeVatGroupJoined(String vatGroupJoined)
    {
        return vatGroupJoined.equalsIgnoreCase('true') ? '1' : '';
    }
    /* Custom transcodification: Since on the Org the picklist value has been created as Boolean
    * while the web service requires 'true' or blank 
    * a transcondification is necessary 
    */
    private String transcodeFlagAttivazPec(String flagAttivazPec)
    {
        return flagAttivazPec.equalsIgnoreCase('true') ? flagAttivazPec : '';
    }
    /* Custom transcodification: Since the web service accepts only one phone number field
    * it is necessary to discrimantes which one to send between mobilephone and phone
    * with priority to mobilephone 
    */
    private String transcodeDivergentSubjectPhone(String mobilePhone, String phone)
    {
        return String.isNotBlank(mobilePhone) ? mobilePhone : phone;
    }
    /* Custom transcodification: Since on the Org the picklist value has been created with readable values
    * while the web service requires a code 
    * a transcondification is necessary 
    */
    private String transcodeFatturaXml(String fatturaXml)
    {
        if(String.isBlank(fatturaXml))
        {
            return '';
        }
        switch on fatturaXml {
            when 'Sintetico' 
            {
                return 'S';
            }
            when 'Dettaglio'
            {   
                return 'A';
            }
            when else 
            {
                return '';
            }
        }
    }
    /* Custom transcodification: Since on the Org the picklist value has been created with readable values
    * while the web service requires a code 
    * a transcondification is necessary 
    */
    private String transcodeModelloFattura(String modello)
    {
        if(String.isBlank(modello))
        {
            return '';
        }
        switch on modello {
            when 'XML'{
                return '01';
            }
            when 'XML PA'{
                return '02';
            }
            when 'XML + carta/email'{
                return '03';
            }
            when 'Estero'{
                return '04';
            }
            when else{
                return '';
            }
        }
    }
    /** This method instances the sobject to be update
     * based on the input order and the result of the web service integration
     */
    private List<SObject> handleSobjectToUpdate(Order inputOrder, HDT_WRP_BpCaCreateResponse response)
    {
        List<SObject> result = new List<SObject>();
        Order orderToUpdate = new Order(Id = inputOrder.Id);
        /* If the customer code is blank the account needs to be updated */
        if(inputOrder.CustomerCode__c == null)
        {
            orderToUpdate.CustomerCode__c = response.data.codiceBP;
            orderToUpdate.ContractAccountCode__c = response.data.codiceContatto;
            orderToUpdate.Phase__c = inputOrder.ProcessType__c.equalsIgnoreCase('Voltura') ? 'Documentazione Validata' : 'Comunicazione verso Heroku';
            Account accountToUpdate = new Account(Id = inputOrder.AccountId, CustomerCode__c = response.data.codiceBP);
            BillingProfile__c billingProfileToUpdate = new BillingProfile__c(Id = inputOrder.BillingProfile__c, ContractAccountCode__c = response.data.codiceContatto);
            result.add(accountToUpdate);
            result.add(billingProfileToUpdate);
            result.add(orderToUpdate);
        }
        /* Otherwise only the Billing Profile needs to be updated */
        else
        {
            orderToUpdate.ContractAccountCode__c = response.data.codiceContatto;
            orderToUpdate.Phase__c = inputOrder.ProcessType__c.equalsIgnoreCase('Voltura') ? 'Documentazione Validata' : 'Comunicazione verso Heroku';
            BillingProfile__c billingProfileToUpdate = new BillingProfile__c(Id = inputOrder.BillingProfile__c, ContractAccountCode__c = response.data.codiceContatto);
            result.add(billingProfileToUpdate);
            result.add(orderToUpdate);
        }
        /* Other orders in progress with same Account and Billing Profile which have CustomerCode and ContractAccount fields blank need to be updated */
        List<Order> otherChildOrders = bpCaQuery.getOtherOrdersToUpdate(inputOrder.Id, inputOrder.Sale__c, inputOrder.BillingProfile__c);
        for(Order otherChild : otherChildOrders)
        {
            Order otherChildToUpdate = new Order(Id = otherChild.Id);
            if(otherChild.CustomerCode__c == null)
            {
                otherChildToUpdate.CustomerCode__c = orderToUpdate.CustomerCode__c;
            }
            if(otherChild.ContractAccountCode__c == null)
            {
                otherChildToUpdate.ContractAccountCode__c = orderToUpdate.ContractAccountCode__c;
            }
            result.add(otherChildToUpdate);
        }

        return result;
    }
    /* This method creates the discard activity in case of integration failure or negative response */
    private void createActivityKo(Order inputOrder, String descrizioneScarto)
    {
        wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();
        activity.wrts_prcgvr__Status__c = 'Aperta';
        activity.Account__c = inputOrder.AccountId;
        activity.Order__c = inputOrder.Id;
        activity.ActivityStartTime__c = System.now();
        activity.Type__c = 'KO creazione BP CA';
        activity.DiscardCategory__c = 'Manuale';
        activity.DiscardDescription__c = descrizioneScarto.abbreviate(250);
        activity.wrts_prcgvr__Description__c = descrizioneScarto.abbreviate(250);

        HDT_UTL_DatabaseService.insertSObject(activity);

        return;
    }
    public String executeRequest(String body){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        String result = '';
        try
        {
            request.setHeader('Accept','application/json');
            request.setHeader('Content-Type','application/json');
            request.setEndpoint('Callout:MulesoftBasePath/customer-data/billing-profile');
            request.setMethod('POST');
            request.setBody(body);
            request.setTimeout(120000);
            response = http.send(request);
            result = response.getBody();
        }catch(CalloutException ex){
            result = '';
        }
        return result;
    }

    public String handleResponse(String bodyResponse){
        HDT_WRP_BpCaCreateResponse responseWrp = (HDT_WRP_BpCaCreateResponse) JSON.deserialize(bodyResponse, HDT_WRP_BpCaCreateResponse.class);
        if(responseWrp.data != null){
            return JSON.serialize(responseWrp.data);
        }else {
            HDT_WRP_Data data = new HDT_WRP_Data();
            data.commenti = responseWrp.errorDetails[0].message;
            return JSON.serialize(data);
        }
    }
    public void updateBillingProfile(String dataString, Id billingId){
        HDT_WRP_Data data =  (HDT_WRP_Data) JSON.deserialize(dataString,HDT_WRP_Data.class);
        if(String.isNotBlank(data.codiceContatto)){
            BillingProfile__c bp = new BillingProfile__c(Id=billingId,ContractAccountCode__c=data.codiceContatto);
            update bp;
        }
    }
    public void updateAccount(String dataString, Id accountId){
        HDT_WRP_Data data =  (HDT_WRP_Data) JSON.deserialize(dataString,HDT_WRP_Data.class);
        if(String.isNotBlank(data.codiceBP)){
            Account acc = new Account(Id=accountId,CustomerCode__c=data.codiceBP);
            update acc;
        }
    }
    /* Wrapper Object for the Web Service Response */
    public class HDT_WRP_BpCaCreateResponse
    {
        public String status {get; set;}
        public String correlationId {get; set;}
        public String timestamp {get; set;}
        public List<HDT_WRP_ErrorDetails> errorDetails {get; set;}
        public HDT_WRP_Data data {get; set;}
    }

    public class HDT_WRP_ErrorDetails
    {
        public String code {get; set;}
        public String message {get; set;}
        public String additionalInfo {get; set;}
    }
    public class HDT_WRP_Data
    {
        public String rdo {get;set;}
        public String codiceCausale {get;set;}
        public String codiceContatto {get;set;}
        public String codiceBPAlternativo {get;set;}
        public String rds {get;set;}
        public String tipoAttivita {get;set;}
        public String commenti {get;set;}
        public String codiceBP {get;set;}
        public String esito {get;set;}
    }
}