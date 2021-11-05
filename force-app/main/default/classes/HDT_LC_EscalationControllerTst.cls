@isTest
public with sharing class HDT_LC_EscalationControllerTst {
    @TestSetup
    static void makeData(){
        Account account = HDT_UTL_DataFactoryTst.createAccountPartner(1, false, 'Mario Rossi')[0];
        account.CompanyOwner__c = 'MMS';
        insert account;
        HDT_UTL_DataFactoryTst.createLead(1, true);
        HDT_UTL_DataFactoryTst.createOpportunity(1, true);
        Order order = HDT_UTL_DataFactoryTst.createOrder(1, true, account.Id, '')[0];
        HDT_UTL_DataFactoryTst.createCase(1, true, account.Id, null, null, null, order.Id);

        insert new Interaction__c(

        );
    }

    @IsTest
    static void methodName(){
        String result;
        Test.startTest();

        Account account = [SELECT Id FROM Account];
        result = HDT_LC_EscalationController.getRecordData(account.Id);
        System.assert(result.contains('Account__c'));
        
        Lead lead = [SELECT Id FROM Lead];
        result = HDT_LC_EscalationController.getRecordData(lead.Id);
        System.assert(result.contains('Lead__c'));
        
        Opportunity opportunity = [SELECT Id FROM Opportunity];
        result = HDT_LC_EscalationController.getRecordData(opportunity.Id);
        System.assert(result.contains('Opportunity__c'));
        
        Order order = [SELECT Id FROM Order];
        result = HDT_LC_EscalationController.getRecordData(order.Id);
        System.assert(result.contains('Order__c'));
        
        Case caseRecord = [SELECT Id FROM Case];
        result = HDT_LC_EscalationController.getRecordData(caseRecord.Id);
        System.assert(result.contains('Case__c'));
        
        Interaction__c interaction = [SELECT Id FROM Interaction__c];
        result = HDT_LC_EscalationController.getRecordData(interaction.Id);
        System.assert(result.contains('Interaction__c'));

        result = HDT_LC_EscalationController.getRecordData(null);
        System.assert(!result.contains('parentEntityField'));

        Test.stopTest();
    }
}
