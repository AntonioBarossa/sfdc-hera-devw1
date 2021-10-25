/**
 * Header of the class "HDT_ContractTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative trigger "HDT_Contract"
 * @history
 * @Created 12/10/2021
 * Modified By:
 **/

@isTest
public class HDT_ContractTst {
    
    @isTest static void test(){
        
        Test.startTest();
        
        List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Contract> contracts = HDT_UTL_DataFactoryTst.createContract(1, true, accs[0].Id);

        System.assertEquals(1, contracts.size(), 'Contract not inserted correctly');

        System.assertNotEquals(null, contracts, 'Contract not inserted correctly');

        Test.stopTest();
        
    }

}