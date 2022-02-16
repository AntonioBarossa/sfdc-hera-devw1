public with sharing class HDT_QBL_VoltureChangeManager implements Queueable,Database.AllowsCallouts {
    private Order order;
    private HDT_QR_RecordType qrRecordType = new HDT_QR_RecordType();

    class HDT_UTL_CustomException  extends Exception{}
    public HDT_QBL_VoltureChangeManager(Order ord) {
        this.order = ord;
    }

    public void execute(QueueableContext context) {
        
        Case newCase = new Case();
        HDT_QR_HerokuPostSalesManager qrClass = new HDT_QR_HerokuPostSalesManager();
        string pod = '';
        string sapContractCode = '';

        newCase.AccountId = order.AccountId;
        newCase.Cluster__c = 'Voltura';
        newCase.CompanyOwner__c = order.CompanyOwner__c;
        newCase.ContactId = order.Contact__c;
        if(order.ContractReference__c != null)
        {
            newCase.Contract__c = order.ContractReference__c;
        }
        newCase.CreatorGroup__c = order.CreatorGroup__c;
        newCase.DistributorNote__c = order.PhoneNumber__c;
        newCase.Origin = order.Channel__c;
        newCase.Order__c = order.Id;
        newCase.Phase__c = 'Bozza';
        newCase.RecordTypeId = qrRecordType.getRecordTypeIdByName('HDT_RT_VolturaTecnica');
        newCase.ServicePoint__c = order.ServicePoint__c;
        newCase.Station__c = Order.LoginWorkstation__c;
        newCase.Type = 'Voltura Tecnica';
        newCase.PhoneNumber__c = order.PhoneNumber__c;
        newCase.Email__c = order.Email__c;
        newCase.BillingProfile__c = order.BillingProfile__c;
        newCase.SupplyCity__c = order.SupplyCity__c;
        newCase.SupplyCityCode__c= order.SupplyCityCode__c; 
        newCase.SupplyCountry__c = order.SupplyCountry__c;
        newCase.SupplyPostalCode__c= order.SupplyPostalCode__c;
        newCase.SupplyProvince__c= order.SupplyState__c;
        newCase.SupplyStreetName__c= order.SupplyStreetName__c;
        newCase.SupplyStreetNumber__c= order.SupplyStreetNumber__c;
        newCase.InvoicingCity__c = order.BillingCity__c;
        newCase.InvoicingCityCode__c = order.BillingCityCode__c;
        newCase.InvoicingCountry__c = order.BillingCountry__c;
        newCase.InvoicingPostalCode__c = order.BillingPostalCode__c;
        newCase.InvoicingProvince__c = order.BillingProvince__c;
        newCase.InvoicingStreetName__c = order.BillingStreetName__c;
        newCase.InvoicingStreetNumber__c = order.BillingStreetName__c;
        newCase.BillingCity__c = order.ResidentialCity__c;
        newCase.BillingCityCode__c = order.ResidentialCityCode__c;
        newCase.BillingCountry__c = order.ResidentialCountry__c;
        newCase.BillingPostalCode__c = order.ResidentialPostalCode__c;
        newCase.BillingProvince__c = order.ResidentialState__c;
        newCase.BillingStreetName__c = order.ResidentialStreet__c;
        newCase.BillingStreetNumber__c = order.ResidentialStreetName__c;
        newCase.SalesCompany__c = order.SalesCompany__c;
        newCase.SalesCompanyCode__c = order.SalesCompanyCode__c;
        newCase.DistributorCode__c = order.DistributorCode__c;
        newCase.Taxes__c = order.ExciseGAS__c;
        newCase.TaxRate__c = order.VAT__c;
        newCase.Resident__c = order.Resident__c;
        newCase.Market__c = order.Market__c;
        newCase.SupplyType__c = order.SupplyType__c;
        newCase.AnnualConsumption__c = order.AnnualConsumption__c;
        newCase.CaliberAvailable__c = order.Caliber__c;

        pod = order.ServicePointCode__c;
        sapContractCode = order.SapContractCode__c;

        //richiamo dataEnrichment
        try{
            newCase = dataEnrichment(pod,sapContractCode,newCase);
        }catch(Exception e){
            System.debug(LoggingLevel.DEBUG, 'Impossibile arrichire dati: ' + e.getMessage());
        }

        //aggiunta Codice Causale
        HDT_CausalCodeCalculation__mdt causalCodeMdt = new HDT_CausalCodeCalculation__mdt();
        causalCodeMdt = qrClass.getCausalCode(newCase.Cluster__c, newCase.Type, order.Commodity__c);
        if(causalCodeMdt != null){
            newCase.CausalCode__c = causalCodeMdt.CausalCode__c;
            system.debug('newCase CausalCode 1--> '+newCase.CausalCode__c);
        }

        //creazione case
        HDT_UTL_DatabaseService.insertSObject(newCase);

        newCase = qrClass.getCaseRecord(newCase.Id);
        system.debug('newCase CausalCode 2--> '+newCase.CausalCode__c);
        //Controllo Compatibilità
        String compatibility = '';
        try
        {
            compatibility = HDT_UTL_MatrixCompatibility.checkCompatibilityPostSales(newCase);
        }
        catch(Exception e)
        {
            errorCompatibility(newCase, 'Errore nella verifica della compatibilita', compatibility);
        }
        //Check Compatibility Output
        if(!String.isEmpty(compatibility))
        {
            errorCompatibility(newCase, 'Processo Incompatibile', compatibility);
        }
        //Aggiornamento case in fase "In attesa data decorrenza".
        newCase.EffectiveDate__c = HDT_UTL_Case.addBusinessDay(order.EffectiveDate__c, 3);
        newCase.SuspensionDate__c = System.today();
        newCase.SuspensionDays__c = newCase.SuspensionDate__c.daysBetween(order.EffectiveDate__c);

        newCase.Phase__c = 'In attesa Data Decorrenza';

        HDT_UTL_DatabaseService.updateSObject(newCase);

    }

    private static Case dataEnrichment(String pod, String contractCOde, Case newCase){
        String serializedResponse = HDT_WS_ArricchimentoDatiTemp.submitRequest(pod, contractCode);
        return HDT_UTL_DataEnrichmentPostSales.handleResponse(serializedResponse, newCase);
    }

    private void errorCompatibility(Case caseToUpdate, String errorMessage, String compatibility){

        System.debug(LoggingLevel.DEBUG, 'Compatibilita non superata ' + compatibility);
        caseToUpdate.Phase__c = 'Bozza Annullata';
        caseToUpdate.Status = 'Closed';
        caseToUpdate.CancellationReason__c = 'Processo incompatibile';
        HDT_UTL_DatabaseService.updateSObject(caseToUpdate);
        throw new HDT_UTL_CustomException (errorMessage); 
    }
}
