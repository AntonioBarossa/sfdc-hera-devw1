public with sharing class HDT_UTL_GenericSolHandler {

    public static Sale__c createSale(String accountId, String contactId, String saleName){
        String recordId;
        Sale__c sale = new Sale__c();
        try{
            sale = new Sale__c(
                Name = saleName+' '+ Date.today(),
                CurrentStep__c = 4.0,
                SalesContactRole__c = 'Titolare',
                SalesContact__c = getTitolare(accountId)?.Contact?.Id,//contactId,
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
        Id saleId = childOrderList[0].Sale__c;
        Sale__c sale = qrSale.getRecordById(saleId,'Account__c,Id,SalesContact__c,Channel__c,VendorLastName__c,VendorFirstName__c,CommercialId__c,AgencyCode__c,Agency__c,AreaManager__c,Name,LowerChannelAgency__c,UpperChannelAgency__c');
        Order childOrder = new Order();
        childOrder.Id = childOrderList[0].Id;
        childOrder = createChildOrderWithItem(childOrder,params);
        Order parentOrder = createParentOrder(childOrder,sale);
        HDT_UTL_DatabaseService.insertSObject(parentOrder);
        childOrder.ParentOrder__c = parentOrder.Id;
        childOrder.Phase__c = 'Comunicazione verso Heroku';
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
        AccountContactRelation accContRel = getTitolare(accountId);
        childOrder.EffectiveDate__c = System.today();
        childOrder.AggregateBilling__c = 'Si';
        Contact cont = accContRel.Contact;//(String)params.get('contactId');
        Account acc = accContRel.Account;
        childOrder.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_VAS').getRecordTypeId();
        childOrder.AccountId = accountId;
        // da Account
        childOrder.ContractAccountCode__c = contractAccount;
        childOrder.CustomerLastName__c = acc.LastName__c;
        childOrder.CustomerName__c = acc.FirstName__c; 
        childOrder.CustomerType__c = acc.CustomerType__c;
        childOrder.CustomerVATNumber__c = acc.VATNumber__c;
        childOrder.CustomerFiscalCode__c = acc.FiscalCode__c;
        childOrder.PhoneNumber__c = acc.Phone;
        if ('HDT_RT_Business'.equalsIgnoreCase(acc.RecordType.DeveloperName)) {
            childOrder.CustomerCompanyName__c = acc.LastName__c;
            childOrder.VAT__c = 'Iva 22% (Cod. 02)';
            childOrder.AtecoCode__c = 'K74878';
            childOrder.HerAteco__c = 'K74878';
        } else if ('HDT_RT_Residenziale'.equalsIgnoreCase(acc.RecordType.DeveloperName)) {
            childOrder.CustomerName__c = acc.FirstName__c;
            childOrder.CustomerLastName__c = acc.LastName__c;
            childOrder.VAT__c = 'Iva 10% (Cod. 01)';
            childOrder.AtecoCode__c = '999999';
            childOrder.HerAteco__c = '999999';
        }
        //Contact Address
        childOrder.ResidentialPlace__c = acc.BillingPlace__c;
        childOrder.ResidentialPostalCode__c = acc.BillingPostalCode; 
        childOrder.ResidentialCity__c = acc.BillingCity; 
        childOrder.ResidentialStreetName__c = acc.BillingStreetName__c; 
        childOrder.ResidentialStreetNumber__c = acc.BillingStreetNumber__c;
        childOrder.ResidentialCountry__c = acc.BillingCountry; 
        childOrder.ResidentialStreetNumberExtension__c = acc.BillingStreetNumberExtension__c;
        //childOrder.ResidentialStreetToponym__c = acc.BillingStreetToponym__c;
        childOrder.ResidentialState__c = acc.BillingState;

        childOrder.ProcessType__c = 'VAS';
        childOrder.SignatureMethod__c = 'Accettato digitalmente';
        childOrder.DocSendingMethod__c = 'Posta Cartacea';
        childOrder.IntegrationId__c = (String) params.get('integrationId');
        childOrder.EffectiveDate = Date.today();
        childOrder.Status = 'In Lavorazione';
        childOrder.BillingProfile__c = bp.Id;
        childOrder.Sale__c = saleId;
        childOrder.VasSubtype__c = 'Analisi Consumi';
        childOrder.Contact__c = cont?.Id;
        childOrder.SalesContact__c = cont?.Id;
        //Billing Address
        childOrder.BillingPlace__c = bp.InvoicingPlace__c;
        childOrder.BillingPostalCode__c = bp.InvoicingPostalCode__c; 
        childOrder.BillingCity__c = bp.InvoicingCity__c; 
        childOrder.BillingStreetNumber__c = bp.InvoicingStreetNumber__c; 
        childOrder.BillingCountry__c = bp.InvoicingCountry__c; 
        //childOrder.BillingStreetToponym__c = bp.InvoicingStreetToponym__c; 
        childOrder.BillingStreetName__c = bp.InvoicingStreetName__c; 
        childOrder.BillingStreetNumberExtension__c = bp.InvoicingStreetNumberExtension__c;
        childOrder.BillingProvince__c = bp.InvoicingProvince__c;
        childOrder.BankAccountSignatoryLastName__c = bp.BankAccountSignatoryLastName__c;
        HDT_UTL_DatabaseService.insertSObject(childOrder);
        HDT_UTL_Order.calculateRateCategory(childOrder);
    }

    public static void createBaseOrderVoltura(Map<String,Object> params,String saleId){

        /*
        IntegrationId__c = payload.integrationId AND ProcessType__c = payload.insProduct AND OrderNumber = payload.serviceRequestNumber AND Contact__c = payload.contactId
         */
        String accountId = (String)params.get('accountId');
        AccountContactRelation accContRel = getTitolare(accountId);
        Contact cont = accContRel.Contact;
        String contractAccount = (String) params.get('contractAccount');
        HDT_QR_BillingProfile qrBilling = new HDT_QR_BillingProfile();
        BillingProfile__c bp = qrBilling.getRecordByContractAccount(contractAccount);
        Account acc = accContRel.Account;
        Order placeholderOrder = new Order(
                IntegrationId__c= params.containsKey('integrationId') ?  (String) params.get('integrationId'):'',
                Contact__c=cont.Id,
                AccountId=accountId,
                RecordTypeId=Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_OrderDossier').getRecordTypeId(),
                Sale__c=saleId,
                ProcessType__c='Voltura',
                EffectiveDate__c=Date.today(),
                ContractAccountCode__c=contractAccount,
                CustomerLastName__c=acc.LastName__c,
                CustomerName__c=acc.FirstName__c,
                CustomerType__c=acc.CustomerType__c,
                CustomerVATNumber__c=acc.VATNumber__c,
                CustomerFiscalCode__c=acc.FiscalCode__c,
                EffectiveDate = Date.today(),
                EffectiveDate__c=Date.today(),
                Status = 'In Lavorazione',
                Phase__c=System.label.phaseBozza,
                BillingProfile__c = bp.Id,
                PaymentMode__c=params.containsKey('paymentMode') ? (String) params.get('paymentMode'):'',
                Note__c=params.containsKey('note') ? (String) params.get('note'):''
        );
        HDT_UTL_DatabaseService.insertSObject(placeholderOrder);
        //HDT_UTL_Order.calculateRateCategory(childOrder);
    }

    public static void handleServiceRequestVoltura(Map<String,Object> params){
        HDT_QR_Order qrOrder = new HDT_QR_Order();
        HDT_QR_Sale qrSale = new HDT_QR_Sale();
        if(!params.containsKey('serviceRequest')){
            throw new CalloutException('Service request missing');
        }
        String orderNumber = (String)params.get('serviceRequest');
        Order parentOrder = qrOrder.getParentOrderVolturaSOL(orderNumber);
        Sale__c sale = qrSale.getRecordById(parentOrder.Sale__c,'Account__c,Id,SalesContact__c,Channel__c,VendorLastName__c,VendorFirstName__c,CommercialId__c,AgencyCode__c,Agency__c,AreaManager__c,Name,LowerChannelAgency__c,UpperChannelAgency__c');
        Order childOrder=createChildOrderVoltura(parentOrder,params);
        /*
        Order childOrder = new Order();
        childOrder.Id = childOrderList[0].Id;
        childOrder = createChildOrderWithItem(childOrder,params);
        Order parentOrder = createParentOrder(childOrder,sale);
        HDT_UTL_DatabaseService.insertSObject(parentOrder);
        childOrder.ParentOrder__c = parentOrder.Id;
        childOrder.Phase__c = 'Comunicazione verso Heroku';
        HDT_UTL_DatabaseService.updateSObject(childOrder);
         */

    }

    public static Order createChildOrderVoltura(Order parentOrder, Map<String,Object> params){
        String contractNumber = (String)params.get('contractNumber');
        List<Contract> contractList = getContractByNumber(contractNumber);
        if(contractList.size()<=0){
            throw new CalloutException('Contract not found');
        }
        Order childOrder=parentOrder.clone(false,true,false,false);
        childOrder.ParentOrder__c=parentOrder.Id;
        childOrder.IntegrationId__c='';
        childOrder.Phase__c=System.label.phaseBozza;
        childOrder.Subprocess__c='Standard';

        HDT_UTL_DatabaseService.insertSObject(childOrder);
        return childOrder;
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
            childOrder.ProcessCode__c = 'Gas'.equalsIgnoreCase(childOrder.Commodity__c) ? 'VCG' : 
                                        'Energia Elettrica'.equalsIgnoreCase(childOrder.Commodity__c) ? 'VCE' : '';
            //dati Service point
            childOrder.Resident__c = contractList[0].ServicePoint__r.Resident__c;
            childOrder.NumeratorGroup__c = contractList[0].ServicePoint__r.NumeratorGroup__c;
            childOrder.SAPImplantCode__c = contractList[0].ServicePoint__r.SAPImplantCode__c;
            childOrder.AnnualConsumption__c = contractList[0].ServicePoint__r.AnnualConsumption__c;
            childOrder.ServicePointCode__c = contractList[0].ServicePoint__r.ServicePointCode__c; 
            childOrder.ImplantType__c = contractList[0].ServicePoint__r.ImplantType__c;
            childOrder.Market__c = contractList[0].ServicePoint__r.MarketOrigin__c;
            childOrder.DisconnectibilityPhone__c = contractList[0].ServicePoint__r.DisconnectibilityPhone__c;
            childOrder.SupplyPostalCode__c = contractList[0].ServicePoint__r.SupplyPostalCode__c;

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
            oi.OccupantsNumber__c = Integer.valueOf(params.get('numeroOccupanti'));
            oi.Surface__c = Integer.valueOf(params.get('superficie'));
            oi.DwellingType__c = (String)params.get('tipologiaAbitazione') == 'Appartamento'?'Appartamento':'Casa Indipendente';
            oi.OwnerAC__c = (String)params.get('proprietario');
            HDT_UTL_DatabaseService.insertSObject(oi);
        }
        return childOrder;
    }

    public static List<Contract> getContractByNumber(String contractNumber){
        List<Contract> returnList = [SELECT 
                                        Id,
                                        ServicePoint__c,
                                        ServicePoint__r.Distributor__r.Code__c,
                                        ContractSalesCompany__c,
                                        ServicePoint__r.CommoditySector__c,
                                        ServicePoint__r.Resident__c,
                                        ServicePoint__r.NumeratorGroup__c,
                                        ServicePoint__r.SAPImplantCode__c,
                                        ServicePoint__r.AnnualConsumption__c,
                                        ServicePoint__r.ServicePointCode__c,
                                        ServicePoint__r.ImplantType__c,
                                        ServicePoint__r.MarketOrigin__c,
                                        ServicePoint__r.DisconnectibilityPhone__c,
                                        ServicePoint__r.SupplyPostalCode__c
                                    FROM Contract WHERE SAPContractCode__c =: contractNumber WITH SECURITY_ENFORCED];
        return returnList;
    }

    private static AccountContactRelation getTitolare(Id accountId){
        List<AccountContactRelation> contactRel = [
            SELECT 
            Account.Id,
            Account.CompanyOwner__c,
            Account.LastName__c,
            Account.FirstName__c,
            Account.CustomerType__c,
            Account.VATNumber__c,
            Account.FiscalCode__c,
            Account.Phone,
            Account.RecordType.DeveloperName,
            Account.BillingPlace__c,
            Account.BillingPostalCode, 
            Account.BillingCity, 
            Account.BillingStreetName__c, 
            Account.BillingStreetNumber__c, 
            Account.BillingCountry, 
            Account.BillingStreetNumberExtension__c, 
            //Account.BillingStreetToponym__c,  
            Account.BillingState,
            Contact.Id, 
            Roles
            FROM AccountContactRelation 
            WHERE AccountId = :accountId
            AND Roles  = 'Titolare'
            AND IsActive = True
            WITH SECURITY_ENFORCED
        ];
        
        return contactRel.isEmpty()? null : contactRel[0];
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
