/*
    @Author:        Davide Viola
    CreatedDate:    20/09/2021
*/

@isTest
public class HDT_LC_ContactSelectionTst {    
    @TestSetup
    static void setup(){

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(2, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        List<Contact> contactList2 = HDT_UTL_DataFactoryTst.createContact(1, true, accList[1].Id);

    }

    public static testMethod void testGetListRecords() {

        Account acc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();

        String retVal = '';
        Map<String, Object> valuesMap = new Map<String, Object>();

        retVal = HDT_LC_ContactSelection.getListRecords(acc.Id);

        for(Object obj : (List<Object>)JSON.deserializeUntyped(retVal)){
            Map<String, Object> data = (Map<String, Object>)obj;
            valuesMap.putAll(data);
         }
         System.assertEquals(valuesMap.get('Id'), [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1].Id);
         System.assertEquals(valuesMap.get('Name'), 'test tester');
        
        Test.stopTest();
    }

    public static testMethod void testGetAdministrators(){
        
        Set<String> accIdSet = new Set<String>();
        for(Account acc : [SELECT Id FROM Account]) accIdSet.add(acc.Id);
        List<AccountContactRelation> acrList = [SELECT Id, AccountId, Roles FROM AccountContactRelation WHERE AccountId = :accIdSet];
        for(AccountContactRelation acr : acrList) acr.Roles = 'Amministratore condominio';
        update acrList;

        Test.startTest();

        String retVal = '';
        Map<String, Object> valuesMap = new Map<String, Object>();

        retVal = HDT_LC_ContactSelection.getAdministrators(acrList[0].AccountId, '');
        System.debug('@Davide - retval: ' +retVal);

        Test.stopTest();
    }
}