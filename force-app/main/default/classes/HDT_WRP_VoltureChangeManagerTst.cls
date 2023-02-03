/**@frpanico 12/10/2021
 * Test Class for the class HDT_WRP_VoltureChangeManager
 */

@IsTest
public with sharing class HDT_WRP_VoltureChangeManagerTst {

    @IsTest
    static void tstMethod()
    {
        Test.startTest();
        HDT_WRP_VoltureChangeManager.HDT_WRP_AccountCheck accountCheck = new HDT_WRP_VoltureChangeManager.HDT_WRP_AccountCheck();
        HDT_WRP_VoltureChangeManager.HDT_WRP_Request req = new HDT_WRP_VoltureChangeManager.HDT_WRP_Request();
        req.description = 'descr';
        req.code = 'code';
        HDT_WRP_VoltureChangeManager.HDT_WRP_Header head = new HDT_WRP_VoltureChangeManager.HDT_WRP_Header();
        head.requestId = 'test';
        req.header = head;
        HDT_WRP_VoltureChangeManager.HDT_WRP_Object obj = new HDT_WRP_VoltureChangeManager.HDT_WRP_Object();
        obj.id = 'test';
        obj.name = 'name';
        obj.objectType = 'test';
        HDT_WRP_VoltureChangeManager.HDT_WRP_Field field = new HDT_WRP_VoltureChangeManager.HDT_WRP_Field();
        field.name = 'test';
        field.value = 'test';
        accountCheck.nextPhase = 'Comunicazione verso Heroku';
        Order ord = new Order(Description = 'Bozza');
        HDT_WRP_VoltureChangeManager.HDT_WRP_ProcessCheck processCheck = new HDT_WRP_VoltureChangeManager.HDT_WRP_ProcessCheck('ok','ok',ord);
        HDT_WRP_VoltureChangeManager.HDT_WRP_Prestazione prest = new HDT_WRP_VoltureChangeManager.HDT_WRP_Prestazione();
        HDT_WRP_VoltureChangeManager.HDT_WRP_Response resp = new HDT_WRP_VoltureChangeManager.HDT_WRP_Response(new Map<String, String>{'status' => 'test', 'correlationId' => 'test', 'timestamp' => 'test'});
        Test.stopTest(); 
        System.assertEquals('Comunicazione verso Heroku', accountCheck.nextPhase,'Fase non corretta');
    }

    @isTest
    static void createHeaderWrapper(){
        Test.startTest();
        HDT_WRP_VoltureChangeManager.HDT_WRP_Header headerWrapper=new HDT_WRP_VoltureChangeManager.HDT_WRP_Header();
        Test.stopTest();
        System.assertEquals(true, headerWrapper!=null, 'Wrapper created');
    }

    @isTest
    static void createFieldsWrapper(){
        Test.startTest();
        HDT_WRP_VoltureChangeManager.HDT_WRP_Field fieldsWrapper= new HDT_WRP_VoltureChangeManager.HDT_WRP_Field();
        Test.stopTest();
        system.assertEquals(true, fieldsWrapper!=null, 'Wrapper created');
    }

    @isTest
    static void createObjectWrapper(){
        Test.startTest();
        HDT_WRP_VoltureChangeManager.HDT_WRP_Object objectWrapper=new HDT_WRP_VoltureChangeManager.HDT_WRP_Object();
        Test.stopTest();
        System.assertEquals(true, objectWrapper!=null, 'Wrapper created');
    }

    @isTest
    static void createRequestWrapper(){
        Test.startTest();
        HDT_WRP_VoltureChangeManager.HDT_WRP_Request requestWrapper= new HDT_WRP_VoltureChangeManager.HDT_WRP_Request();
        Test.stopTest();
        System.assertEquals(true, requestWrapper!=null, 'Wrapper created');
    }

    @isTest
    static void createProcessCheckWrapper(){
        Test.startTest();
        HDT_WRP_VoltureChangeManager.HDT_WRP_ProcessCheck pCheckWrapper=new HDT_WRP_VoltureChangeManager.HDT_WRP_ProcessCheck('result string','message string',new Case());
        Test.stopTest();
        System.assertEquals('Case', String.valueOf(pCheckWrapper.sobj.getSObjectType()), 'Sobject variable is Case type');
    }

    @isTest
    static void createBodyCallWrapper(){
        Test.startTest();
        HDT_WRP_VoltureChangeManager.HDT_WRP_BodyCall bCallWrapper= new HDT_WRP_VoltureChangeManager.HDT_WRP_BodyCall();
        Test.stopTest();
        System.assertEquals(true, bCallWrapper!=null, 'Wrapper created');
    }

    @isTest
    static void createPrestazioneWrapper(){
        Test.startTest();
        HDT_WRP_VoltureChangeManager.HDT_WRP_Prestazione prestazioneWrapper= new HDT_WRP_VoltureChangeManager.HDT_WRP_Prestazione();
        Test.stopTest();
        System.assertEquals(true, prestazioneWrapper!=null, 'Wrapper created');
    }

    @isTest
    static void createResponseWrapper(){
        String randomCode=HDT_UTL_DataFactoryTst.generateRandomChars(18, false, false, true);
        Map<String,Object> params=new Map<String,Object>{
            'status'=>'Ok','correlationId'=>randomCode,'timestamp'=>'18:00.000','prestazione'=> new Map<String,Object>{'rds'=>'','rdo'=>'','pod'=>'','contratto'=>'','tipoAttivita'=>'','note'=>''}
        };
        Test.startTest();
        HDT_WRP_VoltureChangeManager.HDT_WRP_Response responseWrapper= new HDT_WRP_VoltureChangeManager.HDT_WRP_Response(params);
        Test.stopTest();
        System.assertEquals(responseWrapper.correlationId, randomCode, 'matching correlationId');
    }

}