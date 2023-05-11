public with sharing class HDT_UTL_GenericSolHandler {

    public static Sale__c createSale(String accountId, String contactId, String saleName,String saleStatus){
        String recordId;
        Sale__c sale = new Sale__c();
        try{
            sale = new Sale__c(
                Name = saleName+' '+ Date.today().format(),
                CurrentStep__c = 4.0,
                SalesContactRole__c = 'Titolare',
                SalesContact__c = getTitolare(accountId)?.Contact?.Id,//contactId,
                Status__c = saleStatus,
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


    public static Order createParentOrder(Order childOrder,Sale__c sale){
        Order parentOrder = new Order();
        HDT_UTL_ProcessOrderCreation utlProcessOrder = new HDT_UTL_ProcessOrderCreation();
        parentOrder = utlProcessOrder.setParentOrder(childOrder,parentOrder,sale);
       
        return parentOrder;
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
        Account acc = accContRel.Account;
        Order placeholderOrder = new Order(
                IntegrationId__c= params.containsKey('integrationId') ?  (String) params.get('integrationId'):'',
                Contact__c=cont.Id,
                AccountId=accountId,
                RecordTypeId=Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_OrderDossier').getRecordTypeId(),
                Sale__c=saleId,
                EffectiveDate__c=Date.today(),
                CustomerLastName__c=acc.LastName__c,
                CustomerName__c=acc.FirstName__c,
                CustomerType__c=acc.CustomerType__c,
                CustomerVATNumber__c=acc.VATNumber__c,
                CustomerFiscalCode__c=acc.FiscalCode__c,
                EffectiveDate = Date.today(),
                Status = 'Draft',
                Phase__c='Bozza',
                PaymentMode__c=params.containsKey('paymentMode') ? (String) params.get('paymentMode'):'',
                Email__c= String.isNotBlank(cont.Email) ? cont.Email : accContRel.Account.PrimaryEmail__c,
                Channel__c='Web',
                Step__c=1.0
        );
        //System.Label.statusInLavorazione
        HDT_UTL_DatabaseService.insertSObject(placeholderOrder);
        wrts_prcgvr__Activity__c act=HDT_UTL_PostSalesManager.createActivityExternal('Gestione Manuale');
        act.Order__c=placeholderOrder.Id;
        HDT_UTL_DatabaseService.insertSObject(act);
    }

    public static void handleServiceRequestVoltura(Map<String,Object> params){
        HDT_QR_Order qrOrder = new HDT_QR_Order();
        Order parentOrder = qrOrder.getParentOrderVolturaSol((String)params.get('serviceRequest'));
        createChildOrderVoltura(parentOrder,params);
    }

    private static Order createChildOrderVoltura(Order parentOrder, Map<String,Object> params){
        HDT_QR_VoltureChangeManager  voltureChangeQr = new HDT_QR_VoltureChangeManager();
        String contractNumber = (String)params.get('contractNumber');
        List<Contract> contractList = getContractByNumber(contractNumber);
        HDT_QR_BillingProfile qrBilling = new HDT_QR_BillingProfile();
        BillingProfile__c bp=qrBilling.getNewestByAccountId(parentOrder.AccountId);
        Order childOrder=parentOrder.clone(false,true,false,false);
        childOrder.ParentOrder__c=parentOrder.Id;
        childOrder.IntegrationId__c='';
        childOrder.Phase__c='Bozza';
        childOrder.Status='In Lavorazione';
        childOrder.Cluster__c='Attivazioni';
        childOrder.Subprocess__c='Standard';
        childOrder.ProcessType__c='Voltura';
        childOrder.RecordTypeId=Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_Voltura').getRecordTypeId();
        childOrder.Type='New';
        childOrder.VoltureType__c='Ordinaria';
        childOrder.Step__c=3.0;
        childOrder.RealEstateUnit__c=1.0;
        childOrder.Channel__c='Web';
        childOrder.BillingProfile__c=bp.Id;
        childOrder.ContractAccountCode__c=bp.ContractAccountCode__c;
        childOrder.Note__c=params.containsKey('note') ? (String)params.get('note') : '';
        childOrder.PhoneNumber__c=params.containsKey('phoneNumber') ? (String) params.get('phoneNumber') : '';
        childOrder.CausalCode__c='MA1';
        childOrder.ProcessCode__c='MA1';
        parentOrder.BillingProfile__c=bp.Id;
        parentOrder.ContractAccountCode__c=bp.ContractAccountCode__c;
        parentOrder.Note__c=params.containsKey('note') ? (String)params.get('note') : '';
        parentOrder.PhoneNumber__c=params.containsKey('phoneNumber') ? (String) params.get('phoneNumber') : '';
        List<AccountContactRelation> exitingContacts = voltureChangeQr.getContactInfosByAccountId(contractList[0].AccountId);
        if(!exitingContacts.isEmpty())
        {
            childOrder.PreviousCustomer__c = exitingContacts[0]?.ContactId;
        }
        if(contractList.size()>0){
            childOrder.ServicePoint__c = contractList[0].ServicePoint__c;
            childOrder.ContractReference__c = contractList[0].Id;
            childOrder.SalesCompany__c = contractList[0].ContractSalesCompany__c;
            childOrder.SalesCompanyCode__c = getSalesCompanyCode(contractList[0].ContractSalesCompany__c, contractList[0].ServicePoint__r.CommoditySector__c);
            childOrder.DistributorCode__c  = contractList[0].ServicePoint__r.Distributor__r.Code__c;
            childOrder.Commodity__c = contractList[0].ServicePoint__r.CommoditySector__c;
            childOrder.NumeratorGroup__c = contractList[0].ServicePoint__r.NumeratorGroup__c;
            childOrder.SAPImplantCode__c = contractList[0].ServicePoint__r.SAPImplantCode__c;
            childOrder.AnnualConsumption__c = contractList[0].ServicePoint__r.AnnualConsumption__c;
            childOrder.ServicePointCode__c = contractList[0].ServicePoint__r.ServicePointCode__c;
            childOrder.ImplantType__c = contractList[0].ServicePoint__r.ImplantType__c;
            childOrder.Market__c = contractList[0].ServicePoint__r.MarketOrigin__c;
            childOrder.SupplyPostalCode__c = contractList[0].ServicePoint__r.SupplyPostalCode__c;
            //new stuff
            childOrder.PayPurification__c=contractList[0].ServicePoint__r.PayPurification__c;
            childOrder.PaySewer__c=contractList[0].ServicePoint__r.PaySewer__c;
            childOrder.SupplyCity__c=contractList[0].ServicePoint__r.SupplyCity__c;
            childOrder.RateCategory__c=contractList[0].ServicePoint__r.RateCategory__c;
            childOrder.WithdrawalClass__c=contractList[0].ServicePoint__r.WithdrawalClass__c;
            childOrder.Market__c=contractList[0].Market__c;
            childOrder.SupplyType__c=contractList[0].ServicePoint__r.SupplyType__c;
            childOrder.CustomerCategory__c=parentOrder.Account.Category__c;
            childOrder.MeterSN__c=contractList[0].ServicePoint__r.MeterSN__c;
            childOrder.Resident__c=contractList[0].ServicePoint__r.Resident__c;
            childOrder.SapContractCode__c=contractList[0].SAPContractCode__c;
            childOrder.ATO__c=contractList[0].ServicePoint__r.ATO__c;
            childOrder.Disconnectable__c=contractList[0].ServicePoint__r.Disconnectable__c;
            childOrder.NotDisconnectabilityCustomer__c= contractList[0].ServicePoint__r.Disconnectable__c == 'Si' ? 'No' : 'Si';
            childOrder.AggregateBilling__c='No';
            childOrder.SecurityDepositExcluded__c='N';
            childOrder.SeasonUse__c = 'Nessuna stagionalita';
            childOrder.ContractExpenses__c='Nessuno Sconto';
            childOrder.DisconnectibilityType__c=contractList[0].ServicePoint__r.DisconnectibilityType__c;
            childOrder.MarketOrigin__c=contractList[0].ServicePoint__r.MarketOrigin__c;

            childOrder.BillSendMode__c=bp.BillSendingMethod__c;
            childOrder.InvoiceEmailAddress__c=bp.InvoiceEmailAddress__c;
            childOrder.InvoiceCertifiedEmailAddress__c=bp.InvoiceCertifiedEmailAddress__c;
            childOrder.SendCertifiedEmailConsentDate__c=bp.SendCertifiedEmailConsentDate__c;
            childOrder.DivergentSubject__c=bp.DivergentSubject__c;
            childOrder.BillingCity__c=bp.InvoicingCity__c;
            childOrder.BillingCountry__c=bp.InvoicingCountry__c;
            childOrder.BillingPlace__c=bp.InvoicingPlace__c;
            childOrder.BillingProvince__c=bp.InvoicingProvince__c;
            childOrder.BillingStreetName__c=bp.InvoicingStreetName__c;
            childOrder.BillingStreetNumber__c=bp.InvoicingStreetNumber__c;
            childOrder.BillingPostalCode__c=bp.InvoicingPostalCode__c;
            childOrder.BillingCityCode__c=bp.InvoicingCityCode__c;
            childOrder.VAT__c='Iva 10% (Cod. 01)';
            List<OrderItem> ois=generateOrderItem(contractList[0],childOrder,params);
            HDT_UTL_DatabaseService.insertSObject(ois);
        }
        HDT_UTL_DatabaseService.upsertSObject(new List<Order>{childOrder,parentOrder});
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
            Map<String,String> mapParams = getProductInfo(subscription.SBQQ__Product__c,true);
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

    public static List<OrderItem> generateOrderItem(Contract outCustomerContract,Order childOrder,Map<String,Object>params ){
        HDT_QR_Contract qrContract = new HDT_QR_Contract();
        List<SBQQ__Subscription__c> subscriptions = qrContract.getSubscriptionsFromContract(outCustomerContract.Id);
        Set<Id> productIds=new Set<Id>();
        List<OrderItem>ois=new List<OrderItem>();
        Integer offertaCommercialeIndex=0;
        String offertaCommercialeCode='';
        for(SBQQ__Subscription__c subscription : subscriptions){
            if(subscription.SBQQ__Product__r.Family == 'Offerta commerciale'){
                offertaCommercialeIndex=subscriptions.indexOf(subscription);
                offertaCommercialeCode=subscription.SBQQ__Product__r.ProductCode;
            }
            productIds.add(subscription.SBQQ__Product__c);
        }
        if(subscriptions.size()>0){
            childOrder.CommercialProduct__c = subscriptions[offertaCommercialeIndex].SBQQ__ProductName__c;
            childOrder.CommercialProductCode__c = subscriptions[offertaCommercialeIndex].ProductCode__c;
            childOrder.CommercialProductVersion__c = subscriptions[offertaCommercialeIndex].VersionFormula__c;
        }
        if(productIds.size()>0){
            Map<String,PricebookEntry> peMap=getProductInfoVoltura(productIds);
            List<String> idList=new List<String>(peMap.keySet());
            childOrder.Pricebook2Id=peMap.get(idList[0]).Pricebook2Id;
            HDT_UTL_DatabaseService.insertSObject(childOrder);
            for(Id productId:peMap.keySet()){
                ois.add(new OrderItem(
                        Product2Id=productId,
                        PriceBookEntryId=peMap.get(productId).Id,
                        UnitPrice=peMap.get(productId).UnitPrice,
                        Quantity=1,
                        OrderId=childOrder.Id
                    )
                );
            }
            if(String.isNotBlank(childOrder.SalesCompany__c) && String.isNotBlank(offertaCommercialeCode)){
                AmministrazioneSottotipologiaUso__c sottoTipologia=HDT_SRV_DataEnrichmentPostSales.handleSubType(childOrder.SalesCompany__c,offertaCommercialeCode);
                childOrder.IntendedUse__c=sottoTipologia.IntendedUse__c;
                childOrder.UseSubCategory__c=sottoTipologia.SottotipologiaUso__c;
                String tempUseSubCategory=String.isNotBlank(childOrder.UseSubCategory__c) ? childOrder.UseSubCategory__c.toLowerCase():'';
                switch on tempUseSubCategory{
                    when 'uso agricolo e zootecnico'{
                        childOrder.ZootechnicalHousingUnit__c=1.0;
                    }
                    when 'uso pubblico non disalimentabile','altri usi','uso pubblico disalimentabile'{
                        childOrder.NotDomesticHousingUnit__c=1.0;
                    }
                    when 'uso artigianale e commerciale'{
                        childOrder.CommercialHousingUnit__c=1.0;
                    }
                    when 'uso industriale'{
                        childOrder.IndustrialHousingUnit__c=1.0;
                    }
                    when 'uso domestico non residente'{
                        childOrder.NotResidentDomesticHousingUnit__c=1.0;
                    }
                    when 'uso domestico residente'{
                        childOrder.ResidentDomesticHousingUnit__c=1.0;
                    }
                    when else {
                        childOrder.AgriculturalHousingUnit__c=1.0;
                        childOrder.CommercialHousingUnit__c=1.0;
                        childOrder.IndustrialHousingUnit__c=1.0;
                        childOrder.NotDomesticHousingUnit__c=1.0;
                        childOrder.NotResidentDomesticHousingUnit__c=1.0;
                        childOrder.ResidentDomesticHousingUnit__c=1.0;
                        childOrder.ZootechnicalHousingUnit__c=1.0;
                    }
                }
            }

        }
        return ois;
    }

    private static Map<String,PriceBookEntry> getProductInfoVoltura(Set<Id> productIds){
        Map<String,PriceBookEntry> retmap=new Map<String,PriceBookEntry>();
        for(PriceBookEntry pe: [SELECT Id,Name,Pricebook2Id,Product2Id,UnitPrice FROM PriceBookEntry WHERE Product2Id IN:productIds AND Pricebook2.IsStandard=false WITH SECURITY_ENFORCED]) {
            retMap.put(pe.Id,pe);
        }
        return retMap;
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
                                        ServicePoint__r.SupplyPostalCode__c,
                                        ServicePoint__r.PayPurification__c,
                                        ServicePoint__r.PaySewer__c,
                                        ServicePoint__r.SupplyCity__c,
                                        ServicePoint__r.RateCategory__c,
                                        ServicePoint__r.WithdrawalClass__c,
                                        Market__c,
                                        ServicePoint__r.SupplyType__c,
                                        ServicePoint__r.MeterSN__c,
                                        SAPContractCode__c,
                                        ServicePoint__r.ATO__c,
                                        ServicePoint__r.Disconnectable__c,
                                        ServicePoint__r.DisconnectibilityType__c,
                                        VAT__c,
                                        BillingProfile__c,
                                        AccountId
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
            Account.PrimaryEmail__c,
            Contact.Id,
            Contact.Email,
            Roles
            FROM AccountContactRelation 
            WHERE AccountId = :accountId
            AND Roles  = 'Titolare'
            AND IsActive = True
            WITH SECURITY_ENFORCED
        ];
        
        return contactRel.isEmpty()? null : contactRel[0];
    }

    public static Map<String,String> getProductInfo(Id productId,Boolean isAnalisiConsumi){
        String query='SELECT Id, SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c, SBQQ__OptionalSKU__r.ProductCode, SBQQ__OptionalSKU__r.Name FROM SBQQ__ProductOption__c WHERE SBQQ__ConfiguredSKU__c =:productId';
        if(isAnalisiConsumi){
            query+=' AND SBQQ__OptionalSKU__r.Name = \'Analisi Consumi\' WITH SECURITY_ENFORCED';
        }
        if(!Schema.SObjectType.SBQQ__ProductOption__c.isAccessible()){
            throw new QueryException('Product Option is not accessible');
        }
        List<SBQQ__ProductOption__c> optionList = Database.query(query);
        /*
        List<SBQQ__ProductOption__c> optionList = [SELECT Id, SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c, SBQQ__OptionalSKU__r.ProductCode, SBQQ__OptionalSKU__r.Name
            FROM SBQQ__ProductOption__c
            WHERE SBQQ__ConfiguredSKU__c =:productId
            AND SBQQ__OptionalSKU__r.Name = 'Analisi Consumi'
            WITH SECURITY_ENFORCED];
         */

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