/*
    @Author:        Francesco Vitiello
    CreatedDate:    29/09/2021
*/

@isTest
public with sharing class HDT_UTL_PostSalesCriteriaManagerTst {

    
    //DEBUG
    public static final String TEST_NAME = 'HDT_UTL_PostSalesCriteriaManagerTst';
    
    
    //TEST SETUP
    
    @TestSetup
    static void makeData(){
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        List<Account> residentialAccounts=HDT_UTL_DataFactoryTst.createAccountResidenziale(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
        List<Contact> residentialContacts=HDT_UTL_DataFactoryTst.createContact(1, true, residentialAccounts[0].Id);
        List<ServicePoint__c> servicePoits=HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contract> contracts=HDT_UTL_DataFactoryTst.createContract(1, true, residentialAccounts[0].Id);
        List<Order> orders=HDT_UTL_DataFactoryTst.createOrder(1, true, residentialAccounts[0].Id, 'Bozza');
        List<Case> cases=HDT_UTL_DataFactoryTst.createCaseDocumentale(2, true, residentialAccounts[0].Id, residentialContacts[0].Id, servicePoits[0].Id, contracts[0].Id, orders[0].Id);
        HDT_UTL_DataFactoryTst.createDocumentSelected(1,true, false, cases[0].Id, 'TEST001HDT');
        HDT_UTL_DataFactoryTst.createActivityWithParams(1, true, residentialAccounts[0].Id,new Map<String,Object>{
            'Order__c'=>orders[0].Id,'Type__c'=>'Valori non corrispondenti','wrts_prcgvr__IsClosed__c'=>false
        });
        HDT_UTL_DataFactoryTst.createActivityWithParams(1, true, residentialAccounts[0].Id,new Map<String,Object>{
            'Order__c'=>orders[0].Id,'Type__c'=>'Dati tecnici ricevuti_ Extra-sistema','wrts_prcgvr__IsClosed__c'=>false
        });
        HDT_UTL_DataFactoryTst.createActivityWithParams(1, true, residentialAccounts[0].Id,new Map<String,Object>{
            'Case__c'=>cases[0].Id,'Type__c'=>'Gestione Back Office','wrts_prcgvr__IsClosed__c'=>true
        });
        
        
    }
    
    //TESTS

    @isTest
    private static void distributorManagementTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'distributorManagementTest';
        System.debug(debugString);
        
        //SETUP
        
        String phaseStory = 'Pratica non gestita per il DL';

        //TESTING
        Test.startTest();
        Try{
            HDT_UTL_PostSalesCriteriaManager myClass = new HDT_UTL_PostSalesCriteriaManager();            
            myClass.distributorManagement(phaseStory);
            
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(phaseStory != null, 'Attenzione, phaseStory non può essere null!');
        
    }

    @isTest
    private static void secondAdmissibilityTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'secondAdmissibilityTest';
        System.debug(debugString);
        
        //SETUP
        
        String phaseStory = 'Preventivo Accettato';

        //TESTING
        Test.startTest();
        Try{
            
            HDT_UTL_PostSalesCriteriaManager myClass = new HDT_UTL_PostSalesCriteriaManager();            
            myClass.secondAdmissibility(phaseStory);
            
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(phaseStory != null, 'Attenzione, phaseStory non può essere null!');
        
    }

    @isTest
    private static void notExecWorksTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'notExecWorksTest';
        System.debug(debugString);
        
        //SETUP
        
        String phaseStory = 'Dati Tecnici Ricevuti';

        //TESTING
        Test.startTest();
        Try{
            
            HDT_UTL_PostSalesCriteriaManager myClass = new HDT_UTL_PostSalesCriteriaManager();            
            myClass.notExecWorks(phaseStory);
            
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(phaseStory != null, 'Attenzione, phaseStory non può essere null!');
        
    }

    /**
    * @author Cristiano Salvati (c.salvaty@key2.it)
    * @date 25/10/2022
    * @description HDT_UTL_PostSalesCriteriaManagerTst – totalResidueNotNull test method
    */

    @isTest
    static void totalResidueNotNullTst(){
        Boolean result=false;
        List<SObject> senders=[SELECT Id,TotalResidue__c FROM Case WHERE TotalResidue__c >0.00 WITH SECURITY_ENFORCED LIMIT 1];
        Test.startTest();
        result=new HDT_UTL_PostSalesCriteriaManager().totalResidueNotNull(senders[0]);
        Test.stopTest();
        System.assertEquals(true, result, 'total residue is not null');
    }

    /**
    * @author Cristiano Salvati (c.salvaty@key2.it)
    * @date 25/10/2022
    * @description HDT_UTL_PostSalesCriteriaManagerTst – totalResidueNull test method
    */

    @isTest
    static void totalResidueNullTst(){
        Boolean result=false;
        List<SObject> senders=[SELECT Id,TotalResidue__c FROM Case WHERE TotalResidue__c=0.00 WITH SECURITY_ENFORCED LIMIT 1];
        Test.startTest();
        result=new HDT_UTL_PostSalesCriteriaManager().totalResidueNull(senders[0]);
        Test.stopTest();
        System.assertEquals(true, result, 'total residue is null');
    }

    /**
    * @author Cristiano Salvati (c.salvaty@key2.it)
    * @date 25/10/2022
    * @description HDT_UTL_PostSalesCriteriaManagerTst – areActivityOpen test method
    */

    @isTest
    static void areActivityOpenTst(){
        List<Order> orders=[SELECT Id FROM Order WITH SECURITY_ENFORCED LIMIT 1];
        Boolean result=true;
        Test.startTest();
        result=new HDT_UTL_PostSalesCriteriaManager().areActivityOpen(orders[0].Id);
        Test.stopTest();
        System.assertEquals(false, result,'Activity list is not empty');
    }

    @isTest
    static void activityLetturaNonInseritaInSapPresenteTst(){
        List<Case> cases=[SELECT Id,TotalResidue__c FROM Case WHERE TotalResidue__c >0.00 WITH SECURITY_ENFORCED LIMIT 1];
        Boolean result=true;
        Test.startTest();
        result=new HDT_UTL_PostSalesCriteriaManager().activityLetturaNonInseritaInSapPresente(cases[0].Id);
        Test.stopTest();
        System.assertEquals(true, result,'Activity list is not empty');
    }

    @isTest
    static void activityLetturaNonInseritaInSapAssentiTst(){
        List<Case> cases=[SELECT Id,TotalResidue__c FROM Case WHERE TotalResidue__c >0.00 WITH SECURITY_ENFORCED LIMIT 1];
        Boolean result=false;
        Test.startTest();
        result=new HDT_UTL_PostSalesCriteriaManager().activityLetturaNonInseritaInSapAssenti(cases[0].Id);
        Test.stopTest();
        System.assertEquals(false, result,'Activity list is not empty');
    }

    @isTest
    static void isRapidoToAnaliticoTst(){
        List<wrts_prcgvr__Activity__c> activities=[SELECT Id,Order__c FROM wrts_prcgvr__Activity__c WHERE Type__c='Dati tecnici ricevuti_ Extra-sistema' WITH SECURITY_ENFORCED LIMIT 1];
        Boolean result=false;
        Test.startTest();
        result=new HDT_UTL_PostSalesCriteriaManager().isRapidoToAnalitico(activities[0].Order__c);
        Test.stopTest();
        System.assertEquals(true, result, 'Activity list not empty');

    }

    


}