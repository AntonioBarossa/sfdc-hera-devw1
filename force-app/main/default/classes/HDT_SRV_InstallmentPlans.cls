@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_SRV_InstallmentPlans {

    HDT_QR_InstallmentPlans installmentsQr = new HDT_QR_InstallmentPlans();
    HDT_UTL_CreatePaymentsRequestBody paymentsUtl = new HDT_UTL_CreatePaymentsRequestBody();
    HDT_QR_Payments paymentsQr = new HDT_QR_Payments();


    @InvocableMethod(label = 'Predefault valori pianoRate')
    public static void predefaultInstallmentsValues(List<HDT_UTL_FlowInputs> inputs){

        HDT_QR_InstallmentPlans installmentsQr = new HDT_QR_InstallmentPlans();
        HDT_UTL_CreatePaymentsRequestBody paymentsUtl = new HDT_UTL_CreatePaymentsRequestBody();

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
        //Decimal totalToPay = inputs[0].totalToPay; 
        String paymentMethod;

        currentCase.Id = recordId;

        inputCheck.customerCode = customerCode;

        inputsCheck.add(inputCheck);
        
        //Lookup for cases 'Sospensione Fornitura' with same Account and completed
        List<Case> suspensionCases = new List<Case>();
        suspensionCases = installmentsQr.getSuspensionCaseByAccountId(accountId);
        if(suspensionCases != null && suspensionCases.size() > 0){

            currentCase.SuspensionInThePastTwelveMonths__c = true;

        }else{
            
            currentCase.SuspensionInThePastTwelveMonths__c = false;

        }

        //Callout 'Vista Rate' to calculate installmentPlansUnpaid
        try{
            outputs = HDT_SRV_AccountInstallmentsCheck.execute(inputsCheck);
            currentCase.ExistingInstallmentsPlanNumber__c = outputs[0].existingInstallmentPlanUnpaid;
        } catch (Exception e) {
            System.debug(LoggingLevel.DEBUG, 'predefaultInstallmentsValues - exception TypeName' + e.getTypeName());
            System.debug(LoggingLevel.DEBUG, 'predefaultInstallmentsValues - exception Message' + e.getMessage());
            System.debug(LoggingLevel.DEBUG, 'predefaultInstallmentsValues - exception StackTraceString' + e.getStackTraceString());
            
        }

        //check CA with/without SEPA
        paymentMethod = installmentsQr.getPaymentMethodByCaseId(recordId);
        currentCase.CAWithOrWithoutSEPA__c = (paymentMethod != null && paymentMethod != '' && paymentMethod == 'RID');

        //SetExpirationDate at CreatedDate+20businessDay
        DateTime createdCase = installmentsQr.getCaseById(recordId).CreatedDate;
        System.debug(LoggingLevel.DEBUG, 'SRV_InstallmentPlans created date -> ' + createdCase);
        currentCase.ExpirationDate__c = Date.valueOf(createdCase) + 19;
        currentCase.ExpirationDate__c = paymentsUtl.addBusinessDay(currentCase.ExpirationDate__c, 1);
        System.debug(LoggingLevel.DEBUG, 'SRV_InstallmentPlans expiration date -> ' + currentCase.ExpirationDate__c);

        //Set AmountToPayInstallments to TotalPay
        //If totalResidue is Zero amount is DocumentTotalAmount
        List<DocumentSelected__c> raiFeeDocuments = installmentsQr.getDocumentSelectedByCase(recordId);
        Decimal totalRaiFeeResidual = 0.0;
        Decimal documentTotalAmount = 0.0;
        Decimal totalResidue = installmentsQr.getCaseById(recordId).TotalResidue__c;
        Decimal amountInstallment;
        String customerAssisted;

        for(DocumentSelected__c document : raiFeeDocuments){
            if(document.TvFeeResidual__c != null){
                totalRaiFeeResidual += document.TvFeeResidual__c;
            }
        }
        if(totalResidue == 0){
            for(DocumentSelected__c document : raiFeeDocuments){
                documentTotalAmount += document.Amount__c;
            }
            amountInstallment = documentTotalAmount;
        } else {
            amountInstallment = totalResidue;
        }

        //Utilizzato per mostrare a video il totale senza canone rai
        currentCase.AmountToPayInInstallments__c = amountInstallment - totalRaiFeeResidual;
        //Viene poi diviso per il numero di rate
        currentCase.InstallmentAmount__c = amountInstallment;
        //Importo che viene utiizzato per inviare a sap
        currentCase.Amount__c = amountInstallment;

        //Set CustomerAssisted
        customerAssisted = installmentsQr.getCustomerAssistedKpi(accountId);
        if(customerAssisted != null){
            currentCase.CutomerAssisted__c = customerAssisted.equalsIgnoreCase('Si');
        }

        HDT_UTL_DatabaseService.updateSObject(currentCase);

    }

    public String createRequestBody(String recordId){

        List<HDT_UTL_CreatePaymentsRequestBody.HDT_UTL_WrapperInput> inputList = new List<HDT_UTL_CreatePaymentsRequestBody.HDT_UTL_WrapperInput>();
        HDT_UTL_CreatePaymentsRequestBody.HDT_UTL_WrapperInput caseInput = new HDT_UTL_CreatePaymentsRequestBody.HDT_UTL_WrapperInput();
        HDT_UTL_CreatePaymentsRequestBody.HDT_UTL_WrapperInput documentInput = new HDT_UTL_CreatePaymentsRequestBody.HDT_UTL_WrapperInput();
        List<Map<String, Object>> documentsListMap = new List<Map<String, Object>>();
        List<Map<String, Object>> caseListMap = new List<Map<String, Object>>();
        List<DocumentSelected__c> documents = new List<DocumentSelected__c>();
        Case currentCase = new Case();
        String pretty;

        currentCase = installmentsQr.getCaseById(recordId);
        documents = installmentsQr.getDocumentSelectedByCase(recordId);

        System.debug(LoggingLevel.DEBUG, 'SRV_InstallmentPlans Case--> '+currentCase);
        System.debug(LoggingLevel.DEBUG, 'SRV_InstallmentPlans Documetns--> '+documents);

        //String depositPaymentMode = currentCase.DepositPaymentMode__c == 'Paperless' ? 'P' : '';
        String depositPaymentMode = '';
        switch on currentCase.DepositPaymentMode__c {
            when 'Paperless' {
                depositPaymentMode = 'P';
            }
            when 'Bonifico Paperless' {
                depositPaymentMode = 'B';
            }
            when 'Acconto Assistiti' {
                depositPaymentMode = 'A';
            }
            when else {
                depositPaymentMode = ' ';
            }
        }
        Decimal total;
        if(currentCase.DepositAmount__c != null){
            total = currentCase.Amount__c - currentCase.DepositAmount__c;
        }else{
            total = currentCase.Amount__c;
        }
       

        Map<String, Object> caseMap = new Map<String, Object>{
            'numeroSR' => currentCase.CaseNumber,
            'tipoPiano' => transcodeInstallmentPlan(currentCase.TypeInstallmentPlan__c, currentCase.ApplicationInterests__c),
            'numeroRata' => currentCase.InstallmentNumberRequired__c,
            'totale' => total,
            'dataInizio' => currentCase.ExpirationDate__c,
            'acconto' => currentCase.DepositAmount__c,
            'contestazioneCliente' => currentCase.Reason__c,
            'modalitaPagamentoAcconto' => depositPaymentMode
        };

        caseListMap.add(caseMap);

        caseInput.isParent = true;
        caseInput.isChild = false;
        caseInput.configMapList = caseListMap;

        inputList.add(caseInput);

        for(DocumentSelected__c document : documents){
            documentsListMap.add(
                new Map<String, Object>{
                    //'numeroBollettino' => document.Bill__c,
                    'numeroDocumento' => document.DocumentNumber__c,
                    // 'numeroDocumento' => document.DocumentNumber__c.startsWith('0') ? '' : document.DocumentNumber__c,
                    // 'numeroFatturaRata' => document.DocumentNumber__c.startsWith('0') ? document.DocumentNumber__c : '',
                    'scadenzaRata' => document.ExpirationDate__c,
                    'tipoDocumento' => document.Type__c
                }
            );
        }

        documentInput.isParent = false;
        documentInput.isChild = true;
        documentInput.childObjName = 'documenti';
        documentInput.configMapList = documentsListMap;

        inputList.add(documentInput);
    

        pretty = paymentsUtl.createBodyRequest(inputList);

        System.debug(LoggingLevel.DEBUG, 'SRV_InstallmentPlans -->' +pretty);

        return pretty;
    }

    /**
     * Transcodifica il tipo di piano rata inserito su SFDC nel codice attesa da SAP.
     * Input richiesti: tipo piano rata e applicazione interessi.
     */
    @TestVisible
    private String transcodeInstallmentPlan(String typeInstallmentPlan, Boolean applyInterests) {
        if (typeInstallmentPlan == null) {
            return '';
        }
        
        String sapCode = '';

        if (typeInstallmentPlan.equals('Autorita')){
            sapCode = 'Z001';
        } else if (typeInstallmentPlan.equals('Piano Bonus')) { // Piano Bonus deprecato o non in ambito Wave 1
            if (applyInterests) {
                sapCode = 'Z010'; 
            } else {
                sapCode = 'Z011'; 
            }
        } else if (typeInstallmentPlan.equals('Autorita idrico')) { // Autorita idrico non in ambito Wave 1
            if (applyInterests) {
                sapCode = 'Z012'; 
            } else {
                sapCode = 'Z013'; 
            }
        } else {
            if (applyInterests) {
                sapCode = 'Z002'; 
            } else {
                sapCode = 'Z003'; 
            }
        }
        
        return sapCode;
    }

    /* Returns either a RentProcessRule or a Map */
    public HDT_UTL_InstallmentPlans.HDT_UTL_FlowOutputs evaluateRuleList(List<RentProcessRule__c> ruleList, Map<String,Object> criteriaMap){

        RentProcessRule__c foundRule = new RentProcessRule__c();
        HDT_UTL_InstallmentPlans.HDT_UTL_FlowOutputs output = new HDT_UTL_InstallmentPlans.HDT_UTL_FlowOutputs();
        String errorMessage = '';
        String fineTuningField;

        for(RentProcessRule__c rule : ruleList){
            Map<String,Object> notFoundMap = new Map<String,Object>();
            for(String fieldName : criteriaMap.keySet()){
                if(fieldName == 'SuspensionInThePastTwelveMonths__c'){
                    fineTuningField = 'SuspensionInPastTwelveMonths__c';
                }else{
                    fineTuningField = fieldName;
                }
                if(!(rule.get(fineTuningField) == criteriaMap.get(fieldName))){
                    notFoundMap.put(fieldName, criteriaMap.get(fieldName));
                    String fieldLabel = Case.SObjectType.getDescribe().fields.getMap().get(fieldName).getDescribe().getLabel();
                    //errorMessage += '\t' + fieldLabel + ': ' + criteriaMap.get(fieldName) + '(prova invece: '+ rule.get(fineTuningField) + ')\n';
                    errorMessage = formattingErrorMessage(errorMessage, fieldLabel, criteriaMap.get(fieldName), rule.get(fineTuningField));
                }
            }
            if(notFoundMap.isEmpty()){
                foundRule = rule;
                break;
            }
        }

        output.rentRule = foundRule;
        output.errorMessage = errorMessage;
        
        return output;
    }

    private String formattingErrorMessage(String errorMessage, String fieldLabel, Object criteriaField, Object ruleField){
        String fineTuningCriteria = '';
        String fineTuningRule = '';
        Boolean skipped = false;
        if(errorMessage.indexOf(fieldLabel) > -1 || fieldLabel.containsIgnoreCase('Domiciliato')){
            skipped = true;//SKIP
            
        } else {
            if(criteriaField instanceOf Boolean && Boolean.valueOf(criteriaField) == true){
                fineTuningCriteria = 'Flaggato';
                fineTuningRule = 'Non Flaggato'; 
            } else if(criteriaField instanceOf Boolean && Boolean.valueOf(criteriaField) == false){
                fineTuningCriteria = 'Non Flaggato';
                fineTuningRule = 'Flaggato'; 
            } else {
                fineTuningCriteria = String.valueOf(criteriaField);
                fineTuningRule = String.valueOf(ruleField);
            }
            errorMessage += '\t' + fieldLabel + ': ' + fineTuningCriteria + ' (prova invece: ' + fineTuningRule + ')\n';
        }
        System.debug(LoggingLevel.DEBUG, 'formattingErrorMessage - Eseguito Skip.');
        
        return errorMessage;
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