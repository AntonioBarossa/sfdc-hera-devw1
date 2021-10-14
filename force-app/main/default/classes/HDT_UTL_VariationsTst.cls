@isTest
public with sharing class HDT_UTL_VariationsTst {

    
    //DEBUG
    public static final String TEST_NAME = 'HDT_UTL_VariationsTst';
    
    
    //TEST SETUP
    
    
    //TESTS

    @isTest
    private static void consistencyCheckTest(){
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'consistencyCheckTest';
        System.debug(debugString);
        
        //SETUP
        HDT_UTL_DataFactoryTst.pClickCasePhase();        

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        Case myCase = caseList[0];
        myCase.Taxes__c = 'Imposta usi domestici';
        update myCase;
        
        //TESTING
        Test.startTest();
        Try{
            HDT_UTL_Variations.consistencyCheck(myCase.Id, '007-Ris.Ind+Cottura+AcquaCalda', 'A-Domestico', '1004-Riscaldamento promiscuo');
            
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(myCase != null, 'Attenzione, myCase non può essere null!');
        
    }
    

    @isTest
    private static void modifyRateTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'modifyRateTest';
        System.debug(debugString);
        
        //SETUP
        
        HDT_UTL_DataFactoryTst.pClickCasePhase();        

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(3, true);
        ServicePoint__c myServicePoint1 = servPointList[0];
        myServicePoint1.Account__c = accList[0].Id;
        myServicePoint1.CommoditySector__c = 'Energia Elettrica';
        update myServicePoint1;
        ServicePoint__c myServicePoint2 = servPointList[1];
        myServicePoint2.Account__c = accList[0].Id;
        myServicePoint2.CommoditySector__c = 'Energia Elettrica';
        myServicePoint2.Resident__c = true;
        update myServicePoint2;
        ServicePoint__c myServicePoint3 = servPointList[2];
        myServicePoint3.Account__c = accList[0].Id;
        myServicePoint3.CommoditySector__c = 'Energia Elettrica';
        myServicePoint3.Resident__c = true;
        update myServicePoint3;
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(2, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        Case myCase = caseList[0];
        String caseId = myCase.Id;
        Case newCase = caseList[1];
        newCase.ServicePoint__c = myServicePoint3.Id;
        newCase.Resident__c = false;
        update newCase;
        String newCaseId = newCase.Id;

        //TESTING
        Test.startTest();
        Try{
                        
            HDT_UTL_Variations.modifyRate(caseId);
            HDT_UTL_Variations.modifyRate(newCaseId);
            
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(caseId != null, 'Attenzione, caseId non può essere null!');
        System.assert(newCase != null, 'Attenzione, newCase non può essere null!');
        
    }


}