@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_ProcessSales extends HDT_UTL_ProcessExecution {

    private Map<String, HDT_MassiveFieldsObjectMap__mdt> sobjectMap;
    private Map<String, String> mapAccountFields;
    private Map<String, String> mapWrapperAccountFields;
    private Set<String> accountIdSet = new Set<String>();
    private Set<String> contractCodeSet = new Set<String>();
    private Map<String, List<String>> itemRequestMap = new Map<String, List<String>>();
    private List<MassiveLoaderRequestItem__c> itemsToSave;
    private Account newAccount;
    private Contact contact;
    private Map<String, AccountContactRelation> accountContactMap;
    private Map<String, BillingProfile__c> contractToBillProfMap = new Map<String, BillingProfile__c>();
    private List<AccountContactRelation> accContRelationList;
    private List<BillingProfile__c> billingProfileList;
    private Id recordTypeId;
    private Integer contractIndex;
    private Integer accountIdIndex;

    public override void checks(){
        System.debug(LoggingLevel.DEBUG, 'checks');
        mapFieldsObject();

        System.debug(LoggingLevel.DEBUG, '>>> mapAccountFields: ' + String.valueOf(mapAccountFields));
        System.debug(LoggingLevel.DEBUG, '>>> mapWrapperAccountFields: ' + String.valueOf(mapWrapperAccountFields));
        System.debug(LoggingLevel.DEBUG, '>>> mapHeaderForWrapper: ' + String.valueOf(mapHeaderForWrapper));
        System.debug(LoggingLevel.DEBUG, '>>> mapHeaderByPosition: ' + String.valueOf(mapHeaderByPosition));

        System.debug(LoggingLevel.DEBUG, '>>> sobjectMap: ' + String.valueOf(sobjectMap));

        //accountIdIndex = mapHeaderForWrapper.get(mapWrapperAccountFields.get('ACCOUNTID'));
        //contractIndex = mapHeaderForWrapper.get(mapWrapperAccountFields.get('CONTO_CONTRATTUALE'));

        List<String> dataSplitted;
        for(MassiveLoaderRequestItem__c item : currentProcess.currentRequestItemList){
            dataSplitted = item.Data__c.split(splitCharacter, -1);
            //accountIdSet.add(dataSplitted[accountIdIndex]);
            //contractCodeSet.add(dataSplitted[contractIndex]);
            itemRequestMap.put(item.Id, dataSplitted);
        }
    }

    public override void getRecords(){
        System.debug(LoggingLevel.DEBUG, 'getRecords');
        //recordTypeId = HDT_QR_ProcessPostSales.getRecordTypeId('HDT_RT_Residenziale');
        recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Business').getRecordTypeId();
    }

    public override void registryCreation(){
        System.debug(LoggingLevel.DEBUG, 'registryCreation');

        HDT_UTL_ProcessCommonOperations.getLimitDetails('START registryCreation');

        List<sObject> AccountToInsert = new List<sObject>();
        List<String> itemIds = new List<String>();
        itemsToSave = new List<MassiveLoaderRequestItem__c>();

        for(String itemId : itemRequestMap.keySet()){

            List<String> tempSplitted = itemRequestMap.get(itemId);
            newAccount = new Account();
            contact = new Contact();

            Integer count = 0;
            String convertionError;
            String csvHeader;
            String objField;

            System.debug(LoggingLevel.DEBUG, '>>> tempSplitted ' + tempSplitted.size());

            for (String tempField : tempSplitted) {

                if ('null'.equalsIgnoreCase(tempField)) {
                   tempField = '';
                }
                
                csvHeader = mapHeaderByPosition.get(count);
                objField = mapAccountFields.get(csvHeader);

                if (mapRequiredByPosition.get(count) != null && String.isBlank(tempField)) {
                    System.debug(LoggingLevel.DEBUG, '>>> throw new HDT_WRP_ProcessEntitiesException');
                    convertionError = 'Missing Required Field: ' + mapHeaderByPosition.get(count);
                }

                if(!String.isEmpty(convertionError)){
                    // error happened -> exit
                    break;
                }
            
                if(String.isNotBlank(objField) && String.isNotBlank(tempField)){
                    System.debug(LoggingLevel.DEBUG, '>>> CSV Header: ' + csvHeader + '; Case Field: ' + objField + '; value: ' + tempField);
                    //sobjectMap
                    convertionError = mapTypeField(newAccount, mapAccountFields, count, tempField);

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

            System.debug(LoggingLevel.DEBUG, '>>> currentAccount: ' + newAccount);

            newAccount.RecordTypeId = recordTypeId;
            newAccount.IsWrongFiscalData__c = false;
            newAccount.BillingCityCode__c = 'Roma';
            //newAccount.GlobalMigrationKey__c = '1';

            accountToInsert.add(newAccount); 
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

            System.debug('>>>saveResponse.savedObject ' + saveResponse.savedObject);

            for(sObject obj : saveResponse.savedObject){
                if(obj.getSObjectType()==Schema.Account.getSObjectType()){
                    accountIdList.add((Id)obj.get('Id'));
                }
            }

            HDT_UTL_ProcessCommonOperations.getLimitDetails('AFTER CASE CREATION & Enrichment');

            if(saveResponse.reponseItemList.size() > 0){
                itemsToSave.addAll(saveResponse.reponseItemList);
            }

            ///if(saveResponse.savedCase.size() > 0){
            ///    HDT_UTL_ProcessCommonOperations.runCompatibility(saveResponse.savedCase);
            ///}

        }  

    }

    public override void finalUpdate(){
        System.debug(LoggingLevel.DEBUG, 'finalUpdate');
    }

    private void mapFieldsObject(){
        List<HDT_MassiveFieldsObjectMap__mdt> allFieldForThisProcess;

        mapAccountFields = new Map<String, String>();
        mapWrapperAccountFields = new Map<String, String>();

        sobjectMap = new Map<String, HDT_MassiveFieldsObjectMap__mdt>();
        allFieldForThisProcess = HDT_QR_ProcessPostSales.getMapFieldsObjectByDeveloperName('Sales%');

        for(HDT_MassiveFieldsObjectMap__mdt temp : allFieldForThisProcess){
            if(temp.objectType__c.equalsIgnoreCase('WrapperAccount')){
                mapWrapperAccountFields.put(temp.labelField__c, temp.nameField__c);
            } else {
                mapAccountFields.put(temp.MasterLabel, temp.nameField__c);
            }
            sobjectMap.put(temp.MasterLabel, temp);
        }
    }

    private void createContact(){
        contact.DegreeOfStudies__c = newAccount.DegreeOfStudies__c;
        contact.CompanyOwner__c = newAccount.CompanyOwner__c;
        contact.LastName = newAccount.LastName__c;
        contact.Gender__c = newAccount.Gender__c;
        contact.FirstName = newAccount.FirstName__c;
        contact.Birthdate = newAccount.BirthDate__c;
        contact.FiscalCode__c = newAccount.FiscalCode__c;
        contact.Birthcity__c = newAccount.BirthProvince__c;
        contact.MobilePhonePrefix__c = newAccount.MobilePhonePrefix__c;
        contact.Phone = newAccount.Phone;
        contact.MobilePhone = newAccount.MobilePhone__c;
        contact.Email = newAccount.PrimaryEmail__c;
        contact.PhonePrefix__c = newAccount.PhonePrefix__c;
        contact.Fax = newAccount.FAX__c;                       
        contact.Profession__c = newAccount.Profession__c;             
        contact.MailingCity = newAccount.BillingCity;           
        contact.MailingCityCode__c = newAccount.BillingCityCode__c;                  
        contact.MailingCountry = newAccount.BillingCountry;              
        contact.MailingPostalCode = newAccount.BillingPostalCode;                 
        contact.MailingState = newAccount.BillingState;            
        contact.MailingStreet = newAccount.BillingStreet;             
        contact.MailingStreetName__c = newAccount.BillingStreetName__c;                    
        contact.MailingStreetCode__c = newAccount.BillingStreetCode__c;                    
        contact.MailingStreetNumber__c = newAccount.BillingStreetNumber__c;                      
        contact.MailingStreetNumberExtension__c = newAccount.BillingStreetNumberExtension__c;                               
        contact.MailingStreetToponym__c = newAccount.BillingStreetToponym__c;                       
        contact.MailingRegion__c = newAccount.BillingRegion__c;                
        contact.MailingPlace__c = newAccount.BillingPlace__c;                
        contact.MailingPlaceCode__c = newAccount.BillingPlaceCode__c;                    
        contact.MailingIsAddressVerified__c = newAccount.BillingIsAddressVerified__c; 
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
            tempList.add('12345678'); // PI
            tempList.add(''); // Cellulare
            tempList.add('SXSRLA45H28H5'); // CF
            tempList.add(''); // Sesso
            tempList.add(''); // PrefCell
            tempList.add('1003616210'); // CSN
            tempList.add(''); // NumeroConto
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
            tempList.add(''); // SPVia
            tempList.add(''); // ConsumoAnnuo
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