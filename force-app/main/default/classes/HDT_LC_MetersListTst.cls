@isTest
public class HDT_LC_MetersListTst {

    //TEST SETUP
    @testSetup
    static void setup() {

        ServicePoint__c servPoint=new ServicePoint__c();
        servPoint.Name='testServicePoint';
        servPoint.ServicePointCode__c='testServicePointCode';
        insert servPoint;
		//servPoint.RecordTypeId = utlConstants.SERVICEPOINT_RECORDTYPEID_PELETRICCO;

    }

    @isTest
    public static void getDatatableStructure() {
        Object o = HDT_LC_MetersList.getDatatableStructure();
        List<HDT_MetersListColumnTable__mdt> metersListColumnTable = [
            SELECT DeveloperName, MasterLabel
            FROM HDT_MetersListColumnTable__mdt
            ORDER BY Order__c
        ];

        HDT_WRP_MetersList.HDT_WRP_Table tableObj = (HDT_WRP_MetersList.HDT_WRP_Table)o;
        System.assertEquals(metersListColumnTable.size(), tableObj.columnList.size());
    }

    @isTest
    public static void testWebService() {

        ServicePoint__c sp = [
            SELECT Id, Name, ServicePointCode__c
            FROM ServicePoint__c
            LIMIT 1
        ];

        Test.startTest();

        Continuation conti = (Continuation)HDT_LC_MetersList.startRequest(sp.Id);
        
        // Verify that the continuation has the proper requests
        Map<String, HttpRequest> requests = conti.getRequests();
        System.assert(requests.size() == 1, 'requests.size() != 1');

        HttpResponse response = new HttpResponse();
        response.setBody('Mock response body');   
        
        // Set the fake response for the continuation     
        Test.setContinuationResponse('Continuation-1', response);

        // Invoke callback method
        Object result = HDT_LC_MetersList.processResponse(new List<String>{'Continuation-1'}, null);
        
        System.assert(result != null, 'result == null');

        Test.stopTest();
    }

}