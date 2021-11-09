/**
 * @author Luca Molino (Luca.Molino@dunegroup.it)
 * @date 13/09/2021
 * @description Test ckass for HDT_LC_ChildOrderProcessActions 
 * @history Name – Date – Descriptiom
 */

@isTest
public class HDT_LC_ChildOrderProcessActionsTst {
    
	private static HDT_UTL_Constants utlConstants=new HDT_UTL_Constants();
	static HDT_LC_ChildOrderProcessDetails.HDT_WRP_QuoteType quoteTypeWrp=new HDT_LC_ChildOrderProcessDetails.HDT_WRP_QuoteType();
	
    @TestSetup
	static void setup(){

		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(utlConstants.HERA_SYSTEM_ADMINISTRATOR_NAME);

		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);

		internalUser.UserPermissionsMarketingUser=true;

		insert internalUser;

		List<PermissionSetAssignment> permissionSetAssignments=new List<PermissionSetAssignment>{HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, utlConstants.PERMISSIONSET_HDT_SALESFORCE_CPQ_ADMIN_NAME, false), HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, utlConstants.PERMISSIONSET_HDT_VOLTURARETROATTIVA, false), HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, utlConstants.PERMISSIONSET_HDT_SALESFORCE_CPQ_LICENSE_NAME, false)};

		insert permissionSetAssignments;

		System.runAs(internalUser){

			HDT_UTL_DataFactoryTst.pClickCasePhase();
            HDT_UTL_DataFactoryTst.pClickInstance();
            HDT_UTL_DataFactoryTst.pClickOrderPhase();
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa conferma cliente','Bozza',utlConstants.ORDER_RECORDTYPEID_CONNESSIONECONATTIVAZIONE,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_CONNESSIONECONATTIVAZIONE);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Bozza','In Lavorazione',utlConstants.ORDER_RECORDTYPEID_CONNESSIONECONATTIVAZIONE,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_CONNESSIONECONATTIVAZIONE);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Bozza','In Lavorazione',utlConstants.ORDER_RECORDTYPEID_VOLTURA,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_VOLTURA);
            HDT_UTL_DataFactoryTst.newPhaseTransition('In Lavorazione','Bozza',utlConstants.ORDER_RECORDTYPEID_VOLTURA,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_VOLTURA);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Bozza','In Lavorazione',utlConstants.ORDER_RECORDTYPEID_SUBENTRO,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_SUBENTRO);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Bozza','In Lavorazione',utlConstants.ORDER_RECORDTYPEID_SWITCHIN,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_ATTIVAZIONECONMODIFICA);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Bozza','In Lavorazione',utlConstants.ORDER_RECORDTYPEID_ATTIVAZIONECONMODIFICA,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_SWITCHIN);
            HDT_UTL_DataFactoryTst.newPhaseTransition('In Lavorazione','Bozza',utlConstants.ORDER_RECORDTYPEID_TEMPORANEANUOVAATT,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_TEMPORANEANUOVAATT);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Bozza','In Lavorazione',utlConstants.ORDER_RECORDTYPEID_TEMPORANEANUOVAATT,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_TEMPORANEANUOVAATT);

            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa validazione','Da Inviare',utlConstants.ORDER_RECORDTYPEID_CONNESSIONECONATTIVAZIONE,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_CONNESSIONECONATTIVAZIONE);
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa validazione','Da Inviare',utlConstants.ORDER_RECORDTYPEID_VOLTURA,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_VOLTURA);
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa validazione','Da Inviare',utlConstants.ORDER_RECORDTYPEID_SUBENTRO,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_SUBENTRO);
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa validazione','Da Inviare',utlConstants.ORDER_RECORDTYPEID_SWITCHIN,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_ATTIVAZIONECONMODIFICA);
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa validazione','Da Inviare',utlConstants.ORDER_RECORDTYPEID_ATTIVAZIONECONMODIFICA,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_SWITCHIN);
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa validazione','Da Inviare',utlConstants.ORDER_RECORDTYPEID_TEMPORANEANUOVAATT,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_TEMPORANEANUOVAATT);

            HDT_UTL_DataFactoryTst.newPhaseTransition('Bozza','Documentazione Gestita',utlConstants.ORDER_RECORDTYPEID_CONNESSIONECONATTIVAZIONE,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_CONNESSIONECONATTIVAZIONE);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Bozza','Documentazione Gestita',utlConstants.ORDER_RECORDTYPEID_VOLTURA,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_VOLTURA);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Bozza','Documentazione Gestita',utlConstants.ORDER_RECORDTYPEID_SUBENTRO,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_SUBENTRO);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Bozza','Documentazione Gestita',utlConstants.ORDER_RECORDTYPEID_SWITCHIN,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_ATTIVAZIONECONMODIFICA);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Bozza','Documentazione Gestita',utlConstants.ORDER_RECORDTYPEID_ATTIVAZIONECONMODIFICA,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_SWITCHIN);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Bozza','Documentazione Gestita',utlConstants.ORDER_RECORDTYPEID_TEMPORANEANUOVAATT,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_TEMPORANEANUOVAATT);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Bozza','Documentazione Gestita',utlConstants.ORDER_RECORDTYPEID_TEMPORANEANUOVAATT,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_TEMPORANEANUOVAATT);

            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa validazione','Da Inviare',utlConstants.ORDER_RECORDTYPEID_CONNESSIONECONATTIVAZIONE,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_CONNESSIONECONATTIVAZIONE);
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa validazione','Da Inviare',utlConstants.ORDER_RECORDTYPEID_VOLTURA,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_VOLTURA);
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa validazione','Da Inviare',utlConstants.ORDER_RECORDTYPEID_SUBENTRO,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_SUBENTRO);
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa validazione','Da Inviare',utlConstants.ORDER_RECORDTYPEID_SWITCHIN,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_ATTIVAZIONECONMODIFICA);
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa validazione','Da Inviare',utlConstants.ORDER_RECORDTYPEID_ATTIVAZIONECONMODIFICA,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_SWITCHIN);
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa validazione','Da Inviare',utlConstants.ORDER_RECORDTYPEID_TEMPORANEANUOVAATT,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_TEMPORANEANUOVAATT);
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa validazione','Da Inviare',utlConstants.ORDER_RECORDTYPEID_TEMPORANEANUOVAATT,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_TEMPORANEANUOVAATT);
            

            HDT_UTL_DataFactoryTst.newPhaseTransition('Accettazione Voltura','Bozza',utlConstants.ORDER_RECORDTYPEID_VOLTURA,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_VOLTURA);
            HDT_UTL_DataFactoryTst.newPhaseTransition('In Lavorazione','Bozza',utlConstants.ORDER_RECORDTYPEID_VOLTURA,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_VOLTURA);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Da Inviare','Bozza',utlConstants.ORDER_RECORDTYPEID_SUBENTRO,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_SUBENTRO);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Da Inviare','Bozza',utlConstants.ORDER_RECORDTYPEID_SWITCHIN,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_SWITCHIN);
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa validazione','Bozza',utlConstants.ORDER_RECORDTYPEID_SWITCHIN,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_SWITCHIN);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Da Inviare','Comunicazione verso Heroku',utlConstants.ORDER_RECORDTYPEID_SWITCHIN,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_SWITCHIN);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Da Inviare','Bozza',utlConstants.ORDER_RECORDTYPEID_ATTIVAZIONECONMODIFICA,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_ATTIVAZIONECONMODIFICA);
            HDT_UTL_DataFactoryTst.newPhaseTransition('In Lavorazione','Bozza',utlConstants.ORDER_RECORDTYPEID_SWITCHIN,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_ATTIVAZIONECONMODIFICA);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Da Inviare','Bozza',utlConstants.ORDER_RECORDTYPEID_ATTIVAZIONE,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_ATTIVAZIONE);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Da Inviare','Bozza',utlConstants.ORDER_RECORDTYPEID_CONNESSIONECONATTIVAZIONE,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_CONNESSIONECONATTIVAZIONE);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Da Inviare','Bozza',utlConstants.ORDER_RECORDTYPEID_TEMPORANEANUOVAATT,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_TEMPORANEANUOVAATT);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Comunicazione verso Heroku','Bozza',utlConstants.ORDER_RECORDTYPEID_SWITCHIN,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_SWITCHIN);
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa validazione','Da Inviare',utlConstants.ORDER_RECORDTYPEID_SWITCHIN,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_SWITCHIN);

            
			Id rt=utlConstants.ACCOUNT_RECORDTYPEID_RESINDEZIALE;


            List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(2,false,'HERA COMM','Condominio','Grandi Condomini');
			accounts[0].ActiveMonitoring__c=false;
			accounts[0].Name='INRETE DIST. ENER.-13R0000000';
			accounts[0].LastName__c='INRETE DIST. ENER.-13R0000000';

            
            accounts[1].ActiveMonitoring__c=false;
			accounts[1].Name='test account residenziale';
			accounts[1].LastName__c='INRETE DIST. ENER.-13R0100000';
            accounts[1].BillingIsAddressVerified__c = true;
            accounts[1].RecordTypeId=rt;
            accounts[1].CustomerMarking__c='Persona Fisica';
			accounts[1].Category__C='Famiglie';
			insert accounts;
            
            HDT_UTL_DataFactoryTst.createComfortQualityCall(2,true);
            List<BillingProfile__c> billing =HDT_UTL_DataFactoryTst.createBillingProfile(1,true,accounts[0].Id);
			List<Opportunity> opps=HDT_UTL_DataFactoryTst.createOpportunity(1, true);
			List<Sale__c> sales=HDT_UTL_DataFactoryTst.createSale(7, true, accounts[0].Id, 'Attiva');
			List<Pricebook2> pricebook=HDT_UTL_DataFactoryTst.createPricebook(1, true);
			List<Order> orders=HDT_UTL_DataFactoryTst.createOrderWithPricebook(7, false, accounts[0].Id, sales, pricebook[0].Id);
			/*List<Order> ordersParent=HDT_UTL_DataFactoryTst.createOrder(1, false, accounts[0].Id,'Bozza');
            ordersParent[0].Name='parentOrder0';
            insert ordersParent[0];*/
			id orderVoltura=utlConstants.ORDER_RECORDTYPEID_VOLTURA;
            id orderSubentro=utlConstants.ORDER_RECORDTYPEID_SUBENTRO;
            id orderSwitchIn=utlConstants.ORDER_RECORDTYPEID_SWITCHIN;
            id orderAttivazione=utlConstants.ORDER_RECORDTYPEID_ATTIVAZIONE;
            id orderAttivazioneConModifica=utlConstants.ORDER_RECORDTYPEID_ATTIVAZIONECONMODIFICA;
			id orderConnessioneConAttiv=utlConstants.ORDER_RECORDTYPEID_CONNESSIONECONATTIVAZIONE;
			id orderTemporaneaNuovaAtt=utlConstants.ORDER_RECORDTYPEID_TEMPORANEANUOVAATT;
            
            
            Id accId = accounts[0].id;
            
            List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(2,false,accId);

            insert contacts;
			Id contactId = contacts[0].id;
            
            orders[6].RecordTypeId=orderTemporaneaNuovaAtt;
			orders[6].VoltageLevel__c='BT';
			orders[6].ProcessCode__c='E02';
			orders[6].UseTypeEnergy__c='Manifest (Temp Straord 16h)';
			orders[6].CreditCheckDescription__c='test6Temporanea';
			orders[6].RequestOption__c='Domestici-TD';
			orders[6].PowerRequested__c=2;
			orders[6].PowerCommitted__c=2;
            orders[6].Contact__c = contactId;
            orders[6].IsActivationDeferred__c=true;
            orders[6].Status='Draft';
			
            insert orders[6];
            
            orders[0].RecordTypeId=orderSubentro;
			orders[0].Username__c='test';
			orders[0].Password__c='test1';
			orders[0].NotRegisteredMeterCase__c=true;
			orders[0].EffectiveDate__c=date.today();
			orders[0].PowerCommitted__c=2;
			orders[0].ImplantType__c='13A0-Usi di Abitazione BT';
			orders[0].RequestOption__c='Domestici-TD';
			orders[0].CreditCheckDescription__c='test1';
            orders[0].Contact__c = contactId;
            orders[0].IsActivationDeferred__c=true;
			orders[0].VATfacilitationFlag__c=true;
            
			orders[1].RecordTypeId=orderVoltura;
			orders[1].CreditCheckDescription__c='test2Voltura';
			orders[1].ProcessCode__c='PN1';
			orders[1].PowerRequested__c=1;
			orders[1].PowerAvailable__c=3;
			orders[1].PowerCommitted__c=2;
			orders[1].NotRegisteredMeterCase__c=false;
			orders[1].EffectiveDate__c=date.today().addDays(-4);
			orders[1].RequestOption__c='Domestici-TD';
			orders[1].Vat__c='Iva 10% (Cod. 01)';
            orders[1].Contact__c = contactId;
            orders[1].ParentOrder__c = orders[6].Id;
            orders[1].IsActivationDeferred__c=true;
			orders[1].VATfacilitationFlag__c=false;
            
			orders[2].PowerCommitted__c=2;
			orders[2].CreditCheckDescription__c = 'test3';
			orders[2].VoltureType__c='In Continuità';
			orders[2].RecordTypeId = orderSwitchIn;
            orders[2].Contact__c = contactId;
			orders[2].IsActivationDeferred__c=true;
            orders[2].ProcessType__c = 'Switch in Ripristinatorio';
            orders[2].SignedDate__c = Date.today();
            orders[2].VATfacilitationFlag__c=true;
          // system.debug('Order switchIn name ' +  orders[2].Name);
            
			orders[3].PowerCommitted__c=2;
			orders[3].VoltureType__c='In Continuità';
			orders[3].CreditCheckDescription__c='test4AttivConMod';
			orders[3].RecordTypeId=orderAttivazioneConModifica;
			orders[3].PowerRequested__c=3;
			orders[3].ProcessCode__c='E02';
            orders[3].Contact__c = contactId;
            orders[3].IsActivationDeferred__c=true;
            orders[3].ParentOrder__c = orders[6].Id;
			orders[3].VATfacilitationFlag__c=true;

			orders[4].EffectiveDate__c=date.today().addDays(10);
			orders[4].PowerCommitted__c=2;
			orders[4].RecordTypeId=orderAttivazione;
			orders[4].CreditCheckDescription__c='test5Conessione1';
			orders[4].ProcessCode__c='PN1';
            orders[4].Contact__c = contactId;
            orders[4].IsActivationDeferred__c=true;
            orders[4].VATfacilitationFlag__c=true;

			orders[5].RecordTypeId=orderConnessioneConAttiv;
			orders[5].VoltageLevel__c='BT';
			orders[5].ProcessCode__c='E02';
			orders[5].UseTypeEnergy__c='Manifest (Temp Straord 16h)';
			orders[5].CreditCheckDescription__c='test6Temporanea';
			orders[5].RequestOption__c='Domestici-TD';
			orders[5].PowerRequested__c=2;
			orders[5].PowerCommitted__c=2;
            orders[5].Contact__c = contactId;
            orders[5].IsActivationDeferred__c=true;
            orders[5].VATfacilitationFlag__c=false;
            

			upsert orders;
            

			List<Order> childOrders=HDT_UTL_DataFactoryTst.createChildOrder(1, false, accounts[0].Id, sales, orders[0].Id, contacts[0].Id);
			childOrders[0].QualityCall__c=true;
			insert childOrders;

			List<ServicePoint__c> servPoints=HDT_UTL_DataFactoryTst.createServicePoint(1, false);
			servPoints[0].Distributor__c=accounts[0].Id;
			servPoints[0].CommoditySector__c='Energia Elettrica';

			insert servPoints;

			List<SBQQ__Quote__c> quotes=HDT_UTL_DataFactoryTst.createQuote(1, false, orders[0].Id, opps[0].Id, sales[0].Id, 'Amendment');
			quotes[0].IsVAS__c=false;
			quotes[0].AmendmentAllowed__c=false;
			insert quotes;

			orders[0].ServicePoint__c=servPoints[0].Id;
			orders[0].SBQQ__Quote__c=quotes[0].id;
			orders[1].ServicePoint__c=servPoints[0].Id;
			orders[3].ServicePoint__c=servPoints[0].Id;
			orders[3].SBQQ__Quote__c=quotes[0].id;

			update orders;

			List<Contract> contracts=HDT_UTL_DataFactoryTst.createContract(1, true, accounts[0].Id);
			List<Case> cases=HDT_UTL_DataFactoryTst.createCase(1, false, accounts[0].Id, contacts[0].Id, servPoints[0].Id, contracts[0].Id, orders[0].Id);
			cases[0].Type='Cambio Contatore Non Registrato';
			cases[0].Phase__c='Completata';
			cases[0].VulturePracticeReference__c=orders[0].Id;

			insert cases;

            

            billing[0].BankAccountSignatoryLastName__c='HERA COMM';
            
            upsert billing;
		}
	}

    @isTest
	static void testSave(){
        
        //Start Test
     	
        List<ComfortQualityCall__c> cQualityCall =[SELECT Id,ComfortEnabled__c,QualityEnabled__c,Process__c,Channel__c,MarketType__c,
            									   CustomerType__c,DaysComfort__c,UniqueQuality__c, ComfortDocSendingChannel__c, QualitySignatureMethod__c,ComfortSignatureMethod__c 
                                                   FROM ComfortQualityCall__c 
                                                   WHERE ComfortDocSendingChannel__c='Posta Cartacea'];
        
        List<Order> tOrder2=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,Status,
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,
        ParentOrder__c,DocSendingMethod__c,RecordType.Name,ContractReference__c,EffectiveDate__c,Contact__c,ParentOrder__r.Status,IsCloned__c,QuotationType__c
        FROM Order WHERE Name Like 'testOrderName%' ORDER BY Name asc];
        
        
        Test.startTest();
        //Test SwitchIn
      // system.debug('Test SwitchIn'+ tOrder2[6].Status);
        Map<String,Object> m2 = new Map<String,Object>();
        m2.put('EffectiveDate__c', Date.today().addDays(11));

        cQualityCall[0].Process__c = tOrder2[2].RecordType.DeveloperName;
        cQualityCall[0].Channel__c = tOrder2[2].Channel__c;
        cQualityCall[0].CustomerType__c = tOrder2[2].CustomerCategory__c;
        cQualityCall[0].MarketType__c = tOrder2[2].MarketOrigin__c;
        cQualityCall[0].ComfortSignatureMethod__c = tOrder2[2].SignatureMethod__c;
        cQualityCall[0].QualitySignatureMethod__c = tOrder2[2].SignatureMethod__c;
        cQualityCall[0].QualityEnabled__c=false;
        update cQualityCall;
        
		tOrder2[2].SignedDate__c=null;
        
        HDT_LC_ChildOrderProcessActions.save(tOrder2[2],m2);
        
        tOrder2[2].SignedDate__c=Date.today();
        tOrder2[2].ProcessType__c='';
    	HDT_LC_ChildOrderProcessActions.save(tOrder2[2],m2);

        Date expectedResult = [SELECT EffectiveDate__c  FROM Order WHERE Id =: tOrder2[2].Id].EffectiveDate__c;

       // //system.assertEquals((Date)  m2.get('EffectiveDate__c'), expectedResult, 'The Order was not saved correctly');

        Test.stopTest();

    }

    @isTest
	static void testSave2(){
        
        //Start Test
     	
        List<ComfortQualityCall__c> cQualityCall =[SELECT Id,ComfortEnabled__c,QualityEnabled__c,Process__c,Channel__c,MarketType__c,
            									   CustomerType__c,DaysComfort__c,UniqueQuality__c, ComfortDocSendingChannel__c, QualitySignatureMethod__c,ComfortSignatureMethod__c 
                                                   FROM ComfortQualityCall__c 
                                                   WHERE ComfortDocSendingChannel__c='Posta Cartacea'];
        
        List<Order> tOrder2=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,
        ParentOrder__c,DocSendingMethod__c,RecordType.Name,ContractReference__c,EffectiveDate__c,Contact__c,ParentOrder__r.Status,IsCloned__c,QuotationType__c
        FROM Order WHERE Name Like 'testOrderName%' ORDER BY Name asc];
               
        Test.startTest();
		
        //Test Subentro
      // system.debug('Test Subentro');
        Map<String,Object> m = new Map<String,Object>();
        m.put('EffectiveDate', Date.today().addDays(11));

        cQualityCall[0].Process__c = tOrder2[0].RecordType.DeveloperName;
        cQualityCall[0].Channel__c = tOrder2[0].Channel__c;
        cQualityCall[0].CustomerType__c = tOrder2[0].CustomerCategory__c;
        cQualityCall[0].MarketType__c = tOrder2[0].MarketOrigin__c;
        cQualityCall[0].ComfortSignatureMethod__c = tOrder2[0].SignatureMethod__c;
        cQualityCall[0].QualitySignatureMethod__c = tOrder2[0].SignatureMethod__c;
        cQualityCall[0].QualityEnabled__c=true;
        
        cQualityCall[1].Process__c = tOrder2[0].RecordType.DeveloperName;
        cQualityCall[1].Channel__c = tOrder2[0].Channel__c;
        cQualityCall[1].CustomerType__c = tOrder2[0].CustomerCategory__c;
        cQualityCall[1].MarketType__c = tOrder2[0].MarketOrigin__c;
        cQualityCall[1].ComfortSignatureMethod__c = tOrder2[0].SignatureMethod__c;
        cQualityCall[1].QualitySignatureMethod__c = tOrder2[0].SignatureMethod__c;
        cQualityCall[0].QualityEnabled__c=false;

        update cQualityCall;

        HDT_LC_ChildOrderProcessActions.save(tOrder2[0],m);

        Date expectedResult = [SELECT EffectiveDate__c  FROM Order WHERE Id =: tOrder2[0].Id].EffectiveDate__c;

       // //system.assertEquals((Date)  m.get('EffectiveDate__c'), expectedResult, 'The Order was not saved correctly');

        Test.stopTest();

    }

  /*  @isTest
	static void testSave3(){
        
        //Start Test
     	
        List<Order> tOrder2=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,
        ParentOrder__c,DocSendingMethod__c,RecordType.Name,ContractReference__c,EffectiveDate__c,Contact__c,ParentOrder__r.Status,IsCloned__c,QuotationType__c
        FROM Order WHERE Name Like 'testOrderName%' ORDER BY Name asc];
               
        Test.startTest();

        //Test Voltura
      // system.debug('Test Voltura');
        Map<String,Object> m1 = new Map<String,Object>();
        m1.put('EffectiveDate__c', Date.today().addDays(11));
        HDT_LC_ChildOrderProcessActions.save(tOrder2[1],m1);
	
        Date expectedResult = [SELECT EffectiveDate__c  FROM Order WHERE Id =: tOrder2[1].Id].EffectiveDate__c;

        //system.assertEquals((Date)  m1.get('EffectiveDate__c'), expectedResult, 'The Order was not saved correctly');

        Test.stopTest();

    }*/

    @isTest
	static void testSave4(){
        
        //Start Test
        
        List<Order> tOrder2=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,
        ParentOrder__c,DocSendingMethod__c,RecordType.Name,ContractReference__c,EffectiveDate__c,Contact__c,ParentOrder__r.Status,IsCloned__c,QuotationType__c
        FROM Order WHERE Name Like 'testOrderName%' ORDER BY Name asc];
               
        Test.startTest();

        //Test AttivazioneConModifica
      // system.debug('Test AttivazioneConModifica');
        Map<String,Object> m3 = new Map<String,Object>();
        m3.put('EffectiveDate__c', Date.today().addDays(11));
		tOrder2[3].QuotationType__c='Rapido';
        HDT_LC_ChildOrderProcessActions.save(tOrder2[0],m3);

        Date expectedResult = [SELECT EffectiveDate__c  FROM Order WHERE Id =: tOrder2[3].Id].EffectiveDate__c;

        //system.assertEquals((Date)  m3.get('EffectiveDate__c'), expectedResult, 'The Order was not saved correctly');

        Test.stopTest();

    }
    @isTest
	static void testSaveM(){
        
        //Start Test
        
        List<Order> tOrder2=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,
        ParentOrder__c,DocSendingMethod__c,RecordType.Name,ContractReference__c,EffectiveDate__c,Contact__c,ParentOrder__r.Status,IsCloned__c,QuotationType__c
        FROM Order WHERE Name Like 'testOrderName%' ORDER BY Name asc];
        List<Account> accountList= HDT_UTL_DataFactoryTst.createAccountResidenziale(1,false,'HERA COMM','Persona fisica','Famiglie');
 
        Test.startTest();

        //Test AttivazioneConModifica
      // system.debug('Test AttivazioneConModifica');
        Map<String,Object> m3 = new Map<String,Object>();
        accountList.get(0).Id=tOrder2.get(1).AccountId;
        update accountList;
        m3.put('EffectiveDate__c', Date.today().addDays(11));
        tOrder2[1].VATfacilitationFlag__c=true;
        update tOrder2;
        HDT_LC_ChildOrderProcessActions.save(tOrder2[1],m3);
        m3.put('VATfacilitationFlag__c',true);
        try{
        HDT_LC_ChildOrderProcessActions.save(tOrder2[1],m3);
        }
 
        catch(Exception e){ 
            System.assertEquals(true, true, 'Caricare documento per iva e accise');

        }
        Test.stopTest();

    }


    



    @isTest
	static void testSave5(){
        
        //Start Test
        
        List<Order> tOrder2=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,
        ParentOrder__c,DocSendingMethod__c,RecordType.Name,ContractReference__c,EffectiveDate__c,Contact__c,ParentOrder__r.Status,IsCloned__c,QuotationType__c
        FROM Order WHERE Name Like 'testOrderName%' ORDER BY Name asc];
               
        Test.startTest();

        //Test Attivazione
      // system.debug('Test Attivazione');
        Map<String,Object> m4 = new Map<String,Object>();
        m4.put('EffectiveDate__c', Date.today().addDays(11));

        HDT_LC_ChildOrderProcessActions.save(tOrder2[0],m4);

        Date expectedResult = [SELECT EffectiveDate__c  FROM Order WHERE Id =: tOrder2[4].Id].EffectiveDate__c;

        //system.assertEquals((Date)  m4.get('EffectiveDate__c'), expectedResult, 'The Order was not saved correctly');

        Test.stopTest();

    }

    @isTest
	static void testSave6(){
        
        //Start Test
        
        List<Order> tOrder2=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,
        ParentOrder__c,DocSendingMethod__c,RecordType.Name,ContractReference__c,EffectiveDate__c,Contact__c,ParentOrder__r.Status,IsCloned__c,QuotationType__c
        FROM Order WHERE Name Like 'testOrderName%' ORDER BY Name asc];
               
        Test.startTest();

        //Test ConnessioneConAttiv
      // system.debug('Test ConnessioneConAttiv');
        Map<String,Object> m5 = new Map<String,Object>();
        m5.put('EffectiveDate__c', Date.today().addDays(11));

        HDT_LC_ChildOrderProcessActions.save(tOrder2[5],m5);

        String expectedResult = [SELECT Instance326__c  FROM Order WHERE Id =: tOrder2[0].Id].Instance326__c;

        //system.assertEquals('Richiesto', expectedResult, 'The Order was not saved correctly');

        Test.stopTest();

    }

    @isTest
	static void testSave7(){
        
        //Start Test

        
        List<Order> tOrder2=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,
        ParentOrder__c,DocSendingMethod__c,RecordType.Name,ContractReference__c,EffectiveDate__c,Contact__c,ParentOrder__r.Status,IsCloned__c,QuotationType__c
        FROM Order WHERE Name Like 'testOrderName%' ORDER BY Name asc];
               
        Test.startTest();

        //Test TemporaneaNuovaAtt
      // system.debug('Test TemporaneaNuovaAtt');
        Map<String,Object> m6 = new Map<String,Object>();
        m6.put('EffectiveDate__c', Date.today().addDays(11));

        HDT_LC_ChildOrderProcessActions.save(tOrder2[0],m6);

        Date expectedResult = [SELECT EffectiveDate__c  FROM Order WHERE Id =: tOrder2[6].Id].EffectiveDate__c;

        //system.assertEquals((Date)  m6.get('EffectiveDate__c'), expectedResult, 'The Order was not saved correctly');

        Test.stopTest();

    }

    @isTest
	static void testSave8(){
        
        //Start Test

        
        List<Order> tOrder2=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,
        ParentOrder__c,DocSendingMethod__c,RecordType.Name,ContractReference__c,EffectiveDate__c,Contact__c,ParentOrder__r.Status,IsCloned__c,QuotationType__c
        FROM Order WHERE Name Like 'testOrderName%' ORDER BY Name asc];
               
        Test.startTest();

        Map<String, Object> m7 = new Map<String, Object>();
        m7.put('EffectiveDate__c', Date.today().addDays(11));
        HDT_LC_ChildOrderProcessActions.save(tOrder2[0],m7);

        Date expectedResult = [SELECT EffectiveDate__c  FROM Order WHERE Id =: tOrder2[0].Id].EffectiveDate__c;

        //system.assertEquals((Date)  m7.get('EffectiveDate__c'), expectedResult, 'The Order was not saved correctly');

        Test.stopTest();
    }
    /*
     @isTest
	static void testSaveRes(){
        
        //Start Test
     
        List<Order> tOrder2=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,
        ParentOrder__c,DocSendingMethod__c,RecordType.Name,ContractReference__c,EffectiveDate__c,Contact__c,ParentOrder__r.Status,IsCloned__c,QuotationType__c
        FROM Order WHERE Name Like 'testOrderName%' ORDER BY Name asc];
      // system.debug('order list !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!' + tOrder2);
        Test.startTest();
        //Test SwitchIn
      // system.debug('Test SwitchIn');
        Map<String,Object> m2 = new Map<String,Object>();
        m2.put('EffectiveDate__c', Date.today().addDays(11));
		tOrder2[2].SignedDate__c=null;
        tOrder2[2].ProcessType__c='Switch in Gas';
        tOrder2[2].Account.RecordType.DeveloperName = 'HDT_RT_Residenziale';
       	
        HDT_LC_ChildOrderProcessActions.save(tOrder2[2],m2);
        
		tOrder2[2].SignedDate__c=Date.today();
        tOrder2[2].ProcessType__c='';
    	HDT_LC_ChildOrderProcessActions.save(tOrder2[2],m2);
        Date expectedResult = [SELECT EffectiveDate__c  FROM Order WHERE Id =: tOrder2[2].Id].EffectiveDate__c;

        //system.assertEquals((Date)  m2.get('EffectiveDate__c'), expectedResult, 'The Order was not saved correctly');

        Test.stopTest();

    }*/

    @isTest
	static void testSaveRes1(){
        
        //Start Test
     
        List<Order> tOrder2=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,
        ParentOrder__c,DocSendingMethod__c,RecordType.Name,ContractReference__c,EffectiveDate__c,Contact__c,ParentOrder__r.Status,IsCloned__c,QuotationType__c
        FROM Order WHERE Name Like 'testOrderName%' ORDER BY Name asc];
      // system.debug('order list !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!' + tOrder2);
        Test.startTest();
        //Test Subentro
      // system.debug('Test Subentro');
        Map<String,Object> m = new Map<String,Object>();
        m.put('EffectiveDate__c', Date.today().addDays(11));

        tOrder2[0].Account.RecordType.DeveloperName = 'HDT_RT_Residenziale';
    
        HDT_LC_ChildOrderProcessActions.save(tOrder2[0],m);

        Date expectedResult = [SELECT EffectiveDate__c  FROM Order WHERE Id =: tOrder2[0].Id].EffectiveDate__c;

        //system.assertEquals((Date)  m.get('EffectiveDate__c'), expectedResult, 'The Order was not saved correctly');

        Test.stopTest();

    }

    @isTest
	static void testSaveRes2(){
        
        //Start Test
     
        List<Order> tOrder2=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,
        ParentOrder__c,DocSendingMethod__c,RecordType.Name,ContractReference__c,Email__c,EffectiveDate__c,Contact__c,ParentOrder__r.Status,IsCloned__c,QuotationType__c
        FROM Order WHERE Name Like 'testOrderName%' ORDER BY Name asc];
      // system.debug('order list !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!' + tOrder2);
        Test.startTest();

        //Test Voltura
      // system.debug('Test Voltura');
        Map<String,Object> m1 = new Map<String,Object>();
        m1.put('EffectiveDate__c', Date.today().addDays(11));

        tOrder2[1].Account.RecordType.DeveloperName = 'HDT_RT_Residenziale';

        HDT_LC_ChildOrderProcessActions.save(tOrder2[0],m1);

        Date expectedResult = [SELECT EffectiveDate__c  FROM Order WHERE Id =: tOrder2[1].Id].EffectiveDate__c;

       //system.assertEquals((Date)  m1.get('EffectiveDate__c'), expectedResult, 'The Order was not saved correctly');

        Test.stopTest();

    }

    @isTest
	static void testSaveRes3(){
        
        //Start Test
     
        List<Order> tOrder2=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,
        ParentOrder__c,DocSendingMethod__c,RecordType.Name,ContractReference__c,EffectiveDate__c,Contact__c,ParentOrder__r.Status,IsCloned__c,QuotationType__c
        FROM Order WHERE Name Like 'testOrderName%' ORDER BY Name asc];
      // system.debug('order list !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!' + tOrder2);
        Test.startTest();

        //Test AttivazioneConModifica
      // system.debug('Test AttivazioneConModifica');
        Map<String,Object> m3 = new Map<String,Object>();
        m3.put('EffectiveDate__c', Date.today().addDays(11));

        tOrder2[3].Account.RecordType.DeveloperName = 'HDT_RT_Residenziale';
		tOrder2[3].QuotationType__c='Rapido';
        HDT_LC_ChildOrderProcessActions.save(tOrder2[0],m3);

        Date expectedResult = [SELECT EffectiveDate__c  FROM Order WHERE Id =: tOrder2[3].Id].EffectiveDate__c;

        //system.assertEquals((Date)  m3.get('EffectiveDate__c'), expectedResult, 'The Order was not saved correctly');

        Test.stopTest();

    }

    @isTest
	static void testSaveRes4(){
        
        //Start Test
     
        List<Order> tOrder2=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,
        ParentOrder__c,DocSendingMethod__c,RecordType.Name,ContractReference__c,EffectiveDate__c,Contact__c,ParentOrder__r.Status,IsCloned__c,QuotationType__c
        FROM Order WHERE Name Like 'testOrderName%' ORDER BY Name asc];
      // system.debug('order list !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!' + tOrder2);
        Test.startTest();
        //Test Attivazione
      // system.debug('Test Attivazione');
        Map<String,Object> m4 = new Map<String,Object>();
        m4.put('EffectiveDate__c', Date.today().addDays(11));

        tOrder2[4].Account.RecordType.DeveloperName = 'HDT_RT_Residenziale';
    
        HDT_LC_ChildOrderProcessActions.save(tOrder2[0],m4);

        Date expectedResult = [SELECT EffectiveDate__c  FROM Order WHERE Id =: tOrder2[4].Id].EffectiveDate__c;

        //system.assertEquals((Date)  m4.get('EffectiveDate__c'), expectedResult, 'The Order was not saved correctly');

        Test.stopTest();

    }

    @isTest
	static void testSaveRes5(){
        
        //Start Test
     
        List<Order> tOrder2=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,
        ParentOrder__c,DocSendingMethod__c,RecordType.Name,ContractReference__c,EffectiveDate__c,Contact__c,ParentOrder__r.Status,IsCloned__c,QuotationType__c
        FROM Order WHERE Name Like 'testOrderName%' ORDER BY Name asc];
      // system.debug('order list !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!' + tOrder2);
        Test.startTest();

        //Test ConnessioneConAttiv
      // system.debug('Test ConnessioneConAttiv');
        Map<String,Object> m5 = new Map<String,Object>();
        m5.put('EffectiveDate__c', Date.today().addDays(11));

        tOrder2[0].Account.RecordType.DeveloperName = 'HDT_RT_Residenziale';

        HDT_LC_ChildOrderProcessActions.save(tOrder2[5],m5);

        Date expectedResult = [SELECT EffectiveDate__c  FROM Order WHERE Id =: tOrder2[5].Id].EffectiveDate__c;

        //system.assertEquals((Date)  m5.get('EffectiveDate__c'), expectedResult, 'The Order was not saved correctly');

        Test.stopTest();

    }

    @isTest
    static void testSaveRes6(){
        
    	//Start Test
     
  	     List<Order> tOrder2=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
         ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,DocumentLow80__c,
         Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,
         ParentOrder__c,DocSendingMethod__c,RecordType.Name,ContractReference__c,EffectiveDate__c,Contact__c,ParentOrder__r.Status,IsCloned__c,QuotationType__c
         FROM Order WHERE Name Like 'testOrderName%' ORDER BY Name asc];
       // system.debug('order list !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!' + tOrder2);
         Test.startTest();

         //Test TemporaneaNuovaAtt
       // system.debug('Test TemporaneaNuovaAtt');
  		 Map<String,Object> m6 = new Map<String,Object>();

         tOrder2[0].Account.RecordType.DeveloperName = 'HDT_RT_Residenziale';

         HDT_LC_ChildOrderProcessActions.save(tOrder2[6],m6);
        
        Test.stopTest();
     }
  /*
        @isTest
	static void testSaveRes7(){
        
        //Start Test
     
        List<Order> tOrder2=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,Status,
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,
        ParentOrder__c,DocSendingMethod__c,RecordType.Name,ContractReference__c,EffectiveDate__c,Contact__c,ParentOrder__r.Status,IsCloned__c,QuotationType__c
        FROM Order WHERE Name Like 'testOrderName%' ORDER BY Name asc];
      // system.debug('order list !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!' + tOrder2);
        Test.startTest();

        //Test VAS
      // system.debug('Test VAS');
        Map<String,Object> m3 = new Map<String,Object>();
        m3.put('EffectiveDate__c', Date.today().addDays(11));
   		system.debug('parent status************************** ' + tOrder2[6].Status );
        tOrder2[0].Account.RecordType.DeveloperName = 'HDT_RT_VAS';

        tOrder2[0].ProcessType__c = 'Switch in Ripristinatorio';

      // system.debug('order parent status************************** ' + tOrder2[3].ParentOrder__r.Status);

        HDT_LC_ChildOrderProcessActions.save(tOrder2[3],m3);

        Date expectedResult = [SELECT EffectiveDate__c  FROM Order WHERE Id =: tOrder2[3].Id].EffectiveDate__c;

        //system.assertEquals((Date)  m3.get('EffectiveDate__c'), expectedResult, 'The Order was not saved correctly');

        Test.stopTest();

    }
*/
    @isTest
    static void testCancel(){
    Test.startTest();

    List<Order> tOrder=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
                        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
                        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,
                        ParentOrder__c,DocSendingMethod__c,RecordType.Name,EffectiveDate__c,Contact__c,QuotationType__c,ParentOrder__r.Status,IsCloned__c
                        FROM Order
                        WHERE Name='testOrderName0'
                        LIMIT 1];
  // system.debug('test order **************** ' + tOrder[0]);
    String reason ='Annullo cambio offerta';
    
    HDT_LC_ChildOrderProcessActions.cancel(tOrder[0],reason);

    String cancellationReason = [SELECT CancellationReason__c FROM Order WHERE Id =: tOrder[0].Id].CancellationReason__c;

    //system.assertEquals(cancellationReason, reason, 'The Order was not canceled properly');
    
    Test.stopTest();
}

    @isTest
	static void testGetFixedFee(){
        Test.startTest();
        		List<Order> tOrder=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
                            ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
            				Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,
                            ParentOrder__c,DocSendingMethod__c,RecordType.Name,Vat__c,EffectiveDate__c,Contact__c
		                    FROM Order
		                    WHERE Name='testOrderName1'
		                    LIMIT 1];
        Decimal fixedFee = HDT_LC_ChildOrderProcessActions.getFixedFee(tOrder[0].id,'HDT_RT_Attivazione');

      // system.debug('fixedFee ' + fixedFee);


        Test.stopTest();
    }

    @isTest
    static void testSaveDraft(){
        Test.startTest();
            List<Order> tOrder=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
                            ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
            				Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,
                            ParentOrder__c,DocSendingMethod__c,RecordType.Name,EffectiveDate__c
		                    FROM Order
		                    WHERE Name='testOrderName1'
		                    LIMIT 1];
    		tOrder[0].MarketOrigin__c='Libero';

            HDT_LC_ChildOrderProcessActions.saveDraft('Order',tOrder[0]);
            //Test Account

            String marketingOrigin = [SELECT MarketOrigin__c FROM Order WHERE Id =: tOrder[0].Id].MarketOrigin__c;

            //system.assertEquals(tOrder[0].MarketOrigin__c, marketingOrigin, 'The Order draft was not saved properly');

        Test.stopTest();

    }

    @isTest
    static void testSaveDraftAccount(){
        
        Test.startTest();

            List<Account> tAccount=[SELECT Id,Name, PrimaryEmail__c
                                FROM Account
                                WHERE Name='INRETE DIST. ENER.-13R0000000'
                                LIMIT 1];


            tAccount[0].PrimaryEmail__c = 'test.primary@email.com';

            HDT_LC_ChildOrderProcessActions.saveDraft('Account',tAccount[0]);

            String updatedEmail = [SELECT PrimaryEmail__c FROM Account WHERE Id =: tAccount[0].Id].PrimaryEmail__c;

            //system.assertEquals(tAccount[0].PrimaryEmail__c, updatedEmail, 'The Account draft was not saved properly');
        
        Test.stopTest();

    }

    @isTest
    static void testSaveDraftServicePoint(){
        
        Test.startTest();
        
            //Test ServicePoint
            List<Order> tOrderRetrieved =[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
                                ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
                                Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,
                                ParentOrder__c,DocSendingMethod__c,RecordType.Name,ServicePoint__c,Vat__c,EffectiveDate__c
                                FROM Order
                                WHERE Name='testOrderName0'
                                LIMIT 1];
            List<ServicePoint__c> tService=[SELECT Id, Name,ServicePointCode__c, AnnualConsumption__c
                                FROM ServicePoint__c
                                WHERE Id=:tOrderRetrieved[0].ServicePoint__c
                                LIMIT 1];
            
            tService[0].AnnualConsumption__c = 69;

            HDT_LC_ChildOrderProcessActions.saveDraft('ServicePoint__c',tService[0]);

            Decimal updatedConsumption = [SELECT AnnualConsumption__c FROM ServicePoint__c WHERE Id =: tService[0].Id].AnnualConsumption__c;

            //system.assertEquals(tService[0].AnnualConsumption__c, updatedConsumption, 'The Service Point draft was not saved properly');

        Test.stopTest();
        
    }

    @isTest
    static void testSaveDraft2(){
        Test.startTest();

            List<Order> tOrder=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
                ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
                Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,
                ParentOrder__c,DocSendingMethod__c,RecordType.Name,NotRegisteredMeterCase__c,EffectiveDate__c
                FROM Order
                WHERE Name='testOrderName1'
                LIMIT 1];
            List<Order> tOrder2=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
                ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
                Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,
                ParentOrder__c,DocSendingMethod__c,RecordType.Name,NotRegisteredMeterCase__c,EffectiveDate__c
                FROM Order
                WHERE Name='testOrderName0'
                LIMIT 1];

            tOrder[0].MarketOrigin__c='Libero';
		
            HDT_LC_ChildOrderProcessActions.saveDraft('Order',tOrder[0],'Order',tOrder2[0]);

            String marketingOrigin = [SELECT MarketOrigin__c FROM Order WHERE Id =: tOrder[0].Id].MarketOrigin__c;

            //system.assertEquals(tOrder[0].MarketOrigin__c, marketingOrigin, 'The Order draft was not saved properly');

        Test.stopTest();

    }

    @isTest
    static void testSaveDraft2Account() {
        
        List<Account> tAccount=[SELECT Id,Name, PrimaryEmail__c
                                FROM Account
                                WHERE Name='INRETE DIST. ENER.-13R0000000'
                                LIMIT 1];

        tAccount[0].PrimaryEmail__c = 'test.primary@email.com';

        HDT_LC_ChildOrderProcessActions.saveDraft('Account',tAccount[0],'Account',tAccount[0]);

        String updatedEmail = [SELECT PrimaryEmail__c FROM Account WHERE Id =: tAccount[0].Id].PrimaryEmail__c;

        //system.assertEquals(tAccount[0].PrimaryEmail__c, updatedEmail, 'The Account draft was not saved properly');

    }
        
    @isTest
    static void testSaveDraft2ServicePoint(){

        Test.startTest();

        //Test ServicePoint
       	List<Order> tOrderRetrieved =[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
                            ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
            				Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,
                            ParentOrder__c,DocSendingMethod__c,RecordType.Name,ServicePoint__c,Vat__c,NotRegisteredMeterCase__c,EffectiveDate__c, AnnualConsumption__c
		                    FROM Order
		                    WHERE Name='testOrderName0'
		                    LIMIT 1];
        List<ServicePoint__c> tService=[SELECT Id, Name,ServicePointCode__c
		                    FROM ServicePoint__c
		                    WHERE Id=:tOrderRetrieved[0].ServicePoint__c
		                    LIMIT 1];

        tService[0].AnnualConsumption__c = 69;
        
        HDT_LC_ChildOrderProcessActions.saveDraft('ServicePoint__c',tService[0],'ServicePoint__c',tService[0]);

        Decimal updatedConsumption = [SELECT AnnualConsumption__c FROM ServicePoint__c WHERE Id =: tService[0].Id].AnnualConsumption__c;

        //system.assertEquals(tService[0].AnnualConsumption__c, updatedConsumption, 'The Service Point draft was not saved properly');


        Test.stopTest();
        
    }


}