@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_ProcessLead extends HDT_UTL_ProcessExecution {

    private Map<String, String> mapLeadFields;
    private Map<String, String> mapIndividualFields;
    private List<Lead> existingLeadList;
    private List<HDT_WRP_ProcessObjects> processObjList;
    private List<MassiveLoaderRequestItem__c> itemsToSave;
    private HDT_WRP_LeadDataForRetrieve leadDataForRetrieve;

    public override void checks(){

        itemsToSave = new List<MassiveLoaderRequestItem__c>();

        mapFieldsObject();

        HDT_WRP_ProcessObjects processObj;
        leadDataForRetrieve = new HDT_WRP_LeadDataForRetrieve();
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

            System.debug(LoggingLevel.DEBUG, '>>> current lead: ' + processObj.newLead);
            System.debug(LoggingLevel.DEBUG, '>>> current individual: ' + processObj.newIndividual);

        }

    }

    public override void getRecords(){
        existingLeadList = new List<Lead>();
        existingLeadList = HDT_QR_Lead.getCurrentRecords(leadDataForRetrieve);
    }

    public override void registryCreation(){

        System.debug(LoggingLevel.DEBUG, '>>> existingLeadList: ' + existingLeadList.size());
        System.debug(LoggingLevel.DEBUG, '>>> requestItemList: ' + requestItemList.size());

        List<Lead> leadtoUpsert = new List<Lead>();
        List<MassiveLoaderRequestItem__c> itemList = new List<MassiveLoaderRequestItem__c>();

        Lead existingLead;
        for(HDT_WRP_ProcessObjects processObj : processObjList){
            existingLead = searchLead(processObj.newLead);

            if(existingLead != null){
                // in this case upsert existing lead
                System.debug(LoggingLevel.DEBUG, '>>> existingLead: ' + existingLead.Id);

                for(String tempField : mapLeadFields.values()) {
                    if(String.isBlank(String.valueOf(existingLead.get(tempField))) || 'LeadValidityEndDate__c'.equalsIgnoreCase(tempField)) {
                        existingLead.put(tempField, processObj.newLead.get(tempField));
                    }
                }
               
                existingLead.LeadReceptionDate__c = processObj.newLead.LeadReceptionDate__c;
                processObj.newLead = existingLead;

            } else {
                // in this case insert lead
                System.debug(LoggingLevel.DEBUG, '>>> no lead in db');
            }
            
            leadtoUpsert.add(processObj.newLead);
            itemList.add(processObj.requestItem);

        }

        HDT_WRP_SaveResponse leadUpsertResponse;
        leadUpsertResponse = databaseUpsert(leadtoUpsert, itemList, 'Lead');

        //System.debug(LoggingLevel.DEBUG, '>>> reponseItemList: ' + leadUpsertResponse.reponseItemList);
        //System.debug(LoggingLevel.DEBUG, '>>> savedObject: ' + leadUpsertResponse.savedObject);
        System.debug(LoggingLevel.DEBUG, '>>> itemIdToObjId: ' + leadUpsertResponse.itemIdToObjId);
        System.debug(LoggingLevel.DEBUG, '>>> errorItemMap: ' + leadUpsertResponse.errorItemMap);

        if(leadUpsertResponse.reponseItemList.size() > 0){
            itemsToSave.addAll(leadUpsertResponse.reponseItemList);
        }

        //List<Lead> listAfterInsert = HDT_QR_Lead.getCurrentRecords(currentProcess.currentLead);
        //currentProcess.currentLead = listAfterInsert.get(0);
        //currentProcess.currentIndividual.id = currentProcess.currentLead.IndividualId;
        //update currentProcess.currentIndividual;

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

    private void setValueToSets(Lead currentLead){

        if(String.isNotBlank(currentLead.FirstName)){
            leadDataForRetrieve.firstNameSet.add(currentLead.FirstName);
        }

        if(String.isNotBlank(currentLead.LastName)){
            leadDataForRetrieve.lastNameSet.add(currentLead.LastName);
        }

        if(String.isNotBlank(currentLead.CompanyOwner__c)){
            leadDataForRetrieve.companyOwnerSet.add(currentLead.CompanyOwner__c);
        }

        if(String.isNotBlank(currentLead.MobilePhone)){
            leadDataForRetrieve.mobilePhoneSet.add(currentLead.MobilePhone);
        }

        if(String.isNotBlank(currentLead.Phone)){
            leadDataForRetrieve.phoneSet.add(currentLead.Phone);
        }

        if(String.isNotBlank(currentLead.Email)){
            leadDataForRetrieve.emailSet.add(currentLead.Email);
        }

    }

    private Lead searchLead(Lead newLead){

        Boolean firstName;
        Boolean lastName;
        Boolean companyOwner;
        Boolean mobilePhone;
        Boolean phone;
        Boolean email;

        Lead leadFound;

        for(Lead l : existingLeadList){

            firstName = l.FirstName == newLead.FirstName;
            lastName = l.LastName == newLead.LastName;
            companyOwner = l.CompanyOwner__c == newLead.CompanyOwner__c;
            mobilePhone = l.MobilePhone == newLead.MobilePhone;
            phone = l.Phone == newLead.Phone;
            email = l.Email == newLead.Email;

            if( firstName && lastName && companyOwner && (mobilePhone || phone || email) ) {
                leadFound = l;
                break;
            }
        }

        return leadFound;

    }

    private class HDT_WRP_ProcessObjects {
        private Lead newLead;
        private Individual newIndividual;
        private MassiveLoaderRequestItem__c requestItem;
        private List<String> csvSplitted;
    }

    public class HDT_WRP_LeadDataForRetrieve {
        public Set<String> firstNameSet;
        public Set<String> lastNameSet;
        public Set<String> companyOwnerSet;
        public Set<String> mobilePhoneSet;
        public Set<String> phoneSet;
        public Set<String> emailSet;

        public HDT_WRP_LeadDataForRetrieve(){
            firstNameSet = new Set<String>();
            lastNameSet = new Set<String>();
            companyOwnerSet = new Set<String>();
            mobilePhoneSet = new Set<String>();
            phoneSet = new Set<String>();
            emailSet = new Set<String>();
        }

    }

}