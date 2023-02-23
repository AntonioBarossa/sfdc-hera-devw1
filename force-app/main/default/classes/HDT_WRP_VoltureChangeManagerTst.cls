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

}
