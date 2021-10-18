/*
 * @author Laureta Demishaj (laureta.demishaj@dunegroup.it)
 * @date 13/10/2021
 * @description HDT_UTL_CheckPreviousPhase for Test Classes
 * @history Laureta Demishaj – 13/10/2021 – Created class
*/
@isTest
public class HDT_UTL_CheckPreviousPhaseTst {
    public static final HDT_UTL_CheckPreviousPhase myObjectToTest = new HDT_UTL_CheckPreviousPhase();
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    @TestSetup
    private static void mySetup(){
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, false, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);      
        caseList[0].PhaseStory__c = 'Da Inviare@@Comunicazione verso Heroku KO@@1620810421961@@A||Bozza@@Da Inviare@@1620810412328@@A||';
        insert caseList;
    }
    @isTest
    private static void evaluateTst(){
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        Id rt=constants.CASE_RECORDTYPEID_MOROSITA;
        HDT_UTL_DataFactoryTst.newPhaseTransition('Completata', 'Bozza', rt, 'HDT_RT_Morosita');
        String method_OK = 'ModificaLayoutFattura';
        Case obj = [SELECT Id, CaseNumber, ContractCode__c, ElementDetail__c, PhaseStory__c FROM Case];
        Map<String, Object> argsMap = new Map<String,Object>();
        argsMap.put('method', method_OK);
        argsMap.put('record', obj);
        Test.startTest();
        Boolean result =  myObjectToTest.evaluate(argsMap);
        Test.stopTest();
        System.assertEquals(true, result!=null, 'An error has occurred!');
        System.assertNotEquals(false, result=null, 'An error has occurred!');
}
}