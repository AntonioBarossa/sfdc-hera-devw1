/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 26/07/2021
 * @description Test Class for HDT_QR_StaticResource.cls
 * @history Fabricio Petkevicius Nunes – 26/07/2021 – Created class
 */
@isTest
public class HDT_QR_StaticResourceTst{
	@isTest
	static void testgetRecordById(){

		Test.startTest();

		StaticResource tStaticRes=[SELECT Id, Name
		                           FROM StaticResource 
		                           LIMIT 1];

		HDT_QR_StaticResource qrStaticRes=new HDT_QR_StaticResource();

		List<StaticResource> tStaticResList=qrStaticRes.getRecordByName(tStaticRes.Name);

		System.assertEquals(tStaticRes.Name, tStaticResList[0].Name, 'The Static Resource was not retrieve correctly');

		System.assertNotEquals('', tStaticResList[0].Id, 'The static resource was not retrieved correctly');

		Test.stopTest();
	}
}