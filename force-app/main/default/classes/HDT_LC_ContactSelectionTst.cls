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
        contactList.addAll(HDT_UTL_DataFactoryTst.createContact(1, true, accList[1].Id));

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
        Set<String> contIdSet = new Set<String>();
        for(Account acc : [SELECT Id FROM Account]) accIdSet.add(acc.Id);
        List<AccountContactRelation> acrList = [SELECT Id, AccountId, ContactId, Roles FROM AccountContactRelation WHERE AccountId = :accIdSet];
        for(AccountContactRelation acr : acrList) acr.Roles = 'Amministratore condominio';
        update acrList;
        List<Contact> contList = [SELECT Id, AccountId, ContactCode__c FROM Contact WHERE AccountId = :accIdSet];
        Integer i = 2;
        for(Contact cont : contList){
            cont.ContactCode__c = '19001111' +i;
            contIdSet.add(cont.Id);
            i++;
        }
        update contList;
        
        //Vado nelle prossime 3 riche a settare un metodo del test per farmi restituire dalla sosl all'interno del codice i record creati. Se non lo setto, la sosl mi restituisce una List<List> vuota.
        List<String> fixedSearchResults = new List<String>();
        fixedSearchResults.addAll(contIdSet);
		Test.setFixedSearchResults(fixedSearchResults);

        Test.startTest();

        String retVal = '';
        Map<String, Object> valuesMap = new Map<String, Object>();

        retVal = HDT_LC_ContactSelection.getAdministrators(acrList[0].AccountId, '');
        for(Object obj : (List<Object>)JSON.deserializeUntyped(retVal)){
            Map<String, Object> data = (Map<String, Object>)obj;
            valuesMap.putAll(data);
        }
        //Mi aspetto un solo record di contatto corrispondente a quello che NON ha come Account quello passato nel metodo getAdministrators(acrList[0].AccountId).
        System.assertEquals(valuesMap.get('Id'), acrList[1].ContactId);

        Test.stopTest();
    }

    public static testMethod void testGetSolContacts(){

        Set<String> accIdSet = new Set<String>();
        List<AccountContactRelation> acrList = new List<AccountContactRelation>();

        for(Account acc : [SELECT Id, Name FROM Account]) accIdSet.add(acc.Id);
        acrList = [SELECT Id, AccountId, ContactId, Roles, IsManagerSOL__c, IsActive FROM AccountContactRelation WHERE AccountId = :accIdSet];
        for(AccountContactRelation acr : acrList){
            acr.IsManagerSOL__c = True;
            acr.IsActive = True;
        }
        update acrList;

        Test.startTest();
        
        String retVal = '';
        Map<String, Object> valuesMap = new Map<String, Object>();

        retVal = HDT_LC_ContactSelection.getSolContacts(acrList[0].AccountId);
        for(Object obj : (List<Object>)JSON.deserializeUntyped(retVal)){
            Map<String, Object> data = (Map<String, Object>)obj;
            valuesMap.putAll(data);
        }
        //Mi aspetto un solo record di contatto corrispondente a quello che ha come Account quello passato nel metodo getSolContacts(acrList[0].AccountId).
        System.assertEquals(valuesMap.get('Id'), acrList[0].ContactId);

        Test.stopTest();
    }
}