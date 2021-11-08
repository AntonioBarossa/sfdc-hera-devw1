/*
 * @author Laureta Demishaj (laureta.demishaj@dunegroup.it)
 * @date 01/10/2021
 * @description HDT_LCP_CreateDistributorApointment for Test Classes
 * @history Laureta Demishaj – 01/10/2021 – Created class
*/
@isTest
public class HDT_LCP_CreateDistributorApointmentTst {

    @TestSetup
    static void requiredData(){
        HDT_UTL_DataFactoryTst.pClickInstanceActivityIntegration();
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        HDT_UTL_DataFactoryTst.createBillingProfile(1,true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
    }
   @isTest
    public static void createActivityFromCaseTest(){
     List<Case> cs = [SELECT Id FROM Case];
     Test.startTest();
     Map<String, Object> response = HDT_LCP_CreateDistributorApointment.createActivity(cs[0].Id);
     System.assertEquals(2, response.values().size(), 'The method worked, an activity is created also the error is false so the size of the map is 2');
     System.assertNotEquals(null, response, 'The method worked so is not true that the result map has no values');
     Test.stopTest();
    }
    @isTest
    public static void createActivityFromOrderTest(){
     List<Order> ord = [SELECT Id FROM Order];
     Test.startTest();
     Map<String, Object> response = HDT_LCP_CreateDistributorApointment.createActivity(ord[0].Id);
     System.assertEquals(2, response.values().size(), 'The method worked, an activity is created also the error is false so the size of the map is 2');
     System.assertNotEquals(null, response, 'The method worked so is not true that the result map has no values');
     Test.stopTest();
    }
     @isTest
     public static void createActivityFromElseTest(){
     List<Account> acc = [SELECT Id FROM Account];
     Test.startTest();
     Map<String, Object> response = HDT_LCP_CreateDistributorApointment.createActivity(acc[0].Id);
     System.assertEquals(3, response.values().size(), 'The method didnt work since the given parameter is not a case either an order, the error is set to true since Account is an UnsupportedObjectType for this method');
     System.assertNotEquals(null, response, 'The method didnt worked, but is not true that the result map has no values, the error is set to true');
     Test.stopTest();
    }
    @isTest
    public static void createActivityNegativeTest(){
        try{
           Test.startTest();
           HDT_LCP_CreateDistributorApointment.createActivity(null);
           Test.stopTest();
        }
        catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage(), 'When given a null parameter to a method that returns a map there is thrown an exception');
            System.assertNotEquals('', e.getMessage(), 'There is an exception');
        }
    }
}