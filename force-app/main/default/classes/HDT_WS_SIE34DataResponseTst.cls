/**
 * Header of the class "HDT_WS_SIE34DataResponseTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_WS_SIE34DataResponse"
 * @history
 * @Created 20/10/2021
 * Modified By:
 **/
@isTest
public class HDT_WS_SIE34DataResponseTst {
       
    @isTest static void test1(){
        
        HDT_WS_SIE34DataResponse.HDT_WRP_errorResponseObject err = new HDT_WS_SIE34DataResponse.HDT_WRP_errorResponseObject();
        err.code = 'test';
        err.message = 'test';
        err.additionalInfo = 'test';
           
        List<HDT_WS_SIE34DataResponse.HDT_WRP_errorResponseObject> errors = new List<HDT_WS_SIE34DataResponse.HDT_WRP_errorResponseObject>();
        errors.add(err);
        
        HDT_WS_SIE34DataResponse.HDT_WRP_posizioniResponseObject pos = new HDT_WS_SIE34DataResponse.HDT_WRP_posizioniResponseObject();
        pos.campo = 'test';
        pos.valore = 'test';
        
        List<HDT_WS_SIE34DataResponse.HDT_WRP_posizioniResponseObject> posiz = new List<HDT_WS_SIE34DataResponse.HDT_WRP_posizioniResponseObject>();
        posiz.add(pos);
        
        HDT_WS_SIE34DataResponse.HDT_WRP_testataObject testat = new HDT_WS_SIE34DataResponse.HDT_WRP_testataObject();
        testat.esito = 'test';
        testat.messaggio = 'test';
        
        HDT_WS_SIE34DataResponse.HDT_WRP_dataResponseObject obj = new HDT_WS_SIE34DataResponse.HDT_WRP_dataResponseObject();
        obj.testata = testat;
        obj.posizioni = posiz;        
        
        HDT_WS_SIE34DataResponse res = new HDT_WS_SIE34DataResponse();        
        res.data = obj;
        res.errorDetails = errors;
        res.status = 'test';
        res.correlationId = 'test';
        res.timestamp = 'test';
        
        System.assertNotEquals(null, res, 'HDT_WS_SIE34DataResponse not created correctly');        
        System.assertEquals('test', res.data.testata.esito, 'HDT_WS_SIE34DataResponse not created correctly');
    }
}