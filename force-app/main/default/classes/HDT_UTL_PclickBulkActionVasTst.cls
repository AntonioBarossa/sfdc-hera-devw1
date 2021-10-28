/*
 * @author Laureta Demishaj (laureta.demishaj@dunegroup.it)
 * @date 15/10/2021
 * @description HDT_UTL_PclickBulkActionVas for Test Classes
 * @history Laureta Demishaj – 15/10/2021 – Created class
*/
@isTest
public class HDT_UTL_PclickBulkActionVasTst {
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    public static HDT_UTL_PclickBulkActionVas myObjectToTest = new HDT_UTL_PclickBulkActionVas();
    @TestSetup
    static void myData(){
      	HDT_UTL_DataFactoryTst.pClickOrderPhase();
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountResidenziale(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
        List<Contact> conList = HDT_UTL_DataFactoryTst.createContact(1,true,accList[0].Id);
        Id conId              =  conList[0].Id;
        List<Order> orderList          = HDT_UTL_DataFactoryTst.createOrder(2, true, accList[0].Id, 'Bozza');
        orderList[0].Phase__c          = 'Annullato';
        orderList[0].Contact__c        = conId;
        orderList[0].ProcessType__c    = 'Cambio Offerta Ele';
        orderList[0].OrderReference__c = orderList[1].Id;
        update orderList;      
        List<Contract> contrList    = HDT_UTL_DataFactoryTst.createContract(1,true,accList[0].Id);
        contrList[0].SBQQ__Order__c =  orderList[1].Id;
        update contrList;
        }
    @isTest
    public static void testPclickBulkActionVas(){
        List<Order>  ord           = [SELECT Id,Phase__c,PhaseStory__c,OrderReference__c FROM Order WHERE Phase__c = 'Annullato'];
        Map<String,Object> argsMap = new Map<String,Object>{'parameter' => new Map<String, Object>{'records'=> ord }};
        Test.startTest();
        Object result = myObjectToTest.execute(argsMap);     
        HDT_UTL_PclickBulkActionVas.checkVasContractAlignmentBeforeUpdate(ord);      
        Test.stopTest();
        System.assertEquals(null, result=null, 'The result should  be null!');
    }
}