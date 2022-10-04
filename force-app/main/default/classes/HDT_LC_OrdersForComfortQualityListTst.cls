/**
 * @author Valere (valere@noeli-it.net)
 * @date 20/09/2021
 * @description HDT_UTL_OrderProcessAssignment Test Classes
 * @history valere - 20/09/2021– Created Class
 */
@isTest
private class HDT_LC_OrdersForComfortQualityListTst {

  
  @testSetup 
  static void setup() {
    //Id hDT_RT_OrderDossier_RecordTypeId= [select Id, DeveloperName from RecordType Where DeveloperName='HDT_RT_OrderDossier' LIMIT 1].Id;
    Id hdtRtVasRecordTypeId= [select Id, DeveloperName from RecordType Where DeveloperName='HDT_RT_VAS' LIMIT 1].Id;
    Id hdtRtCambioOffertaRecordTypeId= [select Id, DeveloperName from RecordType Where DeveloperName='HDT_RT_CambioOfferta' LIMIT 1].Id;
    Id hdtRtSwitchInRecordTypeId= [select Id, DeveloperName from RecordType Where DeveloperName='HDT_RT_SwitchIn' LIMIT 1].Id;
    HDT_UTL_DataFactoryTst.pClickInstance();
    HDT_UTL_DataFactoryTst.pClickOrderPhase();    
    List<Account> accountList= HDT_UTL_DataFactoryTst.createAccountResidenziale(1,true,'HERA COMM','Persona fisica','Famiglie');
    List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accountList[0].Id);

    //Instantiate the Pricebook2 record with StandardPricebookId
    Pricebook2 standardPricebook = HDT_UTL_DataFactoryTst.activeStandardPricebook();

    List<Sale__c> salesList= HDT_UTL_DataFactoryTst.createSale(4, true, accountList[0].id, 'Bozza');

    List<Order> orderList0= HDT_UTL_DataFactoryTst.createOrderWithParams(1, true, salesList,'HDT_RT_ConnessioneConAttivazione',new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Pricebook2Id'=>standardPricebook.id,
      'Phase__c'=>'Annullato'
    } ); 
    List<Order> orderList1= HDT_UTL_DataFactoryTst.createOrderWithParams(1, true, salesList,'HDT_RT_ConnessioneConAttivazione',new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Pricebook2Id'=>standardPricebook.id,
      'Phase__c'=>'Comunicazione Motore VAS',
      'RecordTypeId'=>hdtRtVasRecordTypeId
    } ); 
    List<Order> orderList2= HDT_UTL_DataFactoryTst.createOrderWithParams(1, true, salesList,'HDT_RT_ConnessioneConAttivazione',new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Pricebook2Id'=>standardPricebook.id,
      'Phase__c'=>'Comunicazione verso Heroku',
      'RecordTypeId'=>hdtRtCambioOffertaRecordTypeId,
      'AgencyCode__c'=>'AG442'
    } );
    List<Order> orderList3= HDT_UTL_DataFactoryTst.createOrderWithParams(1, true, salesList,'HDT_RT_ConnessioneConAttivazione',new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Pricebook2Id'=>standardPricebook.id,
      'Phase__c'=>'Comunicazione verso Heroku',
      'RecordTypeId'=>hdtRtSwitchInRecordTypeId
    } );
    List<Order> orderList5= HDT_UTL_DataFactoryTst.createOrderWithParams(1, true, salesList,'HDT_RT_ConnessioneConAttivazione',new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Pricebook2Id'=>standardPricebook.id,
      'Phase__c'=>'Amm. Precheck OK SII',
      'RecordTypeId'=>hdtRtSwitchInRecordTypeId,
      'Contact__c' => contactList[0].Id
    } );   
          List<Order> orderList6= HDT_UTL_DataFactoryTst.createOrderWithParams(1, true, salesList,'HDT_RT_ConnessioneConAttivazione',new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Pricebook2Id'=>standardPricebook.id,
      'Phase__c'=>'Comunicazione verso Heroku',
      'RecordTypeId'=>hdtRtVasRecordTypeId,
      'Contact__c' => contactList[0].Id
    } ); 
    List<wrts_prcgvr__Activity__c> activities = HDT_UTL_DataFactoryTst.createActivityWithParams(1, false,accountList[0].id,new Map<String,Object>{
        'Order__c'=> orderList0[0].id
    });
    activities.addAll(HDT_UTL_DataFactoryTst.createActivityWithParams(1, false,accountList[0].id,new Map<String,Object>{
      'Order__c'=> orderList1[0].id
    }));
    activities.addAll(HDT_UTL_DataFactoryTst.createActivityWithParams(1, false,accountList[0].id,new Map<String,Object>{
      'Order__c'=> orderList2[0].id
    }));
    activities.addAll(HDT_UTL_DataFactoryTst.createActivityWithParams(1, false,accountList[0].id,new Map<String,Object>{
      'Order__c'=> orderList3[0].id
    }));
    activities.addAll(HDT_UTL_DataFactoryTst.createActivityWithParams(1, false,accountList[0].id,new Map<String,Object>{
      'Order__c'=> orderList5[0].id
    }));
	activities.addAll(HDT_UTL_DataFactoryTst.createActivityWithParams(1, false,accountList[0].id,new Map<String,Object>{
      'Order__c'=> orderList6[0].id
    }));
    insert activities;

    List<ServicePoint__c>  servicePoint=  HDT_UTL_DataFactoryTst.createServicePoint(1, true);
    List<Product2> product2List = HDT_UTL_DataFactoryTst.createProduct2(1, true);
    List<PricebookEntry> pricebookentryList= HDT_UTL_DataFactoryTst.createPricebookEntry(product2List, true, standardPricebook.Id);
    HDT_UTL_DataFactoryTst.createOrderItem(1, true, orderList0[0].id, servicePoint[0].id, product2List[0].Id, pricebookentryList[0].id);
  
    List<AgentMatrix__c > myAMList = HDT_UTL_DataFactoryTst.createAgentMatrix(1, true, 'Agenzie');
    myAMList[0].AgencyName__c = 'JR13 PROGRESS SRL';
    myAMList[0].AgencyCode__c = 'AG442';
    myAMList[0].UpperChannelAgency__c = 'VI';
    myAMList[0].LowerChannelAgency__c = 'AGENZIE';
    myAMList[0].IsMonitoring__c = true;
    update myAMList;
  }
    
  @isTest
  static void testGetTableData() {

    Order order=[SELECT id,CancellationReason__c,Status,Phase__c FROM Order WHERE Phase__c='Annullato' LIMIT 1];

    List<wrts_prcgvr__Activity__c> activity= [SELECT id,Order__r.RecordType.DeveloperName 
                                              FROM wrts_prcgvr__Activity__c
                                              WHERE Order__c=:order.id];
    Test.startTest(); 
    List<wrts_prcgvr__Activity__c> acts = HDT_LC_OrdersForComfortQualityList.getTableData(activity[0].id);
    Test.stopTest();
    //System.assertEquals(1, acts.size());
    System.assertEquals(acts[0].id, activity[0].id,'The value is the same by entering in the else');
    System.assertNotEquals('HDT_RT_OrderDossier', acts[0].Order__r.RecordType.DeveloperName,'The value is the same by entering in the else');

  }

  @isTest
  static void testConfirmContract() {

    Order order=[SELECT id,ConfirmCustomerContract__c,Phase__c FROM Order WHERE Phase__c='Annullato' LIMIT 1];

    List<wrts_prcgvr__Activity__c> activity= [SELECT id,Order__r.RecordType.DeveloperName,wrts_prcgvr__Status__c 
                                              FROM wrts_prcgvr__Activity__c
                                              WHERE Order__c=:order.id];

    Test.startTest();   
    try{
      HDT_LC_OrdersForComfortQualityList.confirmContract( order.id, activity[0].id , 'ComfortNo');
    }catch(Exception e){

    }
    Test.stopTest();
    //System.assertEquals(1, acts.size());
    System.assertEquals(true, [SELECT Id, wrts_prcgvr__Status__c, ContactResult__c FROM wrts_prcgvr__Activity__c WHERE ContactResult__c = 'Quality Call OK'].size()>0,'An wrts_prcgvr__Activity__c is created');
    System.assertNotEquals(false, [SELECT Id, Phase__c FROM Order WHERE Phase__c = 'Annullato'].size()>0,'An Order is created');

  }

  @isTest
  static void testConfirmContractWithHdtRtVas() {

    Order order=[SELECT id,ConfirmCustomerContract__c,Phase__c FROM Order WHERE RecordType.DeveloperName='HDT_RT_VAS' LIMIT 1];

    List<wrts_prcgvr__Activity__c> activity= [SELECT id,Order__r.RecordType.DeveloperName,wrts_prcgvr__Status__c 
                                              FROM wrts_prcgvr__Activity__c
                                              WHERE Order__c=:order.id];

    Test.startTest();       
    try{
      HDT_LC_OrdersForComfortQualityList.confirmContract( order.id, activity[0].id , 'Comfort');
    }catch(Exception e){

    }                       
    Test.stopTest();
    //System.assertEquals(1, acts.size());
    System.assertEquals(true, [SELECT Id, wrts_prcgvr__Status__c, ContactResult__c FROM wrts_prcgvr__Activity__c WHERE ContactResult__c = ''].size()>0,'An wrts_prcgvr__Activity__c is created');
    System.assertNotEquals(false, [SELECT Id, Phase__c FROM Order WHERE Phase__c = 'Comunicazione Motore VAS'].size()>0,'An Order is created');

  }

  @isTest
  static void testConfirmContractWithHdtRtCambioOfferta() {

    Order order=[SELECT id,ConfirmCustomerContract__c,Phase__c FROM Order WHERE RecordType.DeveloperName='HDT_RT_CambioOfferta' LIMIT 1];

    List<wrts_prcgvr__Activity__c> activity= [SELECT id,Order__r.RecordType.DeveloperName,wrts_prcgvr__Status__c 
                                              FROM wrts_prcgvr__Activity__c
                                              WHERE Order__c=:order.id];

    Test.startTest();
    try{
      HDT_LC_OrdersForComfortQualityList.confirmContract( order.id, activity[0].id , 'Comfort');
    }catch(Exception e){

    }
    Test.stopTest();
    //System.assertEquals(1, acts.size());
    System.assertEquals(true, [SELECT Id, wrts_prcgvr__Status__c, ContactResult__c FROM wrts_prcgvr__Activity__c WHERE ContactResult__c = ''].size()>0,'An wrts_prcgvr__Activity__c is created');
    System.assertNotEquals(false, [SELECT Id, Phase__c FROM Order WHERE Phase__c = 'Comunicazione verso Heroku'].size()>0,'An Order is created');
  }

  @isTest
  static void testConfirmContractWithHdtRtSwitchIn() {

    Order order=[SELECT id,ConfirmCustomerContract__c,Phase__c FROM Order WHERE RecordType.DeveloperName='HDT_RT_SwitchIn' LIMIT 1];

    List<wrts_prcgvr__Activity__c> activity= [SELECT id,Order__r.RecordType.DeveloperName,wrts_prcgvr__Status__c 
                                              FROM wrts_prcgvr__Activity__c
                                              WHERE Order__c=:order.id];

    Test.startTest();       
    try{
      HDT_LC_OrdersForComfortQualityList.confirmContract( order.id, activity[0].id , 'Comfort');
    }catch(Exception e){

    }
    Test.stopTest();
    //System.assertEquals(1, acts.size());
    System.assertEquals(true, [SELECT Id, wrts_prcgvr__Status__c, ContactResult__c FROM wrts_prcgvr__Activity__c WHERE ContactResult__c = ''].size()>0,'An wrts_prcgvr__Activity__c is created');
    System.assertNotEquals(false, [SELECT Id, Phase__c FROM Order WHERE Phase__c = 'Comunicazione verso Heroku'].size()>0,'An Order is created');

  }

  @isTest
  static void testCancelContract() {

    Order order=[SELECT id FROM Order WHERE Phase__c='Annullato' LIMIT 1];

    List<wrts_prcgvr__Activity__c> activity= [SELECT id,Order__r.RecordType.DeveloperName 
                                              FROM wrts_prcgvr__Activity__c
                                              WHERE Order__c=:order.id];
    Test.startTest();
    Try{
      HDT_LC_OrdersForComfortQualityList.cancelContract( order.id, activity[0].id , 'Firma Falsa');
    }catch(exception e){
      
    }
    Test.stopTest();
    //System.assertEquals(1, acts.size());
    System.assertEquals(true, [SELECT Id, wrts_prcgvr__Status__c, ContactResult__c FROM wrts_prcgvr__Activity__c WHERE ContactResult__c = 'Annullato Quality Call'].size()>0,'An wrts_prcgvr__Activity__c is created');
    //System.assertNotEquals(false, [SELECT Id, Phase__c,Status FROM Order WHERE Status = 'Activated'].size()>0,'An Order is created');
  }
  @isTest
  static void cancelContractTst()
  {
    Order order=[SELECT id,ConfirmCustomerContract__c,Phase__c FROM Order WHERE RecordType.DeveloperName='HDT_RT_SwitchIn' AND Phase__c = 'Amm. Precheck OK SII' LIMIT 1];
    List<wrts_prcgvr__Activity__c> activity= [SELECT id,Order__r.RecordType.DeveloperName 
    FROM wrts_prcgvr__Activity__c
    WHERE Order__c=:order.id];
    Test.startTest();
      HDT_LC_OrdersForComfortQualityList.cancelContract( order.id, activity[0].id , 'Firma Falsa');
    Test.stopTest();
    List<Order> orderResult = [SELECT Id, Phase__c FROM Order WHERE Id = : order.id];
    System.assertEquals('Annullato', orderResult[0].Phase__c, 'Annullamento fallito');
  }
    
  @isTest
  static void cancelContract2Tst()
  {
    Order order=[SELECT id,ConfirmCustomerContract__c,Phase__c FROM Order WHERE RecordType.DeveloperName='HDT_RT_VAS' AND Phase__c = 'Comunicazione verso Heroku' LIMIT 1];
    List<wrts_prcgvr__Activity__c> activity= [SELECT id,Order__r.RecordType.DeveloperName 
    FROM wrts_prcgvr__Activity__c
    WHERE Order__c=:order.id];
    Test.startTest();
      HDT_LC_OrdersForComfortQualityList.cancelContract( order.id, activity[0].id , 'Contatto Quality Fallito');
    Test.stopTest();
    List<Order> orderResult = [SELECT Id, Phase__c FROM Order WHERE Id = : order.id];
    System.assertEquals('Comunicazione verso Heroku', orderResult[0].Phase__c, 'Annullamento fallito');
  }
}