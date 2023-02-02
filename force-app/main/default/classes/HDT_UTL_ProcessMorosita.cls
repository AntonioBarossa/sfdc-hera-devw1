@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing virtual class HDT_UTL_ProcessMorosita extends HDT_UTL_ProcessExecution {

    private Map<String, String> mapCaseFields;
    private Map<String, String> mapWrapperCaseFields;
    private List<MassiveLoaderRequestItem__c> itemsToSave;
    private Id recordTypeId;
    private Map<String, Case> podToCaseIdMap = new Map<String, Case>();
    private Map<String, Contract> contractMap = new Map<String, Contract>();
    private List<HDT_WRP_ProcessObjects> processObjList;
    private List<AccountContactRelation> accContRelationList;
    private Map<String, AccountContactRelation> accountContactMap = new Map<String, AccountContactRelation>();
    private Set<String> accountIdSet = new Set<String>();
    private Set<String> contractCodeSet = new Set<String>();
    private Map<String,Integer> duplicatePodMap = new Map<String,Integer>();
    private Set<String> podSet = new Set<String>();
    private Integer podIndex;
    private Integer accountIdIndex;
    private Integer contractIndex;


    public override void checks(){
        System.debug(LoggingLevel.DEBUG, 'checks');
        itemsToSave = new List<MassiveLoaderRequestItem__c>();
        
        mapFieldsObject();

        podIndex = mapHeaderForWrapper.get(mapWrapperCaseFields.get('POD'));
        //accountIdIndex = mapHeaderForWrapper.get(mapWrapperCaseFields.get('ACCOUNTID'));
        contractIndex = mapHeaderForWrapper.get(mapWrapperCaseFields.get('CONTRATTO'));

        HDT_WRP_ProcessObjects processObj;
        processObjList = new List<HDT_WRP_ProcessObjects>();
        for(MassiveLoaderRequestItem__c item : requestItemList){
            
            processObj = new HDT_WRP_ProcessObjects();
            processObj.requestItem = item;
            processObj.csvSplitted = item.Data__c.split(splitCharacter, -1);
            String pod = processObj.csvSplitted[podIndex];
            checkRequiredFields(item, processObj.csvSplitted);
            System.debug(LoggingLevel.DEBUG, '>>> itemStatus' + item.Status__c);

            if(item.Status__c.equalsIgnoreCase('Errore')){
                itemsToSave.add(item);
                continue;
            }
            if(podSet.contains(pod)){
                if(duplicatePodMap.containsKey(pod)){
                    Integer i = duplicatePodMap.get(pod) + 1;
                    duplicatePodMap.put(pod,i);
                }else {
                    duplicatePodMap.put(pod,1);
                }
                
            }
            
            //accountIdSet.add(processObj.csvSplitted[accountIdIndex]);
            contractCodeSet.add(processObj.csvSplitted[contractIndex]);
            podSet.add(processObj.csvSplitted[podIndex]);
            
            
            processObjList.add(processObj);
        }

    }

    public override void getRecords(){

        System.debug(LoggingLevel.DEBUG, 'getRecords');

        List<Case> caseList;
        List<Contract> contractList;
        //caseList = HDT_QR_ProcessPostSales.getCaseByServicePointCode(caseList, podSet, 'Sospensione Fornitura');
        //accContRelationList = HDT_QR_ProcessPostSales.getAccountContactRelationList(accContRelationList, accountIdSet, 'Titolare');

        //contractList = HDT_QR_ProcessPostSales.getContracts(contractList, contractCodeSet);
        contractList = HDT_QR_ProcessPostSales.getContractsByPod(contractList, podSet);
        for(Contract contr : contractList){
            accountIdSet.add(contr.AccountId);
        }
        accContRelationList = HDT_QR_ProcessPostSales.getAccountContactRelationList(accContRelationList, accountIdSet, 'Titolare');
        recordTypeId = HDT_QR_ProcessPostSales.getRecordTypeId('HDT_RT_Morosita');

        for(Contract contract : contractList){
            contractMap.put(contract.ServicePoint__r.ServicePointCode__c, contract);
            podSet.add(contract.ServicePoint__r.ServicePointCode__c);
        }

        for(AccountContactRelation singleRelation : accContRelationList){
            accountContactMap.put(singleRelation.AccountId, singleRelation);
        }

        caseList = HDT_QR_ProcessPostSales.getCaseByServicePointCode(caseList, podSet, 'Sospensione Fornitura');
        for(Case c : caseList){
            podToCaseIdMap.put(c.ServicePoint__r.ServicePointCode__c, c);
        }

    }

    public override void registryCreation(){
        System.debug(LoggingLevel.DEBUG, 'registryCreation');

        HDT_QR_CausalCodeCalculation causalCodeCalculation = new HDT_QR_CausalCodeCalculation();
        HDT_CausalCodeCalculation__mdt causalCode;

        List<MassiveLoaderRequestItem__c> requestItemForUpsert;
        List<Case> caseToInsert = new List<Case>();
        List<Case> parentCaseToInsert = new List<Case>();
        requestItemForUpsert = new List<MassiveLoaderRequestItem__c>();
        Map<Id, String> caseNumberMap = new Map<Id, String>();
        Map<String,Case> servicePointContainerMap = new Map<String,Case>();
        //String type = 'Sospensione Fornitura';

        for(HDT_WRP_ProcessObjects processObj : processObjList){

            processObj.newCase = new Case();
            // Per ogni item della mappa itemRequestMap viene convertito il data__c in una lista (processObj.csvSplitted) e tramite il metodo mapTypeField la lista viene
            // convertita nel custom obj indicato, in questo caso è currentProcess.currentCase

            Integer count = 0;
            String convertionError;
            for (String tempField : processObj.csvSplitted) {

                if ('null'.equalsIgnoreCase(tempField)) {
                   tempField = '';
                }
            
                if(String.isNotBlank(mapCaseFields.get(mapHeaderByPosition.get(count))) && String.isNotBlank(tempField)){
                    System.debug(LoggingLevel.DEBUG, '>>> tempField: ' + tempField + ' # Header: ' + mapHeaderByPosition.get(count) + ' # CaseFields: ' + mapCaseFields.get(mapHeaderByPosition.get(count)));
                    convertionError = mapTypeField(processObj.newCase, mapCaseFields, count, tempField);

                    if(!String.isEmpty(convertionError)){
                        // error happened -> exit
                        break;
                    }
                }
                count++;
            }

            if(!String.isEmpty(convertionError)){
                itemsToSave.add(setErrorItem(processObj.requestItem, convertionError));
                continue;
            }

            if(errorForPicklistValue('Case', 'Type', processObj.newCase.Type)){
                itemsToSave.add(setErrorItem(processObj.requestItem, 'Valore processo non corretto: ' + processObj.newCase.Type));
                continue;
            }
            
            String podValue;
            Contract contract;
            if(contractMap.containsKey(processObj.csvSplitted[podIndex])){
                contract = contractMap.get(processObj.csvSplitted[podIndex]);
                processObj.newCase.Contract__c = contract.Id;
                processObj.newCase.Commodity__c = contract.ServicePoint__r.CommoditySector__c;
                processObj.newCase.ServicePoint__c = contract.ServicePoint__c;
                processObj.newCase.BillingProfile__c = contract.BillingProfile__c;
                processObj.newCase.AccountId = contract.AccountId;
            } else {
                itemsToSave.add(setErrorItem(processObj.requestItem, 'Contratto non presente o non attivo'));
                continue;
            }

            podValue = contract.ServicePoint__r.ServicePointCode__c;
            //podValue = processObj.csvSplitted[podIndex];

            System.debug('>>>> podValue ' + podValue);
            System.debug('>>>> podToCaseIdMap ' + podToCaseIdMap);

            if(String.isNotBlank(processObj.newCase.Type)/*processObj.newCase.Type.equalsIgnoreCase('Riattivazione Fornitura') || processObj.newCase.Type.equalsIgnoreCase('Sospensione Fornitura')*/){
                if(podToCaseIdMap.containsKey(podValue)){
                    processObj.newCase.ParentId = podToCaseIdMap.get(podValue).ParentId;
                    processObj.newCase.RelatedCase__c = podToCaseIdMap.get(podValue).Id;
                    if(String.isBlank(processObj.newCase.CompetentOffice__c)){
                        processObj.newCase.CompetentOffice__c = podToCaseIdMap.get(podValue).CompetentOffice__c;
                    }
                    if(String.isBlank(String.valueOf(processObj.newCase.PaymentDate__c)) && processObj.newCase.Type.equalsIgnoreCase('Riattivazione Fornitura')){
                        processObj.newCase.PaymentDate__c = Date.today();
                    }
                } else {
                    //itemsToSave.add(setErrorItem(processObj.requestItem, 'Case di Sospensione fornitura non presente'));
                    //continue;
                    processObj.parentCase = new Case();
                    processObj.parentCase.Contract__c = contract.Id;
                    processObj.newCase.Commodity__c = contract.ServicePoint__r.CommoditySector__c;
                    processObj.parentCase.ServicePoint__c = contract.ServicePoint__c;
                    processObj.parentCase.BillingProfile__c = contract.BillingProfile__c;
                    processObj.parentCase.AccountId = contract.AccountId;
                    processObj.parentCase.Cluster__c = 'Morosità';
                    processObj.parentCase.Type = 'Contenitore Morosità';
                    processObj.parentCase.RecordTypeId = recordTypeId;
                    if(accountContactMap.containsKey(contract.AccountId)){
                        processObj.parentCase.ContactId = accountContactMap.get(contract.AccountId).ContactId;
                    }
                    parentCaseToInsert.add(processObj.parentCase);
                    servicePointContainerMap.put(contract.ServicePoint__c,processObj.parentCase);
                }
            }

            processObj.newCase.Cluster__c = 'Morosità';
            processObj.newCase = setCaseField(processObj.newCase, recordTypeId);

            if(accountContactMap.containsKey(contract.AccountId)){
                processObj.newCase.ContactId = accountContactMap.get(contract.AccountId).ContactId;
            }

            causalCode = causalCodeCalculation.calculateCausalCode(processObj.newCase.Cluster__c, processObj.newCase.Type, '', contract.ServicePoint__r.CommoditySector__c); 

            if(causalCode != null){
                processObj.newCase.CausalCode__c = causalCode.CausalCode__c;//'D01' for example
            }
            if(String.isBlank(processObj.newCase.Origin)){
                processObj.newCase.Origin = 'Da PGM';
                if(processObj.parentCase != null){
                    processObj.parentCase.Origin = 'Da PGM';
                }
            }
            if(duplicatePodMap.containsKey(podValue)){
                Integer countPod = duplicatePodMap.get(podValue);
                if(countPod > 0){
                    countPod = countPod-1;
                    processObj.newCase.Phase__c = 'Bozza Annullata';
                    processObj.newCase.Status = 'Chiuso';
                    processObj.newCase.CancellationReason__c = 'Processo incompatibile';
                    duplicatePodMap.put(podValue,countPod);
                }
                
            }

            System.debug(LoggingLevel.DEBUG, '>>> processObj.newCase: ' + String.valueOf(processObj.newCase));

            if(String.isNotBlank(contract.ServicePoint__r.ServicePointCode__c)){
                try{
                    HDT_WS_ArrichmentDataEntityResponse res = HDT_WS_ArrichmentDataEntityInvoker.callService(null, contract.ServicePoint__r.ServicePointCode__c);
                    processObj.newCase = HDT_UTL_DataEnrichmentPostSales.handleResponse(JSON.serialize(res), processObj.newCase); 
                    caseToInsert.add(processObj.newCase); 
                    requestItemForUpsert.add(processObj.requestItem);
                } catch(Exception e){
                    itemsToSave.add(setErrorItem(processObj.requestItem, 'Errore arricchimento dati # '));
                }
            }

        }
        if(parentCaseToInsert.size()>0){
            HDT_UTL_DatabaseService.insertSObject(parentCaseToInsert);
        }
        if(caseToInsert.size() > 0){
            for(Case singleCase : caseToInsert){
                if(String.isBlank(singleCase.ParentId)){
                    singleCase.ParentId = servicePointContainerMap.get(singleCase.ServicePoint__c).Id;
                }
            }
            HDT_WRP_SaveResponse saveResponse = databaseUpsert(caseToInsert, requestItemForUpsert, 'Case');
            caseToInsert.clear();

            if(saveResponse.savedObject.size() > 0){
                caseNumberMap = setCaseNumberMap(caseNumberMap, saveResponse.itemIdToObjId.values());

                Id caseId;
                for(HDT_WRP_ProcessObjects processObj : processObjList){
                    caseId = saveResponse.itemIdToObjId.get(processObj.requestItem.Id);
                    if(caseNumberMap.containsKey(caseId)){
                        processObj.requestItem.Result__c = caseNumberMap.get(caseId);
                    }
                }
            }

            if(saveResponse.reponseItemList.size() > 0){
                itemsToSave.addAll(saveResponse.reponseItemList);
            }

            if(saveResponse.savedObject.size() > 0){
                runCompatibility(saveResponse.savedObject);
            }
        }  
    }

    public override void finalUpdate(){
        System.debug(LoggingLevel.DEBUG, 'finalUpdate');

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
            mapCaseFields.put(temp.labelField__c, temp.nameField__c);
        }

        for(HDT_MassiveFieldsObjectMap__mdt temp : listWrapperCaseFields){
            mapWrapperCaseFields.put(temp.labelField__c, temp.nameField__c);
        }
    }

    public override void manageCatchException(Integer batchSize, List<MassiveLoaderRequestItem__c> itemList, String message){
        for(MassiveLoaderRequestItem__c item : itemList){
            item.Status__c = 'Errore';
            item.StatusDescription__c = message;
        }
        update itemList;
    }

    private class HDT_WRP_ProcessObjects {
        private Case newCase;
        private Case parentCase;
        private MassiveLoaderRequestItem__c requestItem;
        private List<String> csvSplitted;
    }

}