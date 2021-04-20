public inherited sharing class HDT_UTL_OrderFieldsAlignment {

    private static HDT_QR_BillingProfile billingProfileQr = new HDT_QR_BillingProfile();
    private static HDT_SRV_BillingProfile billingProfileSrv = new HDT_SRV_BillingProfile();
    private static HDT_QR_ServicePoint servicePointQr = new HDT_QR_ServicePoint();
    private static HDT_SRV_ServicePoint servicePointSrv = new HDT_SRV_ServicePoint();
    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    private static HDT_QR_Account accountQr = new HDT_QR_Account();
    private static HDT_SRv_Account accountSrv = new HDT_SRV_Account();

    private static void alignBillingProfileFields(String orderId, String billingProfileId){

        billingProfileSrv.checkReadAccess('SubjectCode__c,InvoiceCertifiedEmailAddress__c,ElectronicInvoicingMethod__c,XMLType__c,CIG__c,CUP__c,IbanIsForeign__c,IbanCIN_IBAN__c,IbanABI__c,IbanCAB__c,IbanCodeNumber__c,BankAccountSignatoryFiscalCode__c,BankAccountSignatoryFirstName__c,BankAccountSignatoryLastName__c,BillSendingMethod__c,PaymentMethod__c,InvoicingCity__c,InvoicingCountry__c,InvoicingProvince__c,InvoicingStreetName__c,InvoicingStreetNumber__c,InvoicingPostalCode__c,InvoicingCityCode__c,InvoiceEmailAddress__c');
        BillingProfile__c billingProfile = billingProfileQr.getRecordById(billingProfileId);

        Order order = new Order(
            Id = orderId,
            SubjectCode__c = billingProfile.SubjectCode__c,
            InvoiceCertifiedEmailAddress__c = billingProfile.InvoiceCertifiedEmailAddress__c,
            ElectronicInvoicingMethod__c = billingProfile.ElectronicInvoicingMethod__c,
            XMLType__c = billingProfile.XMLType__c,
            CIG__c  = billingProfile.CIG__c,
            CUP__c  = billingProfile.CUP__c,
            IbanIsForeign__c = billingProfile.IbanIsForeign__c,
            IbanCIN_IBAN__c = billingProfile.IbanCIN_IBAN__c,
            IbanCIN__c = billingProfile.IbanCIN__c,
            IbanABI__c = billingProfile.IbanABI__c,
            IbanCAB__c = billingProfile.IbanCAB__c,
            IbanCodeNumber__c = billingProfile.IbanCodeNumber__c,
            BankAccountSignatoryFiscalCode__c = billingProfile.BankAccountSignatoryFiscalCode__c,
            BankAccountSignatoryFirstName__c = billingProfile.BankAccountSignatoryFirstName__c,
            BankAccountSignatoryLastName__c = billingProfile.BankAccountSignatoryLastName__c,
            BillSendMode__c = billingProfile.BillSendingMethod__c,
            PaymentMode__c = billingProfile.PaymentMethod__c,
            InvoiceEmailAddress__c = billingProfile.InvoiceEmailAddress__c,
            // BillingCity__c = billingProfile.InvoicingCity__c,
            // BillingCountry__c = billingProfile.InvoicingCountry__c,
            // BillingProvince__c = billingProfile.InvoicingProvince__c,
            // BillingStreetName__c = billingProfile.InvoicingStreetName__c,
            // BillingStreetNumber__c = billingProfile.InvoicingStreetNumber__c,
            // BillingPostalCode__c = billingProfile.InvoicingPostalCode__c,
            BillingCityCode__c = billingProfile.InvoicingCityCode__c,
            // SignatoryType__c = billingProfile.SignatoryType__c
        );

        orderSrv.updateRecord(order);

    }

    private static void alignServicePointFields(String orderId, String servicePointId) {
        
        servicePointSrv.checkReadAccess('AnnualConsumption__c,MarketOrigin__c,PowerAvailable__c,VoltageLevel__c,DisconnectibilityPhone__c,MaxRequiredPotential__c,UseTypeEnergy__c,UseCategory__c,WithdrawalClass__c,MeterSN__c,Resident__c,RemiCode__c,SupplyCity__c,SupplyStreet__c,SupplyStreetNumber__c,SupplyPlace__c,SupplyProvince__c,SupplyPostalCode__c,SupplyCountry__c,PowerContractual__c,ServicePointCode__c,SAPImplantCode__c');
        List<ServicePoint__c> servicePointList = servicePointQr.getRecordById(servicePointId, 'ImplantType__c,SupplySAPCityCode__c,AnnualConsumption__c,MarketOrigin__c,PowerAvailable__c,VoltageLevel__c,DisconnectibilityPhone__c,MaxRequiredPotential__c,UseTypeEnergy__c,UseCategory__c,WithdrawalClass__c,MeterSN__c,Resident__c,RemiCode__c,SupplyCity__c,SupplyStreet__c,SupplyStreetNumber__c,SupplyPlace__c,SupplyProvince__c,SupplyPostalCode__c,SupplyCountry__c,PowerContractual__c,ServicePointCode__c,SAPImplantCode__c');

        ServicePoint__c servicePoint = servicePointList[0];

        Order order = new Order(
            Id = orderId,
            AnnualConsumption__c = servicePoint.AnnualConsumption__c,
            MarketOrigin__c = servicePoint.MarketOrigin__c,
            PowerAvailable__c = servicePoint.PowerAvailable__c,
            VoltageLevel__c = servicePoint.VoltageLevel__c,
            DisconnectibilityPhone__c = servicePoint.DisconnectibilityPhone__c,
            MaxRequiredPotential__c = servicePoint.MaxRequiredPotential__c,
            UseTypeEnergy__c = servicePoint.UseTypeEnergy__c,
            UseCategory__c = servicePoint.UseCategory__c,
            WithdrawalClass__c = servicePoint.WithdrawalClass__c,
            MeterSN__c = servicePoint.MeterSN__c,
            Resident__c = servicePoint.Resident__c,
            RemiCode__c = servicePoint.RemiCode__c,
            SupplyCity__c = servicePoint.SupplyCity__c,
            SupplyStreet__c = servicePoint.SupplyStreet__c,
            SupplyStreetNumber__c = servicePoint.SupplyStreetNumber__c,
            SupplyPlace__c = servicePoint.SupplyPlace__c,
            SupplyPostalCode__c = servicePoint.SupplyPostalCode__c,
            SupplyCountry__c = servicePoint.SupplyCountry__c,
            PowerCommitted__c = servicePoint.PowerContractual__c,
            ServicePointCode__c = servicePoint.ServicePointCode__c,
            // SAPImplantCode__c = servicePoint.SAPImplantCode__c != null ? servicePoint.SAPImplantCode__c : '12345',
            ImplantType__c = servicePoint.ImplantType__c,
            SupplyCityCode__c = servicePoint.SupplySAPCityCode__c,
            SupplyState__c = servicePoint.SupplyProvince__c
        );

        orderSrv.updateRecord(order);
    }

    private static void alignAccountFields(String orderId, String accountId){

        accountSrv.checkReadAccess('FiscalCode__c,VATNumber__c,RecordType.DeveloperName,Name,FirstName__c,LastName__c,PrimaryEmail__c,Phone');
        Account account = accountQr.getRecordById(accountId, 'FiscalCode__c,VATNumber__c,RecordType.DeveloperName,Name,FirstName__c,LastName__c,PrimaryEmail__c,Phone');

        String customerName = null;

        if (account.RecordType.DeveloperName == 'HDT_RT_Business') {
            customerName = account.Name;
        } else if(account.RecordType.DeveloperName == 'HDT_RT_Residenziale') {
            customerName = account.FirstName__c;
        }

        Order order = new Order(
            Id = orderId,
            CustomerFiscalCode__c = account.FiscalCode__c,
            CustomerVATNumber__c = account.VATNumber__c,
            CustomerName__c = customerName,
            // CustomerLastName__c = account.LastName__c,
            // Mail__c = account.PrimaryEmail__c,
            PhoneNumber__c = account.Phone,
            EffectiveDate__c = Date.newInstance(2021, 06, 01)
        );

        orderSrv.updateRecord(order);
    }

    public static void alignFields(Order order) {

        alignAccountFields(order.Id, order.AccountId);
        
        alignBillingProfileFields(order.Id, order.BillingProfile__c);

        if (order.ServicePoint__c != null) {
            alignServicePointFields(order.Id, order.ServicePoint__c);
        }

    }
}
