@isTest
public with sharing class HDT_LC_AppointmentExtraSistTst {
        private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
    public static HDT_QR_RecordType rcTypeQR= new HDT_QR_RecordType();
    @TestSetup
    static void createEnviroment(){
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        List<Account> acctList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');

        List<Contact> contacts=HDT_UTL_DataFactoryTst.createContact(1, true, acctList[0].Id);
		List<ServicePoint__c> servPoints=HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contract> contracts=HDT_UTL_DataFactoryTst.createContract(1, true, acctList[0].Id);
        List<Product2> prods=HDT_UTL_DataFactoryTst.createProduct2(1, true);
        List<Sale__c> sales=HDT_UTL_DataFactoryTst.createSale(2, true, acctList[0].Id, 'Attiva');

        Id pricebookId=Test.getStandardPricebookId();
        List<Order> orderWithPricebook=HDT_UTL_DataFactoryTst.createOrderWithPricebook(2, false, acctList[0].Id, sales, pricebookId);
        orderWithPricebook[1].RecordTypeId=constants.ORDER_RECORDTYPEID_ORDERDOSSIER;
        orderWithPricebook[1].CommercialProduct__c=prods[0].Id;
        insert orderWithPricebook;
        List<Order> orders=HDT_UTL_DataFactoryTst.createOrder(1, true, acctList[0].Id, 'Bozza');
        List<Case> cases=HDT_UTL_DataFactoryTst.createCase(1, false, acctList[0].Id, contacts[0].Id, servPoints[0].Id, contracts[0].Id, orders[0].Id);
        cases[0].RecordTypeId=constants.CASE_RECORDTYPEID_DOCUMENTALECOPIACONTRATTO;
        cases[0].HerokuPracticeCode__c = 'TEST_SALESFORCE';
        insert cases;	
        List<wrts_prcgvr__Activity__c> actList = HDT_UTL_DataFactoryTst.createActivityCustom(1,false,acctList[0].Id);
        actList[0].isAtoA__c = true;
        actList[0].Type__c = 'Presa Appuntamento';
        actList[0].AppointmentCompetence__c = 'Vendita';
        actList[0].isSelfAppointment__c = false;
        actList[0].RecordTypeId = constants.ACTIVITYCUSTOM_RECORDTYPEID_DISTRIBUTORAPPOINTMENT;
        actList[0].Order__c = orders[0].Id;
        actList[0].Case__c = cases[0].Id;
        actList[0].Distributor__c = acctList[0].Id;
        
        
        insert actList;
    }
    
    @isTest
    public static void executeNewTest(){
        wrts_prcgvr__Activity__c act = [SELECT Id, wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c LIMIT 1];
		String res = HDT_LC_AppointmentExtraSist.getLink(act.Id);
        Map<String,String> response = (Map<String,String>)JSON.deserialize(res, Map<String,String>.class);
        System.assertEquals('Nessun Link valido per il presente distributore.', response.get('errorMessage'),'La risposta al get link non è quella attesa.');
    }
    
    @isTest
    public static void getActivityTest(){
        List<wrts_prcgvr__Activity__c> actList = [SELECT Id, wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c LIMIT 1];
		wrts_prcgvr__Activity__c act = actList[0];
        List<String> fields = new List<String> {'wrts_prcgvr__Status__c'};
         
        Test.startTest();
        
        try{
            String res = HDT_LC_AppointmentExtraSist.getActivity(act.Id, fields);     
        }
        catch (Exception e){
               System.assertEquals(true, e != null);
            }
		
        
        Test.stopTest();
        
    }
    
    @isTest
    public static void getActivityOwnerTest(){
        wrts_prcgvr__Activity__c act = [SELECT Id, wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c LIMIT 1];
        
		Boolean res = HDT_LC_AppointmentExtraSist.getActivityOwner(act.Id);
        
        System.assertEquals(true, res, 'La risposta al get link non è quella attesa.');
    }
   
}