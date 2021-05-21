public inherited sharing class HDT_UTL_OrderFieldsAlignment {

    private static HDT_QR_BillingProfile billingProfileQr = new HDT_QR_BillingProfile();
    private static HDT_SRV_BillingProfile billingProfileSrv = new HDT_SRV_BillingProfile();
    private static HDT_QR_ServicePoint servicePointQr = new HDT_QR_ServicePoint();
    private static HDT_SRV_ServicePoint servicePointSrv = new HDT_SRV_ServicePoint();
    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    private static HDT_QR_Account accountQr = new HDT_QR_Account();
    private static HDT_SRv_Account accountSrv = new HDT_SRV_Account();
    private static HDT_QR_Sale saleQr = new HDT_QR_Sale();
    private static HDT_SRV_Sale saleSrv = new HDT_SRV_Sale();
    private static HDT_QR_QuoteLine quoteLineQr = new HDT_QR_QuoteLine();
    private static HDT_SRV_QuoteLine quoteLineSrv = new HDT_SRV_QuoteLine();

    private static void alignBillingProfileFields(Order orderToUpdate, String billingProfileId){

        billingProfileSrv.checkReadAccess('CreateContractAccount__c,SendCertifiedEmailConsentDate__c,SubjectCode__c,InvoiceCertifiedEmailAddress__c,ElectronicInvoicingMethod__c,XMLType__c,CIG__c,CUP__c,IbanIsForeign__c,IbanCIN_IBAN__c,IbanABI__c,IbanCAB__c,IbanCodeNumber__c,BankAccountSignatoryFiscalCode__c,BankAccountSignatoryFirstName__c,BankAccountSignatoryLastName__c,BillSendingMethod__c,PaymentMethod__c,InvoicingCity__c,InvoicingCountry__c,InvoicingProvince__c,InvoicingStreetName__c,InvoicingStreetNumber__c,InvoicingPostalCode__c,InvoicingCityCode__c,InvoiceEmailAddress__c');
        BillingProfile__c billingProfile = billingProfileQr.getRecordById(billingProfileId);

        orderToUpdate.SubjectCode__c = billingProfile.SubjectCode__c;
        orderToUpdate.InvoiceCertifiedEmailAddress__c = billingProfile.InvoiceCertifiedEmailAddress__c;
        orderToUpdate.ElectronicInvoicingMethod__c = billingProfile.ElectronicInvoicingMethod__c;
        orderToUpdate.XMLType__c = billingProfile.XMLType__c;
        orderToUpdate.CIG__c  = billingProfile.CIG__c;
        orderToUpdate.CUP__c  = billingProfile.CUP__c;
        orderToUpdate.IbanIsForeign__c = billingProfile.IbanIsForeign__c;
        orderToUpdate.IbanCIN_IBAN__c = billingProfile.IbanCIN_IBAN__c;
        orderToUpdate.IbanCIN__c = billingProfile.IbanCIN__c;
        orderToUpdate.IbanABI__c = billingProfile.IbanABI__c;
        orderToUpdate.IbanCAB__c = billingProfile.IbanCAB__c;
        orderToUpdate.IbanCodeNumber__c = billingProfile.IbanCodeNumber__c;
        orderToUpdate.BankAccountSignatoryFiscalCode__c = billingProfile.BankAccountSignatoryFiscalCode__c;
        orderToUpdate.BankAccountSignatoryFirstName__c = billingProfile.BankAccountSignatoryFirstName__c;
        orderToUpdate.BankAccountSignatoryLastName__c = billingProfile.BankAccountSignatoryLastName__c;
        orderToUpdate.BillSendMode__c = billingProfile.BillSendingMethod__c;
        orderToUpdate.PaymentMode__c = billingProfile.PaymentMethod__c;
        orderToUpdate.InvoiceEmailAddress__c = billingProfile.InvoiceEmailAddress__c;
        orderToUpdate.BillingCity__c = billingProfile.InvoicingCity__c;
        orderToUpdate.BillingCountry__c = billingProfile.InvoicingCountry__c;
        orderToUpdate.BillingProvince__c = billingProfile.InvoicingProvince__c;
        orderToUpdate.BillingStreetName__c = billingProfile.InvoicingStreetName__c;
        orderToUpdate.BillingStreetNumber__c = billingProfile.InvoicingStreetNumber__c;
        orderToUpdate.BillingPostalCode__c = billingProfile.InvoicingPostalCode__c;
        orderToUpdate.BillingCityCode__c = billingProfile.InvoicingCityCode__c;
        orderToUpdate.SignatoryType__c = billingProfile.SignatoryType__c;
        orderToUpdate.SendCertifiedEmailConsentDate__c = billingProfile.SendCertifiedEmailConsentDate__c;
        orderToUpdate.CreateContractAccount__c = billingProfile.CreateContractAccount__c;
    }

    private static void alignServicePointFields(Order orderToUpdate, String servicePointId) {
        
        servicePointSrv.checkReadAccess('MeterClass__c,RecordType.DeveloperName,DisconnectibilityType__c,Disconnectable__c,AnnualConsumption__c,MarketOrigin__c,PowerAvailable__c,VoltageLevel__c,DisconnectibilityPhone__c,MaxRequiredPotential__c,UseTypeEnergy__c,UseCategory__c,WithdrawalClass__c,MeterSN__c,Resident__c,RemiCode__c,SupplyCity__c,SupplyStreet__c,SupplyStreetNumber__c,SupplyPlace__c,SupplyProvince__c,SupplyPostalCode__c,SupplyCountry__c,PowerContractual__c,ServicePointCode__c,SAPImplantCode__c');
        List<ServicePoint__c> servicePointList = servicePointQr.getRecordById(servicePointId, 'MeterClass__c,RecordType.DeveloperName,DisconnectibilityType__c,Disconnectable__c,ImplantType__c,SupplySAPCityCode__c,AnnualConsumption__c,MarketOrigin__c,PowerAvailable__c,VoltageLevel__c,DisconnectibilityPhone__c,MaxRequiredPotential__c,UseTypeEnergy__c,UseCategory__c,WithdrawalClass__c,MeterSN__c,Resident__c,RemiCode__c,SupplyCity__c,SupplyStreet__c,SupplyStreetNumber__c,SupplyPlace__c,SupplyProvince__c,SupplyPostalCode__c,SupplyCountry__c,PowerContractual__c,ServicePointCode__c,SAPImplantCode__c');

        ServicePoint__c servicePoint = servicePointList[0];

        orderToUpdate.AnnualConsumption__c = servicePoint.AnnualConsumption__c;
        orderToUpdate.MarketOrigin__c = servicePoint.MarketOrigin__c;
        orderToUpdate.Market__c = servicePoint.MarketOrigin__c;
        orderToUpdate.PowerAvailable__c = servicePoint.PowerAvailable__c;
        orderToUpdate.VoltageLevel__c = servicePoint.VoltageLevel__c;
        orderToUpdate.DisconnectibilityPhone__c = servicePoint.DisconnectibilityPhone__c;
        orderToUpdate.MaxRequiredPotential__c = servicePoint.RecordType.DeveloperName == 'HDT_RT_Gas' ? servicePoint.MaxRequiredPotential__c : null;
        orderToUpdate.UseTypeEnergy__c = servicePoint.RecordType.DeveloperName == 'HDT_RT_Ele' && servicePoint.UseTypeEnergy__c == null ? 'Ordinaria (Perm)' : servicePoint.UseTypeEnergy__c;
        orderToUpdate.UseCategory__c = servicePoint.UseCategory__c;
        orderToUpdate.MeterSN__c = servicePoint.MeterSN__c;
        orderToUpdate.Resident__c = servicePoint.Resident__c;
        orderToUpdate.RemiCode__c = servicePoint.RemiCode__c;
        orderToUpdate.SupplyCity__c = servicePoint.SupplyCity__c;
        orderToUpdate.SupplyStreet__c = servicePoint.SupplyStreet__c;
        orderToUpdate.SupplyStreetNumber__c = servicePoint.SupplyStreetNumber__c;
        orderToUpdate.SupplyPlace__c = servicePoint.SupplyPlace__c;
        orderToUpdate.SupplyPostalCode__c = servicePoint.SupplyPostalCode__c;
        orderToUpdate.SupplyCountry__c = servicePoint.SupplyCountry__c;
        orderToUpdate.PowerCommitted__c = servicePoint.PowerContractual__c;
        orderToUpdate.ServicePointCode__c = servicePoint.ServicePointCode__c;
        orderToUpdate.SAPImplantCode__c = servicePoint.SAPImplantCode__c;
        orderToUpdate.ImplantType__c = servicePoint.ImplantType__c;
        orderToUpdate.SupplyCityCode__c = servicePoint.SupplySAPCityCode__c;
        orderToUpdate.SupplyState__c = servicePoint.SupplyProvince__c;
        orderToUpdate.Disconnectable__c = servicePoint.Disconnectable__c != null ? servicePoint.Disconnectable__c : 'Si';
        orderToUpdate.DisconnectibilityType__c = servicePoint.DisconnectibilityType__c;
        orderToUpdate.ConnectionType__c = 'Permanente';
        orderToUpdate.AtecoCode__c = '999999';
        orderToUpdate.InstanceSelfCertification__c = 'SI';
        orderToUpdate.ConnectionMandate__c = 'SI';
        orderToUpdate.SelfCertificationConnection__c = '02';
        orderToUpdate.SurfaceServed__c = 75;
        orderToUpdate.RequestOption__c = calculateRequestedOption(servicePoint.ImplantType__c, servicePoint.PowerContractual__c);
        orderToUpdate.MeterClass__c = servicePoint.RecordType.DeveloperName == 'HDT_RT_Gas' ? servicePoint.MeterClass__c : null;
        orderToUpdate.WithdrawalClass__c = servicePoint.RecordType.DeveloperName == 'HDT_RT_Gas' ? (servicePoint.WithdrawalClass__c != null ? servicePoint.WithdrawalClass__c : '001-7 giorni') : null;
    }

    private static void alignAccountFields(Order orderToUpdate, String accountId){

        accountSrv.checkReadAccess('BillingPlace__c,BillingCountry,BillingPostalCode,BillingState,BillingCity,BillingIsAddressVerified__c,BillingStreetNumber__c,BillingStreetName__c,CustomerMarking__c,BillingCityCode__c,BPSAPModel__c,FiscalCode__c,VATNumber__c,RecordType.DeveloperName,Name,FirstName__c,LastName__c,PrimaryEmail__c,Phone');
        Account account = accountQr.getRecordById(accountId, 'BillingPlace__c,BillingCountry,BillingPostalCode,BillingState,BillingCity,BillingIsAddressVerified__c,BillingStreetNumber__c,BillingStreetName__c,CustomerMarking__c,BillingCityCode__c,BPSAPModel__c,FiscalCode__c,VATNumber__c,RecordType.DeveloperName,Name,FirstName__c,LastName__c,PrimaryEmail__c,Phone');

        String customerName = null;

        if (account.RecordType.DeveloperName == 'HDT_RT_Business') {
            customerName = account.Name;
            orderToUpdate.VAT__c = 'Iva 10% (Cod. 01)';
        } else if(account.RecordType.DeveloperName == 'HDT_RT_Residenziale') {
            customerName = account.FirstName__c;
            orderToUpdate.VAT__c = 'Iva 22% (Cod. 02)';
        }

        orderToUpdate.CustomerFiscalCode__c = account.FiscalCode__c;
        orderToUpdate.CustomerVATNumber__c = account.VATNumber__c;
        orderToUpdate.CustomerName__c = customerName;
        orderToUpdate.CustomerLastName__c = account.LastName__c;
        orderToUpdate.Email__c = account.PrimaryEmail__c;
        orderToUpdate.PhoneNumber__c = account.Phone;
        orderToUpdate.EffectiveDate__c = Date.newInstance(2021, 06, 01);
        orderToUpdate.BPSAPModel__c = account.BPSAPModel__c;
        orderToUpdate.ResidentialStreetName__c = account.BillingStreetName__c;
        orderToUpdate.ResidentialStreetNumber__c = account.BillingStreetNumber__c;
        orderToUpdate.ResidentialIsAddressVerified__c = account.BillingIsAddressVerified__c;
        orderToUpdate.ResidentialCity__c = account.BillingCity;
        orderToUpdate.ResidentialState__c = account.BillingState;
        orderToUpdate.ResidentialPostalCode__c = account.BillingPostalCode;
        orderToUpdate.ResidentialCountry__c = account.BillingCountry;
        orderToUpdate.ResidentialCityCode__c = account.BillingCityCode__c;
        orderToUpdate.ResidentialPlace__c = account.BillingPlace__c;
        orderToUpdate.CustomerCategory__c = account.Category__c;
    }

    private static void alignSaleFields(Order orderToUpdate, String saleId){

        saleSrv.checkReadAccess('SaleBy__c,Campaign__c,SalesContact__c,SalesContact__r.Phone');
        Sale__c sale = saleQr.getRecordById(saleId, 'SaleBy__c,Campaign__c,SalesContact__c,SalesContact__r.Phone');

        orderToUpdate.SaleBy__c = sale.SaleBy__c;
        orderToUpdate.CommissioningCampaign__c = sale.Campaign__c;
        orderToUpdate.PhoneNumber__c = sale.SalesContact__c != null ? sale.SalesContact__r.Phone : null;
        orderToUpdate.Contact__c = sale.SalesContact__c;
        orderToUpdate.CommentForDL__c = sale.SalesContact__c != null ? sale.SalesContact__r.Phone : null;
    }

    private static void alignPrimaryProduct(Order orderToUpdate, String quoteId) {

        quoteLineSrv.checkReadAccess('SBQQ__Product__r.ProductCode,SBQQ__Product__r.Version__c');
        List<SBQQ__QuoteLine__c> quoteLineList = quoteLineQr.getPrimaryRecord(quoteId);

        if (!quoteLineList.isEmpty()) {
            orderToUpdate.CommercialProductCode__c = quoteLineList[0].SBQQ__Product__r.ProductCode;
            orderToUpdate.CommercialProductVersion__c = quoteLineList[0].SBQQ__Product__r.Version__c;
            orderToUpdate.CommercialProduct__c = quoteLineList[0].SBQQ__Product__r.Name;
        }

    }

    public static String calculateRequestedOption(String implantType, Decimal powerContractual){

        String result = '';

        switch on implantType {
            when '13A0-Usi di Abitazione BT' {
                result = 'Domestici-TD';
            }
            when '13BB-Illuminazione pubblica BT' {
                result = 'AEEG Opzione BTIP-E_BTIP';
            }
            when '13CB-Non domestici in BT' {

                if(powerContractual > 0 && powerContractual <= 1.5) {
                    result = 'AEEG Opz BTA1 <= 1,5 kW-E_BTA1';
                } else if(powerContractual > 1.5 && powerContractual <= 3) {
                    result = 'AEEG Op BTA2 >1,5<=3 kW-E_BTA2';
                } else if(powerContractual > 3 && powerContractual <= 6) {
                    result = 'AEEG Op BTA3 >3 <=6 kW-E_BTA3';
                } else if(powerContractual > 6 && powerContractual <= 10) {
                    result = 'AEEG Op BTA4 >6 <=10 kW-E_BTA4';
                } else if(powerContractual > 10 && powerContractual <= 16.5) {
                     result = 'AEEG Op BTA5 > 10 kW-E_BTA5';
                } else if(powerContractual > 16.5) {
                    result = 'AEEG Op BTA6 olt 16,5kW-E_BTA6';
                }

            }
            when '13EM-Non domestici MT' {
                if(powerContractual > 0 && powerContractual <= 100) {
                    result = 'AEEG Opz MTA1 fin 100kW-E_MTA1';
                } else if(powerContractual > 100 && powerContractual <= 500) {
                    result = 'AEEG Op MTA2 >100 <=500-E_MTA2';
                } else if(powerContractual > 500) {
                    result = 'AEEG Op MTA3 olt 500kW-E_MTA3';
                }
            }
            when '13DM-Illuminazione pubblica MT' {
                result = 'AEEG Opzione MTIP-E_MTIP';
            }
            when '13FM-Non domestici AT' {
                result = 'AEEG Op ALTA fin 220 kV-E_ALTA';
            }
        }

        return result;
    }

    public static void alignFields(Order order) {

        Order orderToUpdate = new Order();
        orderToUpdate.Id = order.Id;

        alignAccountFields(orderToUpdate, order.AccountId);

        alignSaleFields(orderToUpdate, order.Sale__c);

        if(order.SBQQ__Quote__c != null) {
            alignPrimaryProduct(orderToUpdate, order.SBQQ__Quote__c);
        }

        if(order.BillingProfile__c != null) {
            alignBillingProfileFields(orderToUpdate, order.BillingProfile__c);
        }

        if (order.ServicePoint__c != null) {
            alignServicePointFields(orderToUpdate, order.ServicePoint__c);
        }

        orderSrv.updateRecord(orderToUpdate);

    }
}
