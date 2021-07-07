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

    public static List<Lead> createLead(Integer amount, Boolean doInsert) {

        List<Lead> leadList = new List<Lead>();

        for (Integer i=0; i<amount; i++) {

            Lead ld = new Lead();
            
            ld.FirstName = 'FirstNameTest'+i;
            ld.LastName = 'LastNameTest';
            ld.CompanyOwner__c = 'MMS';
            ld.Company = 'CompanyTest';
            ld.Status = 'New';
            ld.Email = 'test@test.com';

            leadList.add(ld);

        }
        
        if (doInsert) {

            insert leadList;
        }

        return leadList;
    }
    
    public static List<Opportunity> createOpportunity (Integer amount, Boolean doInsert) {

        List<Opportunity> oppList = new List<Opportunity>();

        for (Integer i=0; i<amount; i++) {

            Opportunity opp = new Opportunity();

            opp.Name = 'testOpportunity'+ i;
            opp.CloseDate = Date.today().addDays(30);
            opp.StageName = 'Negotiation';

            oppList.add(opp);
        }        

        if (doInsert) {

            insert oppList;
        }

        return oppList;
    }

    
}