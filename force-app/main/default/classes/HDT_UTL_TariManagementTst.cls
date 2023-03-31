/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 24-03-2023
 * @last modified by  : Giacinto Florio
**/
@isTest
public with sharing class HDT_UTL_TariManagementTst {

    @IsTest
    static void testExecuteCatalogBlank(){

        List<HDT_UTL_TariManagement.HDT_WRP_TariManagementRequest> inputs = new List<HDT_UTL_TariManagement.HDT_WRP_TariManagementRequest>();
        HDT_UTL_TariManagement.HDT_WRP_TariManagementRequest req = new HDT_UTL_TariManagement.HDT_WRP_TariManagementRequest();

        Case caso = new Case();
        caso.Commodity__c = 'Ambiente';
        insert caso;
        req.caseId = caso.Id;
        req.catalogId = '';
        req.method = 'checkTariProcess';
        inputs.add(req);

        Test.startTest();
        List<HDT_UTL_TariManagement.HDT_WRP_TariManagementResponse> results = HDT_UTL_TariManagement.execute(inputs);
        System.assertNotEquals(null, results, 'results not null');
        Test.stopTest();
    }


    @IsTest
    static void testExecuteCatalogNotBlank(){

        List<HDT_UTL_TariManagement.HDT_WRP_TariManagementRequest> inputs = new List<HDT_UTL_TariManagement.HDT_WRP_TariManagementRequest>();
        HDT_UTL_TariManagement.HDT_WRP_TariManagementRequest req = new HDT_UTL_TariManagement.HDT_WRP_TariManagementRequest();

        Case caso = new Case();
        caso.Commodity__c = 'Ambiente';
        insert caso;

        AccountStatementFilter__c accStatement = new AccountStatementFilter__c();
        accStatement.DocumentSelected__c = '[{"codiceCliente":"1007848247","bloccoAlSollecito":"NO","contoContrattuale":"200011795823","classeConto":"Z001","dataEmissione":"14/06/2022","dataScadenza":"14/07/2022","dilazione":"NO","idPrimoLivelloSAP":"00000000000000000000000000000000000000000000000001","importo":"43.52","modalitaPagamento":"BOLLETTINO","modalitaPagamentoCA":"bollettino postale","numeroFattura":"0000242200363597","r":"I","rateizzato":"NO","residuo":"0.0","societa":"Marche Multiservizi S.p.A","sollecitato":"NO","tipoDocumento":"CALCOLO CONTRATTI ATTIVI","totaleCopertina":"32.08","loginId":"0-1","bonus":"NO","secondoLivelloInformativo":[{"contratto":"3022411080","dataPareggio":"14/06/2022","dataRegistrazione":"14/06/2022","docPareggio":"562300470029","documento":"198673343297","importo":"11.44","motivoDiPareggio":"COMPENSATO","residuo":"0.0","scadenza":"14/07/2022","settoreMerceologico":"Acqua","testoDettaglio":"CALCOLO CONTRATTI ATTIVI","tipoDocumento":"2F","idSecondoLivelloSAP":"00000000000000000000000000000000000000000000000001","tdPareggio":"2C"}],"id":"00000000000000000000000000000000000000000000000001"}]';
        insert accStatement;

        req.caseId = caso.Id;
        req.catalogId = accStatement.Id;
        req.method = 'checkTariProcess';
        inputs.add(req);

        Test.startTest();
        List<HDT_UTL_TariManagement.HDT_WRP_TariManagementResponse> results = HDT_UTL_TariManagement.execute(inputs);
        System.assertNotEquals(null, results, 'results not null');
        Test.stopTest();
    }

    @IsTest
    static void testExecuteAnnualPayment(){

        List<HDT_UTL_TariManagement.HDT_WRP_TariManagementRequest> inputs = new List<HDT_UTL_TariManagement.HDT_WRP_TariManagementRequest>();
        HDT_UTL_TariManagement.HDT_WRP_TariManagementRequest req = new HDT_UTL_TariManagement.HDT_WRP_TariManagementRequest();

        Case caso = new Case();
        caso.Commodity__c = 'Ambiente';
        caso.SupplyCity__c = 'ROMA';
        caso.DeclarationDate__c = Date.today();
        insert caso;

        CityTechnicalData__c city = new CityTechnicalData__c();
        city.CadastralCity__c = 'ROMA';
        city.UnicPaymentAlert__c = '';
        city.UnicPaymentLimitDate__c = Date.today();
        insert city;

        AccountStatementFilter__c accStatement = new AccountStatementFilter__c();
        accStatement.DocumentSelected__c = '[{"codiceCliente":"1007848247","bloccoAlSollecito":"NO","contoContrattuale":"200011795823","classeConto":"Z001","dataEmissione":"14/06/2022","dataScadenza":"14/07/2022","dilazione":"NO","idPrimoLivelloSAP":"00000000000000000000000000000000000000000000000001","importo":"43.52","modalitaPagamento":"BOLLETTINO","modalitaPagamentoCA":"bollettino postale","numeroFattura":"0000242200363597","r":"I","rateizzato":"NO","residuo":"0.0","societa":"Marche Multiservizi S.p.A","sollecitato":"NO","tipoDocumento":"CALCOLO CONTRATTI ATTIVI","totaleCopertina":"32.08","loginId":"0-1","bonus":"NO","secondoLivelloInformativo":[{"contratto":"3022411080","dataPareggio":"14/06/2022","dataRegistrazione":"14/06/2022","docPareggio":"562300470029","documento":"198673343297","importo":"11.44","motivoDiPareggio":"COMPENSATO","residuo":"0.0","scadenza":"14/07/2022","settoreMerceologico":"Acqua","testoDettaglio":"CALCOLO CONTRATTI ATTIVI","tipoDocumento":"2F","idSecondoLivelloSAP":"00000000000000000000000000000000000000000000000001","tdPareggio":"2C"}],"id":"00000000000000000000000000000000000000000000000001"}]';
        insert accStatement;

        req.caseId = caso.Id;
        req.catalogId = accStatement.Id;
        req.method = 'calculateAnnualPaymentEffectiveness';
        inputs.add(req);

        Test.startTest();
        List<HDT_UTL_TariManagement.HDT_WRP_TariManagementResponse> results = HDT_UTL_TariManagement.execute(inputs);
        System.assertNotEquals(null, results, 'results not null');
        Test.stopTest();
    }

}