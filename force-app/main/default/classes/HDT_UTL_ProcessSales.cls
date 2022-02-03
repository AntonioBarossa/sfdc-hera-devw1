@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_ProcessSales extends HDT_UTL_ProcessExecution {

    private Map<String, HDT_MassiveFieldsObjectMap__mdt> sobjectMap;
    private Map<String, String> mapAllFields;
    private Map<String, String> mapWrapperAccountFields;

    //private Set<String> csnSet = new Set<String>();
    //private Set<String> fiscalCodeSet = new Set<String>();
    //private Set<String> vatNumberSet = new Set<String>();
    //private Set<String> marcaturaSet = new Set<String>();
    //private Set<String> contoContrattualeSet = new Set<String>();

    private Map<String, List<String>> itemRequestMap = new Map<String, List<String>>();
    private List<MassiveLoaderRequestItem__c> itemsToSave;
    //private Account account;
    private HDT_WRP_sObject obj;
    //private BillingProfile__c billingProfile;
    //private ServicePoint__c servicePoint;
    //private Map<String, AccountContactRelation> accountContactMap;
    private Map<Id, HDT_WRP_sObject> itemIdToWrapperMap = new Map<Id, HDT_WRP_sObject>();
    //private List<AccountContactRelation> accContRelationList;
    //private List<BillingProfile__c> billingProfileList;
    private Map<String, Id> recordTypeMap;
    private Integer csnIndex;
    //private Integer fiscalCodeIndex;
    //private Integer vatNumberIndex;
    //private Integer marcaturaIndex;
    private Integer contoContrattualeIndex;
    private Integer codicePuntoIndex;
    private Integer recTypeIndex;

    private Boolean enableCreateAccount;
    private Boolean enableCreateBillingProfile;
    private Boolean enableCreateServicePoint;

    public override void checks(){
        System.debug(LoggingLevel.DEBUG, 'checks');
        mapFieldsObject();

        System.debug(LoggingLevel.DEBUG, '>>> mapAllFields: ' + String.valueOf(mapAllFields));
        System.debug(LoggingLevel.DEBUG, '>>> mapWrapperAccountFields: ' + String.valueOf(mapWrapperAccountFields));
        System.debug(LoggingLevel.DEBUG, '>>> mapHeaderForWrapper: ' + String.valueOf(mapHeaderForWrapper));
        System.debug(LoggingLevel.DEBUG, '>>> mapHeaderByPosition: ' + String.valueOf(mapHeaderByPosition));
        System.debug(LoggingLevel.DEBUG, '>>> sobjectMap: ' + String.valueOf(sobjectMap));

        csnIndex = mapHeaderForWrapper.get('CSN');
        //fiscalCodeIndex = mapHeaderForWrapper.get('CF');
        //vatNumberIndex = mapHeaderForWrapper.get('PI');
        //marcaturaIndex = mapHeaderForWrapper.get('Marcatura');
        contoContrattualeIndex = mapHeaderForWrapper.get('ContoContrattuale');
        codicePuntoIndex = mapHeaderForWrapper.get('CodicePunto');
        recTypeIndex = mapHeaderForWrapper.get('Tipo');//(temp.labelField__c, temp.nameField__c);

        System.debug(LoggingLevel.DEBUG, '>>> csnIndex: ' + csnIndex);
        //System.debug(LoggingLevel.DEBUG, '>>> fiscalCodeIndex: ' + fiscalCodeIndex);
        //System.debug(LoggingLevel.DEBUG, '>>> vatNumberIndex: ' + vatNumberIndex);
        //System.debug(LoggingLevel.DEBUG, '>>> marcaturaIndex: ' + marcaturaIndex);
        System.debug(LoggingLevel.DEBUG, '>>> contoContrattualeIndex: ' + contoContrattualeIndex);
        System.debug(LoggingLevel.DEBUG, '>>> codicePuntoIndex: ' + codicePuntoIndex);
        System.debug(LoggingLevel.DEBUG, '>>> recTypeIndex: ' + recTypeIndex);

        List<String> dataSplitted;
        for(MassiveLoaderRequestItem__c item : currentProcess.currentRequestItemList){
            dataSplitted = item.Data__c.split(splitCharacter, -1);
            //csnSet.add(dataSplitted[csnIndex]);
            //fiscalCodeSet.add(dataSplitted[fiscalCodeIndex]);
            //vatNumberSet.add(dataSplitted[vatNumberIndex]);
            //marcaturaSet.add(dataSplitted[marcaturaIndex]);
            //contoContrattualeSet.add(dataSplitted[contoContrattualeIndex]);
            itemRequestMap.put(item.Id, dataSplitted);
        }
    }

    public override void getRecords(){
        System.debug(LoggingLevel.DEBUG, 'getRecords');

        recordTypeMap = new Map<String, Id>();
        recordTypeMap.put('Business', Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Business').getRecordTypeId());
        recordTypeMap.put('Residenziale', Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Residenziale').getRecordTypeId());


    }

    public override void registryCreation(){
        System.debug(LoggingLevel.DEBUG, 'registryCreation');

        HDT_UTL_ProcessCommonOperations.getLimitDetails('START registryCreation');

        List<sObject> AccountToInsert = new List<sObject>();
        List<String> itemIds = new List<String>();
        itemsToSave = new List<MassiveLoaderRequestItem__c>();

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

            enableCreateAccount = (String.isEmpty(tempSplitted[csnIndex])) ? true : false;
            enableCreateBillingProfile = (String.isEmpty(tempSplitted[contoContrattualeIndex])) ? true : false;
            enableCreateServicePoint = (String.isEmpty(tempSplitted[codicePuntoIndex])) ? true : false;

            for (String tempField : tempSplitted) {

                if ('null'.equalsIgnoreCase(tempField)) {
                   tempField = '';
                }
                
                csvHeader = mapHeaderByPosition.get(count);
                objField = mapAllFields.get(csvHeader);

                if (mapRequiredByPosition.get(count) != null && String.isBlank(tempField)) {
                    convertionError = 'Missing Required Field: ' + mapHeaderByPosition.get(count);
                    System.debug(LoggingLevel.DEBUG, '>>> required field error: ' + convertionError);
                    if(!String.isEmpty(convertionError)){
                        // error happened -> exit
                        break;
                    }
                }
            
                if(String.isNotBlank(objField) && String.isNotBlank(tempField)){
                    System.debug(LoggingLevel.DEBUG, '>>> CSV Header: ' + csvHeader + '; Case Field: ' + objField + '; value: ' + tempField);
                    
                    if(sobjectMap.containsKey(csvHeader)){

                        switch on sobjectMap.get(csvHeader).objectType__c {
                            when 'Account' {
                                if(enableCreateAccount){
                                    convertionError = mapTypeField(obj.account, mapAllFields, count, tempField);
                                }
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
                    
                    if(!String.isEmpty(convertionError)){
                        // error happened -> exit
                        System.debug(LoggingLevel.DEBUG, '>>> break for loop...' + csvHeader + ' - ' + objField + ' - ' + tempField);
                        break;
                    }
                }

                count++;
            }

            if(!String.isEmpty(convertionError)){
                itemsToSave.add(setErrorItem(itemId, convertionError));
                continue;
            }

            System.debug(LoggingLevel.DEBUG, '>>> currentAccount: ' + obj.account);
            System.debug(LoggingLevel.DEBUG, '>>> currentBillingProfile: ' + obj.billingProfile);
            System.debug(LoggingLevel.DEBUG, '>>> currentServicePoint: ' + obj.servicePoint);

            obj.account.RecordTypeId = recordTypeMap.get(tempSplitted[recTypeIndex]);
            obj.account.IsWrongFiscalData__c = false;
            obj.account.BillingCityCode__c = 'Roma';

            if(enableCreateAccount){
                createContact();
            } else {
                obj.account.Id = '0013O00000rTvDeQAK';
            }

            itemIdToWrapperMap.put(itemId, obj);

        }

        if(itemIdToWrapperMap.size() > 0){

            HDT_WRP_sObject itObj;
            for(Id itemId : itemIdToWrapperMap.keySet()){
                itObj = itemIdToWrapperMap.get(itemId);
                if(itObj.account.Id == null){
                    itemIds.add(itemId);
                    accountToInsert.add(itObj.account);
                }
            }

            HDT_UTL_ProcessCommonOperations.HDT_WRP_SaveResponse saveAccountResponse;
            saveAccountResponse = HDT_UTL_ProcessCommonOperations.databaseInsert(accountToInsert, itemIds, 'Account');

            System.debug(LoggingLevel.DEBUG, '>>> savedObject ' + saveAccountResponse.savedObject);
            System.debug(LoggingLevel.DEBUG, '>>> itemIdToAccountId: ' + saveAccountResponse.itemIdToAccountId);
            
            for(sObject obj : saveAccountResponse.savedObject){
                if(obj.getSObjectType() == Schema.Account.getSObjectType()){
                    accountIdList.add((Id)obj.get('Id'));
                }
            }

            itemIds.clear();
            itemIds = new List<String>();

            List<Contact> saveContactList = new List<Contact>();
            List<BillingProfile__c> saveBillProfList = new List<BillingProfile__c>();
            List<ServicePoint__c> saveServPointList = new List<ServicePoint__c>();

            HDT_WRP_sObject iterationObj;
            Id accountId;
            List<Id> accountIdsList = new List<Id>();
            for(Id itemId : itemIdToWrapperMap.keySet()){
                iterationObj = itemIdToWrapperMap.get(itemId);

                if(itObj.account.Id == null){
                    if(saveAccountResponse.itemIdToAccountId.containsKey(itemId)){
                        accountId = saveAccountResponse.itemIdToAccountId.get(itemId);
                    }   
                } else {
                    accountId = itObj.account.Id;
                }
                
                if(accountId != null){
                    iterationObj.contact.AccountId = accountId;
                    iterationObj.billingProfile.Account__c = accountId;
                    iterationObj.servicePoint.Account__c = accountId;
    
                    System.debug(LoggingLevel.DEBUG, '>>> currentBillingProfile: ' + iterationObj.billingProfile);
                    System.debug(LoggingLevel.DEBUG, '>>> currentServicePoint: ' + iterationObj.servicePoint);
                    System.debug(LoggingLevel.DEBUG, '>>> currentContact: ' + iterationObj.contact);
    
                    if(enableCreateAccount){
                        saveContactList.add(iterationObj.contact);
                    }
                    
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

            HDT_UTL_ProcessCommonOperations.getLimitDetails('AFTER OBJs CREATION');

            if(saveAccountResponse.reponseItemList.size() > 0){
                itemsToSave.addAll(saveAccountResponse.reponseItemList);
            }

        }  

    }

    public override void finalUpdate(){
        System.debug(LoggingLevel.DEBUG, 'finalUpdate');
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

    private void createContact(){
        obj.contact.DegreeOfStudies__c = obj.account.DegreeOfStudies__c;
        obj.contact.CompanyOwner__c = obj.account.CompanyOwner__c;
        obj.contact.LastName = obj.account.LastName__c;
        obj.contact.Gender__c = obj.account.Gender__c;
        obj.contact.FirstName = obj.account.FirstName__c;
        obj.contact.Birthdate = obj.account.BirthDate__c;
        obj.contact.FiscalCode__c = obj.account.FiscalCode__c;
        obj.contact.Birthcity__c = obj.account.BirthProvince__c;
        obj.contact.MobilePhonePrefix__c = obj.account.MobilePhonePrefix__c;
        obj.contact.Phone = obj.account.Phone;
        obj.contact.MobilePhone = obj.account.MobilePhone__c;
        obj.contact.Email = obj.account.PrimaryEmail__c;
        obj.contact.PhonePrefix__c = obj.account.PhonePrefix__c;
        obj.contact.Fax = obj.account.FAX__c;                       
        obj.contact.Profession__c = obj.account.Profession__c;             
        obj.contact.MailingCity = obj.account.BillingCity;           
        obj.contact.MailingCityCode__c = obj.account.BillingCityCode__c;                  
        obj.contact.MailingCountry = obj.account.BillingCountry;              
        obj.contact.MailingPostalCode = obj.account.BillingPostalCode;                 
        obj.contact.MailingState = obj.account.BillingState;            
        obj.contact.MailingStreet = obj.account.BillingStreet;             
        obj.contact.MailingStreetName__c = obj.account.BillingStreetName__c;                    
        obj.contact.MailingStreetCode__c = obj.account.BillingStreetCode__c;                    
        obj.contact.MailingStreetNumber__c = obj.account.BillingStreetNumber__c;                      
        obj.contact.MailingStreetNumberExtension__c = obj.account.BillingStreetNumberExtension__c;                               
        obj.contact.MailingStreetToponym__c = obj.account.BillingStreetToponym__c;                       
        obj.contact.MailingRegion__c = obj.account.BillingRegion__c;                
        obj.contact.MailingPlace__c = obj.account.BillingPlace__c;                
        obj.contact.MailingPlaceCode__c = obj.account.BillingPlaceCode__c;                    
        obj.contact.MailingIsAddressVerified__c = obj.account.BillingIsAddressVerified__c;
    }

    private class HDT_WRP_sObject {
        private Account account;
        private Contact contact;
        private BillingProfile__c billingProfile;
        private ServicePoint__c servicePoint;
    }

    public static void setDataForTest(){

        Id massiveLoaderRequestId = 'a3d3O000000WyvQQAS';
        Set<Id> docId = new Set<Id>();

        delete [SELECT Id FROM MassiveLoaderRequestItem__c WHERE MassiveLoaderRequest__c = :massiveLoaderRequestId];
        delete [
            SELECT Id
            FROM Account
            WHERE Createddate = today AND CreatedById = '0051X0000055rbNQAQ'
        ];
    
        delete [
            SELECT Id
            FROM Contact
            WHERE Createddate = today AND CreatedById = '0051X0000055rbNQAQ'
        ];

        delete [
            SELECT Id
            FROM BillingProfile__c
            WHERE Createddate = today AND CreatedById = '0051X0000055rbNQAQ'
        ];

        delete [
            SELECT Id
            FROM ServicePoint__c
            WHERE Createddate = today AND CreatedById = '0051X0000055rbNQAQ'
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
        for(Integer n=0; n<20; n++){
            item = new MassiveLoaderRequestItem__c();
            item.MassiveLoaderRequest__c = massiveLoaderRequestId;
            tempList = new List<String>();
            item.Status__c = 'In attesa di lavorazione';

            iteration = String.valueOf(n);

            // -- Account / Contact
            tempList.add('Business'); // Tipo
            tempList.add('true'); // FlagVerificato
            tempList.add(''); // FAX
            tempList.add(''); // Stato
            tempList.add(''); // BP
            tempList.add(''); // Comune
            tempList.add('Adam'); // Nome
            tempList.add(''); // Professione
            tempList.add('AAA-EBT'); // Silos
            tempList.add(''); // Localita
            tempList.add(''); // ComuneNascita
            tempList.add('55'); // Civico
            tempList.add('Daniel'); // Cognome
            tempList.add(''); // CodiceVia
            tempList.add(''); // Provincia
            tempList.add(''); // CodiceLocalita
            tempList.add(''); // IndirizzoEstero
            tempList.add(''); // CAP
            tempList.add('Aziende SME'); // Categoria
            tempList.add(''); // DataNascita
            tempList.add('AAS Associazione'); // Marcatura
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
            tempList.add('100361621' + iteration); // CSN - 1003616210

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
            tempList.add(''); // CodicePunto
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