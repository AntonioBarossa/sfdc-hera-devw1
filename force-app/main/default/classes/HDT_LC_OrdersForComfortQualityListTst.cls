/**
 * @author Valere (valere@noeli-it.net)
 * @date 20/09/2021
 * @description HDT_UTL_OrderProcessAssignment Test Classes
 * @history valere - 20/09/2021– Created Class
 */


 
@isTest
private class HDT_LC_OrdersForComfortQualityListTst {

    
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
    List<Account> accountList= HDT_UTL_DataFactoryTst.createAccountResidenziale(1,true,'HERA COMM','Persona fisica','Famiglie');

    List<Order> orderList= HDT_UTL_DataFactoryTst.createOrder(1, true, accountList[0].id,'Bozza');


    List<wrts_prcgvr__Activity__c> activity=createActivityCustom(1, true,accountList[0].id,new Map<String,Object>{
        'orderId'=> orderList[0].id
    });
    
    
    
    
   
}
    
  @isTest
  static void testGetTableData() {

    Order order=[SELECT id,CancellationReason__c,Status,Phase__c FROM Order];

    List<wrts_prcgvr__Activity__c> activity= [SELECT id,Order__r.RecordType.DeveloperName 
                                              FROM wrts_prcgvr__Activity__c
                                              WHERE Order__c=:order.id];
    
    List<wrts_prcgvr__Activity__c> acts = HDT_LC_OrdersForComfortQualityList.getTableData(activity[0].id);
    System.assertEquals(1, acts.size());
  }


  @isTest
  static void testConfirmContract() {

    Order order=[SELECT id,ConfirmCustomerContract__c,Phase__c FROM Order];

    List<wrts_prcgvr__Activity__c> activity= [SELECT id,Order__r.RecordType.DeveloperName,Status__c 
                                              FROM wrts_prcgvr__Activity__c
                                              WHERE Order__c=:order.id];


    
                                          
    HDT_LC_OrdersForComfortQualityList.confirmContract( order.id, activity[0].id , 'Comfort');

    //System.assertEquals(1, acts.size());
  }


  @isTest
  static void testCancelContract() {

    Order order=[SELECT id FROM Order];

    List<wrts_prcgvr__Activity__c> activity= [SELECT id,Order__r.RecordType.DeveloperName 
                                              FROM wrts_prcgvr__Activity__c
                                              WHERE Order__c=:order.id];
    
    HDT_LC_OrdersForComfortQualityList.cancelContract( order.id, activity[0].id , 'Annullo voltura');
    
    //System.assertEquals(1, acts.size());
  }
 
 

  


}