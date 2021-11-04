/**
 * @author Sabina Levonja (sabina.levonja@dunegroup.it)
 * @date 04/10/2021
 * @description HDT_QR_Helper Test Class
 * @history Sabina Levonja – 04/10/2021 – Created Class
 */
@isTest
public with sharing class HDT_QR_HelperTst {
    public static HDT_QR_Helper helpQR= new HDT_QR_Helper();

    @TestSetup
    static void myData(){
    	List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].Id, 'Bozza');
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].Id);
        HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, spList[0].Id, contractList[0].Id, orderList[0].Id);
    }
    @isTest
    public static void testSetObj(){
        Test.startTest();
            helpQR.setObj('Case');
        Test.stopTest();   
        System.assertEquals(true,helpQR.typeObject!=null,'The field has not been valorized');
        System.assertNotEquals(null,helpQR.typeObject,'The type of the object has not been valorized');

    }
    @isTest
    public static void testSetNestedFields(){
        Test.startTest();
        
        	Case cs=[SELECT Id, CaseNumber, AccountId, AssetId, ContactId, ParentId, RecordTypeId, Status,Priority, Description , ClosedDate FROM Case limit 1];
        	Map<String,Object> objMap = cs.getPopulatedFieldsAsMap();
        	List<String> fields = new List<String>(objMap.keySet());
            helpQR.setNestedFields(fields);
        
        Test.stopTest(); 
        System.assertEquals(true,!helpQR.listNestedFields.isEmpty(),'The list has not been populated');
        System.assertNotEquals(true,helpQR.listNestedFields.isEmpty(),'The list of nested fields has not been populated');
        
    }
    @isTest
    public static void testSetBlackListFields(){
        Test.startTest();
        
        	Case cs=[SELECT IsDeleted, IsEscalated FROM Case limit 1];
        	Map<String,Object> objMap = cs.getPopulatedFieldsAsMap();
        	List<String> fields = new List<String>(objMap.keySet());
            helpQR.setBlackListFields(fields);
        
        Test.stopTest();   
        System.assertEquals(true,!helpQR.blackListFields.isEmpty(),'The list has not been populated');
        System.assertNotEquals(true,helpQR.blackListFields.isEmpty(),'The list of blacklist fields has not been populated');

    }
    @isTest
    public static void testSetFilter(){
        Test.startTest();
            Case cs=[SELECT Id FROM Case limit 1];
        	String filter= 'Id=\''+ cs.Id+'\'';
            helpQR.setFilter(filter);
        
        Test.stopTest();   
        System.assertEquals(true,helpQR.sFilter!=null,'The filter has not been valorized');
        System.assertNotEquals(null,helpQR.sFilter,'The filter has not been valorized');

    }
    @isTest
    public static void testGetAllObjectFields(){
        Test.startTest();
        	helpQR.setObj('Case');
        	Case cs=[SELECT Id, CaseNumber, AccountId, AssetId, ContactId, ParentId, RecordTypeId, Status,Priority, Description , ClosedDate FROM Case limit 1];
        	List<String> fields = new List<String>();
            helpQR.setNestedFields(fields);
        	List<String> blacklistFields = new List<String>();
        	blacklistFields.add('IsDeleted');
        	helpQR.setBlackListFields(blacklistFields);
        	String filter= 'Id=\''+ cs.Id+'\'';
            helpQR.setFilter(filter);
            helpQR.getAllObjectFields();
        	helpQR.getQeryString();
        	helpQR.getListSObject();
        
        Test.stopTest(); 	
        
        System.assertEquals(true,helpQR.getAllObjectFields()!='','There are no fields for this object');
        System.assertNotEquals(false,helpQR.getAllObjectFields().contains('id'),'The Id field has not been passed to the method');     
    }
    @isTest
    public static void testGetQeryString(){
        Test.startTest();
        
            helpQR.setObj('Case');
        	//Case cs=[SELECT Id, CaseNumber, AccountId, AssetId, ContactId, ParentId, RecordTypeId, Status,Priority, Description , ClosedDate FROM Case limit 1];
        	List<String> fields = new List<String>();
            helpQR.setNestedFields(fields);
            String resp= helpQR.getQeryString();
            
        Test.stopTest();  

		System.assertEquals(true, String.isNotBlank(resp),'The query has not been created');
        System.assertNotEquals(false,resp.contains('SELECT'),'The query has not been created correctly'); 
    }
    @isTest
    public static void testGetListSObject(){
        Test.startTest();
        
            helpQR.setObj('Case');
        	Case cs=[SELECT Id, CaseNumber, AccountId, AssetId, ContactId, ParentId, RecordTypeId, Status,Priority, Description , ClosedDate FROM Case limit 1];
        	List<String> fields = new List<String>();
            helpQR.setNestedFields(fields);
        	String filter= 'Id=\''+ cs.Id+'\'';
            helpQR.setFilter(filter);
            List<SObject> resp= helpQR.getListSObject();
        
        Test.stopTest();  

		System.assertEquals(true, resp.size()>0,'There are no records returned');
        System.assertNotEquals(null,resp,'The response is null'); 
    }
    
    @isTest
    public static void testGetListSObjectCatch(){
        Test.startTest();
        
        	helpQR.setObj('Case');
        	Case cs=[SELECT Id, CaseNumber, AccountId, AssetId, ContactId, ParentId, RecordTypeId, Status,Priority, Description , ClosedDate FROM Case limit 1];
        	List<String> fields = new List<String>();
            helpQR.setNestedFields(fields);
        	String filter= 'Id='+ cs.Id;
            helpQR.setFilter(filter);
            List<SObject> resp= helpQR.getListSObject();
        
        Test.stopTest();  
        	
        System.assertNotEquals(true,resp!=null,'The response is not null');         

    }
}