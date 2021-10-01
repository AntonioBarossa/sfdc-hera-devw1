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
        
        
     
     
         HDT_UTL_DataFactoryTst.createWebServiceConfiguration('VAS.Service26', 'testUser', 'method', 'end');
    }
    
    @isTest
    static void testCallService26(){
       Test.startTest();
        List<Account> acctList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        Id accId = acctList[0].Id;
        List<Contract> contraList = HDT_UTL_DataFactoryTst.createContract(1,true,accId);
        Id contraId =  contraList[0].Id;
        List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1,true,accId,'Bozza');
        Id orderId = orderList[0].Id;
        
         
        HDT_WS_ArrichmentDataEntityResponse res = HDT_SRV_ServiceTwentySix.callService26(orderId);
        
         System.assertEquals(null, res.statusCode, 'The call was not successful');
        Test.stopTest();
    }
    

}