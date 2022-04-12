@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_ProcessSales extends HDT_UTL_ProcessExecution {

    private Map<String, MassiveFieldsObjectMap__c> sobjectMap;
    private Map<String, String> mapAllFields;
    private Map<String, String> mapWrapperAccountFields;
    private List<Account> accountList;
    private Map<String, Id> codicePuntoMap;
    private Set<String> csnSet = new Set<String>();
    private Set<String> codicePuntoSet = new Set<String>();
    private Set<String> fiscalCodeSet = new Set<String>();
    private Set<String> vatNumberSet = new Set<String>();
    private Set<String> marcaturaSet = new Set<String>();
    private Set<String> contoContrattualeSet = new Set<String>();
    private List<MassiveLoaderRequestItem__c> itemsToUpdate;
    private List<HDT_WRP_ProcessObjects> processObjList;
    private Map<String, Id> recordTypeMap;
    private Integer contoContrattualeIndex;
    private Integer codicePuntoIndex;
    private Integer recTypeIndex;
    private Map<Id, Id> accountContactMap = new Map<Id, Id>();
    private Map<String, Id> billProfMap;

    public override void checks(){
        System.debug(LoggingLevel.DEBUG, 'checks');
        mapFieldsObject();

        contoContrattualeIndex = mapHeaderForWrapper.get('BillingProfileContoContrattuale');
        codicePuntoIndex = mapHeaderForWrapper.get('ServicePointCodicePunto');
        recTypeIndex = mapHeaderForWrapper.get('AccountTipo');

        HDT_WRP_ProcessObjects processObj;
        processObjList = new List<HDT_WRP_ProcessObjects>();
        itemsToUpdate = new List<MassiveLoaderRequestItem__c>();
        List<String> tempSplitedFields;
        for(MassiveLoaderRequestItem__c item : requestItemList){

            tempSplitedFields = new List<String>();
            tempSplitedFields = item.Data__c.split(splitCharacter, -1);
            
            checkRequiredFields(item, tempSplitedFields);
            System.debug(LoggingLevel.DEBUG, '>>> itemStatus' + item.Status__c);

            if(item.Status__c.equalsIgnoreCase('Errore')){
                itemsToUpdate.add(item);
                continue;
            }

            processObj = new HDT_WRP_ProcessObjects();
            processObj.requestItem = item;
            processObj.csvSplitted = tempSplitedFields;

            codicePuntoSet.add(processObj.csvSplitted[codicePuntoIndex]);
            contoContrattualeSet.add(processObj.csvSplitted[contoContrattualeIndex]);

            processObjList.add(processObj);
        }
    }

    public override void getRecords(){
        System.debug(LoggingLevel.DEBUG, 'getRecords');

        recordTypeMap = new Map<String, Id>();
        codicePuntoMap = new Map<String, Id>();
        billProfMap = new Map<String, Id>();

        recordTypeMap.put('Business', Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Business').getRecordTypeId());
        recordTypeMap.put('Residenziale', Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Residenziale').getRecordTypeId());
        recordTypeMap.put('Gas', Schema.SObjectType.ServicePoint__c.getRecordTypeInfosByDeveloperName().get('HDT_RT_Gas').getRecordTypeId());
        recordTypeMap.put('Ele', Schema.SObjectType.ServicePoint__c.getRecordTypeInfosByDeveloperName().get('HDT_RT_Ele').getRecordTypeId());

        for(ServicePoint__c sp : [SELECT Id, ServicePointCode__c FROM ServicePoint__c WHERE ServicePointCode__c IN :codicePuntoSet]){
            codicePuntoMap.put(sp.ServicePointCode__c, sp.Id);
        }

        for(BillingProfile__c bp : [SELECT Id, ContractAccountCode__c FROM BillingProfile__c WHERE ContractAccountCode__c IN :contoContrattualeSet]){
            billProfMap.put(bp.ContractAccountCode__c, bp.Id);
        }

    }

    public override void registryCreation(){

        getLimitDetails('START registryCreation');

        if(processObjList.size() == 0){
            return;
        }

        List<sObject> accountToInsert;
        List<MassiveLoaderRequestItem__c> requestItemForUpsert;
        List<Contact> saveContactList;
        List<BillingProfile__c> saveBillProfList;
        List<ServicePoint__c> saveServPointList;
        List<AccountContactRelation> acrList;

        accountToInsert = new List<sObject>();
        requestItemForUpsert = new List<MassiveLoaderRequestItem__c>();
        saveContactList = new List<Contact>();
        saveBillProfList = new List<BillingProfile__c>();
        saveServPointList = new List<ServicePoint__c>();

        Integer count = 0;
        String convertionError;
        String csvHeader;
        String objField;

        for(HDT_WRP_ProcessObjects processObj : processObjList){
 
            processObj.account = new Account();
            processObj.billingProfile = new BillingProfile__c();
            processObj.servicePoint = new ServicePoint__c();
            processObj.servicePointWrapper = new Map<String, String>();
            
            count = 0;
            convertionError = '';
            csvHeader = '';
            objField = '';

            System.debug(LoggingLevel.DEBUG, '>>> tempSplitted ' + processObj.csvSplitted.size());

            processObj.createServicePoint = (String.isNotEmpty(processObj.csvSplitted[codicePuntoIndex]) && codicePuntoMap.containsKey(processObj.csvSplitted[codicePuntoIndex])) ? false : true;
            processObj.createBillingProfile = (String.isNotEmpty(processObj.csvSplitted[contoContrattualeIndex]) && billProfMap.containsKey(processObj.csvSplitted[contoContrattualeIndex])) ? false : true;
            
            //if(String.isNotEmpty(processObj.csvSplitted[codicePuntoIndex]) && codicePuntoMap.containsKey(processObj.csvSplitted[codicePuntoIndex])){
            //    processObj.createServicePoint = false;
            //} else {
            //    processObj.createServicePoint = true;
            //}
            
            //if(String.isNotEmpty(processObj.csvSplitted[contoContrattualeIndex]) && billProfMap.containsKey(processObj.csvSplitted[contoContrattualeIndex])){
            //    processObj.createBillingProfile = false;
            //} else {
            //    processObj.createBillingProfile = true;
            //}

            System.debug(LoggingLevel.DEBUG, '>>> enableCreate: billProf [' + processObj.createBillingProfile + ']; servPoint [' + processObj.createServicePoint + ']');

            //processObj.account.RecordTypeId = recordTypeMap.get(processObj.csvSplitted[recTypeIndex]);
            
            for (String tempField : processObj.csvSplitted) {

                if ('null'.equalsIgnoreCase(tempField)) {
                   tempField = '';
                }
                
                csvHeader = mapHeaderByPosition.get(count);
                objField = mapAllFields.get(csvHeader);
            
                if(String.isNotBlank(objField) && String.isNotBlank(tempField)){
                    System.debug(LoggingLevel.DEBUG, '>>> CSV Header: ' + csvHeader + '; sObj Field: ' + objField + '; value: ' + tempField);
                    
                    if(sobjectMap.containsKey(csvHeader)){

                        switch on sobjectMap.get(csvHeader).objectType__c {
                            when 'Account' {
                                convertionError = mapTypeField(processObj.account, mapAllFields, count, tempField);
                            }
                            when 'BillingProfile__c' {
                                if(processObj.createBillingProfile){
                                    convertionError = mapTypeField(processObj.billingProfile, mapAllFields, count, tempField);
                                }
                            }
                            when 'ServicePoint__c' {
                                if(processObj.createServicePoint){
                                    convertionError = mapTypeField(processObj.servicePoint, mapAllFields, count, tempField);
                                }
                            }
                            when 'WrapperSerPoint' {
                                if(processObj.createServicePoint){
                                    processObj.servicePointWrapper.put(mapAllFields.get(mapHeaderByPosition.get(count)), tempField);
                                }
                            }
                        }
                        
                    }
                    
                    if(String.isNotEmpty(convertionError)){
                        // error happened -> exit
                        System.debug(LoggingLevel.DEBUG, '>>> break for loop...' + csvHeader + ' - ' + objField + ' - ' + tempField);
                        break;
                    }
                }

                count++;
            }

            //processObj.csvSplitted.clear();

            if(String.isNotEmpty(convertionError)){
                processObj.requestItem.Status__c = 'Errore';
                processObj.requestItem.StatusDescription__c = convertionError;
                continue;
            }

            //processObj.account.Name = String.isBlank(processObj.account.FirstName__c) ? processObj.account.LastName__c : processObj.account.FirstName__c + ' ' + processObj.account.LastName__c;
            //processObj.account.BillingIsAddressVerified__c = true;

            //System.debug(LoggingLevel.DEBUG, '>>> currentAccount: ' + processObj.account);
            //System.debug(LoggingLevel.DEBUG, '>>> currentBillingProfile: ' + processObj.billingProfile);
            //System.debug(LoggingLevel.DEBUG, '>>> currentServicePoint: ' + processObj.servicePoint);

            addInformationToSet(processObj.account);

        }

        accountList = HDT_QR_ProcessSales.getAccountList(fiscalCodeSet, vatNumberSet, marcaturaSet, csnSet);

        clearAllUselessSets();

        for(HDT_WRP_ProcessObjects processObj : processObjList){

            if(processObj.requestItem.Status__c.equalsIgnoreCase('Errore')){
                System.debug(LoggingLevel.DEBUG, '>>> requestItem.Status__c ');
                continue;
            }

            processObj.account.RecordTypeId = recordTypeMap.get(processObj.csvSplitted[recTypeIndex]);
            processObj.account.Name = String.isBlank(processObj.account.FirstName__c) ? processObj.account.LastName__c : processObj.account.FirstName__c + ' ' + processObj.account.LastName__c;
            processObj.account.BillingIsAddressVerified__c = true;
            processObj.account.Id = setAccountIdFromDb(processObj.account);

            if(processObj.account.Id == null){
                requestItemForUpsert.add(processObj.requestItem);
                accountToInsert.add(processObj.account);
            }

        }

        HDT_WRP_SaveResponse saveAccountResponse;
        saveAccountResponse = databaseUpsert(accountToInsert, requestItemForUpsert, 'Account');

        System.debug(LoggingLevel.DEBUG, '>>> savedObject ' + saveAccountResponse.savedObject);
        System.debug(LoggingLevel.DEBUG, '>>> itemIdToObjId: ' + saveAccountResponse.itemIdToObjId);
        System.debug(LoggingLevel.DEBUG, '>>> errorItemMap: ' + saveAccountResponse.errorItemMap);

        requestItemForUpsert.clear();
        requestItemForUpsert = new List<MassiveLoaderRequestItem__c>();

        for(HDT_WRP_ProcessObjects processObj : processObjList){

            if(saveAccountResponse.errorItemMap.containsKey(processObj.requestItem.Id)){
                System.debug(LoggingLevel.DEBUG, '>>> requestItem.Status__c after save');
                processObj.requestItem.Status__c = 'Errore';
                processObj.requestItem.StatusDescription__c = saveAccountResponse.errorItemMap.get(processObj.requestItem.Id);
                continue;
            }

            if(saveAccountResponse.itemIdToObjId.containsKey(processObj.requestItem.Id)){
                System.debug(LoggingLevel.DEBUG, '>>> you can now create a contact');
                // account not present in DB - create new account and contact
                processObj.contact = new Contact();
                processObj.contact.AccountId = saveAccountResponse.itemIdToObjId.get(processObj.requestItem.Id);
                processObj.contact = createContact(processObj.contact, processObj.account);
                System.debug(LoggingLevel.DEBUG, '>>> currentContact: ' + processObj.contact);
                requestItemForUpsert.add(processObj.requestItem);
                saveContactList.add(processObj.contact);
            }
        }

        HDT_WRP_SaveResponse saveContactResponse;
        if(saveContactList.size() > 0){
            System.debug(LoggingLevel.DEBUG, '>>> save contact');
            saveContactResponse = databaseUpsert(saveContactList, requestItemForUpsert, 'Contact');
            System.debug('>>>>> ' + saveContactResponse.errorItemMap);
        }

        requestItemForUpsert.clear();
        requestItemForUpsert = new List<MassiveLoaderRequestItem__c>();

        Id accountId;
        List<Id> accountIdsList = new List<Id>();
        for(HDT_WRP_ProcessObjects processObj : processObjList){

            if(saveAccountResponse.errorItemMap.containsKey(processObj.requestItem.Id)){
                System.debug(LoggingLevel.DEBUG, '>>> requestItem.Status__c error');
                processObj.requestItem.Status__c = 'Errore';
                processObj.requestItem.StatusDescription__c = saveAccountResponse.errorItemMap.get(processObj.requestItem.Id);
                continue;
            }

            if(processObj.account.Id == null){
                if(saveAccountResponse.itemIdToObjId.containsKey(processObj.requestItem.Id)){
                    accountId = saveAccountResponse.itemIdToObjId.get(processObj.requestItem.Id);
                }   
            } else {
                accountId = processObj.account.Id;
            }
            
            if(accountId != null){
                requestItemForUpsert.add(processObj.requestItem);
                accountIdsList.add(accountId);
            }

            if(processObj.createBillingProfile){
                processObj.billingProfile.Account__c = accountId;
                System.debug(LoggingLevel.DEBUG, '>>> currentBillingProfile: ' + processObj.billingProfile);
                saveBillProfList.add(processObj.billingProfile);
            }

            if(processObj.createServicePoint){
                processObj.servicePoint.Account__c = accountId;

                if(processObj.servicePointWrapper.size() > 0){
                    if(processObj.servicePointWrapper.containsKey('Distributor__r')){
                        processObj.servicePoint.Distributor__r = new Account(GlobalMigrationKey__c = processObj.servicePointWrapper.get('Distributor__r'));
                    }
                }

                if(String.isNotEmpty(processObj.servicePoint.ServicePointCode__c)){
                    processObj.servicePoint.Name = processObj.servicePoint.ServicePointCode__c;
                }
                processObj.servicePoint.RecordTypeId = recordTypeMap.get(processObj.servicePoint.CommoditySector__c);

                System.debug(LoggingLevel.DEBUG, '>>> currentServicePoint: ' + processObj.servicePoint);
                saveServPointList.add(processObj.servicePoint);
            }
            

        }

        System.debug(LoggingLevel.DEBUG, '>>> save billProf and servPoint');

        HDT_WRP_SaveResponse saveBillProfResponse;
        HDT_WRP_SaveResponse saveServPointResponse;
        
        System.debug(LoggingLevel.DEBUG, '>>> saveBillProfList ' + saveBillProfList.size());
        System.debug(LoggingLevel.DEBUG, '>>> saveServPointList ' + saveServPointList.size());

        if(saveBillProfList.size() > 0){
            System.debug(LoggingLevel.DEBUG, '>>> save BillingProfile__c');
            saveBillProfResponse = databaseUpsert(saveBillProfList, requestItemForUpsert, 'BillingProfile__c');
            System.debug(LoggingLevel.DEBUG, '>>> saveBillProfResponse: ' + saveBillProfResponse.itemIdToObjId);
        }
        
        if(saveServPointList.size() > 0){
            System.debug(LoggingLevel.DEBUG, '>>> save ServicePoint__c');
            saveServPointResponse = databaseUpsert(saveServPointList, requestItemForUpsert, 'ServicePoint__c');
            System.debug(LoggingLevel.DEBUG, '>>> saveServPointResponse: ' + saveServPointResponse.itemIdToObjId);
        }
        
        System.debug(LoggingLevel.DEBUG, '>>> accountIdsList: ' + accountIdsList.size());

        if(accountIdsList.size() > 0){
            System.debug(LoggingLevel.DEBUG, '>>> get AccountContactRelation');
            acrList = HDT_QR_ProcessSales.getAccountContactRelationByAccountId(acrList, accountIdsList);
        }

        if(acrList != null && acrList.size() > 0){
            for(AccountContactRelation acr : acrList){
                if(String.isEmpty(acr.Roles)){
                    acr.Roles = 'Titolare';
                }
                accountContactMap.put(acr.AccountId, acr.ContactId);
            }

            update acrList;
        }

        getLimitDetails('AFTER OBJs CREATION');

        HDT_WRP_NextDataObj nextDataObj;

        for(HDT_WRP_ProcessObjects processObj : processObjList){

            if(processObj.requestItem.Status__c.equalsIgnoreCase('Errore')){
                itemsToUpdate.add(processObj.requestItem);
                continue;
            }

            if(saveBillProfResponse != null && saveBillProfResponse.errorItemMap.containsKey(processObj.requestItem.Id)){
                processObj.requestItem.Status__c = 'Errore';
                processObj.requestItem.StatusDescription__c = saveBillProfResponse.errorItemMap.get(processObj.requestItem.Id);
                itemsToUpdate.add(processObj.requestItem);
                continue;
            }

            if(saveServPointResponse != null && saveServPointResponse.errorItemMap.containsKey(processObj.requestItem.Id)){
                processObj.requestItem.Status__c = 'Errore';
                processObj.requestItem.StatusDescription__c = saveServPointResponse.errorItemMap.get(processObj.requestItem.Id);
                itemsToUpdate.add(processObj.requestItem);
                continue;
            }

            nextDataObj = new HDT_WRP_NextDataObj();

            nextDataObj.accountId = processObj.account.Id;
            nextDataObj.contactId = (accountContactMap.containsKey(nextDataObj.accountId)) ? accountContactMap.get(nextDataObj.accountId) : null;

            if(processObj.createBillingProfile){
                if(saveBillProfResponse.itemIdToObjId.containsKey(processObj.requestItem.Id)){
                    nextDataObj.billProfId = saveBillProfResponse.itemIdToObjId.get(processObj.requestItem.Id);
                }
            } else {
                nextDataObj.billProfId = billProfMap.get(processObj.csvSplitted[contoContrattualeIndex]);
            }

            if(processObj.createServicePoint){
                if(saveServPointResponse.itemIdToObjId.containsKey(processObj.requestItem.Id)){
                    nextDataObj.servPointId = saveServPointResponse.itemIdToObjId.get(processObj.requestItem.Id);
                }
            } else {
                nextDataObj.servPointId = codicePuntoMap.get(processObj.csvSplitted[codicePuntoIndex]);
            }

            processObj.requestItem.NextStepData__c = JSON.serialize(nextDataObj);
            processObj.requestItem.Status__c = 'In Lavorazione';
            itemsToUpdate.add(processObj.requestItem);
            
        }

    }

    public override void finalUpdate(){
        System.debug(LoggingLevel.DEBUG, 'finalUpdate');

        if(itemsToUpdate.size() > 0){
            update itemsToUpdate;
        }
    }

    public void addInformationToSet(Account account){
        if(String.isNotEmpty(account.CustomerCode__c)){
            csnSet.add(account.CustomerCode__c);
        }
    
        if(String.isNotEmpty(account.FiscalCode__c)){
            fiscalCodeSet.add(account.FiscalCode__c);
        }
    
        if(String.isNotEmpty(account.VATNumber__c)){
            vatNumberSet.add(account.VATNumber__c);
        }
    
        if(String.isNotEmpty(account.CustomerMarking__c)){
            marcaturaSet.add(account.CustomerMarking__c);
        }
    }

    public Id setAccountIdFromDb(Account iterationAccount){

        //search by CustomerCode__c --> CSN (csv header)
        if(String.isNotEmpty(iterationAccount.CustomerCode__c)){
            for(Account a : accountList){
                if(a.CustomerCode__c.equalsIgnoreCase(iterationAccount.CustomerCode__c)){
                    System.debug(LoggingLevel.DEBUG, '>>> Account id [' + a.Id + '] found by CustomerCode__c -> ' + iterationAccount.CustomerCode__c);
                    return a.Id;
                }
            }
        }
        
        //search by FiscalCode__c, VATNumber__c and CustomerMarking__c
        if( String.isNotEmpty(iterationAccount.FiscalCode__c) &&
            String.isNotEmpty(iterationAccount.VATNumber__c) &&
            String.isNotEmpty(iterationAccount.CustomerMarking__c)
        ) {
            for(Account a : accountList){
                if(
                    a.FiscalCode__c.equalsIgnoreCase(iterationAccount.FiscalCode__c) &&
                    a.VATNumber__c.equalsIgnoreCase(iterationAccount.VATNumber__c) &&
                    a.CustomerMarking__c.equalsIgnoreCase(iterationAccount.CustomerMarking__c)
                ){
                    System.debug(LoggingLevel.DEBUG, '>>> Account id [' + a.Id + '] found by FiscalCode__c,VATNumber__c,CustomerMarking__c');
                    return a.Id;
                }
            }
        }

        return null;

    }

    private void mapFieldsObject(){
        List<MassiveFieldsObjectMap__c> allFieldForThisProcess;

        mapAllFields = new Map<String, String>();
        mapWrapperAccountFields = new Map<String, String>();

        sobjectMap = new Map<String, MassiveFieldsObjectMap__c>();
        //allFieldForThisProcess = HDT_QR_ProcessPostSales.getMapFieldsObjectByDeveloperName('Sales%');
        allFieldForThisProcess = [
            SELECT objectType__c, labelField__c, nameField__c
            FROM MassiveFieldsObjectMap__c 
            WHERE Name LIKE 'Sales%'
            WITH SECURITY_ENFORCED
        ];

        for(MassiveFieldsObjectMap__c temp : allFieldForThisProcess){

            if(temp.objectType__c.equalsIgnoreCase('WrapperAccount')){
                mapWrapperAccountFields.put(temp.labelField__c, temp.nameField__c);
            } else {
                mapAllFields.put(temp.labelField__c, temp.nameField__c);
            }
            sobjectMap.put(temp.labelField__c, temp);
        }
    }

    private Contact createContact(Contact contact, Account account){
        contact.DegreeOfStudies__c = account.DegreeOfStudies__c;
        contact.CompanyOwner__c = account.CompanyOwner__c;
        contact.LastName = account.LastName__c;
        contact.Gender__c = account.Gender__c;
        contact.FirstName = account.FirstName__c;
        contact.Birthdate = account.BirthDate__c;
        contact.FiscalCode__c = account.FiscalCode__c;
        contact.Birthcity__c = account.BirthProvince__c;
        contact.MobilePhonePrefix__c = account.MobilePhonePrefix__c;
        contact.Phone = account.Phone;
        contact.MobilePhone = account.MobilePhone__c;
        contact.Email = account.PrimaryEmail__c;
        contact.PhonePrefix__c = account.PhonePrefix__c;
        contact.Fax = account.FAX__c;                       
        contact.Profession__c = account.Profession__c;             
        contact.MailingCity = account.BillingCity;           
        contact.MailingCityCode__c = account.BillingCityCode__c;                  
        contact.MailingCountry = account.BillingCountry;              
        contact.MailingPostalCode = account.BillingPostalCode;                 
        contact.MailingState = account.BillingState;            
        contact.MailingStreet = account.BillingStreet;             
        contact.MailingStreetName__c = account.BillingStreetName__c;                    
        contact.MailingStreetCode__c = account.BillingStreetCode__c;                    
        contact.MailingStreetNumber__c = account.BillingStreetNumber__c;                      
        contact.MailingStreetNumberExtension__c = account.BillingStreetNumberExtension__c;                               
        contact.MailingStreetToponym__c = account.BillingStreetToponym__c;                       
        contact.MailingRegion__c = account.BillingRegion__c;                
        contact.MailingPlace__c = account.BillingPlace__c;                
        contact.MailingPlaceCode__c = account.BillingPlaceCode__c;                    
        contact.MailingIsAddressVerified__c = account.BillingIsAddressVerified__c;
        return contact;
    }

    public void clearAllUselessSets(){
        fiscalCodeSet.clear();
        vatNumberSet.clear();
        marcaturaSet.clear();
        csnSet.clear();
    }

    private class HDT_WRP_ProcessObjects {
        private Account account;
        private Contact contact;
        private BillingProfile__c billingProfile;
        private ServicePoint__c servicePoint;
        private Map<String, String> servicePointWrapper;
        private Boolean createServicePoint;
        private Boolean createBillingProfile;
        private MassiveLoaderRequestItem__c requestItem;
        private List<String> csvSplitted;
    }

    public class HDT_WRP_NextDataObj {
        public String accountId;
        public String contactId;
        public String billProfId;
        public String servPointId;
    }

}