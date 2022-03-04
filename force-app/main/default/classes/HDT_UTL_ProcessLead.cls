@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_ProcessLead extends HDT_UTL_ProcessExecution {

    private Map<String, String> mapLeadFields;
    private Map<String, String> mapIndividualFields;
    private List<Lead> listLead;
    private List<HDT_WRP_ProcessObjects> processObjList;
    private List<MassiveLoaderRequestItem__c> itemsToSave;

    private Set<String> firstNameSet = new Set<String>();
    private Set<String> lastNameSet = new Set<String>();
    private Set<String> companyOwnerSet = new Set<String>();

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

                //// Se devo essere aggiunti altri campi req
                //if(String.isNotBlank(mapLeadFields.get(mapHeaderByPosition.get(count)))&& String.isNotBlank(tempField) ){
                //    mapTypeField(currentProcess.currentLead,mapLeadFields,count,tempField);
                //}

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
            setValueToSets(processObj.newLead);

            System.debug('>>> current lead: ' + processObj.newLead);
            System.debug('>>> current individual: ' + processObj.newIndividual);

        }

    }

    /*public override void getRecords(){

        if(String.isNotBlank(currentProcess.currentLead.FirstName) &&
           String.isNotBlank(currentProcess.currentLead.LastName) &&
           String.isNotBlank(currentProcess.currentLead.CompanyOwner__c)
        ) {
            listLead = HDT_QR_Lead.getCurrentRecords(currentProcess.currentLead);
        }
       
    }

    /*public override void registryCreation(){

        if (listLead!=null && listLead.size()>0) {
            Lead oldLead=listLead.get(0);
            for (String tempField : mapLeadFields.values()) {
                if ( String.isBlank(String.valueOf(oldLead.get(tempField))) ||'LeadValidityEndDate__c'.equalsIgnoreCase(tempField)) {
                    oldLead.put(tempField,currentProcess.currentLead.get(tempField));
                }
            }
           
            oldLead.LeadReceptionDate__c=currentProcess.currentLead.LeadReceptionDate__c;
            currentProcess.currentLead=oldLead;

            update currentProcess.currentLead;
        }
        else {
            insert currentProcess.currentLead;
        }

        List<Lead> listAfterInsert = HDT_QR_Lead.getCurrentRecords(currentProcess.currentLead);
        currentProcess.currentLead = listAfterInsert.get(0);
        currentProcess.currentIndividual.id = currentProcess.currentLead.IndividualId;
        update currentProcess.currentIndividual;

    }


    public override void finalUpdate(){
        currentProcess.currentRequestItem.Lead__c = currentProcess.currentLead.Id;
        currentProcess.currentRequestItem.Status__c = constant.MASSIVLOADER_STATUS_CHIUSO;
        update currentProcess.currentRequestItem;
    }*/

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

    private void setValueToSets(Lead currentLead){

        if(String.isNotBlank(currentLead.FirstName)){
            firstNameSet.add(currentLead.FirstName);
        }

        if(String.isNotBlank(currentLead.LastName)){
            lastNameSet.add(currentLead.LastName);
        }

        if(String.isNotBlank(currentLead.CompanyOwner__c)){
            companyOwnerSet.add(currentLead.CompanyOwner__c);
        }

    }

    private class HDT_WRP_ProcessObjects {
        private Lead newLead;
        private Individual newIndividual;
        private MassiveLoaderRequestItem__c requestItem;
        private List<String> csvSplitted;
    }

}