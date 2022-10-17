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
 
            List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(2, false, 'HERA COMM', 'Azienda', 'Aziende SME');
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
            orderList[0].AgencyCode__c = 'AgencyCode';
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
            childOrders[0].ProcessType__c = 'Switch in Fittizio';
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
            childOrders[0].IsActivationDeferred__c =false;
            childOrders[0].EffectiveDate__c = System.Today();
            childOrders[0].DateSentToSII__c=System.Today();
            insert childOrders;

            List<AgentMatrix__c> agMatrixList = HDT_UTL_DataFactoryTst.createAgentMatrix(1, false, 'Telefono');
            agMatrixList[0].AgencyCode__c = 'AgencyCode';
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
        String processName='Lead';
        List<String> dataLead = 'Titolare|Bianchi|Mario Rossi SAS|1327650667|1327650667|CLIENTI GENERICI 20%|Azienda|Aziende Soho|HERA COMM|+39|3440418691|+39|null|null|null|854455666|2015-12-31|Napoli|Maschio|Test|null|null|VIA DELLA VITTORIA|MORINO|67050|ITALIA|AQ|null|null|8|null|NA|80014|true|Back office|null|null|Ester|Verdi|null|null|WITEL SRL UNIPERSONALE|Energia Elettrica|IT001E68971403|0011X00000lNMPAQA4|Domestico|13A0-Usi di Abitazione BT|1500|Libero|null|null|Si|null|null|true|3|150|330|BT|Si|Monofase|Monorario|null|null|null|null|null|null|Bologna|1|10|true|RID|null|null|null|null|false|IT98C0987612345098765987123|IT|98|C|9876|12345|98765987123|Stesso Sottoscrittore|Marta|Esposito|STTCFR80A01F205Q|null|null|null|MORINO|VIA DELLA VITTORIA|2|false|null|Vocal Order|E-Mail|Ordinaria (Perm)|Si|2|Permanente|null|621458596|null|999999|Si|621458596|null|75|null|null|Iva 22% (Cod. 02)|2021-09-15|Draft|Analisi Consumi|null|null|null|100|4|Si|Appartamento|null|2021-04-26'.split('|');

        MassiveLoaderRequest__c mlr = HDT_UTL_DataFactoryTst.createMassiveLoaderRequest(processName,dataLead) ;
        HDT_MassiveLoaderProcess__mdt myCMT = new HDT_MassiveLoaderProcess__mdt(DeveloperName= 'Subentro', MasterLabel='Subentro', Priority__c= 20, IsActive__c=true);
        mlr.Priority__c = myCMT.Priority__c;
        update mlr;
        List<MassiveLoaderRequestItem__c> ms=[select Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, MassiveLoaderRequest__c, Account__c, Data__c, Lead__c, StatusDescription__c, Status__c,MassiveLoaderRequest__r.ProcessType__c from MassiveLoaderRequestItem__c ];
        System.debug(ms);
        HDT_UTL_ProcessOrderCreation pr =new HDT_UTL_ProcessOrderCreation();
        
        //pr.setMassiveLoaderRequestItemList(ms);
        pr.setProcess(processName);
       // pr.checks();
       
        }
    
    }

@isTest
    public static void testSubentro1(){

        String processName='Subentro';
        
        String dataLead = 'Titolare|Bianchi|Mario Rossi SAS|1327650667|1327650667|CLIENTI GENERICI 20%|Azienda|Aziende Soho|HERA COMM|+39|3440418691|+39|null|null|null|854455666|2015-12-31|Napoli|Maschio|Business|null|null|VIA DELLA VITTORIA|MORINO|67050|ITALIA|AQ|null|null|8|null|NA|80014|true|Back office|null|null|Ester|Verdi|null|null|WITEL SRL UNIPERSONALE|Energia Elettrica|IT001E68971403|0011X00000lNMPAQA4|Domestico|13A0-Usi di Abitazione BT|1500|Libero|null|null|Si|null|null|true|3|150|330|BT|Si|Monofase|Monorario|null|null|null|null|null|null|Bologna|1|10|true|RID|null|null|null|null|false|IT98C0987612345098765987123|IT|98|C|9876|12345|98765987123|Stesso Sottoscrittore|Marta|Esposito|STTCFR80A01F205Q|null|null|null|MORINO|VIA DELLA VITTORIA|2|false|null|Vocal Order|E-Mail|Ordinaria (Perm)|Si|2|Permanente|null|621458596|null|999999|Si|621458596|null|75|null|null|Iva 22% (Cod. 02)|2021-09-15|Draft|Analisi Consumi|null|null|null|100|4|Si|Appartamento|null|2021-04-26';
        MassiveLoaderRequest__c req= HDT_UTL_DataFactoryTst.createMassiveLoaderRequest(processName,new List<String>{dataLead})        ;
        test.startTest()                                                                                                              ;
        HDT_BA_ProcessOrderCreation processReq = new HDT_BA_ProcessOrderCreation(req.Id, 1, processName)                              ; 
        Database.executeBatch(processReq,1)                                                                                           ;

        test.stopTest()                                                                                                               ;
        MassiveLoaderRequestItem__c ms=[SELECT  StatusDescription__c, Status__c FROM MassiveLoaderRequestItem__c   WHERE MassiveLoaderRequest__c=:req.Id];

        

        
    }
}
