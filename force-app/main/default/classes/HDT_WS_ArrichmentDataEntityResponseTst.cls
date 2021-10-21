/**
 * @author Valere (valere@noeli-it.net)
 * @date 28/09/2021
 * @description HDT_WS_ArrichmentDataEntityResponse Test Class
 * @history valere - 28/09/2021– Created Class
 */
@isTest
private class HDT_WS_ArrichmentDataEntityResponseTst {
  
    @isTest 
    static void testBuilderArrichmentDataEntityResponse() {


        HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_TestataObject  dataTestata=  new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_TestataObject();
        dataTestata.esito='test esito';
        dataTestata.messaggio='test messaggio';

        System.assertEquals('test esito', dataTestata.esito, ' we created an HDT_WRP_TestataObject with esito equal to test esito');
        System.assertNotEquals('esito', dataTestata.esito, ' we created an HDT_WRP_TestataObject with esito equal to test esito');

        HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject  dataPosizioni=  new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
        dataPosizioni.campo='test campo';
        dataPosizioni.valore='test valore';


        System.assertEquals('test campo', dataPosizioni.campo, ' we created an HDT_WRP_PosizioniResponseObject with campo equal to test campo');
        System.assertNotEquals('campo', dataPosizioni.campo, ' we created an HDT_WRP_PosizioniResponseObject with campo equal to test campo');


        List<HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_posizioniResponseObject> ListDataPosizioni= new List<HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_posizioniResponseObject>();
        ListDataPosizioni.add(dataPosizioni);


        HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_DataResponseObject  dataDataResponse=  new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_DataResponseObject();
        dataDataResponse.testata=dataTestata;
        dataDataResponse.posizioni=ListDataPosizioni;



        System.assertEquals('test esito',  dataDataResponse.testata.esito, ' we created an HDT_WRP_DataResponseObject which contains a HDT_WRP_TestataObject with esito equal to test esito');
        System.assertNotEquals('esito',  dataDataResponse.testata.esito, ' we created an HDT_WRP_DataResponseObject which contains a HDT_WRP_TestataObject with esito equal to test esito');


        HDT_WS_ArrichmentDataEntityResponse arrichmentData= new HDT_WS_ArrichmentDataEntityResponse();
        arrichmentData.status='test status';
        arrichmentData.correlationId='test correlationId';
        arrichmentData.timestamp='test timestamp';
        arrichmentData.data= dataDataResponse;


        System.assertEquals('test status',  arrichmentData.status, ' we created an HDT_WS_ArrichmentDataEntityResponse with status equal to test status');
        System.assertNotEquals('status',  arrichmentData.status, ' we created an HDT_WS_ArrichmentDataEntityResponse with status equal to test status');


        HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_ErrorResponseObject  dataErrorResponse=  new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_ErrorResponseObject();
        dataErrorResponse.code='test code';
        dataErrorResponse.message='test message';
        dataErrorResponse.additionalInfo='test additionalInfo';

        System.assertEquals('test code',   dataErrorResponse.code, ' we created an HDT_WRP_ErrorResponseObject with code equal to test code');
        System.assertNotEquals('code',   dataErrorResponse.code, ' we created an HDT_WRP_ErrorResponseObject with code equal to test code');


    }

}