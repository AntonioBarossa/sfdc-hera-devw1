@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_UTL_ProcessVariazioni extends HDT_UTL_ProcessExecution {

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
    private Id recordTypeId;
    private Integer podIndex;
    private Integer contractIndex;
    private Integer accountIdIndex;
    private Integer orderVolturaIndex;
    private String rifVoltura = 'RIF_VOLTURA';

    public override void checks(){
        System.debug(LoggingLevel.DEBUG, 'checks');
        mapFieldsObject();

        System.debug(LoggingLevel.DEBUG, '>>> mapCaseFields: ' + String.valueOf(mapCaseFields));
        System.debug(LoggingLevel.DEBUG, '>>> mapWrapperCaseFields: ' + String.valueOf(mapWrapperCaseFields));
        System.debug(LoggingLevel.DEBUG, '>>> mapHeaderForWrapper: ' + String.valueOf(mapHeaderForWrapper));
        System.debug(LoggingLevel.DEBUG, '>>> mapHeaderByPosition: ' + String.valueOf(mapHeaderByPosition));

        System.debug(LoggingLevel.DEBUG, '>>> sobjectMap: ' + String.valueOf(sobjectMap));

        podIndex = mapHeaderForWrapper.get(mapWrapperCaseFields.get('POD'));
        contractIndex = mapHeaderForWrapper.get(mapWrapperCaseFields.get('CONTRATTO'));
        accountIdIndex = mapHeaderForWrapper.get(mapWrapperCaseFields.get('ACCOUNTID'));

        if(mapWrapperCaseFields.containsKey(rifVoltura)){
            if(mapHeaderForWrapper.containsKey(mapWrapperCaseFields.get(rifVoltura))){
                orderVolturaIndex = mapHeaderForWrapper.get(mapWrapperCaseFields.get(rifVoltura));
            }
        }
        
        HDT_WRP_ProcessObjects processObj;
        processObjList = new List<HDT_WRP_ProcessObjects>();
        for(MassiveLoaderRequestItem__c item : currentProcess.currentRequestItemList){
            processObj = new HDT_WRP_ProcessObjects();
            processObj.requestItem = item;
            processObj.csvSplitted = item.Data__c.split(splitCharacter, -1);

            accountIdSet.add(processObj.csvSplitted[accountIdIndex]);
            contractCodeSet.add(processObj.csvSplitted[contractIndex]);

            processObjList.add(processObj);

            if(orderVolturaIndex != null)
                orderNumberList.add(processObj.csvSplitted[orderVolturaIndex]);
        }

    }

    public override void getRecords(){
        System.debug(LoggingLevel.DEBUG, 'getRecords');

        contractList = HDT_QR_ProcessPostSales.getContracts(contractList, contractCodeSet);
        orderList = HDT_QR_ProcessPostSales.getOrderByOrderNumber(orderList, orderNumberList);

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

    }

    public override void registryCreation(){
        System.debug(LoggingLevel.DEBUG, 'registryCreation');

        HDT_UTL_ProcessCommonOperations.getLimitDetails('START registryCreation');

        List<Case> caseToInsert = new List<Case>();
        List<MassiveLoaderRequestItem__c> requestItemForUpsert;
        itemsToSave = new List<MassiveLoaderRequestItem__c>();
        requestItemForUpsert = new List<MassiveLoaderRequestItem__c>();

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
            
                if (mapRequiredByPosition.get(count) != null && String.isBlank(tempField)) {
                    System.debug(LoggingLevel.DEBUG, '>>> throw new HDT_WRP_ProcessEntitiesException');
                    //throw new HDT_WRP_ProcessEntitiesException( 'Missing Required Field', 'Missing Required Field: ' + mapHeaderByPosition.get(count));
                    convertionError = 'Missing Required Field: ' + mapHeaderByPosition.get(count);
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
                //itemsToSave.add(setErrorItem(itemId, convertionError));
                processObj.requestItem.Status__c = 'Errore';
                processObj.requestItem.StatusDescription__c = convertionError;
                itemsToSave.add(processObj.requestItem);
                continue;
            }

            System.debug(LoggingLevel.DEBUG, '>>> currentCase: ' + processObj.newCase);
            Contract contract;
            
            if(contractMap.containsKey(processObj.csvSplitted[contractIndex])){
                contract = contractMap.get(processObj.csvSplitted[contractIndex]);
                processObj.newCase.Contract__c = contract.Id;
                processObj.newCase.ServicePoint__c = contract.ServicePoint__c;
                processObj.newCase.BillingProfile__c = contract.BillingProfile__c;
            } else {
                //itemsToSave.add(setErrorItem(itemId, 'pod non presente'));
                processObj.requestItem.Status__c = 'Errore';
                processObj.requestItem.StatusDescription__c = 'pod non presente';
                itemsToSave.add(processObj.requestItem);
                continue;
            }
                        
            if(!String.isEmpty(contract.ServicePoint__r.CommoditySector__c)){
                causalCode = causalCodeCalculation.calculateCausalCode(this.processName, processObj.newCase.Type, '', contract.ServicePoint__r.CommoditySector__c); 

                if(causalCode != null){
                    processObj.newCase.CausalCode__c = causalCode.CausalCode__c;//'D01' for example
                } else {
                    //do something -> record error
                }

                currentRecordTypeId = recordTypeMap.get(contract.ServicePoint__r.CommoditySector__c);
            }

            processObj.newCase.AccountId = processObj.csvSplitted[accountIdIndex];
            processObj.newCase.Cluster__c = 'Variazioni';
            processObj.newCase = HDT_UTL_ProcessCommonOperations.setCaseField(processObj.newCase, currentRecordTypeId);

            if(processObj.newCase.Type.equalsIgnoreCase('Cambio contatore non registrato') && orderVolturaIndex != null){
                String currentOrderNum = processObj.csvSplitted[orderVolturaIndex];
                if(orderIdsMap.containsKey(currentOrderNum)){
                    processObj.newCase.VulturePracticeReference__c = orderIdsMap.get(currentOrderNum);
                } else {
                    System.debug(LoggingLevel.DEBUG, '>>> NO ORDER FOUND');
                }
            }

            try{
                String arricchimentoResponse = HDT_WS_ArricchimentoDatiTemp.submitRequest(processObj.csvSplitted[podIndex], null);
                System.debug(LoggingLevel.DEBUG, '>>> arricchimentoResponse: ' + arricchimentoResponse);
                processObj.newCase = HDT_UTL_DataEnrichmentPostSales.handleResponse(arricchimentoResponse, processObj.newCase);
                //processObj.newCase.Taxes__c = null;
                caseToInsert.add(processObj.newCase); 
                requestItemForUpsert.add(processObj.requestItem);
            } catch(Exception e){
                System.debug(LoggingLevel.DEBUG, '>>> arricchimentoError ' + e.getMessage());
                //itemsToSave.add(setErrorItem(itemId, 'Errore arricchimento dati # '));
                processObj.requestItem.Status__c = 'Errore';
                processObj.requestItem.StatusDescription__c = 'Errore arricchimento dati # ';
                itemsToSave.add(processObj.requestItem);
            }

        }

        if(caseToInsert.size() > 0){

            HDT_UTL_ProcessCommonOperations.HDT_WRP_SaveResponse saveResponse;
            saveResponse = HDT_UTL_ProcessCommonOperations.databaseUpsert(caseToInsert, requestItemForUpsert, 'Case');
            runAlignment(saveResponse.savedObject);
            caseToInsert.clear();

            HDT_UTL_ProcessCommonOperations.getLimitDetails('AFTER CASE CREATION / Enrichment / Alignment');

            if(saveResponse.reponseItemList.size() > 0){
                itemsToSave.addAll(saveResponse.reponseItemList);
            }

            if(saveResponse.savedObject.size() > 0){
                HDT_UTL_ProcessCommonOperations.runCompatibility(saveResponse.savedObject);
                HDT_UTL_ProcessCommonOperations.getLimitDetails('AFTER CASE Compatibility');
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

    /*public static void setDataForTest(Integer numRecords){

        Id massiveLoaderRequestId = 'a3d3O000000WwZOQA0';
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
            item.Data__c = '';
            item.Data__c += 'Variazione indirizzo di fornitura|';// PROCESSO
            item.Data__c += '0011X00000pJuhFQAS|';// ACCOUNTID
            item.Data__c += '|';// SOTTOPROCESSO
            item.Data__c += '15750000008418|';// POD
            item.Data__c += '3019671256|';// CONTRATTO
            item.Data__c += '|';// ELEMENTI_DETTAGLIO
            item.Data__c += '|';// SERVIZIO_ENERGIA
            item.Data__c += '|';// DATA_VARIAZIONE
            item.Data__c += '|';// MATRICOLA
            item.Data__c += '|';// RIF_VOLTURA
            item.Data__c += '|';// NOTE_DL
            item.Data__c += '|';// CORRETTORE
            item.Data__c += '|';// DATA_LETTURA
            item.Data__c += '|';// DATA_VAR_RESIDENZA
            item.Data__c += '|';// RESIDENTE
            item.Data__c += 'VIA RANUCCI RENATO 1 , FERRARA FE, 44100 ITALIA|';// INDIRIZZO_FORN
            item.Data__c += 'FERRARA|';// COMUNE
            item.Data__c += 'ITALIA|';// NAZIONE
            item.Data__c += '|';// LOCALITA
            item.Data__c += '44100|';// CAP
            item.Data__c += 'FE|';// PROVINCIA
            item.Data__c += 'VIA RANUCCI RENATO|';// VIA
            item.Data__c += '1|';// CIVICO
            item.Data__c += '|';// ESTENSIONE_CIVICO
            item.Data__c += '004-Uso tecnologico|';// CATEGORIA_USO
            item.Data__c += '|';// TIPO_FORNITURA
            item.Data__c += '|';// TIPO_IMPIANTO
            item.Data__c += '|';// IMPOSTE
            item.Data__c += '|';// DATA_DECORRENZA
            item.Data__c += ''; // IVA
            itemsList.add(item);
        }
        insert itemsList;
    
        MassiveLoaderRequest__c mlr = new MassiveLoaderRequest__c();
        mlr.Id = massiveLoaderRequestId;
        mlr.Status__c = 'In attesa di lavorazione';
        update mlr;
    
    }*/

}