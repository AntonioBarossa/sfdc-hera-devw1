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


		System.debug('tStaticRes = '+tStaticRes);

		HDT_QR_StaticResource qrStaticRes=new HDT_QR_StaticResource();

		List<StaticResource> tStaticResList=qrStaticRes.getRecordByName(tStaticRes.Name);


		System.debug('tStaticResList = '+tStaticResList);


		System.assertEquals(tStaticRes.Name, tStaticResList[0].Name, 'Static Resource return is not correct');

		System.assertNotEquals('', tStaticResList[0].Id);

		Test.stopTest();
	}
}