@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_ProcessSales extends HDT_UTL_ProcessExecution {

    private Map<String, MassiveFieldsObjectMap__c> sobjectMap;
    private Map<String, String> mapAllFields;
    private Map<String, String> mapWrapperAccountFields;
    public List<Account> accountList;
    private Map<String, Id> codicePuntoMap;
    private Set<String> codicePuntoSet = new Set<String>();
    private Set<String> csnSet = new Set<String>();
    private Set<String> fiscalCodeSet = new Set<String>();
    private Set<String> contactFiscalCodeSet = new Set<String>();
    private Set<String> vatNumberSet = new Set<String>();
    private Set<String> marcaturaSet = new Set<String>();
    private Set<String> contoContrattualeSet = new Set<String>();
    private Set<String> sapContractCodeSet = new Set<String>();
    private List<MassiveLoaderRequestItem__c> itemsToUpdate;
    private List<HDT_WRP_ProcessObjects> processObjList;
    private Map<String, Id> recordTypeMap;
    private Integer contoContrattualeIndex;
    private Integer codicePuntoIndex;
    private Integer recTypeIndex;
    private Integer contractIndex;
    private Integer contactCfIndex;
    private Map<Id, Id> accountContactMap = new Map<Id, Id>();
    private Map<String, Id> billProfMap;
    Map<Id, Id> duplicateAccountMap;
    Map<String, Contact> contactReferenteMap;
    String accountRequiredFieldsError = Label.CarMass_SalesAccountRequiredFieldsError;

    public override void checks(){
        System.debug(LoggingLevel.DEBUG, 'checks');
        mapFieldsObject();

        contoContrattualeIndex = mapHeaderForWrapper.get('BillingProfileContoContrattuale');
        codicePuntoIndex = mapHeaderForWrapper.get('ServicePointCodicePunto');
        recTypeIndex = mapHeaderForWrapper.get('AccountTipo');
        contactCfIndex = mapHeaderForWrapper.get('ReferenteCF');
        HDT_WRP_ProcessObjects processObj;
        processObjList = new List<HDT_WRP_ProcessObjects>();
        itemsToUpdate = new List<MassiveLoaderRequestItem__c>();
        List<String> tempSplitedFields;
        for(MassiveLoaderRequestItem__c item : requestItemList){

            tempSplitedFields = new List<String>();
            tempSplitedFields = item.Data__c.split(splitCharacter, -1);
            
            if(!isTest){
                checkRequiredFields(item, tempSplitedFields);
            }
            
            System.debug(LoggingLevel.DEBUG, '>>> itemStatus' + item.Status__c);

            if(item.Status__c.equalsIgnoreCase('Errore')){
                itemsToUpdate.add(item);
                continue;
            }

            processObj = new HDT_WRP_ProcessObjects();
            processObj.requestItem = item;
            processObj.csvSplitted = tempSplitedFields;

            codicePuntoSet.add(processObj.csvSplitted[codicePuntoIndex]);
            if(contoContrattualeIndex != null){
                contoContrattualeSet.add(processObj.csvSplitted[contoContrattualeIndex]);
            }
            if(contactCfIndex != null){
                contactFiscalCodeSet.add(processObj.csvSplitted[contactCfIndex]);
            }
            processObjList.add(processObj);
        }

        if(processName.equalsIgnoreCase('MUC')){
            checkContract();
        }

        //System.debug(LoggingLevel.DEBUG, '>>> JSON ' + JSON.serialize(processObjList));

    }

    public void checkContract(){

        Map<String, Contract> contractMap = new Map<String, Contract>();
        Map<String, Order> contractOrderMap = new Map<String, Order>();
        Map<Id, Order> orderMap;
        List<Id> orderIdList = new List<Id>();
        Date todayDay = Date.today();
        contractIndex = mapHeaderForWrapper.get('Contratto');

        for(HDT_WRP_ProcessObjects processObj : processObjList){
            sapContractCodeSet.add(processObj.csvSplitted[contractIndex]);
        }

        List<Contract> contractList = [
            SELECT Id, SAPContractCode__c, Status, SBQQ__Order__c
            FROM Contract
            WHERE SAPContractCode__c IN :sapContractCodeSet
        ];

        System.debug(LoggingLevel.DEBUG, '>>> contract ' + contractList);

        for(Contract contr : contractList){
            contractMap.put(contr.SAPContractCode__c, contr);
            orderIdList.add(contr.SBQQ__Order__c);
        }

        // Se il contratto è ancora attivo.. Se cessato va in errore la singola riga
        // Se negli ultimi 100 giorni è presente un Cambio offerta sul contratto.. Se presente va in errore la singola riga

        List<Order> orderList = [
            SELECT Id, processType__c, CreatedDate,ContractReference__r.SAPContractCode__c
            FROM Order
            WHERE processType__c LIKE 'Cambio Offerta%'
            AND Status IN ('In Lavorazione','Completed')
            AND (NOT Phase__c IN ('Bozza Annullata','Annullato'))
            //AND Id IN :orderIdList
            AND ContractReference__r.SAPContractCode__c IN:contractMap.keySet()
        ];

        System.debug(LoggingLevel.DEBUG, '>>> orderList ' + orderList);
        for(Order singleOrder : orderList){
            contractOrderMap.put(singleOrder.ContractReference__r.SAPContractCode__c, singleOrder);
        }
        orderMap = new Map<Id, Order>(orderList);

        String sapContractCode;
        Contract currentContract;
        Order currentOrder;
        for(HDT_WRP_ProcessObjects processObj : processObjList){
            sapContractCode = processObj.csvSplitted[contractIndex];

            //System.debug(LoggingLevel.DEBUG, '>>> sapContractCode ' + sapContractCode);

            if(String.isNotEmpty(sapContractCode) && contractMap.containsKey(sapContractCode)){
                currentContract = contractMap.get(sapContractCode);

                System.debug(LoggingLevel.DEBUG, '>>> status ' + currentContract.Status);

                if(currentContract.Status.equalsIgnoreCase('Cessato')){
                    System.debug(LoggingLevel.DEBUG, '>>> Il contratto è cessato');
                    processObj.requestItem.Status__c = 'Errore';
                    processObj.requestItem.StatusDescription__c = 'Il contratto risulta "Cessato"';
                    //itemsToUpdate.add(processObj.requestItem);
                    continue;
                }

                if(contractOrderMap.containsKey(currentContract.SAPContractCode__c)){
                    currentOrder = contractOrderMap.get(currentContract.SAPContractCode__c);

                    Date orderCreatedDate = currentOrder.CreatedDate.date();
                    Integer numberDaysDue = orderCreatedDate.daysBetween(todayDay);

                    System.debug(LoggingLevel.DEBUG, '>>> orderCreatedDate ' + orderCreatedDate + ' - numberDaysDue ' + numberDaysDue);

                    if(numberDaysDue <= 100){
                        System.debug(LoggingLevel.DEBUG, '>>> siamo andati in errore');
                        processObj.requestItem.Status__c = 'Errore';
                        processObj.requestItem.StatusDescription__c = 'E\' presente un cambio offerta negli ultimi 100 giorni';
                        //itemsToUpdate.add(processObj.requestItem);
                        continue;     
                    }
                }
                
            }

        }

    }

    public override void getRecords(){
        System.debug(LoggingLevel.DEBUG, 'getRecords');

        recordTypeMap = new Map<String, Id>();
        codicePuntoMap = new Map<String, Id>();
        billProfMap = new Map<String, Id>();
        contactReferenteMap = new Map<String,Contact>();

        recordTypeMap.put('Organizzazione', Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Business').getRecordTypeId());
        recordTypeMap.put('Persona Fisica', Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Residenziale').getRecordTypeId());
        recordTypeMap.put('Gas', Schema.SObjectType.ServicePoint__c.getRecordTypeInfosByDeveloperName().get('HDT_RT_Gas').getRecordTypeId());
        recordTypeMap.put('Energia Elettrica', Schema.SObjectType.ServicePoint__c.getRecordTypeInfosByDeveloperName().get('HDT_RT_Ele').getRecordTypeId());

        for(ServicePoint__c sp : [SELECT Id, ServicePointCode__c FROM ServicePoint__c WHERE ServicePointCode__c IN :codicePuntoSet]){
            codicePuntoMap.put(sp.ServicePointCode__c, sp.Id);
        }

        System.debug('Set CC' + contoContrattualeSet);

        for(BillingProfile__c bp : [SELECT Id, ContractAccountCode__c FROM BillingProfile__c WHERE ContractAccountCode__c IN :contoContrattualeSet and ContractAccountCode__c != '']){
            billProfMap.put(bp.ContractAccountCode__c, bp.Id);
        }

        if(!contactFiscalCodeSet.isEmpty()){
            List<Contact> contactByFiscalCode = [SELECT Id,FiscalCode__c FROM Contact WHERE FiscalCode__c IN :contactFiscalCodeSet];
            if(contactByFiscalCode.size()>0){
                for(Contact singleContact : contactByFiscalCode){
                    contactReferenteMap.put(singleContact.FiscalCode__c, singleContact);
                }
            }
        }

    }

    public override void registryCreation(){

        getLimitDetails('START registryCreation');

        if(processObjList.size() == 0){
            return;
        }

        List<sObject> accountToInsert;
        List<sObject> accountReferenteToInsert;
        List<MassiveLoaderRequestItem__c> requestItemForUpsert;
        List<Contact> saveContactList;
        List<Contact> saveContactReferenteList;
        List<BillingProfile__c> saveBillProfList;
        List<ServicePoint__c> saveServPointList;
        List<AccountContactRelation> acrList;

        accountToInsert = new List<sObject>();
        accountReferenteToInsert = new List<sObject>();
        requestItemForUpsert = new List<MassiveLoaderRequestItem__c>();
        saveContactList = new List<Contact>();
        saveContactReferenteList = new List<Contact>();
        saveBillProfList = new List<BillingProfile__c>();
        saveServPointList = new List<ServicePoint__c>();

        Integer count = 0;
        String convertionError;
        String csvHeader;
        String objField;

        for(HDT_WRP_ProcessObjects processObj : processObjList){
 
            if(processObj.requestItem.Status__c == 'Errore'){
                continue;
            }

            processObj.account = new Account();
            processObj.billingProfile = new BillingProfile__c();
            processObj.servicePoint = new ServicePoint__c();
            processObj.servicePointWrapper = new Map<String, String>();
            processObj.contactRoleWrapper = new Map<String, String>();
            processObj.referente = new Contact();
            
            count = 0;
            convertionError = '';
            csvHeader = '';
            objField = '';

            System.debug(LoggingLevel.DEBUG, '>>> tempSplitted ' + processObj.csvSplitted.size());

            setEnableCreateObject(processObj);

            for (String tempField : processObj.csvSplitted) {

                if ('null'.equalsIgnoreCase(tempField)) {
                   tempField = '';
                }
                
                csvHeader = mapHeaderByPosition.get(count);
                objField = mapAllFields.get(csvHeader);
            
                if(String.isNotBlank(objField) && String.isNotBlank(tempField)){
                    //System.debug(LoggingLevel.DEBUG, '>>> CSV Header: ' + csvHeader + '; sObj Field: ' + objField + '; value: ' + tempField);
                    
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
                            when 'ContactRoleWrapper'{
                                if(processObj.createReferente){
                                    processObj.contactRoleWrapper.put(mapAllFields.get(mapHeaderByPosition.get(count)), tempField);
                                }
                                
                            }
                            when 'Contact'{
                                if(processObj.createReferente){
                                    convertionError = mapTypeField(processObj.referente, mapAllFields, count, tempField);
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
                processObj.requestItem.StatusDescription__c = convertionError.abbreviate(250);
                continue;
            }

            if(processObj.createServicePoint){
                convertionError = checkRequiredServicePointField(processObj.servicePoint);
                if(String.isNotEmpty(convertionError)){
                    processObj.requestItem.Status__c = 'Errore';
                    processObj.requestItem.StatusDescription__c = convertionError.abbreviate(250);
                    continue;
                }
            }

            addInformationToSet(processObj.account);

        }

        try{
            accountList = HDT_QR_ProcessSales.getAccountList(fiscalCodeSet, vatNumberSet, marcaturaSet, csnSet);
            clearAllUselessSets();
            //findDuplicateForAccounts();
        } catch(Exception e){
            System.debug(LoggingLevel.DEBUG, '>>> Exception ' + e.getMessage() + ' - ' + String.valueOf(e.getLineNumber()));
        }

        String requiredAccountFields;
        String requiredReferenteFields;
        for(HDT_WRP_ProcessObjects processObj : processObjList){

            requiredReferenteFields = '';

            if(processObj.requestItem.Status__c.equalsIgnoreCase('Errore')){
                System.debug(LoggingLevel.DEBUG, '>>> requestItem.Status__c ');
                continue;
            }

            if(recTypeIndex != null){
                processObj.account.RecordTypeId = recordTypeMap.get(processObj.csvSplitted[recTypeIndex]);
            }

            processObj.account.Name = String.isBlank(processObj.account.FirstName__c) ? processObj.account.LastName__c : processObj.account.FirstName__c + ' ' + processObj.account.LastName__c;
            processObj.account.BillingIsAddressVerified__c = true;

            requiredAccountFields = checkRequiredAccountFields(processObj.account);

            if(processObj.createReferente){
                requiredReferenteFields = checkRequiredReferenteFields(processObj.referente);
            }

            if(String.isNotEmpty(requiredAccountFields) || String.isNotEmpty(requiredReferenteFields)){
                processObj.requestItem.Status__c = 'Errore';
                processObj.requestItem.StatusDescription__c = (String.isNotBlank(requiredAccountFields)?requiredAccountFields:requiredReferenteFields).abbreviate(250);
                continue;
            }
            
            if(processObj.createReferente){
                handleReferenteCreation(processObj);
                if(processObj.accountReferente != null){
                    requestItemForUpsert.add(processObj.requestItem);
                    accountReferenteToInsert.add(processObj.accountReferente);
                }
            }

            processObj.account = setAccountFromDb(processObj.account);

            if(processObj.createBillingProfile){
                convertionError = checkRequiredBillingProfileField(processObj.billingProfile, processObj.account.Category__c);
                if(String.isNotEmpty(convertionError)){
                    processObj.requestItem.Status__c = 'Errore';
                    processObj.requestItem.StatusDescription__c = convertionError.abbreviate(250);
                    continue;
                }
            }

            if(processObj.account.Id == null){
                requestItemForUpsert.add(processObj.requestItem);
                accountToInsert.add(processObj.account);
            }

            //if(duplicateAccountMap.containsKey(processObj.requestItem.Id)){
            //    processObj.account.Id = duplicateAccountMap.get(processObj.requestItem.Id);
            //} else {
            //    requestItemForUpsert.add(processObj.requestItem);
            //    accountToInsert.add(processObj.account); 
            //}

            System.debug(LoggingLevel.DEBUG, '>>> accountId ' + processObj.account.Id);

        }

        HDT_WRP_SaveResponse saveAccountResponse;
        if(accountToInsert.size()>0){
            saveAccountResponse = databaseUpsert(accountToInsert, requestItemForUpsert, 'Account');
            System.debug(LoggingLevel.DEBUG, '>>> savedObject ' + saveAccountResponse.savedObject);
            System.debug(LoggingLevel.DEBUG, '>>> itemIdToObjId: ' + saveAccountResponse.itemIdToObjId);
            System.debug(LoggingLevel.DEBUG, '>>> errorItemMap: ' + saveAccountResponse.errorItemMap);
        }

        HDT_WRP_SaveResponse saveAccountReferenteResponse;
        if(accountReferenteToInsert.size()>0){
            // disabled only for test +++ saveAccountReferenteResponse = databaseUpsert(accountReferenteToInsert, requestItemForUpsert, 'Account');
        }

        requestItemForUpsert.clear();
        requestItemForUpsert = new List<MassiveLoaderRequestItem__c>();
        List<Id> accountIdsList = new List<Id>();
        for(HDT_WRP_ProcessObjects processObj : processObjList){

            if(processObj.requestItem.Status__c.equalsIgnoreCase('Errore')){
                System.debug(LoggingLevel.DEBUG, '>>> requestItem.Status__c ');
                continue;
            }

            if(saveAccountResponse != null && saveAccountResponse.errorItemMap.containsKey(processObj.requestItem.Id)){
                System.debug(LoggingLevel.DEBUG, '>>> requestItem.Status__c after save');
                processObj.requestItem.Status__c = 'Errore';
                processObj.requestItem.StatusDescription__c = (saveAccountResponse.errorItemMap.get(processObj.requestItem.Id)).abbreviate(250);
                continue;
            }

            if(saveAccountResponse != null &&  saveAccountResponse.itemIdToObjId.containsKey(processObj.requestItem.Id)){
                System.debug(LoggingLevel.DEBUG, '>>> you can now create a contact');
                // account not present in DB - create new account and contact
                processObj.contact = new Contact();
                processObj.contact.AccountId = saveAccountResponse.itemIdToObjId.get(processObj.requestItem.Id);
                processObj.contact = createContact(processObj.contact, processObj.account);  
                System.debug(LoggingLevel.DEBUG, '>>> currentContact: ' + processObj.contact);
                requestItemForUpsert.add(processObj.requestItem);
                saveContactList.add(processObj.contact);
            }
            if(processObj.createReferente){
                if(saveAccountReferenteResponse != null && saveAccountReferenteResponse.itemIdToObjId.containsKey(processObj.requestItem.Id)){
                    Id accountReferenteId = saveAccountReferenteResponse.itemIdToObjId.get(processObj.requestItem.Id);
                    processObj.referente.AccountId = accountReferenteId;
                    saveContactReferenteList.add(processObj.referente);
                    accountIdsList.add(accountReferenteId);
                }
            }
            
        }
        HDT_WRP_SaveResponse saveContactReferenteResponse;
        if(saveContactReferenteList.size() > 0){
            System.debug(LoggingLevel.DEBUG, '>>> save contact');
            saveContactReferenteResponse = databaseUpsert(saveContactReferenteList, requestItemForUpsert, 'Contact');
            System.debug('>>>>> ' + saveContactReferenteResponse.errorItemMap);
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
        
        for(HDT_WRP_ProcessObjects processObj : processObjList){

            if(processObj.requestItem.Status__c.equalsIgnoreCase('Errore')){
                //System.debug(LoggingLevel.DEBUG, '>>> requestItem.Status__c ');
                continue;
            }

            if(saveAccountResponse != null && saveAccountResponse.errorItemMap.containsKey(processObj.requestItem.Id)){
                //System.debug(LoggingLevel.DEBUG, '>>> requestItem.Status__c error');
                processObj.requestItem.Status__c = 'Errore';
                processObj.requestItem.StatusDescription__c = (saveAccountResponse.errorItemMap.get(processObj.requestItem.Id)).abbreviate(250);
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
        List<AccountContactRelation> acrListToInsert = new List<AccountContactRelation>();
        for(HDT_WRP_ProcessObjects processObj : processObjList){
            
            if(processObj.requestItem.Status__c.equalsIgnoreCase('Errore')){
                continue;
            }
            if(processObj.createReferente){
                AccountContactRelation acr = new AccountContactRelation();
                String accId = processObj.account.Id;
                String contId = processObj.referente.Id;
                if(String.isNotBlank(accId) && String.isNotBlank(contId)){
                    acr.AccountId = processObj.account.Id;
                    acr.ContactId = processObj.referente.Id;
                    acr.Roles = 'Legale Rappresentante';//processObj.contactRoleWrapper.get('Role');
                    acrListToInsert.add(acr);
                }
            }

            if(saveBillProfResponse != null && saveBillProfResponse.errorItemMap.containsKey(processObj.requestItem.Id)){
                processObj.requestItem.Status__c = 'Errore';
                processObj.requestItem.StatusDescription__c = (saveBillProfResponse.errorItemMap.get(processObj.requestItem.Id)).abbreviate(250);
                continue;
            }

            if(saveServPointResponse != null && saveServPointResponse.errorItemMap.containsKey(processObj.requestItem.Id)){
                processObj.requestItem.Status__c = 'Errore';
                processObj.requestItem.StatusDescription__c = (saveServPointResponse.errorItemMap.get(processObj.requestItem.Id)).abbreviate(250);
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
            
        }
        if(!acrListToInsert.isEmpty()){
            insert acrListToInsert;
        }

        for(HDT_WRP_ProcessObjects processObj : processObjList){
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

    /*private void findDuplicateForAccounts() {

        List<Account> accountToCompare = new List<Account>();
        duplicateAccountMap = new Map<Id, Id>();

        for(HDT_WRP_ProcessObjects processObj : processObjList){
            accountToCompare.add(processObj.account);
        }

        List<Datacloud.FindDuplicatesResult> results;
        results = Datacloud.FindDuplicates.findDuplicates(accountToCompare);

        for (Integer i=0; i < processObjList.size(); i++) {
            Account accountDup = null;
            for (Datacloud.DuplicateResult dr : results[i].getDuplicateResults()) {
                if (dr.matchResults.size() > 0 && dr.getMatchResults()[0].matchRecords.size() > 0) {
                    accountDup = (Account)dr.getMatchResults()[0].getMatchRecords()[0].getRecord();
                    duplicateAccountMap.put(processObjList[i].requestItem.Id, String.valueOf(accountDup.Id));
                    break;
                }
            }
            
        }

    }*/

    public void handleReferenteCreation(HDT_WRP_ProcessObjects processObject){
        Account accountTitolare = processObject.account;
        Contact contattoReferente = processObject.referente;
        String fiscalCode = contattoReferente.FiscalCode__c;
        if(contactReferenteMap.containsKey(fiscalCode)){
            //contactReferenteMap.AccountId = processObject.account.Id;
            processObject.referente.Id = contactReferenteMap.get(fiscalCode).Id;
        }else {
            processObject.accountReferente = new Account();
            processObject.accountReferente.Name = contattoReferente.FirstName + ' ' + contattoReferente.LastName;
            processObject.accountReferente.FirstName__c = contattoReferente.FirstName;
            processObject.accountReferente.LastName__c = contattoReferente.LastName;
            processObject.accountReferente.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Residenziale').getRecordTypeId();
            processObject.accountReferente.FiscalCode__c= contattoReferente.FiscalCode__c;
            processObject.accountReferente.PhonePrefix__c= contattoReferente.PhonePrefix__c;
            processObject.accountReferente.PrimaryEmail__c= contattoReferente.Email;
            processObject.accountReferente.FAX__c= contattoReferente.Fax;
            processObject.accountReferente.MobilePhonePrefix__c= contattoReferente.MobilePhonePrefix__c;
            processObject.accountReferente.MobilePhone__c= contattoReferente.MobilePhone;
            processObject.accountReferente.Phone = contattoReferente.Phone;
            processObject.accountReferente.Profession__c = contattoReferente.Profession__c;
            processObject.accountReferente.Gender__c = contattoReferente.Gender__c;
            processObject.accountReferente.DegreeOfStudies__c = contattoReferente.DegreeOfStudies__c;
            processObject.accountReferente.CompanyOwner__c = processObject.account.CompanyOwner__c;
            processObject.accountReferente.CustomerMarking__c = 'D1 - Persona fisica';
            processObject.accountReferente.Category__c = 'Famiglie';
            processObject.accountReferente.BillingPostalCode = contattoReferente.MailingPostalCode;
            processObject.accountReferente.BillingStreetName__c = contattoReferente.MailingStreet;
            processObject.accountReferente.BillingStreetNumber__c = contattoReferente.MailingStreetNumber__c;
            processObject.accountReferente.BillingState = contattoReferente.MailingState;
            processObject.accountReferente.BillingCountry = contattoReferente.MailingCountry;
            processObject.accountReferente.BillingIsAddressVerified__c=true;
        }
        
    }
    
    public String checkRequiredReferenteFields(Contact iterationContact){

        Boolean nameBool = String.isEmpty(iterationContact.FirstName);
        Boolean lastNameBool =  String.isEmpty(iterationContact.LastName);
        Boolean fiscalCodeBool =  String.isEmpty(iterationContact.FiscalCode__c);
        Boolean addressBool = String.isEmpty(iterationContact.MailingStreet);

        if(isTest){
            return '';
        }

        if(nameBool || lastNameBool || fiscalCodeBool){
            return 'Valorizzare Nome, Cognome, Codice Fiscale, Ruolo e indirizzo del Referente';
        }
        return '';
    }

    public String checkRequiredAccountFields(Account iterationAccount){

        Boolean fiscalCodeBool = String.isEmpty(iterationAccount.FiscalCode__c);
        Boolean vatNumberBool = String.isEmpty(iterationAccount.VATNumber__c);
        Boolean customerMarkingBool = String.isEmpty(iterationAccount.CustomerMarking__c);
        Boolean accountCodeBool = String.isEmpty(iterationAccount.CustomerCode__c);
        
        if(isTest){
            return null;
        }

        if(!accountCodeBool){
            return null;
        }else if(customerMarkingBool){
            return accountRequiredFieldsError;
        }else if(fiscalCodeBool && vatNumberBool){
            return accountRequiredFieldsError;
        }
        String email = iterationAccount.PrimaryEmail__c;
        String cellulare = iterationAccount.MobilePhone__c;
        String telefono = iterationAccount.OtherPhone__c;
        String prefissoTelefono = iterationAccount.PhonePrefix__c;
        String prefissoCellulare = iterationAccount.MobilePhonePrefix__c;
        String categoria = iterationAccount.Category__c;
        if(String.isBlank(email) && String.isBlank(telefono) && String.isBlank(cellulare)){
            return 'Valorizzare almeno un dato di contatto tra email, telefono e cellulare';
        }
        if(String.isNotBlank(cellulare) && String.isBlank(prefissoCellulare)){
            return 'Valorizzare il prefisso del Cellulare';
        }
        if(String.isNotBlank(telefono) && String.isBlank(prefissoTelefono)){
            return 'Valorizzare il prefisso del Telefono';
        }

        return null;

    }

    public Account setAccountFromDb(Account iterationAccount){

        Boolean customerCode;
        Boolean fiscalCode;
        Boolean vatNumber;
        Boolean customerMarking;

        //search by CustomerCode__c --> CSN (csv header)
        if(String.isNotEmpty(iterationAccount.CustomerCode__c)){
            for(Account a : accountList){
                customerCode = String.isNotEmpty(iterationAccount.CustomerCode__c) && String.isNotEmpty(a.CustomerCode__c) && a.CustomerCode__c.equalsIgnoreCase(iterationAccount.CustomerCode__c);
                fiscalCode = String.isNotEmpty(iterationAccount.FiscalCode__c) && String.isNotEmpty(a.FiscalCode__c) && a.FiscalCode__c.equalsIgnoreCase(iterationAccount.FiscalCode__c);
                vatNumber = String.isNotEmpty(iterationAccount.VATNumber__c) && String.isNotEmpty(a.VATNumber__c) && a.VATNumber__c.equalsIgnoreCase(iterationAccount.VATNumber__c);
                customerMarking = String.isNotEmpty(iterationAccount.CustomerMarking__c) && String.isNotEmpty(a.CustomerMarking__c) && a.CustomerMarking__c.equalsIgnoreCase(iterationAccount.CustomerMarking__c);

                if(
                    customerCode ||
                    (
                        (fiscalCode || vatNumber) && customerMarking
                    )
                ){

                //if(a.CustomerCode__c.equalsIgnoreCase(iterationAccount.CustomerCode__c)){
                    System.debug(LoggingLevel.DEBUG, '>>> Account id [' + a.Id + '] found by CustomerCode__c -> ' + iterationAccount.CustomerCode__c);
                    return a;
                }
            }
        }

        /*Boolean vatNumberBool;
        Boolean fiscalCodeBool;
        Boolean customerMarkingBool;

        for(Account a : accountList){

            vatNumberBool = String.isNotEmpty(a.VATNumber__c) && String.IsNotEmpty(iterationAccount.VATNumber__c) && a.VATNumber__c.equalsIgnoreCase(iterationAccount.VATNumber__c);
            fiscalCodeBool = String.isNotEmpty(a.FiscalCode__c) && String.IsNotEmpty(iterationAccount.FiscalCode__c) && a.FiscalCode__c.equalsIgnoreCase(iterationAccount.FiscalCode__c);
            customerMarkingBool = String.isNotEmpty(a.CustomerMarking__c) && String.IsNotEmpty(iterationAccount.CustomerMarking__c) && a.CustomerMarking__c.equalsIgnoreCase(iterationAccount.CustomerMarking__c);

            if(
                customerMarkingBool && (fiscalCodeBool || vatNumberBool )
            ){
                System.debug(LoggingLevel.DEBUG, '>>> Account id [' + a.Id + '] found by FiscalCode__c,VATNumber__c,CustomerMarking__c');
                return a;
            }
        }*/

        System.debug(LoggingLevel.DEBUG, '>>> no account found on db...');
        return iterationAccount;

    }

    private void mapFieldsObject(){
        List<MassiveFieldsObjectMap__c> allFieldForThisProcess;

        mapAllFields = new Map<String, String>();
        mapWrapperAccountFields = new Map<String, String>();

        sobjectMap = new Map<String, MassiveFieldsObjectMap__c>();
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

    private void setEnableCreateObject(HDT_WRP_ProcessObjects processObj){
        processObj.createServicePoint = (String.isNotEmpty(processObj.csvSplitted[codicePuntoIndex]) && codicePuntoMap.containsKey(processObj.csvSplitted[codicePuntoIndex])) ? false : true;
        processObj.createBillingProfile = (String.isNotEmpty(processObj.csvSplitted[contoContrattualeIndex]) && billProfMap.containsKey(processObj.csvSplitted[contoContrattualeIndex])) ? false : true;
        
        if(recTypeIndex != null){
            processObj.createReferente = ((String.isNotEmpty(processObj.csvSplitted[recTypeIndex]) && processObj.csvSplitted[recTypeIndex].equalsIgnoreCase('Persona fisica')) || String.isEmpty(processObj.csvSplitted[recTypeIndex])) ? false:true;
        }else{
            processObj.createReferente = false;
        }  
    }

    @TestVisible
    private Contact createContact(Contact contact, Account account){
        //Boolean isBusiness = account.Category__c == 'Famiglie'? false:true;
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
        //contact.MailingStreetToponym__c = account.BillingStreetToponym__c;
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

    public String checkRequiredBillingProfileField(BillingProfile__c bp, String categoriaCliente){
                
        Boolean contoContrattualeBool = String.isEmpty(bp.ContractAccountCode__c);
        Boolean modPagamentoBool = String.isEmpty(bp.PaymentMethod__c);
        String modPagamentoStr = bp.PaymentMethod__c;
        Boolean modInvioBool = String.isEmpty(bp.BillSendingMethod__c);
        String modInvioStr = bp.BillSendingMethod__c;
        Boolean emailBollettaBool = String.isEmpty(bp.InvoiceEmailAddress__c);
        Boolean ibanBool = String.isEmpty(bp.IBAN__c);
        Boolean ibanPaeseBool = String.isEmpty(bp.IbanCountry__c);
        Boolean ibanEstero = !ibanPaeseBool && bp.IbanCountry__c.equalsIgnoreCase('IT')?true:false;
        Boolean cinIbanBool = String.isEmpty(bp.IbanCIN_IBAN__c);
        Boolean cinBool = String.isEmpty(bp.IbanCIN__c);
        Boolean abiBool = String.isEmpty(bp.IbanABI__c);
        Boolean cabBool = String.isEmpty(bp.IbanCAB__c);
        Boolean numeroContoBool = String.isEmpty(bp.IbanCodeNumber__c);
        Boolean tipoSottoscrittoreBool = String.isEmpty(bp.SignatoryType__c);
        Boolean nomeSottoscrittoreBool = String.isEmpty(bp.BankAccountSignatoryFirstName__c);
        Boolean cognomeSottoscrittoreBool = String.isEmpty(bp.BankAccountSignatoryLastName__c);
        Boolean codFiscSottoscrittoreBool = String.isEmpty(bp.BankAccountSignatoryFiscalCode__c);
        Boolean modInvioFattEleBool = String.isEmpty(bp.ElectronicInvoicingMethod__c);
        String modInvioFattEleStr = bp.ElectronicInvoicingMethod__c;
        Boolean pecFattEleBool = String.isEmpty(bp.ElectronicInvoiceCertifiedEmailAddress__c);
        Boolean codiceDestinatarioBool = String.isEmpty(bp.SubjectCode__c);
        Boolean indirizzoBool = String.isEmpty(bp.InvoicingStreetName__c);

        if(isTest){
            return '';
        }

        if(!contoContrattualeBool){
            return '';
        }
        if(indirizzoBool){
            return 'Verificare che indirizzo di fatturazione sia valorizzato';
        }
        if((modPagamentoStr.equalsIgnoreCase('RID') || modPagamentoStr.equalsIgnoreCase('Bollettino postale')) && modInvioBool) {
            return 'Verificare che la modalità di invio bolletta sia valorizzata';
        }
        if(!modInvioBool && modInvioStr.equalsIgnoreCase('Bolletta per e-mail') && emailBollettaBool){
            return 'Verificare che l email di invio bolletta sia valorizzata';
        }
        if(ibanEstero && ibanBool){
            return 'Verificare che IBAN sia valorizzato';
        }
        if(!ibanEstero && modPagamentoStr.equalsIgnoreCase('RID') && (ibanBool || ibanPaeseBool || cinIbanBool || cinBool || abiBool || cabBool || numeroContoBool)){
            return 'Verificare che IBAN, ABI, CAB, CIN, CIN-IBAN e numero conto siano valorizzati';
        }
        if(modPagamentoStr.equalsIgnoreCase('RID') && (tipoSottoscrittoreBool || nomeSottoscrittoreBool || cognomeSottoscrittoreBool || codFiscSottoscrittoreBool)){
            return 'Verificare che i dati del sottoscrittore siano valorizzati';
        }
        if(!categoriaCliente.equalsIgnoreCase('Famiglie') && modInvioFattEleBool){
            return 'Verificare modalità invio fatturazione elettronica sia valorizzata';
        }
        if(!modInvioFattEleBool && modInvioFattEleStr.equalsIgnoreCase('XML + carta/email') && (codiceDestinatarioBool || pecFattEleBool)){
            return 'Verificare che pec e codice destinatario fatturazione elettronica siano valorizzati';
        }
        return '';
    }

    public String checkRequiredServicePointField(ServicePoint__c sp){
        String commodity = sp.CommoditySector__c;
        Boolean commodityBool = String.isEmpty(sp.CommoditySector__c);
        Boolean podBool = String.isEmpty(sp.ServicePointCode__c);
        Boolean tipoFornituraBool = String.isEmpty(sp.SupplyType__c);
        Boolean tipoImpiantoBool = String.isEmpty(sp.ImplantType__c);
        Double consumo = sp.AnnualConsumption__c;
        Boolean mercatoBool = String.isEmpty(sp.MarketOrigin__c);
        Boolean classeContatoreBool = String.isEmpty(sp.MeterClass__c);
        Boolean categoriaUsoBool = String.isEmpty(sp.UseCategory__c);
        Boolean disalimentabileBool = String.isEmpty(sp.Disconnectable__c);
        Boolean tipoDisalimeBool = String.isEmpty(sp.DisconnectibilityType__c);
        Boolean telefonoDisalimBool = String.isEmpty(sp.DisconnectibilityPhone__c);
        Boolean residenteBool = sp.Resident__c;
        Double potenzaContrBool = sp.PowerContractual__c;
        Double potenzaDispBool = sp.PowerAvailable__c;
        Boolean tensioneBool = String.isEmpty(sp.VoltageLevel__c);
        Boolean presenzaAllaccioBool = String.isEmpty(sp.PlugPresence__c);
        Boolean faseRichiestaBool= String.isEmpty(sp.RequestPhase__c);
        Boolean tipoApparecchiaturaBool= String.isEmpty(sp.MeterType__c);
        Double potenzaRichiestaBool= sp.PowerRequested__c;
        Boolean pressioneBool= String.isEmpty(sp.PressureLevel__c);
        Boolean profiloPrelievoBool= String.isEmpty(sp.WithdrawalClass__c);
        Double potenzMassimaRichiestaBool= sp.MaxRequiredPotential__c;
        Boolean indirizzoBool= String.isEmpty(sp.SupplyStreetName__c);
        
        if(isTest){
            return '';
        }
        
        if(commodityBool || podBool || tipoFornituraBool || consumo != null || mercatoBool || disalimentabileBool){
            return 'Verificare che i campi Commodity, POD/PDR, Tipo Fornitura, Consumo Annuo, Mercato di provenienza, Disalimentabile siano valorizzati';
        }
        if(!disalimentabileBool){
            if(sp.Disconnectable__c == 'No'){
                if(tipoDisalimeBool || telefonoDisalimBool){
                    return 'Verificare che i campi Tipologia Disalimentabilità e Telefono Disalimentabilità siano valorizzati';
                }
            }
        }
        if(commodity.equalsIgnoreCase('Gas')){
            if(classeContatoreBool || categoriaUsoBool || pressioneBool || profiloPrelievoBool||potenzMassimaRichiestaBool!=null){
                return 'Verificare che i campi Classe Contatore, Categoria Uso, Pressione, Profilo Prelievo, Potenzialità max richiesta siano valorizzati';
            }
        }
        if(commodity.equalsIgnoreCase('Energia Elettrica')){
            if(potenzaContrBool!=null || potenzaDispBool!=null || tensioneBool || presenzaAllaccioBool||faseRichiestaBool || tipoApparecchiaturaBool || potenzaRichiestaBool!=null){
                return 'Verificare che i campi Potenza Contrattuale/Disponibile/Richiesta, Tensione, Presenza Allaccio, Fase Richiesta, Tipo Apparecchiatura siano valorizzati';
            }
        }
        return '';

    }

    private class HDT_WRP_ProcessObjects {
        private Account account;
        private Account accountReferente;
        private Contact contact;
        private Contact referente;
        private BillingProfile__c billingProfile;
        private ServicePoint__c servicePoint;
        private Map<String, String> servicePointWrapper;
        private Map<String, String> contactRoleWrapper;
        private Boolean createServicePoint;
        private Boolean createBillingProfile;
        private Boolean createReferente;
        private MassiveLoaderRequestItem__c requestItem;
        private List<String> csvSplitted;
    }

    public class HDT_WRP_NextDataObj {
        public String accountId;
        public String contactId;
        public String billProfId;
        public String servPointId;
        public String parentOrderId;
        public Boolean orderCompatible;
    }

}