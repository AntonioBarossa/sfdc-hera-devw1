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

        Test.startTest();
        contractObj = HDT_LC_MeterReadingController.getContractRecords(account.Id);
        Test.stopTest();
    }

    @isTest
    public static void getMeterReadingRecords(){

        HDT_WRP_MeterReading.HDT_WRP_MeterReadingObj meterReadingObj;

        Test.startTest();
        meterReadingObj = HDT_LC_MeterReadingController.getMeterReadingRecords('1006689293');
        Test.stopTest();
    }

}