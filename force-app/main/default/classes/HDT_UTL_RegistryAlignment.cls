@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_UTL_RegistryAlignment extends HDT_UTL_ProcessExecution{
    
    private Id recordTypeId;
    private List<MassiveLoaderRequestItem__c> itemsToSave;
    private List<HDT_WRP_ProcessObjects> processObjList;
    private Integer contractIndex;
    private Set<String> contractCodeSet = new Set<String>();
    private Map<String, Contract> podContractMap = new Map<String, Contract>();
    private Map<String, AccountContactRelation> accountContactMap = new Map<String, AccountContactRelation>();
    private Map<String, String> mapCaseFields;
    private Map<String, String> mapWrapperCaseFields;
    
    

    public override void checks(){
        System.debug(LoggingLevel.DEBUG, 'checks');

        //System.debug(LoggingLevel.DEBUG, '>>> this.processName: ' + this.processName);
        itemsToSave = new List<MassiveLoaderRequestItem__c>();

        mapFieldsObject();
        contractIndex = mapHeaderForWrapper.get(mapWrapperCaseFields.get('CONTRATTO'));

        HDT_WRP_ProcessObjects processObj;
        processObjList = new List<HDT_WRP_ProcessObjects>();
        List<String> tempSplitedFields;
        for(MassiveLoaderRequestItem__c item : requestItemList){

            tempSplitedFields = new List<String>();
            tempSplitedFields = item.Data__c.split(splitCharacter, -1);

            checkRequiredFields(item, tempSplitedFields);
            System.debug(LoggingLevel.DEBUG, '>>> itemStatus' + item.Status__c);

            if(item.Status__c.equalsIgnoreCase('Errore')){
                itemsToSave.add(item);
                continue;
            }

            processObj = new HDT_WRP_ProcessObjects();
            processObj.requestItem = item;
            processObj.csvSplitted = tempSplitedFields;

            contractCodeSet.add(processObj.csvSplitted[contractIndex]);
            processObjList.add(processObj);

        }

    }

    public override void getRecords(){
        System.debug(LoggingLevel.DEBUG, 'getRecords');

        String rtDeveloperName = 'HDT_RT_AllineamentoAnagrafica';
        List<Contract> contractList = new List<Contract>();
        contractList = HDT_QR_ProcessPostSales.getContracts(contractList, contractCodeSet);
        Set<String> accountIdSet = new Set<String>();
        for (Contract contr : contractList){
            if (contr.AccountId != null){
                accountIdSet.add(contr.AccountId);
            }
        }

        List<AccountContactRelation> accContRelationList = new List<AccountContactRelation>();
        accContRelationList = HDT_QR_ProcessPostSales.getAccountContactRelationList(accContRelationList, accountIdSet, 'Titolare');
    

        for(Contract singleContract : contractList){
            podContractMap.put(singleContract.SAPContractCode__c, singleContract);
        }

        for(AccountContactRelation singleRelation : accContRelationList){
            accountContactMap.put(singleRelation.AccountId, singleRelation);
        }

        recordTypeId = HDT_QR_ProcessPostSales.getRecordTypeId(rtDeveloperName);

    }

    public override void registryCreation(){
        System.debug(LoggingLevel.DEBUG, 'registryCreation');

        getLimitDetails('START registryCreation');

        List<Case> caseToInsert = new List<Case>();
        List<MassiveLoaderRequestItem__c> requestItemForUpsert = new List<MassiveLoaderRequestItem__c>();
        String causalCode;
        

        for(HDT_WRP_ProcessObjects processObj : processObjList){
            String codicePod;
            processObj.newCase = new Case();

            Integer count = 0;
            String convertionError;
            for (String tempField : processObj.csvSplitted) {

                if ('null'.equalsIgnoreCase(tempField)) {
                   tempField = '';
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

            if(String.isNotEmpty(convertionError)){
                itemsToSave.add(setErrorItem(processObj.requestItem, convertionError));
                continue;
            }

            if(errorForPicklistValue('Case', 'Type', processObj.newCase.Type)){
                itemsToSave.add(setErrorItem(processObj.requestItem, 'Valore processo non corretto: ' + processObj.newCase.Type));
                continue;
            }

            processObj.newCase.Cluster__c = 'Modifiche Anagrafiche';

            Contract contr;
            if(podContractMap.containsKey(processObj.csvSplitted[contractIndex])){
                contr = podContractMap.get(processObj.csvSplitted[contractIndex]);
                processObj.newCase.Contract__c = contr.Id;
                processObj.newCase.ServicePoint__c = contr.ServicePoint__c;
                processObj.newCase.BillingProfile__c = contr.BillingProfile__c;
                processObj.newCase.AccountId = contr.accountId;
                codicePod = contr.ServicePoint__r?.ServicePointCode__c;
            } else {
                itemsToSave.add(setErrorItem(processObj.requestItem, 'pod non presente'));
                continue;
            }
                  

            if(accountContactMap.containsKey(processObj.newCase.AccountId)){
                AccountContactRelation rel = accountContactMap.get(processObj.newCase.AccountId);
                processObj.newCase.ContactId = rel.contactId;
                processObj.newCase.BillingProvince__c = rel.Account.BillingState;
                processObj.newCase.BillingStreetNumber__c = rel.Account?.BillingStreetNumber__c;
                processObj.newCase.BillingPlace__c = rel.Account?.BillingPlace__c;
                processObj.newCase.BillingStreetName__c = rel.Account?.BillingStreetName__c;
                processObj.newCase.BillingPostalCode__c = rel.Account?.BillingPostalCode;
                processObj.newCase.BillingCountry__c = rel.Account?.BillingCountry;
                processObj.newCase.BillingCityCode__c = rel.Account?.BillingCityCode__c;
                processObj.newCase.FirstName__c = rel.Account?.FirstName__c;
                processObj.newCase.LastName__c = rel.Account?.LastName__c;
                processObj.newCase.VATNumber__c = rel.Account?.VATNumber__c;
                processObj.newCase.FiscalCode__c = rel.Account?.FiscalCode__c;
                processObj.newCase.Mobile__c = rel.Contact?.MobilePhone != null ? rel.Contact.MobilePhone : rel.Contact?.Phone;
            } else {
                itemsToSave.add(setErrorItem(processObj.requestItem, 'account non presente'));
                continue;
            }

            
            
            processObj.newCase = setCaseField(processObj.newCase, recordTypeId);
            
            if(!String.isEmpty(contr.ServicePoint__r.CommoditySector__c)){
                causalCode = 'Gas'.equalsIgnoreCase(contr.ServicePoint__r.CommoditySector__c)? 'AGG' : '03'; 
            }

            if(String.isNotEmpty(causalCode)){
                processObj.newCase.CausalCode__c = causalCode;
                processObj.newCase.OperationCode__c = 'AGG'.equals(causalCode)? '01':'03';
            }


            try{
                HDT_WS_ArrichmentDataEntityResponse res = HDT_WS_ArrichmentDataEntityInvoker.callService(processObj.csvSplitted[contractIndex], codicePod);
                processObj.newCase = HDT_UTL_DataEnrichmentPostSales.handleResponse(JSON.serialize(res), processObj.newCase); 
                caseToInsert.add(processObj.newCase); 
                requestItemForUpsert.add(processObj.requestItem);
            } catch(Exception e){
                System.debug(LoggingLevel.DEBUG, '>>> arricchimentoError ' + e.getMessage());
                itemsToSave.add(setErrorItem(processObj.requestItem, 'Errore arricchimento dati #'));
            }
        }

        if(caseToInsert.size() > 0){

           HDT_WRP_SaveResponse saveResponse;
           saveResponse = databaseUpsert(caseToInsert, requestItemForUpsert, 'Case');

           caseToInsert.clear();

           Map<Id, String> caseNumberMap = new Map<Id, String>();
           caseNumberMap = setCaseNumberMap(caseNumberMap, saveResponse.itemIdToObjId.values());

           getLimitDetails('AFTER CASE CREATION & Enrichment');

           if(saveResponse.reponseItemList.size() > 0){

                for(HDT_WRP_ProcessObjects processObj : processObjList){
                    if(caseNumberMap.containsKey(processObj.newCase.Id)){
                        processObj.requestItem.Result__c = caseNumberMap.get(processObj.newCase.Id);
                    }
                }

               itemsToSave.addAll(saveResponse.reponseItemList);
           }

           if(saveResponse.savedObject.size() > 0){
               runCompatibility(saveResponse.savedObject);
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

    private class HDT_WRP_ProcessObjects {
        private Case newCase;
        private Contract contract;
        private MassiveLoaderRequestItem__c requestItem;
        private List<String> csvSplitted;
    }
    
}
