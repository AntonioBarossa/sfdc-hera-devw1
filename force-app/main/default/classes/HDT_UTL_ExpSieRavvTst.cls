/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 04-11-2022
 * @last modified by  : Giacinto Florio
**/
@isTest
public with sharing class HDT_UTL_ExpSieRavvTst {
    
    @TestSetup
    static void makedata(){     
        
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        Account acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME')[0];
        Order ord = HDT_UTL_DataFactoryTst.createOrder(1, true, acc.id, 'Bozza')[0];
        Contact contact = HDT_UTL_DataFactoryTst.createContact(1, true, acc.Id)[0];
        ServicePoint__c servPoint = HDT_UTL_DataFactoryTst.createServicePoint(1, true)[0]; 
        Contract contract = HDT_UTL_DataFactoryTst.createContract(1, true, acc.Id)[0];
        HDT_UTL_DataFactoryTst.createCase(1, true, acc.Id, contact.Id, servPoint.Id, contract.Id, ord.Id);
    }

    @isTest
    public static void createExportOrderTest() {

        Test.startTest();
        Order ordine = [Select id From Order LIMIT 1];
        ordine.BillingCategory__c = 'C';
        update ordine;
        HDT_WRP_SieRavvExport wrapper = new HDT_WRP_SieRavvExport();
        wrapper.period   = '';
        wrapper.subtype  = '';
        wrapper.cityCode = '';
        wrapper.declarationDate = System.today();
        wrapper.effectiveDate   = System.today();
        wrapper.limitDateX      = System.today();
        wrapper.missingDue = 'N';
        wrapper.record = ordine;

        HDT_UTL_ExpSieRavv.createExportSobjects(wrapper);
        System.assertEquals(ordine.BillingCategory__c,'C','Test OK');
        Test.stopTest();
    }

    @isTest
    public static void createExportCaseTest() {

        Test.startTest();
        Case caso = [SELECT Id, RonchiCode__c FROM Case LIMIT 1];
        caso.Subprocess__c = 'NON DOM_ISTAT/Ronchi';
        caso.BillingCategory__c = 'C';
        update caso;
        HDT_WRP_SieRavvExport wrapper = new HDT_WRP_SieRavvExport();
        wrapper.period   = 'Y';
        wrapper.subtype  = '';
        wrapper.cityCode = '';
        wrapper.declarationDate = System.today();
        wrapper.effectiveDate   = System.today();
        wrapper.limitDateX      = System.today();
        wrapper.missingDue = 'N';

        HDT_UTL_ExpSieRavv.HDT_WRP_InvocableInput invInput = new HDT_UTL_ExpSieRavv.HDT_WRP_InvocableInput();
        invInput.wrap=wrapper;
        invInput.caso=caso;

        HDT_UTL_ExpSieRavv.createExportSobjectsInvocable(new List<HDT_UTL_ExpSieRavv.HDT_WRP_InvocableInput>{invInput});
        System.assertEquals(caso.BillingCategory__c,'C','Test OK');
        Test.stopTest();
    }


    
}
