/**
 * @author Valere (valere@noeli-it.net)
 * @date 22/09/2021
 * @description HDT_VFC_ForzaturaChiusuraCreditCheck Test Class
 * @history valere - 22/09/2021– Created Class
 */
@isTest
private class HDT_VFC_ForzaturaChiusuraCreditCheckTst {
    @testSetup
    static void setup() {
        
        HDT_UTL_DataFactoryTst.pClickInstanceActivityIntegration();
       
        List<Account> accountList= HDT_UTL_DataFactoryTst.createAccountResidenziale(1,true,'HERA COMM','Persona fisica','Famiglie');
        HDT_UTL_DataFactoryTst.createActivityCustom(1, true,accountList[0].id);
    }


    @isTest 
    static void test() {
        Test.startTest();
        HDT_VFC_ForzaturaChiusuraCreditCheck forzatura = new HDT_VFC_ForzaturaChiusuraCreditCheck(
                                                        'SELECT id,wrts_prcgvr__Status__c ,Order__c FROM wrts_prcgvr__Activity__c ');
        Database.executeBatch(forzatura);
        Test.stopTest();
      
        System.assertEquals(1, [select count() from wrts_prcgvr__Activity__c where wrts_prcgvr__Status__c = 'KO Definitivo'],'we updated only one wrts_prcgvr__Activity__c'  );
        System.assertNotEquals(5, [select count() from wrts_prcgvr__Activity__c where wrts_prcgvr__Status__c = 'KO Definitivo'],'we did not update more than one wrts_prcgvr__Activity__c'  );
        
    }
}