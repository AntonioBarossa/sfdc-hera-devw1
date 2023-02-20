public with sharing class HDT_UTL_BpManagement extends HDT_UTL_ProcessExecution{

    private Map<String, String> mapCaseFields;
    private Map<String, String> mapWrapperCaseFields;
    private List<MassiveLoaderRequestItem__c> itemsToSave;
    private List<HDT_WRP_ProcessObjects> processObjList;
    private Set<String>contractCodes=new Set<String>();
    private Set<String>definitiveAccountCodes=new Set<String>();
    private Set<String>definitivesCas=new Set<String>();
    private Set<String>divergentSubjectFiscalCodes=new Set<String>();
    List<MassiveLoaderRequestItem__c> mlriEligible=new List<MassiveLoaderRequestItem__c>();
    List<Case> caseToShift=new List<Case>();
    private Integer contractIndex;
    private Integer accountToMergeIndex;
    private Integer masterAccountIndex;
    private Integer caToMergeIndex;
    private Integer definitiveCaIndex;
    private Integer numeroContoIndex;
    private Integer ibanIndex;
    private Integer abiIndex;
    private Integer cabIndex;
    private Integer cinIndex;
    private Integer cinIbanIndex;
    private Integer foreignIbanIndex;
    private Integer ibanNationIndex;
    private Integer paymentMethodIndex;
    private Integer billSendMethodIndex;
    private Integer billEmailIndex;
    private Integer pecEmailIndex;
    private Integer eletronicInvoicingSendMethodIndex;
    private Integer signatoryTypeIndex;
    private Integer signatoryNameIndex;
    private Integer signatoryLastnameIndex;
    private Integer signatoryFiscalCodeIndex;
    private Integer xmlTypeIndex;
    private Integer createCaIndex;
    private Integer subjectCodeIndex;
    private Integer divergentSubjectIndex;
    private Integer contractAccountCodeIndex;
    private Integer streetNameIndex;
    private Integer streetNumberIndex;
    private Integer streetNumberExtensionIndex;
    private Integer cityIndex;
    private Integer placeIndex;
    private Integer provinceIndex;
    private Integer postalCodeIndex;
    private Integer stateIndex;
    Map<String,Contract> sapCodeContractMap=new Map<String,Contract>();
    Map<String,Account> definitiveAccountCodeMap=new Map<String,Account>();
    Map<String,BillingProfile__c> codeBillingProfMap=new Map<String,BillingProfile__c>();
    Map<String,Contact> fiscalCodeContactMap=new Map<String,Contact>();

    public override void checks(){
        mapFieldsObject();
        populateIndexes();
        itemsToSave = new List<MassiveLoaderRequestItem__c>();
        processObjList = new List<HDT_WRP_ProcessObjects>();
        List<String> tempSplitedFields;
        for(MassiveLoaderRequestItem__c item : requestItemList){
            tempSplitedFields = item.Data__c.split(splitCharacter, -1);//valore dei campi
            checkRequiredFields(item, tempSplitedFields);
            if(String.isNotBlank(item.Status__c) && item.Status__c.equalsIgnoreCase('Errore')){
                itemsToSave.add(item);
                continue;
            }
            contractCodes.add(tempSplitedFields[contractIndex]);
            if(String.isNotBlank(tempSplitedFields[masterAccountIndex])){
                definitiveAccountCodes.add(tempSplitedFields[masterAccountIndex]);
            }
            if(String.isNotBlank(tempSplitedFields[definitiveCaIndex])){
                definitivesCas.add(tempSplitedFields[definitiveCaIndex]);
            }
            if(String.isNotBlank(tempSplitedFields[divergentSubjectIndex])){
                divergentSubjectFiscalCodes.add(tempSplitedFields[divergentSubjectIndex]);
            }
            processObjList.add(new HDT_WRP_ProcessObjects(item,tempSplitedFields,tempSplitedFields[contractIndex]));
        }
    }
    public override void getRecords(){
        HDT_QR_Account qrAccount= new HDT_QR_Account();
        HDT_QR_Contract qrContract= new HDT_QR_Contract();
        HDT_QR_BillingProfile qrBilling= new HDT_QR_BillingProfile();
        HDT_QR_Contact qrContact=new HDT_QR_Contact();
        for(Contract tmpContract:qrContract.getContractBySapCodeBpManagementBulk(contractCodes)){
            sapCodeContractMap.put(tmpContract.SAPContractCode__c,tmpContract);
        }
        if(definitiveAccountCodes.size()>0){
            for(Account current:qrAccount.getAccountByCustomerCodeSet(definitiveAccountCodes)){
                definitiveAccountCodeMap.put(current.CustomerCode__c,current);
            }
        }
        if(definitivesCas.size()>0){
            for(BillingProfile__c tempBp:qrBilling.getRecordByContractAccount(definitivesCas)){
                codeBillingProfMap.put(tempBp.ContractAccountCode__c,tempBp);
            }
        }
        if(divergentSubjectFiscalCodes.size()>0){
            for(Contact cont:qrContact.getContactsByFiscalCodes(divergentSubjectFiscalCodes)){
                fiscalCodeContactMap.put(cont.FiscalCode__c,cont);
            }
        }

    }
    public override void registryCreation(){
        for(HDT_WRP_ProcessObjects currentObj:processObjList){
            currentObj.newCase = generateCase(currentObj.csvSplitted);
            String fieldConversionError='';
            Integer count = 0;
            for (String tempField : currentObj.csvSplitted) {
                if(String.isNotBlank(mapCaseFields.get(mapHeaderByPosition.get(count))) && String.isNotBlank(tempField)){
                    String fieldValue= String.isBlank(currentObj.csvSplitted[count]) ? '':currentObj.csvSplitted[count];
                    fieldConversionError = mapTypeField(currentObj.newCase, mapCaseFields, count, fieldValue);
                    if(String.isNotBlank(fieldConversionError)){
                        break;
                    }
                }
                count++;
            }

            if(String.isNotEmpty(fieldConversionError)){
                itemsToSave.add(setErrorItem(currentObj.requestItem, fieldConversionError));
                continue;
            }

            if(String.isBlank(currentObj.csvSplitted[definitiveCaIndex])){
                try{
                    createBillingProfile(currentObj.newCase,currentObj.csvSplitted);
                }catch (Exception e){
                    itemsToSave.add(setErrorItem(currentObj.requestItem, e.getMessage()));
                    continue;
                }
            }
            caseToShift.add(currentObj.newCase);
            mlriEligible.add(currentObj.requestItem);
        }
        if(caseToShift.size()>0){
            List<Database.SaveResult> insertListResp= Database.insert(caseToShift,false);
            integer removedCount=0;
            for(Database.SaveResult sr:insertListResp){
                if(!sr.isSuccess()){
                    Integer errorObjIndex=insertListResp.indexOf(sr);
                    itemsToSave.add(setErrorItem(mlriEligible[errorObjIndex-removedCount], sr.getErrors().toString().abbreviate(255)));
                    caseToShift.remove(errorObjIndex-removedCount);
                    mlriEligible.remove(errorObjIndex-removedCount);
                    removedCount+=1;
                }
            }
        }
    }

    public override void finalUpdate(){
        if(caseToShift.size()>0){
            for(Case shiftToInLavorazione:caseToShift){
                shiftToInLavorazione.Phase__c='In Lavorazione';
            }
            HDT_WRP_SaveResponse saveResponse=databaseUpsert(caseToShift,mlriEligible,'Case');
            if(saveResponse.reponseItemList.size() > 0){
                itemsToSave.addAll(saveResponse.reponseItemList);
            }
        }
        if(itemsToSave.size() > 0){
            update itemsToSave;
        }
    }

    private void populateIndexes(){
        contractIndex = mapHeaderForWrapper.get('CODICECONTRATTO');
        accountToMergeIndex = mapHeaderForWrapper.get('LISTAACCOUNT');
        masterAccountIndex=mapHeaderForWrapper.get('ACCOUNTDEFINITIVO');
        caToMergeIndex=mapHeaderForWrapper.get('LISTACA');
        definitiveCaIndex =mapHeaderForWrapper.get('CADEFINITIVO');
        numeroContoIndex=mapHeaderForWrapper.get('NUMEROCONTO');
        ibanIndex=mapHeaderForWrapper.get('IBAN');
        abiIndex= mapHeaderForWrapper.get('ABI');
        cabIndex=mapHeaderForWrapper.get('CAB');
        cinIndex=mapHeaderForWrapper.get('CIN');
        cinIbanIndex=mapHeaderForWrapper.get('CINIBAN');
        foreignIbanIndex =mapHeaderForWrapper.get('IBANESTERO');
        ibanNationIndex=mapHeaderForWrapper.get('NAZIONEIBAN');
        paymentMethodIndex=mapHeaderForWrapper.get('MODALITAPAGAMENTO');
        billSendMethodIndex=mapHeaderForWrapper.get('MODALITAINVIOBOLETTA');
        billEmailIndex=mapHeaderForWrapper.get('EMAILINVIOBOLLETTA');
        pecEmailIndex= mapHeaderForWrapper.get('PECFATTURAZIONEELETTRONICA');
        eletronicInvoicingSendMethodIndex=mapHeaderForWrapper.get('MODINVIOFATTURAZIONEELETTRONICA');
        signatoryTypeIndex=mapHeaderForWrapper.get('TIPOSOTTOSCRITTORE');
        signatoryNameIndex=mapHeaderForWrapper.get('NOMESOTTOSCRITTORECC');
        signatoryLastnameIndex= mapHeaderForWrapper.get('COGNOMESOTTOSCRITTORECC');
        signatoryFiscalCodeIndex=mapHeaderForWrapper.get('CFSOTTOSCRITTORECC');
        xmlTypeIndex=mapHeaderForWrapper.get('TIPOXML');
        createCaIndex =mapHeaderForWrapper.get('CREARECA');
        subjectCodeIndex=mapHeaderForWrapper.get('CODICEDESTINATARIO');
        divergentSubjectIndex=mapHeaderForWrapper.get('DESTINATARIODIVERGENTE');
        contractAccountCodeIndex=mapHeaderForWrapper.get('CONTOCONTRATTUALE');
        streetNameIndex=mapHeaderForWrapper.get('NOMEVIA');
        streetNumberIndex=mapHeaderForWrapper.get('CIVICO');
        streetNumberExtensionIndex=mapHeaderForWrapper.get('ESTENSIONECIVICO');
        cityIndex= mapHeaderForWrapper.get('COMUNE');
        placeIndex=mapHeaderForWrapper.get('LOCALITA');
        provinceIndex=mapHeaderForWrapper.get('PROVINCIA');
        postalCodeIndex=mapHeaderForWrapper.get('CAP');
        stateIndex=mapHeaderForWrapper.get('STATO');
    }

    private Case generateCase(List<String> csvValues){
        String caseDescription='';
        Case processCase=new Case(
                Phase__c='Bozza',
                Status='In Lavorazione',
                RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_UnificazioneSeparazioneCABolletta').getRecordTypeId(),
                Type='Unificazione/Separazione BP-CA-Bolletta',
                Cluster__c='Fatturazione',
                Contract__c=sapCodeContractMap.get(csvValues[contractIndex]).Id,
                BillingProfile__c=sapCodeContractMap.get(csvValues[contractIndex]).BillingProfile__c,
                ServicePoint__c=sapCodeContractMap.get(csvValues[contractIndex]).ServicePoint__c
        );
        if(String.isNotBlank(csvValues[masterAccountIndex]) && definitiveAccountCodeMap.containsKey(csvValues[masterAccountIndex]) ){
            processCase.AccountId=definitiveAccountCodeMap.get(csvValues[masterAccountIndex]).Id;
            processCase.Account=definitiveAccountCodeMap.get(csvValues[masterAccountIndex]);
        }else{
            processCase.AccountId=sapCodeContractMap.get(csvValues[contractIndex]).AccountId;
            processCase.Account=sapCodeContractMap.get(csvValues[contractIndex]).Account;
        }
        caseDescription+='Account da unificare:\n'+csvValues[accountToMergeIndex]+'\n\n';
        caseDescription+='Account master:\n'+csvValues[masterAccountIndex]+'\n\n';
        caseDescription+='CA da unificare:\n'+csvValues[caToMergeIndex];
        processCase.Description=caseDescription;
        if(String.isNotBlank(csvValues[definitiveCaIndex])){
            processCase.TargetBillingProfile__c=codeBillingProfMap.get(csvValues[definitiveCaIndex]).Id;
        }
        return processCase;
    }

    public void createBillingProfile(Case processCase,List<String>csvValues){
        BillingProfile__c bpToCreate= new BillingProfile__c(
                IbanCodeNumber__c=csvValues[numeroContoIndex],
                IBAN__c=csvValues[ibanIndex],
                IbanABI__c=csvValues[abiIndex],
                IbanCAB__c=csvValues[cabIndex],
                IbanCIN__c=csvValues[cinIndex],
                IbanCIN_IBAN__c=csvValues[cinIbanIndex],
                IbanIsForeign__c=csvValues[foreignIbanIndex].equalsIgnoreCase('y'),
                IbanCountry__c=csvValues[ibanNationIndex],
                PaymentMethod__c=csvValues[paymentMethodIndex],
                BillSendingMethod__c=csvValues[billSendMethodIndex],
                InvoiceEmailAddress__c=csvValues[billEmailIndex],
                ElectronicInvoiceCertifiedEmailAddress__c=csvValues[pecEmailIndex],
                ElectronicInvoicingMethod__c=csvValues[eletronicInvoicingSendMethodIndex],
                SignatoryType__c=csvValues[signatoryTypeIndex],
                BankAccountSignatoryFirstName__c=csvValues[signatoryNameIndex],
                BankAccountSignatoryLastName__c=csvValues[signatoryLastnameIndex],
                BankAccountSignatoryFiscalCode__c=csvValues[signatoryFiscalCodeIndex],
                XMLType__c=csvValues[xmlTypeIndex],
                SubjectCode__c=csvValues[subjectCodeIndex],
                DivergentSubject__c= (String.isNotBlank(csvValues[divergentSubjectIndex]) && fiscalCodeContactMap.containsKey(csvValues[divergentSubjectIndex]))  ?   fiscalCodeContactMap.get(csvValues[divergentSubjectIndex]).Id  : null,
                ContractAccountCode__c=csvValues[contractAccountCodeIndex],
                InvoicingCountry__c=csvValues[stateIndex],
                CreateContractAccount__c=csvValues[createCaIndex].equalsIgnoreCase('y'),
                InvoicingStreetName__c=csvValues[streetNameIndex],//text 200
                InvoicingStreetNumber__c=csvValues[streetNumberIndex],//text 30
                InvoicingStreetNumberExtension__c=csvValues[streetNumberExtensionIndex],
                InvoicingCity__c=csvValues[cityIndex],
                InvoicingPlace__c=csvValues[placeIndex],
                InvoicingProvince__c=csvValues[provinceIndex],
                InvoicingPostalCode__c=csvValues[postalCodeIndex],
                Account__c=processCase.AccountId
        );
        String checkResponse=checkRequiredBillingProfileField(bpToCreate,processCase.Account.Category__c);
        if(String.isNotBlank(checkResponse)){
            throw new IllegalArgumentException(checkResponse);
        }
        HDT_UTL_DatabaseService.insertSObject(bpToCreate);
        processCase.TargetBillingProfile__c=bpToCreate.Id;
    }

    public String checkRequiredBillingProfileField(BillingProfile__c bp, String categoriaCliente){
        bp.recalculateFormulas();
        Boolean contoContrattualeBool = String.isEmpty(bp.ContractAccountCode__c);
        //Boolean modPagamentoBool = String.isEmpty(bp.PaymentMethod__c);
        String modPagamentoStr = bp.PaymentMethod__c;
        Boolean modInvioBool = String.isEmpty(bp.BillSendingMethod__c);
        String modInvioStr = bp.BillSendingMethod__c;
        Boolean emailBollettaBool = String.isEmpty(bp.InvoiceEmailAddress__c);
        Boolean ibanBool = String.isEmpty(bp.IBAN__c);
        Boolean ibanPaeseBool = String.isEmpty(bp.IbanCountry__c);
        Boolean ibanEstero = !ibanPaeseBool && bp.IbanCountry__c.equalsIgnoreCase('IT')?true:false;
        Boolean cinIbanBool = String.isEmpty(bp.IbanCIN_IBAN__c);
        Boolean cinBool = String.isEmpty(bp.IbanCIN__c);
        Boolean abiBool = String.isEmpty(bp.IbanABI__c);
        Boolean cabBool = String.isEmpty(bp.IbanCAB__c);
        Boolean numeroContoBool = String.isEmpty(bp.IbanCodeNumber__c);
        Boolean tipoSottoscrittoreBool = String.isEmpty(bp.SignatoryType__c);
        Boolean nomeSottoscrittoreBool = String.isEmpty(bp.BankAccountSignatoryFirstName__c);
        Boolean cognomeSottoscrittoreBool = String.isEmpty(bp.BankAccountSignatoryLastName__c);
        Boolean codFiscSottoscrittoreBool = String.isEmpty(bp.BankAccountSignatoryFiscalCode__c);
        Boolean modInvioFattEleBool = String.isEmpty(bp.ElectronicInvoicingMethod__c);
        String modInvioFattEleStr = bp.ElectronicInvoicingMethod__c;
        Boolean pecFattEleBool = String.isEmpty(bp.ElectronicInvoiceCertifiedEmailAddress__c);
        Boolean codiceDestinatarioBool = String.isEmpty(bp.SubjectCode__c);
        Boolean indirizzoBool = String.isEmpty(bp.InvoicingStreetName__c);
        if(!contoContrattualeBool){
            return '';
        }
        if(indirizzoBool){
            return 'Verificare che indirizzo di fatturazione sia valorizzato';
        }
        if((modPagamentoStr.equalsIgnoreCase('RID') || modPagamentoStr.equalsIgnoreCase('Bollettino postale')) && modInvioBool) {
            return 'Verificare che la modalità di invio bolletta sia valorizzata';
        }
        if(!modInvioBool && modInvioStr.equalsIgnoreCase('Bolletta per e-mail') && emailBollettaBool){
            return 'Verificare che l email di invio bolletta sia valorizzata';
        }
        if(ibanEstero && ibanBool){
            return 'Verificare che IBAN sia valorizzato';
        }
        if(!ibanEstero && modPagamentoStr.equalsIgnoreCase('RID') && (ibanBool || ibanPaeseBool || cinIbanBool || cinBool || abiBool || cabBool || numeroContoBool)){
            return 'Verificare che IBAN, ABI, CAB, CIN, CIN-IBAN e numero conto siano valorizzati';
        }
        if(modPagamentoStr.equalsIgnoreCase('RID') && (tipoSottoscrittoreBool || nomeSottoscrittoreBool || cognomeSottoscrittoreBool || codFiscSottoscrittoreBool)){
            return 'Verificare che i dati del sottoscrittore siano valorizzati';
        }
        if(!categoriaCliente.equalsIgnoreCase('Famiglie') && modInvioFattEleBool){
            return 'Verificare modalità invio fatturazione elettronica sia valorizzata';
        }
        if(!modInvioFattEleBool && modInvioFattEleStr.equalsIgnoreCase('XML + carta/email') && (codiceDestinatarioBool || pecFattEleBool)){
            return 'Verificare che pec e codice destinatario fatturazione elettronica siano valorizzati';
        }
        return '';
    }

    private void mapFieldsObject(){
        List<HDT_MassiveFieldsObjectMap__mdt> listCaseFields;
        List<HDT_MassiveFieldsObjectMap__mdt> listWrapperCaseFields;
        mapCaseFields = new Map<String, String>();
        mapWrapperCaseFields = new Map<String, String>();

        listCaseFields = getMapFieldsObject('Case', this.processName);
        listWrapperCaseFields = getMapFieldsObject('WrapperCase', this.processName);

        for(HDT_MassiveFieldsObjectMap__mdt temp : listCaseFields){
            mapCaseFields.put(temp.labelField__c, temp.nameField__c); //mappa header -> api
        }

        for(HDT_MassiveFieldsObjectMap__mdt temp : listWrapperCaseFields){
            mapWrapperCaseFields.put(temp.labelField__c, temp.nameField__c);
        }

    }

    private class HDT_WRP_ProcessObjects {
        private Case newCase;
        private String sapContractCode;
        //private Contract contract;
        private MassiveLoaderRequestItem__c requestItem;
        private List<String> csvSplitted;

        public HDT_WRP_ProcessObjects(){}

        public HDT_WRP_ProcessObjects(MassiveLoaderRequestItem__c requestItem,List<String>csvSplitted,String sapContractCode){
            this.requestItem=requestItem;
            this.csvSplitted=csvSplitted;
            this.sapContractCode=sapContractCode;
        }

        public HDT_WRP_ProcessObjects(MassiveLoaderRequestItem__c requestItem,List<String>csvSplitted,Case newCase,String sapContractCode){
            this.requestItem=requestItem;
            this.csvSplitted=csvSplitted;
            this.newCase=newCase;
            this.sapContractCode=sapContractCode;
        }
    }
}