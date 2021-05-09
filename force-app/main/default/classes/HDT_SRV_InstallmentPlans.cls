public inherited sharing class HDT_SRV_InstallmentPlans {

    HDT_QR_InstallmentPlans installmentsQr = new HDT_QR_InstallmentPlans();

    @InvocableMethod(label = 'Predefault valori pianoRate')
    public static void predefaultInstallmentsValues(List<HDT_UTL_FlowInputs> inputs){

        HDT_QR_InstallmentPlans installmentsQr = new HDT_QR_InstallmentPlans();

        List<HDT_SRV_AccountInstallmentsCheck.HDT_SRV_AccountInstallmentsCheckInput> inputsCheck = 
            new List<HDT_SRV_AccountInstallmentsCheck.HDT_SRV_AccountInstallmentsCheckInput>();
        HDT_SRV_AccountInstallmentsCheck.HDT_SRV_AccountInstallmentsCheckInput inputCheck = 
            new HDT_SRV_AccountInstallmentsCheck.HDT_SRV_AccountInstallmentsCheckInput();
        List<HDT_SRV_AccountInstallmentsCheck.HDT_SRV_AccountInstallmentsCheckOutput> outputs = 
            new List<HDT_SRV_AccountInstallmentsCheck.HDT_SRV_AccountInstallmentsCheckOutput>();

        Case currentCase = new Case();

        String recordId = inputs[0].recordId;
        String accountId = inputs[0].accountId;
        String customerCode = inputs[0].customerCode;
        Decimal totalToPay = inputs[0].totalToPay; 

        currentCase.Id = recordId;

        inputCheck.customerCode = customerCode;

        inputsCheck.add(inputCheck);
        
        //Lookup for cases 'Sospensione Fornitura' with same Account and completed
        if(installmentsQr.getSuspensionCaseByAccountId(accountId).size() > 0){

            currentCase.SuspensionInThePastTwelveMonths__c = true;

        }else{
            
            currentCase.SuspensionInThePastTwelveMonths__c = false;

        }

        //Callout 'Vista Rate' to calculate installmentPlansUnpaid
        outputs = HDT_SRV_AccountInstallmentsCheck.execute(inputsCheck);
        currentCase.ExistingInstallmentsPlanNumber__c = outputs[0].existingInstallmentPlanUnpaid;

        //Set AmountToPayInstallments to TotalPay
        currentCase.AmountToPayInInstallments__c = totalToPay;

        HDT_UTL_DatabaseService.updateSObject(currentCase);

    }

    public String createRequestBody(String recordId){

        List<DocumentSelected__c> documents = new List<DocumentSelected__c>();
        Case currentCase = new Case();
        String pretty;

        currentCase = installmentsQr.getCaseById(recordId);
        documents = installmentsQr.getDocumentSelectedByCase(recordId);

        JSONGenerator gen = JSON.createGenerator(true);

        gen.writeStartObject();
        gen.writeStringField('numeroSR', currentCase.CaseNumber);
        gen.writeStringField('tipoPiano', currentCase.TypeInstallmentPlan__c);
        gen.writeNumberField('totale', currentCase.AmountToPayInInstallments__c);
        gen.writeStringField('numeroRata', currentCase.InstallmentPlanNumber__c);
        gen.writeDateField('dataInizio', currentCase.FirstExpirationDate__c);
        gen.writeBooleanField('acconto', currentCase.Deposit__c);
        gen.writeBooleanField('contestazioneCliente', currentCase.ApplicationInterests__c);
        gen.writeStringField('modalitaPagamentoAcconto', currentCase.DepositPaymentMode__c);
        gen.writeFieldName('documenti');
        gen.writeStartArray();
        for(DocumentSelected__c document : documents){ 
            gen.writeStartObject();
            gen.writeStringField('numeroBollettino', '');
            gen.writeStringField('numeroDocumetno', document.DocumentNumber__c.startsWith('0') ? '' : document.DocumentNumber__c);
            gen.writeStringField('numeroFatturaRata',document.DocumentNumber__c.startsWith('0') ? document.DocumentNumber__c : '');
            gen.writeDateField('scadenzaRata',document.ExpirationDate__c);
            gen.writeStringField('tipoDocumento',document.Type__c);
            gen.writeEndObject();
        }
        gen.writeEndArray();
        gen.writeStringField('pianoPersonalizzato','');
        gen.writeEndObject();

        pretty = gen.getAsString();

        System.debug('SRV_InstallmentPlans -->' +pretty);

        return pretty;
    }


    public class HDT_UTL_FlowInputs{

        @InvocableVariable
        public String recordId;

        @InvocableVariable
        public String accountId;

        @InvocableVariable
        public String customerCode;

        @InvocableVariable
        public Decimal totalToPay;


    }


}
