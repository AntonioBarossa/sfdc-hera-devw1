@istest
public with sharing class HDT_LC_CustomRelatedListTst {
    
    @TestSetup
    static void setup(){

        Account acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME').get(0);

        HDT_UTL_DataFactoryTst.createContact(4, true, acc.Id);
    }

    @IsTest
    static void methodName(){

        Account acc = [SELECT Id FROM Account Limit 1];
        
        Test.startTest();

        HDT_LC_CustomRelatedList.getRecordsToDisplay(acc.Id, 'Id', 'Contact', 'AccountId', 'Id,Account.Name,Individual.Name,Birthdate,Email,CreatedDate', 'Name', false, true);
        
        Test.stopTest();
        
    }
}