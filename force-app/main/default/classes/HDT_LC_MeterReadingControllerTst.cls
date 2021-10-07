@isTest
public class HDT_LC_MeterReadingControllerTst {

    @testSetup
    static void setup() {

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(2, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<ServicePoint__c> servList =  HDT_UTL_DataFactoryTst.createServicePoint(1, true);

        Account acc = accList.get(0);
        ServicePoint__c servPoint = servList.get(0);
        servPoint.SAPImplantCode__c = '001';
        servPoint.CommoditySector__c = 'Gas';
        servPoint.MeterSN__c = 'example';

        update servPoint;

        List<Contract> contrList = HDT_UTL_DataFactoryTst.createContract(1, true, acc.Id);

        Contract contr = contrList.get(0);
        contr.Status = 'In Approval Process';
        contr.ServicePoint__c = servPoint.Id;

        update contr;

        accList.get(1).BillingCityCode__c = 'Genova';
        update accList;


    }

    @isTest
    public static void getConfigurationData(){
        HDT_WRP_MeterReading.HDT_WRP_ColumnsMetadata columnsMetadata;

        Test.startTest();
        columnsMetadata = HDT_LC_MeterReadingController.getConfigurationData();

        System.assertEquals(true, columnsMetadata.success, 'Si è verificato un errore non previsto');
        System.assert(!String.isBlank(columnsMetadata.contractTable), 'Si è verificato un errore in fase di scaricamento dei records');
        System.assert(!String.isBlank(columnsMetadata.meterReadingTable), 'Si è verificato un errore in fase di scaricamento dei records');

        Test.stopTest();
    }

    @isTest
    public static void getContractRecords(){
        HDT_WRP_MeterReading.HDT_WRP_ContractObj contractObj ;

        Account account = [
            SELECT Id, CustomerCode__c
            FROM Account
            WHERE BillingCityCode__c <> 'Genova'
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        Contract contr = [SELECT Id, SAPContractCode__c, Status, EndDate, StartDate, ServicePoint__r.CommoditySector__c, ServicePoint__r.SAPImplantCode__c,
        ServicePoint__r.MeterSN__c, ServicePoint__r.ServicePointCode__c
        FROM Contract WHERE AccountId = :account.Id];

        Test.startTest();
        contractObj = HDT_LC_MeterReadingController.getContractRecords(account.Id);

        System.assertEquals(true, contractObj.success, 'Si è verificato un errore non previsto');
        System.assert(contractObj.contractList.size() > 0, 'Si è verificato un errore in fase di scaricamento dei records');

        Test.stopTest();
    }

    @isTest
    public static void getContractRecordsWithFail(){
        HDT_WRP_MeterReading.HDT_WRP_ContractObj contractObj ;

        Account account = [
            SELECT Id, CustomerCode__c
            FROM Account
            WHERE BillingCityCode__c = 'Genova'
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        Test.startTest();
        contractObj = HDT_LC_MeterReadingController.getContractRecords(account.Id);

        System.assertEquals(false, contractObj.success, 'success != false');
        System.assert(contractObj.contractList == null, 'contractList != null');

        Test.stopTest();
    }

    @isTest
    public static void getMeterReadingRecords(){

        HDT_WRP_MeterReading.HDT_WRP_MeterReadingObj meterReadingObj;

        Test.setMock(HttpCalloutMock.class, new HDT_LC_MeterReadingControllerTstMock());
        Test.startTest();
        meterReadingObj = HDT_LC_MeterReadingController.getMeterReadingRecords('1006689293');

        System.assertEquals(true, meterReadingObj.success, 'Si è verificato un errore non previsto');
        System.assert(meterReadingObj.data != null, 'Si è verificato un errore in fase di scaricamento dei records');

        Test.stopTest();
    }

    @isTest
    public static void getMeterReadingRecordsFail(){

        HDT_WRP_MeterReading.HDT_WRP_MeterReadingObj meterReadingObj;

         // Create a fake response
        HttpResponse response = new HttpResponse();    
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status":"failed","correlationId":"a61cf360-1086-11ec-bf14-0262fe5f28a6","timestamp":"2021-09-08T11:25:04","errorDetails":[{"code":"HTTP:INTERNAL_SERVER_ERROR","message":"HTTPPOSTonresource\'http://isuprq.service.intra:8002/sap/bc/srt/rfc/sap/zurvmc_ws_estratto_letture/150/zurvmc_ws_estratto_letture/zurvmc_ws_estratto_letture\'failed:internalservererror(500).","additionalInfo":"HTTPPOSTonresource\'http://isuprq.service.intra:8002/sap/bc/srt/rfc/sap/zurvmc_ws_estratto_letture/150/zurvmc_ws_estratto_letture/zurvmc_ws_estratto_letture\'failed:internalservererror(500)."}]}');
        response.setStatusCode(500); 
        response.setStatus('OK');

        Test.setMock(HttpCalloutMock.class, new HDT_LC_MeterReadingControllerTstMockFail(response));

        Test.startTest();
        meterReadingObj = HDT_LC_MeterReadingController.getMeterReadingRecords('1006689293');

        System.assertEquals(false, meterReadingObj.success, 'success != false');
        System.assert(meterReadingObj.data == null, 'data != null');

        //Caso con HTTP STATUS KO
        response.setStatusCode(500); 
        response.setStatus('KO');

        Test.setMock(HttpCalloutMock.class, new HDT_LC_MeterReadingControllerTstMockFail(response));

        meterReadingObj = HDT_LC_MeterReadingController.getMeterReadingRecords('1006689293');

        System.assertEquals(false, meterReadingObj.success, 'success != false');
        System.assert(meterReadingObj.data == null, 'data != null');

        Test.stopTest();
    }

    @isTest
    public static void getAccountDataEnrichment(){

        Test.startTest();

        List<HDT_AccountDataEnrichment__mdt> contractMetadataList;
        contractMetadataList = HDT_QR_AccountDataEnrichment.getAccountDataEnrichment(contractMetadataList, 'contract');
        System.assert(contractMetadataList.size() > 0, 'Si è verificato un errore in fase di scaricamento dei records');
    
        Test.stopTest();
        
    }

    @isTest
    public static void getAccountDataEnrichmentMeterReading(){

        Test.startTest();

        List<HDT_AccountDataEnrichment__mdt> contractMetadataList;
        contractMetadataList = HDT_QR_MeterReading.getAccountDataEnrichment(contractMetadataList, 'contract');
        System.assert(contractMetadataList.size() > 0, 'Si è verificato un errore in fase di scaricamento dei records');
    
        Test.stopTest();
        
    }

    public class HDT_LC_MeterReadingControllerTstMockFail implements HttpCalloutMock{
        HttpResponse response;
        HDT_LC_MeterReadingControllerTstMockFail(HttpResponse r){
            response = r;
        }
        public HTTPResponse respond(HTTPRequest request) {
            return response; 
        }
    
    }

}