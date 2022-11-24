@isTest
public class HDT_LC_AccountStatementControllerTst {

    /*
        Test Class for:
        HDT_LC_AccountStatementController - 100%
        HDT_LC_AccountStatementCtrlHelper - 74%
        HDT_LC_AccountStatementCtrlUtility - 90%
        HDT_QR_AccountStatement - 100%
        HDT_WRP_AccountStatement - 53%
    */

    @testSetup
    static void setup() {
        HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
    }
    
    @isTest
    static void getTabsMetaData(){
        HDT_WRP_AccountStatement.HDT_WRP_Tabs tabMetadata;

        Test.startTest();
        
        tabMetadata = HDT_LC_AccountStatementController.getTabsMetaData();
        
        System.assertEquals(true, tabMetadata.success, '');
        System.assertEquals(10, tabMetadata.tabDetail.size(), '');
        
        Test.stopTest();

    }

    @isTest
    static void getSecondLevelColumns(){
        HDT_WRP_AccountStatement.HDT_WRP_SecLevColumnsObj secLevColumnsObj;

        Test.startTest();
        secLevColumnsObj = HDT_LC_AccountStatementController.getSecondLevelColumns('EC');
        
        System.debug('>>> columnObj ' + secLevColumnsObj.columnObj.size());
        System.debug('>>> buttonList ' + secLevColumnsObj.buttonList.size());

        System.assertEquals(true, secLevColumnsObj.success, 'success != true');
        System.assert(secLevColumnsObj.columnObj.size() > 0, 'columnObj.size() == 0');
        System.assert(secLevColumnsObj.buttonList.size() > 0, 'buttonList.size() == 0');

        Test.stopTest();

    }

    @isTest
    static void getSecondLevelColumnsWithFail(){
        HDT_WRP_AccountStatement.HDT_WRP_SecLevColumnsObj secLevColumnsObj;

        Test.startTest();
        secLevColumnsObj = HDT_LC_AccountStatementController.getSecondLevelColumns(null);

        System.assertEquals(false, secLevColumnsObj.success, 'success != false');
        System.assert(secLevColumnsObj.columnObj == null, 'columnObj != null');
        System.assert(secLevColumnsObj.buttonList == null, 'buttonList != null');

        Test.stopTest();

    }

    @isTest
    static void getTabConfiguration(){

        HDT_WRP_AccountStatement.HDT_WRP_ColumnsObj colObj;

        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;

        Test.startTest();
        colObj = HDT_LC_AccountStatementController.getTabConfiguration('EC', accountId);

        System.assertEquals(true, colObj.success, 'success != true');
        System.assert(colObj.confObj != null , 'confObj == null');
        System.assert(colObj.columnObj.size() > 0, 'columnObj.size() == 0');

        Test.stopTest();

    }

    @isTest
    static void getTabConfigurationWithFail(){

        HDT_WRP_AccountStatement.HDT_WRP_ColumnsObj colObj;

        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;

        Test.startTest();
        colObj = HDT_LC_AccountStatementController.getTabConfiguration(null, null);

        System.assertEquals(false, colObj.success, 'success != true');
        System.assert(colObj.confObj == null , 'confObj != null');
        System.assert(colObj.columnObj == null, 'columnObj != null');

        Test.stopTest();

    }

    @isTest
    static void getPicklistValue(){
        Test.startTest();

        String picklistValue = HDT_LC_AccountStatementController.getPicklistValue('EC', 'StepValues');
        System.assert(!String.isBlank(picklistValue), 'picklistValue == null');

        Test.stopTest();

    }

    @isTest
    static void getFieldValues(){
        HDT_WRP_AccountStatement.HDT_WRP_ReturnPicklist picklist;

        Test.startTest();
        picklist = HDT_LC_AccountStatementController.getFieldValues('EC');

        System.assertEquals(true, picklist.success, 'success != true');
        System.assert(String.isBlank(picklist.message), 'message != null');
        System.assert(picklist.companyList.size() > 0, 'companyList.size() == 0');
        System.assert(picklist.joinLevelList.size() > 0, 'joinLevelList.size() == 0');

        picklist = HDT_LC_AccountStatementController.getFieldValues('EC1');

        System.assertEquals(true, picklist.success, 'success != true');
        System.assert(String.isBlank(picklist.message), 'message != null');
        System.assert(picklist.companyList.size() > 0, 'companyList.size() == 0');
        System.assert(picklist.joinLevelList.size() > 0, 'joinLevelList.size() == 0');

        picklist = HDT_LC_AccountStatementController.getFieldValues('EC4');

        System.assertEquals(true, picklist.success, 'success != true');
        System.assert(String.isBlank(picklist.message), 'message != null');
        System.assert(picklist.companyList.size() > 0, 'companyList.size() == 0');
        System.assert(picklist.joinLevelList.size() > 0, 'joinLevelList.size() == 0');

        picklist = HDT_LC_AccountStatementController.getFieldValues('');

        System.assertEquals(false, picklist.success, 'success != true');
        System.assert(!String.isBlank(picklist.message), 'message == null');

        Test.stopTest();

    }

    @isTest
    static void callMulesoft(){
        Test.setMock(HttpCalloutMock.class, new HDT_LC_AccountStatementControllerTstMock());

        HDT_WRP_AccountStatement.HDT_WRP_TechObj techObj;

        List<String> tabCodes = new List<String> { 'EC' , 'EC1' , 'EC3', 'EC4', 'EC6', 'EC7', 'EC9', 'paperless', 'noCustomer'};

        List<String> requestTypeList = new List<String>();
        requestTypeList.add('home');
        requestTypeList.add('allRecentItems');
        requestTypeList.add('joinFilter');
        requestTypeList.add('filters');
        requestTypeList.add('viewResult');
        requestTypeList.add('expired');
        requestTypeList.add('creditRecovery');
        requestTypeList.add('expiredFromDay');
        requestTypeList.add('manageableItems');
        requestTypeList.add('contractService');

        Account account = [
            SELECT Id, CustomerCode__c
            FROM Account
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        Test.startTest();

        for (String code : tabCodes){

            techObj = new HDT_WRP_AccountStatement.HDT_WRP_TechObj();
            techObj.recordId = String.valueOf(account.Id);
            techObj.customerCode = 'noCustomer'.equals(code) ? '' : String.valueOf(account.CustomerCode__c);
            techObj.tabCode = code;
            techObj.statementType = 'ORDINARIO';
            techObj.aggregation = '03';
    
            String reqObj = '{"tipoTransazione":"EC2","tipoEstrattoConto":"ORDINARIO","loginId":"0-1","dataInizio":"2016-09-08","dataFine":"2021-09-08","codiceCliente":"1003616210","applicativo":"ML","aggregazione":"03"}';
    
            Object obj;
            for(String s : requestTypeList){
                techObj.requestType = s;
                obj = HDT_LC_AccountStatementController.callMulesoft(JSON.serialize(techObj, true), reqObj);
    
                System.assert(obj != null, 'obj == null');
            }

        }

        Test.stopTest();

    }

    @isTest
    static void callMulesoftFail(){

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status": "failed","correlationId": "92293250-df3b-11eb-a73c-0200a41fc6da","timestamp": "2021-07-07T17:54:13","errorDetails":[{"code":"HTTP:INTERNAL_SERVER_ERROR","message":"HTTPPOSTonresource\'http://isuprq.service.intra:8002/sap/bc/srt/rfc/sap/zurvmc_ws_estratto_letture/150/zurvmc_ws_estratto_letture/zurvmc_ws_estratto_letture\'failed:internalservererror(500).","additionalInfo":"HTTPPOSTonresource\'http://isuprq.service.intra:8002/sap/bc/srt/rfc/sap/zurvmc_ws_estratto_letture/150/zurvmc_ws_estratto_letture/zurvmc_ws_estratto_letture\'failed:internalservererror(500)."}],"data": []}');
        response.setStatusCode(200);
        response.setStatus('OK');

        Test.setMock(HttpCalloutMock.class, new HDT_LC_AccountStatementControllerTstMockFail(response));

        HDT_WRP_AccountStatement.HDT_WRP_TechObj techObj;

        List<String> tabCodes = new List<String> { 'EC' , 'EC1' , 'EC3', 'EC4', 'EC6', 'EC7', 'EC9', 'paperless', 'noCustomer'};

        List<String> requestTypeList = new List<String>();
        requestTypeList.add('home');
        requestTypeList.add('allRecentItems');
        requestTypeList.add('joinFilter');
        requestTypeList.add('filters');
        requestTypeList.add('viewResult');
        requestTypeList.add('expired');
        requestTypeList.add('creditRecovery');
        requestTypeList.add('expiredFromDay');
        requestTypeList.add('manageableItems');
        requestTypeList.add('contractService');

        Account account = [
            SELECT Id, CustomerCode__c
            FROM Account
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        Test.startTest();

        for (String code : tabCodes){

            techObj = new HDT_WRP_AccountStatement.HDT_WRP_TechObj();
            techObj.recordId = String.valueOf(account.Id);
            techObj.customerCode = 'noCustomer'.equals(code) ? '' : String.valueOf(account.CustomerCode__c);
            techObj.tabCode = code;
            techObj.statementType = 'ORDINARIO';
            techObj.aggregation = '03';
    
            String reqObj = '{"tipoTransazione":"EC2","tipoEstrattoConto":"ORDINARIO","loginId":"0-1","dataInizio":"2016-09-08","dataFine":"2021-09-08","codiceCliente":"1003616210","applicativo":"ML","aggregazione":"03"}';
    
            Object obj;
            for(String s : requestTypeList){
                techObj.requestType = s;
                obj = HDT_LC_AccountStatementController.callMulesoft(JSON.serialize(techObj, true), reqObj);
    
                System.assert(obj != null, 'obj == null');
            }

        }

        Test.stopTest();

    }

    @isTest
    static void callMulesoftFailWithStatusKO(){

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status": "failed","correlationId": "92293250-df3b-11eb-a73c-0200a41fc6da","timestamp": "2021-07-07T17:54:13","errorDetails":[{"code":"HTTP:INTERNAL_SERVER_ERROR","message":"HTTPPOSTonresource\'http://isuprq.service.intra:8002/sap/bc/srt/rfc/sap/zurvmc_ws_estratto_letture/150/zurvmc_ws_estratto_letture/zurvmc_ws_estratto_letture\'failed:internalservererror(500).","additionalInfo":"HTTPPOSTonresource\'http://isuprq.service.intra:8002/sap/bc/srt/rfc/sap/zurvmc_ws_estratto_letture/150/zurvmc_ws_estratto_letture/zurvmc_ws_estratto_letture\'failed:internalservererror(500)."}],"data": []}');
        response.setStatusCode(500);
        response.setStatus('KO');

        Test.setMock(HttpCalloutMock.class, new HDT_LC_AccountStatementControllerTstMockFail(response));

        HDT_WRP_AccountStatement.HDT_WRP_TechObj techObj;

        List<String> tabCodes = new List<String> { 'EC' , 'EC1' , 'EC3', 'EC4', 'EC6', 'EC7', 'EC9', 'paperless', 'noCustomer'};

        List<String> requestTypeList = new List<String>();
        requestTypeList.add('home');
        requestTypeList.add('allRecentItems');
        requestTypeList.add('joinFilter');
        requestTypeList.add('filters');
        requestTypeList.add('viewResult');
        requestTypeList.add('expired');
        requestTypeList.add('creditRecovery');
        requestTypeList.add('expiredFromDay');
        requestTypeList.add('manageableItems');
        requestTypeList.add('contractService');

        Account account = [
            SELECT Id, CustomerCode__c
            FROM Account
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        Test.startTest();

        for (String code : tabCodes){

            techObj = new HDT_WRP_AccountStatement.HDT_WRP_TechObj();
            techObj.recordId = String.valueOf(account.Id);
            techObj.customerCode = 'noCustomer'.equals(code) ? '' : String.valueOf(account.CustomerCode__c);
            techObj.tabCode = code;
            techObj.statementType = 'ORDINARIO';
            techObj.aggregation = '03';
    
            String reqObj = '{"tipoTransazione":"EC2","tipoEstrattoConto":"ORDINARIO","loginId":"0-1","dataInizio":"2016-09-08","dataFine":"2021-09-08","codiceCliente":"1003616210","applicativo":"ML","aggregazione":"03"}';
    
            Object obj;
            for(String s : requestTypeList){
                techObj.requestType = s;
                obj = HDT_LC_AccountStatementController.callMulesoft(JSON.serialize(techObj, true), reqObj);
    
                System.assert(obj != null, 'obj == null');
            }

        }

        Test.stopTest();

    }

    @isTest
    static void serviceCatalogBackendHandler(){
        HDT_WRP_AccountStatement.HDT_WRP_ServiceCatalogResponse serviceCatalogResponse;
        Account account = [SELECT Id, CustomerCode__c FROM Account LIMIT 1];

        List<HDT_WRP_AccountStatement.HDT_WRP_DeserializeObj> objList = new List<HDT_WRP_AccountStatement.HDT_WRP_DeserializeObj>();
        HDT_WRP_AccountStatement.HDT_WRP_DeserializeObj obj1 = new HDT_WRP_AccountStatement.HDT_WRP_DeserializeObj();
        obj1.contoContrattuale = '200001846232';
        obj1.rateizzato = 'NO';
        obj1.numeroFattura = '0000411810643841';
        obj1.residuo = '0.0';
        obj1.societa = 'Hera Comm S.p.A.';
        obj1.fatturaPrescrivibile = 'testString';
        obj1.fatturaPrescritta = 'testString';
        //obj1.DEL_569 = 'testString';
        obj1.documentoPareggio = 'testString';
        obj1.secondoLivelloInformativo = new List<HDT_WRP_AccountStatement.HDT_WRP_SecondLevelObj>();
        obj1.secondoLivelloInformativo.add(new HDT_WRP_AccountStatement.HDT_WRP_SecondLevelObj());

        HDT_WRP_AccountStatement.HDT_WRP_DeserializeObj obj2 = new HDT_WRP_AccountStatement.HDT_WRP_DeserializeObj();
        obj2.contoContrattuale = '200001846232';
        obj2.rateizzato = 'NO';
        obj2.numeroFattura = '0000411810643841';
        obj2.residuo = '0.0';
        obj2.societa = 'Hera Comm S.p.A.';
        obj2.fatturaPrescrivibile = 'testString';
        obj2.fatturaPrescritta = 'testString';
        //obj2.DEL_569 = 'testString';
        obj2.documentoPareggio = 'testString';
        obj2.secondoLivelloInformativo = new List<HDT_WRP_AccountStatement.HDT_WRP_SecondLevelObj>();
        obj2.secondoLivelloInformativo.add(new HDT_WRP_AccountStatement.HDT_WRP_SecondLevelObj());

        HDT_WRP_AccountStatement.HDT_WRP_DeserializeObj obj3 = new HDT_WRP_AccountStatement.HDT_WRP_DeserializeObj();
        obj3.contoContrattuale = '200001846232';
        obj3.rateizzato = 'NO';
        obj3.numeroFattura = '0000411810643841';
        obj3.residuo = '0.0';
        obj3.societa = 'Hera Comm S.p.A.';
        obj3.fatturaPrescrivibile = 'testString';
        obj3.fatturaPrescritta = 'testString';
        //obj3.DEL_569 = 'testString';
        obj3.documentoPareggio = 'testString';
        obj3.secondoLivelloInformativo = new List<HDT_WRP_AccountStatement.HDT_WRP_SecondLevelObj>();
        obj3.secondoLivelloInformativo.add(new HDT_WRP_AccountStatement.HDT_WRP_SecondLevelObj());

        Test.startTest();
        objList.add(obj1);
        serviceCatalogResponse = HDT_LC_AccountStatementController.serviceCatalogBackendHandler('EC', account.Id, JSON.serialize(objList, true), '1');

        System.assertEquals(true, serviceCatalogResponse.success, 'success != true');
        System.assert(!String.isBlank(serviceCatalogResponse.serviceCatalogId), 'serviceCatalogId == null');

        objList.add(obj2);
        serviceCatalogResponse = HDT_LC_AccountStatementController.serviceCatalogBackendHandler('EC', account.Id, JSON.serialize(objList, true), '1');

        System.assertEquals(true, serviceCatalogResponse.success, 'success != true');
        System.assert(!String.isBlank(serviceCatalogResponse.serviceCatalogId), 'serviceCatalogId == null');

        objList.add(obj3);
        serviceCatalogResponse = HDT_LC_AccountStatementController.serviceCatalogBackendHandler('EC4', account.Id, JSON.serialize(objList, true), '2');

        System.assertEquals(false, serviceCatalogResponse.success, 'success != false');
        System.assert(String.isBlank(serviceCatalogResponse.serviceCatalogId), 'serviceCatalogId != null');

        objList.add(obj3);
        serviceCatalogResponse = HDT_LC_AccountStatementController.serviceCatalogBackendHandler('EC7', account.Id, JSON.serialize(objList, true), '1');

        System.assertEquals(true, serviceCatalogResponse.success, 'success != true');
        System.assert(!String.isBlank(serviceCatalogResponse.serviceCatalogId), 'serviceCatalogId != null');

        Test.stopTest();
    }

    @isTest
    static void HDT_WRP_AccountStatement(){
        HDT_WRP_AccountStatement.HDT_WRP_ConfTabObjDetail confTabObjDetail = new HDT_WRP_AccountStatement.HDT_WRP_ConfTabObjDetail();
        confTabObjDetail.recordCode = '';
        confTabObjDetail.customerCode = '';
        confTabObjDetail.tabCode = '';
        confTabObjDetail.hasSecondLevel = true;
        confTabObjDetail.hasAmountField = true;
        confTabObjDetail.secondLevelApiName = '';
        confTabObjDetail.buttonList = new List<HDT_WRP_AccountStatement.HDT_WRP_ButtonObjDetail>();
    
        HDT_WRP_AccountStatement.HDT_WRP_ButtonObjDetail buttonObjDetail = new HDT_WRP_AccountStatement.HDT_WRP_ButtonObjDetail('', '', true, '', '');
        HDT_WRP_AccountStatement.HDT_WRP_ButtonObjDetail buttonObjDetail2 = new HDT_WRP_AccountStatement.HDT_WRP_ButtonObjDetail('', '', true, '', '', '');
    
        HDT_WRP_AccountStatement.HDT_WRP_ColumnsObj columnsObj = new HDT_WRP_AccountStatement.HDT_WRP_ColumnsObj();
        columnsObj.success = true;
        columnsObj.message = '';
        columnsObj.confObj = new HDT_WRP_AccountStatement.HDT_WRP_ConfTabObjDetail();
    
    }

    public class HDT_LC_AccountStatementControllerTstMockFail implements HttpCalloutMock{
        HttpResponse response;
        HDT_LC_AccountStatementControllerTstMockFail(HttpResponse r){
            response = r;
        }
        public HTTPResponse respond(HTTPRequest request) {
            return response; 
        }
    
    }

}