@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_ProcessVariazioni extends HDT_UTL_ProcessExecution {

    private Map<String, HDT_MassiveFieldsObjectMap__mdt> sobjectMap;
    private Map<String, String> mapCaseFields;
    private Map<String, String> mapWrapperCaseFields;
    private Set<String> accountIdSet = new Set<String>();
    private Set<String> contractCodeSet = new Set<String>();
    private List<HDT_WRP_ProcessObjects> processObjList;
    private Map<String, Contract> contractMap = new Map<String, Contract>();
    private Map<String, Id> orderIdsMap = new Map<String, Id>();
    private Map<String, Id> recordTypeMap = new Map<String, Id>();
    private List<MassiveLoaderRequestItem__c> itemsToSave;
    private List<Contract> contractList;
    private List<String> orderNumberList = new List<String>();
    private List<Order> orderList = new List<Order>();
    private Map<String, AccountContactRelation> accountContactMap = new Map<String, AccountContactRelation>();
    private List<AccountContactRelation> accContRelationList;
    private Id recordTypeId;
    private Integer podIndex;
    private Integer contractIndex;
    private Integer accountIdIndex;
    private Integer orderVolturaIndex;
    private String rifVoltura = 'RIF_VOLTURA';

    public override void checks(){
        System.debug(LoggingLevel.DEBUG, 'checks');
        itemsToSave = new List<MassiveLoaderRequestItem__c>();
        mapFieldsObject();

        //System.debug(LoggingLevel.DEBUG, '>>> mapCaseFields: ' + String.valueOf(mapCaseFields));
        //System.debug(LoggingLevel.DEBUG, '>>> mapWrapperCaseFields: ' + String.valueOf(mapWrapperCaseFields));
        //System.debug(LoggingLevel.DEBUG, '>>> mapHeaderForWrapper: ' + String.valueOf(mapHeaderForWrapper));
        //System.debug(LoggingLevel.DEBUG, '>>> mapHeaderByPosition: ' + String.valueOf(mapHeaderByPosition));
        //System.debug(LoggingLevel.DEBUG, '>>> sobjectMap: ' + String.valueOf(sobjectMap));

        podIndex = mapHeaderForWrapper.get(mapWrapperCaseFields.get('POD'));
        contractIndex = mapHeaderForWrapper.get(mapWrapperCaseFields.get('CONTRATTO'));
        //accountIdIndex = mapHeaderForWrapper.get(mapWrapperCaseFields.get('ACCOUNTID'));

        if(mapWrapperCaseFields.containsKey(rifVoltura)){
            if(mapHeaderForWrapper.containsKey(mapWrapperCaseFields.get(rifVoltura))){
                orderVolturaIndex = mapHeaderForWrapper.get(mapWrapperCaseFields.get(rifVoltura));
            }
        }
        
        HDT_WRP_ProcessObjects processObj;
        processObjList = new List<HDT_WRP_ProcessObjects>();
        for(MassiveLoaderRequestItem__c item : requestItemList){
            processObj = new HDT_WRP_ProcessObjects();
            processObj.requestItem = item;
            processObj.csvSplitted = item.Data__c.split(splitCharacter, -1);

            checkRequiredFields(item, processObj.csvSplitted);
            System.debug(LoggingLevel.DEBUG, '>>> itemStatus' + item.Status__c);

            if(item.Status__c.equalsIgnoreCase('Errore')){
                itemsToSave.add(item);
                continue;
            }

            //accountIdSet.add(processObj.csvSplitted[accountIdIndex]);
            contractCodeSet.add(processObj.csvSplitted[contractIndex]);

            processObjList.add(processObj);

            if(orderVolturaIndex != null)
                orderNumberList.add(processObj.csvSplitted[orderVolturaIndex]);
        }

    }

    public override void getRecords(){
        System.debug(LoggingLevel.DEBUG, 'getRecords');

        contractList = HDT_QR_ProcessPostSales.getContracts(contractList, contractCodeSet);
        for(Contract contr : contractList){
            accountIdSet.add(contr.AccountId);
        }
        orderList = HDT_QR_ProcessPostSales.getOrderByOrderNumber(orderList, orderNumberList);
        accContRelationList = HDT_QR_ProcessPostSales.getAccountContactRelationList(accContRelationList, accountIdSet, 'Titolare');

        recordTypeId = HDT_QR_ProcessPostSales.getRecordTypeId('HDT_RT_VariazioniEle');
        recordTypeMap.put('Energia Elettrica', recordTypeId);
        recordTypeId = HDT_QR_ProcessPostSales.getRecordTypeId('HDT_RT_VariazioniGas');
        recordTypeMap.put('Gas', recordTypeId);

        for(Contract contr : contractList){
            contractMap.put(contr.SAPContractCode__c, contr);
        }

        for(Order o : orderList){
            orderIdsMap.put(o.OrderNumber, o.Id);
        }

        for(AccountContactRelation singleRelation : accContRelationList){
            accountContactMap.put(singleRelation.AccountId, singleRelation);
        }

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

        Id currentRecordTypeId;
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

                if(!String.isEmpty(convertionError)){
                    // error happened -> exit
                    break;
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

            System.debug(LoggingLevel.DEBUG, '>>> currentCase: ' + processObj.newCase);
            Contract contract;
            
            if(contractMap.containsKey(processObj.csvSplitted[contractIndex])){
                contract = contractMap.get(processObj.csvSplitted[contractIndex]);
                processObj.newCase.Contract__c = contract.Id;
                processObj.newCase.ServicePoint__c = contract.ServicePoint__c;
                processObj.newCase.BillingProfile__c = contract.BillingProfile__c;
                processObj.newCase.AccountId = contract.AccountId;
            } else {
                itemsToSave.add(setErrorItem(processObj.requestItem, 'pod non presente'));
                continue;
            }
                        
            processObj.newCase.Cluster__c = 'Variazioni';

            if(String.isNotEmpty(contract.ServicePoint__r.CommoditySector__c)){
                causalCode = causalCodeCalculation.calculateCausalCode(processObj.newCase.Cluster__c, processObj.newCase.Type, '', contract.ServicePoint__r.CommoditySector__c); 

                if(causalCode != null){
                    processObj.newCase.CausalCode__c = causalCode.CausalCode__c;//'D01' for example
                }

                currentRecordTypeId = recordTypeMap.get(contract.ServicePoint__r.CommoditySector__c);
            }

            if(String.isNotBlank(contract.AccountId)){
                processObj.newCase.AccountId = contract.AccountId;
                
                if(accountContactMap.containsKey(contract.AccountId)){
                    processObj.newCase.ContactId = accountContactMap.get(contract.AccountId).ContactId;
                }
            }

            processObj.newCase = setCaseField(processObj.newCase, currentRecordTypeId);

            if(processObj.newCase.Type.equalsIgnoreCase('Cambio contatore non registrato') && orderVolturaIndex != null){
                String currentOrderNum = processObj.csvSplitted[orderVolturaIndex];
                if(orderIdsMap.containsKey(currentOrderNum)){
                    processObj.newCase.VulturePracticeReference__c = orderIdsMap.get(currentOrderNum);
                } else {
                    System.debug(LoggingLevel.DEBUG, '>>> NO ORDER FOUND');
                }
            }

            if(String.isNotBlank(contract.ServicePoint__r.ServicePointCode__c)){
                try{
                    HDT_WS_ArrichmentDataEntityResponse res = HDT_WS_ArrichmentDataEntityInvoker.callService(null, contract.ServicePoint__r.ServicePointCode__c);
                    processObj.newCase = HDT_UTL_DataEnrichmentPostSales.handleResponse(JSON.serialize(res), processObj.newCase); 
                    caseToInsert.add(processObj.newCase); 
                    requestItemForUpsert.add(processObj.requestItem);
                } catch(Exception e){
                    System.debug(LoggingLevel.DEBUG, '>>> arricchimentoError ' + e.getMessage());
                    itemsToSave.add(setErrorItem(processObj.requestItem, 'Errore arricchimento dati # '));
                }
            }


        }

        if(caseToInsert.size() > 0){

            HDT_WRP_SaveResponse saveResponse;
            saveResponse = databaseUpsert(caseToInsert, requestItemForUpsert, 'Case');
            runAlignment(saveResponse.savedObject);
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

            getLimitDetails('AFTER CASE CREATION / Enrichment / Alignment');

            if(saveResponse.reponseItemList.size() > 0){
                itemsToSave.addAll(saveResponse.reponseItemList);
            }

            if(saveResponse.savedObject.size() > 0){
                runCompatibility(saveResponse.savedObject);
                getLimitDetails('AFTER CASE Compatibility');
            }

        }  

    }

    private static void runAlignment(List<Case> caseList){

        HDT_SRV_AnagAlignment.HDT_UTL_AnagAlignmentFlowInputs input;
        List<String> returnStringList;
        for(Case c : caseList){
            input = new HDT_SRV_AnagAlignment.HDT_UTL_AnagAlignmentFlowInputs();
            input.inputCase = c;
            input.context = setCorrectContext(c.Type);//'VARIAZIONI_INDIRIZZO_FORNITURA';

            if(String.isEmpty(input.context)){
                continue;
            } else {
                returnStringList = HDT_SRV_AnagAlignment.handleAnagAlignment(new List<HDT_SRV_AnagAlignment.HDT_UTL_AnagAlignmentFlowInputs>{input});
                System.debug('>>> returnStringList: ' + returnStringList);
            }

        }
    }

    private static String setCorrectContext(String context){
        if(context.equalsIgnoreCase(Label.VARIAZIONI_TARIFFA_RES_NONRES)) {
            return 'VARIAZIONI_TARIFFA_RES_NONRES';
        } else if(context.equalsIgnoreCase(Label.VARIAZIONI_INDIRIZZO_FORNITURA)){
            return 'VARIAZIONI_INDIRIZZO_FORNITURA';
        } else if(context.equalsIgnoreCase(Label.VARIAZIONI_MARCATURA_USO_PDR)) {
            return 'VARIAZIONI_MARCATURA_USO_PDR';
        } else {
            return '';
        }
    }

    public override void finalUpdate(){
        System.debug(LoggingLevel.DEBUG, 'finalUpdate');

        System.debug(LoggingLevel.DEBUG, 'itemsToSave ' + itemsToSave);

        if(itemsToSave.size() > 0){
            update itemsToSave;
        }

    }

    public override void manageCatchException(Integer batchSize, List<MassiveLoaderRequestItem__c> itemList, String message){
        for(MassiveLoaderRequestItem__c item : itemList){
            item.Status__c = 'Errore';
            item.StatusDescription__c = message;
        }
        update itemList;
    }

    private void mapFieldsObject(){

        List<HDT_MassiveFieldsObjectMap__mdt> allFieldForThisProcess;

        mapCaseFields = new Map<String, String>();
        mapWrapperCaseFields = new Map<String, String>();
        sobjectMap = new Map<String, HDT_MassiveFieldsObjectMap__mdt>();

        allFieldForThisProcess = HDT_QR_ProcessPostSales.getMapFieldsObjectByDeveloperName('Var%');

        for(HDT_MassiveFieldsObjectMap__mdt temp : allFieldForThisProcess){
            if(temp.objectType__c.equalsIgnoreCase('WrapperCase')){
                mapWrapperCaseFields.put(temp.labelField__c, temp.nameField__c);
            } else {
                mapCaseFields.put(temp.MasterLabel, temp.nameField__c);
                sobjectMap.put(temp.MasterLabel, temp);
            }
            
        }

    }

    private class HDT_WRP_ProcessObjects {
        private Case newCase;
        private Contract contract;
        private MassiveLoaderRequestItem__c requestItem;
        private List<String> csvSplitted;
    }

}