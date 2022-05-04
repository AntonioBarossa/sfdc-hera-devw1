/**
 * @author Fabio Palladino, fabio.palladino@nttdata.com
 * @version 1.0
 * @description: classe di test per il batch HDT_BA_EventLogToTableau.
 * Non è possibile inserire degli assert 
 * @history
 * @Created 01/05/2022
 * Modified By:
 **/
@isTest
public with sharing class HDT_BA_EventLogToTableauTst {
    @isTest static void eventLogTst() {        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HDT_BA_EventLogToTableauTstMock());
        Id batchJobId = Database.executeBatch(new HDT_BA_EventLogToTableau('EventLog'), 20);
        Test.stopTest();
        // Check result
        AsyncApexJob aaj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: batchJobId ];
        System.assertEquals('Completed', aaj.Status, 'HDT_BA_EventLogToTableau batch Fails ');
    }
    
    @isTest static void platformLimitstst() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HDT_BA_EventLogToTableauTstMock());
        Id batchJobId = Database.executeBatch(new HDT_BA_EventLogToTableau('PlatformLimits'), 20);
        Test.stopTest();
        // Check result
        AsyncApexJob aaj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: batchJobId ];
        System.assertEquals('Completed', aaj.Status, 'HDT_BA_EventLogToTableau batch Fails ');  
    }

    public class HDT_BA_EventLogToTableauTstMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"DataStorageMB":{"Max":"1000", "Remaining":"10"},'+
                             '"FileStorageMB":{"Max":"1000", "Remaining":"10"},'+
                             '"DailyBulkApiBatches":{"Max":"1000", "Remaining":"10"},'+   
                             '"HourlyODataCallout":{"Max":"1000", "Remaining":"10"},'+   
                             '"HourlyTimeBasedWorkflow":{"Max":"1000", "Remaining":"10"},'+   
                             '"DailyApiRequests":{"Max":"1000", "Remaining":"10"}}');
            response.setStatusCode(201);
            response.setStatus('OK');
            return response; 
        }
    }
}