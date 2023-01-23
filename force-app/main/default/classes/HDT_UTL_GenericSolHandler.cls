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
        
        //campi voltura
        //che se il valore e' nullo

        //Cambi gia' settati da vecchio metodo
        // childOrder.RecordTypeId
        //childOrder.AccountId 
        // childOrder.Status 

       params.get('OwnerId') != null ? childOrder.OwnerId = params.get('OwnerId') : childOrder.OwnerId;
        
       if(params.get('OwnerId')){
            childOrder.OwnerId = params.get('OwnerId');
        }
       
        if(params.get('OwnerId') != null){
            childOrder.OwnerId = params.get('OwnerId');
        }
        if(params.get('Pricebook2Id') != null){
            childOrder.Pricebook2Id = params.get('Pricebook2Id');
        }
        if(params.get('OpportunityId') != null){
            childOrder.OpportunityId = params.get('OpportunityId');
        }
        if(params.get('Type') != null){
            childOrder.Type = params.get('Type');
        }
        if(params.get('BillingStreet') != null){
            childOrder.BillingStreet = params.get('BillingStreet');
        }
        if(params.get('BillingCity') != null){
            childOrder.BillingCity = params.get('BillingCity');
        }
        if(params.get('BillingState') != null){
            childOrder.BillingState = params.get('BillingState');
        }
        if(params.get('BillingPostalCode') != null){
            childOrder.BillingPostalCode = params.get('BillingPostalCode');
        }
        if(params.get('BillingCountry') != null){
            childOrder.BillingCountry = params.get('BillingCountry');
        }
        if(params.get('BillingAddress') != null){
            childOrder.BillingAddress = params.get('BillingAddress');
        }
        if(params.get('ShippingStreet') != null){
            childOrder.ShippingStreet = params.get('ShippingStreet');
        }
        if(params.get('ShippingCity') != null){
            childOrder.ShippingCity = params.get('ShippingCity');
        }
        if(params.get('ShippingState') != null){
            childOrder.ShippingState = params.get('ShippingState');
        }
        if(params.get('ShippingPostalCode') != null){
            childOrder.ShippingPostalCode = params.get('ShippingPostalCode');
        }
        if(params.get('ShippingCountry') != null){
            childOrder.ShippingCountry = params.get('ShippingCountry');
        }
        if(params.get('ShippingAddress') != null){
            childOrder.ShippingAddress = params.get('ShippingAddress');
        }
        if(params.get('StatusCode') != null){
            childOrder.StatusCode = params.get('StatusCode');
        }
        if(params.get('OrderNumber') != null){
            childOrder.OrderNumber = params.get('OrderNumber');
        }
        if(params.get('SBQQ__ContractingMethod__c') != null){
            childOrder.SBQQ__ContractingMethod__c = params.get('SBQQ__ContractingMethod__c');
        }
        if(params.get('SBQQ__PaymentTerm__c') != null){
            childOrder.SBQQ__PaymentTerm__c = params.get('SBQQ__PaymentTerm__c');
        }
        if(params.get('SBQQ__PriceCalcStatus__c') != null){
            childOrder.SBQQ__PriceCalcStatus__c = params.get('SBQQ__PriceCalcStatus__c');
        }
        if(params.get('SBQQ__Quote__c') != null){
            childOrder.SBQQ__Quote__c = params.get('SBQQ__Quote__c');
        }
        if(params.get('AgencyCode__c') != null){
            childOrder.AgencyCode__c = params.get('AgencyCode__c');
        }
        if(params.get('Agency__c') != null){
            childOrder.Agency__c = params.get('Agency__c');
        }
        /* if(params.get('AggregateBilling__c') != null){
            childOrder.AggregateBilling__c = params.get('AggregateBilling__c');
        } */
        if(params.get('AnnualConsumption__c') != null){
            childOrder.AnnualConsumption__c = params.get('AnnualConsumption__c');
        }
        if(params.get('AreaManager__c') != null){
            childOrder.AreaManager__c = params.get('AreaManager__c');
        }
        /* if(params.get('AtecoCode__c') != null){
            childOrder.AtecoCode__c = params.get('AtecoCode__c');
        } */
        if(params.get('BPSAPModel__c') != null){
            childOrder.BPSAPModel__c = params.get('BPSAPModel__c');
        }
        if(params.get('BillSendMode__c') != null){
            childOrder.BillSendMode__c = params.get('BillSendMode__c');
        }
        if(params.get('BillingCityCode__c') != null){
            childOrder.BillingCityCode__c = params.get('BillingCityCode__c');
        }
        if(params.get('BillingCity__c') != null){
            childOrder.BillingCity__c = params.get('BillingCity__c');
        }
        /* if(params.get('BillingCountry__c') != null){
            childOrder.BillingCountry__c = params.get('BillingCountry__c');
        } */
      /*   if(params.get('BillingPostalCode__c') != null){
            childOrder.BillingPostalCode__c = params.get('BillingPostalCode__c');
        } */
        /* if(params.get('BillingProfile__c') != null){
            childOrder.BillingProfile__c = params.get('BillingProfile__c');
        } */
       /*  if(params.get('BillingProvince__c') != null){
            childOrder.BillingProvince__c = params.get('BillingProvince__c');
        } */
        /* if(params.get('BillingStreetName__c') != null){
            childOrder.BillingStreetName__c = params.get('BillingStreetName__c');
        } */
        /* if(params.get('BillingStreetNumber__c') != null){
            childOrder.BillingStreetNumber__c = params.get('BillingStreetNumber__c');
        } */
        if(params.get('CIAccoutn__c') != null){
            childOrder.CIAccoutn__c = params.get('CIAccoutn__c');
        }
        if(params.get('Channel__c') != null){
            childOrder.Channel__c = params.get('Channel__c');
        }
        if(params.get('Cluster__c') != null){
            childOrder.Cluster__c = params.get('Cluster__c');
        }
        if(params.get('CommercialId__c') != null){
            childOrder.CommercialId__c = params.get('CommercialId__c');
        }
        if(params.get('CommercialProductCode__c') != null){
            childOrder.CommercialProductCode__c = params.get('CommercialProductCode__c');
        }
        if(params.get('CommercialProductLink__c') != null){
            childOrder.CommercialProductLink__c = params.get('CommercialProductLink__c');
        }
        if(params.get('CommercialProductVersion__c') != null){
            childOrder.CommercialProductVersion__c = params.get('CommercialProductVersion__c');
        }
        if(params.get('CommercialProduct__c') != null){
            childOrder.CommercialProduct__c = params.get('CommercialProduct__c');
        }
        if(params.get('Commodity__c') != null){
            childOrder.Commodity__c = params.get('Commodity__c');
        }
        if(params.get('ConnectionMandate__c') != null){
            childOrder.ConnectionMandate__c = params.get('ConnectionMandate__c');
        }
        if(params.get('ConnectionType__c') != null){
            childOrder.ConnectionType__c = params.get('ConnectionType__c');
        }
        if(params.get('Contact__c') != null){
            childOrder.Contact__c = params.get('Contact__c');
        }
        if(params.get('OwnerId') != null){
            childOrder.OwnerId = params.get('OwnerId');
        }
        if(params.get('OwnerId') != null){
            childOrder.OwnerId = params.get('OwnerId');
        }
        if(params.get('OwnerId') != null){
            childOrder.OwnerId = params.get('OwnerId');
        }
        if(params.get('OwnerId') != null){
            childOrder.OwnerId = params.get('OwnerId');
        }
        if(params.get('OwnerId') != null){
            childOrder.OwnerId = params.get('OwnerId');
        }
        if(params.get('OwnerId') != null){
            childOrder.OwnerId = params.get('OwnerId');
        }
        if(params.get('OwnerId') != null){
            childOrder.OwnerId = params.get('OwnerId');
        }
        if(params.get('OwnerId') != null){
            childOrder.OwnerId = params.get('OwnerId');
        }
        if(params.get('OwnerId') != null){
            childOrder.OwnerId = params.get('OwnerId');
        }
        if(params.get('OwnerId') != null){
            childOrder.OwnerId = params.get('OwnerId');
        }
        if(params.get('OwnerId') != null){
            childOrder.OwnerId = params.get('OwnerId');
        }



        HDT_UTL_DatabaseService.insertSObject(childOrder);
        HDT_UTL_Order.calculateRateCategory(childOrder);
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
