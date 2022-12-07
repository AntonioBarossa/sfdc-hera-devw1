@IsTest
private class HDT_BA_DocumentalManagementIdricoBulkTst {
    @TestSetup
    static void setUp(){
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        Id consumoAnomaloRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_ConsumoAnomaloIdrico').getRecordTypeId();
        HDT_UTL_DataFactoryTst.newPhaseTransition('Comunicazionee EngageOne KO', 'in attesa processo doc massivo', consumoAnomaloRTId, 'HDT_RT_ConsumoAnomaloIdrico');
        HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa esito EngageOne', 'in attesa processo doc massivo', consumoAnomaloRTId, 'HDT_RT_ConsumoAnomaloIdrico');
        Integer amount=1;
        List<Account> accs = HDT_UTL_DataFactoryTst.createAccountResidenziale(amount, false, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
        for(Account tmp:accs){
            tmp.SAPIntegrationID__c=tmp.CustomerCode__c;
        }
        insert accs;
        List<ServicePoint__c> servPoint=new List<ServicePoint__c>();
        Integer k=0;
        for(ServicePoint__c sp: HDT_UTL_DataFactoryTst.createServicePoint(amount, false)) {
            sp.ServicePointCode__c=sp.ServicePointCode__c+k;
            servPoint.add(sp);
            k++;
        }
        insert servPoint;
        k=0;
        List<Contact>contactList= HDT_UTL_DataFactoryTst.createContact(amount, false, accs[0].Id);
        for(Contact c:contactList){
            c.AccountId=accs[k].Id;
            k++;
        }
        insert contactList;
        k=0;
        List<BillingProfile__c>billingProfList=HDT_UTL_DataFactoryTst.createBillingProfile(amount, false, accs[0].Id);
        for(BillingProfile__c tmpBill:billingProfList){
            tmpBill.Account__c=accs[k].Id;
            tmpBill.InvoicingCity__c='Roma';
            tmpBill.InvoicingCountry__c='Italia';
            tmpBill.InvoicingPlace__c='Test';
            tmpBill.InvoicingPostalCode__c='00160';
            tmpBill.InvoicingProvince__c='RM';
            tmpBill.InvoicingStreetName__c='Via test';
            tmpBill.InvoicingStreetNumber__c='15';
            tmpBill.InvoiceEmailAddress__c='testinvoice@gmail.com';
            k++;
        }
        insert billingProfList;
        k=0;
        List<Contract> cont = new List<Contract>();
        for(Contract tmp:HDT_UTL_DataFactoryTst.createContract(amount, false, accs[0].Id)){
            tmp.ServicePoint__c = servPoint[k].Id;
            tmp.SAPContractCode__c = '301960232'+k;
            tmp.AccountId=accs[k].Id;
            tmp.Contact__c=contactList[k].Id;
            tmp.BillingProfile__c=billingProfList[k].Id;
            cont.add(tmp);
            k++;
        }
        insert cont;
        List<Case>bulkIdricoCases=new List<Case>();
        bulkIdricoCases.addAll(HDT_UTL_DataFactoryTst.createCaseAnomaloIdricoBulk(1, false, accs[0].Id, servPoint[0].Id, cont[0].Id,billingProfList[0].Id,'Cartacea','Posta Cartacea'));
        insert bulkIdricoCases;
    }
    @IsTest
    static void executeBatchTst() {
        Test.startTest();
        Database.executeBatch(new HDT_BA_DocumentalManagementIdricoBulk(),1);
        Test.stopTest();
        List<Case> caseList=[SELECT Id,Type,Phase__c FROM Case];
        System.assertEquals('In attesa esito EngageOne',caseList[0].Phase__c,'case phase changed');
    }
}