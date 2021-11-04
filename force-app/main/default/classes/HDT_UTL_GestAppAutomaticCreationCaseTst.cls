/**
* @author Elfrida Kora (elfrida.kora@dunegroup.it)
* @date 06/10/2021
* @description HDT_UTL_GestAppAutomaticCreationCase for Test Classes
* @history Elfrida Kora – 06/10/2021 – Created class
*/



@IsTest
public class HDT_UTL_GestAppAutomaticCreationCaseTst {
    
    @TestSetup
    static void setup(){
        
        HDT_UTL_DataFactoryTst.pClickInstanceActivityIntegration();


        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].Id, 'Bozza');
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1, false);
        spList[0].CommoditySector__c = 'Gas';
         spList[0].Distributor__c = accList[0].Id;
        insert spList;
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].Id);
        HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, spList[0].Id, contractList[0].Id, orderList[0].Id);
        
    }
    
     @isTest
    public static void testExecute(){
          
        
         Case c = [SELECT Id,Phase__c,ServicePoint__c,ServicePoint__r.CommoditySector__c,ServicePoint__r.distributor__r.name,ServicePoint__r.Account__c FROM Case LIMIT 1];
        
        Map<String,Object> myMap = new Map<String,Object>{'method' => 'VerificaPressione',
            												'sender' => c};
           Test.startTest();                                                     
          HDT_UTL_GestAppAutomaticCreationCase gestApp = new HDT_UTL_GestAppAutomaticCreationCase(); 
		 gestApp.execute(myMap);
        Test.stopTest();     
        
          System.assertEquals(true, gestApp.execute(myMap), 'The Activity Custom is not created');
          System.assertNotEquals(false, gestApp.execute(myMap), 'The Activity Custom is not created');



    }

}