public inherited sharing class HDT_SRV_InstallmentPlans {

    HDT_QR_InstallmentPlans installmentsQr = new HDT_QR_InstallmentPlans();
    HDT_UTL_CreatePaymentsRequestBody paymentsUtl = new HDT_UTL_CreatePaymentsRequestBody();


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

        System.debug('SRV_InstallmentPlans Case--> '+currentCase);
        System.debug('SRV_InstallmentPlans Documetns--> '+documents);

        String depositPaymentMode = currentCase.DepositPaymentMode__c == 'Paperless' ? 'P' : '';

        Map<String, Object> caseMap = new Map<String, Object>{
            'numeroSR' => currentCase.CaseNumber,
            'tipoPiano' => transcodeInstallmentPlan(currentCase.TypeInstallmentPlan__c, currentCase.ApplicationInterests__c),
            'totale' => currentCase.AmountToPayInInstallments__c,
            'dataInizio' => currentCase.FirstExpirationDate__c,
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
                    'numeroBollettino' => document.Bill__c,
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

        System.debug('SRV_InstallmentPlans -->' +pretty);

        return pretty;
    }

    /**
     * Transcodifica il tipo di piano rata inserito su SFDC nel codice attesa da SAP.
     * Input richiesti: tipo piano rata e applicazione interessi.
     */
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
