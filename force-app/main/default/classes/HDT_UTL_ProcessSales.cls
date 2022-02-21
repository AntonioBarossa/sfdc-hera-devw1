@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_ProcessSales extends HDT_UTL_ProcessExecution {

    private Map<String, HDT_MassiveFieldsObjectMap__mdt> sobjectMap;
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

    public override void checks(){
        System.debug(LoggingLevel.DEBUG, 'checks');
        mapFieldsObject();

        contoContrattualeIndex = mapHeaderForWrapper.get('ContoContrattuale');
        codicePuntoIndex = mapHeaderForWrapper.get('CodicePunto');
        recTypeIndex = mapHeaderForWrapper.get('Tipo');

        HDT_WRP_ProcessObjects processObj;
        processObjList = new List<HDT_WRP_ProcessObjects>();
        itemsToUpdate = new List<MassiveLoaderRequestItem__c>();
        List<String> tempSplitedFields;
        for(MassiveLoaderRequestItem__c item : currentProcess.currentRequestItemList){

            tempSplitedFields = new List<String>();
            tempSplitedFields = item.Data__c.split(splitCharacter, -1);

            Integer count = 0;
            for(String field : tempSplitedFields){

                if(mapRequiredByPosition.containsKey(count) && mapRequiredByPosition.get(count) != null && String.isBlank(tempSplitedFields[count])) {
                    System.debug(LoggingLevel.DEBUG, '>>> Missing Required Field');
                    item.Status__c = 'Errore';
                    item.StatusDescription__c = 'Missing Required Field: ' + mapHeaderByPosition.get(count);
                    break;
                }
                count++;
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
            contoContrattualeSet.add(processObj.csvSplitted[contoContrattualeIndex]);

            processObjList.add(processObj);
        }
    }

    public override void getRecords(){
        System.debug(LoggingLevel.DEBUG, 'getRecords');

        recordTypeMap = new Map<String, Id>();
        codicePuntoMap = new Map<String, Id>();

        recordTypeMap.put('Business', Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Business').getRecordTypeId());
        recordTypeMap.put('Residenziale', Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Residenziale').getRecordTypeId());

        for(ServicePoint__c sp : [SELECT Id, ServicePointCode__c FROM ServicePoint__c WHERE ServicePointCode__c IN :codicePuntoSet]){
            codicePuntoMap.put(sp.ServicePointCode__c, sp.Id);
        }

    }

    public override void registryCreation(){

        HDT_UTL_ProcessCommonOperations.getLimitDetails('START registryCreation');

        if(processObjList.size() == 0){
            return;
        }

        Boolean enableCreateBillingProfile;
        Boolean enableCreateServicePoint;
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

        for(HDT_WRP_ProcessObjects processObj : processObjList){
 
            processObj.account = new Account();
            processObj.billingProfile = new BillingProfile__c();
            processObj.servicePoint = new ServicePoint__c();
            
            Integer count = 0;
            String convertionError;
            String csvHeader;
            String objField;

            System.debug(LoggingLevel.DEBUG, '>>> tempSplitted ' + processObj.csvSplitted.size());

            enableCreateBillingProfile = String.isEmpty(processObj.csvSplitted[contoContrattualeIndex]);
            enableCreateServicePoint = !codicePuntoMap.containsKey(processObj.csvSplitted[codicePuntoIndex]);

            System.debug(LoggingLevel.DEBUG, '>>> enableCreate: billProf [' + enableCreateBillingProfile + ']; servPoint [' + enableCreateServicePoint + ']');

            processObj.account.RecordTypeId = recordTypeMap.get(processObj.csvSplitted[recTypeIndex]);
            
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
                                if(enableCreateBillingProfile){
                                    convertionError = mapTypeField(processObj.billingProfile, mapAllFields, count, tempField);
                                }
                            }
                            when 'ServicePoint__c' {
                                if(enableCreateServicePoint){
                                    convertionError = mapTypeField(processObj.servicePoint, mapAllFields, count, tempField);
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

            processObj.csvSplitted.clear();

            if(String.isNotEmpty(convertionError)){
                processObj.requestItem.Status__c = 'Errore';
                processObj.requestItem.StatusDescription__c = convertionError;
                continue;
            }

            processObj.account.Name = String.isBlank(processObj.account.FirstName__c) ? processObj.account.LastName__c : processObj.account.FirstName__c + ' ' + processObj.account.LastName__c;

            // only for test
            processObj.account.IsWrongFiscalData__c = false;
            processObj.account.BillingCityCode__c = 'Roma';

            System.debug(LoggingLevel.DEBUG, '>>> currentAccount: ' + processObj.account);
            System.debug(LoggingLevel.DEBUG, '>>> currentBillingProfile: ' + processObj.billingProfile);
            System.debug(LoggingLevel.DEBUG, '>>> currentServicePoint: ' + processObj.servicePoint);

            addInformationToSet(processObj.account);

        }

        accountList = HDT_QR_ProcessSales.getAccountList(fiscalCodeSet, vatNumberSet, marcaturaSet, csnSet);

        clearAllUselessSets();

        for(HDT_WRP_ProcessObjects processObj : processObjList){

            if(processObj.requestItem.Status__c.equalsIgnoreCase('Errore')){
                System.debug(LoggingLevel.DEBUG, '>>> requestItem.Status__c ');
                continue;
            }

            processObj.account.Id = setAccountIdFromDb(processObj.account);

            if(processObj.account.Id == null){
                requestItemForUpsert.add(processObj.requestItem);
                accountToInsert.add(processObj.account);
            }

        }

        HDT_UTL_ProcessCommonOperations.HDT_WRP_SaveResponse saveAccountResponse;
        saveAccountResponse = HDT_UTL_ProcessCommonOperations.databaseUpsert(accountToInsert, requestItemForUpsert, 'Account');

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

        HDT_UTL_ProcessCommonOperations.HDT_WRP_SaveResponse saveContactResponse;
        if(saveContactList.size() > 0){
            System.debug(LoggingLevel.DEBUG, '>>> save contact');
            saveContactResponse = HDT_UTL_ProcessCommonOperations.databaseUpsert(saveContactList, requestItemForUpsert, 'Contact');
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
                processObj.billingProfile.Account__c = accountId;
                processObj.servicePoint.Account__c = accountId;

                System.debug(LoggingLevel.DEBUG, '>>> currentBillingProfile: ' + processObj.billingProfile);
                System.debug(LoggingLevel.DEBUG, '>>> currentServicePoint: ' + processObj.servicePoint);
                
                saveBillProfList.add(processObj.billingProfile);
                saveServPointList.add(processObj.servicePoint);
                requestItemForUpsert.add(processObj.requestItem);
                accountIdsList.add(accountId);
            }

        }

        System.debug(LoggingLevel.DEBUG, '>>> save billProf and servPoint');

        HDT_UTL_ProcessCommonOperations.HDT_WRP_SaveResponse saveBillProfResponse;
        HDT_UTL_ProcessCommonOperations.HDT_WRP_SaveResponse saveServPointResponse;
        
        System.debug(LoggingLevel.DEBUG, '>>> saveBillProfList ' + saveBillProfList.size());
        System.debug(LoggingLevel.DEBUG, '>>> saveServPointList ' + saveServPointList.size());

        if(saveBillProfList.size() > 0){
            System.debug(LoggingLevel.DEBUG, '>>> save BillingProfile__c');
            saveBillProfResponse = HDT_UTL_ProcessCommonOperations.databaseUpsert(saveBillProfList, requestItemForUpsert, 'BillingProfile__c');
            System.debug(LoggingLevel.DEBUG, '>>> saveBillProfResponse: ' + saveBillProfResponse.itemIdToObjId);
        }
        
        if(saveServPointList.size() > 0){
            System.debug(LoggingLevel.DEBUG, '>>> save ServicePoint__c');
            saveServPointResponse = HDT_UTL_ProcessCommonOperations.databaseUpsert(saveServPointList, requestItemForUpsert, 'ServicePoint__c');
            System.debug(LoggingLevel.DEBUG, '>>> saveServPointResponse: ' + saveServPointResponse.itemIdToObjId);
        }
        
        System.debug(LoggingLevel.DEBUG, '>>> accountIdsList: ' + accountIdsList.size());

        if(accountIdsList.size() > 0){
            System.debug(LoggingLevel.DEBUG, '>>> get AccountContactRelation');
            acrList = HDT_QR_ProcessSales.getAccountContactRelationByAccountId(acrList, accountIdsList);
        }

        if(acrList != null && acrList.size() > 0){
            for(AccountContactRelation acr : acrList){
                acr.Roles = 'Titolare';
            }

            update acrList;
        }

        HDT_UTL_ProcessCommonOperations.getLimitDetails('AFTER OBJs CREATION');

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
            if(saveAccountResponse.itemIdToObjId.containsKey(processObj.requestItem.Id)){
                nextDataObj.accountId = saveAccountResponse.itemIdToObjId.get(processObj.requestItem.Id);
            }

            if(saveBillProfResponse.itemIdToObjId.containsKey(processObj.requestItem.Id)){
                nextDataObj.billProfId = saveBillProfResponse.itemIdToObjId.get(processObj.requestItem.Id);
            }

            if(saveServPointResponse.itemIdToObjId.containsKey(processObj.requestItem.Id)){
                nextDataObj.servPointId = saveServPointResponse.itemIdToObjId.get(processObj.requestItem.Id);
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
        List<HDT_MassiveFieldsObjectMap__mdt> allFieldForThisProcess;

        mapAllFields = new Map<String, String>();
        mapWrapperAccountFields = new Map<String, String>();

        sobjectMap = new Map<String, HDT_MassiveFieldsObjectMap__mdt>();
        allFieldForThisProcess = HDT_QR_ProcessPostSales.getMapFieldsObjectByDeveloperName('Sales%');

        for(HDT_MassiveFieldsObjectMap__mdt temp : allFieldForThisProcess){

            if(temp.objectType__c.equalsIgnoreCase('WrapperAccount')){
                mapWrapperAccountFields.put(temp.labelField__c, temp.nameField__c);
            } else {
                mapAllFields.put(temp.MasterLabel, temp.nameField__c);
            }
            sobjectMap.put(temp.MasterLabel, temp);
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
        private MassiveLoaderRequestItem__c requestItem;
        private List<String> csvSplitted;
    }

    public class HDT_WRP_NextDataObj {
        public String accountId;
        public String billProfId;
        public String servPointId;
    }

    public static void setDataForTest(Integer numRecords){

        Id massiveLoaderRequestId = 'a3d3O000000WyvQQAS';
        Set<Id> docId = new Set<Id>();

        delete [
            SELECT Id, Data__c, NextStepData__c, Status__c, StatusDescription__c, MassiveLoaderRequest__c
            FROM MassiveLoaderRequestItem__c
            WHERE MassiveLoaderRequest__c = :massiveLoaderRequestId
        ];

        delete [
            SELECT Id, Name, RecordTypeId, RecordType.Name, CustomerCode__c, FiscalCode__c, VATNumber__c, CustomerMarking__c 
            FROM Account
            WHERE CreatedById = '0051X0000055rbNQAQ'
        ];
        
        delete [
            SELECT Id, FirstName, Account.CustomerCode__c
            FROM Contact
            WHERE CreatedById = '0051X0000055rbNQAQ'
        ];

        delete [
            SELECT Id, Account__r.CustomerCode__c
            FROM BillingProfile__c
            WHERE CreatedById = '0051X0000055rbNQAQ'
        ];

        delete [
            SELECT Id, Name, Account__r.CustomerCode__c, ServicePointCode__c
            FROM ServicePoint__c
            WHERE CreatedById = '0051X0000055rbNQAQ'
        ];

        List<ContentDocumentLink> cdlList = [
            SELECT Id, LinkedEntityId, ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :massiveLoaderRequestId
        ];

        if(cdlList.size() > 0){
            for(ContentDocumentLink c : cdlList){
                docId.add(c.ContentDocumentId);
            }

            delete cdlList;
            delete [SELECT Id FROM ContentDocument WHERE Id IN :docId];
        }

        List<MassiveLoaderRequestItem__c> itemsList = new List<MassiveLoaderRequestItem__c>();
        MassiveLoaderRequestItem__c item;
    
        List<String> tempList;
        String iteration = '';
        for(Integer n=0; n<numRecords; n++){
            item = new MassiveLoaderRequestItem__c();
            item.MassiveLoaderRequest__c = massiveLoaderRequestId;
            tempList = new List<String>();
            item.Status__c = 'In attesa di lavorazione';

            iteration = String.valueOf(n);

            // -- Account / Contact
            tempList.add('Residenziale'); // Tipo
            tempList.add('true'); // FlagVerificato
            tempList.add(''); // FAX - 854455666
            tempList.add(''); // Stato
            tempList.add(''); // BP
            tempList.add('Roma'); // Comune
            tempList.add('Adam'); // Nome
            tempList.add(''); // Professione
            tempList.add('AAA-EBT'); // Silos
            tempList.add('Roma'); // Localita
            tempList.add(''); // ComuneNascita
            tempList.add('55'); // Civico
            tempList.add('Daniel'); // Cognome
            tempList.add(''); // CodiceVia
            tempList.add(''); // Provincia
            tempList.add('25'); // CodiceLocalita
            tempList.add(''); // IndirizzoEstero
            tempList.add('00166'); // CAP
            tempList.add('Piccoli condomini'); // Categoria
            tempList.add(''); // DataNascita
            tempList.add('AAS Parti comuni'); // Marcatura
            tempList.add(''); // TitoloStudio
            tempList.add('via roma'); // NomeVia
            tempList.add(''); // Email
            tempList.add(''); // PrefTelefono
            tempList.add(''); // EstensCivico
            tempList.add(''); // AltroTelefono
            tempList.add('1234567' + iteration); // PI - 12345678
            tempList.add(''); // Cellulare
            tempList.add('SXSRLA45H28H' + iteration); // CF - SXSRLA45H28H5
            tempList.add(''); // Sesso
            tempList.add(''); // PrefCell
            //tempList.add('');
            tempList.add('100361621' + iteration); // CSN - 1003616210
            tempList.add('00166'); // CodiceCitta

            // -- Billing Profile
            tempList.add('sono un numero'); // NumeroConto
            tempList.add(''); // IBAN
            tempList.add(''); // ABI
            tempList.add(''); // EmailInvioBolletta
            tempList.add(''); // BPComune
            tempList.add(''); // BPVia
            tempList.add(''); // CFsottoscrittoreCC
            tempList.add(''); // CognomeSottoscrittoreCC
            tempList.add(''); // CINIBAN
            tempList.add(''); // TiploXML
            tempList.add(''); // BPCivico
            tempList.add(''); // CodiceDestinatario
            tempList.add(''); // ModalitaInvioFattElettr
            tempList.add(''); // ModalitaPagamento
            tempList.add(''); // IBANEstero
            tempList.add(''); // TipoSottoscrittore
            tempList.add(''); // ModalitaInvioBolletta
            tempList.add(''); // CAB
            tempList.add(''); // CIN
            tempList.add(''); // Paese
            tempList.add(''); // PecFattElettronica
            tempList.add(''); // DestinatarioDivergente
            tempList.add(''); // NomeSottoscrittoreCC
            tempList.add(''); // ContoContrattuale

            // -- Service Point
            tempList.add(''); // SPVia
            tempList.add('25'); // ConsumoAnnuo
            tempList.add(''); // SPCodice
            tempList.add(''); // PotenzialitaMassimaRichiesta
            tempList.add(''); // CategoriaUso
            tempList.add(''); // SP_IndirizzoEstero
            tempList.add(''); // ClassePrelievo
            tempList.add(''); // Distributore
            tempList.add(''); // Servizio
            tempList.add(''); // ClasseContatore
            tempList.add(''); // PotenzaContrattuale
            tempList.add(''); // LivelloPressione
            tempList.add(''); // PresenzaAllaccio
            tempList.add(''); // PotenzaDisponibile
            tempList.add(''); // TipologiaDisalimentabilita
            tempList.add(''); // MatricolaContatore
            tempList.add(''); // CodiceRemi
            tempList.add(''); // TelefonoNonDisalimentabili
            tempList.add(''); // SPComune
            tempList.add(''); // PotenzaRichiesta
            tempList.add(''); // MercatoProvenienza
            tempList.add(''); // TensioneConsegna
            tempList.add(''); // TipologiaImpianto
            tempList.add(''); // Disalimentabile
            tempList.add(''); // TipoFornitura
            tempList.add(''); // FaseRichiesta
            tempList.add(''); // Residente
            tempList.add(''); // SP_Civico
            tempList.add(''); // TipoApparecchiatura
            tempList.add('IT001E04893470'); // CodicePunto
            tempList.add('');// CodiceImpianto
            item.Data__c = String.join(tempList, '|');
            itemsList.add(item);
        }
        insert itemsList;
    
        MassiveLoaderRequest__c mlr = new MassiveLoaderRequest__c();
        mlr.Id = massiveLoaderRequestId;
        mlr.Status__c = 'In attesa di lavorazione';
        update mlr;
    
    }

}