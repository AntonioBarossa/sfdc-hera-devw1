@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_ProcessLead extends HDT_UTL_ProcessExecution {

    private Map<String, String> mapLeadFields;
    private Map<String, String> mapIndividualFields;
    private List<Lead> existingLeadList;
    private List<HDT_WRP_ProcessObjects> processObjList;
    private List<MassiveLoaderRequestItem__c> itemsToSave;

    public override void checks(){

        itemsToSave = new List<MassiveLoaderRequestItem__c>();

        mapFieldsObject();

        HDT_WRP_ProcessObjects processObj;
        processObjList = new List<HDT_WRP_ProcessObjects>();
        List<String> tempSplitedFields;
        for(MassiveLoaderRequestItem__c item : requestItemList){

            tempSplitedFields = item.Data__c.split(splitCharacter, -1);

            checkRequiredFields(item, tempSplitedFields);
            System.debug(LoggingLevel.DEBUG, '>>> itemStatus' + item.Status__c);

            if(item.Status__c.equalsIgnoreCase('Errore')){
                itemsToSave.add(item);
                continue;
            }

            processObj = new HDT_WRP_ProcessObjects();
            processObj.newIndividual = new Individual();
            processObj.newLead = new Lead();
            processObj.requestItem = item;

            Integer count = 0;
            String convertionError;
            for (String tempField : tempSplitedFields) {

                if ('null'.equalsIgnoreCase(tempField)) {
                   tempField = '';
                }

                if(String.isNotBlank(mapLeadFields.get(mapHeaderByPosition.get(count))) && String.isNotBlank(tempField) ){
                    convertionError = mapTypeField(processObj.newLead, mapLeadFields, count, tempField);

                    if(String.isNotEmpty(convertionError)){
                        // error happened -> exit
                        break;
                    }

                }

                if(String.isNotBlank(mapIndividualFields.get(mapHeaderByPosition.get(count)))&& String.isNotBlank(tempField) ){
                    System.debug(LoggingLevel.DEBUG, '>>> tempField: ' + tempField + ' # Header: ' + mapHeaderByPosition.get(count) + ' # Individual Field: ' + mapIndividualFields.get(mapHeaderByPosition.get(count)));
                    convertionError = mapTypeField(processObj.newIndividual, mapIndividualFields, count, tempField);

                    if(String.isNotEmpty(convertionError)){
                        // error happened -> exit
                        break;
                    }

                    if(errorForPicklistValue('Individual', mapIndividualFields.get(mapHeaderByPosition.get(count)), tempField)){
                        convertionError = 'Valore: ' + tempField + ' non valido per ' + mapIndividualFields.get(mapHeaderByPosition.get(count));
                        break;
                    }

                }

                count++;
            }

            if(String.isNotEmpty(convertionError)){
                itemsToSave.add(setErrorItem(processObj.requestItem, convertionError));
                continue;
            }

            if(String.isBlank(processObj.newLead.Company)) {
                processObj.newLead.Company = processObj.newLead.FirstName + processObj.newLead.LastName;
            }
    
            processObj.newLead.LeadSource = 'Lead freddo';
            processObjList.add(processObj);

            System.debug(LoggingLevel.DEBUG, '>>> current lead: ' + processObj.newLead);
            System.debug(LoggingLevel.DEBUG, '>>> current individual: ' + processObj.newIndividual);

        }

    }

    public override void registryCreation(){

        List<Lead> leadtoUpsert = new List<Lead>();
        List<Lead> leadtoDelete = new List<Lead>();
        List<Lead> savedLeadList = new List<Lead>();
        Map<Id, Lead> savedLeadMap;
        List<Individual> individualtoUpdate = new List<Individual>();
        List<MassiveLoaderRequestItem__c> itemList = new List<MassiveLoaderRequestItem__c>();
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('HDT_RT_Main').getRecordTypeId();

        List<Lead> duplicateLeadList;
        String errorMessage = '';
        Lead existingLead;
        for(HDT_WRP_ProcessObjects processObj : processObjList){

            duplicateLeadList = new List<Lead>();

            try {
                duplicateLeadList = findDuplicateLead(new List<Lead>{processObj.newLead});
            } catch (Exception ex) {
                processObj.requestItem = setErrorItem(processObj.requestItem,  ex.getMessage());
                continue;
            }
            
            System.debug(LoggingLevel.DEBUG, '>>> existingLead: ' + duplicateLeadList);

            if(duplicateLeadList[0] != null){
                // errore duplicato
                errorMessage = 'Duplicato - ' +  duplicateLeadList[0].Name + ' [' + duplicateLeadList[0].email + ']';
                processObj.requestItem = setErrorItem(processObj.requestItem,  errorMessage);
                processObj.newLead.Id = duplicateLeadList[0].Id;
            }

            processObj.newLead.RecordTypeId = recordTypeId;
            leadtoUpsert.add(processObj.newLead);
            itemList.add(processObj.requestItem);

        }

        HDT_WRP_SaveResponse leadUpsertResponse;
        leadUpsertResponse = databaseUpsert(leadtoUpsert, itemList, 'Lead');

        //System.debug(LoggingLevel.DEBUG, '>>> reponseItemList: ' + leadUpsertResponse.reponseItemList);
        //System.debug(LoggingLevel.DEBUG, '>>> savedObject: ' + leadUpsertResponse.savedObject);
        //System.debug(LoggingLevel.DEBUG, '>>> itemIdToObjId: ' + leadUpsertResponse.itemIdToObjId);
        //System.debug(LoggingLevel.DEBUG, '>>> errorItemMap: ' + leadUpsertResponse.errorItemMap);

        itemList.clear();
        
        savedLeadList = [
            SELECT Id, IndividualId
            FROM Lead
            WHERE Id IN :leadUpsertResponse.itemIdToObjId.values()
        ];

        savedLeadMap = new Map<Id, Lead>(savedLeadList);

        for(HDT_WRP_ProcessObjects processObj : processObjList){

            if(processObj.requestItem.Status__c.equalsIgnoreCase('Errore')){
                continue;
            }

            System.debug(LoggingLevel.DEBUG, '>>> saved lead: ' + processObj.newLead.Id);
            System.debug(LoggingLevel.DEBUG, '>>> saved Individual: ' + processObj.newLead.Individual.Id);

            if(leadUpsertResponse.errorItemMap.containsKey(processObj.requestItem.Id)){
                // errore
                processObj.requestItem = setErrorItem(processObj.requestItem, leadUpsertResponse.errorItemMap.get(processObj.requestItem.Id));
                continue;
            }

            processObj.newIndividual.Id = savedLeadMap.get(processObj.newLead.Id).IndividualId;
            individualtoUpdate.add(processObj.newIndividual);
            itemList.add(processObj.requestItem);

        }

        HDT_WRP_SaveResponse individualUpsertResponse;
        individualUpsertResponse = databaseUpsert(individualtoUpdate, itemList, 'Individual');

        for(HDT_WRP_ProcessObjects processObj : processObjList){

            if(processObj.requestItem.Status__c.equalsIgnoreCase('Errore')){
                continue;
            }

            if(individualUpsertResponse.errorItemMap.containsKey(processObj.requestItem.Id)){
                // errore
                processObj.requestItem = setErrorItem(processObj.requestItem, individualUpsertResponse.errorItemMap.get(processObj.requestItem.Id));
                leadtoDelete.add(processObj.newLead);
            }
        }

        if(leadtoDelete.size() > 0){
            HDT_UTL_DatabaseService.deleteSObject(leadtoDelete);
        }

        for(HDT_WRP_ProcessObjects processObj : processObjList){
            if(!processObj.requestItem.Status__c.equalsIgnoreCase('Errore')){
                processObj.requestItem.Status__c = 'Chiuso';
            }
            itemsToSave.add(processObj.requestItem);
        }

    }

    public override void finalUpdate(){
        System.debug(LoggingLevel.DEBUG, '>>> finalUpdate');

        if(itemsToSave.size() > 0){
            update itemsToSave;
        }

    }

    private void mapFieldsObject(){

        List<HDT_MassiveFieldsObjectMap__mdt> listLeadFields = getMapFieldsObject('Lead', this.processName);
        mapLeadFields = new Map<String, String>();

        for(HDT_MassiveFieldsObjectMap__mdt temp : listLeadFields){
            mapLeadFields.put(temp.labelField__c, temp.nameField__c);
        }

        List<HDT_MassiveFieldsObjectMap__mdt> listIndividualFields = getMapFieldsObject('Individual', this.processName);
        mapIndividualFields = new Map<String, String>();

        for(HDT_MassiveFieldsObjectMap__mdt temp : listIndividualFields){
            mapIndividualFields.put(temp.labelField__c, temp.nameField__c);
        }

    }

    private static List<Lead> findDuplicateLead(List<Lead> leadToSearch) {
        List<Lead> leadDuplicated = new List<Lead>();
        List<Datacloud.FindDuplicatesResult> results;

        results = Datacloud.FindDuplicates.findDuplicates(leadToSearch);

        for (Integer i = 0; i < leadToSearch.size(); i++) {
            Lead leadDup = null;
            for (Datacloud.DuplicateResult dr : results[i].getDuplicateResults()) {
                if (dr.matchResults.size() > 0 && dr.getMatchResults()[0].matchRecords.size() > 0) {
                    leadDup = (Lead)dr.getMatchResults()[0].getMatchRecords()[0].getRecord();
                    break;
                }
            }
            leadDuplicated.add(leadDup);
        }
    
        return leadDuplicated;
    }

    private class HDT_WRP_ProcessObjects {
        private Lead newLead;
        private Individual newIndividual;
        private MassiveLoaderRequestItem__c requestItem;
        private List<String> csvSplitted;
    }

}