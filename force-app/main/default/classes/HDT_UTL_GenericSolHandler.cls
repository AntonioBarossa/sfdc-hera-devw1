public with sharing class HDT_UTL_GenericSolHandler {
    public static Sale__c createSale(String accountId, String contactId){
        String recordId;
        Sale__c sale = new Sale__c();
        try{
            sale = new Sale__c(
                Name = 'Vendita Analisi Consumi da Web ' + Date.today(),
                CurrentStep__c = 4.0,
                SalesContactRole__c = 'Titolare',
                SalesContact__c = contactId,
                Status__c = 'Bozza',
                IsMonitoring__c = false,
                Channel__c = 'Web',
                isTransition__c = false,
                Account__c = accountId);
            HDT_UTL_DatabaseService.insertSObject(sale);
            recordId = sale.Id;
        }catch(DmlException ex){
            return null;
        }
        return sale;
    }

    public static void handleAnalisiConsumiOrder(Map<String,Object> params){
        HDT_QR_Order qrOrder = new HDT_QR_Order();
        HDT_QR_Sale qrSale = new HDT_QR_Sale();
        String orderNumber = (String)params.get('serviceRequest');
        List<Order> childOrderList = qrOrder.getRecordByOrderNumber(orderNumber);
        Sale__c sale = qrSale.getRecordById(childOrderList[0].Sale__c,'Account__c,Id,SalesContact__c,Channel__c,VendorLastName__c,VendorFirstName__c,CommercialId__c,AgencyCode__c,Agency__c,AreaManager__c,Name');
        Order childOrder = new Order();
        childOrder.Id = childOrderList[0].Id;
        childOrder = createChildOrderWithItem(childOrder,params);
        Order parentOrder = createParentOrder(childOrder,sale);
        HDT_UTL_DatabaseService.insertSObject(parentOrder);
        childOrder.ParentOrder__c = parentOrder.Id;
        HDT_UTL_DatabaseService.updateSObject(childOrder);
    }

    public static Map<String,String> getProductInfo(Id productId){
        List<SBQQ__ProductOption__c> optionList = [SELECT Id, SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c, SBQQ__OptionalSKU__r.ProductCode, SBQQ__OptionalSKU__r.Name
            FROM SBQQ__ProductOption__c
            WHERE SBQQ__ConfiguredSKU__c =:productId
            AND SBQQ__OptionalSKU__r.Name = 'Analisi Consumi'
            WITH SECURITY_ENFORCED];

         List<PricebookEntry> pbList = [SELECT Id, Pricebook2Id, Product2Id, UnitPrice
            FROM PricebookEntry
            WHERE Product2Id =:productId
            AND Pricebook2.IsStandard = false
            WITH SECURITY_ENFORCED];

        List<PricebookEntry> pbOptionList = [SELECT Id, Pricebook2Id, Product2Id, UnitPrice
            FROM PricebookEntry
            WHERE Product2Id =:optionList[0].SBQQ__OptionalSKU__c
            AND Pricebook2Id =:pbList[0].Pricebook2Id
            WITH SECURITY_ENFORCED];  
        Map<String,String> toReturn = new Map<String,String>();
        toReturn.put('productId', optionList[0].SBQQ__OptionalSKU__c);
        toReturn.put('priceBookEntryId', pbOptionList[0].Id);
        toReturn.put('priceBookId', pbList[0].Pricebook2Id);
        //toReturn.put('unitPrice', pbList[0].UnitPrice);
        return toReturn;
    }

    public static Order createParentOrder(Order childOrder,Sale__c sale){
        Order parentOrder = new Order();
        HDT_UTL_ProcessOrderCreation utlProcessOrder = new HDT_UTL_ProcessOrderCreation();
        parentOrder = utlProcessOrder.setParentOrder(childOrder,parentOrder,sale);
       
        return parentOrder;
    }
    public static String getSalesCompanyCode(String companyName, String commodity){
        String companyCode = '';
        List<HDT_MatriceSocietaVendita__mdt> matriceList  = [
            SELECT Id, SalesCompanyCode__c, SellerCompany__c, Service__c
            FROM HDT_MatriceSocietaVendita__mdt
            WHERE SellerCompany__c =:companyName  AND Service__c =: commodity 
            WITH SECURITY_ENFORCED
        ];
        if(matriceList != null && !matriceList.isEmpty()){
            companyCode = matriceList[0].SalesCompanyCode__c;
        }

        return companyCode;
    }

    public static void createBaseOrder(Map<String,Object> params,String saleId){
        String contractAccount = (String) params.get('contractAccount');
        HDT_QR_BillingProfile qrBilling = new HDT_QR_BillingProfile();
        BillingProfile__c bp = qrBilling.getRecordByContractAccount(contractAccount);
        Order childOrder = new Order();
        String accountId = (String)params.get('accountId');
        childOrder.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_VAS').getRecordTypeId();
        childOrder.AccountId = accountId;
        childOrder.ProcessType__c = 'VAS';
        childOrder.SignatureMethod__c = 'Accettato digitalmente';
        childOrder.DocSendingMethod__c = 'Posta Cartacea';
        childOrder.IntegrationId__c = (String) params.get('integrationId');
        childOrder.EffectiveDate = Date.today();
        childOrder.Status = 'In Lavorazione';
        childOrder.BillingProfile__c = bp.Id;
        childOrder.Sale__c = saleId;
        childOrder.VasSubtype__c = 'Analisi Consumi';
        HDT_UTL_DatabaseService.insertSObject(childOrder);
    }

    public static Order createChildOrderWithItem(Order childOrder, Map<String,Object> params){
        String accountId = (String)params.get('accountId');
        String contractNumber = (String)params.get('contractNumber');
        List<Contract> contractList = getContractByNumber(contractNumber);
        HDT_QR_Contract qrContract = new HDT_QR_Contract();
        if(contractList != null && !contractList.isEmpty()){
            childOrder.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_VAS').getRecordTypeId();
            //childOrder.AccountId = accountId;
            childOrder.ServicePoint__c = contractList[0].ServicePoint__c;
            childOrder.ContractReference__c = contractList[0].Id;
            //childOrder.Contact__c = (String) params.get('contactId');
            childOrder.SalesCompany__c = contractList[0].ContractSalesCompany__c;
            childOrder.SalesCompanyCode__c = getSalesCompanyCode(contractList[0].ContractSalesCompany__c, contractList[0].ServicePoint__r.CommoditySector__c);
            childOrder.DistributorCode__c  = contractList[0].ServicePoint__r.Distributor__r.Code__c;
            childOrder.ProcessType__c = 'VAS';
            childOrder.SignatureMethod__c = 'Accettato digitalmente';
            childOrder.DocSendingMethod__c = 'Posta Cartacea';
            //childOrder.IntegrationId__c = (String) params.get('integrationId') != null?;
            childOrder.Commodity__c = contractList[0].ServicePoint__r.CommoditySector__c;
            SBQQ__Subscription__c subscription = qrContract.getSubscriptionFromContract(contractList[0].Id);
            if(subscription != null){
                childOrder.CommercialProduct__c = subscription.SBQQ__ProductName__c;
                childOrder.CommercialProductCode__c = subscription.ProductCode__c;
                childOrder.CommercialProductVersion__c = subscription.VersionFormula__c;
            }
            childOrder.EffectiveDate = Date.today();
            childOrder.Status = 'In Lavorazione';
            Map<String,String> mapParams = getProductInfo(subscription.SBQQ__Product__c);
            childOrder.Pricebook2Id = mapParams.get('priceBookId');
            HDT_UTL_DatabaseService.updateSObject(childOrder);
            OrderItem oi = new OrderItem();
            oi.Product2Id = mapParams.get('productId');
            oi.PriceBookEntryId = mapParams.get('priceBookEntryId');
            
            oi.UnitPrice = 0;
            oi.Quantity = 1;
            oi.OrderId = childOrder.Id;
            oi.OccupantsNumber__c = (String)params.get('numeroOccupanti');
            oi.Surface__c = (String)params.get('superficie');
            oi.DwellingType__c = (String)params.get('tipologiaAbitazione') == 'Appartamento'?'Appartamento':'Casa Indipendente';
            oi.OwnerAC__c = (String)params.get('proprietario');
            HDT_UTL_DatabaseService.insertSObject(oi);
        }
        return childOrder;
    }

    public static List<Contract> getContractByNumber(String contractNumber){
        List<Contract> returnList = [SELECT Id,ServicePoint__c,ServicePoint__r.Distributor__r.Code__c,ContractSalesCompany__c,ServicePoint__r.CommoditySector__c from Contract WHERE SAPContractCode__c =: contractNumber WITH SECURITY_ENFORCED];
        return returnList;
    }

    /*public static Map<String,String> amendContract(String contractNumber){
        Map<String,String> returnMap = new Map<String,String>();
        List<Contract> contractList = getContractByNumber(contractNumber);
        Id contractId = contractList[0].Id;
        String quoteJson = SBQQ.ServiceRouter.load('SBQQ.ContractManipulationAPI.ContractAmender', contractId, null);
        Map<String,Object> parsedQuote = (Map<String,Object>) JSON.deserializeUntyped(quoteJson);
        Map<String, Object> recordObj = (Map<String, Object>) parsedQuote.get('record');
        String quoteId = (String) recordObj.get('Id');
        String opportunityId = (String) recordObj.get('SBQQ__Opportunity2__c');
        returnMap.put('quoteId', quoteId);
        returnMap.put('opportunityId', opportunityId);
        returnMap.put('contractId', contractId);
        return returnMap;
    }*/

    /*public static void updateOpportunityQuote( Map<String,String> params){
        Opportunity opp = new Opportunity();
        opp.Sale__c = params.get('saleId');
        opp.Id = params.get('opportunityId');
        HDT_UTL_DatabaseService.updateSObject(opp);

        SBQQ__Quote__c quoteRecord = new SBQQ__Quote__c();
        quoteRecord.Id = params.get('quoteId');
        quoteRecord.Sale__c = params.get('saleId');
        quoteRecord.ContractReference__c = params.get('contractId');
        quoteRecord.IntegrationId__c = params.get('integrationId');
        HDT_UTL_DatabaseService.updateSObject(quoteRecord);
    }

    public static String createServiceItem(Map<String,String> params){
        String recordId;
        SaleServiceItem__c serviceItem = new SaleServiceItem__c();
        serviceItem.Opportunity__c = params.get('opportunityId');
        serviceItem.Quote__c = params.get('quoteId');
        serviceItem.ServicePoint__c = params.get('servicePointId');
        HDT_UTL_DatabaseService.insertSObject(serviceItem);
        recordId = serviceItem.Id;
        return recordId;
    }

    public static String createAnalisiConsumiLine(Map<String,String> params){
        String recordId;
        HDT_QR_GenericQuery queryClass = new HDT_QR_GenericQuery();
        String conditions = 'Name = \''+params.get('serviceRequest')+'\'';
        SBQQ__Quote__c quoteRecord = HDT_QR_GenericQuery.getGenericRecords('Id','SBQQ__Quote__c',conditions);
        return recordId;
    }*/
}
