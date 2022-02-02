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
    private Account account;
    private Contact contact;
    private BillingProfile__c billingProfile;
    private ServicePoint__c servicePoint;
    private Map<String, AccountContactRelation> accountContactMap;
    private Map<String, BillingProfile__c> contractToBillProfMap = new Map<String, BillingProfile__c>();
    private List<AccountContactRelation> accContRelationList;
    private List<BillingProfile__c> billingProfileList;
    private Id recordTypeId;
    private Integer csnIndex;
    //private Integer fiscalCodeIndex;
    //private Integer vatNumberIndex;
    //private Integer marcaturaIndex;
    private Integer contoContrattualeIndex;
    private Integer codicePuntoIndex;

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

        System.debug('>>> csnIndex: ' + csnIndex);
        //System.debug('>>> fiscalCodeIndex: ' + fiscalCodeIndex);
        //System.debug('>>> vatNumberIndex: ' + vatNumberIndex);
        //System.debug('>>> marcaturaIndex: ' + marcaturaIndex);
        System.debug('>>> contoContrattualeIndex: ' + contoContrattualeIndex);
        System.debug('>>> codicePuntoIndex: ' + codicePuntoIndex);

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
        recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Business').getRecordTypeId();
        //List<Account> accountList = [
        //    SELECT Id, FiscalCode__c, VATNumber__c, CustomerMarking__c
        //    FROM Account
        //    WHERE FiscalCode__c IN :fiscalCodeSet
        //    AND VATNumber__c IN :vatNumberSet
        //    AND CustomerMarking__c IN :marcaturaSet
        //];
//
        //List<BillingProfile__c> billingProfileList = [
        //    SELECT Id, ContractAccountCode__c
        //    FROM BillingProfile__c
        //    WHERE ContractAccountCode__c IN: contoContrattualeSet
        //];

    }

    public override void registryCreation(){
        System.debug(LoggingLevel.DEBUG, 'registryCreation');

        HDT_UTL_ProcessCommonOperations.getLimitDetails('START registryCreation');

        List<sObject> AccountToInsert = new List<sObject>();
        List<String> itemIds = new List<String>();
        itemsToSave = new List<MassiveLoaderRequestItem__c>();

        for(String itemId : itemRequestMap.keySet()){

            List<String> tempSplitted = itemRequestMap.get(itemId);
            account = new Account();
            contact = new Contact();

            billingProfile = new BillingProfile__c();
            servicePoint = new ServicePoint__c();

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
                                //if(enableCreateAccount)
                                    convertionError = mapTypeField(account, mapAllFields, count, tempField);
                            }
                            when 'BillingProfile__c' {
                                if(enableCreateBillingProfile)
                                    convertionError = mapTypeField(billingProfile, mapAllFields, count, tempField);
                            }
                            when 'ServicePoint__c' {
                                if(enableCreateServicePoint)
                                    convertionError = mapTypeField(servicePoint, mapAllFields, count, tempField);
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

            System.debug(LoggingLevel.DEBUG, '>>> currentAccount: ' + account);
            System.debug(LoggingLevel.DEBUG, '>>> currentBillingProfile: ' + billingProfile);
            System.debug(LoggingLevel.DEBUG, '>>> currentServicePoint: ' + servicePoint);

            account.RecordTypeId = recordTypeId;
            account.IsWrongFiscalData__c = false;
            account.BillingCityCode__c = 'Roma';
            //account.GlobalMigrationKey__c = '1';

            accountToInsert.add(account); 
            itemIds.add(itemId);

            //createContact();
            //contact.GlobalMigrationKey__c = '1';
            //
            //Account accReference = new Account();
            //accReference.GlobalMigrationKey__c = '1';
            //
            //contact.Account = accReference;
            //accountToInsert.add(contact); 

            //System.debug(LoggingLevel.DEBUG, '>>> currentContact: ' + contact);
        }

        if(accountToInsert.size() > 0){

            HDT_UTL_ProcessCommonOperations.HDT_WRP_SaveResponse saveResponse;
            saveResponse = HDT_UTL_ProcessCommonOperations.databaseInsert(accountToInsert, itemIds, 'Account');
            accountToInsert.clear();

            System.debug('>>> saveResponse.savedObject ' + saveResponse.savedObject);
            System.debug('>>> saveResponse.itemIdToAccountId: ' + saveResponse.itemIdToAccountId);

            for(sObject obj : saveResponse.savedObject){
                if(obj.getSObjectType()==Schema.Account.getSObjectType()){
                    accountIdList.add((Id)obj.get('Id'));
                }
            }

            HDT_UTL_ProcessCommonOperations.getLimitDetails('AFTER CASE CREATION & Enrichment');

            if(saveResponse.reponseItemList.size() > 0){
                itemsToSave.addAll(saveResponse.reponseItemList);
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
        for(Integer n=0; n<1; n++){
            item = new MassiveLoaderRequestItem__c();
            item.MassiveLoaderRequest__c = massiveLoaderRequestId;
            tempList = new List<String>();
            item.Status__c = 'In attesa di lavorazione';
            // -- Account / Contact
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
            tempList.add('12345679'); // PI - 12345678
            tempList.add(''); // Cellulare
            tempList.add('SXSRLA45H28H6'); // CF - SXSRLA45H28H5
            tempList.add(''); // Sesso
            tempList.add(''); // PrefCell
            tempList.add('1003616211'); // CSN - 1003616210

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