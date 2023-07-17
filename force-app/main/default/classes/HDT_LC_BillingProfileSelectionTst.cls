@isTest
public class HDT_LC_BillingProfileSelectionTst {
    
    @TestSetup
    static void setup(){
        
    }

    @IsTest
    static void testGetConfiguration(){
        
        Test.startTest();

        String searchKey = 'BillingProfile';

        String results = HDT_LC_BillingProfileSelection.getConfiguration(searchKey);

        List<HDT_Generic_Record_Selection__mdt> configList = (List<HDT_Generic_Record_Selection__mdt>) JSON.deserialize(results, List<HDT_Generic_Record_Selection__mdt>.class);

        System.assert(configList.size() > 0, 'configList.size() = 0 or configList = null');
        System.assertNotEquals(null, configList[0].Columns__c, 'Columns__c = null');

        Test.stopTest();
        
    }

    @IsTest
    static void handleNewBillingProfile(){
        //Creo l'Account Residenziale
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountResidenziale(1, false, 'MMS', 'G1 - MMS Persona fisica','Famiglie');
        accList[0].FiscalCode__c = 'BTQTVM40E24A562P';
        insert accList;
        Id accountId = accList[0].Id;

        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accountId, null, null, null, null);

        //Creo il BillingProfile
        List<BillingProfile__c> bpList = HDT_UTL_DataFactoryTst.createBillingProfile(1,false,accountId);
        insert bpList;
        Id bpId = bpList[0].Id;
        Test.setMock(HTTPCalloutMock.class, new HDT_WS_TestMock());
        Test.startTest();
        String results = HDT_LC_BillingProfileSelection.handleNewBillingProfile(bpId,accountId,caseList[0].Id);
        Test.stopTest();
    }
    class HDT_WS_TestMock implements HTTPCalloutMock
    {
        public HttpResponse respond(HttpRequest request)
        {
            String body = '{"status": "success","correlationId": "0060ea20-37f5-11ed-ba57-0233fc6d39bc","timestamp": "2022-09-19T10:28:13","data": {"codiceCausale": "BPC","tipoAttivita": "OK","commenti": "BP rilevato","codiceBP": "100000001","codiceBPAlternativo":"200000001"}}';
            
            HttpResponse result = new HttpResponse();
            result.setStatusCode(200);
            result.setStatus('success');
            result.setBody(body);
            result.setHeader('Content-Type', 'application/json');

            return result;
        }
    }
}
