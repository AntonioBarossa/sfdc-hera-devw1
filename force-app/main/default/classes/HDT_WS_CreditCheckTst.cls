/**
 * @author Valere (valere@noeli-it.net)
 * @date 29/09/2021
 * @description HDT_WS_CreditCheck Test Class
 * @history valere - 29/09/2021– Created Class
 */
@isTest
private class HDT_WS_CreditCheckTst {

	@testSetup 
    static void setup() {
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration ('CreditCheck', 'endpoint', 'method', 'Other');
    }
    
    @isTest 
    static void testCallService() {


        Test.setMock(HttpCalloutMock.class, new HDT_WS_CreditCheckHttpCalloutMock()); 
        Test.startTest();

        String wrpVals = '{\n' +
        ' "sistema" :"sistema",\n' +
        ' "caso" :"caso",\n' +
        ' "crmEntity" :"crmEntity",\n' +
        ' "crmId" :"crmId",\n' +
        ' "userId" :"userId",\n' +
        ' "activationUser" :"activationUser",\n' +
        ' "account" :"account",\n' +
        ' "jobTitle" :"jobTitle",\n' +
        ' "internalCustomerId" :"internalCustomerId",\n' +
        ' "companyName" :"companyName",\n' +
        ' "externalCustomerId" :"externalCustomerId",\n' +
        ' "secondaryCustomerId" :"secondaryCustomerId",\n' +
        ' "bpClass" :"bpClass",\n' +
        ' "bpCategory" :"bpCategory",\n' +
        ' "bpType" :"bpType",\n' +
        ' "customerType" :"customerType",\n' +
        ' "address" :"address",\n' +
        ' "municipality" :"municipality",\n' +
        ' "district" :"district",\n' +
        ' "postCode" :"postCode",\n' +
        ' "operation" :"operation",\n' +
        ' "companyGroup" :"companyGroup",\n' +
        ' "market" :"market",\n' +
        ' "offerType" :"offerType",\n' +
        ' "bpAlternative" :"bpAlternative",\n' +
        ' "alternativeCustomerId" :"alternativeCustomerId",\n' +
        ' "details" : [{ "annualConsumption":"annualConsumption", ' + 
                        '"commodity":"commodity", ' + 
                        '"totalConsumption":"totalConsumption" },'+

                        '{ "annualConsumption":"annualConsumption", ' + 
                        '"commodity":"commodity", ' + 
                        '"totalConsumption":"totalConsumption" } ]\n' +

        '}';

        HDT_WS_CreditCheckRequest req = (HDT_WS_CreditCheckRequest)json.deserialize(wrpVals, HDT_WS_CreditCheckRequest.class);
        HDT_WS_CreditCheckResponse creditCheckResponse = HDT_WS_CreditCheck.callService(req);
        
        Test.stopTest();
    

        System.assertEquals('code', creditCheckResponse.errorDetails[0].code, 'the sendRequest method of the HDT_WS_HTTPServiceCall class returns an array , the first element of this array has  a code that has the value code');
        System.assertNotEquals('code2', creditCheckResponse.errorDetails[0].code, 'the sendRequest method of the HDT_WS_HTTPServiceCall class returns an array , the first element of this array has  a code that has the value code');
       
    }
}