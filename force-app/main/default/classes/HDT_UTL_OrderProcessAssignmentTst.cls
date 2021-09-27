/**
 * @author Valere (valere@noeli-it.net)
 * @date 20/09/2021
 * @description HDT_UTL_OrderProcessAssignment Test Classes
 * @history valere - 20/09/2021– Created Class
 */
@isTest
private class HDT_UTL_OrderProcessAssignmentTst {

	@testSetup 
  static void setup() {
        
		List<Account> accountList= HDT_UTL_DataFactoryTst.createAccountResidenziale(1,true,'HERA COMM','Persona fisica','Famiglie');
      
    Id recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'HDT_RT_Gas' AND sObjectType = 'ServicePoint__c'].Id;

 
    List<ServicePoint__c> servicePointList= HDT_UTL_DataFactoryTst.createServicePoint(1,true,new Map<String,Object>{
      'servicePointCode'=>'code',
      'meterStatus'=>'Bozza',
      'accountId'=>accountList[0].id,
      'plugPresence'=>'NO',
      'powerRequested'=>2,
      'recordTypeId'=>recordTypeId,
      'commoditySector'=>'Gas'
    });
   

    List<wrts_prcgvr__Activity__c> activities= HDT_UTL_DataFactoryTst.createActivityCustom(1,true, new Map<String,Object>{
          'type'=>'Gestione Switch in Ripristinatorio',
          'status'=>'Creata',
          'accountId'=>accountList[0].id,
          'servicePointCode'=>'Code'
    });

    List<Order> firstOrderList= HDT_UTL_DataFactoryTst.createOrder(1, true, accountList[0].id,'Bozza');
    // Create a scale  
    List<Sale__c> saleList= HDT_UTL_DataFactoryTst.createSale(1, true, new Map<String,Object> {
      'transition'=>true,
      'status'=>'Bozza',
      'accountId'=>accountList[0].id
    });
    // create a quote 
     List<Opportunity> opp= HDT_UTL_DataFactoryTst.createOpportunity(1, true, new Map<String,Object>{
       'sale'=>saleList[0].id
     });
    List<SBQQ__Quote__c> quotes= HDT_UTL_DataFactoryTst.createQuote (1, true,new Map<String,Object>{
      'allowChangeUse'=>false,
      'amendmentAllowed'=>false,
      'type'=>'Quote',
      'orderId'=>firstOrderList[0].id,
      'opportunityId'=>opp[0].id,
      'saleId'=>saleList[0].id,
      'SBQQ__Primary'=>true
    });
    // createSaleServiceItem
    List<SaleServiceItem__c> saleServiceList= HDT_UTL_DataFactoryTst.createSaleServiceItem(1,true,opp[0].id, quotes[0].id,servicePointList[0].id);
    
    Opportunity opps=[select id,SBQQ__PrimaryQuote__c
                           FROM Opportunity WHERE  SBQQ__PrimaryQuote__c =: quotes[0].id
                            
                           LIMIT 1];
    
    List<Order> orderForAllTest= HDT_UTL_DataFactoryTst.createOrder(1,true, accountList[0].id,'Bozza',new Map<String,Object> {
      'servicePoint'=>servicePointList[0].id,
      'powerRequested'=>10,
      'SBQQ__Quote'=>quotes[0].id,
      'accountId'=>accountList[0].id
    });
  }
    
  @isTest
  static void testInitProcesses() {
      List<HDT_UTL_OrderProcessAssignment.HDT_WRP_Process> processes = HDT_UTL_OrderProcessAssignment.initProcesses();
      System.assertEquals(23, processes.size(),'we created 23  HDT_WRP_Process');
      System.assertNotEquals(2, processes.size(),'we have created more than two HDT_WRP_Process');
  }

  @isTest 
  static void testGetAvailableProcessesWithDevelopperNameGas() {
	  Order oneOrder = [select id,Name,AccountId,MarketOrigin__c,PowerRequested__c,PowerCommitted__c,IsWinback__c,
                      ServicePoint__r.MeterStatus__c,ServicePoint__r.Account__c, ServicePoint__r.PlugPresence__c,ServicePoint__r.ServicePointCode__c,
                      SBQQ__Quote__r.AllowChangeUse__c,SBQQ__Quote__r.AmendmentAllowed__c,ServicePoint__r.RecordType.DeveloperName,SBQQ__Quote__r.ContractReference__c
                      FROM Order 
                      WHERE PowerRequested__c=10];
      
    List<HDT_UTL_OrderProcessAssignment.HDT_WRP_Process> processes = HDT_UTL_OrderProcessAssignment.getAvailableProcesses(oneOrder);
    System.assertEquals(0, processes.size(),'there is no process available because there is no order that does not have a Ripristinatorio');
    System.assertNotEquals(2, processes.size(),'there is no process available because there is no order that does not have a Ripristinatorio');
  }

  @isTest 
  static void switchInRipristinatorioAction() {
      Order oneOrder = [select id,Name,AccountId,MarketOrigin__c,PowerRequested__c,PowerCommitted__c,IsWinback__c,
                      ServicePoint__r.MeterStatus__c,ServicePoint__r.Account__c, ServicePoint__r.PlugPresence__c,ServicePoint__r.ServicePointCode__c,
                      SBQQ__Quote__r.AllowChangeUse__c,SBQQ__Quote__r.AmendmentAllowed__c,ServicePoint__r.RecordType.DeveloperName,SBQQ__Quote__r.ContractReference__c
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
    System.assertEquals('Remi', field,' there is no ServicePoint linked to a sale');
    System.assertEquals('code', field,' there is no ServicePoint linked to a sale');
  }


}