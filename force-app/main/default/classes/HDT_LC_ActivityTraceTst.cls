@isTest
public class HDT_LC_ActivityTraceTst {
    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
    
    @TestSetup
    static void makedata(){
        HDT_UTL_DataFactoryTst.pClickInstance();
        
        
        
        List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        
        
        List<wrts_prcgvr__Activity__c> activities=HDT_UTL_DataFactoryTst.createActivityCustom(1, true, accounts[0].id);
        accounts[0].Activity__c = activities[0].Id;
        update accounts;
    }
    
    
    @isTest
    static void getActivityTest(){
        List<Account> accList = [SELECT Id,Activity__c FROM Account WITH SECURITY_ENFORCED LIMIT 1] ;
        String res = HDT_LC_ActivityTrace.getActivity(accList[0].Id);
        system.assertEquals(String.valueOf(accList[0].Activity__c), res,'The result is not what expected' );
    }
    
    
    
}
