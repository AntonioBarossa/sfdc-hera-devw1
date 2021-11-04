/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 24/09/2021
 * @description HDT_UTL_NotifVas Test Classes
 * @history Lucas Fernandes 24/09/2021 – Created Class
 */
@isTest
public with sharing class HDT_UTL_NotifVasTst {
   
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    private static HDT_WRP_MrrRequest.HDT_WRP_Request request = new HDT_WRP_MrrRequest.HDT_WRP_Request();
    private static HDT_WRP_MrrResponse.HDT_WRP_Response response = new HDT_WRP_MrrResponse.HDT_WRP_Response();
	
	@TestSetup
    static void setup(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
        internalUser.UserPermissionsMarketingUser=true;
        insert internalUser;
 
        System.runAs(internalUser) {

            HDT_UTL_DataFactoryTst.pClickInstance();
            HDT_UTL_DataFactoryTst.pClickOrderPhase();
            HDT_UTL_DataFactoryTst.pClickCasePhase();
            HDT_UTL_DataFactoryTst.newPhaseTransition('Accettato Motore Vas', 'Bozza', constants.ORDER_RECORDTYPEID_VAS, 'HDT_RT_VAS');
			HDT_UTL_DataFactoryTst.newPhaseTransition('Accettato Motore Vas', 'Bozza', constants.CASE_RECORDTYPEID_POST_SALES_VAS, 'HDT_RT_PostSalesVAS');
            
            List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
            List<Contact> cttList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
            
            List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].Id, 'Bozza');
            orderList[0].Contact__c = cttList[0].Id;
            orderList[0].RecordTypeId = constants.ORDER_RECORDTYPEID_VAS;
            insert orderList;
            
            List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, false, accList[0].Id);
            contractList[0].SBQQ__Order__c = orderList[0].Id;
            insert contractList;

            List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
            List<SBQQ__Subscription__c> scList = HDT_UTL_DataFactoryTst.createSubscription(1, true, accList[0].Id, contractList[0].Id, spList[0].Id);
            List<Asset> assetList = HDT_UTL_DataFactoryTst.createAsset(1, true, 'HERA COMM');
            
            List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, false, accList[0].Id, cttList[0].Id, spList[0].Id, contractList[0].Id, orderList[0].Id);
            caseList[0].RecordTypeId = constants.CASE_RECORDTYPEID_POST_SALES_VAS;
            caseList[0].AssetId = assetList[0].Id;
            caseList[0].Subscription__c = scList[0].Id;
            caseList[0].Type = 'Disattivazione VAS';
            insert caseList;
        }
    }
	
	@isTest
    public static void testHandleVasNotify() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

                HDT_WRP_MrrRequest.HDT_WRP_Field mrrFields = new HDT_WRP_MrrRequest.HDT_WRP_Field();
                mrrFields.value = 'sales';
                mrrFields.name = 'nome';

                HDT_WRP_MrrRequest.HDT_WRP_Field mrrFields2 = new HDT_WRP_MrrRequest.HDT_WRP_Field();
                mrrFields2.value = [SELECT OrderNumber FROM Order WHERE Phase__c = 'Bozza'].OrderNumber;
                mrrFields2.name = 'KEY_SERVIZIO';

                HDT_WRP_MrrRequest.HDT_WRP_Field mrrFields3 = new HDT_WRP_MrrRequest.HDT_WRP_Field();
                mrrFields3.value = 'OK';
                mrrFields3.name = 'STATO_PRATICA';
    
                List<HDT_WRP_MrrRequest.HDT_WRP_Field> fieldList = new List<HDT_WRP_MrrRequest.HDT_WRP_Field>();
                fieldList.add(mrrFields);
                fieldList.add(mrrFields2);
                fieldList.add(mrrFields3);
    
                HDT_WRP_MrrRequest.HDT_WRP_Header mrrHeader = new HDT_WRP_MrrRequest.HDT_WRP_Header();
                mrrHeader.fields = fieldList;
                HDT_WRP_MrrRequest.HDT_WRP_Object mrrObjects = new HDT_WRP_MrrRequest.HDT_WRP_Object();
                mrrObjects.fields = fieldList;
                mrrObjects.objectType = 'Order';
                
                List<HDT_WRP_MrrRequest.HDT_WRP_Object> objectList = new List<HDT_WRP_MrrRequest.HDT_WRP_Object>();
                objectList.add(mrrObjects);           
    
                HDT_WRP_MrrRequest.HDT_WRP_Request request = new HDT_WRP_MrrRequest.HDT_WRP_Request();
                request.header = mrrHeader;
                request.objects = objectList;
    
                HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem = new HDT_WRP_MrrResponse.HDT_WRP_Response();
                mrrResponseItem.objects = new List<HDT_WRP_MrrResponse.HDT_WRP_Object>();

                RestRequest req = new RestRequest();
                RestResponse res = new RestResponse();
                req.requestURI = 'https://na11.salesforce.com'; // sample Endpoint
                req.httpMethod = 'POST';
                RestContext.request = req;
                RestContext.response = res;
                
                HDT_UTL_NotifVas.handleVasNotify(request, mrrResponseItem);

                System.assertEquals(RestContext.response.statusCode, 200, 'Order updated');
                System.assertNotEquals(RestContext.response.statusCode, 400, 'Order updated');

            Test.stopTest();
        }
    }
	
    @isTest
    public static void testHandleVasNotify2() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            try {

                HDT_WRP_MrrRequest.HDT_WRP_Field mrrFields = new HDT_WRP_MrrRequest.HDT_WRP_Field();
                mrrFields.value = 'postsales';
                mrrFields.name = 'nome';
    
                HDT_WRP_MrrRequest.HDT_WRP_Field mrrFields2 = new HDT_WRP_MrrRequest.HDT_WRP_Field();
                mrrFields2.value = [SELECT OrderNumber FROM Order WHERE Phase__c = 'Bozza'].OrderNumber;
                mrrFields2.name = 'KEY_SERVIZIO';

                HDT_WRP_MrrRequest.HDT_WRP_Field mrrFields3 = new HDT_WRP_MrrRequest.HDT_WRP_Field();
                mrrFields3.name = 'STATO_PRATICA';
                mrrFields3.value = 'OK';

                List<HDT_WRP_MrrRequest.HDT_WRP_Field> fieldList = new List<HDT_WRP_MrrRequest.HDT_WRP_Field>();
                fieldList.add(mrrFields);
                fieldList.add(mrrFields2);
                fieldList.add(mrrFields3);
    
                HDT_WRP_MrrRequest.HDT_WRP_Header mrrHeader = new HDT_WRP_MrrRequest.HDT_WRP_Header();
                mrrHeader.fields = fieldList;
                HDT_WRP_MrrRequest.HDT_WRP_Object mrrObjects = new HDT_WRP_MrrRequest.HDT_WRP_Object();
                mrrObjects.fields = fieldList;
                mrrObjects.objectType = 'Case';
                
                List<HDT_WRP_MrrRequest.HDT_WRP_Object> objectList = new List<HDT_WRP_MrrRequest.HDT_WRP_Object>();
                objectList.add(mrrObjects);           
    
                HDT_WRP_MrrRequest.HDT_WRP_Request request = new HDT_WRP_MrrRequest.HDT_WRP_Request();
                request.header = mrrHeader;
                request.objects = objectList;
    
                HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem = new HDT_WRP_MrrResponse.HDT_WRP_Response();

                RestRequest req = new RestRequest();
                RestResponse res = new RestResponse();
                req.requestURI = 'https://na11.salesforce.com'; // sample Endpoint
                req.httpMethod = 'POST';
                RestContext.request = req;
                RestContext.response = res;
                mrrResponseItem.objects= new List<HDT_WRP_MrrResponse.HDT_WRP_Object>();
                HDT_UTL_NotifVas.handleVasNotify(request, mrrResponseItem);
            } catch (Exception e) {
                System.debug('test exc1 '+e);
                system.debug(e.getStackTraceString());
            }

            try {

                HDT_WRP_MrrRequest.HDT_WRP_Field mrrFields = new HDT_WRP_MrrRequest.HDT_WRP_Field();
                mrrFields.value = 'anything';
                mrrFields.name = 'nome';

                HDT_WRP_MrrRequest.HDT_WRP_Field mrrFields2 = new HDT_WRP_MrrRequest.HDT_WRP_Field();
                mrrFields2.name = 'KEY_SERVIZIO';
    
                List<HDT_WRP_MrrRequest.HDT_WRP_Field> fieldList = new List<HDT_WRP_MrrRequest.HDT_WRP_Field>();
                fieldList.add(mrrFields);
                fieldList.add(mrrFields2);
    
                HDT_WRP_MrrRequest.HDT_WRP_Header mrrHeader = new HDT_WRP_MrrRequest.HDT_WRP_Header();
                mrrHeader.fields = fieldList;
                HDT_WRP_MrrRequest.HDT_WRP_Object mrrObjects = new HDT_WRP_MrrRequest.HDT_WRP_Object();
                mrrObjects.fields = fieldList;
                mrrObjects.objectType = 'Account';
                
                List<HDT_WRP_MrrRequest.HDT_WRP_Object> objectList = new List<HDT_WRP_MrrRequest.HDT_WRP_Object>();
                objectList.add(mrrObjects);           
    
                HDT_WRP_MrrRequest.HDT_WRP_Request request = new HDT_WRP_MrrRequest.HDT_WRP_Request();
                request.header = mrrHeader;
                request.objects = objectList;
    
                HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem = new HDT_WRP_MrrResponse.HDT_WRP_Response();
                mrrResponseItem.objects= new List<HDT_WRP_MrrResponse.HDT_WRP_Object>();               

                HDT_UTL_NotifVas.handleVasNotify(request, mrrResponseItem);
            } catch (Exception e) {
                System.debug('test exc2 '+e);
                system.debug(e.getStackTraceString());
            }
            Test.stopTest();
            Case postSaleVasCase = [Select Phase__c from Case WHERE RecordTypeId = :constants.CASE_RECORDTYPEID_POST_SALES_VAS];
			system.AssertEquals(postSaleVasCase.Phase__c, 'Accettato Motore VAS', 'Unexpected Case Phase');
        }
    }
}