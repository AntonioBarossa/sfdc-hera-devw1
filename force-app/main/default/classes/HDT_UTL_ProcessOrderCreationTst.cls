@isTest
public with sharing class HDT_UTL_ProcessOrderCreationTst {
		
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
	
	@TestSetup
    static void setup(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
        internalUser.UserPermissionsMarketingUser=true;
        insert internalUser;

        HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, constants.PERMISSIONSET_HDT_ENABLECREDITCHECK, true);
 
        System.runAs(internalUser) {
   
            List<MassiveFieldsObjectMap__c> massFieldsMapList = new List<MassiveFieldsObjectMap__c>();
            MassiveFieldsObjectMap__c massFieldsMap = new MassiveFieldsObjectMap__c();
            massFieldsMap.Name = 'Sales_AnalisiConsumi';
            massFieldsMap.labelField__c = 'AnalisiConsumi';
            massFieldsMap.nameField__c = 'AnalisiConsumi';
            massFieldsMap.objectType__c = 'OrderWrapper';
            massFieldsMapList.add(massFieldsMap);
            
            MassiveFieldsObjectMap__c massFieldsMap1 = new MassiveFieldsObjectMap__c();
            massFieldsMap1.Name = 'Sales_CanaleVendita';
            massFieldsMap1.labelField__c = 'Canale';
            massFieldsMap1.nameField__c = 'Channel__c';
            massFieldsMap1.objectType__c = 'Sale__c';
            massFieldsMapList.add(massFieldsMap1);
            
            MassiveFieldsObjectMap__c massFieldsMap2 = new MassiveFieldsObjectMap__c();
            massFieldsMap2.Name = 'Sales_Agenzia';
            massFieldsMap2.labelField__c = 'Agenzia';
            massFieldsMap2.nameField__c = 'Agency__c';
            massFieldsMap2.objectType__c = 'Sale__c';
            massFieldsMapList.add(massFieldsMap2);
            
            MassiveFieldsObjectMap__c massFieldsMap3 = new MassiveFieldsObjectMap__c();
            massFieldsMap3.Name = 'Sales_CodiceAgenzia';
            massFieldsMap3.labelField__c = 'CodiceAgenzia';
            massFieldsMap3.nameField__c = 'AgencyCode__c';
            massFieldsMap3.objectType__c = 'Sale__c';
            massFieldsMapList.add(massFieldsMap3);
            
            MassiveFieldsObjectMap__c massFieldsMap4 = new MassiveFieldsObjectMap__c();
            massFieldsMap4.Name = 'Sales_CognomeAgente';
            massFieldsMap4.labelField__c = 'CognomeAgente';
            massFieldsMap4.nameField__c = 'VendorLastName__c';
            massFieldsMap4.objectType__c = 'Sale__c';
            massFieldsMapList.add(massFieldsMap4);
            
            MassiveFieldsObjectMap__c massFieldsMap5 = new MassiveFieldsObjectMap__c();
            massFieldsMap5.Name = 'Sales_NomeAgente';
            massFieldsMap5.labelField__c = 'NomeAgente';
            massFieldsMap5.nameField__c = 'VendorFirstName__c';
            massFieldsMap5.objectType__c = 'Sale__c';
            massFieldsMapList.add(massFieldsMap5);
            
            MassiveFieldsObjectMap__c massFieldsMap6 = new MassiveFieldsObjectMap__c();
            massFieldsMap6.Name = 'Sales_SocietaVendita';
            massFieldsMap6.labelField__c = 'SocietaVendita';
            massFieldsMap6.nameField__c = 'SalesCompany__c';
            massFieldsMap6.objectType__c = 'Sale__c';
            massFieldsMapList.add(massFieldsMap6);
            
            MassiveFieldsObjectMap__c massFieldsMap7 = new MassiveFieldsObjectMap__c();
            massFieldsMap7.Name = 'Sales_VendutaDa';
            massFieldsMap7.labelField__c = 'VendutaDa';
            massFieldsMap7.nameField__c = 'CommercialId__c';
            massFieldsMap7.objectType__c = 'Sale__c';
            massFieldsMapList.add(massFieldsMap7);

            insert massFieldsMapList;
 
            List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(2, false, 'Hera Comm', 'Azienda', 'Aziende SME');
            accList[0].SatisfactionIndexCtrl__c = 1.0;
            accList[0].PraxidiaUpdateDate__c = Date.newInstance(2021, 09, 14);
            insert accList;

            List<BillingProfile__c> bpList = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, accList[0].Id);
            List<Contact> cttList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
            List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1, false);
            spList[0].CommoditySector__c = 'Energia Elettrica';
            spList[0].SupplyType__c = 'Domestico';
            spList[0].ImplantType__c = '13A0-Usi di Abitazione BT';
            spList[0].Account__c = accList[0].Id;
            insert spList;

            List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].Id, 'Bozza');
            orderList[0].PraxidiaOverrallSatisfaction__c = 2.0;
            orderList[0].PraxidiaDateOutcome__c = Date.newInstance(2020, 08, 10);
            orderList[0].isTransition__c = true;
            orderList[0].RecordTypeId = constants.ORDER_RECORDTYPEID_ORDERDOSSIER;
            orderList[0].AgencyCode__c = 'AG133';
            orderList[0].WizardCompletedDate__c = Date.today();
            orderList[0].Contact__c = cttList[0].Id;
            orderList[0].DocumentPackage__c = 'Validato';
            orderList[0].QualityCall__c = true;
            orderList[0].SignedDate__c = Date.today().addDays(-7);
            orderList[0].ServicePoint__c = spList[0].Id;
            orderList[0].BillingProfile__c = bpList[0].Id;
            orderList[0].SapContractCode__c = '123456';
            orderList[0].TecnicalPhase__c = 'Bozza';
            orderList[0].DateSentToSII__c = System.today();
            orderList[0].Name = 'testOrderName0';
            orderList[0].Phase__c = 'Documentazione Gestita';
            insert orderList;

            List<Sale__c> sales = HDT_UTL_DataFactoryTst.createSale(1, false, accList[0].Id, 'Bozza');
            sales[0].Channel__c = 'Back office';
            sales[0].AgencyCode__c = 'AG133';
            sales[0].Agency__c = 'WITEL SRL UNIPERSONALE';
            sales[0].CommercialId__c = 'AG133V008';
            sales[0].VendorFirstName__c = 'Santa';
            sales[0].VendorLastName__c = 'Claus';
            sales[0].isTransition__c = true;
            insert sales;
            
            List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, false, accList[0].Id);
            insert contractList;

            List<Order> childOrders = HDT_UTL_DataFactoryTst.createChildOrder(1, false, accList[0].Id, sales, orderList[0].Id, cttList[0].Id);
            childOrders[0].Name = 'childOrder0';
            childOrders[0].RecordTypeId = constants.ORDER_RECORDTYPEID_VOLTURA;
            childOrders[0].ContractReference__c = contractList[0].Id;
            childOrders[0].CreditCheckDescription__c = 'Cattivo pagatore C';
            childOrders[0].Phase__c = 'Credit Check KO';
            childOrders[0].IncomingCreditCheckResult__c='OK';
            childOrders[0].ProcessType__c = 'VOLTURA';
            childOrders[0].ServicePoint__c = spList[0].Id;
            childOrders[0].isTransition__c = true;
            childOrders[0].IsMassive__c = true;
            childOrders[0].ParentOrder__c = orderList[0].Id;
            childOrders[0].Channel__c='Back office';
            childOrders[0].Market__c='Libero';
            childOrders[0].MarketOrigin__c='Libero';
            childOrders[0].SupplyType__c = 'Domestico';
            childOrders[0].CustomerCategory__c='Famiglie';
            childOrders[0].SignatureMethod__c='Cartacea';
            childOrders[0].DocSendingMethod__c='Stampa Cartacea';
            childOrders[0].VoltageLevel__c='MT';
            childOrders[0].BillingProfile__c = bpList[0].Id;
            childOrders[0].IsActivationDeferred__c =false;
            childOrders[0].EffectiveDate__c = System.Today();
            childOrders[0].DateSentToSII__c=System.Today();
            insert childOrders;

            List<AgentMatrix__c> agMatrixList = HDT_UTL_DataFactoryTst.createAgentMatrix(1, false, 'Back office');
            agMatrixList[0].AgencyCode__c = 'AG133';
            agMatrixList[0].IsMonitoring__c = true;
            insert agMatrixList;

        }
    }

    @isTest
    public static void test1(){

        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
	    User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserPermissionsMarketingUser=true;
		insert internalUser;
        HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, constants.PERMISSIONSET_HDT_ENABLECREDITCHECK, true);

        System.runAs(internalUser){

        HDT_UTL_DataFactoryTst.createWebServiceConfiguration('VerifIndirizzo','https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/data-management/files','POST','MulesoftSalesforceUser');
        String processName = 'Voltura';
        String dataVoltura = 'Voltura|1327650667|1327650667|1327650667|1327650667|CLIENTI GENERICI 20%|Azienda|Aziende Soho|Hera Comm S.p.A.|+39|3440418691|+39|null|null|null|854455666|WITEL SRL UNIPERSONALE|Napoli|Back office|Back office|Back office|AG133|VIA DELLA VITTORIA|MORINO|67050|Hera Comm S.p.A.|AQ|null|null|8|null|NA|80014|true|Back office|null|null|Ester|Verdi|null|null|WITEL SRL UNIPERSONALE|Energia Elettrica|IT001E68971403|0011X00000lNMPAQA4|Domestico|13A0-Usi di Abitazione BT|1500|Libero|null|null|Si|null|null|true|3|150|330|BT|Si|Monofase|Monorario|null|null|null|null|null|null|Bologna|1|10|true|RID|null|null|null|null|false|IT98C0987612345098765987123|IT|98|C|9876|12345|98765987123|Stesso Sottoscrittore|Marta|Esposito|STTCFR80A01F205Q|null|null|null|MORINO|VIA DELLA VITTORIA|2|false|null|Vocal Order|E-Mail|Ordinaria (Perm)|Si|2|Permanente|null|621458596|null|999999|Si|621458596|null|75|null|null|Iva 22% (Cod. 02)|2021-09-15|Draft|Analisi Consumi|null|null|null|100|4|Si|Appartamento|null|2021-04-26';
    
        List<Order> ordList = [SELECT Id,  AccountId, ServicePoint__c, BillingProfile__c, Contact__c, ParentOrder__c
                                FROM Order WHERE ProcessType__c = 'Voltura' ];
        HDT_UTL_ProcessSales.HDT_WRP_NextDataObj wrpNextDataObj = new HDT_UTL_ProcessSales.HDT_WRP_NextDataObj();
        wrpNextDataObj.accountId = ordList[0].AccountId;
        wrpNextDataObj.contactId = ordList[0].Contact__c;
        wrpNextDataObj.billProfId = ordList[0].BillingProfile__c;
        wrpNextDataObj.servPointId = ordList[0].ServicePoint__c;
        wrpNextDataObj.parentOrderId = ordList[0].ParentOrder__c;
        wrpNextDataObj.orderCompatible = true;

        MassiveLoaderRequest__c mlr = HDT_UTL_DataFactoryTst.createMassiveLoaderRequest(processName,new List<String>{dataVoltura});
        HDT_MassiveLoaderProcess__mdt myCMT = new HDT_MassiveLoaderProcess__mdt(DeveloperName= 'Subentro', MasterLabel='Subentro', Priority__c= 20, IsActive__c=true);
        mlr.Priority__c = myCMT.Priority__c;
        mlr.Status__c = 'In Lavorazione';
        update mlr;
        List<MassiveLoaderRequestItem__c> ms = [SELECT Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, NextStepData__c,
                                                SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, MassiveLoaderRequest__c,
                                                Account__c, Data__c, Lead__c, StatusDescription__c, Status__c,MassiveLoaderRequest__r.ProcessType__c 
                                                FROM MassiveLoaderRequestItem__c ];
        ms[0].NextStepData__c = JSON.serialize(wrpNextDataObj);
        ms[0].Status__c = 'In Lavorazione';
        update ms;
        System.debug(ms);

/*         HDT_UTL_ProcessOrderCreation pr =new HDT_UTL_ProcessOrderCreation();
        pr.setProcess(processName);
        pr.setMassiveLoaderRequestItemList(ms);
        pr.checks(); */

        test.startTest();
        HDT_BA_ProcessOrderCreation processReq = new HDT_BA_ProcessOrderCreation(mlr.Id, 1, processName);
        Database.executeBatch(processReq,1);

        test.stopTest();
       
        }
    
    }

/*     @isTest
    public static void testSubentro1(){

        String processName='Subentro';
        
        String dataLead = 'Titolare|Bianchi|Mario Rossi SAS|1327650667|1327650667|CLIENTI GENERICI 20%|Azienda|Aziende Soho|HERA COMM|+39|3440418691|+39|null|null|null|854455666|2015-12-31|Napoli|Maschio|Business|null|null|VIA DELLA VITTORIA|MORINO|67050|ITALIA|AQ|null|null|8|null|NA|80014|true|Back office|null|null|Ester|Verdi|null|null|WITEL SRL UNIPERSONALE|Energia Elettrica|IT001E68971403|0011X00000lNMPAQA4|Domestico|13A0-Usi di Abitazione BT|1500|Libero|null|null|Si|null|null|true|3|150|330|BT|Si|Monofase|Monorario|null|null|null|null|null|null|Bologna|1|10|true|RID|null|null|null|null|false|IT98C0987612345098765987123|IT|98|C|9876|12345|98765987123|Stesso Sottoscrittore|Marta|Esposito|STTCFR80A01F205Q|null|null|null|MORINO|VIA DELLA VITTORIA|2|false|null|Vocal Order|E-Mail|Ordinaria (Perm)|Si|2|Permanente|null|621458596|null|999999|Si|621458596|null|75|null|null|Iva 22% (Cod. 02)|2021-09-15|Draft|Analisi Consumi|null|null|null|100|4|Si|Appartamento|null|2021-04-26';
        MassiveLoaderRequest__c req= HDT_UTL_DataFactoryTst.createMassiveLoaderRequest(processName,new List<String>{dataLead});
        req.Status__c = 'In Lavorazione';
        update req;
        List<MassiveLoaderRequestItem__c> ms = [SELECT Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, NextStepData__c,
                                                SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, MassiveLoaderRequest__c,
                                                Account__c, Data__c, Lead__c, StatusDescription__c, Status__c,MassiveLoaderRequest__r.ProcessType__c 
                                                FROM MassiveLoaderRequestItem__c ];
        //ms[0].NextStepData__c = JSON.serialize(wrpNextDataObj);
        //ms[0].Data__c = JSON.serialize(wrpNextDataObj);
        ms[0].Status__c = 'In Lavorazione';
        update ms;

        test.startTest();
        HDT_BA_ProcessOrderCreation processReq = new HDT_BA_ProcessOrderCreation(req.Id, 1, processName); 
        Database.executeBatch(processReq,1);

        test.stopTest();
        MassiveLoaderRequestItem__c msResult =[SELECT  StatusDescription__c, Status__c FROM MassiveLoaderRequestItem__c WHERE MassiveLoaderRequest__c=:req.Id];
    } */
}