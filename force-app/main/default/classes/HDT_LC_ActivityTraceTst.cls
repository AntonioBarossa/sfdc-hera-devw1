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
        
        List<Order> orders=HDT_UTL_DataFactoryTst.createOrder(1, false, accounts[0].Id, 'Bozza');
        
        Interaction__c inter = new Interaction__c();
        inter.Account__c = accounts[0].Id;
        insert inter;
        
        orders[0].Interaction__c = inter.Id ;
        
        insert orders;
        
       
       
    }
    
    
    @isTest
    static void getActivityTest(){
        List<Account> accList = [SELECT Id,Activity__c FROM Account WITH SECURITY_ENFORCED LIMIT 1] ;
        String res = HDT_LC_ActivityTrace.getActivity(accList[0].Id);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(res);
        String resultId = (String) m.get('Id');
        system.assertEquals(String.valueOf(accList[0].Activity__c), resultId,'The result is not what expected' );
    }
        
    @isTest
    static void getActivityTestOne(){
        List<Order> orderList = [SELECT Id, Activity__c, Interaction__c FROM Order WITH SECURITY_ENFORCED LIMIT 1] ;
        String res = HDT_LC_ActivityTrace.getActivity(orderList[0].Id);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(res);
        String resultId = (String) m.get('Id');
        system.assertEquals(String.valueOf(orderList[0].Interaction__c), resultId,'The result is not what expected' );
    }
    
    
    
    
}