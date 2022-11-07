/**
* @author Elvin Iluca
* @date 03/11/2022
* @description Test Class for HDT_QR_SolContractVas.cls
* @history Elvin Iluca – 03/11/2022 – Created class
*/

@isTest
public with sharing class HDT_QR_SolContractVasTst {
   
     /**​
    * @author Elvin Iluca
    * @date 03/11/2022
    * @description HDT_QR_SolContractVasTst – Test Class for HDT_QR_SolContractVas.cls
    */
    @TestSetup
	static void setup(){
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, false, accList[0].id);
        contractList[0].status='Attivo';
        insert contractList;
    }

    @isTest
    static void getContractWithOfferTst(){
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<SObject> actualList = new List<SObject>();
        Test.startTest();
        actualList = HDT_QR_SolContractVas.getContractWithOffer(accList[0].Id);
        Test.stopTest();
        System.assertEquals(true,!actualList.isEmpty(),'Error failed to get contract with offer');
    }

    /* @isTest
    static void getContractWithOfferContractNoAccTst(){
        List<Contract> contractList = [SELECT Id, isAccessible FROM Contract LIMIT 1];
        contractList[0].isAccessible=false;
        update contractList;

        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<SObject> actualList = new List<SObject>();
        Test.startTest();
        actualList = HDT_QR_SolContractVas.getContractWithOffer(accList[0].Id);
        Test.stopTest();
        System.assertEquals(true,!actualList.isEmpty(),'Error failed to get contract with offer');
    } */

    @isTest
    static void getProductOptionVasTst(){
    
        Set<String> offerSet = new Set<String>();
        offerSet.add('test');
        List<SObject> actualList = new List<SObject>();
        Test.startTest();
        actualList = HDT_QR_SolContractVas.getProductOptionVas(offerSet);
        Test.stopTest();
        System.assertEquals(true, actualList.isEmpty(), 'Error get null list of product optnions');
    
    }
    
    @isTest
    static void getProductOptionVasNullTst(){
    
        Set<String> offerSet = new Set<String>();
        List<SObject> actualList = new List<SObject>();
        Test.startTest();
        actualList = HDT_QR_SolContractVas.getProductOptionVas(offerSet);
        Test.stopTest();
        System.assertEquals(null, actualList, 'Error get null list of product optnions');
    
    }

    
}
