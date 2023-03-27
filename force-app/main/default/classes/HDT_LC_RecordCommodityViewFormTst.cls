/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 24-03-2023
 * @last modified by  : Giacinto Florio
**/
@isTest
public with sharing class HDT_LC_RecordCommodityViewFormTst {
    
    @IsTest
    static void testGetFields(){

        Case caso = new Case();
        caso.Type = 'Comunicazione Pagamento';
        caso.Commodity__c = 'Ambiente';
        insert caso;

        Test.startTest();
        String results = HDT_LC_RecordCommodityViewForm.getFields(caso.Id, '');
        System.assertNotEquals(null, results, 'results = null');
        Test.stopTest();
    }

}