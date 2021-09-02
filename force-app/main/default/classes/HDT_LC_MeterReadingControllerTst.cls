@isTest
public class HDT_LC_MeterReadingControllerTst {

    @testSetup
    static void setup() {

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
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
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        Contract contr = [SELECT Id, SAPContractCode__c, Status, EndDate, StartDate, ServicePoint__r.CommoditySector__c, ServicePoint__r.SAPImplantCode__c,
        ServicePoint__r.MeterSN__c, ServicePoint__r.ServicePointCode__c
        FROM Contract WHERE AccountId = :account.Id];

        Test.startTest();
        contractObj = HDT_LC_MeterReadingController.getContractRecords(account.Id);

        System.assertEquals(true, contractObj.success, 'Si è verificato un errore non previsto');
        System.assert(contractObj.contractList != null, 'Si è verificato un errore in fase di scaricamento dei records');

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
    public static void getAccountDataEnrichment(){

        Test.startTest();

        List<HDT_AccountDataEnrichment__mdt> contractMetadataList;
        contractMetadataList = HDT_QR_AccountDataEnrichment.getAccountDataEnrichment(contractMetadataList, 'contract');
        System.assert(contractMetadataList != null, 'Si è verificato un errore in fase di scaricamento dei records');
    
        Test.stopTest();
        
    }

}