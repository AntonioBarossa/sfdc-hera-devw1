public with sharing class HDT_UTL_ProcessPostSales extends  HDT_UTL_ProcessExecution {

    //HDT_BA_ProcessRequestItem processReq = new HDT_BA_ProcessRequestItem('a3d3O000000WlXDQA0', 20, 'PostSales'); 
    //Database.executeBatch(processReq, 20);

    private Map<String, String> mapCaseFields;
    private Map<String, Integer> mapHPositionByeader;
    private List<MassiveLoaderRequestItem__c> itemsToSave;

    public override void checks(){
        System.debug('checks');
        mapFieldsObject();
        System.debug('>>> mapCaseFields: ' + String.valueOf(mapCaseFields));
        System.debug('>>> mapHeaderByPosition: ' + String.valueOf(mapHeaderByPosition));
        System.debug('>>> mapRequiredByPosition: ' + String.valueOf(mapRequiredByPosition));
        //System.debug('>>> currentRequestItemList: ' + String.valueOf(currentProcess));

        HDT_QR_StaticResource qrStaticResource = new HDT_QR_StaticResource();
        List<StaticResource> staticResources = qrStaticResource.getRecordByName('PostSales');

        mapHPositionByeader = new Map<String, Integer>();
        Integer count=0;
        for (String temp : staticResources.get(0).Body.toString().remove('\r').remove('\n').split(',')) {
            mapHPositionByeader.put(temp, count);
            count++;
        }
        System.debug('>>> mapHPositionByeader: ' + String.valueOf(mapHPositionByeader));
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
        Id recordTypeId;
        List<Case> caseToInsert = new List<Case>();
        List<String> itemIds = new List<String>();
        itemsToSave = new List<MassiveLoaderRequestItem__c>();

        System.debug('>>> currentRequestItemList: ' + String.valueOf(currentProcess.currentCase));

        Integer podIndex = mapHPositionByeader.get('PodId');
        Integer accountIdIndex = mapHPositionByeader.get('AccountId');

        System.debug('>>> podIndex: ' + podIndex);
        System.debug('>>> accountIdIndex: ' + accountIdIndex);

        List<String> dataSplitted;
        for(MassiveLoaderRequestItem__c item : currentProcess.currentRequestItemList){
            dataSplitted = item.Data__c.split(',');
            accountIdSet.add(dataSplitted[accountIdIndex]);
            podSet.add(dataSplitted[podIndex]);
            itemRequestMap.put(item.Id, dataSplitted);
        }

        recordTypeId = HDT_QR_ProcessPostSales.getRecordTypeId('HDT_RT_Disattivazioni');
        contractList = HDT_QR_ProcessPostSales.getContracts(podSet, contractList);
        accContRelationList = HDT_QR_ProcessPostSales.getAccountContactRelationList(accContRelationList, accountIdSet, 'Titolare');

        System.debug('>>> accountIdSet ' + String.valueOf(accountIdSet));
        System.debug('>>> podSet ' + String.valueOf(podSet));
        System.debug('>>> contractList ' + String.valueOf(contractList));

        for(Contract singleContract : contractList){
            podContractMap.put(singleContract.ServicePoint__r.ServicePointCode__c, singleContract);
        }

        for(AccountContactRelation singleRelation : accContRelationList){
            accountContactMap.put(singleRelation.AccountId, singleRelation.ContactId);
        }

        Case newCase;
        for(String itemId : itemRequestMap.keySet()){

            List<String> tempSplitted = itemRequestMap.get(itemId);

            //Integer count=0;
            //for (String tempField : tempSplitted) {

            //    if ('null'.equalsIgnoreCase(tempField)) {
            //       tempField = '';
            //    }
            //
            //    if (mapRequiredByPosition.get(count) != null && String.isBlank(tempField)) {
            //        System.debug('>>> throw new HDT_WRP_ProcessEntitiesException');
            //       //throw new HDT_WRP_ProcessEntitiesException( 'Missing Required Field','Missing Required Field ' + mapHeaderByPosition.get(count));
            //    }
            //
            //    if(String.isNotBlank(mapCaseFields.get(mapHeaderByPosition.get(count))) && String.isNotBlank(tempField)){
            //        System.debug('>>> tempField: ' + tempField);
            //        System.debug('>>> get mapHeaderByPosition' + mapHeaderByPosition.get(count));
            //        System.debug('>>> get mapCaseFields' + mapCaseFields.get(mapHeaderByPosition.get(count)));
            //        mapTypeField(currentProcess.currentCase, mapCaseFields, count, tempField);
            //    }
            //    
            //}
            //System.debug('>>> currentCase: ' + currentProcess.currentCase);

            newCase = new Case();
            newCase.RecordTypeId = recordTypeId;

            Contract contract;
            
            if(podContractMap.containsKey(tempSplitted[podIndex])){
                contract = podContractMap.get(tempSplitted[podIndex]);
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

            newCase.Type = 'Chiusura Contatore';
            newCase.Status = 'In Lavorazione';
            newCase.Cluster__c = 'Disattivazioni';
            newCase.Phase__c = 'Bozza';
            newCase.CompanyOwner__c = 'HERA COMM';
            newCase.CausalCode__c = 'D01';

            // only to test insert failure
            if(tempSplitted[0]=='error')
                newCase.CareOf__c = 'abcdefghilmnopqrstuvzabcdefghilmnopqrstuvz';

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
            //itemsToSave = databaseInsert(caseToInsert, itemIds, itemsToSave);
            HDT_WRP_SaveResponse saveResponse = databaseInsert(caseToInsert, itemIds);
            caseToInsert.clear();

            if(saveResponse.reponseItemList.size() > 0){
                itemsToSave.addAll(saveResponse.reponseItemList);
            }

            if(saveResponse.savedCase.size() > 0){
                Map<Id, String> compatibilityMap = checkCompatibilityPostSales(saveResponse.savedCase);
                System.debug('>>> compatibilityMap ' + String.valueOf(compatibilityMap));

                if(!compatibilityMap.isEmpty()){
                    updateCaseNotCompatible(compatibilityMap.keySet());
                }
            }

        }  

    }

    //public override void makeProcess(){ // creazione processo
    //    System.debug('makeProcess');
    //}

    public override void finalUpdate(){
        System.debug('finalUpdate');

        if(itemsToSave.size() > 0){
            update itemsToSave;
        }

    }

    private void mapFieldsObject(){
        List<HDT_MassiveFieldsObjectMap__mdt> listCaseFields = getMapFieldsObject('Case', this.processName);
        mapCaseFields = new Map<String, String>();

        for(HDT_MassiveFieldsObjectMap__mdt temp : listCaseFields){
            mapCaseFields.put(temp.labelField__c, temp.nameField__c);
        }
    }

    //public static HDT_WRP_SaveResponse databaseInsert(List<Case> itemList, List<String> itemIds, List<MassiveLoaderRequestItem__c> itemsToSave){
    public static HDT_WRP_SaveResponse databaseInsert(List<Case> itemList, List<String> itemIds){
        HDT_WRP_SaveResponse saveResponse = new HDT_WRP_SaveResponse();
        saveResponse.reponseItemList = new List<MassiveLoaderRequestItem__c>();
        saveResponse.savedCase = new List<Case>();

        SObjectType objtype = Schema.getGlobalDescribe().get('Case');
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();
 
        if(objRes.isCreateable()){

            List<Database.SaveResult> insertResults = Database.insert(itemList, false);

            for(Integer n=0; n<insertResults.size(); n++){
                Database.SaveResult sr = insertResults[n];

                MassiveLoaderRequestItem__c itemError;
                if (!sr.isSuccess()) {
                    
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('>>> ' + String.valueOf(String.valueOf(itemList[n].ServicePoint__c) + ' - item id ' + itemIds[n]));
                        System.debug('>>> ' + ' [' + err.getStatusCode() + ': ' + err.getMessage() + ' on field: ' + err.getFields() + ']');
                        itemError = new MassiveLoaderRequestItem__c();
                        itemError.Id = itemIds[n];
                        itemError.Status__c = 'Errore';
                        itemError.StatusDescription__c = err.getStatusCode() + ': ' + err.getMessage() + ' on field: ' + err.getFields();
                        //itemsToSave.add(itemError);
                        saveResponse.reponseItemList.add(itemError);
                    }
                } else {
                    itemError = new MassiveLoaderRequestItem__c();
                    itemError.Id = itemIds[n];
                    itemError.Status__c = 'Chiuso';
                    //itemsToSave.add(itemError);
                    saveResponse.reponseItemList.add(itemError);
                    saveResponse.savedCase.add(itemList[n]);
                }
            }
        }

        //return itemsToSave;
        return saveResponse;

    }

    public class HDT_WRP_SaveResponse {
        public List<MassiveLoaderRequestItem__c> reponseItemList;
        public List<Case> savedCase;
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

    //only for test
    public static Map<Id, String> checkCompatibilityPostSales(List<Case> csList){

        List<ServiceRequest__c> srList = new List<ServiceRequest__c>();
        List<ServiceRequest__c> srListToDelete = new List<ServiceRequest__c>();
        Map<Id, String> caseIdToCompatibility = new Map<Id, String>();

        try {
            String compatibility = '';

            ServiceRequest__c srvRequest;
            for(Case cs : csList){
                srvRequest = new ServiceRequest__c();
                srvRequest.Case__c = cs.Id;
                srvRequest.ServicePointCode__c= cs.PODPDRFormula__c;
                srvRequest.Status__c = HDT_UTL_MatrixCompatibility.getStatus(cs.Status, 'Case');
                srvRequest.CommoditySector__c= cs.CommodityFormula__c;
                srvRequest.Type__c = 'Case';
    
                if(cs.ServicePoint__c != null){
                    srvRequest.ServicePoint__c = cs.ServicePoint__c;
                } else {
                    srvRequest.Account__c = cs.AccountId;
                    srvRequest.BillingProfile__c = cs.BillingProfile__c;
                }
    
                srvRequest.ProcessType__c = 'Chiusura contatore - EE';
                //srvRequest.ProcessType__c = HDT_UTL_MatrixCompatibility.getProcessType(cs.Type, 'Case', cs.CommodityFormula__c);
                srList.add(srvRequest);
            }

            //ServiceRequest__c sReq = HDT_SRV_ServiceRequest.createRecord(srvRequest);
            HDT_UTL_DatabaseService.insertSObject(srList);

            for(ServiceRequest__c sReq : srList){
                wrts_prcgvr.ObjectCompatibility_1_0.CheckResult result = HDT_UTL_MatrixCompatibility.checkCompatibility(sReq);

                //list of incompatible records
                if(!result.incompatibilities.isEmpty()){
                    compatibility = HDT_UTL_MatrixCompatibility.getIncompatibilityMessage((ServiceRequest__c[])result.incompatibilities);
                    caseIdToCompatibility.put(sReq.Case__c, compatibility);
                    srListToDelete.add(sReq);
                } else {
                    caseIdToCompatibility.put(sReq.Case__c, '');
                }
            }
            
            if(srListToDelete.size() > 0){
                HDT_UTL_DatabaseService.deleteSObject(srListToDelete);
            }

            return caseIdToCompatibility;

        } catch (Exception e) {
            throw e;
        }
    }
    //only for test

    public static void updateCaseNotCompatible(Set<Id> caseIdsSet){
        List<Case> caseToUpdate = new List<Case>();
        Case c;
        for(Id caseId : caseIdsSet){
            c = new Case();
            c.Id = caseId;
            c.Phase__c = 'Bozza Annullata';
            c.Status = 'Closed';
            c.CancellationReason__c = 'Processo incompatibile';
            caseToUpdate.add(c);
        }
        HDT_UTL_DatabaseService.updateSObject(caseToUpdate);
    }

}