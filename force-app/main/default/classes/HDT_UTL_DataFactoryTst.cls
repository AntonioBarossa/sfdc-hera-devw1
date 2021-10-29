/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 29/06/2021
 * @description Data Factory for Test Classes
 * @history Luca Belometti -WR – 05/08/2021 – Created Merhods for creation CampaingMemberAssignment and its relative Item
 * @history Lucas Fernandes 05/08/2021 – Created 'createAccountShare' method
 */
public with sharing class HDT_UTL_DataFactoryTst{

	private staTIC HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();

	//Method to avoid 'ObjectCompatibility' errors from ProcessClick
	public static void pClickInstance(){

		wrts_prcgvr.InstallIntegration.install();
		wrts_prcgvr.VersionManager.newClassInstance('ObjectCompatibility');
	}

	//Metho to avoid PClick for OrderPhase Errors
	public static void pClickOrderPhase(){

		wrts_prcgvr.InstallIntegration.install();
		wrts_prcgvr__PhaseManagerSObjectSetting__c setting=new wrts_prcgvr__PhaseManagerSObjectSetting__c(Name='Order', wrts_prcgvr__ObjectType__c='Order', wrts_prcgvr__PivotField__c='Phase__c');
		insert setting;
	}

	//Method to avoid PClick for CasePhase Errors
	public static void pClickCasePhase(){
		wrts_prcgvr.InstallIntegration.install();
		wrts_prcgvr__PhaseManagerSObjectSetting__c setting=new wrts_prcgvr__PhaseManagerSObjectSetting__c(Name='Case', wrts_prcgvr__ObjectType__c='Case', wrts_prcgvr__PivotField__c='Phase__c');
		insert setting;
	}

		//Method to create PClick Phase Transitions
		public static void newPhaseTransition(String DestinationPhase, String OriginPhase, id recordTypeId, String recordTypeName){
			insert new Wrts_prcgvr__PhaseTransition__c(Wrts_prcgvr__Code__c=Math.random()+'', Wrts_prcgvr__DestinationPhase__c=DestinationPhase, Wrts_prcgvr__OriginPhase__c=OriginPhase, Wrts_prcgvr__RecordTypeId__c=recordTypeId, Wrts_prcgvr__RecordTypeName__c=recordTypeName, Wrts_prcgvr__Type__c='A');

		}

	public static List<Lead> createLead(Integer amount, Boolean doInsert){

		List<Lead> leadList=new List<Lead>();

		for (Integer i=0; i<amount; i++){

			Lead ld=new Lead();

			ld.FirstName='FirstNameTest' + i;
			ld.LastName='LastNameTest' + i;
			ld.CompanyOwner__c='MMS';
			ld.Company='CompanyTest' + i;
			ld.Status='New';
			ld.Email='test@test.com' + i;
			ld.Birthdate__c=date.today();
			ld.Gender__c='Maschio';
			ld.Birthcity__c='Roma';

			leadList.add(ld);

		}

		if (doInsert){

			insert leadList;
		}

		return leadList;
	}

	public static List<City__c> createCity(Integer amount, Boolean doInsert){
		List<City__c> cityList=new List<City__c>();

		for (Integer i=0; i<amount; i++){

			City__c ct=new City__c();

			ct.Name='Roma';
			ct.BelfioreCode__c='Bt'+i;

			cityList.add(ct);

		}

		if (doInsert){

			insert cityList;
		}

		return cityList;
	}

	public static List<Opportunity> createOpportunity(Integer amount, Boolean doInsert){

		List<Opportunity> oppList=new List<Opportunity>();

		for (Integer i=0; i<amount; i++){

			Opportunity opp=new Opportunity();

			opp.Name='testOpportunity'+i;
			opp.CloseDate=Date.today().addDays(30);
			opp.StageName='Negotiation';

			oppList.add(opp);
		}

		if (doInsert){

			insert oppList;
		}

		return oppList;
	}

	public static List<Account> createAccountBusiness(Integer amount, Boolean doInsert, String companyOwner, String customerMarking, String category){

		List<Account> accList=new List<Account>();

		Id rt=utlConstants.ACCOUNT_RECORDTYPEID_BUSINESS;

		for (Integer i=0; i<amount; i++){
			//** [START MOD 2021-08-20] @Author:Luca Belometti - wr (luca.belometti@webresults.it) @Description: Modified the customer code field
			//** It is a unique field, it will crash the insert of acc if the ammount param is more than 1 record
			Decimal numCustomerCode = Decimal.valueOf('1003616210');
			Decimal result = numCustomerCode + i;
			String stringResult = String.valueOf(result);
			//** [END MOD 2021-08-20] @Author:Luca Belometti - wr (luca.belometti@webresults.it) @Description: Modified the customer code field
			//** It is a unique field, it will crash the insert of acc if the ammount param is more than 1 record

			Account acc=new Account();

			acc.RecordTypeId=rt;
			acc.Name='test account'+i;
			acc.CompanyOwner__c=companyOwner;
			acc.CustomerMarking__c=customerMarking;
			acc.Category__C=category;
			acc.VATNumber__c='12345678' + String.valueOf(100 + i);
			acc.BillingCityCode__c='Roma';
			acc.BillingStreetName__c='via roma';
			acc.BillingStreetNumber__c='55';
			acc.LastName__c='test account'+i;
			acc.FiscalCode__c='SXSRLA45H28H5' + String.valueOf(500 + i);
			acc.BillingIsAddressVerified__c=true;
			//@frpanico 06/08 added Customer Code
			//** [START MOD 2021-08-20] @Author:Luca Belometti @Description: Modified the customer code field
			//** It is a unique field, it will crash the insert of acc if the ammount param is more than 1 record
			// OLD VALUE → acc.CustomerCode__c='1003616210';
        	acc.IsWrongFiscalData__c = false;
			acc.CustomerCode__c = stringResult;
			//** [END MOD 2021-08-20] @Author:Luca Belometti - wr (luca.belometti@webresults.it) @Description: Modified the customer code field
			//** It is a unique field, it will crash the insert of acc if the ammount param is more than 1 record

			accList.add(acc);

		}

		if (doInsert){

			insert accList;
		}

		return accList;
	}

	public static List<Account> createAccountResidenziale(Integer amount, Boolean doInsert, String companyOwner, String customerMarking, String category){

		List<Account> accList=new List<Account>();

		Id rt=utlConstants.ACCOUNT_RECORDTYPEID_RESINDEZIALE;

		for (Integer i=0; i<amount; i++){

			//** [START MOD 2021-08-20] @Author:Luca Belometti - wr (luca.belometti@webresults.it) @Description: Modified the customer code field
			//** It is a unique field, it will crash the insert of acc if the ammount param is more than 1 record
			Decimal numCustomerCode = Decimal.valueOf('1003616210');
			Decimal result = numCustomerCode + i;
			String stringResult = String.valueOf(result);
			//** [END MOD 2021-08-20] @Author:Luca Belometti - wr (luca.belometti@webresults.it) @Description: Modified the customer code field
			//** It is a unique field, it will crash the insert of acc if the ammount param is more than 1 record

			Account acc=new Account();

			acc.RecordTypeId=rt;
			acc.Name='test account'+i;
			acc.CompanyOwner__c=companyOwner;
			acc.CustomerMarking__c=customerMarking;
			acc.Category__C=category;
			acc.VATNumber__c='12345678' + String.valueOf(100 + i);
			acc.BillingCityCode__c='Roma';
			acc.BillingStreetName__c='via roma';
			acc.BillingStreetNumber__c='55';
			acc.LastName__c='test account'+i;
			acc.FiscalCode__c='SXSRLA45H28H5' + String.valueOf(100 + i);
			acc.FirstName__c= 'test';
			acc.LastName__c='account'+i;
			//@frpanico 06/08 added Customer Code

			//** [START MOD 2021-08-20] @Author:Luca Belometti @Description: Modified the customer code field
			//** It is a unique field, it will crash the insert of acc if the ammount param is more than 1 record
			// OLD VALUE → acc.CustomerCode__c='1003616210';
        	acc.IsWrongFiscalData__c = false;
        	acc.BillingIsAddressVerified__c = true;
			acc.CustomerCode__c = stringResult;
			//** [END MOD 2021-08-20] @Author:Luca Belometti - wr (luca.belometti@webresults.it) @Description: Modified the customer code field
			//** It is a unique field, it will crash the insert of acc if the ammount param is more than 1 record

			accList.add(acc);

		}

		if (doInsert){

			insert accList;
		}

		return accList;
	}

	public static List<Account> createAccountPartner(Integer amount, Boolean doInsert, String name) {

		List<Account> partnerAccounts = new List<Account>();		

		for (Integer i = 0; i < amount; i++) {
			
			partnerAccounts.add(
				new Account(Name = name, RecordTypeId = '11111')
			);
		}

		if (doInsert) {
			
			insert partnerAccounts;

		}

		return partnerAccounts;
	}

	public static List<Order> createOrder(Integer amount, Boolean doInsert, Id accId, String phase){

		List<Order> orderList=new List<Order>();

		Id rt=utlConstants.ORDER_RECORDTYPEID_DEFAULT;

		for (Integer i=0; i<amount; i++){

			Order ord=new Order();

			ord.RecordTypeId=rt;
			ord.Name='testOrderName'+i;
			ord.Status='Draft';
			ord.EffectiveDate=Date.today();
			ord.AccountId=accId;
			ord.EstimateAmount__c=1000;
			ord.PowerQuote__c=1000;
			ord.AdministrativeBurden__c=1;
			ord.EstimatedVAT__c=1;
			ord.ValidityDateEstimate__c=Date.today().addDays(30);
			ord.Phase__c=phase;
			ord.CIAccoutn__c='Richiesto';
			ord.QuickQuote__c='Richiesto';
			ord.ChamberCommerceRegistration__c='Richiesto';
			ord.Instance326__c='Richiesto';
			ord.DocumentLow80__c='Richiesto';
			ord.AutorizationVolturaThirdTrader__c='Richiesto';
			ord.ContractSigned__c=true;
			ord.SignedDate__c=Date.today();
			ord.SignatureMethod__c='Vocal Order';
			ord.DocSendingMethod__c='E-mail';

			orderList.add(ord);
		}

		if (doInsert){

			insert orderList;
		}

		return orderList;
	}

	public static List<Order> createOrder(Integer amount, Boolean doInsert, Id accId, List<Sale__c> sales){

		List<Order> orderList=new List<Order>();

		Id rt=utlConstants.ORDER_RECORDTYPEID_DEFAULT;

		for (Integer i=0; i<amount; i++){

			Order ord=new Order();

			ord.RecordTypeId=rt;
			ord.Name='testOrderName'+i;
			ord.Status='Draft';
			ord.EffectiveDate=Date.today();
			ord.AccountId=accId;
			ord.EstimateAmount__c=1000;
			ord.PowerQuote__c=1000;
			ord.AdministrativeBurden__c=1;
			ord.EstimatedVAT__c=1;
			ord.ValidityDateEstimate__c=Date.today().addDays(30);
			ord.Phase__c='Bozza';
			ord.CIAccoutn__c='Richiesto';
			ord.QuickQuote__c='Richiesto';
			ord.ChamberCommerceRegistration__c='Richiesto';
			ord.Instance326__c='Richiesto';
			ord.DocumentLow80__c='Richiesto';
			ord.AutorizationVolturaThirdTrader__c='Richiesto';
			ord.ContractSigned__c=true;
			ord.SignedDate__c=Date.today();
			ord.SignatureMethod__c='Vocal Order';
			ord.DocSendingMethod__c='E-mail';
			ord.Sale__c=sales[i].Id;

			orderList.add(ord);
		}

		if (doInsert){

			insert orderList;
		}

		return orderList;
	}

	public static List<Order> createChildOrder(Integer amount, Boolean doInsert, Id accId, List<Sale__c> sales, Id parentOrderId, Id contactId){

		List<Order> orderList=new List<Order>();

		Id rtVoltura=utlConstants.ORDER_RECORDTYPEID_VOLTURA;

		for (Integer i=0; i<amount; i++){

			Order childOrder=new Order();

			childOrder.RecordTypeId=rtVoltura;
			childOrder.ParentOrder__c=parentOrderId;
			childOrder.Name='testChildOrderName';
			childOrder.Status='Draft';
			childOrder.EffectiveDate=Date.today();
			childOrder.AccountId=accId;
			childOrder.EstimateAmount__c=1000;
			childOrder.PowerQuote__c=1000;
			childOrder.AdministrativeBurden__c=1;
			childOrder.EstimatedVAT__c=1;
			childOrder.ValidityDateEstimate__c=Date.today().addDays(30);
			childOrder.Phase__c='Bozza';
			childOrder.CIAccoutn__c='Richiesto';
			childOrder.QuickQuote__c='Richiesto';
			childOrder.ChamberCommerceRegistration__c='Richiesto';
			childOrder.Instance326__c='Richiesto';
			childOrder.DocumentLow80__c='Richiesto';
			childOrder.AutorizationVolturaThirdTrader__c='Richiesto';
			childOrder.ContractSigned__c=true;
			childOrder.SignedDate__c=Date.today();
			childOrder.SignatureMethod__c='Vocal Order';
			childOrder.DocSendingMethod__c='E-mail';
			childOrder.Sale__c=sales[0].Id;
			childOrder.Contact__c=contactId;
			childOrder.ProcessType__c='To define';

			orderList.add(childOrder);
		}

		if (doInsert){

			insert orderList;
		}

		return orderList;
	}

	public static List<Order> createOrderWithPricebook(Integer amount, Boolean doInsert, Id accId, List<Sale__c> sales, Id pricebook2Id){

		List<Order> orderList=new List<Order>();

		Id rt=utlConstants.ORDER_RECORDTYPEID_DEFAULT;

		for (Integer i=0; i<amount; i++){

			Order ord=new Order();

			ord.RecordTypeId=rt;
			ord.Name='testOrderName'+i;
			ord.Status='Draft';
			ord.EffectiveDate=Date.today();
			ord.AccountId=accId;
			ord.EstimateAmount__c=1000;
			ord.PowerQuote__c=1000;
			ord.AdministrativeBurden__c=1;
			ord.EstimatedVAT__c=1;
			ord.ValidityDateEstimate__c=Date.today().addDays(30);
			ord.Phase__c='Bozza';
			ord.CIAccoutn__c='Richiesto';
			ord.QuickQuote__c='Richiesto';
			ord.ChamberCommerceRegistration__c='Richiesto';
			ord.Instance326__c='Richiesto';
			ord.DocumentLow80__c='Richiesto';
			ord.AutorizationVolturaThirdTrader__c='Richiesto';
			ord.ContractSigned__c=true;
			ord.SignedDate__c=Date.today();
			ord.SignatureMethod__c='Vocal Order';
			ord.DocSendingMethod__c='E-mail';
			ord.Sale__c=sales[i].Id;
			ord.Pricebook2Id=pricebook2Id;

			orderList.add(ord);
		}

		if (doInsert){

			insert orderList;
		}

		return orderList;
	}

	public static List<Sale__c> createSale(Integer amount, Boolean doInsert, Id accId, String status){

		List<Sale__c> salesList=new List<Sale__c>();

		for (Integer i=0; i<amount; i++){

			Sale__c sale=new Sale__c();

			sale.Name='testSaleName'+i;
			sale.Status__c=status;
			sale.Account__c=accId;

			salesList.add(sale);
		}

		if (doInsert){

			insert salesList;
		}

		return salesList;
	}

	public static List<ServicePoint__c> createServicePoint(Integer amount, Boolean doInsert){

		List<ServicePoint__c> servPointList=new List<ServicePoint__c>();

		for (Integer i=0; i<amount; i++){

			ServicePoint__c servPoint=new ServicePoint__c();

			servPoint.Name='testServicePoint'+i;
			servPoint.ServicePointCode__c='testServicePointCode';


			servPointList.add(servPoint);
		}

		if (doInsert){

			insert servPointList;
		}

		return servPointList;
	}
	

	public static List<Contact> createContact(Integer amount, Boolean doInsert, Id accId){

		List<Contact> contactList=new List<Contact>();

		for (Integer i=0; i<amount; i++){

			Contact testContact=new Contact();
			testContact.FirstName='test';
			testContact.LastName='tester';
			//@frpanico 05/08 Added Company and Company Owner
			testContact.Company__c='HC+HCM+EENE';
			testContact.CompanyOwner__c='HERA COMM';
			testContact.AccountId=accId;

			contactList.add(testContact);
		}

		if (doInsert){

			insert contactList;
		}

		return contactList;
	}

	public static AccountContactRelation createAccountContactRelation(Boolean doInsert, String accountId, String contactId){
		AccountContactRelation accCtcRel=new AccountContactRelation();
		accCtcRel.AccountId=accountId;
		accCtcRel.ContactId=contactId;
		accCtcRel.Roles='Titolare';

		if (doInsert){
			insert accCtcRel;
		}

		return accCtcRel;
	}

	public static List<Contract> createContract(Integer amount, Boolean doInsert, Id accId){

		List<Contract> contractList=new List<Contract>();

		for (Integer i=0; i<amount; i++){

			Contract testContract=new Contract();
			testContract.AccountId=accId;
			//@frpanico 06/08 Added contract code
			testContract.SAPContractCode__c='301191347'+i;

			contractList.add(testContract);
		}

		if (doInsert){

			insert contractList;
		}

		return contractList;
	}
	
	
	//CASE
	
	//CASE MOROSITà
	public static List<Case> createCase(Integer amount, Boolean doInsert, Id accId, Id contactId, Id servPointId, Id contractId, Id orderId){
		return createCaseMorosita(amount, doInsert, accId, contactId, servPointId, contractId, orderId);
	}
	
	public static List<Case> createCaseMorosita(Integer amount, Boolean doInsert, Id accId, Id contactId, Id servPointId, Id contractId, Id orderId){
		
		List<Case> caseList=new List<Case>();
		
		String rtId='1111';

		for (Integer i=0; i<amount; i++){

			Case testCase=new Case();
			testCase.AccountId=accId;
			testCase.Status='In Lavorazione';
			testCase.Phase__c='Bozza';
			testCase.Subject='test';
			testCase.Type='BP/CA - errata categoria';
			testCase.Subprocess__c='Account';
			testCase.HerokuPracticeCode__c='21313232132132';
			testCase.ContactId=contactId;
			testCase.ServicePoint__c=servPointId;
			testCase.Contract__c=contractId;
			//testCase.VulturePracticeReference__c=orderId;
			testCase.Cluster__c='Pagamenti';
			testCase.RecordTypeId=rtId;
			testCase.CompanyOwner__c='HERA COMM';

			caseList.add(testCase);
		}

		if (doInsert){

			insert caseList;
		}

		return caseList;
	}
	
	//CASE DOCUMENTALE/COPIA CONTRATTO
	public static List<Case> createCaseDocumentale(Integer amount, Boolean doInsert, Id accId, Id contactId, Id servPointId, Id contractId, Id orderId){
		
		List<Case> caseList=new List<Case>();
		
		String rtId='1111';

		for (Integer i=0; i<amount; i++){

			Case testCase=new Case();
			testCase.AccountId=accId;
			testCase.Status='In Lavorazione';
			testCase.Phase__c='Bozza';
			testCase.Subject='test';
			testCase.Type='Allineamento Anagrafica';
			testCase.Subprocess__c='Account';
			testCase.HerokuPracticeCode__c='21313232132132';
			testCase.ContactId=contactId;
			testCase.ServicePoint__c=servPointId;
			testCase.Contract__c=contractId;
			//testCase.VulturePracticeReference__c=orderId;
			testCase.Cluster__c='Pagamenti';
			testCase.RecordTypeId=rtId;
			testCase.CompanyOwner__c='HERA COMM';

			caseList.add(testCase);
		}

		if (doInsert){

			insert caseList;
		}

		return caseList;
	}
	
	

	public static List<OrderItem> createOrderItem(Integer amount, Boolean doInsert, Id orderId, Id servicePointId, Id product2Id, Id pricebookEntryId){

		List<OrderItem> orderItemsList=new List<OrderItem>();

		for (Integer i=0; i<amount; i++){

			OrderItem orderItem=new orderItem();

			orderItem.ServicePoint__c=servicePointId;
			orderItem.OrderId=orderId;
			orderItem.Product2Id=product2Id;
			orderItem.PricebookEntryId=pricebookEntryId;
			orderItem.UnitPrice=0;
			orderItem.Quantity=1;

			orderItemsList.add(orderItem);
		}

		if (doInsert){

			insert orderItemsList;
		}

		return orderItemsList;
	}

	public static List<Product2> createProduct2(Integer amount, Boolean doInsert){

		List<Product2> productList=new List<Product2>();

		for (Integer i=0; i<amount; i++){

			Product2 product=new Product2();

			product.Name='testProduct2Name'+i;

			productList.add(product);
		}

		if (doInsert){

			insert productList;
		}

		return productList;
	}

	public static List<PricebookEntry> createPricebookEntry(List<Product2> productList, Boolean doInsert, Id pricebookId){

		List<PricebookEntry> pricebookEntries=new List<PricebookEntry>();

		for (Product2 product:productList){

			pricebookEntries.add(new PricebookEntry(Product2Id=product.Id, Pricebook2Id=pricebookId, UseStandardPrice=false, UnitPrice=0, IsActive=true));
		}

		if (doInsert){

			insert pricebookEntries;
		}

		return pricebookEntries;
	}

	public static List<AgentMatrix__c> createAgentMatrix(Integer amount, Boolean doInsert, String channel){

		List<AgentMatrix__c> agentMatrixList=new List<AgentMatrix__c>();

		for (Integer i=0; i<amount; i++){

			AgentMatrix__c testAgentMatrix=new AgentMatrix__c();
			testAgentMatrix.Channel__c=channel;

			agentMatrixList.add(testAgentMatrix);
		}

		if (doInsert){

			insert agentMatrixList;
		}

		return agentMatrixList;
	}

	public static List<BillingProfile__c> createBillingProfile(Integer amount, Boolean doInsert, Id Account){

		List<BillingProfile__c> tstBillingProfileList=new List<BillingProfile__c>();

		for (Integer i=0; i<amount; i++){
			//** [START MOD 2021-08-20] @Author:Luca Belometti - wr (luca.belometti@webresults.it) @Description: Modified the ContractAccountCode__c field
			//** It is a unique field, it will crash the insert of BillingProfile__c if the ammount param is more than 1 record
			Decimal numCustomerCode = Decimal.valueOf('200008867681');
			Decimal result = numCustomerCode + i;
			String stringResult = String.valueOf(result);
			//** [END MOD 2021-08-20] @Author:Luca Belometti - wr (luca.belometti@webresults.it) @Description: Modified the ContractAccountCode__c field
			//** It is a unique field, it will crash the insert of BillingProfile__c if the ammount param is more than 1 record

			BillingProfile__c testBillingProfile=new BillingProfile__c();
			testBillingProfile.Account__c=Account;
			//@frpanico 06/08 added CaCode
			
			//** [START MOD 2021-08-20] @Author:Luca Belometti - wr (luca.belometti@webresults.it) @Description: Modified the ContractAccountCode__c field
			//** It is a unique field, it will crash the insert of BillingProfile__c if the ammount param is more than 1 record
			//OLDVALUE: testBillingProfile.ContractAccountCode__c='200008867681';
			testBillingProfile.ContractAccountCode__c = stringResult;
			//** [END MOD 2021-08-20] @Author:Luca Belometti - wr (luca.belometti@webresults.it) @Description: Modified the ContractAccountCode__c field
			//** It is a unique field, it will crash the insert of BillingProfile__c if the ammount param is more than 1 record

			

			tstBillingProfileList.add(testBillingProfile);
		}

		if (doInsert){

			insert tstBillingProfileList;
		}

		return tstBillingProfileList;
	}

	/**
    * @author Andrea Arosio (andrea.arosio@webresults.it)
    * @date 22/07/2021
    * @return void
    */
	public static void installPhaseManagerSObjectSetting() {
        try{
            wrts_prcgvr__PhaseManagerSObjectSetting__c setting = new wrts_prcgvr__PhaseManagerSObjectSetting__c(Name = 'Order',
			wrts_prcgvr__ObjectType__c = 'Order',
			wrts_prcgvr__PivotField__c = 'Phase__c');
            upsert setting Name;
        }catch (Exception ex){
            
			System.debug('Error to upsert Phase Manager SObject Setting : '  +ex.getmessage());
        }
    }
	/**
    * @author Andrea Arosio (andrea.arosio@webresults.it)
    * @date 22/07/2021
    * @return void
    */
	public static void installCsDependecyPhaseCheckSetting() {
        try{
            CS_DependecyPhaseCheck__c setting = new CS_DependecyPhaseCheck__c(Name = 'Comunicazione verso Heroku',
			Phase__c = 'Comunicazione verso Heroku');
            upsert setting Name;
        }catch (Exception ex){
            
			System.debug('Error to upsert CS Dependecy Phase Check : '  +ex.getmessage());
        }
    }
	/**
    * @author Andrea Arosio (andrea.arosio@webresults.it)
    * @date 22/07/2021
    * @return void
    */
	public static wrts_prcgvr__PhaseTransition__c insertPhaseTransition( String apexCalloutActions, String buttonStyle,
            String calloutParameters, String calloutTemplate, String code, String description,
            String destinationPhase, String ensureChildren, String hyperLinkTarget,
            String hyperLinkUrl, Boolean isManualCallout, String originPhase, String label,
            String confirmMessage, String recordTypeId, String recordTypeName, String tooltip, String type, Boolean doDml) {
			Savepoint sp = Database.setSavePoint();
			wrts_prcgvr__PhaseTransition__c pt = null;
			try{
				pt = new wrts_prcgvr__PhaseTransition__c(
				wrts_prcgvr__ApexCalloutActions__c = apexCalloutActions,
				wrts_prcgvr__ButtonStyle__c = buttonStyle,
				wrts_prcgvr__CalloutParameters__c = calloutParameters,
				wrts_prcgvr__CalloutTemplate__c = calloutTemplate,
				wrts_prcgvr__Code__c = String.isBlank(code) ? generateGuid() : code,
				wrts_prcgvr__Description__c = description,
				wrts_prcgvr__DestinationPhase__c = destinationPhase,
				wrts_prcgvr__EnsureChildren__c =  ensureChildren,
				wrts_prcgvr__HyperLinkTarget__c =  hyperLinkTarget,
				wrts_prcgvr__HyperLinkUrl__c =  hyperLinkUrl,
				wrts_prcgvr__IsManualCallout__c =  isManualCallout,
				wrts_prcgvr__OriginPhase__c = originPhase,
				wrts_prcgvr__Label__c = label,
				wrts_prcgvr__ConfirmMessage__c = confirmMessage,
				wrts_prcgvr__RecordTypeId__c = recordTypeId,
				wrts_prcgvr__RecordTypeName__c = recordTypeName,
				wrts_prcgvr__Tooltip__c = tooltip,
				wrts_prcgvr__Type__c = type
			);
            if (doDml) {
                insert pt;
            }
        }catch (Exception ex){
            Database.rollback(sp);
            System.debug('Failed to insert PhaseTransition__c'  + ex.getmessage());
        }
		return pt;
	}
	/**
    * @author Andrea Arosio (andrea.arosio@webresults.it)
    * @date 22/07/2021
    * @return void
    */
	public static String generateGuid() {
        String kHexChars = '0123456789abcdefABCDEF';
        String returnValue = '';
        Integer nextByte = 0;
        for (Integer i = 0; i < 16; i++) {
            if (i == 4 || i == 6 || i == 8 || i == 10) {
                returnValue += '-';
            }

            nextByte = (Math.round(Math.random() * 255) - 128) & 255;

            if (i == 6) {
                nextByte = nextByte & 15;
                nextByte = nextByte | (4 << 4);
            }

            if (i == 8) {
                nextByte = nextByte & 63;
                nextByte = nextByte | 128;
            }

            returnValue += charAt(kHexChars, nextByte >> 4);
            returnValue += charAt(kHexChars, nextByte & 15);
        }
        return returnValue;
    }
	/**
    * @author Andrea Arosio (andrea.arosio@webresults.it)
    * @date 22/07/2021
    * @return void
    */
	public static String charAt(String str, Integer index) {
        if (str == null) {
            return null;
        }

        if (str.length() <= 0) {
            return str;
        }

        if (index < 0 || index >= str.length()) {
            return null;
        }
        return str.substring(index, index + 1);
    }
	/**
    * @author Andrea Arosio (andrea.arosio@webresults.it)
    * @date 22/07/2021
	* @param1 Integer amount
	* @param2 Boolean doInsert
	* @param3 String incoming process
	* @param4 String blocking process
	* @param5 String checking phase
	* @param6 String matching field
    * @return List<DependenciesMatrix__c>
    */
	public static List<DependenciesMatrix__c> createDependenciesMatrix(Integer amount, Boolean doInsert, String incoming, String blocking, String checking, String matching){

		List<DependenciesMatrix__c> depMatrixList=new List<DependenciesMatrix__c>();

		for (Integer i=0; i<amount; i++){

			DependenciesMatrix__c depMtx=new DependenciesMatrix__c();

			depMtx.IncomingProcessType__c = incoming;
			depMtx.BlockingProcessType__c = blocking;
			depMtx.CheckingPhase__c = checking;
			depMtx.MatchingField__c = matching;

			depMatrixList.add(depMtx);
		}

		if (doInsert){

			insert depMatrixList;
		}

		return depMatrixList;
	}

	public static List<SBQQ__Quote__c> createQuote (Integer amount, Boolean doInsert, Id orderId, Id opportunityId, Id saleId, String type) {

		List<SBQQ__Quote__c> quoteList=new List<SBQQ__Quote__c>();

		for (Integer i=0; i<amount; i++){

			SBQQ__Quote__c quote=new SBQQ__Quote__c();
			quote.SBQQ__Type__c=type;
			quote.OrderReference__c=orderId;
			quote.SBQQ__Opportunity2__c=opportunityId;
			quote.Sale__c=saleId;

			quoteList.add(quote);
		}

		if (doInsert){

			insert quoteList;
		}

		return quoteList;
	}

	public static List<Pricebook2> createPricebook(Integer amount, Boolean doInsert){

		List<Pricebook2> pricebookList=new List<Pricebook2>();

		for (Integer i=0; i<amount; i++){

			Pricebook2 pricebook=new Pricebook2();

			pricebook.Name='Test Price Book'+i;
			pricebook.IsActive=true;

			pricebookList.add(pricebook);
		}

		if (doInsert){

			insert pricebookList;
		}

		return pricebookList;
	}

	public static List<Attachment> createAttachment(Integer amount, Boolean doInsert, Id Account){

		List<Attachment> tstAttachmentList=new List<Attachment>();

		string tempString='Blob body test';
		Blob tempBlob=Blob.valueOf(tempString);

		for (Integer i=0; i<amount; i++){

			Attachment testAttachment=new Attachment();
			testAttachment.Name='test';
			testAttachment.ParentId=Account;
			testAttachment.Body=tempBlob;

			tstAttachmentList.add(testAttachment);
		}

		if (doInsert){

			insert tstAttachmentList;
		}

		return tstAttachmentList;
	}

	public static List<ContentVersion> createContentVers(Integer amount, Boolean doInsert){

		List<ContentVersion> tstContentVersList=new List<ContentVersion>();

		string tempString='Version Data test';
		Blob tempBlob=Blob.valueOf(tempString);

		for (Integer i=0; i<amount; i++){

			ContentVersion testContentVers=new ContentVersion();
			testContentVers.PathOnClient='S';
			testContentVers.Title='test';
			testContentVers.VersionData=tempBlob;
			testContentVers.ContentLocation='S';

			tstContentVersList.add(testContentVers);
		}

		if (doInsert){

			insert tstContentVersList;
		}

		return tstContentVersList;
	}

	public static List<Campaign> createCampaign(Integer amount, Boolean doInsert){

		List<Campaign> campaignList=new List<Campaign>();

		for (Integer i=0; i<amount; i++){

			Campaign cp=new Campaign();

			cp.Name='Test Campaign';

			campaignList.add(cp);
		}

		if (doInsert){

			insert campaignList;
		}

		return campaignList;
	}

	//** [START MOD 2021-08-13] @Author Andrei Necsulescu  - WR (andrei.necsulescu@webresults.it) @Description: Added Method to Create a record of CampaignMember
	public static List<CampaignMember> createCampaignMember(Integer amount, Boolean doInsert, String campaignId, String leadId, String contactId) {

		List<CampaignMember> campaignMembers = new List<CampaignMember>();

		for (Integer i = 0; i < amount; i++) {
			
			campaignMembers.add(new CampaignMember(
				CampaignId = campaignId,
				LeadId = leadId,
				ContactId = contactId
			));

		}

		if (doInsert) {

			insert campaignMembers;

		}

		return campaignMembers;

	}

	//** [START MOD 2021-08-05] @Author:Luca Belometti - WR (luca.belometti@webresults.it) @Description: Added Method to Create a record of CampaignMemberAssigmentItem
	public static List<CampaignMemberAssigment__c> createCampaignMemberAssigment(Integer amount, Boolean doInsert, Boolean active, String name){

		List<CampaignMemberAssigment__c> campaignMemberAssigmentList=new List<CampaignMemberAssigment__c>();

		for (Integer i=0; i<amount; i++){

			CampaignMemberAssigment__c cma=new CampaignMemberAssigment__c();

			cma.Active__c=active;
			cma.Name=name;

			campaignMemberAssigmentList.add(cma);
		}

		if (doInsert){

			insert campaignMemberAssigmentList;
		}

		return campaignMemberAssigmentList;
	}

	public static List<CampaignMemberAssigmentItem__c> createCampaignMemberAssigmentItem(Integer amount, Boolean doInsert, Id accountId, Id CampaingMemberAssigmentId, String ProcessingType, Decimal PercentageAllocation){

		List<CampaignMemberAssigmentItem__c> campaignMemberAssigmentItemList=new List<CampaignMemberAssigmentItem__c>();

		for (Integer i=0; i<amount; i++){

			CampaignMemberAssigmentItem__c cma=new CampaignMemberAssigmentItem__c();

			cma.Agency__c=accountId;
			cma.CampaingMemberAssigment__c=CampaingMemberAssigmentId;
			cma.PercentageAllocation__c=PercentageAllocation;
			cma.ProcessingType__c=ProcessingType;

			campaignMemberAssigmentItemList.add(cma);
		}

		if (doInsert){

			insert campaignMemberAssigmentItemList;
		}

		return campaignMemberAssigmentItemList;
	}

	//** [END MOD 2021-08-05] @Author:Luca Belometti - WR (luca.belometti@webresults.it) @Description: Added Method to Create a record of CampaignMemberAssigmentItem
	public static List<CampaignMemberStatus> createCampaignMemberStatus(Integer amount, Boolean doInsert, Id CampaignId){

		List<CampaignMemberStatus> campaignMemberStatusList=new List<CampaignMemberStatus>();

		for (Integer i=0; i<amount; i++){

			CampaignMemberStatus cpms=new CampaignMemberStatus();

			cpms.Label='Test Label';
			cpms.CampaignId=CampaignId;
			cpms.IsDefault=true;

			campaignMemberStatusList.add(cpms);
		}

		if (doInsert){

			insert campaignMemberStatusList;
		}

		return campaignMemberStatusList;
	}

	public static void createPhaseTransition(Boolean doInsert, String destinationPhase, String originPhase, String recordTypeId, String recordTypeName, String type, String calloutTemplate, String calloutParameters, String apexCalloutAction){
		List<wrts_prcgvr__PhaseTransition__c> phaseTransitions=new List<wrts_prcgvr__PhaseTransition__c>();
		wrts_prcgvr__PhaseTransition__c phaseTransition=new wrts_prcgvr__PhaseTransition__c();
		phaseTransition.wrts_prcgvr__Code__c=Math.random()+'';
		phaseTransition.wrts_prcgvr__DestinationPhase__c=destinationPhase;
		phaseTransition.wrts_prcgvr__OriginPhase__c=originPhase;
		phaseTransition.wrts_prcgvr__RecordTypeId__c=recordTypeId;
		phaseTransition.wrts_prcgvr__RecordTypeName__c=recordTypeName;
		phaseTransition.wrts_prcgvr__Type__c=type;
		phaseTransition.wrts_prcgvr__CalloutTemplate__c=calloutTemplate;
		phaseTransition.wrts_prcgvr__CalloutParameters__c=calloutParameters;
		phaseTransition.wrts_prcgvr__ApexCalloutActions__c=apexCalloutAction;
		phaseTransitions.add(phaseTransition);
		if (doInsert){
			insert phaseTransitions;
		}
	}

	public static String getProfileId(String profileName){
		String profileId='';

		if (String.isNotEmpty(profileName)){
			profileId=[SELECT Id
			           FROM Profile
			           WHERE Name=:profileName].Id;
		}

		return profileId;
	}

	public static String getPermissionSetId(String permissionSetName){
		String permissionSetId='';

		if (!String.isEmpty(permissionSetName)){
			permissionSetId=[SELECT Id
			                 FROM permissionSet
			                 WHERE Name=:permissionSetName].Id;
		}

		return permissionSetId;
	}

	public static User createInternalUser(String profileId, Boolean doInsert){

		User internalUser=new User(Alias='crmuser', FirstName='FirstName', LastName='LastName', Email='crmuser@test.com', EmailEncodingKey='UTF-8', LanguageLocaleKey='it', LocaleSidKey='it', ProfileId=profileId, TimeZoneSidKey='Europe/Rome', UserName='crmuser@test.com'+DateTime.now().getTime());
		if (doInsert){

			insert internalUser;
		}
		return internalUser;
	}

	public static User createCommunityUser(Contact contact, String profileId ,Boolean doInsert) {
        User communityUser = new User(
                Alias = 'commuser',
                FirstName = 'FirstName',
                LastName = 'LastName',
                Email = 'commuser@test.com',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'it',
                LocaleSidKey = 'it',
                ProfileId = profileId,
                ContactId = contact.Id,
                TimeZoneSidKey = 'Europe/Rome',
                UserName = 'commuser@test.com' + DateTime.now().getTime()
        );
        if(doInsert) {
            insert communityUser;
        }
        return communityUser;
    }

	public static PermissionSetAssignment assignPermissionSet(User u, String permissionSet, Boolean doInsert){

		PermissionSetAssignment psa=new PermissionSetAssignment(PermissionSetId=getPermissionSetId(permissionSet), AssigneeId=u.Id);

		if (doInsert){

			insert psa;

		}

		return psa;
	}

	public static List<ContentDocumentLink> createContentDocumentLink(Integer Amount, Boolean doInsert, Id OpportunityId, Id ContentDocId){

		List<ContentDocumentLink> contentDocLinkList=new List<ContentDocumentLink>();

		for (Integer i=0; i<amount; i++){

			ContentDocumentLink contentDocLink=new ContentDocumentLink();

			contentDocLink.LinkedEntityId=OpportunityId;
			contentDocLink.ContentDocumentId=ContentDocId;
			contentDocLink.ShareType='V';

			contentDocLinkList.add(contentDocLink);
		}

		if (doInsert){

			insert contentDocLinkList;
		}

		return contentDocLinkList;
	}

	public static List<FileTemplate__c> createFileTemplate(Integer Amount, Boolean doInsert){

		List<FileTemplate__c> ftList=new List<FileTemplate__C>();

		for (Integer i=0; i<amount; i++){

			FileTemplate__c fileTemplate=new FileTemplate__c();

			fileTemplate.HeadLineIndex__c=1.0;
			fileTemplate.FileTemplateName__c='Test File Template';
			fileTemplate.FileTemplateApiName__c='Test File Template Api';
			fileTemplate.FileDelimiter__c=',';
			fileTemplate.FileExtension__c='.csv';
			fileTemplate.FileType__c='CSV';

			ftList.add(fileTemplate);
		}

		if (doInsert){

			insert ftList;
		}

		return ftList;
	}

	public static List<FileTemplateColumn__c> createFileTemplateColumn(Integer Amount, Boolean doInsert, Id fileTemplateId){

		List<FileTemplateColumn__c> ftcList=new List<FileTemplateColumn__c>();

		for (Integer i=0; i<amount; i++){

			FileTemplateColumn__c fileTemplateCol=new FileTemplateColumn__c();

			fileTemplateCol.FileTemplate__c=fileTemplateId;
			fileTemplateCol.HeaderApiName__c='Test Header API Name';
			fileTemplateCol.HeaderName__c='Test Header Name';
			fileTemplateCol.Index__c=1.0;
			fileTemplateCol.Mandatory__c=true;
			fileTemplateCol.DataType__c='Text';
			fileTemplateCol.ValidationRegex__c='Test Validation Regex';
			fileTemplateCol.SobjectType__c='Opportunity';

			ftcList.add(fileTemplateCol);
		}

		if (doInsert){

			insert ftcList;
		}

		return ftcList;
	}

	public static List<SaleServiceItem__c> createSaleServiceItem(Integer amount, Boolean doInsert, Id oppId, Id quoteId, Id servicePointId){

		List<SaleServiceItem__c> saleServiceItemList=new List<SaleServiceItem__c>();

		for (Integer i=0; i<amount; i++){

			SaleServiceItem__c saleServiceItem=new SaleServiceItem__c();

			saleServiceItem.Opportunity__c=oppId;
			saleServiceItem.Quote__c=quoteId;
			saleServiceItem.ServicePoint__c=servicePointId;

			saleServiceItemList.add(saleServiceItem);
		}

		if (doInsert){

			insert saleServiceItemList;
		}

		return saleServiceItemList;
	}

	public static List<DocumentalPayloadAdministration__c> createDocumentalPayloadAdm(){
		List<DocumentalPayloadAdministration__c> lstSobj=new List<DocumentalPayloadAdministration__c>();
		DocumentalPayloadAdministration__c sobj=new DocumentalPayloadAdministration__c();
		sobj.IsData__c=false;
		sobj.Iterative__c='NO';
		sobj.ManageAmount__c=false;
		sobj.PayloadField__c='TESTATA DRIVER';
		sobj.OrderPayloadField__c=0;
		sobj.OrderSection__c=0;
		sobj.Type__c='DRV01';
		lstSobj.add(sobj);

		sobj=new DocumentalPayloadAdministration__c();
		sobj.IsData__c=false;
		sobj.Expression__c='IF|FormParameters.IsFromBatch|=|Y|Batch|Hera';
		sobj.Iterative__c='';
		sobj.ManageAmount__c=false;
		sobj.PayloadField__c='SOURCE';
		sobj.OrderPayloadField__c=1;
		sobj.OrderSection__c=0;
		sobj.Type__c='DRV01';
		lstSobj.add(sobj);

		sobj=new DocumentalPayloadAdministration__c();
		sobj.IsData__c=false;
		sobj.Iterative__c='';
		sobj.ManageAmount__c=false;
		sobj.PayloadField__c='CLUSTER';
		sobj.OrderPayloadField__c=2;
		sobj.OrderSection__c=0;
		sobj.Type__c='DRV01';
		sobj.Object1__c='Order';
		sobj.Object2__c='Case';
		sobj.Field1__c='Cluster__c';
		sobj.Field2__c='Cluster__c';
		lstSobj.add(sobj);
		insert lstSobj;

		return lstSobj;
	}

	public static void createJsonPayload(){
		HDT_WRP_DocumentalConfiguration.HDT_WRP_DatabaseResult wrpPayload=HDT_LC_DocumentalConfigController.controllerHandler();
	}

	public static void createDriverJson(){
		Id folderId=[SELECT Id
		             FROM Folder
		             WHERE DeveloperName=:'DocumentalPayloadAdministration'
		             LIMIT 1].Id;
		List<DocumentalPayloadAdministration__c> docPayloadAdminList;
		docPayloadAdminList=HDT_QR_DocumentalConfiguration.getDocumentalPayloadAdministration(docPayloadAdminList);
		Map<String, List<DocumentalPayloadAdministration__c>> contextOneMap=new Map<String, List<DocumentalPayloadAdministration__c>>();
		for (DocumentalPayloadAdministration__c dpa:docPayloadAdminList){
			if (contextOneMap.containsKey(dpa.Type__c)){
				contextOneMap.get(dpa.Type__c).add(dpa);
			} else{
				contextOneMap.put(dpa.Type__c, new List<DocumentalPayloadAdministration__c>{dpa});
			}
		}
		List<Document> docList=new List<Document>();
		HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalStructure docOneStructure;
		docOneStructure=HDT_LC_DocumentalConfigController.convertMapToStructure(contextOneMap, docOneStructure);
		Document docOne=HDT_LC_DocumentalConfigController.generateDocumentObject(docOneStructure, 'Driver3', folderId);
		docList.add(docOne);
		docOneStructure=null;
		HDT_WRP_DocumentalConfiguration.HDT_WRP_DatabaseResult databaseResult;
		databaseResult=HDT_LC_DocumentalConfigController.databaseInsert(docList, databaseResult);
	}

	public static List<ContentVersion> createContentVersion(Integer amount, Boolean doInsert, string title, String body, String pathOnClient){
		List<ContentVersion> contentVersionList=new List<ContentVersion>();
		Blob bodyBlob=Blob.valueOf(body);
		for (Integer i=0; i<amount; ++i){
			ContentVersion contentVersion=new ContentVersion();
			contentVersion.Title=title;
			contentVersion.VersionData=bodyBlob;
			contentVersion.PathOnClient=pathOnClient;
			contentVersionList.add(contentVersion);
		}
		if (doInsert){
			insert contentVersionList;
		}
		List<ContentVersion> contentVersionListUpd=[SELECT Id, Title, VersionData, PathOnClient, ContentDocumentId
		                                            FROM ContentVersion];
		return contentVersionListUpd;
	}

	public static List<wrts_prcgvr__CalloutTemplate__c> createCalloutTemplate(Integer amount, Boolean doInsert, String name, String code, boolean nullFields, String objName, String structure, String configFile){
		List<wrts_prcgvr__CalloutTemplate__c> calloutTemplatesList=new List<wrts_prcgvr__CalloutTemplate__c>();
		for (Integer i=0; i<amount; ++i){
			wrts_prcgvr__CalloutTemplate__c calloutTemplate=new wrts_prcgvr__CalloutTemplate__c();
			calloutTemplate.Name=name;
			calloutTemplate.wrts_prcgvr__Code__c=code;
			calloutTemplate.wrts_prcgvr__ConfigurationFile__c=configFile;
			calloutTemplate.wrts_prcgvr__IncludeNullFields__c=nullFields;
			calloutTemplate.wrts_prcgvr__ObjectType__c=objName;
			calloutTemplate.wrts_prcgvr__Structure__c=structure;
			calloutTemplatesList.add(calloutTemplate);
		}
		if (doInsert){
			insert calloutTemplatesList;
		}
		return calloutTemplatesList;
	}

	public static void createEndpointRule(Integer amount, Boolean doInsert, String name){
		List<wrts_prcgvr__EndpointRule__c> endpointRuleList=new List<wrts_prcgvr__EndpointRule__c>();
		for (Integer i=0; i<amount; ++i){
			wrts_prcgvr__EndpointRule__c endpointRule=new wrts_prcgvr__EndpointRule__c();
			endpointRule.Name=name;
			endpointRule.wrts_prcgvr__ClientType__c='REST';
			endpointRule.wrts_prcgvr__ContentType__c='application/json';
			endpointRule.wrts_prcgvr__IsActive__c=true;
			endpointRule.wrts_prcgvr__NamedCredential__c=name;
			endpointRule.wrts_prcgvr__Order__c=1;
			endpointRuleList.add(endpointRule);
		}
		if (doInsert){
			insert endpointRuleList;
		}
	}

	public static String notifEsReq(String processCategory, String recordId, String phase, String method){
		return '{"header": null,"requests": ['+
				'{"header": {"requestId": "C00000000261","requestTimestamp": null,"requestType": "NOTIF_ES","fields": ['+
				'{"fieldType": "TEXT","name": "PROCESS_CATEGORY","value": "'+processCategory+'"}]},"objects": [{"fields": ['+
				'{"fieldType": "TEXT","name": "COD_PRAT_UTENTE","value": "Z00000000097"},'+
				'{"fieldType": "TEXT","name": "COD_FLUSSO","value": "0150"},'+
				'{"fieldType": "TEXT","name": "RECORD_ID","value": "'+recordId+'"},'+
				'{"fieldType": "TEXT","name": "TESTO_ERRR","value": ""},'+
				'{"fieldType": "TEXT","name": "FASE","value": "'+phase+'"},'+
				'{"fieldType": "TEXT","name": "METHOD","value": "'+method+'"},'+
				'{"fieldType": "TEXT","name": "VERTRAG","value": "3010147771"},'+
				'{"fieldType": "TEXT","name": "VERTRAG_ST","value": "Cessato"},'+
				'{"fieldType": "TEXT","name": "SERVICEID_DIS","value": "10D00000AU"},'+
				'{"fieldType": "TEXT","name": "UTENZA","value": "BS_030_001"},'+
				'{"fieldType": "TEXT","name": "DATA_EVENTO","value": "2021-07-28 10:11:45"}'+
				'],"id": null,"name": null,"objectType": null,"objects": null}]}]}';
	}

	public static String richPassReq(String spCode, String bpCode, String caCode, String contractCode, String subtypeSiebel, String processType, String cluster, String origin, String effectiveDate, String salesforceKey, String herokuCode){
		return '{"header":null,"requests":[{"header":{"requestId":null,"requestTimestamp":null,"requestType":"RICH_PASS","fields":['+
				'{"fieldType":"TEXT","name":"PROCESS_CATEGORY","value":"postsales"}]},"objects":[{"fields":['+
				'{"fieldType":"TEXT","name":"CODICE_PRESA", "value":"'+spCode+'"},'+
				'{"fieldType":"TEXT","name":"CODICE_CLIENTE", "value":"'+bpCode+'"},'+
				'{"fieldType":"TEXT","name":"CONTO_CONTRATTUALE", "value":"'+caCode+'"},'+
				'{"fieldType":"TEXT","name":"CODICE_CONTRATTO", "value":"'+contractCode+'"},'+
				'{"fieldType":"TEXT","name":"TIPO_SIEBEL", "value":"Credito"},'+
				'{"fieldType":"TEXT","name":"SOTTOTIPO_SIEBEL", "value":"'+subtypeSiebel+'"},'+
				'{"fieldType":"TEXT","name":"COD_FISCALE", "value":"RSSSLD50D25G453V"},'+
				'{"fieldType":"TEXT","name":"RECAPITO", "value":"3401540441"},'+
				'{"fieldType":"TEXT","name":"PROCESS_TYPE", "value":"'+processType+'"},'+
				'{"fieldType":"TEXT", "name":"UFFICIO_COMPETENTE","value":"HCM"},'+
				'{"fieldType":"TEXT", "name":"CLUSTER","value":"'+cluster+'"},'+
				'{"fieldType":"TEXT", "name":"CANALE","value":"'+origin+'"},'+
				'{"fieldType":"TEXT", "name":"DATA_DECORRENZA","value":"'+effectiveDate+'"},'+
				'{"fieldType":"TEXT", "name":"SALESFORCE_KEY","value":"'+salesforceKey+'"},'+
				'{"fieldType":"TEXT", "name":"COD_PRAT_UTENTE","value":"'+herokuCode+'"}'+
				'],"id":null,"name":null,"objectType":null,"objects":null}]}]}';
	}

	public static List<SBQQ__QuoteLine__c> createQuoteLines(String productId, String quoteId, Integer amount, Boolean doInsert){

		List<SBQQ__QuoteLine__c> quoteLines=new List<SBQQ__QuoteLine__c>();

		for (Integer i=0; i<amount; i++){
			quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quoteId, SBQQ__Product__c=productId));
		}

		if (doInsert){
			insert quoteLines;
		}

		return quoteLines;
	}

	public static List<wrts_prcgvr__Activity__c> createActivityCustom(Integer amount, Boolean doInsert, Id accId){

		List<wrts_prcgvr__Activity__c> activityCustomList=new List<wrts_prcgvr__Activity__c>();

		for (Integer i=0; i<amount; i++){

			wrts_prcgvr__Activity__c actCustom=new wrts_prcgvr__Activity__c();

			actCustom.Account__c=accId;

			activityCustomList.add(actCustom);
		}

		if (doInsert){

			insert activityCustomList;
		}

		return activityCustomList;
	}

	/*public static HDT_DataEnrichmentTransocode__mdt     createTranscodeConfig(String name, Boolean isNumber, Integer precision, Boolean isTranscode,
	 String method, String sapField, String sfdcField){
	 HDT_DataEnrichmentTransocode__mdt transcodeConfig = new HDT_DataEnrichmentTransocode__mdt();
	 transcodeConfig.DeveloperName = name;
	 transcodeConfig.Label = name;
	 transcodeConfig.IsNumber__c = isNumber;
	 transcodeConfig.Precision__c = precision;
	 transcodeConfig.IsTranscode__c = isTranscode;
	 transcodeConfig.Method__c = method;
	 transcodeConfig.SapField__c = sapField;
	 transcodeConfig.SfdcField__c = sfdcField;

	 return transcodeConfig;
	 }

	 public static void insertTranscodeConfigs(List<HDT_DataEnrichmentTransocode__mdt> transcodeConfigs){
	 insert transcodeConfigs;
	 }

	 public static void createCausalCodeConfig(String name, String causalCode, String operationCode, String cluster, String commodity,
	 String process, String subprocess){
	 HDT_CausalCodeCalculation__mdt causalCodeConfig = new HDT_CausalCodeCalculation__mdt();
	 causalCodeConfig.DeveloperName = name;
	 causalCodeConfig.Label = name;
	 causalCodeConfig.CausalCode__c = causalCode;
	 causalCodeConfig.OperationCode__c = operationCode;
	 causalCodeConfig.Cluster__c = cluster;
	 causalCodeConfig.Process__c = process;
	 causalCodeConfig.Commodity__c = commodity;
	 causalCodeConfig.Subprocess__c = subprocess;

	 insert causalCodeConfig;
	 }*/
	 
	public static List<AccountShare> createAccountShare(Integer Amount, Boolean doInsert, Id AccountId, Id UserOrGroupId){


		List<AccountShare> accShareList=new List<AccountShare>();


		for (Integer i=0; i<amount; i++){


			AccountShare accShare=new AccountShare();


			accShare.AccountId=AccountId;

			accShare.UserOrGroupId=UserOrGroupId;

			accShare.AccountAccessLevel='Edit';

			accShare.OpportunityAccessLevel='Edit';

			accShare.ContactAccessLevel='Edit';


			accShareList.add(accShare);

		}


		if (doInsert){


			insert accShareList;

		}


		return accShareList;
	}

	public static List<DocumentSelected__c> createDocumentSelected(Integer amount,Boolean doInsert, Boolean credit, String caseId, String ca){

		List<DocumentSelected__c> documents = new List<DocumentSelected__c>();
		Integer fixedAmount = credit ? -15 : 15;
		for(Integer i = 0; i < amount; ++i){
			DocumentSelected__c documentObj = new DocumentSelected__c();
			documentObj.Name = '000041170936496' + i;
			documentObj.Case__c = caseId;
			documentObj.Amount__c = fixedAmount * (i + 1);
			documentObj.Bill__c = '420174500378587' + i;
			documentObj.ContractualAccount__c = ca;
			documentObj.DocumentNumber__c = '000041170936496' + i;
			documentObj.ExpirationDate__c = Date.newInstance(2019, 12, 24);
			documentObj.Extension__c = 'SI';
			documentObj.IssueDate__c = Date.newInstance(2019, 12, 04);
			documentObj.IssuingCompany__c = 'IssuingCompany__c';
			documentObj.PaymentMode__c = 'BOLLETTINO';
			documentObj.DocumentResidue__c =  fixedAmount * (i + 1);
			documentObj.TvFeeResidual__c = 12;
			documentObj.PaymentChannel__c = 'Posta';
			documentObj.Position1__c = '000';
			documentObj.Position2__c = '0001';
			documentObj.Position3__c = '000';
			documents.add(documentObj);
		}
		if(doInsert){
			insert documents;
		}
		return documents;
	}
	public static List<DocumentalActivity__c> createDocumentalActivity(Integer numberRecords, Id orderId, Id caseId){
		List<DocumentalActivity__c> docActList = new List<DocumentalActivity__c>();
		for(Integer i=0; i<numberRecords;i++){
			DocumentalActivity__c docAct = new DocumentalActivity__c();
			docAct.OrderId__c = String.isNotBlank(orderId)?orderId:null;
			docAct.CaseId__c = String.isNotBlank(caseId)?caseId:null;
			docAct.EnvelopeId__c = 'idPlico_' + i;
			docAct.AttachmentCode__c = 'codiceAllegato_'+i;
			docAct.PostelTimestamp__c = '2000000000';
			docActList.add(docAct);
		}
		insert docActList;
		return docActList;
	}

	public static List<AtecoMatrix__c> createAtecoMatrix(Integer amount, Boolean doInsert, String name){

		List<AtecoMatrix__c> atecoMatrixList=new List<AtecoMatrix__c>();

		for (Integer i=0; i<amount; i++){

			AtecoMatrix__c testAtecoMatrix=new AtecoMatrix__c();
			testAtecoMatrix.Name=name+i;

			atecoMatrixList.add(testAtecoMatrix);
		}

		if (doInsert){

			insert atecoMatrixList;
		}

		return atecoMatrixList;
	}

	public static List<FUBProcessing__c> createfubProcessing (Integer amount, Boolean doInsert, String status) {

		List<FUBProcessing__c> fubProcessingList = new List<FUBProcessing__c>();

		for (Integer i=0; i<amount; i++){

			FUBProcessing__c fubProcessing = new FUBProcessing__c(
				Status__c = status
			);		

			fubProcessingList.add(fubProcessing);
		}

		if (doInsert){

			insert fubProcessingList;
		}

		return fubProcessingList;
	}

	public static List<FUBProcessingItem__c> createFubProcessingItem (Integer amount, Boolean doInsert, Id campaignId, Id FubProcessingId) {

		List<FUBProcessingItem__c> fubProcessingItemList = new List<FUBProcessingItem__c>();

		for (Integer i=0; i<amount; i++){

			FUBProcessingItem__c fubProcessingItem = new FUBProcessingItem__c(
				Campaign__c = campaignId,
            	FUBProcessing__c = FubProcessingId
			);

			fubProcessingItemList.add(fubProcessingItem);
		}

		if (doInsert){

			insert fubProcessingItemList;
		}

		return fubProcessingItemList;
	}

	public static List<Individual> createIndividual (Integer amount, Boolean doInsert) {

		List<Individual> indList = new List<Individual>();

		for (Integer i=0; i<amount; i++){

			Individual ind = new Individual(
				FirstName = 'Mama',
				LastName = 'Guzzo'
        	);

			indList.add(ind);
		}

		if (doInsert){

			insert indList;
		}

		return indList;
	}

	public static List<ContactPointPhone> createContactPointPhone (Integer amount, Boolean doInsert, Id individualId) {

		List<ContactPointPhone> cppList = new List<ContactPointPhone>();

		for (Integer i=0; i<amount; i++){

			ContactPointPhone cpp = new ContactPointPhone(
            ParentId = individualId,
            TelephoneNumber = '982591380'
        );

			cppList.add(cpp);
		}

		if (doInsert){

			insert cppList;
		}

		return cppList;
	}

	public static List<ContactPointEmail> createContactPointEmail (Integer amount, Boolean doInsert, Id individualId) {

		List<ContactPointEmail> cpeList = new List<ContactPointEmail>();

		for (Integer i=0; i<amount; i++){

			ContactPointEmail cpe = new ContactPointEmail(
            ParentId = individualId,
            EmailAddress = 'sales@force.com'
        );

			cpeList.add(cpe);
		}

		if (doInsert){

			insert cpeList;
		}

		return cpeList;
	}

	public static List<RentProcessRule__c> createRentProcessRule (Integer amount, Boolean doInsert, boolean applicationInterests, boolean deposit)
	{
		List<RentProcessRule__c> rules = new List<RentProcessRule__c>();
		for(Integer i=0; i < amount; ++i)
		{
			RentProcessRule__c rule = new RentProcessRule__c();
			rule.AmountToPayInInstallmentsFrom__c 		= 0.01;
			rule.AmountToPayInInstallmentsTo__c			= 2000;
			rule.ApplicationInterests__c				= applicationInterests;    //input
			rule.ApprovalProcess__c						= false;
			rule.AttachmentManagement__c				= false;
			rule.CAWithOrWithoutSEPA__c					= false;
			rule.Deposit__c								= deposit; //input
			rule.ExistingInstallmentPlanUnpaidFrom__c 	= 0;
			rule.ExistingInstallmentPlanUnpaidTo__c		= 3;
			rule.InstallmentPlanReason__c				= 'Fattura SD'; 
			rule.MaxInstallmentsNumber__c				= 6;
			rule.Category__c							= 'Famiglie';
			rules.add(rule);	
		}
		if(doInsert)
		{
			insert rules;
		}
		return rules;
	}
	public static List<SBQQ__QuoteProcess__c> createQuoteProcess(Integer amount, Boolean doInsert) {

		List<SBQQ__QuoteProcess__c> qProcessList = new List<SBQQ__QuoteProcess__c>();

		for (Integer i=0; i<amount; i++){

			SBQQ__QuoteProcess__c qp = new SBQQ__QuoteProcess__c(
            	Name = 'testQuoteProcess'+i,
				SBQQ__Default__c = true,
				SBQQ__GuidedOnly__c = true,
				SBQQ__ProductAutoSelected__c = true,
				SBQQ__ProductConfigurationInitializer__c = 'initializerTest',
				SBQQ__ProductSearchExecutor__c = 'Executor',
				SBQQ__SortOrder__c = 1
        	);

			qProcessList.add(qp);
		}

		if (doInsert){

			insert qProcessList;
		}

		return qProcessList;
	}

	public static List<PaperProcessing__c> createPaperProcessing(Integer amount, Boolean doInsert, String name, String campaignId) {

		List<PaperProcessing__c> paperProcessings = new List<PaperProcessing__c>();

		for (Integer i = 0; i < amount; i++) {
			paperProcessings.add(
				new PaperProcessing__c(Name = name, Campaign__c = campaignId)
			);
		}

		if (doInsert) {
			insert paperProcessings;
		}

		return paperProcessings;

	}

	public static String getUserRoleId (String userRoleDeveloperName){
		String userRoleId='';

		if (!String.isEmpty(userRoleDeveloperName)){

			userRoleId=[SELECT Id
			FROM UserRole
			WHERE DeveloperName = :userRoleDeveloperName
			LIMIT 1].Id;

		}

		return userRoleId;
	}


	/**
	 * @author Valere 
	 * @date 14/09/2021
	 * @description create commercial code record 
	 */
    public static List<CommercialCode__c> createCommercialCode(Integer amount, Boolean doInsert){

		List<CommercialCode__c> commercialCode=new List<CommercialCode__c>();

		for (Integer i=0; i<amount; i++){

			CommercialCode__c cp=new CommercialCode__c(Name='Test CommercialCode');

			commercialCode.add(cp);
		}

		if (doInsert){

			insert commercialCode;
		}

		return commercialCode;
	}

	/**
     * @author Valere (valere@noeli-it.net)
     * @date 13/09/2021
     * @description createCity Method
     * @history valere - 15/09/2021– Created method
     */
    public static List<City__c> createCity(Integer amount, Boolean doInsert,Boolean serviceEle,String sdv){
		List<City__c> cityList=new List<City__c>();

		for (Integer i=0; i<amount; i++){

			City__c ct=new City__c();

			ct.Name='Roma';
			ct.BelfioreCode__c='Bt'+i;
            ct.ServiceEle__c=serviceEle;
            ct.SDV__c=sdv;

			cityList.add(ct);

		}

		if (doInsert){

			insert cityList;
		}

		return cityList;
	}

     /**
     * @author Valere (valere@noeli-it.net)
     * @date 13/09/2021
     * @description createAccountBusiness Method
     * @history valere - 15/09/2021– Created method
     */
    public static List<Account> createAccountBusiness(Integer amount, Boolean doInsert, Map<String,String> params){

		List<Account> accList=new List<Account>();
		Id rt=utlConstants.ACCOUNT_RECORDTYPEID_BUSINESS;

		for (Integer i=0; i<amount; i++){
			Decimal numCustomerCode = Decimal.valueOf(params.get('numCustomerCode')+i);
			Decimal result = numCustomerCode + i;
			String stringResult = String.valueOf(result);
			Account acc=new Account();

			acc.RecordTypeId=rt;
			acc.Name=params.get('nameStart')+i;
			acc.CompanyOwner__c=params.get('companyOwner');
			acc.CustomerMarking__c=params.get('customerMarking');
			acc.Category__C=params.get('category');
			acc.code__c=params.get('code');
			acc.CustomerCode__c=params.get('customerCode');
			acc.VATNumber__c=params.get('vatNumber');
			acc.BillingCityCode__c='Roma';
			acc.BillingStreetName__c='via roma';
			acc.BillingStreetNumber__c='55';
			acc.LastName__c=params.get('nameStart')+i;
			acc.FiscalCode__c='SXSRLA45H28H501K';
			acc.BillingIsAddressVerified__c=true;
        	acc.IsWrongFiscalData__c = false;
        	acc.BillingIsAddressVerified__c = true;
			acc.CustomerCode__c = stringResult;

			accList.add(acc);

		}

		if (doInsert){

			insert accList;
		}

		return accList;
	}

     /**
     * @author Valere (valere@noeli-it.net)
     * @date 13/09/2021
     * @description createServicePoint Method
     * @history valere - 15/09/2021– Created method
     */
    public static List<ServicePoint__c> createServicePoint(Integer amount, Boolean doInsert,String supplyCity,String distributor){

		List<ServicePoint__c> servPointList=HDT_UTL_DataFactoryTst.createServicePoint(1, false);
		for(ServicePoint__c sp:servPointList){
			sp.SupplyProvince__c='AQ';
			sp.GlobalMigrationKey__c='1123255';
			sp.SupplyCity__c=supplyCity;
			sp.CommoditySector__c='Energia Elettrica';
			sp.Distributor__c=distributor;
		}

		if (doInsert){

			insert servPointList;
		}

		return servPointList;
	}
	

	public static List<CS_SelezioneFornitura__c> createSelezioneFornitura(Integer amount, Boolean doInsert) {

		List<CS_SelezioneFornitura__c> selezioneList = new List<CS_SelezioneFornitura__c>();

		for (Integer i=0; i<amount; i++){

			CS_SelezioneFornitura__c selezione = new CS_SelezioneFornitura__c(
				Name = 'selezioneTestName'
			);

			selezioneList.add(selezione);
		}

		if (doInsert){

			insert selezioneList;
		}

		return selezioneList;
	}

	public static List<CommercialCode__c> createCommCode(Integer amount, Boolean doInsert) {

		List<CommercialCode__c> commCodeList = new List<CommercialCode__c>();

		for (Integer i=0; i<amount; i++){

			CommercialCode__c commCode = new CommercialCode__c(
				Name = 'testCommCode'
			);

			commCodeList.add(commCode);
		}

		if (doInsert){

			insert commCodeList;
		}

		return commCodeList;
	}

	public static List<MatriceRemiCode__c> createMatriceRemiCode(Integer amount, Boolean doInsert){

		List<MatriceRemiCode__c> matriceRemiCode=new List<MatriceRemiCode__c>();

		for (Integer i=0; i<amount; i++){

			MatriceRemiCode__c mRemiCode=new MatriceRemiCode__c();

			mRemiCode.RemiCode__c='test';

			matriceRemiCode.add(mRemiCode);

		}

		if (doInsert){

			insert matriceRemiCode;
		}

		return matriceRemiCode;
	}

	public static List<ServiceRequest__c> createServiceRequest(Integer amount, Boolean doInsert) {

		List<ServiceRequest__c> srList = new List<ServiceRequest__c>();

		for (Integer i=0; i<amount; i++){

			ServiceRequest__c sr = new ServiceRequest__c(
				ProcessType__c = 'Alert'
			);

			srList.add(sr);
		}

		if (doInsert){

			insert srList;
		}

		return srList;
	}
	
	public static List<SurveyResponse__c> createSurveyResponse(Integer amount, Boolean doInsert) {

		List<SurveyResponse__c> srList = new List<SurveyResponse__c>();

		for (Integer i=0; i<amount; i++){

			SurveyResponse__c sr = new SurveyResponse__c(
				Name = 'testName'
			);

			srList.add(sr);
		}

		if (doInsert){

			insert srList;
		}

		return srList;
	}

	public static List<RateCategory__c> createRateCategoty(Integer amount, Boolean doInsert) {

		List<RateCategory__c> rateCatList = new List<RateCategory__c>();

		for (Integer i=0; i<amount; i++){

			RateCategory__c rateCat = new RateCategory__c(
				Commodity__c='testCommodity',
				Name='testName',
				CalculatedValue__c='123',
				ProductName__c='testProduct',
				Fornitura__c='testFornitura',
				DistributorCode__c='testDistCode'
			);

		rateCatList.add(rateCat);
		}

		if (doInsert){

			insert rateCatList;
		}
	return rateCatList;
	}

	public static List<SurveyCRM__c> createSurveyCrm (Integer amount, Boolean doInsert) {

		List<SurveyCRM__c> surveyCrmList = new List<SurveyCRM__c>();

		for (Integer i=0; i<amount; i++){

			SurveyCRM__c surveyCrm = new SurveyCRM__c(
				Name = 'testName'
			);

			surveyCrmList.add(surveyCrm);
		}

		if (doInsert){

			insert surveyCrmList;
		}

		return surveyCrmList;
	}

	public static List<VisitAssignmentRules__c> createVisitAssignmentRules (Integer amount, Boolean doInsert) {

		List<VisitAssignmentRules__c> visitAssigRulesList = new List<VisitAssignmentRules__c>();

		for (Integer i=0; i<amount; i++){

			VisitAssignmentRules__c visitAssigRule = new VisitAssignmentRules__c(
				Name = 'testName'
			);

			visitAssigRulesList.add(visitAssigRule);
		}

		if (doInsert){

			insert visitAssigRulesList;
		}

		return visitAssigRulesList;
	}

	public static List<MassiveLoaderRequest__c> createMassiveLoaderRequest (Integer amount, Boolean doInsert){

		List<MassiveLoaderRequest__c> massiveLoaderRequestList = new List<MassiveLoaderRequest__c>();

		for(Integer i=0; i<amount; i++){

			MassiveLoaderRequest__c massiveLoaderRequest = new MassiveLoaderRequest__c();

			massiveLoaderRequest.ProcessType__c = 'SwitchIn';
			massiveLoaderRequest.Status__c = 'In Lavorazione';
			massiveLoaderRequest.TotalRequest__c = 2;
			massiveLoaderRequest.Phase__c = 'File in elaborazione';
			massiveLoaderRequest.Priority__c = 1;


			massiveLoaderRequestList.add(massiveLoaderRequest);
		}

		if (doInsert){

			insert massiveLoaderRequestList;
		}

		return massiveLoaderRequestList;

	}

	public static List<BlackList__c> createBlacklist (Integer amount, Boolean doInsert) {

		List<BlackList__c> blacklistList = new List<BlackList__c>();

		for (Integer i=0; i<amount; i++){

			BlackList__c blacklist = new BlackList__c(
				Name='testBlacklist',
				Domain__c='testDomain',
				Pod__c='testPOD'
			);

			blacklistList.add(blacklist);
		}

		if (doInsert){

			insert blacklistList;
		}

		return blacklistList;
	}

	public static List<ComfortQualityCall__c> createComfortQualityCall (Integer amount, Boolean doInsert) {

		List<ComfortQualityCall__c> comfQualityCallList = new List<ComfortQualityCall__c>();

		for (Integer i=0; i<amount; i++){

			ComfortQualityCall__c comQualityCall = new ComfortQualityCall__c(
				ComfortDocSendingChannel__c='Posta Cartacea'
			);

			comfQualityCallList.add(comQualityCall);
		}

		if (doInsert){

			insert comfQualityCallList;
		}

		return comfQualityCallList;
	}

}
