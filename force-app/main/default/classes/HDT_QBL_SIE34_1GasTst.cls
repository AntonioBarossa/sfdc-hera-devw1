/**
 * @author Sabina Levonja (sabina.levonja@dunegroup.it)
 * @date 15/10/2021
 * @description HDT_QBL_SIE34_1Gas Test Class
 * @history Sabina Levonja – 15/10/2021 – Created Class
 */
@isTest
public with sharing class HDT_QBL_SIE34_1GasTst {

    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
    private static Datetime d= Datetime.now().addHours(-3);

    @TestSetup
    static void setup(){
        
        HDT_UTL_DataFactoryTst.pClickOrderPhase();

		List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
		List<Sale__c> sales=HDT_UTL_DataFactoryTst.createSale(1, true, accounts[0].id, 'Attiva');            
        Id pricebookId = Test.getStandardPricebookId();
            
        List<Order> orders = HDT_UTL_DataFactoryTst.createOrderWithPricebook(1,false,accounts[0].id,sales,pricebookId);
        orders[0].Phase__c = 'Completata';
        orders[0].Commodity__c ='GAS';
        orders[0].recordTypeId = constants.ORDER_RECORDTYPEID_CONNESSIONECONATTIVAZIONE;
        insert orders; 
        List<ServicePoint__c> points = HDT_UTL_DataFactoryTst.createServicePoint(1,true);            
        List<Product2> products = HDT_UTL_DataFactoryTst.createProduct2(1,true);            
        List<PricebookEntry> entries = HDT_UTL_DataFactoryTst.createPricebookEntry(products,true,pricebookId);            
        HDT_UTL_DataFactoryTst.createOrderItem(1,true,orders[0].id,points[0].id,products[0].id,entries[0].id);
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration('SIE34', 'end', 'method', 'testUser');
        HDT_UTL_DataFactoryTst.createWebServiceCredential('FirstName LastName', 'pass12345', 'usernameTest');
    }
    
    @isTest
    public static void testQueue() {
		HDT_QBL_SIE34_1Gas qb=new HDT_QBL_SIE34_1Gas('test',d.format('yyyy-MM-dd \'T\'hh:\'Z\'mm:ss'),'pdf');
        Test.startTest();
        	Id res = System.enqueueJob(qb);
        Test.stopTest();
        System.assertEquals('Completed' , [SELECT Id , Status FROM AsyncApexJob WHERE Id=:res][0].Status, 'The job has not been completed');
        System.assertNotEquals(null , [SELECT Id , Status FROM AsyncApexJob WHERE Id=:res][0].Status, 'The job has not been completed');
    }
}