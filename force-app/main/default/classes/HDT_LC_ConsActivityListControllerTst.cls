@isTest
public with sharing class HDT_LC_ConsActivityListControllerTst {
    private static String type = 'consumptionList2g';
    private static String requestObj = '{"contractCode":"3029324331","date":"2023-05-17","idAggregation":"D"}';
    @TestSetup
    static void setup(){
        HttpResponse res = new HttpResponse();
    }

    @IsTest
    static void getTableConfig(){
        Test.startTest();
        HDT_LC_ConsActivityListController.getTableConfig(type);
        Test.stopTest();
    }

    @IsTest
    static void startRequest(){
        Test.startTest();
        HDT_LC_ConsActivityListController.startRequest(type, requestObj);
        Test.stopTest();
    }

    @IsTest
    static void processResponse(){
        String mockResponseBody = 'TestBodyResponse';
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"DataStorageMB":{"Max":"1000", "Remaining":"10"},'+
                         '"FileStorageMB":{"Max":"1000", "Remaining":"10"},'+
                         '"DailyBulkApiBatches":{"Max":"1000", "Remaining":"10"},'+   
                         '"HourlyODataCallout":{"Max":"1000", "Remaining":"10"},'+   
                         '"HourlyTimeBasedWorkflow":{"Max":"1000", "Remaining":"10"},'+   
                         '"DailyApiRequests":{"Max":"1000", "Remaining":"10"}}');
        response.setStatusCode(200);
        response.setStatus('OK');
        Test.startTest();
        //String label = JSON.serialize(response);
        List<String> labels = new List<String>();
        labels.add('itsok');
        HDT_LC_ConsActivityListController.processResponse(labels, response.getStatus());
        Test.stopTest();
    }

}