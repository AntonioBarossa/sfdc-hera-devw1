/**
* @author Elfrida Kora (elfrida.kora@dunegroup.it)
* @date 01/10/2021
* @description HDT_SRV_ServiceTwentySix for Test Classes
* @history Elfrida Kora – 01/10/2021 – Created class
*/


@IsTest
public class HDT_SRV_ServiceTwentySixTst {    
    
    @TestSetup
    static void makedata(){     
     
         createWebServiceConfiguration('VAS.Service26', 'Callout:MulesoftBasePath/activations/catalog-attributes', 'POST', 'testUser');
    }
    
    @isTest
    static void testCallService26(){
       
        
        List<Account> acctList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        Id accId = acctList[0].Id;
        List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1,true,accId,'Bozza');
        Id orderId = orderList[0].Id;
        
        HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
		
        Test.setMock(HttpCalloutMock.class, mock);
         
        Test.startTest(); 
        HDT_WS_ArrichmentDataEntityResponse res = (HDT_WS_ArrichmentDataEntityResponse) HDT_SRV_ServiceTwentySix.callService26(orderId);
        System.debug('@@@@' + res);
        System.assertEquals(200, res.statusCode, 'The call was not successful');
        System.assertNotEquals(400, res.statusCode, 'The returned status code was not correct');

        Test.stopTest();
    }
    
	public static void createWebServiceConfiguration (String name, String endpoint, String method, String user) {

		HDT_WebServiceConfiguration__c wsConfig = new HDT_WebServiceConfiguration__c(
			Name = name,
			Endpoint__c = endpoint,
			Method__c = method,
			User__c = user         
		);
		
		insert wsConfig;
	}
}