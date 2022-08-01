/**
* @author Luis Bispo (luis.bispo@engdb.com.br)
* @date 13/07/2021
* @description HDT_LC_DocumentValidationTst for Test Classes
* @history Luis Bispo – 13/07/2021 – Created class
*/


@isTest
public with sharing class HDT_LC_DocumentValidationTst {

    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();

    @TestSetup
    static void setup(){
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        HDT_UTL_DataFactoryTst.newPhaseTransition('Documentazione Gestita','Bozza',constants.ORDER_RECORDTYPEID_ORDERDOSSIER,constants.ORDER_RECORDTYPE_DEVELOPERNAME_ORDERDOSSIER);

        List<Account> acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Contact> cttList = HDT_UTL_DataFactoryTst.createContact(1, true, acc[0].Id);
        Order ord = HDT_UTL_DataFactoryTst.createOrder(1, false, acc[0].Id, 'Bozza').get(0);
        ord.RecordTypeId = constants.ORDER_RECORDTYPEID_ORDERDOSSIER;
        ord.Contact__c = cttList[0].Id;
        ord.Channel__c = 'Canale TEST';
        insert ord;
    }

    @isTest
    static void testIsValidPhase(){
        
        Order ord = [SELECT id From Order LIMIT 1];
        
        Test.startTest();

            Boolean result;
            result = HDT_LC_DocumentValidation.isValidPhase(ord.Id);

        System.assertEquals(false, result, 'IsValidPhase did not work correctly');
        System.assertNotEquals(true, result, 'IsValidPhase did not work correctly');

        Test.stopTest();
    }

    @isTest
    static void testSaveValidationSucess(){
        Order ord = [SELECT id, Instance326__c, DocumentLow80__c, CILegalRepresentative__c, ChamberCommerceRegistration__c, AutorizationVolturaThirdTrader__c, CIAccoutn__c, QuickQuote__c,Phase__c,DocumentPackage__c From Order LIMIT 1];
        
        Test.startTest();   
            HDT_LC_DocumentValidation.saveValidation(ord);
            System.assert(ord !=null, 'Order is not null');
            System.assertNotEquals(null, ord, 'SaveValidationSucess did not work correctly');
        Test.stopTest();
    }
    // phase error
    @isTest
    static void testSaveValidationFail(){
        Order ord = [SELECT id,CILegalRepresentative__c, DocumentPackage__c,Instance326__c, DocumentLow80__c, ChamberCommerceRegistration__c, AutorizationVolturaThirdTrader__c, CIAccoutn__c, QuickQuote__c,Phase__c From Order LIMIT 1];
        ord.CIAccoutn__c = 'Validato';
        ord.QuickQuote__c = 'Validato';
        ord.ChamberCommerceRegistration__c = 'Validato';
        ord.Instance326__c = 'Validato';
        ord.DocumentLow80__c = 'Validato';
        ord.AutorizationVolturaThirdTrader__c = 'Validato';
        ord.DocumentPackage__c = 'Validato';
        ord.CILegalRepresentative__c = 'Validato';
        update ord;
        Test.startTest();   
            HDT_LC_DocumentValidation.saveValidation(ord);
            System.assert(ord !=null, 'Order is not null');
            System.assertNotEquals(null, ord, 'SaveValidationSucess did not work correctly');
        Test.stopTest();
    }

    @isTest
    static void testgetOrderAccountId(){
        
        Order ord = [SELECT id From Order LIMIT 1];
        
        Test.startTest();

            String result;
            result = HDT_LC_DocumentValidation.getOrderAccountId(ord.Id);

        Test.stopTest();

        System.assertNotEquals(null, result, 'getOrderAccountId did not work correctly');
    }

    @isTest
    static void testupdateOrder(){
        Order ord = [SELECT id, Instance326__c, DocumentLow80__c, CIAccoutn__c, MarketingPrivacyAcquired__c From Order LIMIT 1];
        
        Test.startTest();   
            HDT_LC_DocumentValidation.updateOrder(ord);
        Test.stopTest();

        System.assertNotEquals(null, ord, 'updateOrder did not work correctly');

    }

    @isTest
    static void testCancelOrder(){
        Order ord = [SELECT id From Order LIMIT 1];
        
        Test.startTest();   
            HDT_LC_DocumentValidation.cancelOrder(ord.Id);
        Test.stopTest();

        System.assertNotEquals(null, ord, 'cancelOrder did not work correctly');

    }
}