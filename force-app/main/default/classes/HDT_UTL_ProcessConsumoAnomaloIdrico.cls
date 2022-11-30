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
    private Integer contractIndex;
    private Integer accountIndex;
    private Set<String>contractCodes=new Set<String>();
    private Set<Id>accountIds=new Set<Id>();
    private Map<String,Contract> contractCodePodMap=new Map<String,Contract>();
    public override void checks(){
        //Carico mapping
        mapFieldsObject();
        contractIndex = mapHeaderForWrapper.get('CONTRATTO');
        accountIndex = mapHeaderForWrapper.get('ACCOUNTID');
        itemsToSave = new List<MassiveLoaderRequestItem__c>();
        HDT_WRP_ProcessObjects processObj;
        processObjList = new List<HDT_WRP_ProcessObjects>();
        List<String> tempSplitedFields;
        for(MassiveLoaderRequestItem__c item : requestItemList){
            tempSplitedFields = new List<String>();
            tempSplitedFields = item.Data__c.split(splitCharacter, -1);//valore dei campi
            checkRequiredFields(item, tempSplitedFields);
            if(String.isNotBlank(item.Status__c) && item.Status__c.equalsIgnoreCase('Errore')){
                itemsToSave.add(item);
                continue;
            }
            contractCodes.add(tempSplitedFields[contractIndex]);
            accountIds.add(tempSplitedFields[accountIndex]);
            processObj = new HDT_WRP_ProcessObjects();
            processObj.requestItem = item;
            processObj.csvSplitted = tempSplitedFields;
            processObjList.add(processObj);
        }
    }

    public override void getRecords(){
        HDT_QR_Contract qrContract= new HDT_QR_Contract();
        for(Contract tmpContract:qrContract.getContractByContractCodeConsumoAnomaloIdrico(contractCodes)){
            contractCodePodMap.put(tmpContract.SAPContractCode__c,tmpContract);
        }
    }

    public override void registryCreation(){
        List<Case> caseToInsert = new List<Case>();
        List<MassiveLoaderRequestItem__c> requestItemForUpsert=new List<MassiveLoaderRequestItem__c>();
        for(HDT_WRP_ProcessObjects currentObj:processObjList){
            currentObj.newCase=new Case(Phase__c='in attesa processo doc massivo', Status='In Lavorazione',RecordTypeId=constant.CASE_RECORDTYPEID_CONSUMO_ANOMALO_IDRICO,Cluster__c='Segnalazioni');
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
            if(errorForPicklistValue('Case', 'Type', currentObj.newCase.Type)){
                itemsToSave.add(setErrorItem(currentObj.requestItem, 'Valore processo non corretto: ' + currentObj.newCase.Type));
                continue;
            }
            Map<String,Object>integrityResult=integrityChecks(currentObj.csvSplitted);
            if(! (Boolean)integrityResult.get('checksAreValid')){
                itemsToSave.add(setErrorItem(currentObj.requestItem, (String) integrityResult.get('errorMessage')));
                continue;
            }
            currentObj.contract=contractCodePodMap.get(currentObj.csvSplitted[contractIndex]);
            currentObj.newCase.ServicePoint__c=currentObj.contract.ServicePoint__c;
            currentObj.newCase.Contract__c=currentObj.contract.Id;
            currentObj.newCase.AccountId=currentObj.contract.Contact__r.AccountId;
            currentObj.newCase.ContactId=currentObj.contract.Contact__c;
            currentObj.newCase.JointBottomAdhesion__c=currentObj.contract.ServicePoint__r.JointBottomAdhesion__c;
            currentObj.newCase.PaySewer__c=currentObj.contract.ServicePoint__r.PaySewer__c;
            currentObj.newCase.PayPurification__c=currentObj.contract.ServicePoint__r.PayPurification__c;
            currentObj.newCase.MeterCode__c=currentObj.contract.ServicePoint__r.MeterSN__c;
            currentObj.newCase.Commodity__c =currentObj.contract.ServicePoint__r.CommoditySector__c;
            currentObj.newCase.Distributor__c=currentObj.contract.ServicePoint__r.Distributor__c;
            currentObj.newCase.SupplyType__c=currentObj.contract.ServicePoint__r.SupplyType__c;
            //currentObj.newCase.PhoneNumber__ccontractCodePodMap.get(currentObj.csvSplitted[contractIndex]).Id;
            //currentObj.newCase.SuppliedEmailcontractCodePodMap.get(currentObj.csvSplitted[contractIndex]).Id;
           //currentObj.newCase.SuppliedPhone=contractCodePodMap.get(currentObj.csvSplitted[contractIndex]).Id;
            currentObj.newCase.BillingProfile__c=currentObj.contract.BillingProfile__c;

            caseToInsert.add(currentObj.newCase);
            requestItemForUpsert.add(currentObj.requestItem);
        }
        if(caseToInsert.size()>0){
            HDT_WRP_SaveResponse saveResponse=databaseUpsert(caseToInsert,requestItemForUpsert,'Case');
            if(saveResponse.reponseItemList.size() > 0){
                itemsToSave.addAll(saveResponse.reponseItemList);
            }
        }
    }

    private Map<String,Object> integrityChecks(List<String>csvSplitted){
        Map<String,Object> retMap=new Map<String,Object>{'errorMessage'=>'','checksAreValid'=>true};
        if(!contractCodePodMap.containsKey(csvSplitted[contractIndex])){
            retMap.put('errorMessage','Codice Contratto SAP non trovato: ' + csvSplitted[contractIndex]);
            retMap.put('checksAreValid',false);
        }
        if(String.isBlank(contractCodePodMap.get(csvSplitted[contractIndex]).ServicePoint__c)){
            retMap.put('errorMessage','Nessun POD relazionato al contratto: ' +csvSplitted[contractIndex]);
            retMap.put('checksAreValid',false);
        }
        if(String.isBlank(contractCodePodMap.get(csvSplitted[contractIndex]).Contact__r.AccountId) || (contractCodePodMap.get(csvSplitted[contractIndex]).Contact__r.Account.SAPIntegrationID__c != csvSplitted[accountIndex])){
            retMap.put('errorMessage','Account non trovato/differente');
            retMap.put('checksAreValid',false);
        }
        if(String.isBlank(contractCodePodMap.get(csvSplitted[contractIndex]).BillingProfile__c)){
            retMap.put('errorMessage','Billing profile non valorizzato');
            retMap.put('checksAreValid',false);
        }
        return retMap;
    }

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

        for(HDT_MassiveFieldsObjectMap__mdt temp : listWrapperCaseFields){
            mapWrapperCaseFields.put(temp.labelField__c, temp.nameField__c);
        }

    }

    private class HDT_WRP_ProcessObjects {
        private Case newCase;
        private Contract contract;
        private MassiveLoaderRequestItem__c requestItem;
        private List<String> csvSplitted;
    }
}