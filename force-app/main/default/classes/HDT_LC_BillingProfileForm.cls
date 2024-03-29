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
            'IbanCodeNumber__c',
            'DivergentSubject__c'
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
            //when  'Bonifico bancario'{
            when  'Bonifico'{
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

        if(billingProfile.PaymentMethod__c == 'RID' && (!billingProfile.IbanIsForeign__c || (billingProfile.IbanIsForeign__c && !String.isBlank(billingProfile.IBAN__c) && billingProfile.IBAN__c.startsWithIgnoreCase('SM')))){
            if(!String.isBlank(billingProfile.IBAN__c) && billingProfile.IBAN__c.length() == 27){
                billingProfile.IbanCountry__c = billingProfile.IBAN__c.substring(0, 2).toUpperCase();
                billingProfile.IbanCIN_IBAN__c = billingProfile.IBAN__c.substring(2, 4).toUpperCase();
                billingProfile.IbanCIN__c = billingProfile.IBAN__c.substring(4, 5).toUpperCase();
                billingProfile.IbanABI__c = billingProfile.IBAN__c.substring(5, 10).toUpperCase();
                billingProfile.IbanCAB__c = billingProfile.IBAN__c.substring(10, 15).toUpperCase();
                billingProfile.IbanCodeNumber__c = billingProfile.IBAN__c.substring(15,27).toUpperCase();
            }else if (!String.isBlank(billingProfile.IBAN__c)){
                throw new AuraHandledException('IBAN non valido');
            }else{
                billingProfile.IbanCountry__c = billingProfile.IbanCountry__c.toUpperCase();
                billingProfile.IbanCIN_IBAN__c = billingProfile.IbanCIN_IBAN__c.toUpperCase();
                billingProfile.IbanCIN__c = billingProfile.IbanCIN__c.toUpperCase();
                billingProfile.IbanABI__c = billingProfile.IbanABI__c.toUpperCase();
                billingProfile.IbanCAB__c = billingProfile.IbanCAB__c.toUpperCase();
                billingProfile.IbanCodeNumber__c = billingProfile.IbanCodeNumber__c.toUpperCase();
            }
            
            String iban = billingProfile.IbanCountry__c + billingProfile.IbanCIN_IBAN__c + billingProfile.IbanCIN__c + billingProfile.IbanABI__c + billingProfile.IbanCAB__c + billingProfile.IbanCodeNumber__c;

            HDT_UTL_ValidateIban.HDT_UTL_FlowInputs ibanToValidate = new HDT_UTL_ValidateIban.HDT_UTL_FlowInputs();
            // ibanToValidate.iban = billingProfile.IbanCountry__c + billingProfile.IbanCIN_IBAN__c + billingProfile.IbanCIN__c + billingProfile.IbanABI__c + billingProfile.IbanCAB__c + billingProfile.IbanCodeNumber__c;
            // ibanToValidate.iban = billingProfile.IbanCountry__c + billingProfile.IbanCIN_IBAN__c + billingProfile.IbanCIN__c + billingProfile.IbanABI__c + billingProfile.IbanCAB__c + billingProfile.IbanCodeNumber__c;
            ibanToValidate.iban = iban;

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
        if(!'RID'.equalsIgnoreCase(billingProfile.PaymentMethod__c) && (!String.isBlank(billingProfile.IbanABI__c) || !String.isBlank(billingProfile.IbanCAB__c) || !String.isBlank(billingProfile.IbanCIN_IBAN__c) || !String.isBlank(billingProfile.IbanCodeNumber__c) || !String.isBlank(billingProfile.IBAN__c))){
            billingProfile.IbanCountry__c = null;
            billingProfile.IbanCIN_IBAN__c = null;
            billingProfile.IbanCIN__c = null;
            billingProfile.IbanABI__c = null;
            billingProfile.IbanCAB__c = null;
            billingProfile.IbanCodeNumber__c = null;
            billingProfile.IBAN__c = null;
        }

       Account acc = accountQr.getRecordById(billingProfile.Account__c, 'CustomerMarking__c, Category__c');

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
       /* Se marcatura = 'D8 - Marcatura nulla' si va a guardare la categoria dell'account e si esegue il seguente mapping
       Famiglie --> Privati
       Aziende Soho --> Small Business
       Piccoli Condomini --> Piccoli Condomini
       Da estendere wave successive
       */
       Map<String, String> nullMarkingMap = new Map<String,String>
       {
        'Famiglie' => 'Privati',
        'Aziende Soho' => 'Small Business',
        'Piccoli Condomini' => 'Piccoli Condomini'
       };
      if('D8 - Marcatura nulla'.equalsIgnoreCase(acc.CustomerMarking__c))
       {
        billingProfile.AccountClass__c = nullMarkingMap.get(acc.Category__c);
       }
       else
       {
        billingProfile.AccountClass__c = mapCustMarkToAccClass.get(acc.CustomerMarking__c);
       }
      
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

    @AuraEnabled
    public static String getAccount(String accountId){
        accountSrv.checkReadAccess('Category__c');
        Account acc = accountQr.getRecordById(accountId, 'Category__c');
        return acc != null ? acc.Category__c : '';
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

        String compareStringNewBp = bp.InvoicingStreetName__c + bp.InvoicingStreetNumber__c + bp.InvoicingStreetNumberExtension__c + bp.InvoicingPlace__c + bp.InvoicingCity__c + bp.InvoicingProvince__c + bp.InvoicingPostalCode__c + bp.InvoicingCountry__c + bp.PaymentMethod__c + bp.BillSendingMethod__c + bp.IBAN__c  + bp.IbanABI__c + bp.IbanCAB__c + bp.IbanCIN_IBAN__c + bp.IbanCIN__c + bp.IbanCodeNumber__c + bp.IbanIsForeign__c;
        
        if(!String.isBlank(bp.Account__c)){
            List<BillingProfile__c> bpAccountList = billingProfileQr.getRecordsByAccount(bp.Account__c);
            String compareStringExistingBp = '';
            if(bpAccountList.size() > 0){
                for (BillingProfile__c bpAcc : bpAccountList) {
                    compareStringExistingBp = bpAcc.InvoicingStreetName__c + bpAcc.InvoicingStreetNumber__c + bpAcc.InvoicingStreetNumberExtension__c + bpAcc.InvoicingPlace__c + bpAcc.InvoicingCity__c + bpAcc.InvoicingProvince__c + bpAcc.InvoicingPostalCode__c + bpAcc.InvoicingCountry__c + bpAcc.PaymentMethod__c + bpAcc.BillSendingMethod__c + bpAcc.IBAN__c  + bpAcc.IbanABI__c + bpAcc.IbanCAB__c + bpAcc.IbanCIN_IBAN__c + bpAcc.IbanCIN__c + bpAcc.IbanCodeNumber__c + bpAcc.IbanIsForeign__c;
                    if(compareStringNewBp.equalsIgnoreCase(compareStringExistingBp) && !bp.CreateContractAccount__c){
                        errorCode = 'ERRBP-000004';
                        errorMessage = 'Esiste già un Billing Profile con le stesse condizioni (Indirizzo, Iban, Modalità di pagamento, Modalità Invio Bolletta), selezionare il flag "CA da creare" se si vuole comunque procedere con la creazione.';
                        break;
                    }
                }
            }
        }

        return new HDT_UTL_ErrorHandler(errorCode,errorMessage);
    }

}
