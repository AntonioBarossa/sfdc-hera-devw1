/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 24-03-2023
 * @last modified by  : Giacinto Florio
**/
@isTest
public with sharing class HDT_UTL_ManageTariTst {
    
    @IsTest
    static void testCheckTariProcess(){
    
        AccountStatementFilter__c accStatement = new AccountStatementFilter__c();
        accStatement.DocumentSelected__c = '[{"codiceCliente":"1007848247","bloccoAlSollecito":"NO","contoContrattuale":"200011795823","classeConto":"Z001","dataEmissione":"14/06/2022","dataScadenza":"14/07/2022","dilazione":"NO","idPrimoLivelloSAP":"00000000000000000000000000000000000000000000000001","importo":"43.52","modalitaPagamento":"BOLLETTINO","modalitaPagamentoCA":"bollettino postale","numeroFattura":"0000242200363597","r":"I","rateizzato":"NO","residuo":"0.0","societa":"Marche Multiservizi S.p.A","sollecitato":"NO","tipoDocumento":"CALCOLO CONTRATTI ATTIVI","totaleCopertina":"32.08","loginId":"0-1","bonus":"NO","secondoLivelloInformativo":[{"contratto":"3022411080","dataPareggio":"14/06/2022","dataRegistrazione":"14/06/2022","docPareggio":"562300470029","documento":"198673343297","importo":"11.44","motivoDiPareggio":"COMPENSATO","residuo":"0.0","scadenza":"14/07/2022","settoreMerceologico":"Acqua","testoDettaglio":"CALCOLO CONTRATTI ATTIVI","tipoDocumento":"2F","idSecondoLivelloSAP":"00000000000000000000000000000000000000000000000001","tdPareggio":"2C"}],"id":"00000000000000000000000000000000000000000000000001"}]';
        insert accStatement;

        Test.startTest();
        List<Boolean> results = HDT_UTL_ManageTari.checkTariProcess(new List<String>{accStatement.Id});
        System.assertNotEquals(null, results, 'results not null');
        Test.stopTest();
    }
}