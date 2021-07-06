/**
* @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
* @date 29/06/2021
* @description Data Factory for Test Classes
* @history Lucas da Silva Fernandes – 29/06/2021 – Created class
*/

public with sharing class HDT_UTL_DataFactoryTst {

    //Method to avoid 'ObjectCompatibility' errors from ProcessClick
    public static void pClickInstance() {
        
        wrts_prcgvr.InstallIntegration.install();
        wrts_prcgvr.VersionManager.newClassInstance('ObjectCompatibility');
    }

    public static Lead createLead() {

        Lead ld = new Lead();
        
        ld.FirstName = 'FirstNameTest';
        ld.LastName = 'LastNameTest';
        ld.CompanyOwner__c = 'MMS';
        ld.Company = 'CompanyTest';
        ld.Status = 'New';
        ld.Email = 'test@test.com';

        insert ld;

        return ld;
    }
    
    
}
