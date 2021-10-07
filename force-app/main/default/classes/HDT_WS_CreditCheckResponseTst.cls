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
    system.assertEquals('status',creditCheckResponse.status,'value of parameter is matching');
    system.assertNotEquals('timestampfalse',creditCheckResponse.timestamp,'value of parameter is not matching');
    
    HDT_WS_CreditCheckResponse.HDT_WRP_DataResponseObject dataResponseObject = new HDT_WS_CreditCheckResponse.HDT_WRP_DataResponseObject ();
    dataResponseObject.testata = new HDT_WS_CreditCheckResponse.HDT_WRP_testataObject();
    dataResponseObject.posizioni = new List<HDT_WS_CreditCheckResponse.HDT_WRP_posizioniResponseObject>();
    
    HDT_WS_CreditCheckResponse.HDT_WRP_TestataObject testataObject = new HDT_WS_CreditCheckResponse.HDT_WRP_TestataObject ();
    testataObject.esito='esito';
    testataObject.messaggio='messaggio';
    system.assertEquals('esito',testataObject.esito,'value of parameter is matching');
    system.assertNotEquals('messaggiofalse',testataObject.messaggio,'value of parameter is not matching');

    HDT_WS_CreditCheckResponse.HDT_WRP_PosizioniResponseObject posizioniResponseObject = new HDT_WS_CreditCheckResponse.HDT_WRP_PosizioniResponseObject ();
    posizioniResponseObject.campo='campo';
    posizioniResponseObject.valore='valore';
    system.assertEquals('campo',posizioniResponseObject.campo,'value of parameter is matching');
    system.assertNotEquals('valorefalse',posizioniResponseObject.valore,'value of parameter is not matching');

    HDT_WS_CreditCheckResponse.HDT_WRP_ErrorResponseObject errorResponseObject = new HDT_WS_CreditCheckResponse.HDT_WRP_ErrorResponseObject ();
    errorResponseObject.code='code';
    Map<String, String> messagemap = new Map<String, String>();
    messagemap.put('keymessage','valuemessage');
    errorResponseObject.message=messagemap;
    errorResponseObject.additionalInfo='additionalInfo';
    system.assertEquals('code',errorResponseObject.code,'value of parameter is matching');
    system.assertNotEquals('additionalInfofalse',errorResponseObject.additionalInfo,'value of parameter is not matching');

    HDT_WS_CreditCheckResponse.HDT_WRP_ResultObject resultObject = new HDT_WS_CreditCheckResponse.HDT_WRP_ResultObject ();
    resultObject.applicationGuid='applicationGuid';
    resultObject.applicationId='applicationId';
    resultObject.identificativoCrm='identificativoCrm';
    resultObject.responseStatus='responseStatus';
    resultObject.errorTimestamp='errorTimestamp';
    system.assertEquals('applicationGuid',resultObject.applicationGuid,'value of parameter is matching');
    system.assertNotEquals('errorTimestampfalse',resultObject.errorTimestamp,'value of parameter is not matching');
}
}