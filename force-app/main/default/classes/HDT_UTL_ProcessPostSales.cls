public with sharing class HDT_UTL_ProcessPostSales extends  HDT_UTL_ProcessExecution {

    //HDT_BA_ProcessRequestItem processReq = new HDT_BA_ProcessRequestItem('a3d3O000000WlXDQA0', 20, 'PostSales'); 
    //Database.executeBatch(processReq, 20);

    private Map<String, String> mapCaseFields;

    public override void checks(){
        System.debug('checks');
        mapFieldsObject();
        System.debug('>>> mapCaseFields: ' + String.valueOf(mapCaseFields));
        System.debug('>>> mapHeaderByPosition: ' + String.valueOf(mapHeaderByPosition));
        System.debug('>>> mapRequiredByPosition: ' + String.valueOf(mapRequiredByPosition));
    }

    public override void getRecords(){
        System.debug('getRecords');
    }

    public override void registryCreation(){
        System.debug('registryCreation');

        Set<String> podSet = new Set<String>();
        Set<String> accountIdSet = new Set<String>();
        List<Contract> contractList;
        Map<String, List<String>> itemRequestMap = new Map<String, List<String>>();
        Map<String, String> accountContactMap = new Map<String, String>();
        Map<String, Contract> podContractMap = new Map<String, Contract>();
        List<AccountContactRelation> accContRelationList;
        Id recordTypeId;// = Schema.SObjectType.Case.getRecordTypeInfosByName().get('HDT_RT_Disattivazioni').getRecordTypeId();
        List<Case> caseToInsert = new List<Case>();
        List<String> itemIds = new List<String>();
        List<MassiveLoaderRequestItem__c> itemErrorToSave;

        recordTypeId = HDT_QR_ProcessPostSales.getRecordTypeId('HDT_RT_Disattivazioni');

        System.debug('>>> currentRequestItemList: ' + String.valueOf(currentProcess.currentRequestItemList));

        List<String> dataSplitted;
        for(MassiveLoaderRequestItem__c item : currentProcess.currentRequestItemList){
            dataSplitted = item.Data__c.split(',');
            accountIdSet.add(dataSplitted[1]);
            podSet.add(dataSplitted[2]);
            itemRequestMap.put(item.Id, dataSplitted);
        }

        contractList = HDT_QR_ProcessPostSales.getContracts(podSet, contractList);

        System.debug('>>> accountIdSet ' + String.valueOf(accountIdSet));
        System.debug('>>> podSet ' + String.valueOf(podSet));
        System.debug('>>> contractList ' + String.valueOf(contractList));

        for(Contract singleContract : contractList){
            podContractMap.put(singleContract.ServicePoint__r.ServicePointCode__c, singleContract);
        }

        accContRelationList = HDT_QR_ProcessPostSales.getAccountContactRelationList(accContRelationList, accountIdSet, 'Titolare');

        for(AccountContactRelation singleRelation : accContRelationList){
            accountContactMap.put(singleRelation.AccountId, singleRelation.ContactId);
        }

        Case newCase;
        for(String itemId : itemRequestMap.keySet()){

            List<String> tempSplitted = itemRequestMap.get(itemId);

            newCase = new Case();
            newCase.RecordTypeId = recordTypeId;

            Contract contract;
            
            if(podContractMap.containsKey(tempSplitted[2])){
                contract = podContractMap.get(tempSplitted[2]);
                newCase.Contract__c = contract.Id;
                newCase.ServicePoint__c = contract.ServicePoint__c;
                newCase.BillingProfile__c = contract.BillingProfile__c;
            }
            
            String accountId = tempSplitted[1];
            newCase.AccountId = accountId;

            if(accountContactMap.containsKey(accountId)){
                newCase.ContactId = accountContactMap.get(accountId);
            }

            newCase.Type = 'Chiusura Contatore';
            newCase.Status = 'In Lavorazione';
            newCase.Cluster__c = 'Disattivazioni';
            newCase.Phase__c = 'Bozza';
            newCase.CompanyOwner__c = 'HERA COMM';
            newCase.CausalCode__c = 'D01';

            // only to test insert failure
            newCase.CareOf__c = 'abcdefghilmnopqrstuvzabcdefghilmnopqrstuvz';

            String arricchimentoResponse = HDT_WS_ArricchimentoDatiTemp.submitRequest(tempSplitted[2], null);
            newCase = HDT_UTL_DataEnrichmentPostSales.handleResponse(arricchimentoResponse, newCase);
            caseToInsert.add(newCase);

        }

        System.debug('>>> caseToInsert ' + String.valueOf(caseToInsert));
        
        itemIds.addAll(itemRequestMap.keySet());
        itemErrorToSave = databaseInsert(caseToInsert, itemIds, itemErrorToSave);

        if(itemErrorToSave.size() > 0){
            update itemErrorToSave;
        }

    }

    //public override void makeProcess(){ // creazione processo
    //    System.debug('makeProcess');
    //}

    public override void finalUpdate(){
        System.debug('finalUpdate');
    }


    private void mapFieldsObject(){
        List<HDT_MassiveFieldsObjectMap__mdt> listCaseFields = getMapFieldsObject('Case', this.processName);
        mapCaseFields = new Map<String, String>();

        for(HDT_MassiveFieldsObjectMap__mdt temp : listCaseFields){
            mapCaseFields.put(temp.labelField__c, temp.nameField__c);
        }
    }

    public static List<MassiveLoaderRequestItem__c> databaseInsert(List<Case> itemList, List<String> itemIds, List<MassiveLoaderRequestItem__c> itemErrorToSave){

        itemErrorToSave = new List<MassiveLoaderRequestItem__c>();

        SObjectType objtype = Schema.getGlobalDescribe().get('Case');
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();
 
        if(objRes.isCreateable()){

            List<Database.SaveResult> insertResults = Database.insert(itemList, false);

            for(Integer n=0; n<insertResults.size(); n++){
                Database.SaveResult sr = insertResults[n];

                if (!sr.isSuccess()) {
                    
                    MassiveLoaderRequestItem__c itemError;
                    for(Database.Error err : sr.getErrors()) {
                        itemError = new MassiveLoaderRequestItem__c();
                        itemError.Id = itemIds[n];
                        itemError.Status__c = 'Errore';
                        itemError.StatusDescription__c = err.getStatusCode() + ': ' + err.getMessage() + ' on field: ' + err.getFields();
                        System.debug('>>> ' + String.valueOf(String.valueOf(itemList[n].ServicePoint__c) + ' - item id ' + itemIds[n]));
                        System.debug('>>> ' + ' [' + err.getStatusCode() + ': ' + err.getMessage() + ' on field: ' + err.getFields() + ']');
                        itemErrorToSave.add(itemError);
                    }

                }
            }
        }

        return itemErrorToSave;

    }

    public override void manageCatchException(Integer batchSize, List<MassiveLoaderRequestItem__c> itemList, String message){
        for(MassiveLoaderRequestItem__c item : itemList){
            item.Status__c = 'Errore';
            item.StatusDescription__c = message;
        }
        update itemList;
    }

}