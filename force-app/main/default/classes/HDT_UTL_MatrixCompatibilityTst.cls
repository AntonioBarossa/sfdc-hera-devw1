/**
* @author Elfrida Kora (elfrida.kora@dunegroup.it)
* @date 20/09/2021
* @description HDT_UTL_MatrixCompatibility for Test Classes
* @history Elfrida Kora – 20/09/2021 – Created class
* @history Sabina Levonja – 08/10/2021 
*/

@IsTest
public class HDT_UTL_MatrixCompatibilityTst {
    
    @TestSetup
    static void allData(){
    
        HDT_UTL_DataFactoryTst.pClickInstance();
         
        List<Account> acctList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        Id accId = acctList[0].Id;   
        List<Contract> contraList = HDT_UTL_DataFactoryTst.createContract(1,true,accId);
        Id contraId =  contraList[0].Id;
        List<ServicePoint__c> sp = HDT_UTL_DataFactoryTst.createServicePoint(1,false);
        sp[0].CommoditySector__c = 'Gas';  
        insert sp;     
        List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1,true,accId,'Bozza');
        Id orderId = orderList[0].Id;
        List<Contact> conList = HDT_UTL_DataFactoryTst.createContact(1,true,accId);
        Id conId =  conList[0].Id;
        Id spId =  sp[0].Id;
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1,false,accId,conId,spId,contraId, orderList[0].Id);
        caseList[0].Type = 'Rimborso';
        insert caseList;
        Id caseId = caseList[0].Id;
        List<ServiceRequest__c> srList = new List<ServiceRequest__c>();
        srList = HDT_UTL_DataFactoryTst.createServiceRequest(2,false);
        srList[0].ServicePoint__c = spId;
        srList[0].Order__c = orderId;
        srList[0].Case__c = caseId;
        srList[0].ServicePointCode__c = sp[0].ServicePointCode__c;
        srList[0].CommoditySector__c = sp[0].CommoditySector__c;
        srList[0].Type__c = 'Case';
        srList[0].ProcessType__c = 'Sospensione fornitura - GAS';
            
        insert srList;
    }
      
    @isTest
    public static void testCheckCompatibilitySales(){
        Test.startTest();
        
       	Map<String,Object> testMap = new Map<String,Object>();
        
        ServiceRequest__c sr = new ServiceRequest__c();
        sr = [SELECT Id,ServicePointCode__c,Status__c,Case__c,CommoditySector__c,Type__c,Account__c,BillingProfile__c,ProcessType__c,ServicePoint__c FROM ServiceRequest__c limit 1];
        
        testMap.put('servicePointCode',sr.ServicePointCode__c);
        testMap.put('commoditySector',sr.CommoditySector__c);
        testMap.put('type',sr.Type__c);
        testMap.put('servicePoint',sr.ServicePoint__c);
        testMap.put('processType','Sospensione Fornitura');   
        
        Map<String,Object> resp= HDT_UTL_MatrixCompatibility.checkCompatibilitySales(testMap,true);
        Test.stopTest();

        System.assertEquals(true,!resp.isEmpty(),'The response is empty');
        System.assertNotEquals(false,String.isBlank(String.valueOf(resp.get('compatibility'))),'The response is empty');

    }
    
     @isTest
    public static void testCheckCompatibilitySales1(){
        Test.startTest();
        
       Map<String,Object> testMap = new Map<String,Object>();
        Order ord=[Select Id,ServicePoint__c,ServicePoint__r.ServicePointCode__c,ServicePoint__r.CommoditySector__c,AccountId from Order limit 1];
        testMap.put('servicePointCode',ord.ServicePoint__r.ServicePointCode__c);
        testMap.put('order',ord.Id);
        testMap.put('commoditySector',ord.ServicePoint__r.CommoditySector__c);
        testMap.put('type','Order');
        testMap.put('servicePoint',ord.ServicePoint__c);
		testMap.put('isBillableVas',true);
        testMap.put('account',ord.AccountId);
        testMap.put('processType','Prima Attivazione con modifica');
       
        Map<String,Object> resp= HDT_UTL_MatrixCompatibility.checkCompatibilitySales(testMap,null);
        Test.stopTest();
        
        System.assertEquals(true,!resp.isEmpty(),'The response is empty');
        System.assertNotEquals(false,String.isBlank(String.valueOf(resp.get('compatibility'))),'There is a blocking process');
    }
    
    
    @isTest
    public static void testGetStatus(){
        Test.startTest();
            
            HDT_UTL_MatrixCompatibility.getStatus('New','Case');
            HDT_UTL_MatrixCompatibility.getStatus('In Lavorazione','Case');
            HDT_UTL_MatrixCompatibility.getStatus('Sequenzializzato','Case');
            HDT_UTL_MatrixCompatibility.getStatus('Closed','Case');
            HDT_UTL_MatrixCompatibility.getStatus('Draft','Order');
            HDT_UTL_MatrixCompatibility.getStatus('In Lavorazione','Order');
            HDT_UTL_MatrixCompatibility.getStatus('Activated','Order');
            HDT_UTL_MatrixCompatibility.getStatus('Completed','Order');
            HDT_UTL_MatrixCompatibility.getStatus('Annullato','Order');
            String resp= HDT_UTL_MatrixCompatibility.getStatus('Sequenzializzato','Order');
        Test.stopTest();
        
		System.assertEquals(true,!String.isBlank(resp),'The response is empty');
        System.assertNotEquals('',resp,'The response is empty');
	}

     @isTest
    public static void testCheckCompatibilityPostSales(){
        Test.startTest();
        
        Case c =[SELECT Id,PODPDRFormula__c,Status,CommodityFormula__c,AccountId,ServicePoint__c,BillingProfile__c,Type FROM Case limit 1];
        String resp= HDT_UTL_MatrixCompatibility.checkCompatibilityPostSales(c);
        Test.stopTest();
        
		System.assertEquals(true,String.isBlank(resp),'There is a blocking process');
        System.assertNotEquals(false,String.isBlank(resp),'The response is not empty');
    }
    @isTest
    public static void testCheckCompatibilityPostSalesCatch(){
        try{
            Test.startTest();
        		HDT_UTL_MatrixCompatibility.checkCompatibilityPostSales(null);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Attempt to de-reference a null object',e.getMessage(),'The Exception has not been catched');
        }      
    }

     @isTest
    public static void testGetIncompatibilityMessage(){
        Test.startTest();
            
            List<ServiceRequest__c> srList =  [SELECT Id,ServicePointCode__c,Status__c,Order__c,CommoditySector__c,Type__c,Account__c,BillingProfile__c,ProcessType__c,ServicePoint__c FROM ServiceRequest__c];      
            HDT_UTL_MatrixCompatibility.getIncompatibilityMessage(srList);
            srList[0].Case__c=null;
            update srList;
            String resp= HDT_UTL_MatrixCompatibility.getIncompatibilityMessage(srList);
        Test.stopTest();
		System.assertEquals(true,String.isNotBlank(resp),'There is no blocking process');
        System.assertNotEquals(true,String.isBlank(resp),'The response is not empty');
    }
    @isTest
    public static void testGetIncompatibilityMessage1(){
        Test.startTest();
            Order ord=[Select Id,ServicePoint__c,ServicePoint__r.ServicePointCode__c,ServicePoint__r.CommoditySector__c,AccountId from Order limit 1];
        
            List<ServiceRequest__c> srList =  [SELECT Id,ServicePointCode__c,Status__c,Order__c,CommoditySector__c,Type__c,Account__c,BillingProfile__c,ProcessType__c,ServicePoint__c FROM ServiceRequest__c];      
            srList[0].Type__c='Order';
            srList[0].Order__c=ord.Id;
            srList[0].ServicePointCode__c=ord.ServicePoint__r.ServicePointCode__c;
            update srList;
            String resp= HDT_UTL_MatrixCompatibility.getIncompatibilityMessage(srList);
        Test.stopTest();
        System.assertEquals(true,String.isNotBlank(resp),'There is no blocking process');
        System.assertNotEquals(true,String.isBlank(resp),'The response is not empty');
    }
}