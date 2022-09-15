/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 25-08-2022
 * @last modified by  : Giacinto Florio
**/
@isTest
public with sharing class HDT_LC_ActiveRepentantTst {

    @TestSetup
    static void setup(){
        TermsAdministration__c terms = new TermsAdministration__c();
        terms.City__c='Roma';
        insert terms;
    
        CityTechnicalData__c cityTech = new CityTechnicalData__c();
        cityTech.CadastralCity__c='Roma';
        insert cityTech;

        TermTable__c termtable = new TermTable__c();
        termtable.City__c='Roma';
        termtable.Subtype__c='Subentro';
        termtable.CriteriaX__c='Xcriteria';
        insert termtable;
    }

    @isTest
    public static void getTermsTest() {

        Test.startTest();
        List<TermsAdministration__c> terms = HDT_LC_ActiveRepentant.getTerms('Roma');
        TermsAdministration__c term = terms[0];
        System.assertEquals(term.City__c, 'Roma', 'Occorrenza Trovata!');
        Test.stopTest();
    }

    @isTest
    public static void getTablesTest() {

        Test.startTest();
        HDT_LC_ActiveRepentant.HDT_WRP_Data data = HDT_LC_ActiveRepentant.getTables('Roma','Subentro');
        System.assertEquals(data.termsTable[0].CriteriaX__c, 'Xcriteria','Occorrenza Trovata!');
        Test.stopTest();
    }


}
