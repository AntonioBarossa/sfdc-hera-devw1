/**
 * @author Valere (valere@noeli-it.net)
 * @date 01/10/2021
 * @description HDT_WS_CreditCheckResponseTst Test Class
 * @history valere - 01/10/2021– Created Class
 */
@istest
public class HDT_WS_CreditCheckResponseTst {
@istest
static void methodTst(){



    HDT_WS_CreditCheckResponse creditCheckResponse = new HDT_WS_CreditCheckResponse();
    creditCheckResponse.status = 'status';
    creditCheckResponse.correlationId = 'correlationId';
    creditCheckResponse.timestamp = 'timestamp';
    creditCheckResponse.result = new HDT_WS_CreditCheckResponse.HDT_WRP_ResultObject();
    HDT_WS_CreditCheckResponse.HDT_WRP_dataResponseObject data = new HDT_WS_CreditCheckResponse.HDT_WRP_dataResponseObject();
    List<HDT_WS_CreditCheckResponse.HDT_WRP_errorResponseObject> errorDetails = new List<HDT_WS_CreditCheckResponse.HDT_WRP_errorResponseObject>();
    system.assertEquals('status',creditCheckResponse.status, 'The good value');
    system.assertNotEquals('timestampfalse',creditCheckResponse.timestamp, 'The bad value');
    
    HDT_WS_CreditCheckResponse.HDT_WRP_DataResponseObject dataResponseObject = new HDT_WS_CreditCheckResponse.HDT_WRP_DataResponseObject ();
    dataResponseObject.testata = new HDT_WS_CreditCheckResponse.HDT_WRP_testataObject();
    dataResponseObject.posizioni = new List<HDT_WS_CreditCheckResponse.HDT_WRP_posizioniResponseObject>();
    
    HDT_WS_CreditCheckResponse.HDT_WRP_TestataObject testataObject = new HDT_WS_CreditCheckResponse.HDT_WRP_TestataObject ();
    testataObject.esito='esito';
    testataObject.messaggio='messaggio';
    system.assertEquals('esito',testataObject.esito, 'The good value');
    system.assertNotEquals('messaggiofalse',testataObject.messaggio, 'The bad value');

    HDT_WS_CreditCheckResponse.HDT_WRP_PosizioniResponseObject posizioniResponseObject = new HDT_WS_CreditCheckResponse.HDT_WRP_PosizioniResponseObject ();
    posizioniResponseObject.campo='campo';
    posizioniResponseObject.valore='valore';
    system.assertEquals('campo',posizioniResponseObject.campo, 'The good value');
    system.assertNotEquals('valorefalse',posizioniResponseObject.valore, 'The bad value');

    HDT_WS_CreditCheckResponse.HDT_WRP_ErrorResponseObject errorResponseObject = new HDT_WS_CreditCheckResponse.HDT_WRP_ErrorResponseObject ();
    errorResponseObject.code='code';
    errorResponseObject.message='message';
    errorResponseObject.additionalInfo='additionalInfo';
    system.assertEquals('code',errorResponseObject.code, 'The good value');
    system.assertNotEquals('additionalInfofalse',errorResponseObject.additionalInfo, 'The bad value');

    HDT_WS_CreditCheckResponse.HDT_WRP_ResultObject resultObject = new HDT_WS_CreditCheckResponse.HDT_WRP_ResultObject ();
    resultObject.applicationGuid='applicationGuid';
    resultObject.applicationId='applicationId';
    resultObject.identificativoCrm='identificativoCrm';
    resultObject.responseStatus='responseStatus';
    resultObject.errorTimestamp='errorTimestamp';
    system.assertEquals('applicationGuid',resultObject.applicationGuid, 'The good value');
    system.assertNotEquals('errorTimestampfalse',resultObject.errorTimestamp, 'The bad value');
}
}