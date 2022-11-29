/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @description HDT_UTL_OrderFieldsAlignment – Align Order fields with Service Point, Account, Billing Profile
*/
public inherited sharing class HDT_UTL_OrderFieldsAlignment {

    private static HDT_QR_BillingProfile billingProfileQr = new HDT_QR_BillingProfile();
    private static HDT_SRV_BillingProfile billingProfileSrv = new HDT_SRV_BillingProfile();
    private static HDT_QR_ServicePoint servicePointQr = new HDT_QR_ServicePoint();
    private static HDT_SRV_ServicePoint servicePointSrv = new HDT_SRV_ServicePoint();
    private static HDT_QR_OrderItem orderItemQr = new HDT_QR_OrderItem();
    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    private static HDT_QR_Account accountQr = new HDT_QR_Account();
    private static HDT_SRv_Account accountSrv = new HDT_SRV_Account();
    private static HDT_QR_Sale saleQr = new HDT_QR_Sale();
    private static HDT_SRV_Sale saleSrv = new HDT_SRV_Sale();
    private static HDT_QR_QuoteLine quoteLineQr = new HDT_QR_QuoteLine();
    private static HDT_SRV_QuoteLine quoteLineSrv = new HDT_SRV_QuoteLine();
    private static HDT_QR_Quote quoteQr = new HDT_QR_Quote();
    private static HDT_SRV_Quote quoteSrv = new HDT_SRV_Quote();
    private static HDT_WRP_Data mixedData = new HDT_WRP_Data();

    private static Map<String,String> mapIvaIdToValue = new Map<String,String>{
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



    private static void alignBillingProfileFields(Order orderToUpdate, String billingProfileId){

        billingProfileSrv.checkReadAccess('ContractAccountCode__c,IbanCountry__c,CreateContractAccount__c,SendCertifiedEmailConsentDate__c,SubjectCode__c,InvoiceCertifiedEmailAddress__c,ElectronicInvoicingMethod__c,XMLType__c,CIG__c,CUP__c,IbanIsForeign__c,IbanCIN_IBAN__c,IbanABI__c,IbanCAB__c,IbanCodeNumber__c,BankAccountSignatoryFiscalCode__c,BankAccountSignatoryFirstName__c,BankAccountSignatoryLastName__c,BillSendingMethod__c,PaymentMethod__c,InvoicingCity__c,InvoicingCountry__c,InvoicingProvince__c,InvoicingStreetName__c,InvoicingStreetNumber__c,InvoicingPostalCode__c,InvoicingCityCode__c,InvoiceEmailAddress__c');
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
    }

    private static void alignServicePointFields(Order orderToUpdate, String servicePointId) {
        Map<String,String> mapIvaIdToValue2 = new Map<String,String>{
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

            Map<String,String> mapAcciseEle = new Map<String,String>{
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
            
                Map<String,String> mapAcciseGas = new Map<String,String>{
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

        servicePointSrv.checkReadAccess('NumeratorGroup__c,ATO__C,CommoditySector__c,IsRemoteManaged__c,MeterType__c,PowerRequested__c,RequestPhase__c,PressureLevel__c,Distributor__r.Code__c,SupplyType__c,SupplyTypeTemp__c,MeterClass__c,RecordType.DeveloperName,DisconnectibilityType__c,Disconnectable__c,AnnualConsumption__c,MarketOrigin__c,PowerAvailable__c,VoltageLevel__c,DisconnectibilityPhone__c,MaxRequiredPotential__c,UseTypeEnergy__c,UseCategory__c,WithdrawalClass__c,MeterSN__c,Resident__c,RemiCode__c,VATNumberUdb__c,SupplyCity__c,SupplyStreet__c,SupplyStreetNumber__c,SupplyStreetNumberExtension__c,SupplyPlace__c,SupplyProvince__c,SupplyPostalCode__c,SupplyCountry__c,PowerContractual__c,ServicePointCode__c,SAPImplantCode__c');
        List<ServicePoint__c> servicePointList = servicePointQr.getRecordById(servicePointId, 'SupplyStreetName__c,ATO__C,isSTG__c,NumeratorGroup__c,SwitchOutDate__c,SupplyStreetNumberExtension__c,SupplyTypeTemp__c,exciseEle__c,ExciseGas__c,Vat__c,CommoditySector__c,IsRemoteManaged__c,MeterType__c,SwitchInWinback__c,PowerRequested__c,RequestPhase__c,PressureLevel__c,Distributor__r.Code__c,SupplyType__c,MeterClass__c,RecordType.DeveloperName,DisconnectibilityType__c,Disconnectable__c,ImplantType__c,ImplantTypeTemp__c,SupplySAPCityCode__c,AnnualConsumption__c,MarketOrigin__c,PowerAvailable__c,Pressure__c,VoltageLevel__c,DisconnectibilityPhone__c,MaxRequiredPotential__c,UseTypeEnergy__c,UseCategory__c,WithdrawalClass__c,MeterSN__c,Resident__c,RemiCode__c,VATNumberUdb__c,SupplyCity__c,SupplyStreet__c,SupplyStreetNumber__c,SupplyPlace__c,SupplyProvince__c,SupplyPostalCode__c,SupplyCountry__c,PowerContractual__c,ServicePointCode__c,SAPImplantCode__c,MeterStatus__c,AreaDeclaredTARI__c');

        ServicePoint__c servicePoint = servicePointList[0];
        
        if(servicePoint.CommoditySector__c == 'Energia Elettrica'){
            orderToUpdate.exciseEle__c =  mapAcciseEle.get(servicePoint.exciseEle__c) != null ? mapAcciseEle.get(servicePoint.exciseEle__c) : mapAcciseEle.get('ALTRO');

            if ((servicePoint.exciseEle__c == null || servicePoint.exciseEle__c == '') //HRAWRM-498
                && servicePoint.SupplyTypeTemp__c == 'Non Domestico') {
                orderToUpdate.ExciseEle__c = 'Imposta ordinaria Altri Usi (Cod. E_IE_M04)';
            } else if ((servicePoint.exciseEle__c == null || servicePoint.exciseEle__c == '')
            && servicePoint.SupplyTypeTemp__c == 'Domestico') {
                orderToUpdate.ExciseEle__c = 'Imposta usi domestici';
            }
        }
        else if(servicePoint.CommoditySector__c == 'Gas'){
            orderToUpdate.ExciseGas__c =  mapAcciseGas.get(servicePoint.ExciseGas__c) != null ? mapAcciseGas.get(servicePoint.ExciseGas__c) : mapAcciseGas.get('ALTRO');

            if ((servicePoint.ExciseGas__c == null || servicePoint.ExciseGas__c == '') //HRAWRM-498
                && servicePoint.SupplyTypeTemp__c != 'A-Domestico') {

                    if(orderToUpdate.VAT__c == 'Iva 22% (Cod. 02)'){
                        orderToUpdate.ExciseGas__c = 'Imposta usi non domestici iva 22% (Cod. G_ICC)';
                    } else if(orderToUpdate.VAT__c == 'Iva 10% (Cod. 01)'){
                        orderToUpdate.ExciseGas__c = 'Imposta usi non domestici iva 10% (Cod. G_ICC10)';
                    }

            } else if ((servicePoint.ExciseGas__c == null || servicePoint.ExciseGas__c == '') 
                && servicePoint.SupplyTypeTemp__c == 'A-Domestico') {
                orderToUpdate.ExciseGas__c = 'Imposta Usi Domestici (Cod. G_ICD)';
            }
        } 
/*
        if((servicePoint.exciseEle__c != null && servicePoint.exciseEle__c != '') || (servicePoint.ExciseGas__c != null && servicePoint.ExciseGas__c != '')){
            orderToUpdate.exciseEle__c =  servicePoint.exciseEle__c == 'ALTRO' ? 'Imposta usi domestici' : mapAcciseEle.get(servicePoint.exciseEle__c);
            orderToUpdate.ExciseGas__c =  ServicePoint.ExciseGas__c == 'ALTRO' ? 'Altro' : mapAcciseGas.get(ServicePoint.ExciseGas__c);
        }*/
        if (servicePoint.Vat__c != null && servicePoint.Vat__c != '') {
            orderToUpdate.vat__c = mapIvaIdToValue2.get(ServicePoint.Vat__c);
        }

        orderToUpdate.AnnualConsumption__c = servicePoint.AnnualConsumption__c;
        orderToUpdate.isWinback__c = servicePoint.SwitchInWinback__c;
        orderToUpdate.SwitchOutDate__c = servicePoint.SwitchOutDate__c;
        orderToUpdate.MarketOrigin__c = servicePoint.MarketOrigin__c;
        orderToUpdate.MarketOrigin__c = (String.isBlank(orderToUpdate.MarketOrigin__c) && servicePoint.RecordType.DeveloperName == 'HDT_RT_Acqua') ? 'Regolamentato' : orderToUpdate.MarketOrigin__c;
        orderToUpdate.MarketOrigin__c = (String.isBlank(orderToUpdate.MarketOrigin__c) && servicePoint.RecordType.DeveloperName == 'HDT_RT_Ambiente') ? 'Regolamentato' : orderToUpdate.MarketOrigin__c;
        orderToUpdate.Market__c =   servicePoint.RecordType.DeveloperName == 'HDT_RT_Acqua' || servicePoint.RecordType.DeveloperName == 'HDT_RT_Ambiente'?'Regolamentato':'Libero';
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
        orderToUpdate.SupplyStreetName__c = servicePoint.SupplyStreet__c != null ?  servicePoint.SupplyStreet__c : servicePoint.SupplyStreetName__c;
        orderToUpdate.SupplyStreetNumber__c = servicePoint.SupplyStreetNumber__c;
        orderToUpdate.SupplyStreetNumberExtension__c = servicePoint.SupplyStreetNumberExtension__c;
        orderToUpdate.SupplyPlace__c = servicePoint.SupplyPlace__c;
        orderToUpdate.SupplyPostalCode__c = servicePoint.SupplyPostalCode__c;
        orderToUpdate.SupplyCountry__c = servicePoint.SupplyCountry__c;
        orderToUpdate.PowerCommitted__c = servicePoint.PowerContractual__c;
        orderToUpdate.ServicePointCode__c = servicePoint.ServicePointCode__c;
        orderToUpdate.SAPImplantCode__c = servicePoint.SAPImplantCode__c;
        orderToUpdate.ImplantType__c = servicePoint.ImplantTypeTemp__c;
        orderToUpdate.SupplyCityCode__c = servicePoint.SupplySAPCityCode__c;
        orderToUpdate.SupplyState__c = servicePoint.SupplyProvince__c;
        orderToUpdate.Disconnectable__c = servicePoint.Disconnectable__c != null ? servicePoint.Disconnectable__c : 'Si';
        orderToUpdate.DisconnectibilityType__c = servicePoint.DisconnectibilityType__c;
        orderToUpdate.ConnectionType__c = 'Permanente';
        orderToUpdate.InstanceSelfCertification__c = 'SI';
        orderToUpdate.ConnectionMandate__c = 'SI';
        orderToUpdate.SelfCertificationConnection__c = '02';
        orderToUpdate.RequestOption__c = calculateRequestedOption(servicePoint.ImplantTypeTemp__c, servicePoint.PowerContractual__c);
        orderToUpdate.MeterClass__c = servicePoint.RecordType.DeveloperName == 'HDT_RT_Gas' || servicePoint.RecordType.DeveloperName == 'HDT_RT_Acqua' ? servicePoint.MeterClass__c : null;
        orderToUpdate.MeterClass__c = servicePoint.RecordType.DeveloperName == 'HDT_RT_Acqua' && String.isNotBlank(orderToUpdate.MeterClass__c) && orderToUpdate.MeterClass__c.indexOf('DN')>-1?null:orderToUpdate.MeterClass__c;
        orderToUpdate.Caliber__c = servicePoint.RecordType.DeveloperName == 'HDT_RT_Gas'? servicePoint.MeterClass__c : null;
        orderToUpdate.WithdrawalClass__c = servicePoint.RecordType.DeveloperName == 'HDT_RT_Gas' ? (servicePoint.WithdrawalClass__c != null ? servicePoint.WithdrawalClass__c : '001 - 7 giorni') : null;
        orderToUpdate.SupplyType__c = servicePoint.SupplyTypeTemp__c != null ? servicePoint.SupplyTypeTemp__c : servicePoint.SupplyType__c;
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
        mixedData.servicePointStatus=servicePoint.MeterStatus__c;
        /**@frpanico 2022-03-15
         * Aggiunta valorizzazione
         * NumeratorGroup__c
         * per ScontiBonus
         */
        orderToUpdate.NumeratorGroup__c = servicePoint.NumeratorGroup__c;
        orderToUpdate.isSTG__c = servicePoint.isSTG__c;
        orderToUpdate.surface__c= servicePoint.AreaDeclaredTARI__c;
        orderToUpdate.ATO__c = 'Acqua'.equalsIgnoreCase(servicePoint.CommoditySector__c) ? servicePoint.ATO__c : '';
    }

    private static void alignAccountFields(Order orderToUpdate, String accountId, Order orderOld){

        
        accountSrv.checkReadAccess('CustomerCode__c,CustomerType__c,Category__c,BillingPlace__c,BillingCountry,BillingPostalCode,BillingState,BillingCity,BillingIsAddressVerified__c,BillingStreetNumber__c,BillingStreetName__c,CustomerMarking__c,BillingCityCode__c,BPSAPModel__c,FiscalCode__c,VATNumber__c,RecordType.DeveloperName,Name,FirstName__c,LastName__c,PrimaryEmail__c,Phone');
        Account account = accountQr.getRecordById(accountId, 'BillingStreetNumberExtension__c,CustomerCode__c,CustomerType__c,Category__c,BillingPlace__c,BillingCountry,BillingPostalCode,BillingState,BillingCity,BillingIsAddressVerified__c,BillingStreetNumber__c,BillingStreetName__c,CustomerMarking__c,BillingCityCode__c,BPSAPModel__c,FiscalCode__c,VATNumber__c,RecordType.DeveloperName,Name,FirstName__c,LastName__c,PrimaryEmail__c,Phone');
        if(!orderOld.isTransition__c){
            changeCustomerMarking(account);
        }
        // Order toCheck = orderQr.getRecordById(orderToUpdate.id);
        // String customerName = null;
        // String customerLastName = null;
        // if(toCheck.vat__c == null || toCheck.vat__c == ''){
            if (account.RecordType.DeveloperName == 'HDT_RT_Business') {
                String ragioneSociale = account.CustomerMarking__c.containsIgnoreCase('Ditta Individuale') && String.isNotBlank(account.FirstName__c) ? account.FirstName__c + ' ' + account.LastName__c : account.LastName__c;
                orderToUpdate.CustomerCompanyName__c = ragioneSociale;

                if (orderOld.ServicePoint__c != null && (orderOld.ServicePoint__r.Vat__c == null || orderOld.ServicePoint__r.Vat__c == '')) {
                    // 26/08/2021 - gabriele.rota@webresults.it - Calcolo IVA
                    orderToUpdate.VAT__c = 'Iva 22% (Cod. 02)';
                }
                /**@frpanico 2022-04-05
                 * Valorizzazione codice Ateco
                 * Valido solo per W1
                 */
                orderToUpdate.AtecoCode__c = 'K74878';
                orderToUpdate.HerAteco__c = 'K74878';

            } else if(account.RecordType.DeveloperName == 'HDT_RT_Residenziale') {
                orderToUpdate.CustomerName__c = account.FirstName__c;
                orderToUpdate.CustomerLastName__c = account.LastName__c;

                if (orderOld.ServicePoint__c != null && (orderOld.ServicePoint__r.Vat__c == null || orderOld.ServicePoint__r.Vat__c == '')) {

                    // 26/08/2021 - gabriele.rota@webresults.it - Calcolo IVA
                    orderToUpdate.VAT__c = 'Iva 10% (Cod. 01)';
                }

                orderToUpdate.AtecoCode__c = '999999';
                orderToUpdate.HerAteco__c = '999999';
            }
        // }
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
    }

    private static void alignSaleFields(Order orderToUpdate, String saleId){

        saleSrv.checkReadAccess('Agency__c,AgencyCode__c,CommercialId__c,VendorFirstName__c,VendorLastName__c,Channel__c,UpperChannelAgency__c,LowerChannelAgency__c,SaleBy__c,Campaign__c,SalesContact__c,SalesContact__r.IndividualId,SalesContact__r.Individual.MarketingPrivacy__c,SalesContact__r.Individual.ProfilingPrivacy__c,SalesContact__r.Phone,SalesContact__r.MobilePhone,AreaManager__c');
        Sale__c sale = saleQr.getRecordById(saleId, 'Agency__c,DocumentDate__c,DocumentNumber__c,DocumentType__c,AgencyCode__c,CommercialId__c,VendorFirstName__c,VendorLastName__c,Channel__c,UpperChannelAgency__c,LowerChannelAgency__c,SaleBy__c,Campaign__c,Campaign__r.Name,CommissioningCampaign__c,CommissioningCampaign__r.Name,SalesContact__c,SalesContact__r.IndividualId,SalesContact__r.Individual.MarketingPrivacy__c,SalesContact__r.Individual.ProfilingPrivacy__c,SalesContact__r.Phone,SalesContact__r.MobilePhone,CreatedBy.LoginChannel__c,CreatedBy.Station__c,CreatedBy.CreatorGroup__c,AreaManager__c');

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
        orderToUpdate.DocumentDate__c = sale.DocumentDate__c;
        orderToUpdate.DocumentNumber__c = sale.DocumentNumber__c;
        orderToUpdate.DocumentType__c = sale.DocumentType__c;

        orderToUpdate.LoginChannel__c=sale.CreatedBy.LoginChannel__c;
        orderToUpdate.LoginWorkstation__c= sale.CreatedBy.Station__c;
        orderToUpdate.CreatorGroup__c= sale.CreatedBy.CreatorGroup__c;

        try {
            HDT_LC_CanaleContattoIVRLogin.generateUsernameAndPassword(orderToUpdate.Id);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }

    //metodo non corretto. In caso di multi offerta o vas standalone riporta su tutti gli order l'offerta della prima quoteLine parent.
    //sostituito con metodo alignPrimaryOrderProduct
    private static void alignPrimaryProduct(Order orderToUpdate, String quoteId) {

        quoteLineSrv.checkReadAccess('SBQQ__Product__r.ProductCode,SBQQ__Product__r.Version__c');
        List<SBQQ__QuoteLine__c> quoteLineList = quoteLineQr.getPrimaryRecord(quoteId);

        if (!quoteLineList.isEmpty()) {
            system.debug('productcode '+quoteLineList[0].SBQQ__Product__r.ProductCode);
            orderToUpdate.CommercialProductCode__c = quoteLineList[0].SBQQ__Product__r.ProductCode;
            orderToUpdate.CommercialProductVersion__c = quoteLineList[0].SBQQ__Product__r.Version__c;
            orderToUpdate.CommercialProduct__c = quoteLineList[0].SBQQ__Product__r.Name;
            orderToUpdate.VasServiceActivationDate__c = quoteLineList[0].DelayEffectiveDate__c;
            orderToUpdate.CommercialProductLink__c = quoteLineList[0].SBQQ__Product__c;//gabriele.rota@webresults.it - 01/10/2021
        }
    }
    private static void alignPrimaryOrderProduct(Order orderToUpdate) {
        List<OrderItem> orderItemList = orderItemQr.getMainItem(orderToUpdate.Id);
        if(!orderItemList.isEmpty()){
            if(orderItemList[0].Product2.Family.equalsIgnoreCase('Offerta commerciale')){
                orderToUpdate.CommercialProductCode__c = orderItemList[0].Product2.ProductCode;
                orderToUpdate.RateCategory__c = orderItemList[0].Product2.ProductCode;
            }  
            else{
                orderToUpdate.CommercialProductCode__c = orderItemList[0].Product2.DescriptionSAP__c;
            }
            orderToUpdate.CommercialProductVersion__c = orderItemList[0].Product2.Version__c;
            orderToUpdate.CommercialProduct__c = orderItemList[0].Product2.Name;
            orderToUpdate.VasServiceActivationDate__c = orderItemList[0].DelayEffectiveDate__c;
            orderToUpdate.CommercialProductLink__c = orderItemList[0].Product2Id;
            orderToUpdate.ApprovalType__c           = orderItemList[0].Product2.ApprovalType__c;
            orderToUpdate.IntegratedSAP__c          = orderItemList[0].Product2.IntegratedSAP__c;
            orderToUpdate.Surface__c                = orderItemList[0].Surface__c;
            orderToUpdate.EmploymentMonthsInYear__c = orderItemList[0].MonthsOccupYear__c;
        }
        
    }

    private static void alignQuote(Order orderToUpdate, String quoteId, Order order) {


        quoteSrv.checkReadAccess('SalesCompanyCode__c,SalesCompany__c');
        SBQQ__Quote__c quote = quoteQr.getRecordById(quoteId);

        if (order.SalesCompanyCode__c == null) {
            orderToUpdate.SalesCompanyCode__c = quote.SalesCompanyCode__c;
        }

        if (order.SalesCompany__c == null) {
            orderToUpdate.SalesCompany__c = quote.SalesCompany__c;
        }
        if(quote.IsVAS__c){
            orderToUpdate.IsVAS__c=quote.IsVAS__c;
        }
        orderToUpdate.isBillableVas__c=quote.isBillableVas__c;
        mixedData.quoteAmendmentAllow=quote.AmendmentAllowed__c;
        mixedData.contrNumb=quote.SBQQ__MasterContract__r?.ContractNumber;
        mixedData.billProf=quote.SBQQ__MasterContract__r?.BillingProfile__c;
        system.debug('quote aligned');
    }

    private static void alignOrderItem(Order orderToUpdate, Order originalOrder) {

        List<OrderItem> mainItems = orderItemQr.getMainItem(orderToUpdate.Id);
        Set<String> sconti = HDT_UTL_OrderProcessAssignment.getFamilySconto();

        
        if(originalOrder.ServicePoint__c != null){
            OrderItem mainScontiItem = null;
            for(OrderItem item : mainItems){
                if(sconti.contains(item.Product2.Family)){
                    mainScontiItem=item;
                    break;
                }
            }
            if(mainScontiItem!=null){
                mainItems= new List<OrderItem>{mainScontiItem};
            }
        }
        
        if((originalOrder.ServicePoint__c != null && !sconti.contains(mainItems[0].Product2.Family) && !'Opzioni TARI'.equalsIgnoreCase(mainItems[0].Product2.Family)) || mainItems.isEmpty()){
            return;
        }
        if(!sconti.contains(mainItems[0].Product2.Family)){
            
            
            orderToUpdate.CommercialProductCode__c = mainItems[0].Product2.ProductCode;
            orderToUpdate.CommercialProductVersion__c = mainItems[0].Product2.Version__c;
            orderToUpdate.CommercialProduct__c = mainItems[0].Product2.DescriptionSAP__c;

            orderToUpdate.isVas__c= mainItems[0].Product2.Family.startsWith('VAS');
            orderToUpdate.VASType__c=orderToUpdate.isVas__c? mainItems[0].Product2.Family : '';
            orderToUpdate.VASSubtype__c=orderToUpdate.isVas__c? mainItems[0].Product2.Name.abbreviate(30) : '';
            orderToUpdate.VASBillingMode__c= mainItems[0].VASBillingMode__c;
            Id idToFilter = mainItems[0]?.SBQQ__QuoteLine__r?.ServicePointLinkItem__r?.ServicePoint__c;
            idToFilter= idToFilter!=null? idToFilter : mainItems[0]?.SBQQ__QuoteLine__r?.SBQQ__RequiredBy__c;
            if(orderToUpdate.isVas__c && originalOrder.OrderReference__c==null && originalOrder.SBQQ__Quote__r.SBQQ__Type__c != 'Amendment' && idToFilter!=null){
                //fai il match con l'orderItem di tipo pod che ha lo stesso quote
                List<OrderItem> orderItemsPod=orderItemQr.getPodOrderFromQuote(originalOrder.SBQQ__Quote__c, idToFilter);
                if(!orderItemsPod.isEmpty()){
                    orderToUpdate.OrderReference__c=orderItemsPod[0].OrderId;
                    orderToUpdate.ServicePointCode__c=orderItemsPod[0].Order?.ServicePoint__r?.ServicePointCode__c;
                    orderToUpdate.ServicePoint__c = orderItemsPod[0].Order?.ServicePoint__c;
                }
            }else if(originalOrder.OrderReference__c!=null || originalOrder.ContractReference__c!=null){
                Sobject reference = originalOrder.OrderReference__c!=null? (Sobject) originalOrder.OrderReference__r : (Sobject) originalOrder.ContractReference__r;
                orderToUpdate.ServicePointCode__c=(String) reference.getSObject('ServicePoint__r')?.get('ServicePointCode__c');
                orderToUpdate.ServicePoint__c = (String) reference.get('ServicePoint__c');
            }
            if('Opzioni TARI'.equalsIgnoreCase(mainItems[0].Product2.Family)){
                List<OrderItem> orderItemsPod=orderItemQr.getPodOrderFromQuote(originalOrder.SBQQ__Quote__c, mainItems[0]?.SBQQ__QuoteLine__r?.SBQQ__RequiredBy__c);
                if(!orderItemsPod.isEmpty() && mainItems[0]?.SBQQ__QuoteLine__r?.SBQQ__RequiredBy__c != null){
                    orderToUpdate.OrderReference__c=orderItemsPod[0].OrderId;
                    orderToUpdate.RateCategory__c = orderItemsPod[0].Order.RateCategory__c;
                }else{
                    orderToUpdate.RateCategory__c = getTariCommercialProductCodeFromSub(originalOrder.ContractReference__c);
                }
            }
        }
        
        if(sconti.contains(mainItems[0].Product2.Family)){
            HDT_UTL_Sales.handleContractVariation(orderToUpdate,originalOrder);
            //only for Amend Bonus
            List<OrderItem> billableVas = orderToUpdate.isVas__c? null : orderItemQr.getAnalisiConsumi(orderToUpdate.id);
            if(billableVas?.size() > 0){
                orderToUpdate.VASType__c=billableVas[0].Product2.Family;
                orderToUpdate.VASSubtype__c= mainItems[0].Product2.Name.abbreviate(30);
            }
            
            orderToUpdate.ConfirmCustomerContract__c=mixedData.contrNumb;
            if(orderToUpdate.BillingProfile__c==null && mixedData.billProf!=null){
                orderToUpdate.BillingProfile__c=mixedData.billProf;
                alignBillingProfileFields(orderToUpdate, orderToUpdate.BillingProfile__c);
            }
            /* @frpanico 01/03/2022 */
            /* Get Service Point from the quoteLine */
            /* not amendment */

            List<SBQQ__Quote__c> quotes = [SELECT ContractReference__c,
            ContractReference__r.ServicePoint__c,
            ContractReference__r.ServicePoint__r.ServicePointCode__c,
            OrderReference__c,
            OrderReference__r.ServicePoint__c,
            OrderReference__r.ServicePoint__r.ServicePointCode__c
            FROM SBQQ__Quote__c
            WHERE Id = :originalOrder.SBQQ__Quote__c
            WITH SECURITY_ENFORCED];

            if(!quotes.isEmpty())
            {

                SObject reference = quotes[0].ContractReference__c != null ? (SObject) quotes[0].ContractReference__r : quotes[0].OrderReference__c != null ? (SObject) quotes[0].OrderReference__r : null;
                if(reference != null)
                {
                    orderToUpdate.ServicePointCode__c=(String) reference.getSObject('ServicePoint__r')?.get('ServicePointCode__c');
                    orderToUpdate.ServicePoint__c = (String) reference.get('ServicePoint__c');
                }
                else{
                
                
                    List<SBQQ__QuoteLine__c> quoteLine = [SELECT ServicePoint__c 
                        FROM SBQQ__QuoteLine__c 
                        WHERE SBQQ__Quote__c = :originalOrder.SBQQ__Quote__c
                        AND SBQQ__ProductFamily__c NOT IN ('VAS Fatturabili')
                        AND ServicePoint__c != null 
                        WITH SECURITY_ENFORCED];
                    
                    if(!quoteLine.isEmpty())
                    {
                        System.debug(LoggingLevel.DEBUG, '# QuoteLine > ' + JSON.serialize(quoteLine));
                        if(quoteLine[0].ServicePoint__c != null)
                        {
                            orderToUpdate.ServicePoint__c = quoteLine[0].ServicePoint__c;
                        }
                    }
                }
            }
        }
        if(orderToUpdate.ServicePoint__c != null)
        {
            alignServicePointFields(orderToUpdate, orderToUpdate.ServicePoint__c);
        }
    }

    private static String getTariCommercialProductCodeFromSub(Id contrReference){
        if(contrReference != null){    
            List<SBQQ__Subscription__c> lsubs = [
                SELECT ProductCode__c
                FROM SBQQ__Subscription__c 
                WHERE SBQQ__Contract__c =:contrReference
                AND SBQQ__Product__r.Family='Offerta commerciale'
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            if(lsubs.isEmpty()){    return null;    }
            return lsubs[0].ProductCode__c;
        }
        return null;
    }

    /**
    * @description getRecordsByIdWithFields
    * @param implantType - String
    * @param powerContractual - Decimal
    * @return String
    */
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

    /**
    * @description alignFields
    * @param order - Order
    */
    public static void alignFields(Order order) {

        system.debug('ORDER FIELDS ALIGN');

        Order orderToUpdate = new Order();
        orderToUpdate.Id = order.Id;

        alignAccountFields(orderToUpdate, order.AccountId, order);

        if(order.Sale__c != null){
            alignSaleFields(orderToUpdate, order.Sale__c);
        }

        if(order.SBQQ__Quote__c != null) {
            //alignPrimaryProduct(orderToUpdate, order.SBQQ__Quote__c);
            alignPrimaryOrderProduct(orderToUpdate);
            alignQuote(orderToUpdate, order.SBQQ__Quote__c, order);
        }

        if(order.BillingProfile__c != null) {
            alignBillingProfileFields(orderToUpdate, order.BillingProfile__c);
        }

        if (order.ServicePoint__c != null) {
            alignServicePointFields(orderToUpdate, order.ServicePoint__c);
        }

        //Enter here for VAS or BonusESconti
        alignOrderItem(orderToUpdate, order);

        orderSrv.updateRecord(orderToUpdate);
        //LG 2009 Concetta Richiesta disattivazione da ROOM
        /*if (order.ServicePoint__c != null) {
            servicePointSrv.updateRecord(new ServicePoint__c(
                Id = order.ServicePoint__c,
                PowerRequested__c = null
            ));
        }*/
    }

    private static void changeCustomerMarking(Account account){
        Map<String, String> customerMarkingTranscode = 
                new  Map<String, String>{
                    'Persona fisica'=> 'D1 - ',
                    'Azienda' => 'D3 - ',
                    'Parti comuni' => 'D4 - '
                };

        String appendix = customerMarkingTranscode.get(account.customerMarking__c);
        if(String.isNotBlank(appendix)){
            account.customerMarking__c = appendix+account.customerMarking__c;
            accountSrv.updateRecord(account);
        }
    }

    private inherited sharing class HDT_WRP_Data{
        public String servicePointStatus ='';
        public String contrNumb ='';
        public Id billProf =null;
        public Boolean quoteAmendmentAllow = false;
    }
}
