public inherited sharing class HDT_UTL_MassiveOrderFieldsAlignment {

    public static List<Account> getAccountByIds(List<Id> accIds){

        SObjectType objtype = Schema.getGlobalDescribe().get('Account');
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();
        List<Account> accList;

        if(objRes.isAccessible()){
            accList = [
                SELECT BillingStreetNumberExtension__c, CustomerCode__c, CustomerType__c, Category__c, BillingPlace__c, BillingCountry, BillingPostalCode, BillingState, BillingCity, BillingIsAddressVerified__c,
                       BillingStreetNumber__c, BillingStreetName__c, CustomerMarking__c, BillingCityCode__c, BPSAPModel__c, FiscalCode__c, VATNumber__c, RecordType.DeveloperName, Name, FirstName__c, LastName__c,
                       PrimaryEmail__c, Phone
                FROM Account
                WHERE Id IN :accIds
                WITH SECURITY_ENFORCED
            ];     
        }

        return accList;
    }

    public static List<Sale__c> getSaleByIds(List<Id> saleIds){

        SObjectType objtype = Schema.getGlobalDescribe().get('Sale__c');
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();
        List<Sale__c> saleList;

        if(objRes.isAccessible()){
            saleList = [
                SELECT Agency__c, AgencyCode__c, CommercialId__c, VendorFirstName__c, VendorLastName__c, Channel__c, UpperChannelAgency__c, LowerChannelAgency__c, SaleBy__c, Campaign__c, Campaign__r.Name,
                    CommissioningCampaign__c, CommissioningCampaign__r.Name, SalesContact__c, SalesContact__r.IndividualId, SalesContact__r.Individual.MarketingPrivacy__c, SalesContact__r.Individual.ProfilingPrivacy__c,
                    SalesContact__r.Phone, SalesContact__r.MobilePhone, CreatedBy.LoginChannel__c, CreatedBy.Station__c, CreatedBy.CreatorGroup__c, AreaManager__c
                FROM Sale__c
                WHERE Id IN :saleIds
                WITH SECURITY_ENFORCED
            ];
        }

        return saleList;
    
    }

    public static List<Contract> getContractByServicePointIds(List<Id> podSet){

        SObjectType objtype = Schema.getGlobalDescribe().get('Contract');
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();
        List<Contract> contractList;

        if(objRes.isAccessible()){
            contractList = [
                SELECT Id,
                ServicePoint__r.ServicePointCode__c,
                Account.FirstName__c, Account.LastName__c, Account.FiscalCode__c, Account.VATNumber__c,Account.BusinessNameRcuFormula__c,AccountId,SAPContractCode__c
                FROM Contract
                WHERE ServicePoint__c IN :podSet
                WITH SECURITY_ENFORCED
            ];
        }

        return contractList;
    
    }

    public static List<BillingProfile__c> getBillingProfileByIds(List<Id> idsList){

        SObjectType objtype = Schema.getGlobalDescribe().get('BillingProfile__c');
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();
        List<BillingProfile__c> billingProfileList;

        if(objRes.isAccessible()){
            billingProfileList = [
                SELECT ContractAccountCode__c, IbanCountry__c, CreateContractAccount__c, SendCertifiedEmailConsentDate__c, SubjectCode__c, InvoiceCertifiedEmailAddress__c, ElectronicInvoicingMethod__c, XMLType__c,
                       CIG__c, CUP__c, IbanIsForeign__c, IbanCIN_IBAN__c, IbanABI__c, IbanCAB__c, IbanCodeNumber__c, BankAccountSignatoryFiscalCode__c, BankAccountSignatoryFirstName__c, BankAccountSignatoryLastName__c,
                       BillSendingMethod__c, PaymentMethod__c, InvoicingCity__c, InvoicingCountry__c, InvoicingProvince__c, InvoicingStreetName__c, InvoicingStreetNumber__c, InvoicingPostalCode__c, InvoicingCityCode__c,
                       InvoiceEmailAddress__c, IbanCIN__c, InvoicingStreetNumberExtension__c, SignatoryType__c
                FROM BillingProfile__c
                WHERE Id IN :idsList
                WITH SECURITY_ENFORCED
            ];
        }

        return billingProfileList;

    }

    public static List<ServicePoint__c> getServicePointByIds(List<Id> idsList){

        SObjectType objtype = Schema.getGlobalDescribe().get('ServicePoint__c');
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();
        List<ServicePoint__c> servicePointList;

        if(objRes.isAccessible()){
            servicePointList = [
                SELECT SwitchOutDate__c, SupplyStreetNumberExtension__c, SupplyTypeTemp__c, exciseEle__c, ExciseGas__c, Vat__c, CommoditySector__c, IsRemoteManaged__c, MeterType__c, SwitchInWinback__c, PowerRequested__c,
                       RequestPhase__c, PressureLevel__c, Distributor__r.Code__c, SupplyType__c, MeterClass__c, RecordType.DeveloperName, DisconnectibilityType__c, Disconnectable__c, ImplantType__c, ImplantTypeTemp__c,
                       SupplySAPCityCode__c, AnnualConsumption__c, MarketOrigin__c, PowerAvailable__c, Pressure__c, VoltageLevel__c, DisconnectibilityPhone__c, MaxRequiredPotential__c, UseTypeEnergy__c, UseCategory__c,
                       WithdrawalClass__c, MeterSN__c, Resident__c, RemiCode__c, VATNumberUdb__c, SupplyCity__c, SupplyStreet__c, SupplyStreetNumber__c, SupplyPlace__c, SupplyProvince__c, SupplyPostalCode__c, SupplyCountry__c,
                       PowerContractual__c, ServicePointCode__c, SAPImplantCode__c, MeterStatus__c
                FROM ServicePoint__c
                WHERE Id IN :idsList
                WITH SECURITY_ENFORCED
            ];
        }

        return servicePointList;

    }

    public static Order alignAccountFields(Order orderToUpdate, Account account){

        if (account.RecordType.DeveloperName == 'HDT_RT_Business') {

            orderToUpdate.CustomerCompanyName__c = account.LastName__c;
            if(orderToUpdate.ServicePoint__c != null && (String.isBlank(orderToUpdate.ServicePoint__r.Vat__c))){
                if(String.isEmpty(orderToUpdate.VAT__c)){
                    orderToUpdate.VAT__c = 'Iva 22% (Cod. 02)';
                }
            }
            orderToUpdate.AtecoCode__c = 'K74878';
            orderToUpdate.HerAteco__c = 'K74878';

        } else if(account.RecordType.DeveloperName == 'HDT_RT_Residenziale') {

            orderToUpdate.CustomerName__c = account.FirstName__c;
            orderToUpdate.CustomerLastName__c = account.LastName__c;

            if(orderToUpdate.ServicePoint__c != null && (String.isBlank(orderToUpdate.ServicePoint__r.Vat__c))){
                if(String.isEmpty(orderToUpdate.VAT__c)){
                    orderToUpdate.VAT__c = 'Iva 10% (Cod. 01)';
                }
            }

            orderToUpdate.AtecoCode__c = '999999';
            orderToUpdate.HerAteco__c = '999999';
        }

        orderToUpdate.CustomerFiscalCode__c = account.FiscalCode__c;
        orderToUpdate.CustomerVATNumber__c = account.VATNumber__c;
        orderToUpdate.Email__c = account.PrimaryEmail__c;
        orderToUpdate.PhoneNumber__c = account.Phone;
        orderToUpdate.BPSAPModel__c = account.BPSAPModel__c;
        orderToUpdate.ResidentialStreetName__c = account.BillingStreetName__c;
        orderToUpdate.ResidentialStreetNumber__c = account.BillingStreetNumber__c;
        orderToUpdate.ResidentialStreetNumberExtension__c = account.BillingStreetNumberExtension__c;
        orderToUpdate.ResidentialIsAddressVerified__c = account.BillingIsAddressVerified__c;
        orderToUpdate.ResidentialCity__c = account.BillingCity;
        orderToUpdate.ResidentialState__c = account.BillingState;
        orderToUpdate.ResidentialPostalCode__c = account.BillingPostalCode;
        orderToUpdate.ResidentialCountry__c = account.BillingCountry;
        orderToUpdate.ResidentialCityCode__c = account.BillingCityCode__c;
        orderToUpdate.ResidentialPlace__c = account.BillingPlace__c;
        orderToUpdate.CustomerCategory__c = account.Category__c;
        orderToUpdate.CustomerType__c = account.CustomerType__c;
        orderToUpdate.CustomerCode__c = account.CustomerCode__c;

        return orderToUpdate;
    }

    public static Order alignSaleFields(Order orderToUpdate, Sale__c sale){

		orderToUpdate.SaleBy__c = sale.SaleBy__c;
        orderToUpdate.CommissioningCampaign__c = sale.CommissioningCampaign__c;
        orderToUpdate.Campaign__c = sale.Campaign__c;
        orderToUpdate.CampaignName__c = sale.Campaign__r?.Name;
        orderToUpdate.CommissioningCampaignName__c = sale.CommissioningCampaign__r?.Name;

        orderToUpdate.PhoneNumber__c = sale.SalesContact__c != null ? (sale.SalesContact__r.Phone != null ? sale.SalesContact__r.Phone : sale.SalesContact__r.MobilePhone) : null;
        orderToUpdate.Contact__c = sale.SalesContact__c;
        orderToUpdate.SalesContact__c = sale.SalesContact__c;
        orderToUpdate.CommentForDL__c = sale.SalesContact__c != null ? (sale.SalesContact__r.Phone != null ? sale.SalesContact__r.Phone : sale.SalesContact__r.MobilePhone) : null;
        orderToUpdate.MarketingPrivacy__c = sale.SalesContact__r?.Individual?.MarketingPrivacy__c;
        orderToUpdate.ProfilingPrivacy__c = sale.SalesContact__r?.Individual?.ProfilingPrivacy__c;
        orderToUpdate.LowerChannelAgency__c = sale.LowerChannelAgency__c;
        orderToUpdate.UpperChannelAgency__c = sale.UpperChannelAgency__c;
        orderToUpdate.Channel__c = sale.Channel__c;
        orderToUpdate.VendorLastName__c = sale.VendorLastName__c;
        orderToUpdate.VendorFirstName__c = sale.VendorFirstName__c;
        orderToUpdate.CommercialId__c = sale.CommercialId__c;
        orderToUpdate.AgencyCode__c = sale.AgencyCode__c;
        orderToUpdate.Agency__c = sale.Agency__c;
        orderToUpdate.AreaManager__c = sale.AreaManager__c;
        //orderToUpdate.LoginChannel__c = sale.CreatedBy.LoginChannel__c;
        orderToUpdate.LoginWorkstation__c = sale.CreatedBy.Station__c;
        //orderToUpdate.CreatorGroup__c = sale.CreatedBy.CreatorGroup__c;

        return orderToUpdate;
    }

    public static Order alignBillingProfileFields(Order orderToUpdate, BillingProfile__c billingProfile){

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
        orderToUpdate.BillingStreetNumberExtension__c = billingProfile.InvoicingStreetNumberExtension__c;
        orderToUpdate.BillingPostalCode__c = billingProfile.InvoicingPostalCode__c;
        orderToUpdate.BillingCityCode__c = billingProfile.InvoicingCityCode__c;

        if(!'Bollettino postale'.equalsIgnoreCase(billingProfile.PaymentMethod__c)){
            orderToUpdate.SignatoryType__c = billingProfile.SignatoryType__c;
        }

        orderToUpdate.SendCertifiedEmailConsentDate__c = billingProfile.SendCertifiedEmailConsentDate__c;
        orderToUpdate.CreateContractAccount__c = billingProfile.CreateContractAccount__c;
        orderToUpdate.IbanCountry__c = billingProfile.IbanCountry__c;
        orderToUpdate.ContractAccountCode__c = billingProfile.ContractAccountCode__c;

        return orderToUpdate;
    }

    public static Order alignContractFields(Order orderToUpdate, Contract contract){
        Boolean isBusiness = String.isNotBlank(contract.Account.BusinessNameRcuFormula__c);
        orderToUpdate.PreviousHolderFirstName__c = contract.Account.FirstName__c;
        orderToUpdate.PreviousHolderLastName__c = isBusiness? '':contract.Account.LastName__c;
        orderToUpdate.PreviousHolderFiscalCode__c=contract.Account.FiscalCode__c;
        orderToUpdate.PreviousHoldeCompanyName__c= isBusiness? '':contract.Account.BusinessNameRcuFormula__c;
        orderToUpdate.PreviousHolderVatNumber__c=contract.Account.VATNumber__c;
        orderToUpdate.ContractReference__c = contract.Id;
        //orderToUpdate.PreviousCustomer__c = contract.AccountId;
        orderToUpdate.SapContractCode__c = contract.SAPContractCode__c;
        return orderToUpdate;
    }

    public static Order alignServicePointFields(Order orderToUpdate, ServicePoint__c servicePoint){

        HDT_WRP_Data mixedData = new HDT_WRP_Data();
        Map<String, String> mapIvaIdToValue2 = generateMap('mapIvaIdToValue2');
        Map<String, String> mapAcciseEle = generateMap('mapAcciseEle');
        Map<String, String> mapAcciseGas = generateMap('mapAcciseGas');

        if(servicePoint.CommoditySector__c == 'Energia Elettrica'){

            if(String.isEmpty(orderToUpdate.ExciseEle__c)){
                orderToUpdate.exciseEle__c =  mapAcciseEle.get(servicePoint.exciseEle__c) != null ? mapAcciseEle.get(servicePoint.exciseEle__c) : mapAcciseEle.get('ALTRO');
            }

            if ((servicePoint.exciseEle__c == null || servicePoint.exciseEle__c == '') //HRAWRM-498
                && servicePoint.SupplyTypeTemp__c == 'Non Domestico') {
                if(String.isEmpty(orderToUpdate.ExciseEle__c)){
                    orderToUpdate.ExciseEle__c = 'Imposta ordinaria Altri Usi (Cod. E_IE_M04)';
                }
            } else if ((servicePoint.exciseEle__c == null || servicePoint.exciseEle__c == '') && servicePoint.SupplyTypeTemp__c == 'Domestico') {
                if(String.isEmpty(orderToUpdate.ExciseEle__c)){
                    orderToUpdate.ExciseEle__c = 'Imposta usi domestici';
                }
            }

        } else if(servicePoint.CommoditySector__c == 'Gas'){

            orderToUpdate.ExciseGas__c = mapAcciseGas.get(servicePoint.ExciseGas__c) != null ? mapAcciseGas.get(servicePoint.ExciseGas__c) : mapAcciseGas.get('ALTRO');

            if ((servicePoint.ExciseGas__c == null || servicePoint.ExciseGas__c == '') && servicePoint.SupplyTypeTemp__c != 'A-Domestico') {

                if(orderToUpdate.VAT__c == 'Iva 22% (Cod. 02)'){
                    if(String.isEmpty(orderToUpdate.ExciseGas__c)){
                        orderToUpdate.ExciseGas__c = 'Imposta usi non domestici iva 22% (Cod. G_ICC)';
                    }
                } else if(orderToUpdate.VAT__c == 'Iva 10% (Cod. 01)'){
                    if(String.isEmpty(orderToUpdate.ExciseGas__c)){
                        orderToUpdate.ExciseGas__c = 'Imposta usi non domestici iva 10% (Cod. G_ICC10)';
                    }
                }

            } else if ((servicePoint.ExciseGas__c == null || servicePoint.ExciseGas__c == '') && servicePoint.SupplyTypeTemp__c == 'A-Domestico') {
                if(String.isEmpty(orderToUpdate.ExciseGas__c)){
                    orderToUpdate.ExciseGas__c = 'Imposta Usi Domestici (Cod. G_ICD)';
                }
            }
        } 

        if (servicePoint.Vat__c != null && servicePoint.Vat__c != '') {
            if(String.isEmpty(orderToUpdate.vat__c)){
                orderToUpdate.vat__c = mapIvaIdToValue2.get(ServicePoint.Vat__c);
            }
        }

        orderToUpdate.AnnualConsumption__c = servicePoint.AnnualConsumption__c;
        orderToUpdate.isWinback__c = servicePoint.SwitchInWinback__c;
        orderToUpdate.SwitchOutDate__c = servicePoint.SwitchOutDate__c;
        orderToUpdate.MarketOrigin__c = (String.isBlank(servicePoint.MarketOrigin__c) && servicePoint.RecordType.DeveloperName == 'HDT_RT_Acqua') ? 'Regolamentato' : servicePoint.MarketOrigin__c;
        orderToUpdate.MarketOrigin__c = (String.isBlank(servicePoint.MarketOrigin__c) && servicePoint.RecordType.DeveloperName == 'HDT_RT_Ambiente') ? 'Regolamentato' : servicePoint.MarketOrigin__c;
        orderToUpdate.MarketOrigin__c = String.isBlank(servicePoint.MarketOrigin__c) ? 'Libero' : servicePoint.MarketOrigin__c;
        orderToUpdate.Market__c =  orderToUpdate.MarketOrigin__c;
        orderToUpdate.PowerAvailable__c = servicePoint.PowerAvailable__c;
        orderToUpdate.VoltageLevel__c = servicePoint.VoltageLevel__c;
        orderToUpdate.DisconnectibilityPhone__c = servicePoint.DisconnectibilityPhone__c;
        orderToUpdate.MaxRequiredPotential__c = servicePoint.RecordType.DeveloperName == 'HDT_RT_Gas' ? servicePoint.MaxRequiredPotential__c : null;
        orderToUpdate.UseTypeEnergy__c = servicePoint.RecordType.DeveloperName == 'HDT_RT_Ele' && servicePoint.UseTypeEnergy__c == null ? 'Ordinaria (Perm)' : servicePoint.UseTypeEnergy__c;
        orderToUpdate.UseCategory__c = servicePoint.UseCategory__c;
        orderToUpdate.MeterSN__c = servicePoint.MeterSN__c;
        orderToUpdate.Resident__c = servicePoint.Resident__c;
        orderToUpdate.RemiCode__c = servicePoint.RemiCode__c;
        orderToUpdate.VATNumberUdb__c = servicePoint.VATNumberUdb__c;
        orderToUpdate.SupplyCity__c = servicePoint.SupplyCity__c;
        orderToUpdate.SupplyStreetName__c = servicePoint.SupplyStreet__c;
        orderToUpdate.SupplyStreetNumber__c = servicePoint.SupplyStreetNumber__c;
        orderToUpdate.SupplyStreetNumberExtension__c = servicePoint.SupplyStreetNumberExtension__c;
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
        orderToUpdate.InstanceSelfCertification__c = 'SI';
        orderToUpdate.ConnectionMandate__c = 'SI';
        orderToUpdate.SelfCertificationConnection__c = '02';
        orderToUpdate.RequestOption__c = HDT_UTL_OrderFieldsAlignment.calculateRequestedOption(servicePoint.ImplantTypeTemp__c, servicePoint.PowerContractual__c);
        orderToUpdate.MeterClass__c = servicePoint.RecordType.DeveloperName == 'HDT_RT_Gas' ? servicePoint.MeterClass__c : null;
        orderToUpdate.Caliber__c = servicePoint.RecordType.DeveloperName == 'HDT_RT_Gas' ? servicePoint.MeterClass__c : null;
        orderToUpdate.WithdrawalClass__c = servicePoint.RecordType.DeveloperName == 'HDT_RT_Gas' ? (servicePoint.WithdrawalClass__c != null ? servicePoint.WithdrawalClass__c : '001 - 7 giorni') : null;
        orderToUpdate.SupplyType__c = servicePoint.SupplyType__c;
        //orderToUpdate.EffectiveDate__c = servicePoint.RecordType.DeveloperName == 'HDT_RT_SwitchIn' ? Date.newInstance(2021, 06, 01) : Date.today(); //to do: with switch in calculation logic
        orderToUpdate.DistributorCode__c = servicePoint.Distributor__r.Code__c;
        orderToUpdate.PressureLevel__c = servicePoint.PressureLevel__c;
        orderToUpdate.RequestPhase__c = servicePoint.RequestPhase__c;
        orderToUpdate.PowerRequested__c = servicePoint.PowerRequested__c;
        orderToUpdate.EnergyService__c = 'No';
        orderToUpdate.LiftingPeople__c = 'No';
        orderToUpdate.MeterType__c = servicePoint.MeterType__c;
        orderToUpdate.IsRemoteManaged__c = servicePoint.IsRemoteManaged__c;
        orderToUpdate.CustomerRequestDate__c = Date.today();
        //Aggiunta valorizzazione Commodity
        orderToUpdate.Commodity__c = servicePoint.CommoditySector__c;
        orderToUpdate.Pressure__c = servicePoint.Pressure__c;
        mixedData.servicePointStatus = servicePoint.MeterStatus__c;

        return orderToUpdate;
    }

    private static Order alignOrderProductFields(Order orderToUpdate, Product2 product2) {
        //orderToUpdate.CommercialProductCode__c = product2.ProductCode
        //orderToUpdate.CommercialProductVersion__c = orderItemList[0].Product2.Version__c;
        //orderToUpdate.CommercialProduct__c = product2.Name;
        //orderToUpdate.VasServiceActivationDate__c = DelayEffectiveDate__c;
        //orderToUpdate.CommercialProductLink__c = Product2Id;
        return orderToUpdate;
    }

    private static Map<String, String> generateMap(String mapType){

        switch on mapType {
            when 'mapIvaIdToValue2' {
                return new Map<String, String>{
                    '01' => 'Iva 10% (Cod. 01)',
                    '02' => 'Iva 22% (Cod. 02)',
                    '03' => 'Iva 10% Soc. Controllate (Cod. 03)',
                    '04' => 'Iva 22% Soc. Controllate (Cod. 04)',
                    '05' => 'Iva 10% Soc. Collegate (Cod. 05)',
                    '06' => 'Iva 22% Soc. Collegate (Cod. 06)',
                    '07' => 'Iva 10% Soc. Controllanti (Cod. 07)',
                    '08' => 'Iva 22% Soc. Controllanti (Cod. 08)',
                    '09' => 'Iva 10% Soc. del Gruppo (Cod. 09)',
                    '10' => 'Iva 22% Soc. del Gruppo (Cod. 10)',
                    '12' => 'Iva esente-non imp Art 72 (Cod. 12)',
                    '13' => 'Iva Fuori Campo Autofatt. Art 2 (Cod. 13)',
                    '14' => 'Iva 10% Soc. Partecipate (Cod. 14)',
                    '17' => 'Iva esente-non imp art 8 S. Marino (Cod. 17)',
                    '19' => 'Iva Fuori Campo Livigno (Cod. 19)',
                    '25' => 'Iva Reverse Charge (Cod. 25)',
                    '26' => 'Iva Reseller esente (Cod. 26)',
                    '27' => 'Iva 10% Consociate (Cod. 27)',
                    '28' => 'Iva 22% Consociate (Cod. 28)',
                    'S1' => 'Iva Split payment 10% (Cod. S1)',
                    'S2' => 'Iva Split payment 22% (Cod. S2)',
                    'S3' => 'Iva Split payment 10% Soc. del Gruppo (Cod. S3)',
                    'S4' => 'Iva Split payment 22% Soc. del Gruppo (Cod. S4)'
                };
            }
            when 'mapAcciseEle' {
                return new Map<String,String>{
                    'E_IE_M04' => 'Imposta ordinaria Altri Usi (Cod. E_IE_M04)',
                    'E_IE_14A' => 'Imposta C En>50% unità prod (Cod. E_IE_14A)',
                    'E_IE_L11' => 'Imposta Usi Chim Elettrol Metal No Sog. Obbl. (Cod. E_IE_L11)',
                    'E_IE_L10' => 'Imposta Esente Forze Armate NATO (Cod. E_IE_L10)',
                    'E_IE_L03' => 'Imposta FFSS (Cod. E_IE_L03)',
                    'E_IE_L98' => 'Imposta Grossiti EE Non Domest (Cod. E_IE_L98)',
                    'E_IE_L01' => 'Imposta Illum Pubbl (Cod. E_IE_L01)',
                    'E_IE_06C' => 'No sottoposto 100% Off. Acquisto_Min.Chim.Metall. (Cod. E_IE_06C)',
                    'E_IE_L13' => 'Imposta Opifici (Cod. E_IE_L13)',
                    'E_IE_L06' => 'Imposta esente Prod.EE (Cod. E_IE_L06)',
                    'E_IE_L02' => 'Imposta Sedi Diplomatiche (Cod.E_IE_L02)',
                    'E_IE_L04' => 'Imposta Trasp Urb. (Cod. E_IE_L04)',
                    'E_IE_11D' => 'Imposta % Usi Chim Metall No Sog. Obbl. (Cod. E_IE_11D)',
                    'E_IE_11C' => 'Imposta % Usi Mineral No Sog. Obbl. (Cod. E_IE_11C)',
                    'E_IE_11A' => 'Imposta Usi Mineral No Sog. Obbl. (Cod. E_IE_11A)',
                    'ALTRO' => 'Imposta usi domestici'
                };
            }
            when 'mapAcciseGas' {
                return new Map<String,String>{
                    'G_I09' => 'Imposta Autotrazione (Cod. G_I09)',
                    'G_I15' => 'Imosta Autopr-Prod EE Industr (Cod. G_I15)',
                    'G_I22' => 'Imposta Processi Metallurgici (Cod. G_I22)',
                    'G_I23' => 'Imposta Processi Mineralogici (Cod. G_I23)',
                    'G_I24' => 'Imposta Forze Armate Nazionali (Cod. G_I24)',
                    'G_ICD' => 'Imposta Usi Domestici (Cod. G_ICD)',
                    'G_ICC10' => 'Imposta usi non domestici iva 10% (Cod. G_ICC10)',
                    'G_ICC' => 'Imposta usi non domestici iva 22% (Cod. G_ICC)',
                    'G_I04' => 'Imposta usi industriali (Cod. G_I04)',
                    'G_I21' => 'Imposta Processi Elettrolitici (Cod. G_I21)',
                    'G_I25' => 'Imposta Forze Armate NATO (Cod. G_I25)',
                    'G_I26' => 'Imposta Sedi Diplomatiche - Art.22 (Cod. G_I26)',
                    'ALTRO' => 'Altro'
                };
            }
        }
        return null;
    }

    private class HDT_WRP_Data{
        public String servicePointStatus = '';
        public String contrNumb = '';
        public Id billProf = null;
        public Boolean quoteAmendmentAllow = false;
    }

}