@isTest
public class HDT_LC_MeterReadingControllerTst {

    @testSetup
    static void setup() {
        Account a = new Account();
        a.CustomerCode__c = '1006689293';
        a.Name = 'accountTest';
        insert a;
    }

    @isTest
    public static void getConfigurationData(){
        HDT_WRP_MeterReading.HDT_WRP_ColumnsMetadata columnsMetadata;

        Test.startTest();
        columnsMetadata = HDT_LC_MeterReadingController.getConfigurationData();
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

        ServicePoint__c sp = new ServicePoint__c();
        sp.SAPImplantCode__c = '001';
        sp.CommoditySector__c = 'Gas';
        sp.MeterSN__c = 'example';
        sp.ServicePointCode__c = 'servicePointCode';
        insert sp;

        Contract c = new Contract();
        c.SAPContractCode__c = 'sapCode';
        c.Status = 'Draft';
        c.StartDate = Date.today();
        c.EndDate = Date.today().addDays(1);
        c.ServicePoint__c = sp.Id;
        c.AccountId = account.Id;
        insert c;

        c.Status = 'In Approval Process';
        update c;

        Test.startTest();
        contractObj = HDT_LC_MeterReadingController.getContractRecords(account.Id);
        Test.stopTest();
    }

    @isTest
    public static void getMeterReadingRecords(){

        HDT_WRP_MeterReading.HDT_WRP_MeterReadingObj meterReadingObj;

        Test.setMock(HttpCalloutMock.class, new HDT_LC_MeterReadingControllerTstMock());
        Test.startTest();
        meterReadingObj = HDT_LC_MeterReadingController.getMeterReadingRecords('1006689293');
        Test.stopTest();
    }

    @isTest
    public static void getAccountDataEnrichment(){
        List<HDT_AccountDataEnrichment__mdt> contractMetadataList;
        contractMetadataList = HDT_QR_AccountDataEnrichment.getAccountDataEnrichment(contractMetadataList, 'contract');
    }

}