@isTest
public class HDT_SRV_DataEnrichmentPostSalesTst {
    
    @TestSetup
    static void setup(){

        HDT_UTL_Constants constantsUtl = new HDT_UTL_Constants();
        String rtName =  constantsUtl.CASE_RECORDTYPE_DEVELOPERNAME_MOROSITA;
        String rtId = constantsUtl.CASE_RECORDTYPEID_MOROSITA;
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(2, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        AccountContactRelation accountContactRel = HDT_UTL_DataFactoryTst.createAccountContactRelation(true, accList[1].Id,contactList[0].Id);
        
        List<BillingProfile__c> billingProfileList = HDT_UTL_DataFactoryTst.createBillingProfile(1,false, accList[0].Id);
        billingProfileList[0].InvoicingStreetName__c = 'Roma';
        billingProfileList[0].InvoicingStreetNumber__c = '15';
        billingProfileList[0].InvoicingStreetNumberExtension__c = '20100 ITALIA';
        billingProfileList[0].InvoicingCity__c = 'ROMA';
        billingProfileList[0].InvoicingProvince__c = 'RM';
        billingProfileList[0].InvoicingPostalCode__c = '10190';
        billingProfileList[0].InvoicingCountry__c = 'ITALIA';
        insert billingProfileList;

        AmministrazioneSottotipologiaUso__c subTable = new AmministrazioneSottotipologiaUso__c();
        subTable.Societa__c='5010';
        subTable.SottotipologiaUso__c='Uso domestico non residente';
        subTable.DataFineValidita__c=date.today().addDays(10);
        insert subTable;

        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Contract> contractListTwo = HDT_UTL_DataFactoryTst.createContract(1, true, accList[1].id);

        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(2, false, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        caseList[0].Type = 'Sollecito Emissione Bolletta';
        caseList[1].Type = 'Unificazione/Separazione BP-CA-Bolletta';
        insert caseList;

        List<ContentVersion> contentVersionList = HDT_UTL_DataFactoryTst.createContentVersion(1, true, 'Callout_Template', 
        '{"name": "Case","label": "Caso","sObjectType": "Case","queryable": true,"fields": ['
        +'{"name": "CreatedDate","label": "DT_RIC_UTENTE"},'
        +'{"name": "CaseNumber","label": "RIF_RICH"},'
        +'{"name": "Type","label": "TIPO_OPERAZIONE"},'
        +'{"name": "Id","label": "RECORD_ID"}'
        +']}'
        ,'Callout_Template.json');
        List<wrts_prcgvr__CalloutTemplate__c> calloutTemplates = HDT_UTL_DataFactoryTst.createCalloutTemplate(1,true,'Callout_Prova','prova',true,'Case','Flat',contentVersionList[0].ContentDocumentId);
        HDT_UTL_DataFactoryTst.createEndpointRule(1, true, 'Prova');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Da Inviare', 'Da Inviare', rtId, rtName,'C',calloutTemplates[0].wrts_prcgvr__Code__c,'requestType=CREA_RIC;','HDT_SRV_HerokuPostSalesManager(method="execute");');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Comunicazione verso Heroku OK', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Comunicazione verso Heroku KO', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Da Inviare', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'In Lavorazione', 'Bozza', rtId, rtName,'A','','','');
        
    }

    //INIZIO Test method per classe HDT_SRV_DataEnrichmentPostSales

    @isTest
    static void testGetPicklistValue(){

        Test.startTest();

        HDT_SRV_DataEnrichmentPostSales c = new HDT_SRV_DataEnrichmentPostSales();

        String result = c.getPicklistValue('Case', 'PhaseTypeAvailable__c', '0.8');
        System.assert('Monofase'.equals(result), 'result != Monofase');

        result = c.getPicklistValue('Case', 'PhaseTypeAvailable__c', '1.1');
        System.assert('Trifase'.equals(result), 'result != Monofase');

        result = c.getPicklistValue('Case', 'Taxes__c', 'E_IMPOST');
        System.assert('Imposta usi domestici'.equals(result), 'result != Monofase');
        
        result = c.getPicklistValue('Case', 'TaxRate__c', '10');
        System.assertEquals(result, 'Iva 22% Soc. del Gruppo (Cod. 10)', 'Match errato tra valori della picklist');
        
        result = c.getPicklistValue('Case', 'VATPercentage__c', '10');
        System.assertEquals(result, 'SOCIETA\' DEL GRUPPO 22%-10', 'Match errato tra valori della picklist');
        
        result = c.getPicklistValue('Case', 'TaxRate__c', '22');
        System.assert(String.isBlank(result), 'Match errato tra valori della picklist');

        Test.stopTest();
        
    }

    @IsTest
    static void testGetBoolFromString(){
        
        Test.startTest();
        
        HDT_SRV_DataEnrichmentPostSales c = new HDT_SRV_DataEnrichmentPostSales();

        Boolean result = c.getBoolFromString('SI');
        System.assertEquals(true, result, 'result != true');

        Boolean result2 = c.getBoolFromString('NO');
        System.assertEquals(false, result2, 'result != true');

        Test.stopTest();
        
    }

    @IsTest
    static void testGetDateByYear(){
        
        Test.startTest();

        HDT_SRV_DataEnrichmentPostSales c = new HDT_SRV_DataEnrichmentPostSales();

        Date dt = c.getDateByYear('2021');
        System.debug('Data: ' + dt);

        System.assertEquals('2021-01-01', String.valueOf(dt), 'dt != 2021-01-01');

        Test.stopTest();
        
    }

    @IsTest
    static void testGetBillingProfileIdBySapCode(){
        
        Test.startTest();
            
        HDT_SRV_DataEnrichmentPostSales c = new HDT_SRV_DataEnrichmentPostSales();

        BillingProfile__c billProfile = [Select Id, ContractAccountCode__c FROM BillingProfile__c LIMIT 1];

        String result = c.getBillingProfileIdBySapCode(billProfile.ContractAccountCode__c);

        System.assert(!String.isBlank(result), 'result is blank');

        Test.stopTest();
        
    }

    @IsTest
    static void testGetDeliveryAddress(){
        
        Test.startTest();

        HDT_SRV_DataEnrichmentPostSales c = new HDT_SRV_DataEnrichmentPostSales();

        BillingProfile__c billProfile = [SELECT Id FROM BillingProfile__c LIMIT 1];

        String result = c.getDeliveryAddress(billProfile.Id);

        System.assert(!String.isBlank(result), 'result is blank');

        Test.stopTest();
        
    }

    @IsTest
    static void testCalculateSalesCompany(){
        
        Test.startTest();

        HDT_SRV_DataEnrichmentPostSales c = new HDT_SRV_DataEnrichmentPostSales();


        String result = c.calculateSalesCompany('13V0000000');
        System.assertEquals('Hera Comm S.p.A.', result, 'result != Hera Comm S.p.A.');

        String result2 = c.calculateSalesCompany('10V0000160');
        System.assertEquals('Hera Comm Marche', result2, 'result != Hera Comm S.p.A.');

        Test.stopTest();
        
    }

    @IsTest
    static void testGetCaliber(){

        List<String> caliberValues = new List<String>();
        caliberValues.add('GRT005');
        caliberValues.add('GRT010');
        caliberValues.add('GRT015');
        caliberValues.add('GRT006');
        caliberValues.add('GRT011');
        caliberValues.add('GRT016');
        caliberValues.add('GRT002');
        caliberValues.add('GRT007');
        caliberValues.add('GRT012');
        caliberValues.add('GRT003');
        caliberValues.add('GRT008');
        caliberValues.add('GRT013');
        caliberValues.add('GRT017');
        caliberValues.add('GRT004');
        caliberValues.add('GRT009');
        caliberValues.add('GRT014');
        caliberValues.add('GRT018');
        
        Test.startTest();
        
        HDT_SRV_DataEnrichmentPostSales c = new HDT_SRV_DataEnrichmentPostSales();


        for (String caliber : caliberValues){

            String result = c.getCaliber(caliber);

            System.assert(!String.isBlank(result), 'result is blank for caliber: ' + caliber);

        }

        Test.stopTest();
        
    }

    @IsTest
    static void testGetOpzione(){

        
        List<String> options = new List<String>{'E_UD_TDR','E_UD_TDNR','E_MTIP','E_BTIP','E_MTA1','E_BTA1','E_MTA3','E_MTA2','E_BTA6','E_BTA5','E_BTA4','E_BTA3','E_BTA2','E_ALTA'};
        
        Test.startTest();

        HDT_SRV_DataEnrichmentPostSales c = new HDT_SRV_DataEnrichmentPostSales();

        for (String option : options){

            String result = c.getOpzione(option);
            System.assert(!String.isBlank(result), 'result is blank for option: ' + option);

        }

        Test.stopTest();
        
    }

    @IsTest
    static void testWriteBlockCode(){


        Case currentCase = [Select Id, Type FROM Case WHERE Type = 'Sollecito Emissione Bolletta'];

        Test.startTest();
        
        HDT_SRV_DataEnrichmentPostSales c = new HDT_SRV_DataEnrichmentPostSales();

        String result = c.writeBlockCode('Sap Valute Test', currentCase);

        System.assert(!String.isBlank(result), 'result is blank');

        Test.stopTest();
        
    }

    @IsTest
    static void testWriteCollectiveBillType(){


        Case currentCase = [Select Id, Type FROM Case WHERE Type = 'Unificazione/Separazione BP-CA-Bolletta'];

        Test.startTest();
        
        HDT_SRV_DataEnrichmentPostSales c = new HDT_SRV_DataEnrichmentPostSales();

        String result = c.writeCollectiveBillType('Sap Valute Test', currentCase);

        System.assert(!String.isBlank(result), 'result is blank');

        Test.stopTest();
        
    }

    @IsTest
    static void testPopulateCase(){
        
        Case currentCase = [Select Id, Type FROM Case WHERE Type = 'Unificazione/Separazione BP-CA-Bolletta'];

        Test.startTest();

        HDT_SRV_DataEnrichmentPostSales c = new HDT_SRV_DataEnrichmentPostSales();

        Map<String, Object> transcodeMap = new Map<String, Object>();
        transcodeMap.put('FirstName__c', 'Test');

        Case cs = c.populateCase(transcodeMap, currentCase);

        System.assertEquals('Test', cs.FirstName__c, 'cs.FirstName__c != Test');

        Test.stopTest();
        
    }

    //PROVVISORIO
    @isTest
    static void testHandleSubTyp() {
        Test.startTest();
        String checkHandleSub = HDT_SRV_DataEnrichmentPostSales.handleSubType('Hera S.p.A.','');
		System.assertEquals('Uso domestico non residente', checkHandleSub , 'testHandleSubTyp FALLITO');
		Test.stopTest();
    }

    @isTest
    static void testTransCodeSiNo0(){
        Test.startTest();
        String checkZero = HDT_SRV_DataEnrichmentPostSales.transCodeSiNo('0');
        System.assertEquals('No',checkZero,'testTransCodeSiNo0 Fallito');
        String checkOne = HDT_SRV_DataEnrichmentPostSales.transCodeSiNo('1');
        System.assertEquals('Si', checkOne, 'testTransCodeSiNo1 Fallito');
        String checkTwo = HDT_SRV_DataEnrichmentPostSales.transCodeSiNo('2');
        System.assertEquals('Si - Ridotta', checkTwo , 'testTransCodeSiNo2 Fallito');
        Test.stopTest();
   }



    //FINE Test method per classe HDT_SRV_DataEnrichmentPostSales

}