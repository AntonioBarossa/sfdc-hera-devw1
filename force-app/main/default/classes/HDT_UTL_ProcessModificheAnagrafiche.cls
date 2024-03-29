@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_ProcessModificheAnagrafiche extends HDT_UTL_ProcessExecution {

    private Map<String, HDT_MassiveFieldsObjectMap__mdt> sobjectMap;
    private Map<String, String> mapCaseFields;
    private Map<String, String> mapWrapperCaseFields;
    private Set<String> accountIdSet = new Set<String>();
    private Set<String> contractCodeSet = new Set<String>();
    private List<HDT_WRP_ProcessObjects> processObjList;
    private List<MassiveLoaderRequestItem__c> itemsToSave;
    private Case newCase;
    private Map<String, AccountContactRelation> accountContactMap;
    private Map<String, BillingProfile__c> contractToBillProfMap = new Map<String, BillingProfile__c>();
    private List<AccountContactRelation> accContRelationList;
    private List<BillingProfile__c> billingProfileList;
    private List<Account> accountList;
    private Map<String,Id> accountIdMap;
    private Id recordTypeId;
    private Integer contractIndex;
    private Integer accountIdIndex;

    public override void checks(){
        System.debug(LoggingLevel.DEBUG, 'checks');
        itemsToSave = new List<MassiveLoaderRequestItem__c>();
        mapFieldsObject();

        //System.debug(LoggingLevel.DEBUG, '>>> mapCaseFields: ' + String.valueOf(mapCaseFields));
        //System.debug(LoggingLevel.DEBUG, '>>> mapWrapperCaseFields: ' + String.valueOf(mapWrapperCaseFields));
        //System.debug(LoggingLevel.DEBUG, '>>> mapHeaderForWrapper: ' + String.valueOf(mapHeaderForWrapper));
        //System.debug(LoggingLevel.DEBUG, '>>> mapHeaderByPosition: ' + String.valueOf(mapHeaderByPosition));
        //System.debug(LoggingLevel.DEBUG, '>>> sobjectMap: ' + String.valueOf(sobjectMap));

        accountIdIndex = mapHeaderForWrapper.get(mapWrapperCaseFields.get('ACCOUNTID'));
        contractIndex = mapHeaderForWrapper.get(mapWrapperCaseFields.get('CONTO_CONTRATTUALE'));

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

            accountIdSet.add(processObj.csvSplitted[accountIdIndex]);
            contractCodeSet.add(processObj.csvSplitted[contractIndex]);
            
            processObjList.add(processObj);
        }

    }

    public override void getRecords(){
        System.debug(LoggingLevel.DEBUG, 'getRecords');

        accountContactMap = new Map<String, AccountContactRelation>();
        accountList = HDT_QR_ProcessPostSales.getAccountByCode(accountList,accountIdSet);
        accountIdMap = new Map<String,Id>();
        accountIdSet = new Set<String>();
        for(Account acc : accountList){
            accountIdMap.put(acc.CustomerCode__c, acc.Id);
            accountIdSet.add(acc.Id);
        }
        billingProfileList = HDT_QR_ProcessPostSales.getBillingProfileByContractAccountCode(billingProfileList, contractCodeSet);
        accContRelationList = HDT_QR_ProcessPostSales.getAccountContactRelationList(accContRelationList, accountIdSet, 'Titolare');
        recordTypeId = HDT_QR_ProcessPostSales.getRecordTypeId('HDT_RT_VariazioneAnagraficaCliente');

        //System.debug(LoggingLevel.DEBUG, '>>> accountIdSet ' + String.valueOf(accountIdSet));
        //System.debug(LoggingLevel.DEBUG, '>>> billingProfileList ' + String.valueOf(billingProfileList));

        for(BillingProfile__c singleBillProf : billingProfileList){
            contractToBillProfMap.put(singleBillProf.ContractAccountCode__c, singleBillProf);
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

        List<String> emptyCsvField;
        for(HDT_WRP_ProcessObjects processObj : processObjList){

            newCase = new Case();

            Integer count = 0;
            String convertionError;
            String csvHeader;
            String objField;
            String accountId;
            emptyCsvField = new List<String>();

            System.debug(LoggingLevel.DEBUG, '>>> processObj.csvSplitted ' + processObj.csvSplitted.size());

            for (String tempField : processObj.csvSplitted) {
                accountId = accountIdMap.get(processObj.csvSplitted[accountIdIndex]);
                if ('null'.equalsIgnoreCase(tempField)) {
                   tempField = '';
                }
                
                csvHeader = mapHeaderByPosition.get(count);
                objField = mapCaseFields.get(csvHeader);

                if(!String.isEmpty(convertionError)){
                    // error happened -> exit
                    break;
                }
            
                if(String.isNotBlank(objField)){//&& String.isNotBlank(tempField)
                    System.debug(LoggingLevel.DEBUG, '>>> CSV Header: ' + csvHeader + '; Case Field: ' + objField + '; value: ' + tempField);
                    
                    if(String.isNotBlank(tempField)){
                        convertionError = mapTypeField(newCase, mapCaseFields, count, tempField);
                    } else {
                        System.debug(LoggingLevel.DEBUG, '>>> ' + csvHeader + ' is empty!');
                        emptyCsvField.add(csvHeader);
                    }

                    if(!String.isEmpty(convertionError)){
                        // error happened -> exit
                        System.debug(LoggingLevel.DEBUG, '>>> break for loop...' + csvHeader + ' - ' + objField + ' - ' + tempField);
                        break;
                    }
                }

                count++;
            }

            if(!String.isEmpty(convertionError)){
                itemsToSave.add(setErrorItem(processObj.requestItem, convertionError));
                continue;
            }

            if(errorForPicklistValue('Case', 'Type', newCase.Type)){
                itemsToSave.add(setErrorItem(processObj.requestItem, 'Valore processo non corretto: ' + newCase.Type));
                continue;
            }

            Boolean enableBillProfEdit = (newCase.Subprocess__c.equalsIgnoreCase('Modifica Dati Di Recapito'));
            System.debug(LoggingLevel.DEBUG, '>>> enableBillProfEdit: ' + enableBillProfEdit);

            if(emptyCsvField.size() > 0){
                System.debug(LoggingLevel.DEBUG, '>>> we need to set empty fields');
                convertionError = setEmptyCsvFields(emptyCsvField, newCase, accountId, processObj.csvSplitted[contractIndex], enableBillProfEdit);

                if(!String.isEmpty(convertionError)){
                    itemsToSave.add(setErrorItem(processObj.requestItem, convertionError));
                    continue;
                }

            }

            if(enableBillProfEdit && contractToBillProfMap.containsKey(processObj.csvSplitted[contractIndex])){
                newCase.BillingProfile__c = contractToBillProfMap.get(processObj.csvSplitted[contractIndex]).Id;
            }

            if(accountContactMap.containsKey(accountId)){
                newCase.ContactId = accountContactMap.get(accountId).ContactId;
                newCase.Category__c = accountContactMap.get(accountId).Account.Category__c;
            }

            //newCase.AccountId = processObj.csvSplitted[accountIdIndex];
            newCase.AccountId = accountIdMap.get(accountId);
            newCase.Cluster__c = 'Modifiche Anagrafiche';
            newCase = setCaseField(newCase, recordTypeId);

            System.debug(LoggingLevel.DEBUG, '>>> currentCase: ' + newCase);

            caseToInsert.add(newCase); 
            requestItemForUpsert.add(processObj.requestItem);
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

    private String setEmptyCsvFields(List<String> emptyFieldToSet, Case caseToSet, String accountId, String contractAccountCode, Boolean enableBillProfEdit){

        System.debug(LoggingLevel.DEBUG, '>>> setEmptyCsvFields');
        Map<String, Object> fieldsToValue;
        Object newValueToSet;

        HDT_MassiveFieldsObjectMap__mdt massiveFieldsObject;
        AccountContactRelation accContRel;
        BillingProfile__c billingProfile;
        for(String emptyField : emptyFieldToSet){
            System.debug(LoggingLevel.DEBUG, '>>> empty field to set -> ' + emptyField);

            massiveFieldsObject = sobjectMap.get(emptyField);
            System.debug(LoggingLevel.DEBUG, '>>> massiveFieldsObject -> ' + massiveFieldsObject);

            switch on massiveFieldsObject.objectType__c {
                when 'Account' {
                    if(accountContactMap.containsKey(accountId)){
                        accContRel = accountContactMap.get(accountId);
                        fieldsToValue = accContRel.getPopulatedFieldsAsMap();
                        Account currentAccount = (Account)fieldsToValue.get('Account');
                        newValueToSet = currentAccount.get(massiveFieldsObject.labelField__c);
                    } else {
                        return 'Account non presente';
                    }
                }	
                when 'Contact' {
                    if(accountContactMap.containsKey(accountId)){
                        accContRel = accountContactMap.get(accountId);
                        fieldsToValue = accContRel.getPopulatedFieldsAsMap();
                        Contact currentContact = (Contact)fieldsToValue.get('Contact');
                        newValueToSet = currentContact.get(massiveFieldsObject.labelField__c);
                    } else {
                        return 'Contatto non presente';
                    }    
                }
                when 'BillingProfile__c' {

                    if(!enableBillProfEdit){
                        continue;
                    }

                    if(contractToBillProfMap.containsKey(contractAccountCode)){
                        billingProfile = contractToBillProfMap.get(contractAccountCode);
                        fieldsToValue = billingProfile.getPopulatedFieldsAsMap();
                        newValueToSet = fieldsToValue.get(massiveFieldsObject.labelField__c);
                    } else {
                        return 'BillingProfile non presente';
                    }    
                }

            }

            if(newValueToSet != null && !String.isEmpty(massiveFieldsObject.nameField__c)){
                System.debug(LoggingLevel.DEBUG, '>>> new value to set: ' + newValueToSet + ' for -> ' + emptyField + ' [' + massiveFieldsObject.labelField__c + ']');
                caseToSet.put(massiveFieldsObject.nameField__c, newValueToSet);
            }

        }

        return null;

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
            item.StatusDescription__c = message.abbreviate(250);
        }
        update itemList;
    }

    private void mapFieldsObject(){

        List<HDT_MassiveFieldsObjectMap__mdt> allFieldForThisProcess;

        mapCaseFields = new Map<String, String>();
        mapWrapperCaseFields = new Map<String, String>();

        sobjectMap = new Map<String, HDT_MassiveFieldsObjectMap__mdt>();
        allFieldForThisProcess = HDT_QR_ProcessPostSales.getMapFieldsObject(this.processName);

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
        private MassiveLoaderRequestItem__c requestItem;
        private List<String> csvSplitted;
    }

}