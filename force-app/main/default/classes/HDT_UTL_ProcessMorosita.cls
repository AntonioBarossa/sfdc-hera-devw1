@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing virtual class HDT_UTL_ProcessMorosita extends  HDT_UTL_ProcessExecution {

    private Map<String, String> mapCaseFields;
    private Map<String, String> mapWrapperCaseFields;
    private List<MassiveLoaderRequestItem__c> itemsToSave;
    private Id recordTypeId;
    private Map<String, Id> podToCaseIdMap = new Map<String, Id>();
    private Map<String, Contract> contractMap = new Map<String, Contract>();
    private List<HDT_WRP_ProcessObjects> processObjList;
    private Set<String> accountIdSet = new Set<String>();
    private Set<String> contractCodeSet = new Set<String>();
    private Set<String> podSet = new Set<String>();
    private Integer podIndex;
    private Integer accountIdIndex;
    private Integer contractIndex;


    public override void checks(){
        System.debug(LoggingLevel.DEBUG, 'checks');
        mapFieldsObject();

        podIndex = mapHeaderForWrapper.get(mapWrapperCaseFields.get('POD'));
        accountIdIndex = mapHeaderForWrapper.get(mapWrapperCaseFields.get('ACCOUNTID'));
        contractIndex = mapHeaderForWrapper.get(mapWrapperCaseFields.get('CONTRATTO'));

        HDT_WRP_ProcessObjects processObj;
        processObjList = new List<HDT_WRP_ProcessObjects>();
        for(MassiveLoaderRequestItem__c item : currentProcess.currentRequestItemList){
            processObj = new HDT_WRP_ProcessObjects();
            processObj.requestItem = item;
            processObj.csvSplitted = item.Data__c.split(splitCharacter, -1);

            accountIdSet.add(processObj.csvSplitted[accountIdIndex]);
            contractCodeSet.add(processObj.csvSplitted[contractIndex]);
            podSet.add(processObj.csvSplitted[podIndex]);
            
            processObjList.add(processObj);
        }

    }

    public override void getRecords(){
        System.debug(LoggingLevel.DEBUG, 'getRecords');
        List<Case> caseList;
        List<Contract> contractList;
        caseList = HDT_QR_ProcessPostSales.getCaseByServicePointCode(caseList, podSet, 'Sospensione Fornitura');

        contractList = HDT_QR_ProcessPostSales.getContracts(contractList, contractCodeSet);
        recordTypeId = HDT_QR_ProcessPostSales.getRecordTypeId('HDT_RT_Morosita');

        for(Case c : caseList){
            podToCaseIdMap.put(c.ServicePoint__r.ServicePointCode__c, c.Id);
        }

        for(Contract contract : contractList){
            contractMap.put(contract.SAPContractCode__c, contract);
        }

    }

    public override void registryCreation(){
        System.debug(LoggingLevel.DEBUG, 'registryCreation');

        HDT_QR_CausalCodeCalculation causalCodeCalculation = new HDT_QR_CausalCodeCalculation();
        HDT_CausalCodeCalculation__mdt causalCode;

        List<MassiveLoaderRequestItem__c> requestItemForUpsert;
        List<Case> caseToInsert = new List<Case>();
        itemsToSave = new List<MassiveLoaderRequestItem__c>();
        requestItemForUpsert = new List<MassiveLoaderRequestItem__c>();

        String type = 'Sospensione Fornitura';

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
            
                //if (mapRequiredByPosition.get(count) != null && String.isBlank(tempField)) {
                //    System.debug(LoggingLevel.DEBUG, '>>> throw new HDT_WRP_ProcessEntitiesException');
                //   //throw new HDT_WRP_ProcessEntitiesException( 'Missing Required Field','Missing Required Field ' + mapHeaderByPosition.get(count));
                //}
            
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
                //itemsToSave.add(setErrorItem(itemId, convertionError));
                processObj.requestItem.Status__c = 'Errore';
                processObj.requestItem.StatusDescription__c = convertionError;
                itemsToSave.add(processObj.requestItem);
                continue;
            }

            if(podToCaseIdMap.containsKey(processObj.csvSplitted[podIndex])){
                processObj.newCase.ParentId = podToCaseIdMap.get(processObj.csvSplitted[podIndex]);
                //processObj.newCase.RelatedCase__c
            } else {
                //itemsToSave.add(setErrorItem(itemId, 'pod non presente'));
                processObj.requestItem.Status__c = 'Errore';
                processObj.requestItem.StatusDescription__c = 'pod non presente';
                itemsToSave.add(processObj.requestItem);
                continue;
            }
            
            Contract contract;
            if(contractMap.containsKey(processObj.csvSplitted[contractIndex])){
                contract = contractMap.get(processObj.csvSplitted[contractIndex]);
                processObj.newCase.Contract__c = contract.Id;
                processObj.newCase.ServicePoint__c = contract.ServicePoint__c;
                processObj.newCase.BillingProfile__c = contract.BillingProfile__c;
            } else {
                processObj.requestItem.Status__c = 'Errore';
                processObj.requestItem.StatusDescription__c = 'Contratto non presente';
                itemsToSave.add(processObj.requestItem);
                continue;
            }

            processObj.newCase.Cluster__c = 'Morosità';
            processObj.newCase = HDT_UTL_ProcessCommonOperations.setCaseField(processObj.newCase, recordTypeId);
            // ContactId ???

            causalCode = causalCodeCalculation.calculateCausalCode(this.processName, processObj.newCase.Type, '', contract.ServicePoint__r.CommoditySector__c); 

            if(causalCode != null){
                processObj.newCase.CausalCode__c = causalCode.CausalCode__c;//'D01' for example
            } else {
                //do something -> record error
            } 

            System.debug(LoggingLevel.DEBUG, '>>> processObj.newCase: ' + String.valueOf(processObj.newCase));

            try{
                String arricchimentoResponse = HDT_WS_ArricchimentoDatiTemp.submitRequest(processObj.csvSplitted[podIndex], null);
                processObj.newCase = HDT_UTL_DataEnrichmentPostSales.handleResponse(arricchimentoResponse, processObj.newCase);
                caseToInsert.add(processObj.newCase); 
                requestItemForUpsert.add(processObj.requestItem);
            } catch(Exception e){
                //itemsToSave.add(setErrorItem(itemId, 'Errore arricchimento dati # '));
                processObj.requestItem.Status__c = 'Errore';
                processObj.requestItem.StatusDescription__c = 'Errore arricchimento dati # ';
                itemsToSave.add(processObj.requestItem);
            }

        }

        if(caseToInsert.size() > 0){

            HDT_UTL_ProcessCommonOperations.HDT_WRP_SaveResponse saveResponse = HDT_UTL_ProcessCommonOperations.databaseUpsert(caseToInsert, requestItemForUpsert, 'Case');
            caseToInsert.clear();

            if(saveResponse.reponseItemList.size() > 0){
                itemsToSave.addAll(saveResponse.reponseItemList);
            }

            if(saveResponse.savedObject.size() > 0){
                HDT_UTL_ProcessCommonOperations.runCompatibility(saveResponse.savedObject);
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
        private MassiveLoaderRequestItem__c requestItem;
        private List<String> csvSplitted;
    }

    /*public static void setDataForTest(Integer numRecords){

        Id massiveLoaderRequestId = 'a3d3O000000WuAYQA0';
        Set<Id> docId = new Set<Id>();

        delete [
            SELECT Id, Data__c, NextStepData__c, Status__c, StatusDescription__c, MassiveLoaderRequest__c
            FROM MassiveLoaderRequestItem__c
            WHERE MassiveLoaderRequest__c = :massiveLoaderRequestId
        ];

        delete [
            SELECT Id, Type, AccountId, NotPerformedBefore__c, WrittenReceiptRequestDate__c, CustomerRecessDate__c, VulturePracticeReference__c,
                   DistributorNote__c, ServicePoint__c, BillingProfile__c, Contract__c, RecordTypeId, ContactId, CausalCode__c, 
                   Phase__c, Status, CancellationReason__c
            FROM Case
            WHERE CreatedById = '0051X0000055rbNQAQ'
        ];
    
        List<ContentDocumentLink> cdlList = [
            SELECT Id, LinkedEntityId, ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :massiveLoaderRequestId
        ];

        if(cdlList.size() > 0){
            for(ContentDocumentLink c : cdlList){
                docId.add(c.ContentDocumentId);
            }

            delete cdlList;
            delete [SELECT Id FROM ContentDocument WHERE Id IN :docId];
        }

        List<MassiveLoaderRequestItem__c> itemsList = new List<MassiveLoaderRequestItem__c>();
        MassiveLoaderRequestItem__c item;
    
        for(Integer n=0; n<numRecords; n++){
            item = new MassiveLoaderRequestItem__c();
            item.MassiveLoaderRequest__c = massiveLoaderRequestId;
            item.Status__c = 'In attesa di lavorazione';

            //PROCESSO,ACCOUNTID,POD,CONTRATTO,UFFICIO_COMPETENTE,DATA_PAGAMENTO
            //Riattivazione Fornitura,0011X00000jcKXUQA2,IT001E00032928,3019602323,HCM,2021-12-23

            if(n>=0 && n<= 10){
                // errore arricchimento dati
                item.Data__c = 'Riattivazione Fornitura|0011X00000owtvoQAA|IT001E32452366|3019602323|HCM|2021-12-23';
            } else if(n>10 && n<=15){
                //success
                item.Data__c = 'Riattivazione Fornitura|0011X00000jcKXUQA2|IT001E00032928|3019602323|HCM|2021-12-23';
            
            } else if(n>15){
                //custom error
                item.Data__c = 'Riattivazione Fornitura|0011X00000jcKXUQA2|IT001E00032928|3019602323|HCM|2021-12-23';
            }
            itemsList.add(item);
        }
        insert itemsList;
    
        MassiveLoaderRequest__c mlr = new MassiveLoaderRequest__c();
        mlr.Id = massiveLoaderRequestId;
        mlr.Status__c = 'In attesa di lavorazione';
        update mlr;
    
    }*/

}