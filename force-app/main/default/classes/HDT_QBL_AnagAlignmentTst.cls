/*
    @Author:        Davide Viola
    CreatedDate:    07/10/2021
*/

@isTest
public class HDT_QBL_AnagAlignmentTst {

    @TestSetup
    static void setup(){
        
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(2, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        contactList.addAll(HDT_UTL_DataFactoryTst.createContact(1, true, accList[1].Id));
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].id, 'Bozza');
        ordList[0].EffectiveDate__c = Date.today()-5;
        insert ordList;
        HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        HDT_UTL_DataFactoryTst.createBillingProfile(1,true, accList[0].Id);
        HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);

    }
    @isTest
    public static void testExecute(){
        
        String rtName = 'HDT_RT_AllineamentoAnagrafica';
        String rtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_AllineamentoAnagrafica').getRecordTypeId();
        List<Case> caseList = new List<Case>();
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact cont = [SELECT Id FROM Contact LIMIT 1];
        ServicePoint__c sp = [SELECT Id FROM ServicePoint__c LIMIT 1];
        Contract contr = [SELECT Id FROM Contract LIMIT 1];
        Order ord = [SELECT Id FROM Order LIMIT 1];
        
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Da Inviare', 'Bozza', rtId, rtName,'A','','','');

        caseList = HDT_UTL_DataFactoryTst.createCase(2, false, acc.Id, cont.Id, sp.Id, contr.Id, ord.Id);
        for(Case c : caseList){
            c.RecordTypeId = rtId;
        }
        // Necessario per valorizzare i campi formula PODPDRFormula__c e ContractCode__c usati dall'arricchimento dati.
        Formula.recalculateFormulas(caseList);
        HDT_QBL_AnagAlignment anagAlign = new HDT_QBL_AnagAlignment(caseList);

        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new HDT_WS_PostSalesTstMock());
        System.enqueueJob(anagAlign);
        Test.stopTest();
        //Mi aspetto che a sistema sia stato salvato un record di case con valorizzati i campi formula:
        List<Case> newCaseList = [SELECT Id, PODPDRFormula__c, ContractCode__c FROM Case];
        System.assertEquals(1, newCaseList.size(),'case List is null');
        System.assertEquals('testServicePointCode', newCaseList[0].PODPDRFormula__c , 'PODPDRFormula__c is not assigned correctly');
        System.assertEquals('3011913470', newCaseList[0].ContractCode__c , 'ContractCode__c is not assigned correclty');
    }
    @isTest
    public static void testExecuteWithoutRecords(){
        
        List<Case> caseList = new List<Case>();
        HDT_QBL_AnagAlignment anagAlign = new HDT_QBL_AnagAlignment(caseList);
        
        Test.startTest();
        System.enqueueJob(anagAlign);
        Test.stopTest();
        //Mi aspetto che non abbia creato nessun record.
        List<Case> newCaseList = [SELECT Id, PODPDRFormula__c, ContractCode__c FROM Case];
        System.assertEquals(newCaseList.size(), 0, '');
    }
    @isTest
    public static void testExecuteException(){
        
        String rtName = 'HDT_RT_AllineamentoAnagrafica';
        String rtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_AllineamentoAnagrafica').getRecordTypeId();
        List<Case> caseList = new List<Case>();
        
        Case myCase = new Case(
        	recordTypeId = rtId
        );
        caseList.add(myCase);
        
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Da Inviare', 'Bozza', rtId, rtName,'A','','','');        
        HDT_QBL_AnagAlignment anagAlign = new HDT_QBL_AnagAlignment(caseList);
        
        Test.startTest();
        System.enqueueJob(anagAlign);
        Test.stopTest();
        //Il processo è andato in Eccezione fallendo l'arrichimento dati. Quindi mi aspetto che sia stato creato il case ma senza altri campi popolati.
        List<Case> newCaseList = [SELECT Id, PODPDRFormula__c, ContractCode__c FROM Case];
        System.assertEquals(newCaseList.size(), 1,'');
        System.assertEquals(true ,newCaseList[0].PODPDRFormula__c == null, 'PODPDRFormula__c is not Null');
        System.assertEquals(true, newCaseList[0].ContractCode__c == null, 'ContractCode__c is not Null');
    }
}