/**
 * @author Valere (valere@noeli-it.net)
 * @date 20/09/2021
 * @description HDT_UTL_OrderProcessAssignment Test Classes
 * @history valere - 20/09/2021– Created Class
 */

@isTest
private class HDT_UTL_OrderProcessAssignmentTst {

  private static HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();

	@testSetup 
  static void setup() {
    HDT_UTL_DataFactoryTst.pClickInstance();
    HDT_UTL_DataFactoryTst.pClickOrderPhase();      
		List<Account> accountList= HDT_UTL_DataFactoryTst.createAccountResidenziale(1,true,'HERA COMM','Persona fisica','Famiglie');
 
    List<ServicePoint__c> servicePointList = HDT_UTL_DataFactoryTst.createServicePoint(1, false);
    servicePointList.get(0).MeterStatus__c = 'Bozza';
    servicePointList.get(0).Account__c= accountList[0].id;
    servicePointList.get(0).PlugPresence__c= 'NO';
    servicePointList.get(0).PowerRequested__c = 2;
    servicePointList.get(0).CommoditySector__c = 'Gas';
    servicePointList.get(0).RecordTypeId = utlConstants.SERVICEPOINT_RECORDTYPEID_GAS;
    servicePointList.get(0).SupplyCity__c = 'supplyCity';

    insert servicePointList;

    List<wrts_prcgvr__Activity__c> activities= HDT_UTL_DataFactoryTst.createActivityCustom(1, false, accountList.get(0).Id);
    activities.get(0).Type__c = 'Gestione Switch in Ripristinatorio';
    activities.get(0).wrts_prcgvr__Status__c = 'Creata';
    activities.get(0).ServicePointCode__c = servicePointList.get(0).ServicePointCode__c;

    insert activities;

    List<Order> firstOrderList = HDT_UTL_DataFactoryTst.createOrder(1, true, accountList[0].id,'Bozza');

    List<Sale__c> saleList = HDT_UTL_DataFactoryTst.createSale(1, false, accountList.get(0).Id, 'Bozza');
    saleList.get(0).isTransition__c = true;

    insert saleList;

    List<Opportunity> opp = HDT_UTL_DataFactoryTst.createOpportunity(1, false);
    opp.get(0).Sale__c = saleList[0].id;

    insert opp;

    List<SBQQ__Quote__c> quotes= HDT_UTL_DataFactoryTst.createQuote(1, false, firstOrderList[0].id, opp.get(0).Id, saleList.get(0).Id, 'Quote');
    quotes.get(0).AllowChangeUse__c = false;
    quotes.get(0).AmendmentAllowed__c = false;
    quotes.get(0).SBQQ__Primary__c = true;

    insert quotes;

    HDT_UTL_DataFactoryTst.createSaleServiceItem(1, true, opp[0].id, quotes[0].id,servicePointList[0].id);
    
    List<Order> orderForAllTest = HDT_UTL_DataFactoryTst.createOrder(1, false, accountList[0].id, 'Bozza');
    orderForAllTest.get(0).servicePoint__c = servicePointList.get(0).Id;
    orderForAllTest.get(0).powerRequested__c = 10;
    orderForAllTest.get(0).SBQQ__Quote__c = quotes[0].id;
    orderForAllTest.get(0).MarketOrigin__c = 'Libero';
    
    insert orderForAllTest;

    List<MatriceRemiCode__c> remiList = HDT_UTL_DataFactoryTst.createMatriceRemiCodeWithParams(1,false, new Map<String,Object> {
      'SalesCompany__c'=>'salesCompany',
      'Comune__c'=>'supplyCity'
    });

    remiList.addAll(HDT_UTL_DataFactoryTst.createMatriceRemiCodeWithParams(1,false, new Map<String,Object> {
      'SalesCompany__c'=>null,
      'SalesCompany__c'=>'supplyCity'
    }));

    insert remiList;

    HDT_UTL_DataFactoryTst.createService26Config(1,true);
    
    // create Profile and User
	
    User user = HDT_UTL_DataFactoryTst.createInternalUser(HDT_UTL_DataFactoryTst.getProfileId(utlConstants.SYSTEM_ADMINISTRATOR_NAME),true);

           
    //Create Custom setting 
	
    HDT_UTL_DataFactoryTst.createSalePartnerCommunity(user,true);

    ProcessMatrix__c process = new ProcessMatrix__c();
    process.CasualCode__c = 'SE1';
    process.Commodity__c = 'Gas';
    process.ContractStatus__c = 'null';
    process.ExistActivityDatiDiscordanti__c = false;
    process.ExistActivitySwitchRipristinatorio__c = true;
    process.IsAmendment__c = false;
    process.IsChangeUse__c = false;
    process.IsReseller__c = false;
    process.MarketOrigin__c = 'Default;FUI;Libero;Regolamentato;Salvaguardia';
    process.OngoingSwitchOut__c = false;
    process.PlugPresence__c = false;
    process.PowerChange__c = false;
    process.ProcessName__c = 'Test Process';
    process.RecordTypeName__c = 'HDT_RT_SwitchIn';
    process.isOwnAccount__c = 'Si';
    process.isSTG__c = false;

    insert process;
  }
  
  @isTest
  static void wrpTest()
  {
    Test.startTest();
      HDT_UTL_OrderProcessAssignment.HDT_WRP_Process processWrp = new HDT_UTL_OrderProcessAssignment.HDT_WRP_Process('test','test','tst',new Set<String>{'test'},new Set<String>{'test'},'Si',true,true,true,true,'test',true,true,true);
    Test.stopTest();
    System.assertEquals(true, processWrp != null, 'WRP Fallito');
  }

  @isTest 
  static void testGetAvailableProcessesWithDevelopperNameGas() {

    User user=[SELECT ProfileID FROM User WHERE Email='crmuser@test.com' LIMIT 1];
      
    system.runAs(user){
      Order oneOrder = [select id,Name,AccountId,MarketOrigin__c,PowerRequested__c,PowerCommitted__c,IsWinback__c,VoltageLevel__c,PowerAvailable__c,
      ServicePoint__r.MeterStatus__c,ServicePoint__r.Account__c, ServicePoint__r.PlugPresence__c,ServicePoint__r.ServicePointCode__c,
      SBQQ__Quote__r.AllowChangeUse__c,SBQQ__Quote__r.AmendmentAllowed__c,ServicePoint__r.RecordType.DeveloperName,SBQQ__Quote__r.ContractReference__c,
      ServicePoint__r.isReseller__c, ServicePoint__r.SapContractStatus__c,isSTG__c,ServicePoint__r.CommoditySector__c
      FROM Order 
      WHERE PowerRequested__c=10];

        List<ProcessMatrix__c> processes = HDT_UTL_OrderProcessAssignment.getAvailableProcesses(oneOrder);
        System.assertEquals(0, processes.size(),'there is no process available because there is no order that does not have a Ripristinatorio');
        System.assertNotEquals(2, processes.size(),'there is no process available because there is no order that does not have a Ripristinatorio');

    }
	  }

  @isTest 
  static void switchInRipristinatorioAction() {
      Order oneOrder = [select id,Name,AccountId,MarketOrigin__c,PowerRequested__c,PowerCommitted__c,IsWinback__c,
                      ServicePoint__r.MeterStatus__c,ServicePoint__r.Account__c, ServicePoint__r.PlugPresence__c,ServicePoint__r.ServicePointCode__c,
                      SBQQ__Quote__r.AllowChangeUse__c,SBQQ__Quote__r.AmendmentAllowed__c,ServicePoint__r.RecordType.DeveloperName,SBQQ__Quote__r.ContractReference__c,isSTG__c,
                      ServicePoint__r.CommoditySector__c
                      FROM Order 
                      WHERE PowerRequested__c=10];

                      HDT_UTL_OrderProcessAssignment.switchInRipristinatorioAction(oneOrder);

     System.assertEquals(1, [SELECT count() FROM wrts_prcgvr__Activity__c WHERE Order__c=: oneOrder.id], ' we only have one update wrts_prcgvr__Activity__c ');	
     System.assertNotEquals(3, [SELECT count() FROM wrts_prcgvr__Activity__c WHERE Order__c=: oneOrder.id], ' we only have one update wrts_prcgvr__Activity__c ');	
      
  }

  @isTest 
  static void testFieldsTransition() {     
    Sale__c sale = [SELECT Id FROM Sale__c WHERE Name='testSaleName0' LIMIT 1];
    String field = HDT_UTL_OrderProcessAssignment.fieldsTransition(sale);
  
    System.assertEquals('Subentro_Remi', field,' the service point has a CommoditySector equal to GAS and a MeterStatus different from Attivo');
    System.assertNotEquals('code', field,' the service point has a CommoditySector equal to GAS and a MeterStatus different from Attivo');
  }

  

  @isTest 
  static void testGetFamilySconto(){   
    Set<String> familySconto = HDT_UTL_OrderProcessAssignment.getFamilySconto();

    System.assertEquals(true, familySconto.contains('Bonus Eur/Giorno'),' there is no ServicePoint linked to a sale');
    System.assertNotEquals(false, familySconto.contains('Bonus Eur/Giorno'),' there is no ServicePoint linked to a sale');
  
  }



}