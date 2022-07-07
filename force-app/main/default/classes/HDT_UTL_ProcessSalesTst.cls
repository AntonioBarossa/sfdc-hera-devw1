@isTest
public with sharing class HDT_UTL_ProcessSalesTst {

        /*
        List<sObject> objList = new List<sObject>();
        Contact cont = new Contact();
        cont.FirstName = 'test';
        cont.LastName = 'last';
        cont.GlobalMigrationKey__c = '1';
        Account accReference = new Account();
        accReference.GlobalMigrationKey__c = '1';
        cont.Account = accReference;
        Account newAccount = new Account();
        newAccount.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Business').getRecordTypeId();
        newAccount.Name = 'test account';
        newAccount.CompanyOwner__c = 'AAA-EBT';
        newAccount.CustomerMarking__c = 'AAS Associazione';
        newAccount.Category__C = 'Aziende SME';
        newAccount.BillingCityCode__c = 'Roma';
        newAccount.BillingStreetName__c = 'via roma';
        newAccount.BillingStreetNumber__c = '55';
        newAccount.LastName__c = 'test account';
        newAccount.BillingIsAddressVerified__c = true;
        newAccount.FiscalCode__c = 'SXSRLA45H28H5';
        newAccount.VATNumber__c = '12345678';
        newAccount.IsWrongFiscalData__c = false;
        newAccount.CustomerCode__c = '1003616210';
        newAccount.GlobalMigrationKey__c = '1';
        objList.add(newAccount);
        objList.add(cont);
        Database.insert(objList);

        HDT_WS_ArrichmentDataEntityResponse serResp = HDT_WS_ArrichmentDataEntityInvoker.callService('',currentProcess.currentServicePoint.ServicePointCode__c);
        HDT_UTL_ServicePoint.extractDataFromArriccDataServiceWithExistingSp(currentProcess.currentServicePoint, serResp);


        try {
            List<ServicePoint__c> spList = [SELECT Id, MeterStatus__c,Distributor__c,Account__c FROM ServicePoint__c WHERE ServicePointCode__c  = 'IT001E04893470' LIMIT 1];
            HDT_WS_ArrichmentDataEntityResponse serResp=HDT_WS_ArrichmentDataEntityInvoker.callService('', 'IT001E04893470');
            System.debug(serResp);
            List<ServicePoint__c> spListWs = HDT_UTL_ServicePoint.extractDataFromArriccDataServiceWithExistingSp(spList[0], serResp);
            System.debug(spListWs);
        } catch (Exception e){
            System.debug('Exception > ' + e.getMessage());
        }
        System.debug('CpuTime > ' + limits.getCpuTime());

        */

        /*public static void setDataForTest(Integer numRecords){

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

            //if(n==1){
            //    tempList.add('854455666'); // FAX - 
            //} else {
            //    tempList.add(''); // FAX - 854455666
            //}
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
    
    }*/

}