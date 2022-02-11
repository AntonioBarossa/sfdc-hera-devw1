public with sharing class HDT_QBL_VoltureChangeManager implements Queueable,Database.AllowsCallouts {
    private Order order;
    private HDT_QR_RecordType qrRecordType = new HDT_QR_RecordType();

    class MyException extends Exception{}
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
            newCase.Contract__c = order.ContractReference__c; 
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
        pod = order.ServicePointCode__c;
        sapContractCode = order.SapContractCode__c;

        //richiamo dataEnrichment
        try{
            newCase = dataEnrichment(pod,sapContractCode,newCase);
        }catch(Exception e){
            System.debug(LoggingLevel.DEBUG, 'Impossibile arrichire dati: ' + e.getMessage());
        }

        //creazione case
         HDT_UTL_DatabaseService.insertSObject(newCase);

        //aggiunta Codice Causale
        HDT_CausalCodeCalculation__mdt causalCodeMdt = new HDT_CausalCodeCalculation__mdt();
        causalCodeMdt = qrClass.getCausalCode(newCase.Cluster__c, newCase.Type, order.Commodity__c);
        if(causalCodeMdt != null){
            newCase.CausalCode__c = causalCodeMdt.CausalCode__c;
        }
        newCase = qrClass.getCaseRecord(newCase.Id);
        //Controllo Compatibilità
        String compatibility = '';
        try
        {
            compatibility = HDT_UTL_MatrixCompatibility.checkCompatibilityPostSales(newCase);
        }
        catch(Exception e)
        {
            System.debug(LoggingLevel.DEBUG, 'Compatibilita non superata ' + compatibility);
            newCase.Phase__c = 'Bozza Annullata';
            newCase.Status = 'Closed';
            newCase.CancellationReason__c = 'Processo incompatibile';
            HDT_UTL_DatabaseService.updateSObject(newCase);
            throw new MyException('Errore nella verifica della compatibilita'); 
        }
        //Check Compatibility Output
        if(String.isEmpty(compatibility))
        {
            System.debug(LoggingLevel.DEBUG, 'Compatibilita superata con successo ' + compatibility);
        }
        else
        {
            System.debug(LoggingLevel.DEBUG, 'Compatibilita non superata ' + compatibility);
            newCase.Phase__c = 'Bozza Annullata';
            newCase.Status = 'Closed';
            newCase.CancellationReason__c = 'Processo incompatibile';
            HDT_UTL_DatabaseService.updateSObject(newCase);
            throw new MyException('Processo Incompatibile');
        }

        //Aggiornamento case in fase "In attesa data decorrenza".
        newCase.EffectiveDate__c = HDT_UTL_Case.addBusinessDay(order.EffectiveDate__c, 3);
        newCase.SuspensionDate__c = System.today();
        newCase.SuspensionDays__c = order.EffectiveDate__c.daysBetween(newCase.SuspensionDate__c);

        newCase.Phase__c = 'In attesa Data Decorrenza';

        HDT_UTL_DatabaseService.updateSObject(newCase);

    }

    private static Case dataEnrichment(String pod, String contractCOde, Case newCase){
        String serializedResponse = HDT_WS_ArricchimentoDatiTemp.submitRequest(pod, contractCode);
        return HDT_UTL_DataEnrichmentPostSales.handleResponse(serializedResponse, newCase);
    }

    // private HDT_CausalCodeCalculation__mdt getCausalCode(String cluster, String process, String commodity){
    //     return [SELECT Id, 
    //     CausalCode__c,
    //     OperationCode__c
    //     FROM  HDT_CausalCodeCalculation__mdt
    //     WHERE Cluster__c = :cluster
    //     AND Process__c = :process
    //     AND Commodity__c = :commodity
    //     WITH SECURITY_ENFORCED
    //     LIMIT 1];
    // }
}
