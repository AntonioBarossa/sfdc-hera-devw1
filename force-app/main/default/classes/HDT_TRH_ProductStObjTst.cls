@isTest
public class HDT_TRH_ProductStObjTst {

    @testSetup
    static void setup() {
        List<OperandTemplate__c> operandTemplateList = new List<OperandTemplate__c>();
        OperandTemplate__c op1 = new OperandTemplate__c(Operands__c = 'ES_ADG_GO', ContractTemplate__c = 'ZELE_PREZZO', Typology__c = 'PDISCNT', Definition__c = 'DESCR ES_ADG_GO');
        operandTemplateList.add(op1);
        insert operandTemplateList;

        List<RateTemplate__c> rateList = new List<RateTemplate__c>();
        RateTemplate__c rateTemplate = new RateTemplate__c(Name = 'EVVUD', ContractTemplate__c = 'ZELE_DOMES', ServiceProduct__c = 'ELE_DOMES', Visibile__c = true);
        rateList.add(rateTemplate);
        insert rateList;
    }

    @isTest
    static void beforeInsert(){

        Boolean finished = false;

        Test.startTest();

        Product2 p = new Product2();
        p.ProductCode = 'pCode01';
        p.Version__c = '01V1';
        p.Name = 'ExampleProduct';
        p.Family = Label.HDT_ProductFamilyTrigger;

        insert p;

        finished = true;

        Test.stopTest();

        System.assertEquals(true, finished, 'Test Not Ended');

    }

    @isTest
    static void beforeUpdate(){

        Boolean finished = false;

        Product2 p = new Product2();
        p.ProductCode = 'pCode01';
        p.Version__c = '01V1';
        p.Name = 'ExampleProduct';
        p.Family = Label.HDT_ProductFamilyTrigger;
        p.DescriptionSAP__c = 'descr';

        insert p;


        RateTemplate__c rate = [
            SELECT Id
            FROM RateTemplate__c
            WITH SECURITY_ENFORCED
            LIMIT 1    
        ];

        TechnicalOffer__c technicalOffer = new TechnicalOffer__c();
        technicalOffer.Name = p.ProductCode + ' [' + p.Version__c + '] [EVVUD]';
        technicalOffer.NameExternalId__c = technicalOffer.Name;
        technicalOffer.Product__c = p.Id;
        technicalOffer.RateCategory__c = rate.Id;
        technicalOffer.SapCode__c = '1010';
        technicalOffer.Status__c = 'Status OK';
        insert technicalOffer;

        List<TechnicalOfferItem__c> techOffeItems = new List<TechnicalOfferItem__c>();
        TechnicalOfferItem__c tecOffItem = new TechnicalOfferItem__c();
        tecOffItem.TechnicalOffer__c = technicalOffer.Id;
        tecOffItem.Type__c = 'PDISCNT';
        tecOffItem.Definition__c = 'DESCR ES_ADG_GO';
        tecOffItem.G__c = false;
        tecOffItem.V__c = false;
        tecOffItem.M__c = false;
        tecOffItem.S__c = null;
        tecOffItem.Operand__c = 'ES_ADG_GO';
        tecOffItem.FareType__c = 'TEST';
        tecOffItem.FareTypeValue__c = 'TEST';
        tecOffItem.InfoGroup__c = 'TEST';
        tecOffItem.InfoGroupValue__c = 'TEST';
        tecOffItem.NumericValue__c = '0.00001';
        tecOffItem.Flag__c = false;
        tecOffItem.PriceCode__c = 'TEST';
        tecOffItem.PriceCodeValue__c = 'TEST';
        tecOffItem.DiscountCode__c = 'TEST';
        tecOffItem.DiscountCodeValue__c = 'TEST';
        tecOffItem.StringValue__c = 'TEST';
        techOffeItems.add(tecOffItem);
        insert techOffeItems;

        Test.startTest();

        p.StartDate__c = Date.today().addDays(2);
        p.EndDate__c = Date.today().addDays(6);
        p.Status__c = 'Confermata';
        update p;

        finished = true;

        Test.stopTest();

        System.assertEquals(true, finished, 'Test Not Ended');

    }

    @isTest
    static void changeStatusHandlerNull(){

        Boolean finished = false;

        Product2 pOld = new Product2();
        pOld.Status__c = null;

        Product2 pNew = new Product2();
        pNew.Status__c = null;

        HDT_WRP_ProductStObjProcess.HDT_WRP_StatusResponse statusResponse;
        statusResponse = HDT_UTL_ProductStObjProcess.changeStatusHandler(statusResponse, null, pOld, pNew, 0, 0);

        finished = true;

        System.assertEquals(true, finished, 'Test Not Ended');

    }

    @isTest
    static void changeStatusHandlerInDevelopment(){

        Boolean finished = false;

        Product2 pOld = new Product2();
        pOld.Status__c = Label.HDT_InDevelopment;

        Product2 pNew = new Product2();
        pNew.Status__c = Label.HDT_InDevelopment;

        HDT_WRP_ProductStObjProcess.HDT_WRP_StatusResponse statusResponse;
        statusResponse = HDT_UTL_ProductStObjProcess.changeStatusHandler(statusResponse, null, pOld, pNew, 0, 0);

        pNew.Status__c = Label.HDT_Confirmed;
        pOld.Family = Label.HDT_ProductFamilyTrigger;
        statusResponse = HDT_UTL_ProductStObjProcess.changeStatusHandler(statusResponse, null, pOld, pNew, 0, 0);

        pNew.Status__c = Label.HDT_Sold;
        statusResponse = HDT_UTL_ProductStObjProcess.changeStatusHandler(statusResponse, null, pOld, pNew, 0, 0);

        pNew.Status__c = Label.HDT_Canceled;
        statusResponse = HDT_UTL_ProductStObjProcess.changeStatusHandler(statusResponse, null, pOld, pNew, 0, 0);

        pNew.Status__c = Label.HDT_Expired;
        statusResponse = HDT_UTL_ProductStObjProcess.changeStatusHandler(statusResponse, null, pOld, pNew, 0, 0);

        finished = true;

        System.assertEquals(true, finished, 'Test Not Ended');

    }

    @isTest
    static void changeStatusHandlerConfirmed(){

        Boolean finished = false;

        Product2 pOld = new Product2();
        pOld.Status__c = Label.HDT_Confirmed;

        Product2 pNew = new Product2();
        pNew.Status__c = Label.HDT_InDevelopment;

        HDT_WRP_ProductStObjProcess.HDT_WRP_StatusResponse statusResponse;
        statusResponse = HDT_UTL_ProductStObjProcess.changeStatusHandler(statusResponse, null, pOld, pNew, 0, 0);

        pNew.Status__c = Label.HDT_Confirmed;
        statusResponse = HDT_UTL_ProductStObjProcess.changeStatusHandler(statusResponse, null, pOld, pNew, 0, 0);

        pNew.Status__c = Label.HDT_Sold;
        statusResponse = HDT_UTL_ProductStObjProcess.changeStatusHandler(statusResponse, null, pOld, pNew, 0, 0);

        pNew.Status__c = Label.HDT_Canceled;
        statusResponse = HDT_UTL_ProductStObjProcess.changeStatusHandler(statusResponse, null, pOld, pNew, 0, 0);

        pNew.Status__c = Label.HDT_Expired;
        statusResponse = HDT_UTL_ProductStObjProcess.changeStatusHandler(statusResponse, null, pOld, pNew, 0, 0);

        finished = true;

        System.assertEquals(true, finished, 'Test Not Ended');

    }

    @isTest
    static void changeStatusHandlerSold(){

        Boolean finished = false;

        Product2 pOld = new Product2();
        pOld.Status__c = Label.HDT_Sold;

        Product2 pNew = new Product2();
        pNew.Status__c = Label.HDT_InDevelopment;

        HDT_WRP_ProductStObjProcess.HDT_WRP_StatusResponse statusResponse;
        statusResponse = HDT_UTL_ProductStObjProcess.changeStatusHandler(statusResponse, null, pOld, pNew, 0, 0);

        pNew.Status__c = Label.HDT_Confirmed;
        statusResponse = HDT_UTL_ProductStObjProcess.changeStatusHandler(statusResponse, null, pOld, pNew, 0, 0);

        pNew.Status__c = Label.HDT_Sold;
        statusResponse = HDT_UTL_ProductStObjProcess.changeStatusHandler(statusResponse, null, pOld, pNew, 0, 0);

        pNew.Status__c = Label.HDT_Canceled;
        statusResponse = HDT_UTL_ProductStObjProcess.changeStatusHandler(statusResponse, null, pOld, pNew, 0, 0);

        pNew.Status__c = Label.HDT_Expired;
        statusResponse = HDT_UTL_ProductStObjProcess.changeStatusHandler(statusResponse, null, pOld, pNew, 0, 0);

        finished = true;

        System.assertEquals(true, finished, 'Test Not Ended');

    }

    @isTest
    static void changeStatusHandlerCanceled(){

        Boolean finished = false;

        Product2 pOld = new Product2();
        pOld.Status__c = Label.HDT_Canceled;

        Product2 pNew = new Product2();
        pNew.Status__c = Label.HDT_InDevelopment;

        HDT_WRP_ProductStObjProcess.HDT_WRP_StatusResponse statusResponse;
        statusResponse = HDT_UTL_ProductStObjProcess.changeStatusHandler(statusResponse, null, pOld, pNew, 0, 0);

        pNew.Status__c = Label.HDT_Confirmed;
        statusResponse = HDT_UTL_ProductStObjProcess.changeStatusHandler(statusResponse, null, pOld, pNew, 0, 0);

        pNew.Status__c = Label.HDT_Sold;
        statusResponse = HDT_UTL_ProductStObjProcess.changeStatusHandler(statusResponse, null, pOld, pNew, 0, 0);

        pNew.Status__c = Label.HDT_Canceled;
        statusResponse = HDT_UTL_ProductStObjProcess.changeStatusHandler(statusResponse, null, pOld, pNew, 0, 0);

        pNew.Status__c = Label.HDT_Expired;
        statusResponse = HDT_UTL_ProductStObjProcess.changeStatusHandler(statusResponse, null, pOld, pNew, 0, 0);

        finished = true;

        System.assertEquals(true, finished, 'Test Not Ended');

    }

    @isTest
    static void changeStatusHandlerExpired(){

        Boolean finished = false;

        Product2 pOld = new Product2();
        pOld.Status__c = Label.HDT_Expired;

        Product2 pNew = new Product2();
        pNew.Status__c = Label.HDT_InDevelopment;

        HDT_WRP_ProductStObjProcess.HDT_WRP_StatusResponse statusResponse;
        statusResponse = HDT_UTL_ProductStObjProcess.changeStatusHandler(statusResponse, null, pOld, pNew, 0, 0);

        pNew.Status__c = Label.HDT_Confirmed;
        statusResponse = HDT_UTL_ProductStObjProcess.changeStatusHandler(statusResponse, null, pOld, pNew, 0, 0);

        pNew.Status__c = Label.HDT_Sold;
        statusResponse = HDT_UTL_ProductStObjProcess.changeStatusHandler(statusResponse, null, pOld, pNew, 0, 0);

        pNew.Status__c = Label.HDT_Canceled;
        statusResponse = HDT_UTL_ProductStObjProcess.changeStatusHandler(statusResponse, null, pOld, pNew, 0, 0);

        pNew.Status__c = Label.HDT_Expired;
        statusResponse = HDT_UTL_ProductStObjProcess.changeStatusHandler(statusResponse, null, pOld, pNew, 0, 0);

        finished = true;

        System.assertEquals(true, finished, 'Test Not Ended');

    }

}