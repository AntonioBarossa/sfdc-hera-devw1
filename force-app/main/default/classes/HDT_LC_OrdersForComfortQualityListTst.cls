/**
 * @author Valere (valere@noeli-it.net)
 * @date 20/09/2021
 * @description HDT_UTL_OrderProcessAssignment Test Classes
 * @history valere - 20/09/2021– Created Class
 */


 
@isTest
private class HDT_LC_OrdersForComfortQualityListTst {

  public static List<Order> createOrderWithPricebookWithPhase(Integer amount, Boolean doInsert, List<Sale__c> sales, Map<String,Object> params){

		List<Order> orderList=new List<Order>();

		for (Integer i=0; i<amount; i++){

			Order ord=new Order();

			ord.Name='testOrderName'+i;
			ord.Status='Draft';
			ord.EffectiveDate=Date.today();
			ord.AccountId=(String)params.get('AccountId');
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
			ord.Pricebook2Id=(String)params.get('Pricebook2Id');
			ord.Phase__c=(String)params.get('Phase__c');
			ord.RecordTypeId=(String)params.get('RecordTypeId');

			orderList.add(ord);
		}

		if (doInsert){

			insert orderList;
		}

		return orderList;
	}

  
    public static List<wrts_prcgvr__Activity__c> createActivityCustom(Integer amount, Boolean doInsert, Id accId,Map<String,Object> params){

		List<wrts_prcgvr__Activity__c> activityCustomList=new List<wrts_prcgvr__Activity__c>();
    
		for (Integer i=0; i<amount; i++){

			wrts_prcgvr__Activity__c actCustom=new wrts_prcgvr__Activity__c();

			actCustom.Account__c=accId;
      actCustom.Order__c=(String)params.get('orderId');


			activityCustomList.add(actCustom);
		}

		if (doInsert){

			insert activityCustomList;
		}

		return activityCustomList;
	}


    @testSetup 
  static void setup() {
    //Id hDT_RT_OrderDossier_RecordTypeId= [select Id, DeveloperName from RecordType Where DeveloperName='HDT_RT_OrderDossier' LIMIT 1].Id;
    Id hDT_RT_VAS_RecordTypeId= [select Id, DeveloperName from RecordType Where DeveloperName='HDT_RT_VAS' LIMIT 1].Id;
    Id hDT_RT_CambioOfferta_RecordTypeId= [select Id, DeveloperName from RecordType Where DeveloperName='HDT_RT_CambioOfferta' LIMIT 1].Id;
    Id hDT_RT_SwitchIn_RecordTypeId= [select Id, DeveloperName from RecordType Where DeveloperName='HDT_RT_SwitchIn' LIMIT 1].Id;
    HDT_UTL_DataFactoryTst.pClickInstance();
    HDT_UTL_DataFactoryTst.pClickOrderPhase();    
    List<Account> accountList= HDT_UTL_DataFactoryTst.createAccountResidenziale(1,true,'HERA COMM','Persona fisica','Famiglie');

    //Instantiate the Pricebook2 record with StandardPricebookId
    Pricebook2 standardPricebook = new Pricebook2(
              Id = Test.getStandardPricebookId(),
              IsActive = true
    );
    Update standardPricebook;

    List<Sale__c> salesList= HDT_UTL_DataFactoryTst.createSale(4, true, accountList[0].id, 'Bozza');

    List<Order> orderList0= createOrderWithPricebookWithPhase(1, true, salesList,new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Pricebook2Id'=>standardPricebook.id,
      'Phase__c'=>'Annullato',
      'RecordTypeId'=>null
  } ); 
  List<Order> orderList1= createOrderWithPricebookWithPhase(1, true, salesList,new Map<String,Object>{
    'AccountId'=>accountList[0].id,
    'Pricebook2Id'=>standardPricebook.id,
    'Phase__c'=>'Comunicazione Motore VAS',
    'RecordTypeId'=>hDT_RT_VAS_RecordTypeId
} ); 
List<Order> orderList2= createOrderWithPricebookWithPhase(1, true, salesList,new Map<String,Object>{
  'AccountId'=>accountList[0].id,
  'Pricebook2Id'=>standardPricebook.id,
  'Phase__c'=>'Comunicazione verso Heroku',
  'RecordTypeId'=>hDT_RT_CambioOfferta_RecordTypeId
} );
List<Order> orderList3= createOrderWithPricebookWithPhase(1, true, salesList,new Map<String,Object>{
  'AccountId'=>accountList[0].id,
  'Pricebook2Id'=>standardPricebook.id,
  'Phase__c'=>'Comunicazione verso Heroku',
  'RecordTypeId'=>hDT_RT_SwitchIn_RecordTypeId
} );    
    //orderList[0].RecordTypeId=hDT_RT_OrderDossier_RecordTypeId;
    // orderList[0].Phase__c='Annullato';
    // orderList[1].RecordTypeId=hDT_RT_VAS_RecordTypeId;
    // orderList[1].Phase__c='Comunicazione Motore VAS';
    // orderList[2].RecordTypeId=hDT_RT_CambioOfferta_RecordTypeId;
    // orderList[2].Phase__c='Comunicazione verso Heroku';
    // orderList[3].RecordTypeId=hDT_RT_SwitchIn_RecordTypeId;
    // orderList[3].Phase__c='Comunicazione verso Heroku';
    // insert orderList;
    //List<Order> orderList= HDT_UTL_DataFactoryTst.createOrder(1, true, accountList[0].id,'Bozza');
    List<wrts_prcgvr__Activity__c> activity0=createActivityCustom(1, true,accountList[0].id,new Map<String,Object>{
        'orderId'=> orderList0[0].id
    });
    List<wrts_prcgvr__Activity__c> activity1=createActivityCustom(1, true,accountList[0].id,new Map<String,Object>{
      'orderId'=> orderList1[0].id
    });
    List<wrts_prcgvr__Activity__c> activity2=createActivityCustom(1, true,accountList[0].id,new Map<String,Object>{
      'orderId'=> orderList2[0].id
    });
    List<wrts_prcgvr__Activity__c> activity3=createActivityCustom(1, true,accountList[0].id,new Map<String,Object>{
      'orderId'=> orderList3[0].id
    });
    List<ServicePoint__c>  servicePoint=  HDT_UTL_DataFactoryTst.createServicePoint(1, true);
    List<Product2> Product2List = HDT_UTL_DataFactoryTst.createProduct2(1, true);
    List<PricebookEntry> pricebookentryList= HDT_UTL_DataFactoryTst.createPricebookEntry(Product2List, true, standardPricebook.Id);
    List<OrderItem> orderItem= HDT_UTL_DataFactoryTst.createOrderItem(1, true, orderList0[0].id, servicePoint[0].id, Product2List[0].Id, pricebookentryList[0].id);

    
       
   
}
    
  @isTest
  static void testGetTableData() {

    Order order=[SELECT id,CancellationReason__c,Status,Phase__c FROM Order WHERE Phase__c='Annullato' LIMIT 1];

    List<wrts_prcgvr__Activity__c> activity= [SELECT id,Order__r.RecordType.DeveloperName 
                                              FROM wrts_prcgvr__Activity__c
                                              WHERE Order__c=:order.id];
    
    List<wrts_prcgvr__Activity__c> acts = HDT_LC_OrdersForComfortQualityList.getTableData(activity[0].id);
    //System.assertEquals(1, acts.size());
    System.assertEquals(acts[0].id, activity[0].id,'The value is the same by entering in the else');
    System.assertNotEquals('HDT_RT_OrderDossier', acts[0].Order__r.RecordType.DeveloperName,'The value is the same by entering in the else');

  }


  @isTest
  static void testConfirmContract() {

    Order order=[SELECT id,ConfirmCustomerContract__c,Phase__c FROM Order WHERE Phase__c='Annullato' LIMIT 1];

    List<wrts_prcgvr__Activity__c> activity= [SELECT id,Order__r.RecordType.DeveloperName,Status__c 
                                              FROM wrts_prcgvr__Activity__c
                                              WHERE Order__c=:order.id];


    
                                          
    HDT_LC_OrdersForComfortQualityList.confirmContract( order.id, activity[0].id , 'ComfortNo');

    //System.assertEquals(1, acts.size());
    System.assertEquals(true, [SELECT Id, Status__c, ContactResult__c FROM wrts_prcgvr__Activity__c WHERE ContactResult__c = 'Quality Call OK'].size()>0,'An wrts_prcgvr__Activity__c is created');
    System.assertNotEquals(false, [SELECT Id, Phase__c FROM Order WHERE Phase__c = 'Annullato'].size()>0,'An Order is created');

  }


  @isTest
  static void testConfirmContractWithHDT_RT_VAS() {

    Order order=[SELECT id,ConfirmCustomerContract__c,Phase__c FROM Order WHERE RecordType.DeveloperName='HDT_RT_VAS' LIMIT 1];

    List<wrts_prcgvr__Activity__c> activity= [SELECT id,Order__r.RecordType.DeveloperName,Status__c 
                                              FROM wrts_prcgvr__Activity__c
                                              WHERE Order__c=:order.id];


    
                                          
    HDT_LC_OrdersForComfortQualityList.confirmContract( order.id, activity[0].id , 'Comfort');

    //System.assertEquals(1, acts.size());
    System.assertEquals(true, [SELECT Id, Status__c, ContactResult__c FROM wrts_prcgvr__Activity__c WHERE ContactResult__c = ''].size()>0,'An wrts_prcgvr__Activity__c is created');
    System.assertNotEquals(false, [SELECT Id, Phase__c FROM Order WHERE Phase__c = 'Comunicazione Motore VAS'].size()>0,'An Order is created');

  }

  @isTest
  static void testConfirmContractWithHDT_RT_CambioOfferta() {

    Order order=[SELECT id,ConfirmCustomerContract__c,Phase__c FROM Order WHERE RecordType.DeveloperName='HDT_RT_CambioOfferta' LIMIT 1];

    List<wrts_prcgvr__Activity__c> activity= [SELECT id,Order__r.RecordType.DeveloperName,Status__c 
                                              FROM wrts_prcgvr__Activity__c
                                              WHERE Order__c=:order.id];


    
                                          
    HDT_LC_OrdersForComfortQualityList.confirmContract( order.id, activity[0].id , 'Comfort');

    //System.assertEquals(1, acts.size());
    System.assertEquals(true, [SELECT Id, Status__c, ContactResult__c FROM wrts_prcgvr__Activity__c WHERE ContactResult__c = ''].size()>0,'An wrts_prcgvr__Activity__c is created');
    System.assertNotEquals(false, [SELECT Id, Phase__c FROM Order WHERE Phase__c = 'Comunicazione verso Heroku'].size()>0,'An Order is created');

  }

  @isTest
  static void testConfirmContractWithHDT_RT_SwitchIn() {

    Order order=[SELECT id,ConfirmCustomerContract__c,Phase__c FROM Order WHERE RecordType.DeveloperName='HDT_RT_SwitchIn' LIMIT 1];

    List<wrts_prcgvr__Activity__c> activity= [SELECT id,Order__r.RecordType.DeveloperName,Status__c 
                                              FROM wrts_prcgvr__Activity__c
                                              WHERE Order__c=:order.id];


    
                                          
    HDT_LC_OrdersForComfortQualityList.confirmContract( order.id, activity[0].id , 'Comfort');

    //System.assertEquals(1, acts.size());
    System.assertEquals(true, [SELECT Id, Status__c, ContactResult__c FROM wrts_prcgvr__Activity__c WHERE ContactResult__c = ''].size()>0,'An wrts_prcgvr__Activity__c is created');
    System.assertNotEquals(false, [SELECT Id, Phase__c FROM Order WHERE Phase__c = 'Comunicazione verso Heroku'].size()>0,'An Order is created');

  }

  @isTest
  static void testCancelContract() {

    Order order=[SELECT id FROM Order WHERE Phase__c='Annullato' LIMIT 1];

    List<wrts_prcgvr__Activity__c> activity= [SELECT id,Order__r.RecordType.DeveloperName 
                                              FROM wrts_prcgvr__Activity__c
                                              WHERE Order__c=:order.id];
    
    HDT_LC_OrdersForComfortQualityList.cancelContract( order.id, activity[0].id , 'Annullo voltura');
    
    //System.assertEquals(1, acts.size());
    System.assertEquals(true, [SELECT Id, Status__c, ContactResult__c FROM wrts_prcgvr__Activity__c WHERE ContactResult__c = 'Annullato'].size()>0,'An wrts_prcgvr__Activity__c is created');
    System.assertNotEquals(false, [SELECT Id, Phase__c,Status FROM Order WHERE Status = 'Activated'].size()>0,'An Order is created');

  }
 
 

  


}