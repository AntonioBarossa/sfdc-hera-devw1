/*

{
  "phoneNumber" : "3287777777",
  "fiscalCode" : "BRRSMN81T22I459C",
  "clientTypology" : "Domestico",
  "contactName" : "Simone tortora",
  "streetCode" : "041044811157",
  "city" : "PESARO",
  "street" : "VIALE VENTIQUATTRO MAGGIO",
  "streetNumber" : "16",
  "typeInt" : "Ingombr+RAEE_NOAPP-IURD0033",
  "requestCode" : "11111",
  "materialDescription" : "Prodotto 1: Valigia varie tipologie"
}


*/
@isTest
public with sharing class HDT_WS_GarbageManTest {

	private static final String JSON_REQUEST = '{"phoneNumber":"3287777777","fiscalCode":"BRRSMN81T22I459C","clientTypology":"Domestico","contactName":"Simone tortora","streetCode":"041044811157","city":"PESARO","street":"VIALE VENTIQUATTRO MAGGIO","streetNumber":"16","typeInt":"Ingombr+RAEE_NOAPP-IURD0033","requestCode":"11111","materialDescription":"Prodotto 1: Valigia varie tipologie"}';

	@isTest
    public static void testCalloutOk() {

        //test
        Test.startTest();

        //setup for test
        RestRequest req = new RestRequest();
        RestResponse restResp = new RestResponse();

        String reqString = JSON_REQUEST;
        req.requestURI = 'services/apexrest/rifiutologo';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(reqString);

        RestContext.request = req;
        RestContext.response = restResp;

        //call webservice method
        HDT_WS_GarbageMan.HDT_WRP_WasteDisposalResponse res = HDT_WS_GarbageMan.handleWasteDisposalFromApp();
		system.assertEquals(
			'Y',
			res.requestInCharge,
			'Test Callout returned negative'
		);
        HDT_WS_GarbageMan waGar = new HDT_WS_GarbageMan();
        Test.StopTest();
    }

	@isTest
	public static void testCalloutKo() {

		List<Account> accs = HDT_UTL_DataFactoryTst.createAccountResidenziale(1, false, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
		system.debug('CODICE FISCALE '+accs[0].FiscalCode__c);
		accs[0].FiscalCode__c = accs[0]?.FiscalCode__c?.substring(0, accs[0].FiscalCode__c.length()-1) + 'P';
		system.debug('CODICE FISCALE '+accs[0].FiscalCode__c);
		insert accs;
        //test
        Test.startTest();

        //setup for test
        RestRequest req = new RestRequest();
        RestResponse restResp = new RestResponse();

		Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(JSON_REQUEST);
		requestMap.put('typeInt', null);
		requestMap.put('fiscalCode', accs[0].FiscalCode__c);

        req.requestURI = 'services/apexrest/rifiutologo';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(requestMap));

        RestContext.request = req;
        RestContext.response = restResp;

        //call webservice method
        HDT_WS_GarbageMan.HDT_WRP_WasteDisposalResponse res = HDT_WS_GarbageMan.handleWasteDisposalFromApp();
		system.assertEquals(
			'N',
			res.requestInCharge,
			'Test Callout did not failed as expected for incomplete data'
		);

		requestMap.put('typeInt', 'SCARICHI ABUSIVI');
        req.requestBody = Blob.valueOf(JSON.serialize(requestMap));
		res = HDT_WS_GarbageMan.handleWasteDisposalFromApp();

		system.assertEquals(
			'N',
			res.requestInCharge,
			'Test Callout did not failed as expected for Invalid Type Intervention'
		);

        Test.StopTest();
    }

	@isTest
    public static void testCalloutKoInsertFailed() {

        //test
        Test.startTest();

        //setup for test
        RestRequest req = new RestRequest();
        RestResponse restResp = new RestResponse();

        String reqString = '{"phoneNumber":"3287777777","fiscalCode":"BRRSMN81T22I459C","clientTypology":"Domestico Non","contactName":"Simone tortora","streetCode":"041044811157","city":"PESARO","street":"VIALE VENTIQUATTRO MAGGIO","streetNumber":"16","typeInt":"Ingombr+RAEE_NOAPP-IURD0033","requestCode":"11111","materialDescription":"Prodotto 1: Valigia varie tipologie"}';
        req.requestURI = 'services/apexrest/rifiutologo';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(reqString);

        RestContext.request = req;
        RestContext.response = restResp;

        //call webservice method
        HDT_WS_GarbageMan.HDT_WRP_WasteDisposalResponse res = HDT_WS_GarbageMan.handleWasteDisposalFromApp();
        system.assertEquals(
			'N',
			res.requestInCharge,
			'Test Callout did not failed as expected for Invalid Type Intervention'
		);
        HDT_WS_GarbageMan waGar = new HDT_WS_GarbageMan();
        Test.StopTest();
    }

	@isTest
	public static void testPhoneExtraction() {
		HDT_WS_GarbageMan.HDT_WRP_WasteDisposalResponse response = new HDT_WS_GarbageMan.HDT_WRP_WasteDisposalResponse();
		response.errorDetails = null;
		HDT_WS_GarbageMan.HDT_WRP_WasteDisposalRequest request = new HDT_WS_GarbageMan.HDT_WRP_WasteDisposalRequest();
		String resultPhone = HDT_WS_GarbageMan.getPhoneNumber(request, null);
		System.assert(String.isBlank(resultPhone), 'Unexpected Result');
	}

}