@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_UTL_ProcessDisattivazioni extends  HDT_UTL_ProcessExecution {

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
    private Map<String, List<String>> itemRequestMap = new Map<String, List<String>>();
    private Map<String, String> accountContactMap = new Map<String, String>();
    private Map<String, Contract> podContractMap = new Map<String, Contract>();
    private Integer podIndex;
    private Integer contractIndex;
    private Integer accountIdIndex;
    private Integer orderVolturaIndex;
    private Boolean isVolturaProcess;

    public override void checks(){
        System.debug(LoggingLevel.DEBUG, 'checks');

        System.debug(LoggingLevel.DEBUG, '>>> this.processName: ' + this.processName);

        mapFieldsObject();

        System.debug(LoggingLevel.DEBUG, '>>> mapCaseFields: ' + String.valueOf(mapCaseFields));
        System.debug(LoggingLevel.DEBUG, '>>> mapWrapperCaseFields: ' + String.valueOf(mapWrapperCaseFields));
        System.debug(LoggingLevel.DEBUG, '>>> mapHeaderForWrapper: ' + String.valueOf(mapHeaderForWrapper));
        System.debug(LoggingLevel.DEBUG, '>>> mapHeaderByPosition: ' + String.valueOf(mapHeaderByPosition));

        isVolturaProcess = (this.processName == 'VolturaTecnica') ? true : false;

        podIndex = mapHeaderForWrapper.get(mapWrapperCaseFields.get('POD'));
        contractIndex = mapHeaderForWrapper.get(mapWrapperCaseFields.get('CONTRATTO'));
        accountIdIndex = mapHeaderForWrapper.get(mapWrapperCaseFields.get('ACCOUNTID'));

        if(!isVolturaProcess){
            orderVolturaIndex = mapHeaderForWrapper.get(mapWrapperCaseFields.get('ORDER_VOLTURA'));
        }

        System.debug(LoggingLevel.DEBUG, '>>> Index: podIndex [' + podIndex + ']; contract [' + contractIndex + ']; accountId [' + accountIdIndex + ']; orderVoltura [' + orderVolturaIndex + ']');

        List<String> dataSplitted;
        for(MassiveLoaderRequestItem__c item : currentProcess.currentRequestItemList){
            dataSplitted = item.Data__c.split(',');
            accountIdSet.add(dataSplitted[accountIdIndex]);
            contractCodeSet.add(dataSplitted[contractIndex]);
            itemRequestMap.put(item.Id, dataSplitted);

            if(!isVolturaProcess){
                orderNumberList.add(dataSplitted[orderVolturaIndex]);
            }

        }

    }

    public override void getRecords(){
        System.debug(LoggingLevel.DEBUG, 'getRecords');

        String rtDeveloperName = '';
        contractList = HDT_QR_ProcessPostSales.getContracts(contractList, contractCodeSet);
        accContRelationList = HDT_QR_ProcessPostSales.getAccountContactRelationIdsList(accContRelationList, accountIdSet, 'Titolare');
        
        //System.debug(LoggingLevel.DEBUG, '>>> accountIdSet ' + String.valueOf(accountIdSet));
        //System.debug(LoggingLevel.DEBUG, '>>> podSet ' + String.valueOf(podSet));
        //System.debug(LoggingLevel.DEBUG, '>>> contractList ' + String.valueOf(contractList));
        //System.debug(LoggingLevel.DEBUG, '>>> orderList ' + String.valueOf(orderList));

        if(!isVolturaProcess){

            rtDeveloperName = 'HDT_RT_Disattivazioni';
            orderList = HDT_QR_ProcessPostSales.getOrderByOrderNumber(orderList, orderNumberList);

            for(Order o : orderList){
                orderIdMap.put(o.OrderNumber, o.Id);
            }

        } else {
            rtDeveloperName = 'HDT_RT_VolturaTecnica';
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

        HDT_UTL_ProcessCommonOperations.getLimitDetails('START registryCreation');

        List<Case> caseToInsert = new List<Case>();
        List<String> itemIds = new List<String>();
        itemsToSave = new List<MassiveLoaderRequestItem__c>();

        HDT_QR_CausalCodeCalculation causalCodeCalculation = new HDT_QR_CausalCodeCalculation();
        HDT_CausalCodeCalculation__mdt causalCode;

        //System.debug(LoggingLevel.DEBUG, '>>> currentRequestItemList: ' + String.valueOf(currentProcess.currentCase));
        //System.debug(LoggingLevel.DEBUG, '>>> get mapCaseFields: ' + mapCaseFields.get(mapHeaderByPosition.get(count)));

        Case newCase;
        for(String itemId : itemRequestMap.keySet()){

            List<String> tempSplitted = itemRequestMap.get(itemId);
            newCase = new Case();
            // Per ogni item della mappa itemRequestMap viene convertito il data__c in una lista (tempSplitted) e tramite il metodo mapTypeField la lista viene
            // convertita nel custom obj indicato, in questo caso è currentProcess.currentCase

            Integer count = 0;
            String convertionError;
            for (String tempField : tempSplitted) {

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
                    convertionError = mapTypeField(newCase, mapCaseFields, count, tempField);

                    if(!String.isEmpty(convertionError)){
                        // error happened -> exit
                        break;
                    }
                }
                count++;
            }

            if(!String.isEmpty(convertionError)){
                itemsToSave.add(setErrorItem(itemId, convertionError));
                continue;
            }

            //System.debug(LoggingLevel.DEBUG, '>>> currentCase: ' + newCase);

            Contract contract;
            
            if(podContractMap.containsKey(tempSplitted[contractIndex])){
                contract = podContractMap.get(tempSplitted[contractIndex]);
                newCase.Contract__c = contract.Id;
                newCase.ServicePoint__c = contract.ServicePoint__c;
                newCase.BillingProfile__c = contract.BillingProfile__c;
            } else {
                itemsToSave.add(setErrorItem(itemId, 'pod non presente'));
                continue;
            }
            
            String accountId = tempSplitted[accountIdIndex];
            newCase.AccountId = accountId;

            if(accountContactMap.containsKey(accountId)){
                newCase.ContactId = accountContactMap.get(accountId);
            } else {
                itemsToSave.add(setErrorItem(itemId, 'account non presente'));
                continue;
            }

            newCase.Cluster__c = 'Disattivazioni';
            newCase = HDT_UTL_ProcessCommonOperations.setCaseField(newCase, recordTypeId);
            
            if(!String.isEmpty(contract.ServicePoint__r.CommoditySector__c)){
                causalCode = causalCodeCalculation.calculateCausalCode(this.processName, newCase.Type, '', contract.ServicePoint__r.CommoditySector__c); 

                if(causalCode != null){
                    newCase.CausalCode__c = causalCode.CausalCode__c;//'D01' for example
                } else {
                    //do something -> record error
                }
            }

            if(newCase.Type.equalsIgnoreCase('Recesso per Rifiuto Voltura')){
                String currentOrderNum = tempSplitted[orderVolturaIndex];
                if(orderIdMap.containsKey(currentOrderNum)){
                    newCase.VulturePracticeReference__c = orderIdMap.get(currentOrderNum);
                } else {
                    System.debug(LoggingLevel.DEBUG, '>>> NO ORDER FOUND');
                }
            }

            // only to test insert failure
            //if(tempSplitted[8]=='customError')
            //    newCase.CareOf__c = 'abcdefghilmnopqrstuvzabcdefghilmnopqrstuvz';

            try{
                String arricchimentoResponse = HDT_WS_ArricchimentoDatiTemp.submitRequest(tempSplitted[podIndex], null);
                newCase = HDT_UTL_DataEnrichmentPostSales.handleResponse(arricchimentoResponse, newCase);
                caseToInsert.add(newCase); 
                itemIds.add(itemId);
            } catch(Exception e){
                System.debug(LoggingLevel.DEBUG, '>>> arricchimentoError ' + e.getMessage());
                itemsToSave.add(setErrorItem(itemId, 'Errore arricchimento dati # '));
            }

        }

        if(caseToInsert.size() > 0){

            HDT_UTL_ProcessCommonOperations.HDT_WRP_SaveResponse saveResponse;
            saveResponse = HDT_UTL_ProcessCommonOperations.databaseInsert(caseToInsert, itemIds);

            caseToInsert.clear();

            HDT_UTL_ProcessCommonOperations.getLimitDetails('AFTER CASE CREATION & Enrichment');

            if(saveResponse.reponseItemList.size() > 0){
                itemsToSave.addAll(saveResponse.reponseItemList);
            }

            if(saveResponse.savedCase.size() > 0){
                HDT_UTL_ProcessCommonOperations.runCompatibility(saveResponse.savedCase);
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

    public static void setDataForTest(){
        delete [SELECT Id FROM MassiveLoaderRequestItem__c WHERE MassiveLoaderRequest__c ='a3d3O000000WlXDQA0'];
        delete [
            SELECT Id, Type, AccountId, NotPerformedBefore__c, WrittenReceiptRequestDate__c, CustomerRecessDate__c, VulturePracticeReference__c,
                   DistributorNote__c, ServicePoint__c, BillingProfile__c, Contract__c, RecordTypeId, ContactId, CausalCode__c, 
                   Phase__c, Status, CancellationReason__c
            FROM Case
            WHERE Createddate = today AND CreatedById = '0051X0000055rbNQAQ'
        ];
    
        List<MassiveLoaderRequestItem__c> itemsList = new List<MassiveLoaderRequestItem__c>();
        MassiveLoaderRequestItem__c item;
    
        for(Integer n=0; n<20; n++){
            item = new MassiveLoaderRequestItem__c();
            item.MassiveLoaderRequest__c = 'a3d3O000000WlXDQA0';
            item.Status__c = 'In attesa di lavorazione';
            if(n>=0 && n<= 10){
                item.Data__c = 'Chiusura Contatore,0011X00000owtvoQAA,IT001E32452366,3019602323,2021-12-23,2021-11-23,2021-10-23,x,errorArrich';
            } else if(n>10 && n<=15){
                switch on n {
                    when 11 {
                        item.Data__c = 'Chiusura Contatore,0011X00000jcKXUQA2,IT001E00032928,3019602323,2021-12-23,2021-11-23,2021-10-23,00000155,success';
                    }	
                    when 12 {
                        item.Data__c = 'Recesso per altri motivi,0011X00000jcKXUQA2,IT001E00032928,3019602323,2021-12-23,2021-11-23,2021-10-23,00000157,success';
                    }
                    when 13 {
                        item.Data__c = 'Recesso per rifiuto voltura,0011X00000jcKXUQA2,IT001E00032928,3019602323,2021-12-23,2021-11-23,2021-10-23,00000160,success';
                    }
                    when 14 {
                        item.Data__c = 'Chiusura Contatore,0011X00000jcKXUQA2,IT001E00032928,3019602323,2021-12-23,2021-11-23,2021-10-23,00000166,success';
                    }
                    when 15 {
                        item.Data__c = 'Chiusura Contatore,0011X00000jcKXUQA2,IT001E00032928,3019602323,2021-12-23,2021-11-23,2021-10-23,00000168,success';
                    }
                }
    
            } else if(n>15){
                item.Data__c = 'Chiusura Contatore,0011X00000jcKXUQA2,IT001E00032928,3019602323,2021-12-23,2021-11-23,x,x,customError';
            }
            itemsList.add(item);
        }
        insert itemsList;
    
        MassiveLoaderRequest__c mlr = new MassiveLoaderRequest__c();
        mlr.Id = 'a3d3O000000WlXDQA0';
        mlr.Status__c = 'In attesa di lavorazione';
        update mlr;
    
    }

    public static void setDataForTest_VolturaTecnica(){

        Id massiveLoaderRequestId = 'a3d3O000000WuVlQAK';

        delete [SELECT Id FROM MassiveLoaderRequestItem__c WHERE MassiveLoaderRequest__c = :massiveLoaderRequestId];
        delete [
            SELECT Id, Type, AccountId, NotPerformedBefore__c, WrittenReceiptRequestDate__c, CustomerRecessDate__c, VulturePracticeReference__c,
                   DistributorNote__c, ServicePoint__c, BillingProfile__c, Contract__c, RecordTypeId, ContactId, CausalCode__c, 
                   Phase__c, Status, CancellationReason__c
            FROM Case
            WHERE Createddate = today AND CreatedById = '0051X0000055rbNQAQ'
        ];
    
        List<MassiveLoaderRequestItem__c> itemsList = new List<MassiveLoaderRequestItem__c>();
        MassiveLoaderRequestItem__c item;
    
        for(Integer n=0; n<20; n++){
            item = new MassiveLoaderRequestItem__c();
            item.MassiveLoaderRequest__c = massiveLoaderRequestId;
            item.Status__c = 'In attesa di lavorazione';
            item.Data__c = 'Chiusura Contatore,0011X00000jcKXUQA2,IT001E00032928,3019602323,Ordinaria,No';
            itemsList.add(item);
        }
        insert itemsList;
    
        MassiveLoaderRequest__c mlr = new MassiveLoaderRequest__c();
        mlr.Id = massiveLoaderRequestId;
        mlr.Status__c = 'In attesa di lavorazione';
        update mlr;
    
    }

}