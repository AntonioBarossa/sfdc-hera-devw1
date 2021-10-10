/**
 * @author Luca Molino (luca.molino@dunegroup.it)
 * @date 16/09/2021
 * @description HDT_WRP_PaperProcessing Test Class
 * @history Luca Molino – 04/10/2021 – Created Class
 */
@isTest
public with sharing class HDT_WS_RicCreBpCaRequestTst {
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    
    @TestSetup
    static void setup(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.HERA_SYSTEM_ADMINISTRATOR_NAME);
 
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
 
        internalUser.UserPermissionsMarketingUser=true;
 
        insert internalUser;        
    }

    @isTest
    public static void testRicCreBpCaRequest(){
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
            
            Test.startTest();
            HDT_WS_RicCreBpCaRequest req = new HDT_WS_RicCreBpCaRequest();
            HDT_WS_RicCreBpCaRequest.HDT_WS_RicCreBpCaRequestAddress address = new HDT_WS_RicCreBpCaRequest.HDT_WS_RicCreBpCaRequestAddress();
            
            address.comune='MILANO';
            address.nazione ='ITALIA';
            address.toponimo ='test';
            address.frazione ='test';
            address.piano ='2';
            address.civico ='45';
            address.suffissoCivico ='c';
            address.cap ='20092';
            address.provincia ='MILANO';
            address.via ='Veneto';

            HDT_WS_RicCreBpCaRequest.HDT_WS_RicCreBpCaRequestGrupIva2 gruppoIva = new HDT_WS_RicCreBpCaRequest.HDT_WS_RicCreBpCaRequestGrupIva2();
            gruppoIva.adesione='test';
            gruppoIva.partitaIva='test';
            gruppoIva.dataInizio=Date.today();
            gruppoIva.dataFine=Date.today()+30;
            


            HDT_WS_RicCreBpCaRequest.HDT_WS_RicCreBpCaRequestAccount acc = new HDT_WS_RicCreBpCaRequest.HDT_WS_RicCreBpCaRequestAccount();
            acc.nome='test';
            acc.alias='test';
            acc.partner='test';
            acc.tipoAccount='test';
            acc.categoria='test';
            acc.fax='test';
            acc.cellulare='test';
            acc.telefono='test';
            acc.email='test';
            acc.emailCont='test';
            acc.marcaturaCliente='test';
            acc.codiceFiscale='test';
            acc.modelloCA='test';
            acc.partitaIva='test';
            acc.indirizzo=address;
            acc.gruppoIva=gruppoIva;

            HDT_WS_RicCreBpCaRequest.HDT_WS_RicCreBpCaRequestbank reqBank = new HDT_WS_RicCreBpCaRequest.HDT_WS_RicCreBpCaRequestbank();
            reqBank.filiale='test';
            reqBank.nome='test';
            reqBank.comune='test';
            reqBank.provincia='test';
            reqBank.nazione='test';


            HDT_WS_RicCreBpCaRequest.HDT_WS_RicCreBpCaRequestdateBank datiBancari = new HDT_WS_RicCreBpCaRequest.HDT_WS_RicCreBpCaRequestdateBank();
            datiBancari.banca=reqBank;
            datiBancari.abi='test';
            datiBancari.cab='test';
            datiBancari.contoCorrente='test';
            datiBancari.codiceFiscale='test';
            datiBancari.nome='test';
            datiBancari.cognome='test';
            datiBancari.terminiPagamento='test';
            datiBancari.cin='test';
            datiBancari.iban='test';
            datiBancari.metodoPagamento='test';
            datiBancari.metodoPagamentoAlternativo='test';

            HDT_WS_RicCreBpCaRequest.HDT_WS_RicCreBpCaRequestDestination reqDest = new HDT_WS_RicCreBpCaRequest.HDT_WS_RicCreBpCaRequestDestination();
            reqDest.nome='test';
            reqDest.fax='test';
            reqDest.email='test';
            reqDest.partitaIva='test';
            reqDest.telefono='test';
            reqDest.codiceFiscale='test';
            reqDest.idIntegrazione='test';
            reqDest.cognome='test';
            reqDest.indirizzo=address;
            
            HDT_WS_RicCreBpCaRequest.HDT_WS_RicCreBpCaRequestBilling reqBilling = new HDT_WS_RicCreBpCaRequest.HDT_WS_RicCreBpCaRequestBilling();
            reqBilling.codiceUfficio='test';
            reqBilling.fatturaXML='test';
            reqBilling.mailPec='test';
            reqBilling.modello='test';

            HDT_WS_RicCreBpCaRequest.HDT_WS_RicCreBpCaRequestGrupIva gruppoIva2 = new HDT_WS_RicCreBpCaRequest.HDT_WS_RicCreBpCaRequestGrupIva();
            gruppoIva2.idOggetto='';
            gruppoIva2.contoContrattuale='';
            gruppoIva2.emailInvioBolletta='';
            gruppoIva2.creaNuovoCA='';
            gruppoIva2.pecInvioBolletta='';
            gruppoIva2.datiBancari=datiBancari;
            gruppoIva2.indirizzo=address;
            gruppoIva2.destinatarioDivergente=reqDest;
            gruppoIva2.fattura=reqBilling;

            
            req.account=acc;
            req.ordine=gruppoIva2;
            req.cancellaBPAlternativo='test';
            req.codiceCausale='test';
            req.dataCreazione=0;
            req.nomeContatto='test';
            req.numeroSR='test';

            system.assertEquals(req.cancellaBPAlternativo,'test','the field cancellaBPAlternativo is not valorized');
            system.assertNotEquals(req.cancellaBPAlternativo,'test','the field cancellaBPAlternativo is valorized');

            Test.stopTest();
        } 
    }
}
