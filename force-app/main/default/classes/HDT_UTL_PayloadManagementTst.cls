@isTest
public with sharing class HDT_UTL_PayloadManagementTst {
    
    //DEBUG
    
    //DATA
    
    
    //TEST SETUP
    private static void mySetup(){
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
    }

    
    //TESTS
    
    //execute
    //TODO: IMPLEMENTAZIONE (A PESO LEGGERO)
    
    
    //handleAmountVas
    @isTest
    private static void handleAmountVasTest(){
        
        //SETUP
        OrderItem myItem = new OrderItem();
        myItem.UnitPrice = 35.5;
        myItem.PriceNetDiscounted__c = 30.5;
        myItem.Quantity = 1.0;
        
        List<SObject> itemVasList = new List<SObject>();
        itemVasList.add(myItem);
        
        Map<String,List<SObject>> inputs = new Map<String,List<SObject>>();
        inputs.put('ItemVAS', itemVasList);

        
        Map<String,Object> formParams = new Map<String,Object>();
        
        
        //TESTING objectString (ItemVAS not null)
        HDT_UTL_PayloadManagement myObjectToTest = new HDT_UTL_PayloadManagement();
        String result = myObjectToTest.handleAmountVas(inputs, formParams);
        
        //ASSERTS
        String toTest = myItem.UnitPrice + '|' + myItem.PriceNetDiscounted__c + '|' + myItem.Quantity;
        System.assert(toTest.equalsIgnoreCase(result), 'Stringa differente - result: ' + result + ' - toTest' + toTest);
    }
    
    
    //handleFlagDeliveryAddress
    
    
    
    //handleFlagPaperless
    
    
    
    //calculateCompanyCode
    
    
    
    //checkQuotationType
    
    
    
    //calculateQuotationAmount
    
    
    
    //checkGruppoIva
    
    
    
    //checkCommercialOffer
    
    
    
    //generateSection20
    
    
    
    //generateSection40
    
    
    
    //generateSection50
    
    
    
    //generateSection70
    
    
    
    //generateSectionReclami
    
    
    
    //calculateSignModeDriver
    
    
    
    //calculateDriverCatalogo
    
    
    
    //calculateIndemnityBox
    @isTest
    static void calculateIndemnityBoxTest() {
        
        //SETUP
        Test.startTest();
        
        String complaintClassification = 'Reclamo Scritto';
        Boolean indemnityConfirmed = True;
        String indemnityMotivation = null;
        String correctionRight = 'No';
        Boolean expiredCorrection = False;
        String correctionDocumentEmissionDate = null;
        Decimal indemnityDueSendResponse = 0;
        String boxType = HDT_UTL_PayloadManagement.calculateIndemnityBox(complaintClassification, indemnityConfirmed, indemnityMotivation, correctionRight, expiredCorrection, correctionDocumentEmissionDate, indemnityDueSendResponse);
        System.assertEquals('1', boxType);

        complaintClassification = 'Reclamo Scritto';
        indemnityConfirmed = True;
        indemnityMotivation = null;
        correctionRight = 'Si';
        expiredCorrection = False;
        correctionDocumentEmissionDate = String.valueOf(Date.today());
        boxType = HDT_UTL_PayloadManagement.calculateIndemnityBox(complaintClassification, indemnityConfirmed, indemnityMotivation, correctionRight, expiredCorrection, correctionDocumentEmissionDate, indemnityDueSendResponse);
        System.assertEquals('1', boxType);

        complaintClassification = 'Reclamo Scritto';
        indemnityConfirmed = True;
        indemnityMotivation = null;
        correctionRight = 'Si';
        expiredCorrection = True;
        correctionDocumentEmissionDate = String.valueOf(Date.today());
        boxType = HDT_UTL_PayloadManagement.calculateIndemnityBox(complaintClassification, indemnityConfirmed, indemnityMotivation, correctionRight, expiredCorrection, correctionDocumentEmissionDate, indemnityDueSendResponse);
        System.assertEquals('2', boxType);

        complaintClassification = 'Reclamo Scritto';
        indemnityConfirmed = True;
        indemnityMotivation = null;
        correctionRight = 'Si';
        expiredCorrection = True;
        correctionDocumentEmissionDate = String.valueOf(Date.today());
        boxType = HDT_UTL_PayloadManagement.calculateIndemnityBox(complaintClassification, indemnityConfirmed, indemnityMotivation, correctionRight, expiredCorrection, correctionDocumentEmissionDate, 25);
        System.assertEquals('4', boxType);

        complaintClassification = 'Reclamo Scritto';
        indemnityConfirmed = True;
        indemnityMotivation = null;
        correctionRight = 'Si';
        expiredCorrection = True;
        correctionDocumentEmissionDate = null;
        boxType = HDT_UTL_PayloadManagement.calculateIndemnityBox(complaintClassification, indemnityConfirmed, indemnityMotivation, correctionRight, expiredCorrection, correctionDocumentEmissionDate, indemnityDueSendResponse);
        System.assertEquals('5', boxType);

        complaintClassification = 'Reclamo Scritto';
        indemnityConfirmed = True;
        indemnityMotivation = null;
        correctionRight = 'Si';
        expiredCorrection = False;
        correctionDocumentEmissionDate = null;
        boxType = HDT_UTL_PayloadManagement.calculateIndemnityBox(complaintClassification, indemnityConfirmed, indemnityMotivation, correctionRight, expiredCorrection, correctionDocumentEmissionDate, indemnityDueSendResponse);
        System.assertEquals('1', boxType);

        complaintClassification = 'Rettifica Doppia Fatturazione';
        indemnityConfirmed = True;
        indemnityMotivation = null;
        correctionRight = 'Si';
        expiredCorrection = True;
        correctionDocumentEmissionDate = null;
        boxType = HDT_UTL_PayloadManagement.calculateIndemnityBox(complaintClassification, indemnityConfirmed, indemnityMotivation, correctionRight, expiredCorrection, correctionDocumentEmissionDate, indemnityDueSendResponse);
        System.assert(String.isBlank(boxType));

        complaintClassification = 'Rettifica Doppia Fatturazione';
        indemnityConfirmed = True;
        indemnityMotivation = null;
        correctionRight = 'Si';
        expiredCorrection = False;
        correctionDocumentEmissionDate = String.valueOf(Date.today());
        boxType = HDT_UTL_PayloadManagement.calculateIndemnityBox(complaintClassification, indemnityConfirmed, indemnityMotivation, correctionRight, expiredCorrection, correctionDocumentEmissionDate, indemnityDueSendResponse);
        System.assert(String.isBlank(boxType));

        complaintClassification = 'Rettifica Doppia Fatturazione';
        indemnityConfirmed = True;
        indemnityMotivation = null;
        correctionRight = 'Si';
        expiredCorrection = True;
        correctionDocumentEmissionDate = String.valueOf(Date.today());
        boxType = HDT_UTL_PayloadManagement.calculateIndemnityBox(complaintClassification, indemnityConfirmed, indemnityMotivation, correctionRight, expiredCorrection, correctionDocumentEmissionDate, indemnityDueSendResponse);
        System.assertEquals('8', boxType);

        complaintClassification = 'Rettifica Doppia Fatturazione';
        indemnityConfirmed = False;
        indemnityMotivation = 'Altro indennizzo stesso anno solare';
        correctionRight = 'Si';
        expiredCorrection = True;
        correctionDocumentEmissionDate = String.valueOf(Date.today());
        boxType = HDT_UTL_PayloadManagement.calculateIndemnityBox(complaintClassification, indemnityConfirmed, indemnityMotivation, correctionRight, expiredCorrection, correctionDocumentEmissionDate, indemnityDueSendResponse);
        System.assertEquals('6', boxType);

        Test.stopTest();
    }
    
}
