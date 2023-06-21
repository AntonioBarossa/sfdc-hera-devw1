@isTest
public with sharing class HDT_UTL_ProcessSalesTst {
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();

    @isTest
    public static void processSalesMucTest(){

        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
	    User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserPermissionsMarketingUser=true;
		insert internalUser;
        HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, constants.PERMISSIONSET_HDT_ENABLECREDITCHECK, true);

        System.runAs(internalUser){

            List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(2, false, 'Hera Comm', 'Azienda', 'Aziende SME');
            accList[0].SatisfactionIndexCtrl__c = 1.0;
            accList[0].PraxidiaUpdateDate__c = Date.newInstance(2021, 09, 14);
            insert accList;

            List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, false, accList[0].Id);
            contractList[0].SAPContractCode__c = '3020577083';
            //contractList[0].Status = 'Cessato';
            insert contractList;


            String processName = 'MUC';
            String dataVoltura = 'true||ITALIA|HERA COMM|URBINO|VALENTINA||||13|EDERA|041067099015|PU||false|61029|Famiglie||D1 - Persona fisica||VIA CA BRUNELLO|email@prova.com|+39|||DREVNT67C42L500Y||||Femmina|+39|1010369692|false|||||URBINO|VIA CA BRUNELLO||||Sintetico|13||XML + carta/email|Bollettino postale||false||Cartaceo||||||200015387184|ITALIA||61029|PU|||HC_VenditaMM|||false|3385050158|||Si|Iva 10% (Cod. 01)||Imposta usi domestici|Cartacea|Posta Cartacea|2023-01-04|3385050158||URBINO|ITALIA|61029|PU|VIA CA BRUNELLO|13||Switch in Ele||Si|Permanente|2023-03-01|||Contratto firmato|Ordinaria (Perm)|Quality call|||URBINO||PU||VALENTINA|EDERA|DREVNT67C42L500Y|+39|3385050158||||||61029|ITALIA|Titolare|100|Appartamento||Si|3|PNNECB24+N|V42|false||||KAKTUS SRL|STEFANI Ilaria|Agenzie|AGENZIE|VI|AG870|Maggioli|Chiara|AG870V013|Hera Comm S.p.A.|||BT|13A0-Usi di Abitazione BT|URBINO|3|Si|Domestico||false|13|Multiorario|IT001E59103901|4012729301|61029|PU|ITALIA|||VIA CA BRUNELLO|3380|||false||Energia Elettrica||3||Si|3.3||||Persona Fisica|13D0000001||||';

            MassiveLoaderRequest__c mlr = HDT_UTL_DataFactoryTst.createMassiveLoaderRequest(processName,new List<String>{dataVoltura});
            //HDT_MassiveLoaderProcess__mdt myCMT = new HDT_MassiveLoaderProcess__mdt(DeveloperName= 'SwitchIn', MasterLabel='SwitchIn', Priority__c= 1, IsActive__c=true);
            mlr.Priority__c = 1;
            mlr.Status__c = 'In attesa di Lavorazione';
            update mlr;
            List<MassiveLoaderRequestItem__c> ms = [SELECT Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, NextStepData__c,
                                                    SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, MassiveLoaderRequest__c,
                                                    Account__c, Data__c, Lead__c, StatusDescription__c, Status__c,MassiveLoaderRequest__r.ProcessType__c 
                                                    FROM MassiveLoaderRequestItem__c ];

            ms[0].Status__c = 'In attesa di Lavorazione';
            update ms;
            System.debug(ms);
            createMapping();
            
            Test.startTest();
            HDT_BA_ProcessRequestItem processReq = new HDT_BA_ProcessRequestItem(mlr.Id, 1, processName);
            Database.executeBatch(processReq,1);
            Test.stopTest();

        }
    }

    @isTest
    public static void processSalesTest(){

        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
	    User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserPermissionsMarketingUser=true;
		insert internalUser;
        HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, constants.PERMISSIONSET_HDT_ENABLECREDITCHECK, true);

        System.runAs(internalUser){

            List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(2, false, 'Hera Comm', 'Azienda', 'Aziende SME');
            accList[0].SatisfactionIndexCtrl__c = 1.0;
            accList[0].PraxidiaUpdateDate__c = Date.newInstance(2021, 09, 14);
            insert accList;

            List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, false, accList[0].Id);
            contractList[0].SAPContractCode__c = '3020577083';
            //contractList[0].Status = 'Cessato';
            insert contractList;


            String processName = 'MUC';
            String mucData = 'VCCMRA71R20L103G|1007227415|false|200010740269|true|3020577083|Cambio Offerta Ele|VCCMRA71R20L103G|PNNECB24+N|V42|true|||KAKTUS SRL|STEFANI Ilaria|Agenzie|AGENZIE|VI|AG870|Maggioli|Chiara|AG870V013|Hera Comm S.p.A.|IT001E68845859|4009188637|Persona Fisica|13D0000001|Contratto già firmato||||';

            //String dataVoltura = 'true||ITALIA|HERA COMM|URBINO|VALENTINA||||13|EDERA|041067099015|PU||false|61029|Famiglie||D1 - Persona fisica||VIA CA BRUNELLO|email@prova.com|+39|||DREVNT67C42L500Y||||Femmina|+39|1010369692|false|||||URBINO|VIA CA BRUNELLO||||Sintetico|13||XML + carta/email|Bollettino postale||false||Cartaceo||||||200015387184|ITALIA||61029|PU|||HC_VenditaMM|||false|3385050158|||Si|Iva 10% (Cod. 01)||Imposta usi domestici|Cartacea|Posta Cartacea|2023-01-04|3385050158||URBINO|ITALIA|61029|PU|VIA CA BRUNELLO|13||Switch in Ele||Si|Permanente|2023-03-01|||Contratto firmato|Ordinaria (Perm)|Quality call|||URBINO||PU||VALENTINA|EDERA|DREVNT67C42L500Y|+39|3385050158||||||61029|ITALIA|Titolare|100|Appartamento||Si|3|PNNECB24+N|V42|false||||KAKTUS SRL|STEFANI Ilaria|Agenzie|AGENZIE|VI|AG870|Maggioli|Chiara|AG870V013|Hera Comm S.p.A.|||BT|13A0-Usi di Abitazione BT|URBINO|3|Si|Domestico||false|13|Multiorario|IT001E59103901|4012729301|61029|PU|ITALIA|||VIA CA BRUNELLO|3380|||false||Energia Elettrica||3||Si|3.3||||Persona Fisica|13D0000001||||';

            MassiveLoaderRequest__c mlr = HDT_UTL_DataFactoryTst.createMassiveLoaderRequest(processName,new List<String>{mucData});
            //HDT_MassiveLoaderProcess__mdt myCMT = new HDT_MassiveLoaderProcess__mdt(DeveloperName= 'SwitchIn', MasterLabel='SwitchIn', Priority__c= 1, IsActive__c=true);
            mlr.Priority__c = 1;
            mlr.Status__c = 'In attesa di Lavorazione';
            update mlr;
            List<MassiveLoaderRequestItem__c> ms = [SELECT Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, NextStepData__c,
                                                    SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, MassiveLoaderRequest__c,
                                                    Account__c, Data__c, Lead__c, StatusDescription__c, Status__c,MassiveLoaderRequest__r.ProcessType__c 
                                                    FROM MassiveLoaderRequestItem__c ];

            ms[0].Status__c = 'In attesa di Lavorazione';
            update ms;
            System.debug(ms);
            createMapping();

            Test.startTest();
            HDT_BA_ProcessRequestItem processReq = new HDT_BA_ProcessRequestItem(mlr.Id, 1, processName);
            Database.executeBatch(processReq,1);
            Test.stopTest();

        }
    
    }

    @isTest
    public static void checkRequiredAccountFieldsTest(){
        Account iterationAccount = new Account();
        iterationAccount.FiscalCode__c = 'CLBSRN93H66D488A';
        iterationAccount.VATNumber__c = '1111115';
        iterationAccount.CustomerMarking__c = 'G1 - MMS Persona fisica';
        iterationAccount.CustomerCode__c = '1007848247';

        iterationAccount.CustomerCode__c = '';

        iterationAccount.PrimaryEmail__c = '';
        iterationAccount.MobilePhone__c = '';
        iterationAccount.OtherPhone__c = '';
        iterationAccount.PhonePrefix__c = '';
        iterationAccount.MobilePhonePrefix__c = '';
        iterationAccount.Category__c = '';

        HDT_UTL_ProcessSales process = new HDT_UTL_ProcessSales();
        process.checkRequiredAccountFields(iterationAccount);

        iterationAccount.PrimaryEmail__c = 'test@test.com';
        process.checkRequiredAccountFields(iterationAccount);
    }

    @isTest
    public static void setAccountFromDbTest(){
        HDT_UTL_ProcessSales process = new HDT_UTL_ProcessSales();
        process.accountList = new List<Account>();
        Account iterationAccount = new Account();
        iterationAccount.FiscalCode__c = 'CLBSRN93H66D488A';
        iterationAccount.VATNumber__c = '1111115';
        iterationAccount.CustomerMarking__c = 'G1 - MMS Persona fisica';
        iterationAccount.CustomerCode__c = '1007848247';
        process.accountList.add(iterationAccount);
        process.setAccountFromDb(iterationAccount);
    }

    @isTest
    public static void createContactTest(){

        Account account = new Account();
        account.DegreeOfStudies__c = 'text';
        account.CompanyOwner__c = 'text';
        account.LastName__c = 'text';
        account.Gender__c = 'text';
        account.FirstName__c = 'text';
        account.BirthDate__c = Date.today();
        account.FiscalCode__c = 'text';
        account.BirthProvince__c = 'text';
        account.MobilePhonePrefix__c = 'text';
        account.Phone = 'text';
        account.MobilePhone__c = 'text';
        account.PrimaryEmail__c = 'text';
        account.PhonePrefix__c = 'text';
        account.FAX__c = 'text';
        account.Profession__c = 'text';
        account.BillingCity = 'text';
        account.BillingCityCode__c = 'text';
        account.BillingCountry = 'text';
        account.BillingPostalCode = 'text';
        account.BillingState = 'text';
        account.BillingStreet = 'text';
        account.BillingStreetName__c = 'text';
        account.BillingStreetCode__c = 'text';
        account.BillingStreetNumber__c = 'text';
        account.BillingStreetNumberExtension__c = 'text';
        account.BillingRegion__c = 'text';
        account.BillingPlace__c = 'text';
        account.BillingPlaceCode__c = 'text';
        account.BillingIsAddressVerified__c = true;
        HDT_UTL_ProcessSales process = new HDT_UTL_ProcessSales();
        process.createContact(new Contact(), account);
    }
    
    @isTest
    public static void checkMethodTest(){
        BillingProfile__c bp = setBillingProfile();
        HDT_UTL_ProcessSales process = new HDT_UTL_ProcessSales();
        process.checkRequiredBillingProfileField(bp, 'Famiglie');
    }

    @isTest
    public static void checkMethodTest1(){        
        BillingProfile__c bp = setBillingProfile();
        bp.ContractAccountCode__c = '';
        HDT_UTL_ProcessSales process = new HDT_UTL_ProcessSales();
        process.checkRequiredBillingProfileField(bp, 'Famiglie');
    }

    @isTest
    public static void checkMethodTest2(){        
        BillingProfile__c bp = setBillingProfile();
        bp.ContractAccountCode__c = '';
        bp.InvoicingStreetName__c = '';
        HDT_UTL_ProcessSales process = new HDT_UTL_ProcessSales();
        process.checkRequiredBillingProfileField(bp, 'Famiglie');
    }

    @isTest
    public static void checkMethodTest3(){        
        BillingProfile__c bp = setBillingProfile();
        bp.ContractAccountCode__c = '';
        bp.IBAN__c = '';
        bp.IbanCountry__c = 'EN';
        HDT_UTL_ProcessSales process = new HDT_UTL_ProcessSales();
        process.checkRequiredBillingProfileField(bp, 'Famiglie');
    }

    @isTest
    public static void checkMethodTest4(){        
        BillingProfile__c bp = setBillingProfile();
        bp.ContractAccountCode__c = '';
        bp.IbanCIN_IBAN__c = '';
        HDT_UTL_ProcessSales process = new HDT_UTL_ProcessSales();
        process.checkRequiredBillingProfileField(bp, 'Famiglie');
    }

    @isTest
    public static void checkMethodTest5(){        
        BillingProfile__c bp = setBillingProfile();
        bp.ContractAccountCode__c = '';
        bp.SignatoryType__c = '';
        HDT_UTL_ProcessSales process = new HDT_UTL_ProcessSales();
        process.checkRequiredBillingProfileField(bp, 'Famiglie');
    }

    @isTest
    public static void checkMethodTest6(){        
        BillingProfile__c bp = setBillingProfile();
        bp.ContractAccountCode__c = '';
        bp.ElectronicInvoicingMethod__c = '';
        HDT_UTL_ProcessSales process = new HDT_UTL_ProcessSales();
        process.checkRequiredBillingProfileField(bp, 'Test');
    }

    @isTest
    public static void checkMethodTest7(){        
        BillingProfile__c bp = setBillingProfile();
        bp.ContractAccountCode__c = '';
        bp.ElectronicInvoicingMethod__c = 'XML + carta/email';
        bp.SubjectCode__c = '';
        HDT_UTL_ProcessSales process = new HDT_UTL_ProcessSales();
        process.checkRequiredBillingProfileField(bp, 'Test');
    }

    @isTest
    public static void checkMethodTest8(){        
        BillingProfile__c bp = setBillingProfile();
        bp.ContractAccountCode__c = '';
        bp.BillSendingMethod__c = '';
        bp.SubjectCode__c = '';
        HDT_UTL_ProcessSales process = new HDT_UTL_ProcessSales();
        process.checkRequiredBillingProfileField(bp, 'Test');
    }

    @isTest
    public static void checkMethodTest9(){        
        BillingProfile__c bp = setBillingProfile();
        bp.ContractAccountCode__c = '';
        bp.BillSendingMethod__c = 'Bolletta per e-mail';
        bp.InvoiceEmailAddress__c = '';
        HDT_UTL_ProcessSales process = new HDT_UTL_ProcessSales();
        process.checkRequiredBillingProfileField(bp, 'Test');
    }

    public static BillingProfile__c setBillingProfile(){        
        BillingProfile__c bp = new BillingProfile__c();
        bp.ContractAccountCode__c = 'x';
        bp.PaymentMethod__c = 'RID';
        bp.BillSendingMethod__c = 'x';
        bp.InvoiceEmailAddress__c = 'x';
        bp.IBAN__c = 'x';
        bp.IbanCountry__c = 'IT';
        bp.IbanCIN_IBAN__c = 'x';
        bp.IbanCIN__c = 'x';
        bp.IbanABI__c = 'x';
        bp.IbanCAB__c = 'x';
        bp.IbanCodeNumber__c = 'x';
        bp.SignatoryType__c = 'x';
        bp.BankAccountSignatoryFirstName__c = 'x';
        bp.BankAccountSignatoryLastName__c = 'x';
        bp.BankAccountSignatoryFiscalCode__c = 'x';
        bp.ElectronicInvoicingMethod__c = 'XML + carta/email';
        bp.ElectronicInvoiceCertifiedEmailAddress__c = 'x';
        bp.SubjectCode__c = 'x';
        bp.InvoicingStreetName__c = 'x';
        return bp;
    }

    @isTest
    public static void checkServicePointTest(){        
        ServicePoint__c sp = new ServicePoint__c();
        sp = setServicePoint(sp);
        sp.CommoditySector__c = 'Acqua';
        HDT_UTL_ProcessSales process = new HDT_UTL_ProcessSales();
        process.checkRequiredServicePointField(sp);
    }

    @isTest
    public static void checkServicePointTest1(){        
        ServicePoint__c sp = new ServicePoint__c();
        sp = setServicePoint(sp);
        sp.Disconnectable__c = 'No';
        sp.DisconnectibilityType__c = '';
        HDT_UTL_ProcessSales process = new HDT_UTL_ProcessSales();
        process.checkRequiredServicePointField(sp);
    }

    @isTest
    public static void checkServicePointTest2(){        
        ServicePoint__c sp = new ServicePoint__c();
        sp = setServicePoint(sp);
        sp.CommoditySector__c = 'Gas';
        sp.MeterClass__c = '';
        HDT_UTL_ProcessSales process = new HDT_UTL_ProcessSales();
        process.checkRequiredServicePointField(sp);
    }

    @isTest
    public static void checkServicePointTest3(){        
        ServicePoint__c sp = new ServicePoint__c();
        sp = setServicePoint(sp);
        sp.CommoditySector__c = 'Energia Elettrica';
        sp.MeterType__c = '';
        HDT_UTL_ProcessSales process = new HDT_UTL_ProcessSales();
        process.checkRequiredServicePointField(sp);
    }

    @isTest
    public static void checkServicePointTest4(){        
        ServicePoint__c sp = new ServicePoint__c();
        sp.CommoditySector__c = 'Gas';
        sp.ServicePointCode__c = 'IT001E53625154';
        sp.SupplyType__c = 'Domestico';
        sp.ImplantType__c = '1001-Cottura cibi';
        sp.AnnualConsumption__c = null;
        sp.MarketOrigin__c = 'Libero';
        sp.MeterClass__c = 'G2';
        sp.UseCategory__c = '001-Uso cottura cibi';
        sp.Disconnectable__c = 'Si';
        sp.DisconnectibilityType__c = '02- Pubblica utilità';
        //sp.DisconnectibilityPhone__c = false;
        sp.Resident__c = false;
        sp.PowerContractual__c = 1;
        sp.PowerAvailable__c = 1;
        sp.VoltageLevel__c = 'BT';
        sp.PlugPresence__c = 'Si';
        sp.RequestPhase__c = 'Monofase';
        sp.MeterType__c = 'Multiorario';
        sp.PowerRequested__c = 1;
        sp.PressureLevel__c = 'BP';
        sp.WithdrawalClass__c = '001 - 7 giorni';
        sp.MaxRequiredPotential__c = 1;
        sp.SupplyStreetName__c = 'x';
        HDT_UTL_ProcessSales process = new HDT_UTL_ProcessSales();
        process.checkRequiredServicePointField(sp);
    }

    @isTest
    public static void checkServicePointTest5(){        
        ServicePoint__c sp = new ServicePoint__c();
        sp.CommoditySector__c = 'Energia Elettrica';
        sp.ServicePointCode__c = 'IT001E53625154';
        sp.SupplyType__c = 'Domestico';
        sp.ImplantType__c = '1001-Cottura cibi';
        sp.AnnualConsumption__c = null;
        sp.MarketOrigin__c = 'Libero';
        sp.MeterClass__c = 'G2';
        sp.UseCategory__c = '001-Uso cottura cibi';
        sp.Disconnectable__c = 'Si';
        sp.DisconnectibilityType__c = '02- Pubblica utilità';
        //sp.DisconnectibilityPhone__c = false;
        sp.Resident__c = false;
        sp.PowerContractual__c = 1;
        sp.PowerAvailable__c = 1;
        sp.VoltageLevel__c = 'BT';
        sp.PlugPresence__c = 'Si';
        sp.RequestPhase__c = 'Monofase';
        sp.MeterType__c = 'Multiorario';
        sp.PowerRequested__c = null;
        sp.PressureLevel__c = 'BP';
        sp.WithdrawalClass__c = '001 - 7 giorni';
        sp.MaxRequiredPotential__c = 1;
        sp.SupplyStreetName__c = 'x';
        HDT_UTL_ProcessSales process = new HDT_UTL_ProcessSales();
        process.checkRequiredServicePointField(sp);
    }

    public static ServicePoint__c setServicePoint(ServicePoint__c sp){
        sp.CommoditySector__c = '';
        sp.ServicePointCode__c = 'IT001E53625154';
        sp.SupplyType__c = 'Domestico';
        sp.ImplantType__c = '1001-Cottura cibi';
        //sp.AnnualConsumption__c = 1;
        sp.MarketOrigin__c = 'Libero';
        sp.MeterClass__c = 'G2';
        sp.UseCategory__c = '001-Uso cottura cibi';
        sp.Disconnectable__c = 'No';
        sp.DisconnectibilityType__c = '02- Pubblica utilità';
        //sp.DisconnectibilityPhone__c = false;
        sp.Resident__c = false;
        sp.PowerContractual__c = 1;
        sp.PowerAvailable__c = 1;
        sp.VoltageLevel__c = 'BT';
        sp.PlugPresence__c = 'Si';
        sp.RequestPhase__c = 'Monofase';
        sp.MeterType__c = 'Multiorario';
        sp.PowerRequested__c = 1;
        sp.PressureLevel__c = 'BP';
        sp.WithdrawalClass__c = '001 - 7 giorni';
        sp.MaxRequiredPotential__c = 1;
        sp.SupplyStreetName__c = 'x';
        return sp;
    }

    public static void createMapping(){
        List<MassiveFieldsObjectMap__c> mappingList = new List<MassiveFieldsObjectMap__c>();
        mappingList.add(addMappingField('ChildOrder','PagaDepurazione','PayPurification__c'));
        mappingList.add(addMappingField('ChildOrder','PagaFognatura','PaySewer__c'));
        mappingList.add(addMappingField('ChildOrder','UnitaAbitativeUsoAgricolo','AgriculturalHousingUnit__c'));
        mappingList.add(addMappingField('ChildOrder','UnitaAbitativeUsoZootecnico','ZootechnicalHousingUnit__c'));
        mappingList.add(addMappingField('ChildOrder','UnitaAbitativeNonDomesticoGen','NotDomesticHousingUnit__c'));
        mappingList.add(addMappingField('ChildOrder','UnitaAbitativeUsoArt/comm','CommercialHousingUnit__c'));
        mappingList.add(addMappingField('ChildOrder','UnitaAbitativeDomesticoNonResidente','NotResidentDomesticHousingUnit__c'));
        mappingList.add(addMappingField('ChildOrder','ComunitaPostiLetto','ComPostiLetto__c'));
        mappingList.add(addMappingField('ChildOrder','NumeroComponentiDomesticoResidente','DomesticResidentNumber__c'));
        mappingList.add(addMappingField('ChildOrder','UnitaAbitativeDomesticoResidente','ResidentDomesticHousingUnit__c'));
        mappingList.add(addMappingField('ChildOrder','Coabitazione','Cohabitation__c'));
        mappingList.add(addMappingField('ChildOrder','NumeroCoabitanti','CohabitantsNumber__c'));
        mappingList.add(addMappingField('ChildOrder','UnitaAbitativeUsoIndustriale','IndustrialHousingUnit__c'));
        mappingList.add(addMappingField('ChildOrder','ForfaitScaricoFognatura','ForfaitSewer__c'));
        mappingList.add(addMappingField('ChildOrder','UnitaAbitativeNonDomesticoGenerico','NotDomesticHousingUnit__c'));
        mappingList.add(addMappingField('ChildOrder','NumeroBoccheIdrante','HydrantMouthsNumber__c'));
        mappingList.add(addMappingField('ChildOrder','EsclusioneDepositoCauzionale','SecurityDepositExcluded__c'));
        mappingList.add(addMappingField('ChildOrder','ClienteNonDisalimentabile','NotDisconnectabilityCustomer__c'));
        mappingList.add(addMappingField('ChildOrder','OrderUsoStagionale','SeasonUse__c'));
        mappingList.add(addMappingField('Sale__c','CanaleVendita','Channel__c'));
        mappingList.add(addMappingField('ServicePoint__c','ServicePointTelefonoNonDisalimentabili','DisconnectibilityPhone__c'));
        mappingList.add(addMappingField('ServicePoint__c','ServicePointMercatoProvenienza','MarketOrigin__c'));
        mappingList.add(addMappingField('ServicePoint__c','ServicePointTensioneConsegna','VoltageLevel__c'));
        mappingList.add(addMappingField('ServicePoint__c','ServicePointTipologiaImpianto','ImplantType__c'));
        mappingList.add(addMappingField('ServicePoint__c','ServicePointComune','SupplyCity__c'));
        mappingList.add(addMappingField('ServicePoint__c','ServicePointPotenzaRichiesta','PowerRequested__c'));
        mappingList.add(addMappingField('ServicePoint__c','ServicePointResidente','Resident__c'));
        mappingList.add(addMappingField('ServicePoint__c','ServicePointDisalimentabile','Disconnectable__c'));
        mappingList.add(addMappingField('ServicePoint__c','ServicePointTipoFornitura','SupplyType__c'));
        mappingList.add(addMappingField('ServicePoint__c','ServicePointFaseRichiesta','RequestPhase__c'));
        mappingList.add(addMappingField('ServicePoint__c','ServicePointCivico','SupplyStreetNumber__c'));
        mappingList.add(addMappingField('ServicePoint__c','ServicePointTipoApparecchiatura','MeterType__c'));
        mappingList.add(addMappingField('ServicePoint__c','ServicePointCodicePunto','ServicePointCode__c'));
        mappingList.add(addMappingField('ServicePoint__c','ServicePointCodiceImpianto','SAPImplantCode__c'));
        mappingList.add(addMappingField('ServicePoint__c','ServicePointCAP','SupplyPostalCode__c'));
        mappingList.add(addMappingField('ServicePoint__c','ServicePointProvincia','SupplyProvince__c'));
        mappingList.add(addMappingField('ServicePoint__c','ServicePointStato','SupplyCountry__c'));
        mappingList.add(addMappingField('ServicePoint__c','ServicePointLocalita','SupplyPlace__c'));
        mappingList.add(addMappingField('ServicePoint__c','ServicePointBarrato','SupplyStreetNumberExtension__c'));
        mappingList.add(addMappingField('BillingProfile__c','BillingProfileNumeroConto','IbanCodeNumber__c'));
        mappingList.add(addMappingField('BillingProfile__c','BillingProfileIBAN','IBAN__c'));
        mappingList.add(addMappingField('BillingProfile__c','BillingProfileABI','IbanABI__c'));
        mappingList.add(addMappingField('BillingProfile__c','BillingProfileEmailInvioBolletta','InvoiceEmailAddress__c'));
        mappingList.add(addMappingField('BillingProfile__c','BillingProfileBPComune','InvoicingCity__c'));
        mappingList.add(addMappingField('BillingProfile__c','BillingProfileBPVia','InvoicingStreetName__c'));
        mappingList.add(addMappingField('BillingProfile__c','BillingProfileCFsottoscrittoreCC','BankAccountSignatoryFiscalCode__c'));
        mappingList.add(addMappingField('BillingProfile__c','BillingProfileCognomeSottoscrittoreCC','BankAccountSignatoryLastName__c'));
        mappingList.add(addMappingField('BillingProfile__c','BillingProfileCINIBAN','IbanCIN_IBAN__c'));
        mappingList.add(addMappingField('BillingProfile__c','BillingProfileTiploXML','XMLType__c'));
        mappingList.add(addMappingField('BillingProfile__c','BillingProfileBPCivico','InvoicingStreetNumber__c'));
        mappingList.add(addMappingField('BillingProfile__c','BillingProfileCodiceDestinatario','SubjectCode__c'));
        mappingList.add(addMappingField('BillingProfile__c','BillingProfileModalitaInvioFattElettr','ElectronicInvoicingMethod__c'));
        mappingList.add(addMappingField('BillingProfile__c','BillingProfileModalitaPagamento','PaymentMethod__c'));
        mappingList.add(addMappingField('BillingProfile__c','BillingProfileIBANEstero','IbanIsForeign__c'));
        mappingList.add(addMappingField('BillingProfile__c','BillingProfileTipoSottoscrittore','SignatoryType__c'));
        mappingList.add(addMappingField('BillingProfile__c','BillingProfileModalitaInvioBolletta','BillSendingMethod__c'));
        mappingList.add(addMappingField('BillingProfile__c','BillingProfileCAB','IbanCAB__c'));
        mappingList.add(addMappingField('BillingProfile__c','BillingProfileCIN','IbanCIN__c'));
        mappingList.add(addMappingField('BillingProfile__c','BillingProfilePaese','IbanCountry__c'));
        mappingList.add(addMappingField('BillingProfile__c','BillingProfileContoContrattuale','ContractAccountCode__c'));
        mappingList.add(addMappingField('BillingProfile__c','BillingProfilePecFattElettronica','ElectronicInvoiceCertifiedEmailAddress__c'));
        mappingList.add(addMappingField('BillingProfile__c','BillingProfileDestinatarioDivergente','DivergentSubject__c'));
        mappingList.add(addMappingField('BillingProfile__c','BillingProfileNomeSottoscrittoreCC','BankAccountSignatoryFirstName__c'));
        mappingList.add(addMappingField('BillingProfile__c','BillingProfileStato','InvoicingCountry__c'));
        mappingList.add(addMappingField('BillingProfile__c','BillingProfileLocalita','InvoicingPlace__c'));
        mappingList.add(addMappingField('BillingProfile__c','BillingProfileCAP','InvoicingPostalCode__c'));
        mappingList.add(addMappingField('BillingProfile__c','BillingProfileProvincia','InvoicingProvince__c'));
        mappingList.add(addMappingField('BillingProfile__c','BillingProfileSuffisso','InvoicingStreetNumberExtension__c'));
        mappingList.add(addMappingField('ChildOrder','OrderNoteDL','CommentForDL__c'));
        mappingList.add(addMappingField('OrderItem','AnalisiConsumiSuperficie','Surface__c'));
        mappingList.add(addMappingField('OrderItem','AnalisiConsumiTipologiaAbitazione','DwellingType__c'));
        mappingList.add(addMappingField('ChildOrder','OrderSuperficie','SurfaceServed__c'));
        mappingList.add(addMappingField('ChildOrder','OrderLivelloPressione','PressureLevel__c'));
        mappingList.add(addMappingField('ChildOrder','OrderFatturazioneAggregata','AggregateBilling__c'));
        mappingList.add(addMappingField('ChildOrder','OrderIva','VAT__c'));
        mappingList.add(addMappingField('ChildOrder','OrderAcciseGas','ExciseGAS__c'));
        mappingList.add(addMappingField('ChildOrder','OrderAcciseEle','ExciseEle__c'));
        mappingList.add(addMappingField('ChildOrder','OrderModalitaFirma','SignatureMethod__c'));
        mappingList.add(addMappingField('ChildOrder','OrderModalitaSpedizione','DocSendingMethod__c'));
        mappingList.add(addMappingField('ChildOrder','OrderDataFirma','SignedDate__c'));
        mappingList.add(addMappingField('ChildOrder','OrderTelefonoContratto','PhoneNumber__c'));
        mappingList.add(addMappingField('ChildOrder','OrderEmailContratto','ShippingMail__c'));
        mappingList.add(addMappingField('ChildOrder','OrderSpedizioneCitta','ShippingCity__c'));
        mappingList.add(addMappingField('ChildOrder','OrderSpedizioneNazione','ShippingCountry__c'));
        mappingList.add(addMappingField('ChildOrder','OrderSpedizioneCAP','ShippingPostalCode__c'));
        mappingList.add(addMappingField('ChildOrder','OrderSpedizioneProvincia','ShippingProvince__c'));
        mappingList.add(addMappingField('ChildOrder','OrderSpedizioneVia','ShippingStreetName__c'));
        mappingList.add(addMappingField('OrderItem','AnalisiConsumiMantieniAC','KeepConsumptionsAnalysis__c'));
        mappingList.add(addMappingField('Account','AccountFlagVerificato','BillingIsAddressVerified__c'));
        mappingList.add(addMappingField('Account','AccountFAX','FAX__c'));
        mappingList.add(addMappingField('Account','AccountStato','BillingCountry'));
        mappingList.add(addMappingField('Account','AccountBP','BPSAPModel__c'));
        mappingList.add(addMappingField('Account','AccountComune','BillingCity'));
        mappingList.add(addMappingField('Account','AccountNome','FirstName__c'));
        mappingList.add(addMappingField('Account','AccountCivico','BillingStreetNumber__c'));
        mappingList.add(addMappingField('Account','AccountSilos','CompanyOwner__c'));
        mappingList.add(addMappingField('Account','AccountLocalita','BillingPlace__c'));
        mappingList.add(addMappingField('Account','AccountComuneNascita','BirthProvince__c'));
        mappingList.add(addMappingField('OrderItem','AnalisiConsumiProprietario','OwnerAC__c'));
        mappingList.add(addMappingField('Account','AccountCognome','LastName__c'));
        mappingList.add(addMappingField('Account','AccountCodiceVia','BillingStreetCode__c'));
        mappingList.add(addMappingField('Account','AccountProvincia','BillingState'));
        mappingList.add(addMappingField('Account','AccountCodiceLocalita','BillingPlaceCode__c'));
        mappingList.add(addMappingField('Account','AccountIndirizzoEstero','ShippingAddressIsForeign__c'));
        mappingList.add(addMappingField('Account','AccountCAP','BillingPostalCode'));
        mappingList.add(addMappingField('Account','AccountCategoria','Category__c'));
        mappingList.add(addMappingField('Account','AccountDataNascita','BirthDate__c'));
        mappingList.add(addMappingField('Account','AccountMarcatura','CustomerMarking__c'));
        mappingList.add(addMappingField('Account','AccountTitoloStudio','DegreeOfStudies__c'));
        mappingList.add(addMappingField('Account','AccountNomeVia','BillingStreetName__c'));
        mappingList.add(addMappingField('ChildOrder','OrderSpedizioneCivico','ShippingStreetNumber__c'));
        mappingList.add(addMappingField('ChildOrder','OrderSpedizioneBarrato','ShippingStreetNumberExtension__c'));
        mappingList.add(addMappingField('ChildOrder','Processo','ProcessType__c'));
        mappingList.add(addMappingField('OrderWrapper','CodiceOfferta','CodiceOfferta'));
        mappingList.add(addMappingField('OrderWrapper','VersioneOfferta','VersioneOfferta'));
        mappingList.add(addMappingField('OrderWrapper','AnalisiConsumi','AnalisiConsumi'));
        mappingList.add(addMappingField('OrderWrapper','CodicePromo','CodicePromo'));
        mappingList.add(addMappingField('OrderWrapper','CodiceBonus','CodiceBonus'));
        mappingList.add(addMappingField('OrderItem','AnalisiConsumiNumeroOccupanti','OccupantsNumber__c'));
        mappingList.add(addMappingField('Sale__c','Agenzia','Agency__c'));
        mappingList.add(addMappingField('Sale__c','AreaManager','AreaManager__c'));
        mappingList.add(addMappingField('Sale__c','CanaleInferioreAgenzia','LowerChannelAgency__c'));
        mappingList.add(addMappingField('Account','AccountProfessione','Profession__c'));
        mappingList.add(addMappingField('Sale__c','CanaleSuperioreAgenzia','UpperChannelAgency__c'));
        mappingList.add(addMappingField('Sale__c','CodiceAgenzia','AgencyCode__c'));
        mappingList.add(addMappingField('Sale__c','CognomeAgente','VendorLastName__c'));
        mappingList.add(addMappingField('Sale__c','NomeAgente','VendorFirstName__c'));
        mappingList.add(addMappingField('Sale__c','VendutaDa','CommercialId__c'));
        mappingList.add(addMappingField('Sale__c','SocietaVendita','SalesCompany__c'));
        mappingList.add(addMappingField('Account','AccountEmail','PrimaryEmail__c'));
        mappingList.add(addMappingField('Account','AccountPrefTelefono','PhonePrefix__c'));
        mappingList.add(addMappingField('Account','AccountEstensCivico','BillingStreetNumberExtension__c'));
        mappingList.add(addMappingField('Account','AccountSesso','Gender__c'));
        mappingList.add(addMappingField('Account','AccountPI','VATNumber__c'));
        mappingList.add(addMappingField('Account','AccountCellulare','MobilePhone__c'));
        mappingList.add(addMappingField('Account','AccountCF','FiscalCode__c'));
        mappingList.add(addMappingField('Account','AccountPrefCell','MobilePhonePrefix__c'));
        mappingList.add(addMappingField('Account','AccountCSN','CustomerCode__c'));
        mappingList.add(addMappingField('WrapperAccount','AccountTipo',''));
        mappingList.add(addMappingField('ServicePoint__c','ServicePointVia','SupplyStreetName__c'));
        mappingList.add(addMappingField('ServicePoint__c','ServicePointConsumoAnnuo','AnnualConsumption__c'));
        mappingList.add(addMappingField('ServicePoint__c','ServicePointPotenzialitaMassimaRichiesta','MaxRequiredPotential__c'));
        mappingList.add(addMappingField('ServicePoint__c','ServicePointCategoriaUso','UseCategory__c'));
        mappingList.add(addMappingField('ServicePoint__c','ServicePointIndirizzoEstero','SupplyAddessIsForeign__c'));
        mappingList.add(addMappingField('ServicePoint__c','ServicePointClassePrelievo','WithdrawalClass__c'));
        mappingList.add(addMappingField('WrapperSerPoint','ServicePointCodiceDistributore','Distributor__r'));
        mappingList.add(addMappingField('ServicePoint__c','ServicePointServizio','CommoditySector__c'));
        mappingList.add(addMappingField('ServicePoint__c','ServicePointClasseContatore','MeterClass__c'));
        mappingList.add(addMappingField('ServicePoint__c','ServicePointPotenzaContrattuale','PowerContractual__c'));
        mappingList.add(addMappingField('ServicePoint__c','ServicePointLivelloPressione','PressureLevel__c'));
        mappingList.add(addMappingField('ServicePoint__c','ServicePointPresenzaAllaccio','PlugPresence__c'));
        mappingList.add(addMappingField('ServicePoint__c','ServicePointPotenzaDisponibile','PowerAvailable__c'));
        mappingList.add(addMappingField('ServicePoint__c','ServicePointTipologiaDisalimentabilita','DisconnectibilityType__c'));
        mappingList.add(addMappingField('ServicePoint__c','ServicePointMatricolaContatore','MeterSN__c'));
        mappingList.add(addMappingField('ServicePoint__c','ServicePointCodiceRemi','RemiCode__c'));
        mappingList.add(addMappingField('ChildOrder','OrderTipoVoltura','VoltureType__c'));
        mappingList.add(addMappingField('ChildOrder','MandatoConnessione','ConnectionMandate__c'));
        mappingList.add(addMappingField('ChildOrder','OrderTipoConnessione','ConnectionType__c'));
        mappingList.add(addMappingField('Account','AccountAltroTelefono','OtherPhone__c'));
        mappingList.add(addMappingField('ChildOrder','OrderDecorrenza','EffectiveDate__c'));
        mappingList.add(addMappingField('ChildOrder','Delibera','Deliberation__c'));
        mappingList.add(addMappingField('ChildOrder','OrderEsclusioneDepCauz','SecurityDepositExcluded__c'));
        mappingList.add(addMappingField('ChildOrder','OrderAutocertContrConn','SelfCertificationConnection__c'));
        mappingList.add(addMappingField('ChildOrder','UsoEnergia','UseTypeEnergy__c'));
        mappingList.add(addMappingField('ChildOrder','OrderConfermaContrCli','ConfirmCustomerContract__c'));
        mappingList.add(addMappingField('ChildOrder','TipoVoltura','VoltureType__c'));
        mappingList.add(addMappingField('ChildOrder','DataDecorrenza','EffectiveDate__c'));
        mappingList.add(addMappingField('ChildOrder','ConvenzioneAssociazione','ConventionAssociation__c'));
        mappingList.add(addMappingField('ChildOrder','GruppoCreatore','CreatorGroup__c'));
        mappingList.add(addMappingField('ChildOrder','CanaleLogin','LoginChannel__c'));
        mappingList.add(addMappingField('Contact','ReferenteCitta','MailingCity'));
        mappingList.add(addMappingField('Contact','ReferenteCivico','MailingStreetNumber__c'));
        mappingList.add(addMappingField('Contact','ReferenteProvincia','MailingState'));
        mappingList.add(addMappingField('Contact','ReferenteVia','MailingStreet'));
        mappingList.add(addMappingField('Contact','ReferenteNome','FirstName'));
        mappingList.add(addMappingField('Contact','ReferenteCognome','LastName'));
        mappingList.add(addMappingField('Contact','ReferenteCF','FiscalCode__c'));
        mappingList.add(addMappingField('ContactRoleWrapper','ReferenteRuolo','Roles'));
        mappingList.add(addMappingField('Contact','ReferentePrefCellulare','MobilePhonePrefix__c'));
        mappingList.add(addMappingField('Contact','ReferenteCellulare','MobilePhone'));
        mappingList.add(addMappingField('Contact','ReferentePrefTelefono','PhonePrefix__c'));
        mappingList.add(addMappingField('Contact','ReferenteTelefono','HomePhone'));
        mappingList.add(addMappingField('Contact','ReferenteEmail','Email'));
        mappingList.add(addMappingField('Contact','ReferentePec','CertifiedEmail__c'));
        mappingList.add(addMappingField('Contact','ReferenteFax','Fax'));
        mappingList.add(addMappingField('Contact','ReferenteCap','MailingPostalCode'));
        mappingList.add(addMappingField('BillingProfile__c','BillingProfileCreaCA','CreateContractAccount__c'));
        mappingList.add(addMappingField('ChildOrder','AzioneCommerciale','CommercialAction__c'));
        mappingList.add(addMappingField('ChildOrder','FlagMUC','IsMuc__c'));
        mappingList.add(addMappingField('Sale__c','CampagnaCommissioning','CommissioningCampaign__c'));
        mappingList.add(addMappingField('Contact','ReferenteNazione','MailingCountry'));
        insert mappingList;
    }

    public static MassiveFieldsObjectMap__c addMappingField(String objectType, String labelField, String nameField){
        return new MassiveFieldsObjectMap__c(Name='Sales_'+labelField,objectType__c=objectType, labelField__c=labelField, nameField__c=nameField);
    }
        /*
        List<sObject> objList = new List<sObject>();
        Contact cont = new Contact();
        cont.FirstName = 'test';
        cont.LastName = 'last';
        cont.GlobalMigrationKey__c = '1';
        Account accReference = new Account();
        accReference.GlobalMigrationKey__c = '1';
        cont.Account = accReference;
        Account newAccount = new Account();
        newAccount.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Business').getRecordTypeId();
        newAccount.Name = 'test account';
        newAccount.CompanyOwner__c = 'AAA-EBT';
        newAccount.CustomerMarking__c = 'AAS Associazione';
        newAccount.Category__C = 'Aziende SME';
        newAccount.BillingCityCode__c = 'Roma';
        newAccount.BillingStreetName__c = 'via roma';
        newAccount.BillingStreetNumber__c = '55';
        newAccount.LastName__c = 'test account';
        newAccount.BillingIsAddressVerified__c = true;
        newAccount.FiscalCode__c = 'SXSRLA45H28H5';
        newAccount.VATNumber__c = '12345678';
        newAccount.IsWrongFiscalData__c = false;
        newAccount.CustomerCode__c = '1003616210';
        newAccount.GlobalMigrationKey__c = '1';
        objList.add(newAccount);
        objList.add(cont);
        Database.insert(objList);

        HDT_WS_ArrichmentDataEntityResponse serResp = HDT_WS_ArrichmentDataEntityInvoker.callService('',currentProcess.currentServicePoint.ServicePointCode__c);
        HDT_UTL_ServicePoint.extractDataFromArriccDataServiceWithExistingSp(currentProcess.currentServicePoint, serResp);


        try {
            List<ServicePoint__c> spList = [SELECT Id, MeterStatus__c,Distributor__c,Account__c FROM ServicePoint__c WHERE ServicePointCode__c  = 'IT001E04893470' LIMIT 1];
            HDT_WS_ArrichmentDataEntityResponse serResp=HDT_WS_ArrichmentDataEntityInvoker.callService('', 'IT001E04893470');
            System.debug(serResp);
            List<ServicePoint__c> spListWs = HDT_UTL_ServicePoint.extractDataFromArriccDataServiceWithExistingSp(spList[0], serResp);
            System.debug(spListWs);
        } catch (Exception e){
            System.debug('Exception > ' + e.getMessage());
        }
        System.debug('CpuTime > ' + limits.getCpuTime());

        */

        /*public static void setDataForTest(Integer numRecords){

        Id massiveLoaderRequestId = 'a3d3O000000WyvQQAS';
        Set<Id> docId = new Set<Id>();

        delete [
            SELECT Id, Data__c, NextStepData__c, Status__c, StatusDescription__c, MassiveLoaderRequest__c
            FROM MassiveLoaderRequestItem__c
            WHERE MassiveLoaderRequest__c = :massiveLoaderRequestId
        ];

        delete [
            SELECT Id, Name, RecordTypeId, RecordType.Name, CustomerCode__c, FiscalCode__c, VATNumber__c, CustomerMarking__c 
            FROM Account
            WHERE CreatedById = '0051X0000055rbNQAQ'
        ];
        
        delete [
            SELECT Id, FirstName, Account.CustomerCode__c
            FROM Contact
            WHERE CreatedById = '0051X0000055rbNQAQ'
        ];

        delete [
            SELECT Id, Account__r.CustomerCode__c
            FROM BillingProfile__c
            WHERE CreatedById = '0051X0000055rbNQAQ'
        ];

        delete [
            SELECT Id, Name, Account__r.CustomerCode__c, ServicePointCode__c
            FROM ServicePoint__c
            WHERE CreatedById = '0051X0000055rbNQAQ'
        ];

        List<ContentDocumentLink> cdlList = [
            SELECT Id, LinkedEntityId, ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :massiveLoaderRequestId
        ];

        if(cdlList.size() > 0){
            for(ContentDocumentLink c : cdlList){
                docId.add(c.ContentDocumentId);
            }

            delete cdlList;
            delete [SELECT Id FROM ContentDocument WHERE Id IN :docId];
        }

        List<MassiveLoaderRequestItem__c> itemsList = new List<MassiveLoaderRequestItem__c>();
        MassiveLoaderRequestItem__c item;
    
        List<String> tempList;
        String iteration = '';
        for(Integer n=0; n<numRecords; n++){
            item = new MassiveLoaderRequestItem__c();
            item.MassiveLoaderRequest__c = massiveLoaderRequestId;
            tempList = new List<String>();
            item.Status__c = 'In attesa di lavorazione';

            iteration = String.valueOf(n);

            // -- Account / Contact
            tempList.add('Residenziale'); // Tipo
            tempList.add('true'); // FlagVerificato

            //if(n==1){
            //    tempList.add('854455666'); // FAX - 
            //} else {
            //    tempList.add(''); // FAX - 854455666
            //}
            tempList.add(''); // FAX - 854455666
            tempList.add(''); // Stato
            tempList.add(''); // BP
            tempList.add('Roma'); // Comune
            tempList.add('Adam'); // Nome
            tempList.add(''); // Professione
            tempList.add('AAA-EBT'); // Silos
            tempList.add('Roma'); // Localita
            tempList.add(''); // ComuneNascita
            tempList.add('55'); // Civico
            tempList.add('Daniel'); // Cognome
            tempList.add(''); // CodiceVia
            tempList.add(''); // Provincia
            tempList.add('25'); // CodiceLocalita
            tempList.add(''); // IndirizzoEstero
            tempList.add('00166'); // CAP
            tempList.add('Piccoli condomini'); // Categoria
            tempList.add(''); // DataNascita
            tempList.add('AAS Parti comuni'); // Marcatura
            tempList.add(''); // TitoloStudio
            tempList.add('via roma'); // NomeVia
            tempList.add(''); // Email
            tempList.add(''); // PrefTelefono
            tempList.add(''); // EstensCivico
            tempList.add(''); // AltroTelefono
            tempList.add('1234567' + iteration); // PI - 12345678
            tempList.add(''); // Cellulare
            tempList.add('SXSRLA45H28H' + iteration); // CF - SXSRLA45H28H5
            tempList.add(''); // Sesso
            tempList.add(''); // PrefCell
            //tempList.add('');
            tempList.add('100361621' + iteration); // CSN - 1003616210
            tempList.add('00166'); // CodiceCitta

            // -- Billing Profile
            tempList.add('sono un numero'); // NumeroConto
            tempList.add(''); // IBAN
            tempList.add(''); // ABI
            tempList.add(''); // EmailInvioBolletta
            tempList.add(''); // BPComune
            tempList.add(''); // BPVia
            tempList.add(''); // CFsottoscrittoreCC
            tempList.add(''); // CognomeSottoscrittoreCC
            tempList.add(''); // CINIBAN
            tempList.add(''); // TiploXML
            tempList.add(''); // BPCivico
            tempList.add(''); // CodiceDestinatario
            tempList.add(''); // ModalitaInvioFattElettr
            tempList.add(''); // ModalitaPagamento
            tempList.add(''); // IBANEstero
            tempList.add(''); // TipoSottoscrittore
            tempList.add(''); // ModalitaInvioBolletta
            tempList.add(''); // CAB
            tempList.add(''); // CIN
            tempList.add(''); // Paese
            tempList.add(''); // PecFattElettronica
            tempList.add(''); // DestinatarioDivergente
            tempList.add(''); // NomeSottoscrittoreCC
            tempList.add(''); // ContoContrattuale

            // -- Service Point
            tempList.add(''); // SPVia
            tempList.add('25'); // ConsumoAnnuo
            tempList.add(''); // SPCodice
            tempList.add(''); // PotenzialitaMassimaRichiesta
            tempList.add(''); // CategoriaUso
            tempList.add(''); // SP_IndirizzoEstero
            tempList.add(''); // ClassePrelievo
            tempList.add(''); // Distributore
            tempList.add(''); // Servizio
            tempList.add(''); // ClasseContatore
            tempList.add(''); // PotenzaContrattuale
            tempList.add(''); // LivelloPressione
            tempList.add(''); // PresenzaAllaccio
            tempList.add(''); // PotenzaDisponibile
            tempList.add(''); // TipologiaDisalimentabilita
            tempList.add(''); // MatricolaContatore
            tempList.add(''); // CodiceRemi
            tempList.add(''); // TelefonoNonDisalimentabili
            tempList.add(''); // SPComune
            tempList.add(''); // PotenzaRichiesta
            tempList.add(''); // MercatoProvenienza
            tempList.add(''); // TensioneConsegna
            tempList.add(''); // TipologiaImpianto
            tempList.add(''); // Disalimentabile
            tempList.add(''); // TipoFornitura
            tempList.add(''); // FaseRichiesta
            tempList.add(''); // Residente
            tempList.add(''); // SP_Civico
            tempList.add(''); // TipoApparecchiatura
            tempList.add('IT001E04893470'); // CodicePunto
            tempList.add('');// CodiceImpianto
            item.Data__c = String.join(tempList, '|');
            itemsList.add(item);
        }
        insert itemsList;
    
        MassiveLoaderRequest__c mlr = new MassiveLoaderRequest__c();
        mlr.Id = massiveLoaderRequestId;
        mlr.Status__c = 'In attesa di lavorazione';
        update mlr;
    
    }*/

}