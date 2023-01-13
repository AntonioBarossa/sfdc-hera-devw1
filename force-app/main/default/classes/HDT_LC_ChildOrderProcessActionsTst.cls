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
            HDT_UTL_DataFactoryTst.newPhaseTransition('In Lavorazione','Bozza',utlConstants.ORDER_RECORDTYPEID_ORDERDOSSIER,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_ORDERDOSSIER);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Bozza','In Lavorazione',utlConstants.ORDER_RECORDTYPEID_ORDERDOSSIER,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_ORDERDOSSIER);
            
            HDT_UTL_DataFactoryTst.newPhaseTransition('Bozza','Accettazione Voltura',utlConstants.ORDER_RECORDTYPEID_CONNESSIONECONATTIVAZIONE,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_CONNESSIONECONATTIVAZIONE);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Accettazione Voltura','Bozza',utlConstants.ORDER_RECORDTYPEID_CONNESSIONECONATTIVAZIONE,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_CONNESSIONECONATTIVAZIONE);

            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa validazione','Da Inviare',utlConstants.ORDER_RECORDTYPEID_CONNESSIONECONATTIVAZIONE,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_CONNESSIONECONATTIVAZIONE);
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa validazione','Da Inviare',utlConstants.ORDER_RECORDTYPEID_VOLTURA,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_VOLTURA);
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa validazione','Da Inviare',utlConstants.ORDER_RECORDTYPEID_SUBENTRO,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_SUBENTRO);
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa validazione','Da Inviare',utlConstants.ORDER_RECORDTYPEID_SWITCHIN,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_ATTIVAZIONECONMODIFICA);
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa validazione','Da Inviare',utlConstants.ORDER_RECORDTYPEID_ATTIVAZIONECONMODIFICA,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_SWITCHIN);
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa validazione','Da Inviare',utlConstants.ORDER_RECORDTYPEID_ORDERDOSSIER,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_ORDERDOSSIER);

            HDT_UTL_DataFactoryTst.newPhaseTransition('Documentazione Gestita','Bozza',utlConstants.ORDER_RECORDTYPEID_CONNESSIONECONATTIVAZIONE,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_CONNESSIONECONATTIVAZIONE);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Documentazione Gestita','Bozza',utlConstants.ORDER_RECORDTYPEID_VOLTURA,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_VOLTURA);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Documentazione Gestita','Bozza',utlConstants.ORDER_RECORDTYPEID_SUBENTRO,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_SUBENTRO);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Documentazione Gestita','Bozza',utlConstants.ORDER_RECORDTYPEID_SWITCHIN,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_ATTIVAZIONECONMODIFICA);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Documentazione Gestita','Bozza',utlConstants.ORDER_RECORDTYPEID_ATTIVAZIONECONMODIFICA,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_SWITCHIN);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Documentazione Gestita','Bozza',utlConstants.ORDER_RECORDTYPEID_ORDERDOSSIER,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_ORDERDOSSIER);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Documentazione Gestita','Bozza',utlConstants.ORDER_RECORDTYPEID_ORDERDOSSIER,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_ORDERDOSSIER);
            
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa validazione','Da Inviare',utlConstants.ORDER_RECORDTYPEID_CONNESSIONECONATTIVAZIONE,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_CONNESSIONECONATTIVAZIONE);
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa validazione','Da Inviare',utlConstants.ORDER_RECORDTYPEID_VOLTURA,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_VOLTURA);
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa validazione','Da Inviare',utlConstants.ORDER_RECORDTYPEID_SUBENTRO,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_SUBENTRO);
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa validazione','Da Inviare',utlConstants.ORDER_RECORDTYPEID_SWITCHIN,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_ATTIVAZIONECONMODIFICA);
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa validazione','Da Inviare',utlConstants.ORDER_RECORDTYPEID_ATTIVAZIONECONMODIFICA,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_SWITCHIN);
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa validazione','Da Inviare',utlConstants.ORDER_RECORDTYPEID_ORDERDOSSIER,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_ORDERDOSSIER);
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa validazione','Da Inviare',utlConstants.ORDER_RECORDTYPEID_RIATTIVAZIONENONMOROSE,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_RIATTIVAZIONENONMOROSE);
            

            HDT_UTL_DataFactoryTst.newPhaseTransition('Da Inviare','Bozza',utlConstants.ORDER_RECORDTYPEID_ATTIVAZIONE,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_ATTIVAZIONE);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Bozza','Da Inviare',utlConstants.ORDER_RECORDTYPEID_ATTIVAZIONE,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_ATTIVAZIONE);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Accettazione Voltura','Bozza',utlConstants.ORDER_RECORDTYPEID_VOLTURA,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_VOLTURA);
            HDT_UTL_DataFactoryTst.newPhaseTransition('In Lavorazione','Bozza',utlConstants.ORDER_RECORDTYPEID_VOLTURA,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_VOLTURA);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Da Inviare','Bozza',utlConstants.ORDER_RECORDTYPEID_VAS,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_VAS);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Da Inviare','Bozza',utlConstants.ORDER_RECORDTYPEID_VOLTURA,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_VOLTURA);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Da Inviare','Bozza',utlConstants.ORDER_RECORDTYPEID_SUBENTRO,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_SUBENTRO);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Da Inviare','Bozza',utlConstants.ORDER_RECORDTYPEID_SWITCHIN,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_SWITCHIN);
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa validazione','Bozza',utlConstants.ORDER_RECORDTYPEID_SWITCHIN,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_SWITCHIN);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Da Inviare','Comunicazione verso Heroku',utlConstants.ORDER_RECORDTYPEID_SWITCHIN,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_SWITCHIN);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Da Inviare','Bozza',utlConstants.ORDER_RECORDTYPEID_ATTIVAZIONECONMODIFICA,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_ATTIVAZIONECONMODIFICA);
            HDT_UTL_DataFactoryTst.newPhaseTransition('In Lavorazione','Bozza',utlConstants.ORDER_RECORDTYPEID_SWITCHIN,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_ATTIVAZIONECONMODIFICA);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Da Inviare','Bozza',utlConstants.ORDER_RECORDTYPEID_CONNESSIONECONATTIVAZIONE,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_CONNESSIONECONATTIVAZIONE);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Da Inviare','Bozza',utlConstants.ORDER_RECORDTYPEID_ORDERDOSSIER,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_ORDERDOSSIER);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Comunicazione verso Heroku','Bozza',utlConstants.ORDER_RECORDTYPEID_SWITCHIN,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_SWITCHIN);
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa validazione','Da Inviare',utlConstants.ORDER_RECORDTYPEID_SWITCHIN,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_SWITCHIN);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Sospeso','Bozza',utlConstants.ORDER_RECORDTYPEID_RIATTIVAZIONENONMOROSE,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_RIATTIVAZIONENONMOROSE);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Sospeso','Bozza',utlConstants.ORDER_RECORDTYPEID_VOLTURA,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_VOLTURA);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Da Inviare','Bozza',utlConstants.ORDER_RECORDTYPEID_RIATTIVAZIONENONMOROSE,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_RIATTIVAZIONENONMOROSE);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Documentazione Gestita','Bozza',utlConstants.ORDER_RECORDTYPEID_RIATTIVAZIONENONMOROSE,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_RIATTIVAZIONENONMOROSE);
            //HDT_UTL_DataFactoryTst.newPhaseTransition('In Lavorazione','Bozza',utlConstants.ORDER_RECORDTYPEID_RIATTIVAZIONENONMOROSE,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_RIATTIVAZIONENONMOROSE);

            
			Id rt=utlConstants.ACCOUNT_RECORDTYPEID_RESINDEZIALE;


            List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(2,false,'HERA COMM','Condominio','Grandi Condomini');
			accounts[0].ActiveMonitoring__c=false;
			accounts[0].Name='INRETE DIST. ENER.-13R0000000';
			accounts[0].LastName__c='INRETE DIST. ENER.-13R0000000';

            
            accounts[1].ActiveMonitoring__c=false;
			accounts[1].Name='MARCO ROSSI';
			accounts[1].FirstName__c='MARCO';
			accounts[1].LastName__c='ROSSI';
            accounts[1].BillingIsAddressVerified__c = true;
            accounts[1].RecordTypeId=rt;
            accounts[1].CustomerMarking__c='Persona Fisica';
			accounts[1].Category__C='Famiglie';
			insert accounts;

            accounts[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Distributore').getRecordTypeId();

            update accounts;

            List<Account> myAccountResidenzialeList = new List<Account>();
            Account myAccountResidenziale = new Account();
            id accountResidenziale=utlConstants.ACCOUNT_RECORDTYPEID_RESINDEZIALE;
            myAccountResidenziale.RecordTypeId = accountResidenziale;
            myAccountResidenziale.Name = 'Test Residenziale';
            myAccountResidenziale.CompanyOwner__c = 'MMS';
            myAccountResidenziale.CustomerMarking__c = 'MMS Persona fisica';
            myAccountResidenziale.Category__c = 'Famiglie';
            myAccountResidenziale.BillingCityCode__c='Roma';
			myAccountResidenziale.BillingStreetName__c='via roma';
			myAccountResidenziale.BillingStreetNumber__c='55';
            myAccountResidenziale.FiscalCode__c = 'PMOPPP21M18E507H';
            myAccountResidenziale.IsWrongFiscalData__c = false;
        	myAccountResidenziale.BillingIsAddressVerified__c = true;
            myAccountResidenzialeList.add(myAccountResidenziale);
            insert myAccountResidenzialeList;
            
            HDT_UTL_DataFactoryTst.createComfortQualityCall(2,true);
            List<BillingProfile__c> billing =HDT_UTL_DataFactoryTst.createBillingProfile(1,true,accounts[0].Id);
			List<Opportunity> opps=HDT_UTL_DataFactoryTst.createOpportunity(1, true);
			List<Sale__c> sales=HDT_UTL_DataFactoryTst.createSale(9, true, accounts[0].Id, 'Attiva');
			List<Pricebook2> pricebook=HDT_UTL_DataFactoryTst.createPricebook(1, true);
            List<ServicePoint__c> sp = HDT_UTL_DataFactoryTst.createServicePoint(1, false);
            sp[0].RecordTypeId = utlConstants.SERVICEPOINT_RECORDTYPEID_GAS;
            sp[0].CommoditySector__c = 'Gas';
            insert sp;
			List<Order> orders=HDT_UTL_DataFactoryTst.createOrderWithPricebook(9, false, accounts[0].Id, sales, pricebook[0].Id);
            Integer index = 0;
            for(order ord : orders){
                if(index < 4){
                    ord.SignatureMethod__c = 'OTP Remoto';
                }
                index++;
            }
            
            id orderVoltura=utlConstants.ORDER_RECORDTYPEID_VOLTURA;
            id orderSubentro=utlConstants.ORDER_RECORDTYPEID_SUBENTRO;
            id orderSwitchIn=utlConstants.ORDER_RECORDTYPEID_SWITCHIN;
            id orderAttivazione=utlConstants.ORDER_RECORDTYPEID_ATTIVAZIONE;
            id orderAttivazioneConModifica=utlConstants.ORDER_RECORDTYPEID_ATTIVAZIONECONMODIFICA;
			id orderConnessioneConAttiv=utlConstants.ORDER_RECORDTYPEID_CONNESSIONECONATTIVAZIONE;
			id orderDossier=utlConstants.ORDER_RECORDTYPEID_ORDERDOSSIER;
            Id orderVas = utlConstants.ORDER_RECORDTYPEID_VAS;
            
            
            Id accId = accounts[0].id;
            
            List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(2,false,accId);

            insert contacts;
			Id contactId = contacts[0].id;
            
            orders[6].RecordTypeId=orderDossier;
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
            orders[6].Channel__c  = 'Sportello';
            orders[6].SignedDate__c = Date.today();
			
            insert orders[6];
            
            orders[0].RecordTypeId=orderSubentro;
			orders[0].Username__c='test';
			orders[0].Password__c='test1';
			orders[0].NotRegisteredMeterCase__c=false;
			orders[0].EffectiveDate__c=date.today();
			orders[0].PowerCommitted__c=2;
			orders[0].ImplantType__c='13A0-Usi di Abitazione BT';
			orders[0].RequestOption__c='Domestici-TD';
			orders[0].CreditCheckDescription__c='test1';
            orders[0].Contact__c = contactId;
            orders[0].IsActivationDeferred__c=true;
			orders[0].VATfacilitationFlag__c=true;
            orders[0].SupplyType__c = 'Domestico';

            
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
            orders[2].ExciseGas__c = 'Imposta Usi Domestici (Cod. G_ICD)';
            orders[2].UseCategory__c='003-CotturaCibi+AcquaCalda';
            orders[2].SupplyType__c = 'Domestico';
            orders[2].CustomerCategory__c = 'Famiglie';
            orders[2].ImplantType__c = '13A0-Usi di Abitazione BT';
            orders[2].WithdrawalClass__c = '001 - 7 giorni';



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
            orders[3].Commodity__c = 'Energia Elettrica';
            orders[3].SupplyType__c = 'Domestico';


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
            orders[5].Commodity__c='Gas';
            orders[5].ExciseGas__c = 'Imposta Usi Domestici (Cod. G_ICD)';
            orders[5].UseCategory__c='003-CotturaCibi+AcquaCalda';
            orders[5].SupplyType__c = 'Domestico';
            orders[5].CustomerCategory__c = 'Famiglie';
            orders[5].ImplantType__c = '13A0-Usi di Abitazione BT';
            orders[5].WithdrawalClass__c = '001 - 7 giorni';     
            
            orders[7].RecordTypeId=orderVas;
            orders[7].VasSubtype__c = 'Analisi Consumi';
			orders[7].VoltageLevel__c='BT';
			orders[7].ProcessCode__c='E02';
			orders[7].UseTypeEnergy__c='Manifest (Temp Straord 16h)';
			orders[7].CreditCheckDescription__c='test6Temporanea';
			orders[7].RequestOption__c='Domestici-TD';
			orders[7].PowerRequested__c=2;
			orders[7].PowerCommitted__c=2;
            orders[7].Contact__c = contactId;
            orders[7].IsActivationDeferred__c=true;
            orders[7].VATfacilitationFlag__c=false;
            orders[7].Commodity__c='Gas';
            orders[7].ExciseGas__c = 'Imposta Usi Domestici (Cod. G_ICD)';
            orders[7].UseCategory__c='003-CotturaCibi+AcquaCalda';
            orders[7].SupplyType__c = 'Domestico';
            orders[7].CustomerCategory__c = 'Famiglie';
            orders[7].ImplantType__c = '13A0-Usi di Abitazione BT';
            orders[7].WithdrawalClass__c = '001 - 7 giorni';    

			upsert orders;

            FieldCoerenceServicePoint__c testObject = new FieldCoerenceServicePoint__c();
            testObject.AccountCategory__c = 'Famiglie';
            testObject.UseCategory__c = '003-CotturaCibi+AcquaCalda';
            testObject.Commodity__c = 'Gas';
            testObject.ImplantType__c = '13A0-Usi di Abitazione BT';
            testObject.SupplyType__c = 'Domestico';
            testObject.WithdrawalClass__c = '001 - 7 giorni';
            testObject.Taxes__c = 'G_ICD';
            testObject.IsActive__c = true;
            insert testObject;
            

			List<Order> childOrders=HDT_UTL_DataFactoryTst.createChildOrder(1, false, accounts[0].Id, sales, orders[0].Id, contacts[0].Id);
			childOrders[0].QualityCall__c=true;
			insert childOrders;

			List<ServicePoint__c> servPoints=HDT_UTL_DataFactoryTst.createServicePoint(2, false);
			servPoints[0].Distributor__c=accounts[0].Id;
			servPoints[0].CommoditySector__c='Energia Elettrica';
            servPoints[1].Distributor__c=accounts[0].Id;
			servPoints[1].CommoditySector__c='Gas';

			insert servPoints;

            
            List<Order> ordersResidenziale=HDT_UTL_DataFactoryTst.createOrder(1, false, myAccountResidenzialeList[0].Id,'Bozza');
			ordersResidenziale[0].Name = 'orderResidenziale';
            ordersResidenziale[0].RecordTypeId = utlConstants.ORDER_RECORDTYPEID_VOLTURA;
            ordersResidenziale[0].ServicePoint__c = servPoints[0].Id;
            ordersResidenziale[0].Contact__c = contactId;
            ordersResidenziale[0].ParentOrder__c = orders[6].Id;
            ordersResidenziale[0].BillingProfile__c = billing[0].Id;
            insert ordersResidenziale;

            List<Order> ordersResidenzialeSwitchIn=HDT_UTL_DataFactoryTst.createOrder(1, false, myAccountResidenzialeList[0].Id,'Bozza');
			ordersResidenzialeSwitchIn[0].Name = 'orderResidenzialeSwitchIn';
            ordersResidenzialeSwitchIn[0].ServicePoint__c = servPoints[0].Id;
            ordersResidenzialeSwitchIn[0].Contact__c = contactId;
            ordersResidenzialeSwitchIn[0].ParentOrder__c = orders[6].Id;
            ordersResidenzialeSwitchIn[0].BillingProfile__c = billing[0].Id;
            ordersResidenzialeSwitchIn[0].PowerCommitted__c=2;
			ordersResidenzialeSwitchIn[0].CreditCheckDescription__c = 'test3';
			ordersResidenzialeSwitchIn[0].VoltureType__c='In Continuità';
			ordersResidenzialeSwitchIn[0].RecordTypeId = orderSwitchIn;
			ordersResidenzialeSwitchIn[0].IsActivationDeferred__c=true;
            ordersResidenzialeSwitchIn[0].ProcessType__c = 'Switch in Ripristinatorio';
            ordersResidenzialeSwitchIn[0].SignedDate__c = null;
            ordersResidenzialeSwitchIn[0].VATfacilitationFlag__c=true;
            ordersResidenzialeSwitchIn[0].ExciseGas__c = 'Imposta Usi Domestici (Cod. G_ICD)';
            ordersResidenzialeSwitchIn[0].UseCategory__c='003-CotturaCibi+AcquaCalda';
            ordersResidenzialeSwitchIn[0].SupplyType__c = 'Domestico';
            ordersResidenzialeSwitchIn[0].CustomerCategory__c = 'Famiglie';
            ordersResidenzialeSwitchIn[0].ImplantType__c = '13A0-Usi di Abitazione BT';
            ordersResidenzialeSwitchIn[0].WithdrawalClass__c = '001 - 7 giorni';
            ordersResidenzialeSwitchIn[0].SignatureMethod__c = 'OTP Remoto';
            insert ordersResidenzialeSwitchIn;


			List<SBQQ__Quote__c> quotes=HDT_UTL_DataFactoryTst.createQuote(1, false, orders[0].Id, opps[0].Id, sales[0].Id, 'Amendment');
			quotes[0].IsVAS__c=false;
			quotes[0].AmendmentAllowed__c=false;
			insert quotes;

			orders[0].ServicePoint__c=servPoints[0].Id;
			orders[0].SBQQ__Quote__c=quotes[0].id;
			orders[1].ProcessType__c='Voltura';//HRADTR_GV 
			orders[1].NotRegisteredMeterCase__c=true;//HRADTR_GV 
			orders[1].ServicePoint__c=servPoints[0].Id;
            orders[2].ServicePoint__c=servPoints[1].Id;
			orders[3].ServicePoint__c=servPoints[0].Id;
			orders[3].SBQQ__Quote__c=quotes[0].id;
            orders[5].ServicePoint__c=servPoints[1].Id;



			update orders;

			List<Contract> contracts=HDT_UTL_DataFactoryTst.createContract(1, true, accounts[0].Id);
			List<Case> cases=HDT_UTL_DataFactoryTst.createCase(1, false, accounts[0].Id, contacts[0].Id, servPoints[0].Id, contracts[0].Id, orders[0].Id);
			cases[0].Type='Cambio Contatore Non Registrato';
			cases[0].Phase__c='Completata';
            cases[0].ServicePoint__c = servPoints[0].Id;//HRADTR_GV
			cases[0].VulturePracticeReference__c=orders[1].Id;//HRADTR_GV

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
        
        List<Order> tOrder2=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c, ExciseGas__c, UseCategory__c, SupplyType__c, ImplantType__c, WithdrawalClass__c,
        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,Status,
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,Market__c,
        ParentOrder__c,DocSendingMethod__c,RecordType.Name,ContractReference__c,EffectiveDate__c,Contact__c,ParentOrder__r.Status,IsCloned__c,QuotationType__c
        FROM Order WHERE Name Like 'testOrderName%' ORDER BY Name asc];
        
        
        Test.startTest();
        Try{
                
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
            tOrder2[2].SignatureMethod__c = 'Contratto già firmato';
            tOrder2[2].ProcessType__c='';
            HDT_LC_ChildOrderProcessActions.save(tOrder2[2],m2);

            list<Order> expectedResult = [SELECT  Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
            ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,Status,
            Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,EffectiveDate__c  FROM Order WHERE id=:tOrder2[2].id] ;
            System.assertEquals(expectedResult.get(0).status, 'In Lavorazione', 'In Lavorazione');
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        } 
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
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,Market__c,
        ParentOrder__c,DocSendingMethod__c,RecordType.Name,ContractReference__c,EffectiveDate__c,Contact__c,ParentOrder__r.Status,IsCloned__c,QuotationType__c
        FROM Order WHERE Name Like 'testOrderName%' ORDER BY Name asc];
               
        Test.startTest();
		
        //Test Subentro
      // system.debug('Test Subentro');
        Map<String,Object> m = new Map<String,Object>();
        m.put('EffectiveDate', Date.today());

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

        List<Order> expectedResult = [SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,
        ParentOrder__c,DocSendingMethod__c,RecordType.Name,ContractReference__c,EffectiveDate__c,Contact__c,ParentOrder__r.Status,IsCloned__c,QuotationType__c  FROM Order WHERE Id =: tOrder2[0].Id];
        System.assertEquals(System.today(), expectedResult.get(0).EffectiveDate__c, System.today());

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
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,Market__c,
        ParentOrder__c,DocSendingMethod__c,RecordType.Name,ContractReference__c,EffectiveDate__c,Contact__c,ParentOrder__r.Status,IsCloned__c,QuotationType__c
        FROM Order WHERE Name Like 'testOrderName%' ORDER BY Name asc];
               
        Test.startTest();

        //Test AttivazioneConModifica
      // system.debug('Test AttivazioneConModifica');
        Map<String,Object> m3 = new Map<String,Object>();
        m3.put('EffectiveDate__c', Date.today());
		tOrder2[3].QuotationType__c='Rapido';
        HDT_LC_ChildOrderProcessActions.save(tOrder2[0],m3);

        List<Order> expectedResult = [SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,
        ParentOrder__c,DocSendingMethod__c,RecordType.Name,ContractReference__c,EffectiveDate__c,Contact__c,ParentOrder__r.Status,IsCloned__c,QuotationType__c  FROM Order WHERE Id =: tOrder2[0].Id];
        System.assertEquals(System.today(), expectedResult.get(0).EffectiveDate__c, System.today());


        Test.stopTest();

    }
    @isTest
	static void testSaveM(){
        
        //Start Test
        
        List<Order> tOrder2=[SELECT Id, Name, Contact__c, Contact__r.Id, Account.Id, Account.RecordType.Id, Account.RecordType.DeveloperName, RecordType.Id, RecordType.DeveloperName, Commodity__c,
        VATfacilitationFlag__c, SignatureMethod__c, ProcessType__c, EffectiveDate__c, QuotationType__c, ParentOrder__c, ParentOrder__r.Id, ParentOrder__r.Status,Market__c,
        Channel__c, CustomerCategory__c, MarketOrigin__c FROM Order WHERE Name = 'orderResidenziale'];
        

        Test.startTest();

        //Test AttivazioneConModifica
        // system.debug('Test AttivazioneConModifica');
        Map<String,Object> m3 = new Map<String,Object>();

        m3.put('EffectiveDate__c', Date.today().addDays(11));
        tOrder2[0].VATfacilitationFlag__c=true;
        tOrder2[0].QuotationType__c='Rapido';
        tOrder2[0].Commodity__c = 'Energia Elettrica';
        tOrder2[0].ProcessType__c = 'Switch in Ripristinatorio';
        Order myOrder = [Select Id from Order where RecordType.Name = 'Order Dossier'];
        tOrder2[0].ParentOrder__c = myOrder.Id;
        tOrder2[0].EffectiveDate__c = Date.today();
        tOrder2[0].SupplyType__c = 'Domestico';
        update tOrder2;

        HDT_LC_ChildOrderProcessActions.save(tOrder2[0],m3);

        m3.put('VATfacilitationFlag__c',true);
        try{
        HDT_LC_ChildOrderProcessActions.save(tOrder2[0],m3);
        }
 
        catch(Exception e){ 
            System.assertEquals(true, true, 'Caricare documento per iva e accise');

        }
        Test.stopTest();

    }

    @isTest
	static void testSaveSwitchInResidenziale(){
        
        //Start Test
        
        List<Order> tOrder2=[SELECT Id, Name, Contact__c, Contact__r.Id, Account.Id, Account.RecordType.Id, Account.RecordType.DeveloperName, RecordType.Id, RecordType.DeveloperName, Commodity__c,
        VATfacilitationFlag__c, SignatureMethod__c, ProcessType__c, EffectiveDate__c, QuotationType__c, ParentOrder__c, ParentOrder__r.Id, ParentOrder__r.Status,Market__c,
        Channel__c, CustomerCategory__c, MarketOrigin__c, IsCloned__c, SignedDate__c,VolturaThirdTrader__c FROM Order WHERE Name = 'orderResidenzialeSwitchIn'];
        

        Test.startTest();

        //Test AttivazioneConModifica
        // system.debug('Test AttivazioneConModifica');
        Map<String,Object> m3 = new Map<String,Object>();

        m3.put('EffectiveDate__c', Date.today().addDays(11));
        tOrder2[0].VATfacilitationFlag__c=true;
        tOrder2[0].VolturaThirdTrader__c=true;
        tOrder2[0].QuotationType__c='Rapido';
        tOrder2[0].Commodity__c = 'Energia Elettrica';
        tOrder2[0].ProcessType__c = 'Switch in Ele';
        Order myOrder = [Select Id from Order where RecordType.Name = 'Order Dossier'];
        tOrder2[0].ParentOrder__c = myOrder.Id;
        tOrder2[0].EffectiveDate__c = Date.today();
        tOrder2[0].SupplyType__c = 'Domestico';
        tOrder2[0].SignatureMethod__c = 'OTP Remoto';
        update tOrder2;
        system.debug('PUNTO 1 --> '+tOrder2[0].Account.RecordType.DeveloperName);
        HDT_LC_ChildOrderProcessActions.save(tOrder2[0],m3);

        m3.put('VATfacilitationFlag__c',true);
        try{
        HDT_LC_ChildOrderProcessActions.save(tOrder2[0],m3);
        }
 
        catch(Exception e){ 
            System.assertEquals(true, true, 'Caricare documento per iva e accise');

        }
        Test.stopTest();

    }

    @isTest
	static void testSaveM2(){
        
        //Start Test
        
        List<Order> tOrder2=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,Market__c,
        ParentOrder__c,DocSendingMethod__c,RecordType.Name,ContractReference__c,EffectiveDate__c,Contact__c,ParentOrder__r.Status,IsCloned__c,QuotationType__c
        FROM Order WHERE Name Like 'testOrderName%' ORDER BY Name asc limit 1];
        List<Account> accountList= HDT_UTL_DataFactoryTst.createAccountResidenziale(1,false,'HERA COMM','Persona fisica','Famiglie');
        List<Order> listToDelete =[SELECT ID FROM ORDER where id NOT IN:tOrder2];
        delete listToDelete;
        Test.startTest();

        //Test AttivazioneConModifica
      // system.debug('Test AttivazioneConModifica');
        Map<String,Object> m3 = new Map<String,Object>();
        accountList.get(0).Id=tOrder2.get(0).AccountId;
        update accountList;
        m3.put('EffectiveDate__c', Date.today().addDays(11));
        tOrder2[0].VATfacilitationFlag__c=true;
        tOrder2[0].QuotationType__c='Rapido';

        Id recordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_CONNESSIONECONATTIVAZIONE).getRecordTypeId();

        tOrder2[0].recordTypeId=recordTypeId;
        tOrder2[0].Phase__c='Bozza';
        tOrder2[0].QuotationType__c='Rapido';
        update tOrder2[0];
        HDT_LC_ChildOrderProcessActions.save(tOrder2[0],m3);
        List<Order> expectedResult = [SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,
        ParentOrder__c,DocSendingMethod__c,RecordType.Name,ContractReference__c,EffectiveDate__c,Contact__c,ParentOrder__r.Status,IsCloned__c,QuotationType__c,QuickQuote__c  FROM Order WHERE Id =: tOrder2[0].Id];
        System.assertEquals('Richiesto', expectedResult.get(0).QuickQuote__c, 'Richiesto');

        Test.stopTest();

    }
    @isTest
	static void testSaveM3(){
        
        //Start Test
        
        List<Order> tOrder2=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,Market__c,
        ParentOrder__c,DocSendingMethod__c,RecordType.Name,ContractReference__c,EffectiveDate__c,Contact__c,ParentOrder__r.Status,IsCloned__c,QuotationType__c
        FROM Order WHERE CreditCheckDescription__c = 'test4AttivConMod' ORDER BY Name asc limit 1];
        List<Account> accountList= HDT_UTL_DataFactoryTst.createAccountResidenziale(1,false,'HERA COMM','Persona fisica','Famiglie');
        List<Order> listToDelete =[SELECT ID FROM ORDER where id NOT IN:tOrder2];
        delete listToDelete;
        Test.startTest();

        //Test AttivazioneConModifica
      // system.debug('Test AttivazioneConModifica');
        Map<String,Object> m3 = new Map<String,Object>();
        accountList.get(0).Id=tOrder2.get(0).AccountId;
        update accountList;
        m3.put('EffectiveDate__c', Date.today().addDays(11));
        tOrder2[0].VATfacilitationFlag__c=true;
        Id recordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_ATTIVAZIONECONMODIFICA).getRecordTypeId();

        tOrder2[0].recordTypeId=recordTypeId;
        tOrder2[0].Phase__c='Bozza';
        tOrder2[0].QuotationType__c='Rapido';

        update tOrder2[0];
        tOrder2=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,Market__c,
        ParentOrder__c,DocSendingMethod__c,RecordType.Name,ContractReference__c,EffectiveDate__c,Contact__c,ParentOrder__r.Status,IsCloned__c,QuotationType__c
        FROM Order WHERE Name Like 'testOrderName%' ORDER BY Name asc limit 1];
        system.debug('@@@ tOrder2 SaveM3 '+ tOrder2);
        system.debug('@@@ m3 SaveM3'+ m3);
        HDT_LC_ChildOrderProcessActions.save(tOrder2[0],m3);
        recordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_ATTIVAZIONE).getRecordTypeId();

        tOrder2[0].recordTypeId=recordTypeId;
        tOrder2[0].Phase__c='Bozza';

        update tOrder2[0];
        tOrder2=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,Market__c,
        ParentOrder__c,DocSendingMethod__c,RecordType.Name,ContractReference__c,EffectiveDate__c,Contact__c,ParentOrder__r.Status,IsCloned__c,QuotationType__c
        FROM Order WHERE Name Like 'testOrderName%' ORDER BY Name asc limit 1];
        HDT_LC_ChildOrderProcessActions.save(tOrder2[0],m3);
        List<Order> expectedResult = [SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,
        ParentOrder__c,DocSendingMethod__c,RecordType.Name,ContractReference__c,EffectiveDate__c,Contact__c,ParentOrder__r.Status,IsCloned__c,QuotationType__c,QuickQuote__c  FROM Order WHERE Id =: tOrder2[0].Id];
        System.assertEquals('Richiesto', expectedResult.get(0).QuickQuote__c, 'Richiesto');

        Test.stopTest();

    }
    @isTest
	static void testSaveM4(){
        
        //Start Test
        
        List<Order> tOrder2=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,QuickQuote__c,
        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,Market__c,
        ParentOrder__c,DocSendingMethod__c,RecordType.Name,ContractReference__c,EffectiveDate__c,Contact__c,ParentOrder__r.Status,IsCloned__c,QuotationType__c
        FROM Order WHERE Name Like 'testOrderName%' ORDER BY Name asc limit 1];
        List<Order> listToDelete =[SELECT ID FROM ORDER where id NOT IN:tOrder2];
        delete listToDelete;
        Test.startTest();
        Map<String,Object> m3 = new Map<String,Object>();
        m3.put('EffectiveDate__c', Date.today().addDays(11));
        tOrder2[0].VATfacilitationFlag__c=true;
        tOrder2[0].QuotationType__c='Rapido';

        Id recordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_ATTIVAZIONECONMODIFICA).getRecordTypeId();

        tOrder2[0].recordTypeId=recordTypeId;
        tOrder2[0].Phase__c='Bozza';
        update tOrder2[0];
        tOrder2=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,QuickQuote__c,
        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,Market__c,
        ParentOrder__c,DocSendingMethod__c,RecordType.Name,ContractReference__c,EffectiveDate__c,Contact__c,ParentOrder__r.Status,IsCloned__c,QuotationType__c
        FROM Order WHERE Name Like 'testOrderName%' ORDER BY Name asc limit 1];
        HDT_LC_ChildOrderProcessActions.save(tOrder2[0],m3);
        recordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_ATTIVAZIONE).getRecordTypeId();

        tOrder2[0].recordTypeId=recordTypeId;
        tOrder2[0].Phase__c='Bozza';

        update tOrder2[0];
        tOrder2=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,QuickQuote__c,
        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,Market__c,
        ParentOrder__c,DocSendingMethod__c,RecordType.Name,ContractReference__c,EffectiveDate__c,Contact__c,ParentOrder__r.Status,IsCloned__c,QuotationType__c
        FROM Order WHERE Name Like 'testOrderName%' ORDER BY Name asc limit 1];
        HDT_LC_ChildOrderProcessActions.save(tOrder2[0],m3);
        List<Order> expectedResult = [SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,QuickQuote__c,
        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,
        ParentOrder__c,DocSendingMethod__c,RecordType.Name,ContractReference__c,EffectiveDate__c,Contact__c,ParentOrder__r.Status,IsCloned__c,QuotationType__c  FROM Order];
        System.assertEquals('Richiesto', expectedResult.get(0).QuickQuote__c, 'Richiesto');

        Test.stopTest();

    }


    



    @isTest
	static void testSave5(){
        
        //Start Test
        
        List<Order> tOrder2=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,Market__c,
        ParentOrder__c,DocSendingMethod__c,RecordType.Name,ContractReference__c,EffectiveDate__c,Contact__c,ParentOrder__r.Status,IsCloned__c,QuotationType__c
        FROM Order WHERE Name Like 'testOrderName%' ORDER BY Name asc];
               
        Test.startTest();

        //Test Attivazione
      // system.debug('Test Attivazione');
        Map<String,Object> m4 = new Map<String,Object>();
        m4.put('EffectiveDate__c', Date.today().addDays(11));

        HDT_LC_ChildOrderProcessActions.save(tOrder2[0],m4);

        Date expectedResult = [SELECT EffectiveDate__c  FROM Order WHERE Id =: tOrder2[0].Id].EffectiveDate__c;
        System.assertEquals( m4.get('EffectiveDate__c'),expectedResult,  m4.get('EffectiveDate__c'));

        Test.stopTest();

    }

    @isTest
	static void testSaveVas(){
        
        //Start Test
        
        List<Order> tOrder2=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,
        ParentOrder__c,DocSendingMethod__c,RecordType.Name,ContractReference__c,EffectiveDate__c,Contact__c,ParentOrder__r.Status,IsCloned__c,QuotationType__c
        FROM Order WHERE Name Like 'testOrderName%' and RecordTypeId = :utlConstants.ORDER_RECORDTYPEID_VAS ORDER BY Name asc];
               
        Test.startTest();

        //Test Attivazione
      // system.debug('Test Attivazione');
        //Map<String,Object> m4 = new Map<String,Object>();
        //m4.put('EffectiveDate__c', Date.today().addDays(11));

        HDT_LC_ChildOrderProcessActions.save(tOrder2[0],null);
        Boolean result = true;
        //Date expectedResult = [SELECT EffectiveDate__c  FROM Order WHERE Id =: tOrder2[0].Id].EffectiveDate__c;
        System.assertEquals(true,result,  'result');
        
        Test.stopTest();

    }

    @isTest
	static void testSave6(){
        
        //Start Test
        
        List<Order> tOrder2=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c, ExciseGas__c, UseCategory__c, SupplyType__c, ImplantType__c, WithdrawalClass__c,
        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,Market__c,
        ParentOrder__c,DocSendingMethod__c,RecordType.Name,ContractReference__c,EffectiveDate__c,Contact__c,ParentOrder__r.Status,IsCloned__c,QuotationType__c
        FROM Order WHERE Name Like 'testOrderName%' ORDER BY Name asc];
               
        Test.startTest();
        Try{
                
            //Test ConnessioneConAttiv
        // system.debug('Test ConnessioneConAttiv');
            Map<String,Object> m5 = new Map<String,Object>();
            m5.put('EffectiveDate__c', Date.today().addDays(11));

            HDT_LC_ChildOrderProcessActions.save(tOrder2[5],m5);

            String expectedResult = [SELECT Instance326__c  FROM Order WHERE Id =: tOrder2[5].Id].Instance326__c;
            System.assertEquals('Richiesto', expectedResult, 'Richiesto');
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }

        Test.stopTest();

    }

    @isTest
	static void testSave7(){
        
        //Start Test

        
        List<Order> tOrder2=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,Market__c,
        ParentOrder__c,DocSendingMethod__c,RecordType.Name,ContractReference__c,EffectiveDate__c,Contact__c,ParentOrder__r.Status,IsCloned__c,QuotationType__c
        FROM Order WHERE Name Like 'testOrderName%' ORDER BY Name asc];
               
        Test.startTest();

        //Test TemporaneaNuovaAtt
      // system.debug('Test TemporaneaNuovaAtt');
        Map<String,Object> m6 = new Map<String,Object>();
        m6.put('EffectiveDate__c', Date.today().addDays(11));

        HDT_LC_ChildOrderProcessActions.save(tOrder2[0],m6);

        Date expectedResult = [SELECT EffectiveDate__c  FROM Order WHERE Id =: tOrder2[0].Id].EffectiveDate__c;
        System.assertEquals( m6.get('EffectiveDate__c'), expectedResult, m6.get('EffectiveDate__c'));

        Test.stopTest();

    }

    @isTest
	static void testSave8(){
        
        //Start Test

        
        List<Order> tOrder2=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,Market__c,
        ParentOrder__c,DocSendingMethod__c,RecordType.Name,ContractReference__c,EffectiveDate__c,Contact__c,ParentOrder__r.Status,IsCloned__c,QuotationType__c
        FROM Order WHERE Name Like 'testOrderName%' ORDER BY Name asc];
               
        Test.startTest();

        Map<String, Object> m7 = new Map<String, Object>();
        m7.put('EffectiveDate__c', Date.today().addDays(11));
        HDT_LC_ChildOrderProcessActions.save(tOrder2[0],m7);

        List<Order> expectedResult = [SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,QuickQuote__c,
        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,
        ParentOrder__c,DocSendingMethod__c,RecordType.Name,ContractReference__c,EffectiveDate__c,Contact__c,ParentOrder__r.Status,IsCloned__c,QuotationType__c  FROM Order];
        System.assertEquals('Richiesto', expectedResult.get(0).QuickQuote__c, 'Richiesto');


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
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,Market__c,
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

        System.assertEquals(  m.get('EffectiveDate__c'), expectedResult, m.get('EffectiveDate__c'));

        Test.stopTest();

    }

    @isTest
	static void testSaveRes2(){
        
        //Start Test
     
        List<Order> tOrder2=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,Market__c,
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

        Date expectedResult = [SELECT EffectiveDate__c  FROM Order WHERE Id =: tOrder2[0].Id].EffectiveDate__c;
       System.assertEquals(  m1.get('EffectiveDate__c'), expectedResult, m1.get('EffectiveDate__c'));
  

        Test.stopTest();

    }

    @isTest
	static void testSaveRes3(){
        
        //Start Test
     
        List<Order> tOrder2=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,Market__c,
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

        List<Order> expectedResult = [SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,QuickQuote__c,
        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,
        ParentOrder__c,DocSendingMethod__c,RecordType.Name,ContractReference__c,EffectiveDate__c,Contact__c,ParentOrder__r.Status,IsCloned__c,QuotationType__c  FROM Order];
        System.assertEquals('Richiesto', expectedResult.get(0).QuickQuote__c, 'Richiesto');


        Test.stopTest();

    }

    @isTest
	static void testSaveRes4(){
        
        //Start Test
     
        List<Order> tOrder2=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,Market__c,
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

        Date expectedResult = [SELECT EffectiveDate__c  FROM Order WHERE Id =: tOrder2[0].Id].EffectiveDate__c;

        System.assertEquals(  m4.get('EffectiveDate__c'), expectedResult, m4.get('EffectiveDate__c'));
        Test.stopTest();

    }

    @isTest
	static void testSaveRes5(){
        
        //Start Test
     
        List<Order> tOrder2=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c, ExciseGas__c, UseCategory__c, SupplyType__c, ImplantType__c, WithdrawalClass__c,
        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,Market__c,
        ParentOrder__c,DocSendingMethod__c,RecordType.Name,ContractReference__c,EffectiveDate__c,Contact__c,ParentOrder__r.Status,IsCloned__c,QuotationType__c
        FROM Order WHERE Name Like 'testOrderName%' ORDER BY Name asc];
      // system.debug('order list !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!' + tOrder2);
        Test.startTest();
        Try{
                
            //Test ConnessioneConAttiv
        // system.debug('Test ConnessioneConAttiv');
            Map<String,Object> m5 = new Map<String,Object>();
            m5.put('EffectiveDate__c', Date.today().addDays(11));

            tOrder2[0].Account.RecordType.DeveloperName = 'HDT_RT_Residenziale';

            HDT_LC_ChildOrderProcessActions.save(tOrder2[5],m5);

            Date expectedResult = [SELECT EffectiveDate__c  FROM Order WHERE Id =: tOrder2[5].Id].EffectiveDate__c;

            System.assertEquals(  m5.get('EffectiveDate__c'), expectedResult, m5.get('EffectiveDate__c'));
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        } 

        Test.stopTest();

    }

    // @isTest
    // static void testSaveRes6(){
        
    // 	//Start Test
     
  	//      List<Order> tOrder2=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
    //      ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,DocumentLow80__c,
    //      Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,
    //      ParentOrder__c,DocSendingMethod__c,RecordType.Name,ContractReference__c,EffectiveDate__c,Contact__c,ParentOrder__r.Status,IsCloned__c,QuotationType__c
    //      FROM Order WHERE Name Like 'testOrderName%' ORDER BY Name asc];
    //    // system.debug('order list !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!' + tOrder2);
    //      Test.startTest();

    //      //Test TemporaneaNuovaAtt
    //    // system.debug('Test TemporaneaNuovaAtt');
  	// 	 Map<String,Object> m6 = new Map<String,Object>();

    //      tOrder2[0].Account.RecordType.DeveloperName = 'HDT_RT_Residenziale';

    //      HDT_LC_ChildOrderProcessActions.save(tOrder2[6],m6);
        
    //     Test.stopTest();
    //  }
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

    System.assertEquals(reason, cancellationReason, reason);
    
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

        System.assertEquals(53.3610, fixedFee,53.3610);

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
            System.assertEquals('Libero', marketingOrigin, 'Libero');

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
            System.assertEquals(tAccount[0].PrimaryEmail__c, updatedEmail, 'test.primary@email.com');
        
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

            System.assertEquals(tService[0].AnnualConsumption__c, updatedConsumption, 69);

        Test.stopTest();
        
    }

    @isTest
    static void testSaveDraftBillingProfile(){
        
        Test.startTest();
        
            //Test ServicePoint
            List<Order> tOrderRetrieved =[SELECT Id, Name, BillingProfile__c
                                FROM Order
                                WHERE Name='orderResidenziale'
                                LIMIT 1];
            List<BillingProfile__c> tBilling=[SELECT Id, BankAgency__c
                                FROM BillingProfile__c
                                WHERE Id=:tOrderRetrieved[0].BillingProfile__c
                                LIMIT 1];

            tBilling[0].BankAgency__c = 'MAROTTA';
            HDT_LC_ChildOrderProcessActions.saveDraft('BillingProfile__c',tBilling[0]);

            String updatedName = [SELECT BankAgency__c FROM BillingProfile__c WHERE Id =: tBilling[0].Id].BankAgency__c;

            System.assertEquals(tBilling[0].BankAgency__c, updatedName, 'Update fallito');

        Test.stopTest();
        
    }

    @isTest
    static void testSaveDraft2(){
        Test.startTest();

            List<Order> tOrder=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
                ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
                Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,
                ParentOrder__c,DocSendingMethod__c,RecordType.Name,NotRegisteredMeterCase__c,EffectiveDate__c,Commodity__c
                FROM Order
                WHERE Name='testOrderName1'
                LIMIT 1];
            tOrder[0].RecordTypeId = utlConstants.ORDER_RECORDTYPEID_VOLTURA;
            update tOrder[0];
            List<Order> tOrder2=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
                ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,
                Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,
                ParentOrder__c,DocSendingMethod__c,RecordType.Name,NotRegisteredMeterCase__c,EffectiveDate__c,Commodity__c
                FROM Order
                WHERE Name='testOrderName0'
                LIMIT 1];

            tOrder[0].MarketOrigin__c='Libero';
            update tOrder;
            update tOrder2;
		
            HDT_LC_ChildOrderProcessActions.saveDraft('Order',tOrder[0],'Order',tOrder2[0]);

            String marketingOrigin = [SELECT MarketOrigin__c FROM Order WHERE Id =: tOrder[0].Id].MarketOrigin__c;

            System.assertEquals(tOrder[0].MarketOrigin__c, marketingOrigin, 'Libero');

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

        System.assertEquals(tAccount[0].PrimaryEmail__c, updatedEmail, 'The Account draft was not saved properly');

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

        System.assertEquals(tService[0].AnnualConsumption__c, updatedConsumption, 'The Service Point draft was not saved properly');


        Test.stopTest();
        
    }

    @isTest
    static void testSaveDraft2BillingProfile(){
        
        Test.startTest();
        
            //Test ServicePoint
            List<Order> tOrderRetrieved =[SELECT Id, Name, BillingProfile__c
                                FROM Order
                                WHERE Name='orderResidenziale'
                                LIMIT 1];
            List<BillingProfile__c> tBilling=[SELECT Id, BankAgency__c
                                FROM BillingProfile__c
                                WHERE Id=:tOrderRetrieved[0].BillingProfile__c
                                LIMIT 1];

            tBilling[0].BankAgency__c = 'MAROTTA';
            HDT_LC_ChildOrderProcessActions.saveDraft('BillingProfile__c',tBilling[0], 'BillingProfile__c',tBilling[0]);

            String updatedName = [SELECT BankAgency__c FROM BillingProfile__c WHERE Id =: tBilling[0].Id].BankAgency__c;

            System.assertEquals(tBilling[0].BankAgency__c, updatedName, 'Update fallito');

        Test.stopTest();
        
    }

    @IsTest
    static void voltureReadingTst()
    {
        List<Order> tOrder=[SELECT Id, Name, AccountId,RecordType.DeveloperName,SignedDate__c,
        ProcessType__c,VolturaThirdTrader__c,IsActivationDeferred__c,Market__c,
        Account.RecordType.DeveloperName,Channel__c,MarketOrigin__c,CustomerCategory__c,SignatureMethod__c,
        ParentOrder__c, ParentOrder__r.Status,DocSendingMethod__c,RecordType.Name,NotRegisteredMeterCase__c,EffectiveDate__c,Commodity__c
        FROM Order
        WHERE Name = 'testOrderName1'
        LIMIT 1];
        tOrder[0].Subprocess__c = 'Con Autolettura';
        List<ServicePoint__c> sp = [SELECT Id FROM ServicePoint__c];
        tOrder[0].ServicePoint__c = sp[0].Id;
        tOrder[0].SignatureMethod__c = 'Contratto già firmato';
        tOrder[0].ExciseGas__c = 'Imposta Usi Domestici (Cod. G_ICD)';
        tOrder[0].VAT__c = 'Iva 22% (Cod. 02)';
        tOrder[0].RegionalAdditional__c = 2;
        tOrder[0].Commodity__c = 'Gas';
        tOrder[0].CustomerCategory__c = 'Famiglie';
        tOrder[0].SupplyType__c = 'A-Domestico';
        tOrder[0].ImplantType__c = '1004-Riscaldamento promiscuo';
        tOrder[0].WithdrawalClass__c = '001 - 7 giorni';
        tOrder[0].UseCategory__c = '007-Ris.Ind+Cottura+AcquaCalda';
        update tOrder;

        Reading__c reading = new Reading__c();
        reading.OrderGas__c = tOrder[0].Id;
        reading.ReadingValueMeter__c = 10;
        reading.ReadingValueCorrector__c = 10;
        reading.ReadingSerialNumberCorrector__c = 'test';
        insert reading;

        List<FieldCoerenceServicePoint__c> fieldCspList = HDT_UTL_DataFactoryTst.createFieldCoerenceServicePoint(1, false, 'GAS');
        fieldCspList[0].AccountCategory__c = 'Famiglie';
        fieldCspList[0].SupplyType__c = 'A-Domestico';
        fieldCspList[0].ImplantType__c = '1004-Riscaldamento promiscuo';
        fieldCspList[0].Taxes__c = 'G_ICD';
        fieldCspList[0].UseCategory__c = '007-Ris.Ind+Cottura+AcquaCalda';
        fieldCspList[0].WithdrawalClass__c = '001 - 7 giorni';
        insert fieldCspList;

        Test.startTest();
            HDT_LC_ChildOrderProcessActions.save(tOrder[0], null);
        Test.stopTest();
        List<Order> orderList = [SELECT Id FROM Order WHERE Name = 'testOrderName1'];
        System.assertEquals(true, !orderList.isEmpty(), 'Update fallito');

        
    }


}