@isTest
public class HDT_LC_RecordEditFormFlowControllerTst {
    
    @TestSetup
    static void setup(){
        
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        List<Lead> leadList = HDT_UTL_DataFactoryTst.createLead(1, true);
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<BillingProfile__c> billingProfileList = HDT_UTL_DataFactoryTst.createBillingProfile(1,true, accList[0].Id);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, false);
        servPointList[0].Account__c = accList[0].Id;
        insert servPointList;
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].id, 'Bozza');
        ordList[0].ServicePoint__c = servPointList[0].Id;
        ordList[0].Cluster__c = 'Attivazioni';
        ordList[0].ProcessType__c = 'Subentro Gas';
        insert ordList;
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, false, accList[0].id);
        contractList[0].ServicePoint__c = servPointList[0].Id;
        contractList[0].Status = 'Attivo';
        insert contractList;
        
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(2, false, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        caseList[0].BillingProfile__c = billingProfileList[0].Id;
        caseList[0].RecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_Autolettura').getRecordTypeId();
        caseList[0].Phase__c  = 'Inviata a SAP';
        caseList[0].Type  = 'Autolettura da cliente';
        caseList[0].Market__c = 'Libero';
        caseList[0].SalesCompany__c = 'TestCompany';

        caseList[1].RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_Informative').getRecordTypeId();
        caseList[1].Type = 'Informative';
        
        insert caseList;
        
        String rtName = 'HDT_RT_Autolettura';
        String rtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_Autolettura').getRecordTypeId();
        String rtNameInformative = 'HDT_RT_Informative';
        String rtIdInformative = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_Informative').getRecordTypeId();
        
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Inviata a SAP', 'Bozza', rtId, rtName,'A','','','');

        List<Opportunity> oppList = HDT_UTL_DataFactoryTst.createOpportunity(1, true);

        List<ContentVersion> contentVersion = HDT_UTL_DataFactoryTst.createContentVers(1, true);

        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentVersion[0].Id].ContentDocumentId;

        List<ContentDocumentLink> contentDocLinkList = HDT_UTL_DataFactoryTst.createContentDocumentLink(1, false, oppList[0].Id, contentDocumentId);
        contentDocLinkList[0].LinkedEntityId=accList[0].Id;
        insert contentDocLinkList;

    }

    @IsTest
    static void testGetFields(){

        String processType = 'Altri Venditori';
        
        Test.startTest();

        String results = HDT_LC_RecordEditFormFlowController.getFields(processType);

        System.assertNotEquals(null, results, 'results = null');

        Test.stopTest();
        
    }

    @IsTest
    static void testPrePopulateFieldsFromCase(){

        Case caseToPopulate = [SELECT Id FROM Case WHERE Type <> 'Autolettura da cliente' LIMIT 1];
        Case caseToCopy = [SELECT Id FROM Case WHERE Type = 'Autolettura da cliente' LIMIT 1];
        
        Test.startTest();
        
        String results = HDT_LC_RecordEditFormFlowController.prePopulateFields(caseToPopulate.Id, caseToCopy.Id);

        Case updatedCase = [SELECT Id, Market__c, InformativeType__c, SalesCompany__c FROM Case WHERE Id =: caseToPopulate.Id LIMIT 1];
        System.assertEquals('Libero', updatedCase.Market__c, 'Market__c != Libero');
        System.assertEquals('Autolettura da cliente', updatedCase.InformativeType__c, 'InformativeType__c != Autolettura da cliente');

        Test.stopTest();
        
    }

    @IsTest
    static void testPrePopulateFieldsFromOrder(){

        Case caseToPopulate = [SELECT Id FROM Case WHERE Type = 'Informative' LIMIT 1];
        Order orderToCopy = [SELECT Id FROM Order WHERE Cluster__c = 'Attivazioni' LIMIT 1];
        
        Test.startTest();
        
        String results = HDT_LC_RecordEditFormFlowController.prePopulateFields(caseToPopulate.Id, orderToCopy.Id);

        Case updatedCase = [SELECT Id, InformativeType__c, InformativeCluster__c FROM Case WHERE Id =: caseToPopulate.Id LIMIT 1];
        System.assertEquals('Subentro Gas', updatedCase.InformativeType__c, 'InformativeType__c != Subentro Gas');
        System.assertEquals('Attivazioni', updatedCase.InformativeCluster__c, 'InformativeCluster__c != Attivazioni');

        Test.stopTest();
        
    }

    @IsTest
    static void testPrePopulateFieldsFromServicePoint(){

        Case caseToPopulate = [SELECT Id FROM Case WHERE Type <> 'Autolettura da cliente' LIMIT 1];
        ServicePoint__c svToCopy = [SELECT Id FROM ServicePoint__c LIMIT 1];
        
        Test.startTest();
        
        String results = HDT_LC_RecordEditFormFlowController.prePopulateFields(caseToPopulate.Id, svToCopy.Id);

        Case updatedCase = [SELECT Id, ServicePoint__c FROM Case WHERE Id =: caseToPopulate.Id LIMIT 1];
        System.assertEquals(svToCopy.Id, updatedCase.ServicePoint__c, 'ServicePoint__c != svToCopy');

        Test.stopTest();
        
    }

    @IsTest
    static void testPrePopulateFieldsFromBillingProfile(){

        Case caseToPopulate = [SELECT Id FROM Case WHERE Type <> 'Autolettura da cliente' LIMIT 1];
        BillingProfile__c billingProfileToCopy = [SELECT Id FROM BillingProfile__c LIMIT 1];
        
        Test.startTest();
        
        String results = HDT_LC_RecordEditFormFlowController.prePopulateFields(caseToPopulate.Id, billingProfileToCopy.Id);

        Case updatedCase = [SELECT Id, BillingProfile__c FROM Case WHERE Id =: caseToPopulate.Id LIMIT 1];
        System.assertEquals(billingProfileToCopy.Id, updatedCase.BillingProfile__c, 'BillingProfile__c != billingProfileToCopy');

        Test.stopTest();
        
    }

    @IsTest
    static void testPrePopulateFieldsFromAccount(){

        Case caseToPopulate = [SELECT Id FROM Case WHERE Type <> 'Autolettura da cliente' LIMIT 1];
        Account accountToCopy = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        
        String results = HDT_LC_RecordEditFormFlowController.prePopulateFields(caseToPopulate.Id, accountToCopy.Id);

        Case updatedCase = [SELECT Id, AccountId FROM Case WHERE Id =: caseToPopulate.Id LIMIT 1];
        System.assertEquals(accountToCopy.Id, updatedCase.AccountId, 'AccountId != accountToCopy');

        Test.stopTest();
        
    }

    @IsTest
    static void testPrePopulateFieldsFromContat(){

        Case caseToPopulate = [SELECT Id FROM Case WHERE Type <> 'Autolettura da cliente' LIMIT 1];
        Contact contactToCopy = [SELECT Id FROM Contact LIMIT 1];
        
        Test.startTest();
        
        String results = HDT_LC_RecordEditFormFlowController.prePopulateFields(caseToPopulate.Id, contactToCopy.Id);

        Case updatedCase = [SELECT Id, ContactId FROM Case WHERE Id =: caseToPopulate.Id LIMIT 1];
        System.assertEquals(contactToCopy.Id, updatedCase.ContactId, 'ContactId != contactToCopy');

        Test.stopTest();
        
    }

    @IsTest
    static void testPrePopulateFieldsFromLead(){

        Case caseToPopulate = [SELECT Id FROM Case WHERE Type <> 'Autolettura da cliente' LIMIT 1];
        Lead leadToCopy = [SELECT Id FROM Lead LIMIT 1];
        
        Test.startTest();
        
        String results = HDT_LC_RecordEditFormFlowController.prePopulateFields(caseToPopulate.Id, leadToCopy.Id);

        Case updatedCase = [SELECT Id, ContactId, Lead__c FROM Case WHERE Id =: caseToPopulate.Id LIMIT 1];
        System.assertEquals(leadToCopy.Id, updatedCase.Lead__c, 'Lead__c != leadToCopy');

        Test.stopTest();
        
    }

    @IsTest
    static void testGetFieldToPrePopulate(){
        
        Test.startTest();
        
        Case cs = [SELECT Id FROM Case WHERE Type = 'Informative' LIMIT 1];

        Case updatedCase = HDT_LC_RecordEditFormFlowController.getFieldToPrePopulate(cs.Id);

        System.assert(updatedCase != null, 'updatedCase == null');

        Test.stopTest();
        
    }

    @IsTest
    static void testValidateRecord(){
        
        Test.startTest();

        Case cs = [SELECT Id FROM Case WHERE Type = 'Informative' LIMIT 1];

        String validateClass = 'HDT_UTL_CaseValidations';
        String fields = '';

        String results = HDT_LC_RecordEditFormFlowController.validateRecord(validateClass, fields, cs.Id);
        System.assertNotEquals(null, results, 'results = null');

        //Case with validateClass = null
        String results2 = HDT_LC_RecordEditFormFlowController.validateRecord(null, fields, cs.Id);

        HDT_UTL_CaseValidationWrapper res = (HDT_UTL_CaseValidationWrapper) JSON.deserialize(results2, HDT_UTL_CaseValidationWrapper.class);
        System.assertEquals('OK', res.outcomeCode, 'outcomeCode != OK');
        System.assertEquals('Success', res.outcomeDescription, 'outcomeDescription != Success');

        Test.stopTest();
        
    }

    @IsTest
    static void testGetOptions(){
        
        Case cs = [SELECT Id FROM Case WHERE Type = 'Informative' LIMIT 1];

        Test.startTest();

        String serviceClass = 'HDT_SRV_InformativeManager';
        Map<String, String> paramsMap = new Map<String, String>();
        paramsMap.put('method', 'cluster');
        paramsMap.put('context', cs.Id);

        String params = JSON.serialize(paramsMap);

        String results = HDT_LC_RecordEditFormFlowController.getOptions(serviceClass, params);

        System.assertNotEquals(null, results, 'results = null');

        Test.stopTest();
        
    }

    @IsTest
    static void testGetContentDocs(){

        Account acc = [SELECT Id FROM Account LIMIT 1];

        ContentDocumentLink contDocLink = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId=:acc.Id LIMIT 1];
        
        Test.startTest();

        List<ContentDocument> contentDocList = HDT_LC_RecordEditFormFlowController.getContentDocs(acc.Id);

        System.assert(contentDocList.size() > 0, 'contentDocList.size() = 0 or contentDocList = null');

        Test.stopTest();
        
    }

}
