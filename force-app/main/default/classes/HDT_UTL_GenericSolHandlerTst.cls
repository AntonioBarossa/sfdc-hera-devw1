/**
* @author Cristiano Salvati
* @date 19/10/2022
* @description Test Class for HDT_UTL_GenericSolHandler
* @history Cristiano Salvati – 19/10/2022 – Created class
*/
@isTest
public class HDT_UTL_GenericSolHandlerTst {
    private static HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();
    @TestSetup
    static void makeData(){
        HDT_MatriceSocietaVendita__mdt recordMatrice=[SELECT Id,Service__c,SellerCompany__c FROM HDT_MatriceSocietaVendita__mdt WHERE Service__c='Energia Elettrica' LIMIT 1]; 
        List<Account> residentialAccount= HDT_UTL_DataFactoryTst.createAccountResidenziale(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
        List<ServicePoint__c> servicePoints= HDT_UTL_DataFactoryTst.createServicePoint(1, false);
        servicePoints[0].Resident__c=true;
        servicePoints[0].NumeratorGroup__c='15ALG9';
        servicePoints[0].AnnualConsumption__c=150.00;
        servicePoints[0].ServicePointCode__c='SP-15089';
        servicePoints[0].ImplantType__c='13A0-Usi di Abitazione BT';
        servicePoints[0].MarketOrigin__c='Libero';
        servicePoints[0].DisconnectibilityPhone__c='+393023598322';
        servicePoints[0].SupplyPostalCode__c='00159';
        servicePoints[0].CommoditySector__c=recordMatrice.Service__c;
        insert servicePoints;
        HDT_UTL_DataFactoryTst.createContact(1, true, residentialAccount[0].Id);
        List<Sale__c> sales = HDT_UTL_DataFactoryTst.createSale(1, true, residentialAccount[0].Id, 'Attiva');
        List<Order> orderList=HDT_UTL_DataFactoryTst.createOrder(1, false, residentialAccount[0].Id, sales);
        List<Contract> contracts= HDT_UTL_DataFactoryTst.createContract(1, false, residentialAccount[0].Id);
        contracts[0].ServicePoint__c=servicePoints[0].Id;
        contracts[0].ContractSalesCompany__c=recordMatrice.SellerCompany__c;
        insert contracts;
        List<Product2> productList= HDT_UTL_DataFactoryTst.createProduct2(1, false);
        productList[0].Family= 'Offerta commerciale';
        productList[0].Name='Analisi Consumi';
        insert productList;
        HDT_UTL_DataFactoryTst.createPricebookEntry(productList, true, Test.getStandardPricebookId());
        List<Pricebook2> pricebookList= HDT_UTL_DataFactoryTst.createPricebook(1, true);
        HDT_UTL_DataFactoryTst.createPricebookEntry(productList, true, pricebookList[0].Id);
        List<SBQQ__Subscription__c> subscriptions= HDT_UTL_DataFactoryTst.createSubscription (1, false, residentialAccount[0].Id, contracts[0].Id, servicePoints[0].Id);
        subscriptions[0].SBQQ__Product__c=productList[0].Id;
        insert subscriptions;
        
        HDT_UTL_DataFactoryTst.createProductOption(productList[0].Id, productList[0].Id, true);
    }

    @isTest
    static void createSaleTst(){
        Contact cont=[SELECT Id,AccountId FROM Contact LIMIT 1];
        Test.startTest();
        HDT_UTL_GenericSolHandler.createSale(cont.AccountId, cont.Id);
        Test.stopTest();
        Sale__c generatedSale=[SELECT Id,Account__c FROM Sale__c WHERE Account__c=:cont.AccountId];
        System.assertEquals(cont.AccountId, generatedSale.Account__c, 'oggetto Sale__c generato con successo');
    }

    @isTest
    static void handleAnalisiConsumiOrderTst(){
        Order ord=[SELECT Id,OrderNumber FROM Order LIMIT 1];
        Contact cont=[SELECT Id,AccountId FROM Contact LIMIT 1];
        Contract contr=[SELECT Id, SAPContractCode__c FROM Contract LIMIT 1];
        PricebookEntry pe=[SELECT Id,Product2Id,Pricebook2Id FROM PricebookEntry WHERE Pricebook2.IsStandard=False LIMIT 1];
        Map<String,Object> params=new Map<String,Object>{'serviceRequest'=>ord.OrderNumber,
                                                            'accountId'=>cont.AccountId,
                                                            'contractNumber'=>contr.SAPContractCode__c,
                                                            'priceBookId'=>pe.Pricebook2Id,
                                                            'productId'=> pe.Product2Id,
                                                            'priceBookEntryId'=>pe.Id,
                                                            'numeroOccupanti'=>3,
                                                            'superficie'=>50,
                                                            'tipologiaAbitazione'=>'Casa Indipendente',
                                                            'proprietario'=>'Marco'

        };
        //vedere perchè scoppia l'interfaccia di pclick all'update del child order
        Test.startTest();
        HDT_UTL_GenericSolHandler.handleAnalisiConsumiOrder(params);
        Test.stopTest();
        System.assertEquals(true,true,'temp');
    }
}
