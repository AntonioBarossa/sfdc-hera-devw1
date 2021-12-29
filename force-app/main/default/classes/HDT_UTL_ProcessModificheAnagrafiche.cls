public with sharing class HDT_UTL_ProcessModificheAnagrafiche extends HDT_UTL_ProcessExecution {

    private Map<String, String> mapCaseFields;
    private Map<String, String> mapWrapperCaseFields;
    private Map<String, String> mapContactFields;
    private Map<String, String> mapBillingProfileFields;
    private Map<String, String> mapAccountFields;
    private Set<String> accountIdSet = new Set<String>();
    private Set<String> contractCodeSet = new Set<String>();
    private Map<String, List<String>> itemRequestMap = new Map<String, List<String>>();
    private List<MassiveLoaderRequestItem__c> itemsToSave;
    private Map<String, String> accountContactMap = new Map<String, String>();
    private List<AccountContactRelation> accContRelationList;
    private Id recordTypeId;
    private Integer contractIndex;
    private Integer accountIdIndex;

    public override void checks(){
        System.debug('checks');
        mapFieldsObject();

        accountIdIndex = mapHeaderForWrapper.get(mapWrapperCaseFields.get('ACCOUNTID'));
        contractIndex = mapHeaderForWrapper.get(mapWrapperCaseFields.get('CONTO_CONTRATTUALE'));

        List<String> dataSplitted;
        for(MassiveLoaderRequestItem__c item : currentProcess.currentRequestItemList){
            dataSplitted = item.Data__c.split(',');
            accountIdSet.add(dataSplitted[accountIdIndex]);
            contractCodeSet.add(dataSplitted[contractIndex]);
            itemRequestMap.put(item.Id, dataSplitted);
        }

    }

    public override void getRecords(){
        System.debug('getRecords');

        //contractList = HDT_QR_ProcessPostSales.getContracts(contractList, contractCodeSet);
        accContRelationList = HDT_QR_ProcessPostSales.getAccountContactRelationList(accContRelationList, accountIdSet, 'Titolare');
        recordTypeId = HDT_QR_ProcessPostSales.getRecordTypeId('HDT_RT_VariazioneAnagraficaCliente');

        //System.debug('>>> accountIdSet ' + String.valueOf(accountIdSet));
        //System.debug('>>> podSet ' + String.valueOf(podSet));
        //System.debug('>>> contractList ' + String.valueOf(contractList));
        //System.debug('>>> orderList ' + String.valueOf(orderList));

        //for(Contract singleContract : contractList){
        //    podContractMap.put(singleContract.SAPContractCode__c, singleContract);
        //}

        for(AccountContactRelation singleRelation : accContRelationList){
            accountContactMap.put(singleRelation.AccountId, singleRelation.ContactId);
        }
        
    }

    public override void registryCreation(){
        System.debug('registryCreation');

        HDT_UTL_ProcessCommonOperations.getLimitDetails('START registryCreation');

        List<Case> caseToInsert = new List<Case>();
        List<String> itemIds = new List<String>();
        itemsToSave = new List<MassiveLoaderRequestItem__c>();

        Case newCase;
        BillingProfile__c billProf;
        Contact contact;
        Account acc;
        for(String itemId : itemRequestMap.keySet()){

            List<String> tempSplitted = itemRequestMap.get(itemId);
            newCase = new Case();
            billProf = new BillingProfile__c();
            contact = new Contact();
            acc = new Account();

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

                if(String.isNotBlank(mapContactFields.get(mapHeaderByPosition.get(count))) && String.isNotBlank(tempField)){
                    System.debug('>>> tempField: ' + tempField + ' # Header: ' + mapHeaderByPosition.get(count) + ' # contactFields: ' + mapContactFields.get(mapHeaderByPosition.get(count)));
                    convertionError = mapTypeField(contact, mapContactFields, count, tempField);

                    if(!String.isEmpty(convertionError)){
                        // error happened -> exit
                        break;
                    }
                }

                if(String.isNotBlank(mapBillingProfileFields.get(mapHeaderByPosition.get(count))) && String.isNotBlank(tempField)){
                    System.debug('>>> tempField: ' + tempField + ' # Header: ' + mapHeaderByPosition.get(count) + ' # billProfFields: ' + mapBillingProfileFields.get(mapHeaderByPosition.get(count)));
                    convertionError = mapTypeField(billProf, mapBillingProfileFields, count, tempField);

                    if(!String.isEmpty(convertionError)){
                        // error happened -> exit
                        break;
                    }
                }

                if(String.isNotBlank(mapAccountFields.get(mapHeaderByPosition.get(count))) && String.isNotBlank(tempField)){
                    System.debug('>>> tempField: ' + tempField + ' # Header: ' + mapHeaderByPosition.get(count) + ' # accountFields: ' + mapAccountFields.get(mapHeaderByPosition.get(count)));
                    convertionError = mapTypeField(acc, mapAccountFields, count, tempField);

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

            System.debug('>>> currentCase: ' + newCase);
            System.debug('>>> currentContact: ' + contact);
            System.debug('>>> currentbillProf: ' + billProf);
            System.debug('>>> currentAccount: ' + acc);

            //Contract contract;
            //if(podContractMap.containsKey(tempSplitted[contractIndex])){
            //    contract = podContractMap.get(tempSplitted[contractIndex]);
            //    newCase.Contract__c = contract.Id;
            //    newCase.ServicePoint__c = contract.ServicePoint__c;
            //    newCase.BillingProfile__c = contract.BillingProfile__c;
            //} else {
            //    itemsToSave.add(setErrorItem(itemId, 'pod non presente'));
            //    continue;
            //}
            
            continue;

            String accountId = tempSplitted[accountIdIndex];
            newCase.AccountId = accountId;

            if(accountContactMap.containsKey(accountId)){
                newCase.ContactId = accountContactMap.get(accountId);
            } else {
                itemsToSave.add(setErrorItem(itemId, 'account non presente'));
                continue;
            }

            newCase.RecordTypeId = recordTypeId;
            newCase.Status = 'In Lavorazione';
            newCase.Cluster__c = 'Modifiche Anagrafiche';
            newCase.Phase__c = 'Bozza';
            newCase.CompanyOwner__c = 'HERA COMM';

        }

        if(caseToInsert.size() > 0){

            HDT_UTL_ProcessCommonOperations.HDT_WRP_SaveResponse saveResponse;
            saveResponse = HDT_UTL_ProcessCommonOperations.databaseInsert(caseToInsert, itemIds);

            caseToInsert.clear();

            HDT_UTL_ProcessCommonOperations.getLimitDetails('AFTER CASE CREATION & Enrichment');

            if(saveResponse.reponseItemList.size() > 0){
                itemsToSave.addAll(saveResponse.reponseItemList);
            }

        }  

    }

    public override void finalUpdate(){
        System.debug('finalUpdate');

        if(itemsToSave.size() > 0){
            update itemsToSave;
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

    private void mapFieldsObject(){

        List<HDT_MassiveFieldsObjectMap__mdt> listCaseFields;
        List<HDT_MassiveFieldsObjectMap__mdt> listWrapperCaseFields;
        List<HDT_MassiveFieldsObjectMap__mdt> listContactFields;
        List<HDT_MassiveFieldsObjectMap__mdt> listBillingProfileFields;
        List<HDT_MassiveFieldsObjectMap__mdt> listAccountFields;
        mapCaseFields = new Map<String, String>();
        mapWrapperCaseFields = new Map<String, String>();
        mapContactFields = new Map<String, String>();
        mapBillingProfileFields = new Map<String, String>();
        mapAccountFields = new Map<String, String>();

        listCaseFields = getMapFieldsObject('Case', this.processName);
        listWrapperCaseFields = getMapFieldsObject('WrapperCase', this.processName);
        listContactFields = getMapFieldsObject('Contact', this.processName);
        listBillingProfileFields = getMapFieldsObject('BillingProfile__c', this.processName);
        listAccountFields = getMapFieldsObject('Account', this.processName);

        for(HDT_MassiveFieldsObjectMap__mdt temp : listCaseFields){
            mapCaseFields.put(temp.labelField__c, temp.nameField__c);
        }

        for(HDT_MassiveFieldsObjectMap__mdt temp : listWrapperCaseFields){
            mapWrapperCaseFields.put(temp.labelField__c, temp.nameField__c);
        }

        for(HDT_MassiveFieldsObjectMap__mdt temp : listContactFields){
            mapContactFields.put(temp.labelField__c, temp.nameField__c);
        }

        for(HDT_MassiveFieldsObjectMap__mdt temp : listBillingProfileFields){
            mapBillingProfileFields.put(temp.labelField__c, temp.nameField__c);
        }

        for(HDT_MassiveFieldsObjectMap__mdt temp : listAccountFields){
            mapAccountFields.put(temp.labelField__c, temp.nameField__c);
        }

    }

    public static void setDataForTest_ModificheAnagrafiche(){

        Id massiveLoaderRequestId = 'a3d3O000000WuVqQAK';

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
    
        for(Integer n=0; n<1; n++){
            item = new MassiveLoaderRequestItem__c();
            item.MassiveLoaderRequest__c = massiveLoaderRequestId;
            item.Status__c = 'In attesa di lavorazione';
            item.Data__c = 'Variazione Anagrafica Cliente,0011X00000jcKXUQA2,,contoCode,3336560123,,,,,,Cartaceo,,,,,,,,,,,,,,,,,,,,ADAM,,,,,,,,,,,,,,,';
            itemsList.add(item);
        }
        insert itemsList;
    
        MassiveLoaderRequest__c mlr = new MassiveLoaderRequest__c();
        mlr.Id = massiveLoaderRequestId;
        mlr.Status__c = 'In attesa di lavorazione';
        update mlr;
    
    }

}