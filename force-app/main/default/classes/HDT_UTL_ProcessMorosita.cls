public with sharing virtual class HDT_UTL_ProcessMorosita extends  HDT_UTL_ProcessExecution {

    private Map<String, String> mapCaseFields;
    private Map<String, String> mapWrapperCaseFields;
    private List<MassiveLoaderRequestItem__c> itemsToSave;
    private Id recordTypeId;
    private Map<String, Id> podToCaseIdMap = new Map<String, Id>();
    private Map<String, Contract> contractMap = new Map<String, Contract>();
    private Map<String, List<String>> itemRequestMap = new Map<String, List<String>>();
    private Set<String> accountIdSet = new Set<String>();
    private Set<String> contractCodeSet = new Set<String>();
    private Set<String> podSet = new Set<String>();
    private Integer podIndex;
    private Integer accountIdIndex;
    private Integer contractIndex;


    public override void checks(){
        System.debug('checks');
        mapFieldsObject();

        podIndex = mapHeaderForWrapper.get(mapWrapperCaseFields.get('POD'));
        accountIdIndex = mapHeaderForWrapper.get(mapWrapperCaseFields.get('ACCOUNTID'));
        contractIndex = mapHeaderForWrapper.get(mapWrapperCaseFields.get('CONTRATTO'));

        List<String> dataSplitted;
        for(MassiveLoaderRequestItem__c item : currentProcess.currentRequestItemList){
            dataSplitted = item.Data__c.split(',');
            accountIdSet.add(dataSplitted[accountIdIndex]);
            contractCodeSet.add(dataSplitted[contractIndex]);
            podSet.add(dataSplitted[podIndex]);
            itemRequestMap.put(item.Id, dataSplitted);
        }

    }

    public override void getRecords(){
        System.debug('getRecords');
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
        System.debug('registryCreation');

        HDT_QR_CausalCodeCalculation causalCodeCalculation = new HDT_QR_CausalCodeCalculation();
        HDT_CausalCodeCalculation__mdt causalCode;
        List<Case> caseToInsert = new List<Case>();
        List<String> itemIds = new List<String>();
        itemsToSave = new List<MassiveLoaderRequestItem__c>();

        String type = 'Sospensione Fornitura';

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
            
                //if (mapRequiredByPosition.get(count) != null && String.isBlank(tempField)) {
                //    System.debug('>>> throw new HDT_WRP_ProcessEntitiesException');
                //   //throw new HDT_WRP_ProcessEntitiesException( 'Missing Required Field','Missing Required Field ' + mapHeaderByPosition.get(count));
                //}
            
                if(String.isNotBlank(mapCaseFields.get(mapHeaderByPosition.get(count))) && String.isNotBlank(tempField)){
                    System.debug('>>> tempField: ' + tempField + ' # Header: ' + mapHeaderByPosition.get(count) + ' # CaseFields: ' + mapCaseFields.get(mapHeaderByPosition.get(count)));
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

            if(podToCaseIdMap.containsKey(tempSplitted[podIndex])){
                newCase.ParentId = podToCaseIdMap.get(tempSplitted[podIndex]);
                //newCase.RelatedCase__c
            } else {
                itemsToSave.add(setErrorItem(itemId, 'pod non presente'));
                continue;
            }
            
            Contract contract;
            if(contractMap.containsKey(tempSplitted[contractIndex])){
                contract = contractMap.get(tempSplitted[contractIndex]);
                newCase.Contract__c = contract.Id;
                newCase.ServicePoint__c = contract.ServicePoint__c;
                newCase.BillingProfile__c = contract.BillingProfile__c;
            } else {
                itemsToSave.add(setErrorItem(itemId, 'contratto non presente'));
                continue;
            }

            newCase.RecordTypeId = recordTypeId;
            newCase.Status = 'In Lavorazione';
            newCase.Cluster__c = 'Morosità';
            newCase.Phase__c = 'Bozza';

            // ContactId ???

            causalCode = causalCodeCalculation.calculateCausalCode(this.processName, newCase.Type, '', contract.ServicePoint__r.CommoditySector__c); 

            if(causalCode != null){
                newCase.CausalCode__c = causalCode.CausalCode__c;//'D01' for example
            } else {
                //do something -> record error
            } 

            System.debug('>>> newCase: ' + String.valueOf(newCase));

            try{
                String arricchimentoResponse = HDT_WS_ArricchimentoDatiTemp.submitRequest(tempSplitted[podIndex], null);
                newCase = HDT_UTL_DataEnrichmentPostSales.handleResponse(arricchimentoResponse, newCase);
                caseToInsert.add(newCase); 
                itemIds.add(itemId);
            } catch(Exception e){
                itemsToSave.add(setErrorItem(itemId, 'Errore arricchimento dati # '));
            }

        }

        if(caseToInsert.size() > 0){

            HDT_UTL_ProcessCommonOperations.HDT_WRP_SaveResponse saveResponse = HDT_UTL_ProcessCommonOperations.databaseInsert(caseToInsert, itemIds);
            caseToInsert.clear();

            if(saveResponse.reponseItemList.size() > 0){
                itemsToSave.addAll(saveResponse.reponseItemList);
            }

            if(saveResponse.savedCase.size() > 0){
                Map<Id, String> compatibilityMap = HDT_UTL_ProcessCommonOperations.checkCompatibilityPostSales(saveResponse.savedCase);
                //System.debug('>>> compatibilityMap ' + String.valueOf(compatibilityMap));

                //***************** */
                // example to test Phase__c => Da Inviare           
                //Set<Id> i = compatibilityMap.keySet();
                //List<Id> listkey = new List<Id>();
                //listkey.addAll(i);
                //compatibilityMap.remove(listkey[0]);
                //***************** */

                HDT_UTL_ProcessCommonOperations.updateCaseAfterCompatibility(compatibilityMap, saveResponse.savedCase);

            }

        }  

    }

    public override void finalUpdate(){
        System.debug('finalUpdate');

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

    private static MassiveLoaderRequestItem__c setErrorItem(String itemId, String message){
        MassiveLoaderRequestItem__c itemError = new MassiveLoaderRequestItem__c();
        itemError.Id = itemId;
        itemError.Status__c = 'Errore';
        itemError.StatusDescription__c = message;
        return itemError;
    }

    public override void manageCatchException(Integer batchSize, List<MassiveLoaderRequestItem__c> itemList, String message){
        for(MassiveLoaderRequestItem__c item : itemList){
            item.Status__c = 'Errore';
            item.StatusDescription__c = message;
        }
        update itemList;
    }

    public static void setDataForTest(){

        Id massiveLoaderRequestId = 'a3d3O000000WuAYQA0';

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

            //PROCESSO,ACCOUNTID,POD,CONTRATTO,UFFICIO_COMPETENTE,DATA_PAGAMENTO
            //Riattivazione Fornitura,0011X00000jcKXUQA2,IT001E00032928,3019602323,HCM,2021-12-23

            if(n>=0 && n<= 10){
                // errore arricchimento dati
                item.Data__c = 'Riattivazione Fornitura,0011X00000owtvoQAA,IT001E32452366,3019602323,HCM,2021-12-23';
            } else if(n>10 && n<=15){
                //success
                item.Data__c = 'Riattivazione Fornitura,0011X00000jcKXUQA2,IT001E00032928,3019602323,HCM,2021-12-23';
    
            } else if(n>15){
                //custom error
                item.Data__c = 'Riattivazione Fornitura,0011X00000jcKXUQA2,IT001E00032928,3019602323,HCM,2021-12-23';
            }
            itemsList.add(item);
        }
        insert itemsList;
    
        MassiveLoaderRequest__c mlr = new MassiveLoaderRequest__c();
        mlr.Id = massiveLoaderRequestId;
        mlr.Status__c = 'In attesa di lavorazione';
        update mlr;
    
    }

}