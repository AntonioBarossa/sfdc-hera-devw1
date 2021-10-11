@isTest
public class HDT_LC_LastBillTst {

    @testSetup
    static void setup() {
        KpiTracking__c kpi = new KpiTracking__c();
        kpi.LastBillAmount__c = 10;
        kpi.LastBillNumber__c = '101';
        kpi.LastBillExpirationDate__c = Date.today();
        kpi.LastBillPaymentStatus__c = 'PAGATA';
        kpi.LastBillCommodity__c = '{"Energia elettrica":"true"}';
        kpi.LastBillLastUpdate__c = Date.today();
        insert kpi;
    }

    @isTest
    static void getData(){

        KpiTracking__c kpi = [SELECT Id FROM KpiTracking__c LIMIT 1];
        HDT_LC_LastBill.getData('accountCode', 'mode', kpi.Id);

    }

    @isTest
    static void updateKpiTracking(){

        Map<String,String> mapping = new Map<String,String>();
        mapping.put('commodity', '{"Energia elettrica":"true"}');
        mapping.put('billStatus', 'PAGATA');
        mapping.put('expiredDate', String.valueOf(Date.today()));
        mapping.put('billNumber', '101');
        mapping.put('amount', '10');

        String result = JSON.serialize(mapping);

        KpiTracking__c kpi = [SELECT Id FROM KpiTracking__c LIMIT 1];
        HDT_LC_LastBill.updateKpiTracking(result, kpi.Id);

    }
    
    @isTest
    public static void testWebService() {

        KpiTracking__c kpi = [SELECT Id FROM KpiTracking__c LIMIT 1];

        HDT_LC_LastBill controller = new HDT_LC_LastBill();
        // Invoke the continuation by calling the action method
        Continuation conti = (Continuation)HDT_LC_LastBill.startRequest('accountCode', 'mode', kpi.Id);
        // Verify that the continuation has the proper requests
        Map<String, HttpRequest> requests = conti.getRequests();
        system.assert(requests.size() == 1);
        //system.assert(requests.get(controller.requestLabel) != null);
        
        // Perform mock callout 
        // (i.e. skip the callout and call the callback method)
        
        HttpResponse response = new HttpResponse();
        response.setBody('Mock response body');
        
        // Set the fake response for the continuation
        Test.setContinuationResponse('Continuation-1', response);
        
        // Invoke callback method
        Object result = HDT_LC_LastBill.processResponse(new List<String>{'Continuation-1'}, null);
        
        // result is the return value of the callback
        System.assertEquals(null, result);
        
        // Verify that the controller's result variable
        //   is set to the mock response.
        //System.assertEquals('Mock response body', controller.result);
    }

}