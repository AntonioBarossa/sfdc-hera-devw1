public inherited sharing class HDT_UTL_OrderFieldsAlignment {

    private static HDT_QR_BillingProfile billingProfileQr = new HDT_QR_BillingProfile();
    private static HDT_SRV_BillingProfile billingProfileSrv = new HDT_SRV_BillingProfile();
    private static HDT_QR_ServicePoint servicePointQr = new HDT_QR_ServicePoint();
    private static HDT_SRV_ServicePoint servicePointSrv = new HDT_SRV_ServicePoint();
    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();

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
            InvoicingCity__c = billingProfile.InvoicingCity__c,
            InvoicingCountry__c = billingProfile.InvoicingCountry__c,
            InvoicingProvince__c = billingProfile.InvoicingProvince__c,
            InvoicingStreetName__c = billingProfile.InvoicingStreetName__c,
            InvoicingStreetNumber__c = billingProfile.InvoicingStreetNumber__c,
            InvoicingPostalCode__c = billingProfile.InvoicingPostalCode__c,
            InvoicingCityCode__c = billingProfile.InvoicingCityCode__c
        );

        orderSrv.updateRecord(order);

    }

    private static void alignServicePointFields(String orderId, String servicePointId) {
        
        servicePointSrv.checkReadAccess('AnnualConsumption__c,MarketOrigin__c,PowerAvailable__c,VoltageLevel__c,DisconnectibilityPhone__c,MaxRequiredPotential__c,UseTypeEnergy__c,UseCategory__c,WithdrawalClass__c,MeterSN__c,Resident__c,RemiCode__c,SupplyCity__c,SupplyStreet__c,SupplyStreetNumber__c,SupplyPlace__c,SupplyProvince__c,SupplyPostalCode__c,SupplyCountry__c,PowerContractual__c');
        List<ServicePoint__c> servicePointList = servicePointQr.getRecordById(servicePointId, 'AnnualConsumption__c,MarketOrigin__c,PowerAvailable__c,VoltageLevel__c,DisconnectibilityPhone__c,MaxRequiredPotential__c,UseTypeEnergy__c,UseCategory__c,WithdrawalClass__c,MeterSN__c,Resident__c,RemiCode__c,SupplyCity__c,SupplyStreet__c,SupplyStreetNumber__c,SupplyPlace__c,SupplyProvince__c,SupplyPostalCode__c,SupplyCountry__c,PowerContractual__c');

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
            PowerCommitted__c = servicePoint.PowerContractual__c
        );

        orderSrv.updateRecord(order);
    }

    public static void alignFields(Order order) {
        
        alignBillingProfileFields(order.Id, order.BillingProfile__c);

        if (order.ServicePoint__c != null) {
            alignServicePointFields(order.Id, order.ServicePoint__c);
        }

    }
}
