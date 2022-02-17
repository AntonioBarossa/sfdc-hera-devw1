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
    private Map<String, List<String>> itemRequestMap = new Map<String, List<String>>();
    private List<MassiveLoaderRequestItem__c> itemsToUpdate;
    private HDT_WRP_sObject obj;
    private Map<Id, HDT_WRP_sObject> itemIdToWrapperMap = new Map<Id, HDT_WRP_sObject>();
    private Map<String, Id> recordTypeMap;
    private Integer contoContrattualeIndex;
    private Integer codicePuntoIndex;
    private Integer recTypeIndex;
    private Boolean enableCreateBillingProfile;
    private Boolean enableCreateServicePoint;

    public override void checks(){
        System.debug(LoggingLevel.DEBUG, 'checks');
        mapFieldsObject();

        contoContrattualeIndex = mapHeaderForWrapper.get('ContoContrattuale');
        codicePuntoIndex = mapHeaderForWrapper.get('CodicePunto');
        recTypeIndex = mapHeaderForWrapper.get('Tipo');

        List<String> dataSplitted;
        for(MassiveLoaderRequestItem__c item : currentProcess.currentRequestItemList){
            dataSplitted = item.Data__c.split(splitCharacter, -1);
            codicePuntoSet.add(dataSplitted[codicePuntoIndex]);
            contoContrattualeSet.add(dataSplitted[contoContrattualeIndex]);
            itemRequestMap.put(item.Id, dataSplitted);
        }
    }

    public override void getRecords(){
        System.debug(LoggingLevel.DEBUG, 'getRecords');

        recordTypeMap = new Map<String, Id>();
        recordTypeMap.put('Business', Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Business').getRecordTypeId());
        recordTypeMap.put('Residenziale', Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Residenziale').getRecordTypeId());

        codicePuntoMap = new Map<String, Id>();

        for(ServicePoint__c sp : [SELECT Id, ServicePointCode__c FROM ServicePoint__c WHERE ServicePointCode__c IN :codicePuntoSet]){
            codicePuntoMap.put(sp.ServicePointCode__c, sp.Id);
        }

    }

    public override void registryCreation(){
        System.debug(LoggingLevel.DEBUG, 'registryCreation');

        HDT_UTL_ProcessCommonOperations.getLimitDetails('START registryCreation');

        List<sObject> accountToInsert = new List<sObject>();
        List<String> itemIds = new List<String>();
        itemsToUpdate = new List<MassiveLoaderRequestItem__c>();

        for(String itemId : itemRequestMap.keySet()){

            List<String> tempSplitted = itemRequestMap.get(itemId);
            
            obj = new HDT_WRP_sObject();
            obj.account = new Account();
            obj.contact = new Contact();
            obj.billingProfile = new BillingProfile__c();
            obj.servicePoint = new ServicePoint__c();
            
            Integer count = 0;
            String convertionError;
            String csvHeader;
            String objField;

            System.debug(LoggingLevel.DEBUG, '>>> tempSplitted ' + tempSplitted.size());

            enableCreateBillingProfile = String.isEmpty(tempSplitted[contoContrattualeIndex]);
            enableCreateServicePoint = !codicePuntoMap.containsKey(tempSplitted[codicePuntoIndex]);

            System.debug(LoggingLevel.DEBUG, '>>> enableCreate: billProf [' + enableCreateBillingProfile + ']; servPoint [' + enableCreateServicePoint + ']');

            for (String tempField : tempSplitted) {

                if ('null'.equalsIgnoreCase(tempField)) {
                   tempField = '';
                }
                
                csvHeader = mapHeaderByPosition.get(count);
                objField = mapAllFields.get(csvHeader);

                if (mapRequiredByPosition.get(count) != null && String.isBlank(tempField)) {
                    convertionError = 'Missing Required Field: ' + mapHeaderByPosition.get(count);
                    System.debug(LoggingLevel.DEBUG, '>>> required field error: ' + convertionError);
                    if(String.isNotEmpty(convertionError)){
                        // error happened -> exit
                        break;
                    }
                }
            
                if(String.isNotBlank(objField) && String.isNotBlank(tempField)){
                    System.debug(LoggingLevel.DEBUG, '>>> CSV Header: ' + csvHeader + '; sObj Field: ' + objField + '; value: ' + tempField);
                    
                    if(sobjectMap.containsKey(csvHeader)){

                        switch on sobjectMap.get(csvHeader).objectType__c {
                            when 'Account' {
                                convertionError = mapTypeField(obj.account, mapAllFields, count, tempField);
                            }
                            when 'BillingProfile__c' {
                                if(enableCreateBillingProfile){
                                    convertionError = mapTypeField(obj.billingProfile, mapAllFields, count, tempField);
                                }
                            }
                            when 'ServicePoint__c' {
                                if(enableCreateServicePoint){
                                    convertionError = mapTypeField(obj.servicePoint, mapAllFields, count, tempField);
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

            if(String.isNotEmpty(convertionError)){
                itemsToUpdate.add(setErrorItem(itemId, convertionError));
                continue;
            }

            System.debug(LoggingLevel.DEBUG, '>>> currentAccount: ' + obj.account);
            System.debug(LoggingLevel.DEBUG, '>>> currentBillingProfile: ' + obj.billingProfile);
            System.debug(LoggingLevel.DEBUG, '>>> currentServicePoint: ' + obj.servicePoint);

            obj.account.RecordTypeId = recordTypeMap.get(tempSplitted[recTypeIndex]);
            
            // only for test
            obj.account.Name = String.isBlank(obj.account.FirstName__c) ? obj.account.LastName__c : obj.account.FirstName__c + ' ' + obj.account.LastName__c;
            obj.account.IsWrongFiscalData__c = false;
            obj.account.BillingCityCode__c = 'Roma';

            addInformationToSet(obj.account);

            itemIdToWrapperMap.put(itemId, obj);

        }

        accountList = HDT_QR_ProcessSales.getAccountList(fiscalCodeSet, vatNumberSet, marcaturaSet, csnSet);

        List<Contact> saveContactList = new List<Contact>();
        List<BillingProfile__c> saveBillProfList = new List<BillingProfile__c>();
        List<ServicePoint__c> saveServPointList = new List<ServicePoint__c>();

        if(itemIdToWrapperMap.size() > 0){

            HDT_WRP_sObject itObj;
            for(Id itemId : itemIdToWrapperMap.keySet()){
                itObj = itemIdToWrapperMap.get(itemId);

                itObj.account.Id = setAccountIdFromDb(itObj.account);

                if(itObj.account.Id == null){
                    itObj.contact = createContact(itObj.contact, itObj.account);
                    saveContactList.add(itObj.contact);
                    itemIds.add(itemId);
                    accountToInsert.add(itObj.account);
                }

            }

            HDT_UTL_ProcessCommonOperations.HDT_WRP_SaveResponse saveAccountResponse;
            saveAccountResponse = HDT_UTL_ProcessCommonOperations.databaseInsert(accountToInsert, itemIds, 'Account');

            //itemsToUpdate.addAll(saveAccountResponse.reponseItemList);

            System.debug(LoggingLevel.DEBUG, '>>> savedObject ' + saveAccountResponse.savedObject);
            System.debug(LoggingLevel.DEBUG, '>>> itemIdToObjId: ' + saveAccountResponse.itemIdToObjId);

            itemIds.clear();
            itemIds = new List<String>();

            HDT_WRP_sObject iterationObj;
            Id accountId;
            List<Id> accountIdsList = new List<Id>();
            for(Id itemId : itemIdToWrapperMap.keySet()){
                iterationObj = itemIdToWrapperMap.get(itemId);

                if(iterationObj.account.Id == null){
                    if(saveAccountResponse.itemIdToObjId.containsKey(itemId)){
                        accountId = saveAccountResponse.itemIdToObjId.get(itemId);
                    }   
                } else {
                    accountId = iterationObj.account.Id;
                }
                
                if(accountId != null){
                    iterationObj.contact.AccountId = accountId;
                    iterationObj.billingProfile.Account__c = accountId;
                    iterationObj.servicePoint.Account__c = accountId;
    
                    System.debug(LoggingLevel.DEBUG, '>>> currentBillingProfile: ' + iterationObj.billingProfile);
                    System.debug(LoggingLevel.DEBUG, '>>> currentServicePoint: ' + iterationObj.servicePoint);
                    System.debug(LoggingLevel.DEBUG, '>>> currentContact: ' + iterationObj.contact);
                    
                    saveBillProfList.add(iterationObj.billingProfile);
                    saveServPointList.add(iterationObj.servicePoint);
                    itemIds.add(itemId);
                    accountIdsList.add(accountId);
                }

            }

            HDT_UTL_ProcessCommonOperations.HDT_WRP_SaveResponse saveContactResponse;
            HDT_UTL_ProcessCommonOperations.HDT_WRP_SaveResponse saveBillProfResponse;
            HDT_UTL_ProcessCommonOperations.HDT_WRP_SaveResponse saveServPointResponse;

            if(saveContactList.size() > 0){
                saveContactResponse = HDT_UTL_ProcessCommonOperations.databaseInsert(saveContactList, itemIds, 'Contact');
            }
            
            if(saveBillProfList.size() > 0){
                saveBillProfResponse = HDT_UTL_ProcessCommonOperations.databaseInsert(saveBillProfList, itemIds, 'BillingProfile__c');
            }
            
            if(saveServPointList.size() > 0){
                saveServPointResponse = HDT_UTL_ProcessCommonOperations.databaseInsert(saveServPointList, itemIds, 'ServicePoint__c');
            }
            
            List<AccountContactRelation> acrList;

            if(accountIdsList.size() > 0){
                acrList = HDT_QR_ProcessSales.getAccountContactRelationByAccountId(acrList, accountIdsList);
            }

            if(acrList.size() > 0){
                for(AccountContactRelation acr : acrList){
                    acr.Roles = 'Titolare';
                }
    
                update acrList;
            }

            System.debug('> > > ' + saveBillProfResponse.itemIdToObjId);
            System.debug('> > > ' + saveServPointResponse.itemIdToObjId);

            HDT_UTL_ProcessCommonOperations.getLimitDetails('AFTER OBJs CREATION');

            HDT_WRP_NextDataObj nextDataObj;
            MassiveLoaderRequestItem__c item;
            for(Id itemId : itemIdToWrapperMap.keySet()){

                item = new MassiveLoaderRequestItem__c();
                item.Id = itemId;

                nextDataObj = new HDT_WRP_NextDataObj();
                if(saveAccountResponse.itemIdToObjId.containsKey(item.Id)){
                    nextDataObj.accountId = saveAccountResponse.itemIdToObjId.get(item.Id);
                }

                if(saveBillProfResponse.itemIdToObjId.containsKey(item.Id)){
                    nextDataObj.billProfId = saveBillProfResponse.itemIdToObjId.get(item.Id);
                }

                if(saveServPointResponse.itemIdToObjId.containsKey(item.Id)){
                    nextDataObj.servPointId = saveServPointResponse.itemIdToObjId.get(item.Id);
                }
                item.NextStepData__c = JSON.serialize(nextDataObj);
                item.Status__c = 'In Lavorazione';
                itemsToUpdate.add(item);
            }

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

    private class HDT_WRP_sObject {
        private Account account;
        private Contact contact;
        private BillingProfile__c billingProfile;
        private ServicePoint__c servicePoint;
    }

    public class HDT_WRP_NextDataObj {
        public String accountId;
        public String billProfId;
        public String servPointId;
    }

    public static void setDataForTest(Integer numRecords){

        Id massiveLoaderRequestId = 'a3d3O000000WyvQQAS';
        Set<Id> docId = new Set<Id>();

        delete [SELECT Id FROM MassiveLoaderRequestItem__c WHERE MassiveLoaderRequest__c = :massiveLoaderRequestId];
        delete [
            SELECT Id
            FROM Account
            WHERE CreatedById = '0051X0000055rbNQAQ'
        ];
        
        delete [
            SELECT Id
            FROM Contact
            WHERE CreatedById = '0051X0000055rbNQAQ'
        ];

        delete [
            SELECT Id
            FROM BillingProfile__c
            WHERE CreatedById = '0051X0000055rbNQAQ'
        ];

        delete [
            SELECT Id
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
            tempList.add(''); // FAX
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