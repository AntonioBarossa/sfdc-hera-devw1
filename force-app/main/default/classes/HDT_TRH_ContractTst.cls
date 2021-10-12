/**
 * Header of the class "HDT_TRH_ContractTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_TRH_Contract"
 * @history
 * @Created 12/10/2021
 * Modified By:
 **/
@isTest
public with sharing class HDT_TRH_ContractTst{
    
	@isTest
	public static void testUpdate(){

		Test.startTest();

		List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
		List<Contract> contracts = HDT_UTL_DataFactoryTst.createContract(1, true, accs[0].Id);
        List<Order> orders = HDT_UTL_DataFactoryTst.createOrder(1,true,accs[0].id,'Bozza');               
        
        Contract contr = [Select Id from contract limit 1];
        contr.SBQQ__Order__c = orders[0].id;
        
        update contr;
        
        Test.stopTest();
        
        List<Contract> query = [Select id,SBQQ__Order__c from contract];

		System.assertEquals(1, query.size(), 'Contract not inserted correctly');
		System.assertNotEquals(null, query[0].SBQQ__Order__c, 'Contract not updated correctly');

	}

}