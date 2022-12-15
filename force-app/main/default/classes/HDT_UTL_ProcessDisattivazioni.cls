@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_ProcessDisattivazioni extends HDT_UTL_ProcessExecution {

    private Map<String, String> mapCaseFields;
    private Map<String, String> mapWrapperCaseFields;
    private List<MassiveLoaderRequestItem__c> itemsToSave;
    private Id recordTypeId;
    private Map<String, Id> orderIdMap = new Map<String, Id>();
    private List<Contract> contractList;
    private List<AccountContactRelation> accContRelationList;
    private List<Order> orderList;
    private List<String> orderNumberList = new List<String>();
    private Set<String> contractCodeSet = new Set<String>();
    private Set<String> accountIdSet = new Set<String>();
    private List<HDT_WRP_ProcessObjects> processObjList;
    private Map<String, String> accountContactMap = new Map<String, String>();
    private Map<String, Contract> podContractMap = new Map<String, Contract>();
    private Integer podIndex;
    private Integer contractIndex;
    private Integer accountIdIndex;
    private Integer orderVolturaIndex;
    private Boolean isVolturaProcess;

    public override void checks(){
        System.debug(LoggingLevel.DEBUG, 'checks');

        //System.debug(LoggingLevel.DEBUG, '>>> this.processName: ' + this.processName);
        itemsToSave = new List<MassiveLoaderRequestItem__c>();

        mapFieldsObject();

        isVolturaProcess = (this.processName == 'VolturaTecnica') ? true : false;

        podIndex = mapHeaderForWrapper.get(mapWrapperCaseFields.get('POD'));
        contractIndex = mapHeaderForWrapper.get(mapWrapperCaseFields.get('CONTRATTO'));
        //accountIdIndex = mapHeaderForWrapper.get(mapWrapperCaseFields.get('ACCOUNTID'));

        if(!isVolturaProcess){
            orderVolturaIndex = mapHeaderForWrapper.get(mapWrapperCaseFields.get('ORDER_VOLTURA'));
        }

        System.debug(LoggingLevel.DEBUG, '>>> Index: podIndex [' + podIndex + ']; contract [' + contractIndex + ']; accountId [' + accountIdIndex + ']; orderVoltura [' + orderVolturaIndex + ']');

        HDT_WRP_ProcessObjects processObj;
        processObjList = new List<HDT_WRP_ProcessObjects>();
        List<String> tempSplitedFields;
        for(MassiveLoaderRequestItem__c item : requestItemList){

            tempSplitedFields = new List<String>();
            tempSplitedFields = item.Data__c.split(splitCharacter, -1);

            checkRequiredFields(item, tempSplitedFields);
            System.debug(LoggingLevel.DEBUG, '>>> itemStatus' + item.Status__c);

            if(item.Status__c.equalsIgnoreCase('Errore')){
                itemsToSave.add(item);
                continue;
            }

            processObj = new HDT_WRP_ProcessObjects();
            processObj.requestItem = item;
            processObj.csvSplitted = tempSplitedFields;

            //accountIdSet.add(processObj.csvSplitted[accountIdIndex]);
            contractCodeSet.add(processObj.csvSplitted[contractIndex]);
            processObjList.add(processObj);

            if(!isVolturaProcess){
                orderNumberList.add(processObj.csvSplitted[orderVolturaIndex]);
            }

        }

    }

    public override void getRecords(){
        System.debug(LoggingLevel.DEBUG, 'getRecords');

        String rtDeveloperName = '';
        contractList = HDT_QR_ProcessPostSales.getContracts(contractList, contractCodeSet);
        for(Contract contr : contractList){
            accountIdSet.add(contr.AccountId);
        }
        accContRelationList = HDT_QR_ProcessPostSales.getAccountContactRelationIdsList(accContRelationList, accountIdSet, 'Titolare');
        
        //System.debug(LoggingLevel.DEBUG, '>>> accountIdSet ' + String.valueOf(accountIdSet));
        //System.debug(LoggingLevel.DEBUG, '>>> podSet ' + String.valueOf(podSet));
        //System.debug(LoggingLevel.DEBUG, '>>> contractList ' + String.valueOf(contractList));
        //System.debug(LoggingLevel.DEBUG, '>>> orderList ' + String.valueOf(orderList));

        if(isVolturaProcess){
            rtDeveloperName = 'HDT_RT_VolturaTecnica';
        } else {
            rtDeveloperName = 'HDT_RT_Disattivazioni';
            orderList = HDT_QR_ProcessPostSales.getOrderByOrderNumber(orderList, orderNumberList);

            for(Order o : orderList){
                orderIdMap.put(o.OrderNumber, o.Id);
            }
        }

        for(Contract singleContract : contractList){
            podContractMap.put(singleContract.SAPContractCode__c, singleContract);
        }

        for(AccountContactRelation singleRelation : accContRelationList){
            accountContactMap.put(singleRelation.AccountId, singleRelation.ContactId);
        }

        recordTypeId = HDT_QR_ProcessPostSales.getRecordTypeId(rtDeveloperName);

    }

    public override void registryCreation(){
        System.debug(LoggingLevel.DEBUG, 'registryCreation');

        getLimitDetails('START registryCreation');

        List<Case> caseToInsert = new List<Case>();
        List<MassiveLoaderRequestItem__c> requestItemForUpsert;
        requestItemForUpsert = new List<MassiveLoaderRequestItem__c>();
        Map<Id, String> caseNumberMap = new Map<Id, String>();

        HDT_QR_CausalCodeCalculation causalCodeCalculation = new HDT_QR_CausalCodeCalculation();
        HDT_CausalCodeCalculation__mdt causalCode;

        //System.debug(LoggingLevel.DEBUG, '>>> currentRequestItemList: ' + String.valueOf(currentProcess.currentCase));
        //System.debug(LoggingLevel.DEBUG, '>>> get mapCaseFields: ' + mapCaseFields.get(mapHeaderByPosition.get(count)));

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

            if(String.isNotEmpty(convertionError)){
                itemsToSave.add(setErrorItem(processObj.requestItem, convertionError));
                continue;
            }

            if(errorForPicklistValue('Case', 'Type', processObj.newCase.Type)){
                itemsToSave.add(setErrorItem(processObj.requestItem, 'Valore processo non corretto: ' + processObj.newCase.Type));
                continue;
            }

            //System.debug(LoggingLevel.DEBUG, '>>> currentCase: ' + processObj.newCase);
            
            Contract contract;
            if(podContractMap.containsKey(processObj.csvSplitted[contractIndex])){
                contract = podContractMap.get(processObj.csvSplitted[contractIndex]);
                processObj.newCase.Contract__c = contract.Id;
                processObj.newCase.ServicePoint__c = contract.ServicePoint__c;
                processObj.newCase.BillingProfile__c = contract.BillingProfile__c;
                processObj.newCase.AccountId = contract.AccountId;
            } else {
                itemsToSave.add(setErrorItem(processObj.requestItem, 'pod non presente'));
                continue;
            }
            
            String accountId = contract.AccountId;
            processObj.newCase.AccountId = accountId;

            if(accountContactMap.containsKey(accountId)){
                processObj.newCase.ContactId = accountContactMap.get(accountId);
            } else {
                itemsToSave.add(setErrorItem(processObj.requestItem, 'account non presente'));
                continue;
            }

            //per voltura tecnica -> cluster = voltura tecnica
            if(isVolturaProcess){
                processObj.newCase.Cluster__c = 'Voltura';
            } else {
                processObj.newCase.Cluster__c = 'Disattivazioni';
            }
            
            processObj.newCase = setCaseField(processObj.newCase, recordTypeId);
            
            if(!String.isEmpty(contract.ServicePoint__r.CommoditySector__c)){
                causalCode = causalCodeCalculation.calculateCausalCode(processObj.newCase.Cluster__c, processObj.newCase.Type, '', contract.ServicePoint__r.CommoditySector__c); 
            }

            if(causalCode != null){
                processObj.newCase.CausalCode__c = causalCode.CausalCode__c;//'D01' for example
            }

            //if(processObj.newCase.Type.equalsIgnoreCase('Recesso per Rifiuto Voltura')){
            if(!isVolturaProcess){

                String currentOrderNum = processObj.csvSplitted[orderVolturaIndex];
                if(orderIdMap.containsKey(currentOrderNum)){
                    processObj.newCase.VulturePracticeReference__c = orderIdMap.get(currentOrderNum);
                } else {
                    System.debug(LoggingLevel.DEBUG, '>>> NO ORDER FOUND');
                }
            }
            //}

            try{
                HDT_WS_ArrichmentDataEntityResponse res = HDT_WS_ArrichmentDataEntityInvoker.callService(null, contract.ServicePoint__r.ServicePointCode__c);
                processObj.newCase = HDT_UTL_DataEnrichmentPostSales.handleResponse(JSON.serialize(res), processObj.newCase); 
                caseToInsert.add(processObj.newCase); 
                requestItemForUpsert.add(processObj.requestItem);
            } catch(Exception e){
                System.debug(LoggingLevel.DEBUG, '>>> arricchimentoError ' + e.getMessage());
                itemsToSave.add(setErrorItem(processObj.requestItem, 'Errore arricchimento dati #'));
            }

        }

       if(caseToInsert.size() > 0){

           HDT_WRP_SaveResponse saveResponse;
           saveResponse = databaseUpsert(caseToInsert, requestItemForUpsert, 'Case');
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

           getLimitDetails('AFTER CASE CREATION & Enrichment');

           if(saveResponse.reponseItemList.size() > 0){
               itemsToSave.addAll(saveResponse.reponseItemList);
           }

           if(saveResponse.savedObject.size() > 0){
               runCompatibility(saveResponse.savedObject);
           }

       }  

    }

    //public override void makeProcess(){ // creazione processo
    //    System.debug(LoggingLevel.DEBUG, 'makeProcess');
    //}

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
        private Contract contract;
        private MassiveLoaderRequestItem__c requestItem;
        private List<String> csvSplitted;
    }

}