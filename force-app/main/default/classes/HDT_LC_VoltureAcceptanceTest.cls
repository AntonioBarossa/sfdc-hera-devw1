@IsTest
public with sharing class HDT_LC_VoltureAcceptanceTest {

    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
    
    @TestSetup
    static void makeData(){
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        HDT_UTL_DataFactoryTst.newPhaseTransition('Voltura Rifiutata','Accettazione Voltura',constants.ORDER_RECORDTYPEID_VOLTURA,constants.ORDER_RECORDTYPE_DEVELOPERNAME_VOLTURA);
        List<Account> acctList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Contact> contacts=HDT_UTL_DataFactoryTst.createContact(1, true, acctList[0].Id);
		List<Product2> prods=HDT_UTL_DataFactoryTst.createProduct2(1, true);
        List<Sale__c> sales=HDT_UTL_DataFactoryTst.createSale(1, true, acctList[0].Id, 'Attiva');
        Id pricebookId=Test.getStandardPricebookId();List<Order> orderWithPricebook=HDT_UTL_DataFactoryTst.createOrderWithPricebook(1, false, acctList[0].Id, sales, pricebookId);
        orderWithPricebook[0].RecordTypeId=constants.ORDER_RECORDTYPEID_VOLTURA;
        orderWithPricebook[0].CommercialProduct__c=prods[0].Id;
        orderWithPricebook[0].Phase__c = 'Accettazione Voltura';
        orderWithPricebook[0].Contact__c =contacts[0].Id;
        insert orderWithPricebook;
        wrts_prcgvr__ActivityStatusSetting__c cs = new wrts_prcgvr__ActivityStatusSetting__c();
        cs.Name='Chiusa';
        cs.wrts_prcgvr__ApiName__c='Chiusa';
        cs.wrts_prcgvr__IsClosed__c=true;
        insert cs;
        List<wrts_prcgvr__Activity__c> actList = HDT_UTL_DataFactoryTst.createActivityCustom(1,false,acctList[0].Id);
        actList[0].Order__c = orderWithPricebook[0].Id;
        actList[0].Type__c = 'Accettazione Voltura';
        insert actList;
    }

    @IsTest
    public static void testGetActivity(){
        String debugString = 'testGetActivity --> ';
        wrts_prcgvr__Activity__c activity = [SELECT id FROM wrts_prcgvr__Activity__c].get(0);
            
        Test.startTest();
            String errorMessage = '';
            try{
                HDT_LC_VoltureAcceptance.getActivity(null);
            }catch(Exception e){
                errorMessage = e.getMessage();
            }
            System.assert(errorMessage.containsIgnoreCase('Script-thrown exception'),debugString + 'eccezione non lanciata');
            activity = (wrts_prcgvr__Activity__c) JSON.deserialize(HDT_LC_VoltureAcceptance.getActivity(activity.Id),wrts_prcgvr__Activity__c.class);
            System.assert(!activity.isUserActivity__c,debugString + 'attività non restituita');
        Test.stopTest();
    }

    @IsTest
    public static void updateOrder(){
        String debugString = 'testUpdatOrder --> ';
        wrts_prcgvr__Activity__c activity = [SELECT id,Order__c FROM wrts_prcgvr__Activity__c].get(0);
        Test.startTest();
        String errorMessage = '';
        try{
            HDT_LC_VoltureAcceptance.updateOrder(activity.Id, null, 'Voltura Rifiutata');
        }catch(Exception e){
            errorMessage = e.getMessage();
        }
        System.assert(errorMessage.containsIgnoreCase('Script-thrown exception'),debugString + 'eccezione non lanciata');
        String response = HDT_LC_VoltureAcceptance.updateOrder(activity.Id, activity.Order__c, 'Voltura Rifiutata');
        System.assertEquals('OK', response, debugString + 'ordine non aggiornato');
        Test.stopTest();
    }
}
