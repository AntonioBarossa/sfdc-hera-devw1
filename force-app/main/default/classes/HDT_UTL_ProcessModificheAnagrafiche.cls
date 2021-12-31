public with sharing class HDT_UTL_ProcessModificheAnagrafiche extends HDT_UTL_ProcessExecution {

    private Map<String, HDT_MassiveFieldsObjectMap__mdt> sobjectMap;
    //private Map<String, Object> modAnagFieldMap;
    private Map<String, String> mapCaseFields;
    private Map<String, String> mapWrapperCaseFields;
    private Set<String> accountIdSet = new Set<String>();
    private Set<String> contractCodeSet = new Set<String>();
    private Map<String, List<String>> itemRequestMap = new Map<String, List<String>>();
    private List<MassiveLoaderRequestItem__c> itemsToSave;
    private Case newCase;
    private Map<String, AccountContactRelation> accountContactMap;
    private Map<String, BillingProfile__c> contractToBillProfMap = new Map<String, BillingProfile__c>();
    private List<AccountContactRelation> accContRelationList;
    private List<BillingProfile__c> billingProfileList;
    private Id recordTypeId;
    private Integer contractIndex;
    private Integer accountIdIndex;

    public override void checks(){
        System.debug('checks');
        mapFieldsObject();

        System.debug('>>> mapCaseFields: ' + String.valueOf(mapCaseFields));
        System.debug('>>> mapWrapperCaseFields: ' + String.valueOf(mapWrapperCaseFields));
        System.debug('>>> mapHeaderForWrapper: ' + String.valueOf(mapHeaderForWrapper));
        System.debug('>>> mapHeaderByPosition: ' + String.valueOf(mapHeaderByPosition));

        System.debug('>>> sobjectMap: ' + String.valueOf(sobjectMap));

        accountIdIndex = mapHeaderForWrapper.get(mapWrapperCaseFields.get('ACCOUNTID'));
        contractIndex = mapHeaderForWrapper.get(mapWrapperCaseFields.get('CONTO_CONTRATTUALE'));

        List<String> dataSplitted;
        for(MassiveLoaderRequestItem__c item : currentProcess.currentRequestItemList){
            dataSplitted = item.Data__c.split(',', -1);
            accountIdSet.add(dataSplitted[accountIdIndex]);
            contractCodeSet.add(dataSplitted[contractIndex]);
            itemRequestMap.put(item.Id, dataSplitted);
        }

    }

    public override void getRecords(){
        System.debug('getRecords');

        accountContactMap = new Map<String, AccountContactRelation>();

        billingProfileList = HDT_QR_ProcessPostSales.getBillingProfileByContractAccountCode(billingProfileList, contractCodeSet);
        accContRelationList = HDT_QR_ProcessPostSales.getAccountContactRelationList(accContRelationList, accountIdSet, 'Titolare');
        recordTypeId = HDT_QR_ProcessPostSales.getRecordTypeId('HDT_RT_VariazioneAnagraficaCliente');

        //System.debug('>>> accountIdSet ' + String.valueOf(accountIdSet));
        //System.debug('>>> billingProfileList ' + String.valueOf(billingProfileList));

        for(BillingProfile__c singleBillProf : billingProfileList){
            contractToBillProfMap.put(singleBillProf.ContractAccountCode__c, singleBillProf);
        }

        for(AccountContactRelation singleRelation : accContRelationList){
            accountContactMap.put(singleRelation.AccountId, singleRelation);
        }
        
    }

    public override void registryCreation(){
        System.debug('registryCreation');

        HDT_UTL_ProcessCommonOperations.getLimitDetails('START registryCreation');

        List<Case> caseToInsert = new List<Case>();
        List<String> itemIds = new List<String>();
        itemsToSave = new List<MassiveLoaderRequestItem__c>();

        List<String> emptyCsvField;
        for(String itemId : itemRequestMap.keySet()){

            List<String> tempSplitted = itemRequestMap.get(itemId);
            newCase = new Case();

            Integer count = 0;
            String convertionError;
            String setEmptyCsvFields;
            String csvHeader;
            String objField;
            emptyCsvField = new List<String>();

            System.debug('>>> tempSplitted ' + tempSplitted.size());

            for (String tempField : tempSplitted) {

                if ('null'.equalsIgnoreCase(tempField)) {
                   tempField = '';
                }
                
                csvHeader = mapHeaderByPosition.get(count);
                objField = mapCaseFields.get(csvHeader);

                //if (mapRequiredByPosition.get(count) != null && String.isBlank(tempField)) {
                //    System.debug('>>> throw new HDT_WRP_ProcessEntitiesException');
                //   //throw new HDT_WRP_ProcessEntitiesException( 'Missing Required Field','Missing Required Field ' + mapHeaderByPosition.get(count));
                //}
            
                if(String.isNotBlank(objField)){//&& String.isNotBlank(tempField)
                    System.debug('>>> CSV Header: ' + csvHeader + '; Case Field: ' + objField + '; value: ' + tempField);
                    
                    if(String.isNotBlank(tempField)){
                        convertionError = mapTypeField(newCase, mapCaseFields, count, tempField);
                    } else {
                        System.debug('>>> ' + csvHeader + ' is empty!');
                        emptyCsvField.add(csvHeader);
                    }

                    if(!String.isEmpty(convertionError)){
                        // error happened -> exit
                        System.debug('>>> break for loop...' + csvHeader + ' - ' + objField + ' - ' + tempField);
                        break;
                    }
                }

                count++;
            }

            if(!String.isEmpty(convertionError)){
                itemsToSave.add(setErrorItem(itemId, convertionError));
                continue;
            }

            if(emptyCsvField.size() > 0){
                System.debug('>>> we need to set empty fields');
                convertionError = setEmptyCsvFields(emptyCsvField, newCase, tempSplitted[accountIdIndex]);

                if(!String.isEmpty(convertionError)){
                    itemsToSave.add(setErrorItem(itemId, convertionError));
                    continue;
                }

            }

            System.debug('>>> currentCase: ' + newCase);

            newCase.AccountId = tempSplitted[accountIdIndex];
            newCase.RecordTypeId = recordTypeId;
            newCase.Status = 'In Lavorazione';
            newCase.Cluster__c = 'Modifiche Anagrafiche';
            newCase.Phase__c = 'Bozza';
            newCase.CompanyOwner__c = 'HERA COMM';
            caseToInsert.add(newCase); 
            itemIds.add(itemId);
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

    private String setEmptyCsvFields(List<String> emptyFieldToSet, Case caseToSet, String accountId){

        System.debug('>>> setEmptyCsvFields');
        Map<String, Object> fieldsToValue;
        String newValueToSet;

        HDT_MassiveFieldsObjectMap__mdt massiveFieldsObject;
        AccountContactRelation accContRel;
        for(String emptyField : emptyFieldToSet){
            System.debug('>>> empty field to set -> ' + emptyField);

            massiveFieldsObject = sobjectMap.get(emptyField);
            System.debug('>>> massiveFieldsObject -> ' + massiveFieldsObject);

            switch on massiveFieldsObject.objectType__c {
                when 'Account' {
                    if(accountContactMap.containsKey(accountId)){
                        accContRel = accountContactMap.get(accountId);
                        fieldsToValue = accContRel.getPopulatedFieldsAsMap();
                        Account currentAccount = (Account)fieldsToValue.get('Account');
                        newValueToSet = String.valueOf(currentAccount.get(massiveFieldsObject.labelField__c));
                    } else {
                        return 'Account non presente';
                    }
                }	
                when 'Contact' {
                    
                }
                when 'BillingProfile__c' {
                    
                }

            }

            if(!String.isEmpty(newValueToSet) && !String.isEmpty(massiveFieldsObject.labelField__c)){
                System.debug('>>> new value to set: ' + newValueToSet + ' for -> ' + emptyField + ' [' + massiveFieldsObject.labelField__c + ']');
                caseToSet.put(massiveFieldsObject.labelField__c, newValueToSet);
            }

        }

        return null;

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

        //List<HDT_MassiveFieldsObjectMap__mdt> listCaseFields;
        //List<HDT_MassiveFieldsObjectMap__mdt> listWrapperCaseFields;
        List<HDT_MassiveFieldsObjectMap__mdt> allFieldForThisProcess;//++

        mapCaseFields = new Map<String, String>();
        mapWrapperCaseFields = new Map<String, String>();

        //
        sobjectMap = new Map<String, HDT_MassiveFieldsObjectMap__mdt>();

        //listCaseFields = getMapFieldsObject('Case', this.processName);
        //listWrapperCaseFields = getMapFieldsObject('WrapperCase', this.processName);

        //
        allFieldForThisProcess = [
            SELECT objectType__c, labelField__c, nameField__c, MasterLabel 
            FROM HDT_MassiveFieldsObjectMap__mdt 
            WHERE processType__c = :this.processName
            WITH SECURITY_ENFORCED
        ];

        //for(HDT_MassiveFieldsObjectMap__mdt temp : listCaseFields){
        //    mapCaseFields.put(temp.labelField__c, temp.nameField__c);
        //}
//
        //for(HDT_MassiveFieldsObjectMap__mdt temp : listWrapperCaseFields){
        //    mapWrapperCaseFields.put(temp.labelField__c, temp.nameField__c);
        //}

        for(HDT_MassiveFieldsObjectMap__mdt temp : allFieldForThisProcess){
            if(temp.objectType__c.equalsIgnoreCase('WrapperCase')){
                mapWrapperCaseFields.put(temp.labelField__c, temp.nameField__c);
            } else {
                mapCaseFields.put(temp.MasterLabel, temp.nameField__c);
                sobjectMap.put(temp.MasterLabel, temp);
            }
            
        }

    }

    //only for test
    //private void setMap(){
    //    List<StaticResource> staticResources = staticResourceQr.getRecordByName('modificheAnagraficaFieldMapping');
    //    modAnagFieldMap = (Map<String, Object>) JSON.deserializeUntyped(staticResources[0].Body.toString());
    //}

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
    
        for(Integer n=0; n<2; n++){
            item = new MassiveLoaderRequestItem__c();
            item.MassiveLoaderRequest__c = massiveLoaderRequestId;
            item.Status__c = 'In attesa di lavorazione';
            item.Data__c = 'Variazione Anagrafica Cliente,0011X00000rL7Z6QAK,,contoCode,3336560123,,,,,,Cartaceo,,,,,,,,,,,,,,,,,,,,ADAM,,,,,,,,,,,,,,,';//--0011X00000jcKXUQA2
            itemsList.add(item);
        }
        insert itemsList;
    
        MassiveLoaderRequest__c mlr = new MassiveLoaderRequest__c();
        mlr.Id = massiveLoaderRequestId;
        mlr.Status__c = 'In attesa di lavorazione';
        update mlr;
    
    }

}