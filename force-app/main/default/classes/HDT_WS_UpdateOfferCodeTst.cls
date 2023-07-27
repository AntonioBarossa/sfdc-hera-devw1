@isTest
public with sharing class HDT_WS_UpdateOfferCodeTst {

    @TestSetup
    static void setup(){
        List<Account> accountList= HDT_UTL_DataFactoryTst.createAccountResidenziale(1,true,'HERA COMM','Persona fisica','Famiglie');
        List<Contract> listOfContract = HDT_UTL_DataFactoryTst.createContract(1, true, accountList[0].Id);
        listOfContract[0].Status = 'Attivo';
        update listOfContract;
    }

    @isTest
    static void insertOfferLog (){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'services/apexrest/offercode32';
        req.httpMethod = 'POST';
        List<Contract> listOfContract = new List<Contract>([SELECT Id, SAPContractCode__c FROM Contract ]);
        HDT_WRP_UpdateOfferCode.HDT_WRP_UpdateOfferCodeRequest requestWrap = new HDT_WRP_UpdateOfferCode.HDT_WRP_UpdateOfferCodeRequest();
        HDT_WRP_UpdateOfferCode.HDT_WRP_UpdateOfferCodeData data = new HDT_WRP_UpdateOfferCode.HDT_WRP_UpdateOfferCodeData();
        data.sapContractCode = listOfContract[0].SAPContractCode__c;
        data.pod = 'Test';
        data.offerCode = 'Test';
        data.profile = 'Test';
        data.commodity = 'Energia Elettrica';
        data.effectiveDate = '2023-07-24';
        data.codTzero = 'Y';
        data.causalCode = 'Test';
        data.effectiveMonths = '12';
        requestWrap.method = 'update';
        requestWrap.data = new List<HDT_WRP_UpdateOfferCode.HDT_WRP_UpdateOfferCodeData> {data};

        req.requestBody = Blob.valueOf(JSON.serialize(requestWrap));

        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
            HDT_WS_UpdateOfferCode.doPost();
        Test.stopTest();
        System.assertEquals(200, RestContext.response.statusCode);
    }

    @isTest
    static void exceededLimitOfInsertObject (){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'services/apexrest/offercode32';
        req.httpMethod = 'POST';
        HDT_WRP_UpdateOfferCode.HDT_WRP_UpdateOfferCodeRequest requestWrap = new HDT_WRP_UpdateOfferCode.HDT_WRP_UpdateOfferCodeRequest();
        List<HDT_WRP_UpdateOfferCode.HDT_WRP_UpdateOfferCodeData> listOfData = new List<HDT_WRP_UpdateOfferCode.HDT_WRP_UpdateOfferCodeData>();
        for(Integer i = 0; i<= Integer.valueOf(Label.HDT_OfferCodeMaxItem)+1;i++){
            HDT_WRP_UpdateOfferCode.HDT_WRP_UpdateOfferCodeData data = new HDT_WRP_UpdateOfferCode.HDT_WRP_UpdateOfferCodeData();
            data.sapContractCode = '01234232332';
            data.pod = 'Test';
            data.offerCode = 'Test';
            data.profile = 'Test';
            data.commodity = 'Energia Elettrica';
            data.effectiveDate = '2023-07-24';
            data.codTzero = 'Y';
            data.causalCode = 'Test';
            data.effectiveMonths = '12';
            listOfData.add(data);
        }
        
        requestWrap.method = 'update';
        requestWrap.data = listOfData;

        req.requestBody = Blob.valueOf(JSON.serialize(requestWrap));

        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
            HDT_WS_UpdateOfferCode.doPost();
        Test.stopTest();
        System.assertEquals(200, RestContext.response.statusCode);
    }

    @isTest
    static void noActiveContractFound (){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'services/apexrest/offercode32';
        req.httpMethod = 'POST';
        HDT_WRP_UpdateOfferCode.HDT_WRP_UpdateOfferCodeRequest requestWrap = new HDT_WRP_UpdateOfferCode.HDT_WRP_UpdateOfferCodeRequest();
        HDT_WRP_UpdateOfferCode.HDT_WRP_UpdateOfferCodeData data = new HDT_WRP_UpdateOfferCode.HDT_WRP_UpdateOfferCodeData();
        data.sapContractCode = '012013232032';
        data.pod = 'Test';
        data.offerCode = 'Test';
        data.profile = 'Test';
        data.commodity = 'Energia Elettrica';
        data.effectiveDate = '2023-07-24';
        data.codTzero = 'Y';
        data.causalCode = 'Test';
        data.effectiveMonths = '12';
        requestWrap.method = 'update';
        requestWrap.data = new List<HDT_WRP_UpdateOfferCode.HDT_WRP_UpdateOfferCodeData> {data};

        req.requestBody = Blob.valueOf(JSON.serialize(requestWrap));

        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
            HDT_WS_UpdateOfferCode.doPost();
        Test.stopTest();
        System.assertEquals(200, RestContext.response.statusCode);
    }


    @isTest
    static void catchDeserializeRequest (){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'services/apexrest/offercode32';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize('Test'));

        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
            HDT_WS_UpdateOfferCode.doPost();
        Test.stopTest();
        System.assertEquals(500, RestContext.response.statusCode);
    }

}