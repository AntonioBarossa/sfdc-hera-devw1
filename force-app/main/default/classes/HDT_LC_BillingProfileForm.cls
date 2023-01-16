/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 27/11/2020
* @description Apex controller for hdtBillingProfileForm.js component
* @history Keltin Mesonjesi – 27/11/2020 – Created class
*/

public inherited sharing class HDT_LC_BillingProfileForm {

    private static HDT_SRV_BillingProfile billingProfileSrv = new HDT_SRV_BillingProfile();
    private static HDT_QR_BillingProfile billingProfileQr = new HDT_QR_BillingProfile();
    private static HDT_SRV_Account accountSrv = new HDT_SRV_Account();
    private static HDT_QR_Account accountQr = new HDT_QR_Account();
    private static HDT_SRV_Contact contactSrv = new HDT_SRV_Contact();
    private static HDT_QR_Contact contactQr = new HDT_QR_Contact();

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @date 27/11/2020
     * @description Get form fields based on selected payment method
     * @param String paymentMethod
     * @return Map<String,Set<String>>
     */
    @AuraEnabled
    public static Map<String,List<String>> getFormFields(String paymentMethod, String accountId){
        
        Map<String,List<String>> resultMap = new Map<String,List<String>>();

        List<String> bollettionoPostale = new List<String>{
            'BillSendingMethod__c',
            'InvoiceEmailAddress__c',
            'InvoiceCertifiedEmailAddress__c',
            'SendCertifiedEmailConsentDate__c',
            'DivergentSubject__c',
            'CreateContractAccount__c'
            // 'CareOf__c' //Presso
        };

        List<String> bonificoBancario = new List<String>{
            'BillSendingMethod__c',
            'InvoiceEmailAddress__c',
            'InvoiceCertifiedEmailAddress__c',
            'SendCertifiedEmailConsentDate__c',
            'DivergentSubject__c',
            'CreateContractAccount__c'
            // 'CareOf__c' //Presso
        };

        List<String> rid = new List<String>{
            'BillSendingMethod__c',
            'InvoiceEmailAddress__c',
            'InvoiceCertifiedEmailAddress__c',
            'SendCertifiedEmailConsentDate__c',
            'CreateContractAccount__c',
            'IbanIsForeign__c',
            'IBAN__c',
            'IbanCountry__c',
            'IbanCIN_IBAN__c',
            'IbanCIN__c',
            'IbanABI__c',
            'IbanCAB__c',
            'IbanCodeNumber__c'
            // 'CareOf__c' //Presso
        };

        List<String> fatturazioneElettronica = new List<String>{
            'ElectronicInvoicingMethod__c',
            'XMLType__c',
            'ElectronicInvoiceCertifiedEmailAddress__c',
            'SubjectCode__c',
            'SubjectCodeStartDate__c',
            'SubjectCodeEndDate__c',
            'CIG__c',
            'CUP__c'
        };

        List<String> tipologiaIntestatario = new List<String>{
            'OtherPayer__c',
            'LegalAgent__c',
            'BankAccountSignatoryFiscalCode__c',
            'BankAccountSignatoryFirstName__c',
            'BankAccountSignatoryLastName__c'
        };

        List<String> fieldsToCheck = new List<String>();
        fieldsToCheck.addAll(bollettionoPostale);
        fieldsToCheck.addAll(rid);
        fieldsToCheck.addAll(fatturazioneElettronica);
        fieldsToCheck.addAll(tipologiaIntestatario);
        billingProfileSRV.checkReadAccess(String.join(fieldsToCheck,','));

        switch on paymentMethod {
            when  'Bonifico bancario'{
                resultMap.put('choosenFields', bonificoBancario);
            }
            when  'Bollettino postale'{
                resultMap.put('choosenFields', bollettionoPostale);
            }
            when 'RID' {
                resultMap.put('choosenFields', rid);
                resultMap.put('tipologiaIntestatario', tipologiaIntestatario);
            }
        }

        accountSrv.checkReadAccess('RecordType.DeveloperName');
        // Account currentAccount = accountQr.getRecordById(accountId, 'RecordType.DeveloperName ');
        // if (currentAccount.RecordType.DeveloperName  == 'HDT_RT_Business') { //HRAWRM-829
            resultMap.put('fatturazioneElettronica', fatturazioneElettronica);
        // }

        return resultMap;

    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Create BillingProfile__C record
     * @param BillingProfile__c
     * @return BillingProfile__c
     */
    @AuraEnabled
    public static BillingProfile__c createBillingProfile(BillingProfile__c billingProfile){

        if(billingProfile.PaymentMethod__c == 'RID' && !billingProfile.IbanIsForeign__c){
            String iban = billingProfile.IbanCountry__c + billingProfile.IbanCIN_IBAN__c + billingProfile.IbanCIN__c + billingProfile.IbanABI__c + billingProfile.IbanCAB__c + billingProfile.IbanCodeNumber__c;

            HDT_UTL_ValidateIban.HDT_UTL_FlowInputs ibanToValidate = new HDT_UTL_ValidateIban.HDT_UTL_FlowInputs();
            // ibanToValidate.iban = billingProfile.IbanCountry__c + billingProfile.IbanCIN_IBAN__c + billingProfile.IbanCIN__c + billingProfile.IbanABI__c + billingProfile.IbanCAB__c + billingProfile.IbanCodeNumber__c;
            ibanToValidate.iban = billingProfile.IbanCountry__c + billingProfile.IbanCIN_IBAN__c + billingProfile.IbanCIN__c + billingProfile.IbanABI__c + billingProfile.IbanCAB__c + billingProfile.IbanCodeNumber__c;

            List<String> ibanValidationResult = HDT_UTL_ValidateIban.validateIban(new List<HDT_UTL_ValidateIban.HDT_UTL_FlowInputs>{ibanToValidate});

            if (ibanValidationResult[0] == 'KO') {
                throw new AuraHandledException('IBAN non valido');
            }

            billingProfile.IBAN__c = iban;
        }
        if(billingProfile.IbanIsForeign__c != null && billingProfile.IbanIsForeign__c)
        {
            billingProfile.IbanCountry__c = String.isNotBlank(billingProfile.Iban__c) ? billingProfile.Iban__c.substring(0,2) : '';
        }

       Account acc = accountQr.getRecordById(billingProfile.Account__c, 'CustomerMarking__c');

       Map<String,String> mapCustMarkToAccClass = new Map<String,String>{
           'D2 - Ditta individuale' => 'Small Business',
           'G2 - MMS Ditta individuale' => 'Small Business',
           'G3 - MMS Azienda' => 'Small Business',
           'D3 - Azienda' => 'Small Business',
           'Associazione' => 'Small Business',
           'D6 - Associazione' => 'Small Business',
           'G6 - MMS Associazione' => 'Small Business',
           'Ditta individuale' => 'Small Business',
           'Azienda' => 'Small Business',
           'MMS Parti comuni' => 'Small Business',
           'G4 - MMS Parti comuni' => 'Small Business',
           'AAS Azienda' => 'Small Business',
           'AAS Associazione' => 'Small Business',
           'D4 - Parti comuni' => 'Small Business',
           'Parti comuni' => 'Small Business',

           'Persona fisica' => 'Privati',
           'D1 - Persona fisica' => 'Privati',
           'MMS Persona fisica' => 'Privati',
           'G1 - MMS Persona fisica' => 'Privati',
           'AAS Persona fisica' => 'Privati',
           
           'Condominio' => 'Piccoli Condomini',
           'D5 - Condominio' => 'Piccoli Condomini',
           'G5 - MMS Condominio' => 'Piccoli Condomini',
           'AAS Condominio' => 'Piccoli Condomini'

       };

       billingProfile.AccountClass__c = mapCustMarkToAccClass.get(acc.CustomerMarking__c);

       /**@frpanico 2022-03-16
        * Gestione clona BillingProfile
        * Se il CA è valorizzato va sbiancato in quanto
        * il CA è un campo univoco
        */
        if(String.isNotEmpty((String)billingProfile.get('ContractAccountCode__c')))
        {
            billingProfile.ContractAccountCode__c = '';
        }
        HDT_UTL_ErrorHandler validator = validateForm(billingProfile);
        if(!validator.isSuccess)
        {
            throw new AuraHandledException(validator.errorDescription);
        }
        return billingProfileSrv.createRecord(billingProfile);
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get Owner info when 'Stesso Sottoscrittore' is selected in 'SignatoryType__c' or 'OtherPayer__c'
     * @param String accountId
     * @return Account
     */
    @AuraEnabled
    public static Account getAccountOwnerInfo(String accountId){
        accountSrv.checkReadAccess('FirstName__c,LastName__c,FiscalCode__c');
        return accountQr.getRecordById(accountId, 'FirstName__c,LastName__c,FiscalCode__c');
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get contact info when 'Legale Rapresentante' is selected in 'SignatoryType__c'
     * @param String contactId
     * @return Contact
     */
    @AuraEnabled
    public static Contact getLegalAccount(String contactId){
        contactSrv.checkReadAccess('FirstName,LastName,FiscalCode__c');
        return contactQr.getRecordById(contactId);
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get Billing Profile clone
     * @param String billingProfileId
     * @return BillingProfile__c
     */
    @AuraEnabled
    public static BillingProfile__c getCloneBillingProfile(String billingProfileId){
        return billingProfileQr.getRecordById(billingProfileId);
    }

    private static HDT_UTL_ErrorHandler validateForm(BillingProfile__c bp)
    {
        String errorCode = '';
        String errorMessage = '';
        if(bp.BillSendingMethod__c != null && bp?.BillSendingMethod__c?.equalsIgnoreCase('Bolletta per e-mail') 
            && (!String.isBlank(bp?.InvoiceCertifiedEmailAddress__c) || bp?.SendCertifiedEmailConsentDate__c != null))
        {
            errorCode = 'ERRBP-000001';
            errorMessage = 'Per Modalità Invio "Bolletta per Email" non è possibile valorizzare "Email PEC" e "Data consenso email PEC"';
        }
        if(bp.BillSendingMethod__c != null && bp?.BillSendingMethod__c?.equalsIgnoreCase('Fatturazione PA') && bp?.ElectronicInvoicingMethod__c?.equalsIgnoreCase('XML + carta/email'))
        {
            errorCode = 'ERRBP-000002';
            errorMessage = 'Per Modalità Invio "Fatturazione PA" non è possibile inserire Modalità Fattura "XML + Carta/Email"';
        }
        if(bp?.IbanIsForeign__c && bp?.IBAN__c?.deleteWhitespace().startsWithIgnoreCase('IT'))
        {
            errorCode = 'ERRBP-000003';
            errorMessage = 'Per IBAN Estero non è possibile inserire un IBAN Italiano';
        }
        return new HDT_UTL_ErrorHandler(errorCode,errorMessage);
    }

}
