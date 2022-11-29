/** NTTDATA Classe per la gestione del caricamento massivo del Consumo Anomalo Idrico, 
 * richiamata dal batch HDT_BA_ProcessOrderCreation dinamicamente in base la configurazione del metadata HDT_MassiveLoaderProcess__mdt
 * e utilizzando il mapping field nel metadata HDT_MassiveFieldsObjectMap__mdt.
 **/
@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_ProcessConsumoAnomaloIdrico extends HDT_UTL_ProcessExecution {
    private List<MassiveLoaderRequestItem__c> itemsToSave;
    private Map<String, String> mapCaseFields;
    private Map<String, String> mapWrapperCaseFields;
    private List<HDT_WRP_ProcessObjects> processObjList;
    //private Map<String, String> accountContactMap = new Map<String, String>();
    //private Map<String, Contract> podContractMap = new Map<String, Contract>();
    private Integer contractIndex;
    private Integer accountIndex;
    private Set<String>contractCodes=new Set<String>();
    private Set<Id>accountIds=new Set<Id>();
    private Map<String,Contract> contractCodePodMap=new Map<String,Contract>();
    private Map<Id,Contact> accountIdContactMap=new Map<Id,Contact>();
    /*
        mapRequiredByPosition posizioneElemento->header colonna csv, mapCaseFields header colonna csv -> api name campo
        mapCaseFields.get(mapRequiredByPosition.get(someIndex)) -> api name campo per la posizione someIndex; csvSplitted[someIndex] valore della colonna in posizione someIndex
    */
    public override void checks(){
        System.debug(LoggingLevel.DEBUG, 'checks');
        //Carico mapping
        mapFieldsObject();
        contractIndex = mapHeaderForWrapper.get('CONTRATTO');
        accountIndex = mapHeaderForWrapper.get('ACCOUNTID');
        System.debug('contract index:'+contractIndex);
        System.debug('account index: '+accountIndex);
        itemsToSave = new List<MassiveLoaderRequestItem__c>();
        HDT_WRP_ProcessObjects processObj;
        processObjList = new List<HDT_WRP_ProcessObjects>();
        List<String> tempSplitedFields;
        for(MassiveLoaderRequestItem__c item : requestItemList){

            tempSplitedFields = new List<String>();
            tempSplitedFields = item.Data__c.split(splitCharacter, -1);//valore dei campi
            System.debug('tempSplitedFields value: '+tempSplitedFields);

            checkRequiredFields(item, tempSplitedFields);
            System.debug(LoggingLevel.DEBUG, '>>> itemStatus' + item.Status__c);

            if(String.isNotBlank(item.Status__c) && item.Status__c.equalsIgnoreCase('Errore')){
                itemsToSave.add(item);
                continue;
            }
            System.debug('mapHeaderByPosition: '+mapHeaderByPosition);
            System.debug('mapHeaderForWrapper: '+mapHeaderForWrapper);
            contractCodes.add(tempSplitedFields[contractIndex]);
            system.debug('contract code added: '+tempSplitedFields[contractIndex]);
            accountIds.add(tempSplitedFields[accountIndex]);
            system.debug('account id added: '+tempSplitedFields[accountIndex]);
            processObj = new HDT_WRP_ProcessObjects();
            processObj.requestItem = item;
            processObj.csvSplitted = tempSplitedFields;

            processObjList.add(processObj);

        }


    }

    public override void getRecords(){
        HDT_QR_Contact qrCont=new HDT_QR_Contact();
        HDT_QR_Contract qrContract= new HDT_QR_Contract();
        for(Contact tmpCont:qrCont.getContactByAccountIdConsumoAnomaloMassivo(accountIds)){
            accountIdContactMap.put(tmpCont.AccountId,tmpCont);
        }
        for(Contract tmpContract:qrContract.getContractByContractCodeConsumoAnomaloIdrico(contractCodes)){
            contractCodePodMap.put(tmpContract.SAPContractCode__c,tmpContract);
        }
    }

    public override void registryCreation(){
        System.debug('registryCreation start');
        List<Case> caseToInsert = new List<Case>();
        List<MassiveLoaderRequestItem__c> requestItemForUpsert=new List<MassiveLoaderRequestItem__c>();
        System.debug('processObjList: '+processObjList);
        for(HDT_WRP_ProcessObjects currentObj:processObjList){
            currentObj.newCase=new Case(Phase__c='in attesa processo doc massivo', Status='In Lavorazione',RecordTypeId=constant.CASE_RECORDTYPEID_CONSUMO_ANOMALO_IDRICO,Cluster__c='Segnalazioni');
            String fieldConversionError='';
            Integer count = 0;
            for (String tempField : currentObj.csvSplitted) {
                //mapCaseFields.get(mapHeaderByPosition.get(count))
                if(String.isNotBlank(mapCaseFields.get(mapHeaderByPosition.get(count))) && String.isNotBlank(tempField)){
                    String fieldValue= String.isBlank(currentObj.csvSplitted[count]) ? '':currentObj.csvSplitted[count];
                    System.debug(LoggingLevel.DEBUG, '>>> tempField: ' + tempField + ' # Header: ' + mapHeaderByPosition.get(count) + ' # CaseFields: ' + mapCaseFields.get(mapHeaderByPosition.get(count)));
                    fieldConversionError = mapTypeField(currentObj.newCase, mapCaseFields, count, fieldValue);
                    if(String.isNotBlank(fieldConversionError)){
                        System.debug(fieldConversionError);
                        break;
                    }
                }
                count++;
            }
            if(String.isNotEmpty(fieldConversionError)){
                itemsToSave.add(setErrorItem(currentObj.requestItem, fieldConversionError));
                continue;
            }
            if(errorForPicklistValue('Case', 'Type', currentObj.newCase.Type)){
                itemsToSave.add(setErrorItem(currentObj.requestItem, 'Valore processo non corretto: ' + currentObj.newCase.Type));
                continue;
            }
            if(!ContractCodePodMap.containsKey(currentObj.csvSplitted[contractIndex])){
                itemsToSave.add(setErrorItem(currentObj.requestItem, 'Codice Contratto SAP non trovato: ' + currentObj.csvSplitted[contractIndex]));
                continue;
            }
            if(String.isBlank(ContractCodePodMap.get(currentObj.csvSplitted[contractIndex]).ServicePoint__c)){
                itemsToSave.add(setErrorItem(currentObj.requestItem, 'Nessun POD relazionato al contratto: ' + currentObj.csvSplitted[contractIndex]));
                continue;
            }
            if(!accountIdContactMap.containsKey(currentObj.csvSplitted[accountIndex])){
                itemsToSave.add(setErrorItem(currentObj.requestItem, 'Account Id non trovato: ' + currentObj.csvSplitted[accountIndex]));
                continue;
            }
            currentObj.newCase.ServicePoint__c=ContractCodePodMap.get(currentObj.csvSplitted[contractIndex]).ServicePoint__c;
            currentObj.newCase.Contract__c=ContractCodePodMap.get(currentObj.csvSplitted[contractIndex]).Id;
            currentObj.newCase.AccountId=accountIdContactMap.get(currentObj.csvSplitted[accountIndex]).AccountId;
            currentObj.newCase.ContactId=accountIdContactMap.get(currentObj.csvSplitted[accountIndex]).Id;
            currentObj.newCase.PhoneNumber__c= String.isNotBlank(accountIdContactMap.get(currentObj.csvSplitted[accountIndex]).Phone) ? accountIdContactMap.get(currentObj.csvSplitted[accountIndex]).Phone : accountIdContactMap.get(currentObj.csvSplitted[accountIndex]).MobilePhone;
            currentObj.newCase.SuppliedEmail=String.isNotBlank(accountIdContactMap.get(currentObj.csvSplitted[accountIndex]).Account.PrimaryEmail__c) ? accountIdContactMap.get(currentObj.csvSplitted[accountIndex]).Account.PrimaryEmail__c : accountIdContactMap.get(currentObj.csvSplitted[accountIndex]).Email;
            currentObj.newCase.SuppliedPhone=String.isNotBlank(accountIdContactMap.get(currentObj.csvSplitted[accountIndex]).Phone) ? accountIdContactMap.get(currentObj.csvSplitted[accountIndex]).Phone : accountIdContactMap.get(currentObj.csvSplitted[accountIndex]).MobilePhone;
            System.debug('new case created: '+currentObj.newCase);
            caseToInsert.add(currentObj.newCase);
            requestItemForUpsert.add(currentObj.requestItem);
        }
        System.debug('outside for loop registryCreation');
        if(caseToInsert.size()>0){
            HDT_WRP_SaveResponse saveResponse=databaseUpsert(caseToInsert,requestItemForUpsert,'Case');
            System.debug('inserted cases: '+caseToInsert);
            if(saveResponse.reponseItemList.size() > 0){
                itemsToSave.addAll(saveResponse.reponseItemList);
            }
        }
    }

    //public override void makeProcess(){
    //}

    public override void finalUpdate(){
        if(itemsToSave.size() > 0){
            update itemsToSave;
        }
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
        System.debug('mapCaseFields: '+mapCaseFields);

        for(HDT_MassiveFieldsObjectMap__mdt temp : listWrapperCaseFields){
            mapWrapperCaseFields.put(temp.labelField__c, temp.nameField__c);
        }
        System.debug('mapWrapperCaseFields: '+mapWrapperCaseFields);

    }


    private class HDT_WRP_ProcessObjects {
        private Case newCase;
        private Contract contract;
        private MassiveLoaderRequestItem__c requestItem;
        private List<String> csvSplitted;
    }
}
