/**
 * @author Valere (valere@noeli-it.net)
 * @date 20/09/2021
 * @description HDT_SRV_SalesHandler Test Classes
 * @history valere - 20/09/2021– Created Class
 */
@isTest
private class HDT_SRV_SalesHandlerTst {

  class TestBuilderCallManageSalesProcessCategory{//Built to avoid calling the manageSalesProcessCategory in different 
    // test method that would generate an exception on method already tested
    // basically, we called the same method in different isTest method to avoid too many queries exception
    public TestBuilderCallManageSalesProcessCategory(Order order,String phase, String requestType,Map<String,Boolean> paramsBool){//withoutObjects==true will trigger an error to test failing cases
      if(paramsBool==null) {
         paramsBool=new Map<String,Boolean>{'withRunId'=>false,'withoutObjects'=>false,'withImpPrevDist'=>false,'withDesErrAeeg'=>false};
      }
        RestResponse res = new RestResponse();
        res.statusCode = 200;
        RestContext.response = res;
        
        HDT_WRP_MrrRequest.HDT_WRP_Request request=new HDT_WRP_MrrRequest.HDT_WRP_Request();
        HDT_WRP_MrrRequest.HDT_WRP_Header header=new HDT_WRP_MrrRequest.HDT_WRP_Header();
        header.requestType=requestType;
		    HDT_WRP_MrrRequest.HDT_WRP_Field field=new HDT_WRP_MrrRequest.HDT_WRP_Field();
        HDT_WRP_MrrRequest.HDT_WRP_Field field3=new HDT_WRP_MrrRequest.HDT_WRP_Field();
     // For Pass the RICH_PASS and NOTIF_ES else    
        if(requestType=='RICH_PASS'||requestType=='NOTIF_ES'){
          field.name='ATTIVITA';
          field.value=null;
        } 
        else{
        // create fields
          field.name='ATTIVITA';
          field.value='Gestione Switch in Ripristinatorio';
          field3.name='CODERR_AEEG';
          field3.value='032';
          if(phase=='Ammissibilità OK'){
            field3.value='034';
        	}
      	}
        HDT_WRP_MrrRequest.HDT_WRP_Field field1=new HDT_WRP_MrrRequest.HDT_WRP_Field();
        field1.name='RECORD_ID';
        field1.value=order.Id;
        HDT_WRP_MrrRequest.HDT_WRP_Field field2=new HDT_WRP_MrrRequest.HDT_WRP_Field();
        field2.name='FASE';
        field2.value=phase;
        HDT_WRP_MrrRequest.HDT_WRP_Field field4=new HDT_WRP_MrrRequest.HDT_WRP_Field();
        field4.name='IMP_PREV_DIST';
        field4.value='10';
        HDT_WRP_MrrRequest.HDT_WRP_Field field5=new HDT_WRP_MrrRequest.HDT_WRP_Field();
        field5.name='TEMP_ES_PREV';
        field5.value='10';
        HDT_WRP_MrrRequest.HDT_WRP_Field field6=new HDT_WRP_MrrRequest.HDT_WRP_Field();
        field6.name='TIPO_INTERVENTO';
        field6.value='Attivazione';
        
        HDT_WRP_MrrRequest.HDT_WRP_Field field7=new HDT_WRP_MrrRequest.HDT_WRP_Field();
        field7.name='DES_ERR_AEEG';
        field7.value='OK';
        HDT_WRP_MrrRequest.HDT_WRP_Field field8=new HDT_WRP_MrrRequest.HDT_WRP_Field();
        field8.name='VKONT';
        field8.value='Compl';
        HDT_WRP_MrrRequest.HDT_WRP_Field field9=new HDT_WRP_MrrRequest.HDT_WRP_Field();
        field9.name='DT_CREA';
        field9.value='2021-06-01';
        HDT_WRP_MrrRequest.HDT_WRP_Field field10=new HDT_WRP_MrrRequest.HDT_WRP_Field();
          //if(requestType!='SIE34_1' && requestType!='SIE34_2' && requestType!='SIE34_3' && requestType!='SIE34_6' && requestType!='SIE34_7'){//to avoid entering into a block that enqueues Jobs
        field10.name='runId';
        field10.value='runId00';
          //}
        HDT_WRP_MrrRequest.HDT_WRP_Field field11=new HDT_WRP_MrrRequest.HDT_WRP_Field();
        if(requestType=='NOTIF_ES'){
            field11.name='CODERR_ES';
            field11.value='003';
          }
        HDT_WRP_MrrRequest.HDT_WRP_Field field12=new HDT_WRP_MrrRequest.HDT_WRP_Field();
        field12.name='COD_FLUSSO';
        field12.value='E150F';
        HDT_WRP_MrrRequest.HDT_WRP_Field field13=new HDT_WRP_MrrRequest.HDT_WRP_Field();
        field13.name='updatedFrom';
        field13.value='badvalue';//To throw List index out of bounds 
        HDT_WRP_MrrRequest.HDT_WRP_Field field14=new HDT_WRP_MrrRequest.HDT_WRP_Field();
        field14.name='NOTE_ANN';
        field14.value='note';//To throw List index out of bounds
        HDT_WRP_MrrRequest.HDT_WRP_Field field15=new HDT_WRP_MrrRequest.HDT_WRP_Field();
        field15.name='TESTO_ERRR';
        field15.value='ok';//To throw List index out of bounds 
        HDT_WRP_MrrRequest.HDT_WRP_Field field16=new HDT_WRP_MrrRequest.HDT_WRP_Field();
        field16.name='ANNOTAZIONI';
        field16.value='ok';//To throw List index out of bounds 
        HDT_WRP_MrrRequest.HDT_WRP_Field field17=new HDT_WRP_MrrRequest.HDT_WRP_Field();
        field17.name='STATO_SOSP';
        field17.value='ok';//To throw List index out of bounds 
        HDT_WRP_MrrRequest.HDT_WRP_Field field18=new HDT_WRP_MrrRequest.HDT_WRP_Field();
        field18.name='DATE_SOSP';
        field18.value='ok';//To throw List index out of bounds 
        HDT_WRP_MrrRequest.HDT_WRP_Field field19=new HDT_WRP_MrrRequest.HDT_WRP_Field();
        field19.name='INDENNIZZO';
        field19.value='ok';//To throw List index out of bounds 
        HDT_WRP_MrrRequest.HDT_WRP_Field field20=new HDT_WRP_MrrRequest.HDT_WRP_Field();
        field20.name='DATE_SOST';
        field20.value='ok';//To throw List index out of bounds 
        HDT_WRP_MrrRequest.HDT_WRP_Field field21=new HDT_WRP_MrrRequest.HDT_WRP_Field();
        field21.name='DATA_SALVAGUARDIA';
        field21.value='ok';//To throw List index out of bounds 
        HDT_WRP_MrrRequest.HDT_WRP_Field field22=new HDT_WRP_MrrRequest.HDT_WRP_Field();
        field22.name='DATA_ULT_SOSP';
        field22.value='ok';//To throw List index out of bounds 
        HDT_WRP_MrrRequest.HDT_WRP_Field field23=new HDT_WRP_MrrRequest.HDT_WRP_Field();
        field23.name='DT_SOSP_ATT';
        field23.value='ok';//To throw List index out of bounds
        HDT_WRP_MrrRequest.HDT_WRP_Field field24=new HDT_WRP_MrrRequest.HDT_WRP_Field();
        field24.name='MERCATO_PROV';
        field24.value='ok';//To throw List index out of bounds 
          
        List<HDT_WRP_MrrRequest.HDT_WRP_Field> fieldList=new List<HDT_WRP_MrrRequest.HDT_WRP_Field> ();
        fieldList.add(field);
        fieldList.add(field1);
        fieldList.add(field2);
        fieldList.add(field3);
        System.debug('paramsBool.get("withImpPrevDist")!=null '+paramsBool.get('withImpPrevDist')!=null);
        if(paramsBool.get('withImpPrevDist')!=null && paramsBool.get('withImpPrevDist')==true) fieldList.add(field4);
        fieldList.add(field5);
        fieldList.add(field6);
		    fieldList.add(field7);
        fieldList.add(field8);
        fieldList.add(field9);
        System.debug('paramsBool.get("withRunId")!=null '+paramsBool.get('withRunId')!=null);
        if(paramsBool.get('withRunId')!=null && paramsBool.get('withRunId')==true) fieldList.add(field10);
        if(requestType=='NOTIF_ES') fieldList.add(field11);
        HDT_WRP_MrrRequest.HDT_WRP_Object obj=new HDT_WRP_MrrRequest.HDT_WRP_Object();
        fieldList.add(field11);
        fieldList.add(field12);
        fieldList.add(field13);
        fieldList.add(field14);
        fieldList.add(field15);
        fieldList.add(field16);
        fieldList.add(field17);
        fieldList.add(field18);
        fieldList.add(field19);
        fieldList.add(field20);
        fieldList.add(field21);
        fieldList.add(field22);
        fieldList.add(field23);
        fieldList.add(field24);
        obj.fields=fieldList;
        List<HDT_WRP_MrrRequest.HDT_WRP_Object> objList=new List<HDT_WRP_MrrRequest.HDT_WRP_Object> ();
        objList.add(obj);
        request.header=header;
        request.objects=objList;
        System.debug('paramsBool.get("withoutObjects")!=null '+paramsBool.get('withoutObjects')!=null);
        if(paramsBool.get('withoutObjects')==null || paramsBool.get('withoutObjects')==false) request.objects=objList;
      
      /* Configuration of response */
        HDT_WRP_MrrResponse.HDT_WRP_Object objResponse =new HDT_WRP_MrrResponse.HDT_WRP_Object();
        List<HDT_WRP_MrrResponse.HDT_WRP_Object> objResponseList=new List<HDT_WRP_MrrResponse.HDT_WRP_Object> ();
        objResponseList.add(objResponse);
        HDT_WRP_MrrResponse.HDT_WRP_Response response =new HDT_WRP_MrrResponse.HDT_WRP_Response();
        response.objects=objResponseList;
        // Try{
        new HDT_SRV_SalesHandler().manageSalesProcessCategory(request,response);
        // }catch(Exception e){}
    }

  }


@testSetup 
static void setup() {

    HDT_UTL_DataFactoryTst.pClickInstance();
    HDT_UTL_DataFactoryTst.pClickOrderPhase(); 
    HDT_UTL_DataFactoryTst.createWebServiceConfiguration ('CampagenDmDmpData', 'https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/data-management/files', 'POST', 'MulesoftSalesforceUser');
    HDT_UTL_DataFactoryTst.createWebServiceCredential ('MulesoftSalesforceUser', 'uat-heroku', 'heroku-hera-uat-2021!');
    List<Account> accountList= HDT_UTL_DataFactoryTst.createAccountResidenziale(1,true,'HERA COMM','Persona fisica','Famiglie');
    List<BillingProfile__c> billingProfileList=HDT_UTL_DataFactoryTst.createBillingProfile(1, true, accountList[0].id);
    List<ServicePoint__c> servicePointList= HDT_UTL_DataFactoryTst.createServicePoint(3, true);
    List<Sale__c> salesList= HDT_UTL_DataFactoryTst.createSale(1, true, accountList[0].id, 'Bozza');
    Pricebook2 pricebook= HDT_UTL_DataFactoryTst.activeStandardPricebook();
    List<Product2> product2List = HDT_UTL_DataFactoryTst.createProduct2(1, true);
    List<PricebookEntry> pricebookentryList= HDT_UTL_DataFactoryTst.createPricebookEntry(product2List, true, pricebook.Id);
    List<Contact> contactList= HDT_UTL_DataFactoryTst.createContact(1, true,accountList[0].id);
    List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accountList[0].Id);

    List<Order> orders;

    orders = HDT_UTL_DataFactoryTst.createOrderWithParams(1, false, salesList,'HDT_RT_Attivazione',new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Phase__c'=>'Ammissibilità KO',
      'BillingProfile__c'=>billingProfileList[0].Id,
      'ServicePoint__c'=>servicePointList[0].Id,
      'ProcessType__c'=>'Prima Attivazione Fuori delibera',
      'CausalCode__c'=>'034' 
    } ); 
    orders.addAll(HDT_UTL_DataFactoryTst.createOrderWithParams(1, false, salesList,'HDT_RT_Attivazione',new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Phase__c'=>'Ammissibilità OK',
      'BillingProfile__c'=>billingProfileList[0].Id,
      'ServicePoint__c'=>servicePointList[0].Id,
      'ProcessType__c'=>'Prima Attivazione Fuori delibera',
      'CausalCode__c'=>'034'          
    } )); 
    orders.addAll(HDT_UTL_DataFactoryTst.createOrderWithParams(1, false, salesList,'HDT_RT_TemporaneaNuovaAtt',new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Phase__c'=>'Dati Tecnici Ricevuti',
      'BillingProfile__c'=>billingProfileList[0].Id,
      'SupplyType__c'=>'Domestico',
      'ServicePoint__c'=>servicePointList[0].Id
    } )); 
    orders.addAll(HDT_UTL_DataFactoryTst.createOrderWithParams(1, false, salesList,'HDT_RT_ConnessioneConAttivazione',new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Phase__c'=>'Esito OK da DL',
      'BillingProfile__c'=>billingProfileList[0].Id,
      'ServicePoint__c'=>servicePointList[0].Id
    } )); 
    orders.addAll(HDT_UTL_DataFactoryTst.createOrderWithParams(1, false, salesList,'HDT_RT_Attivazione',new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Phase__c'=>'Esito KO da DL',
      'BillingProfile__c'=>billingProfileList[0].Id,
      'ServicePoint__c'=>servicePointList[0].Id
    } )); 
/*     orders.addAll(HDT_UTL_DataFactoryTst.createOrderWithParams(1, false, salesList,'HDT_RT_AttivazioneConModifica',new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Phase__c'=>'Amm. Precheck OK SII',
      'BillingProfile__c'=>billingProfileList[0].Id,
      'ServicePoint__c'=>servicePointList[0].Id
    } ));  */
/*     orders.addAll(HDT_UTL_DataFactoryTst.createOrderWithParams(1, false, salesList,'HDT_RT_AttivazioneConModifica',new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Phase__c'=>'Esito KO da SII',
      'BillingProfile__c'=>billingProfileList[0].Id,
      'ServicePoint__c'=>servicePointList[0].Id
    } )); */
/*     orders.addAll(HDT_UTL_DataFactoryTst.createOrderWithParams(1, false, salesList,'HDT_RT_AttivazioneConModifica',new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Phase__c'=>'Esito OK da SII',
      'BillingProfile__c'=>billingProfileList[0].Id,
      'ServicePoint__c'=>servicePointList[0].Id
    } ));  */
    orders.addAll(HDT_UTL_DataFactoryTst.createOrderWithParams(1, false, salesList,'HDT_RT_AttivazioneConModifica',new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Phase__c'=>'Annullamento - Inviato al DL/SII',
      'BillingProfile__c'=>billingProfileList[0].Id,
      'ServicePoint__c'=>servicePointList[0].Id
    } )); 
    orders.addAll(HDT_UTL_DataFactoryTst.createOrderWithParams(1, false, salesList,'HDT_RT_AttivazioneConModifica',new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Phase__c'=>'Annullamento - Ammissibilità OK',
      'BillingProfile__c'=>billingProfileList[0].Id,
      'ServicePoint__c'=>servicePointList[0].Id
    } ));
    orders.addAll(HDT_UTL_DataFactoryTst.createOrderWithParams(1, false, salesList,'HDT_RT_AttivazioneConModifica',new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Phase__c'=>'Errore lavorazione SAP',
      'BillingProfile__c'=>billingProfileList[0].Id,
      'ServicePoint__c'=>servicePointList[0].Id
    } )); 
    orders.addAll(HDT_UTL_DataFactoryTst.createOrderWithParams(1, false, salesList,'HDT_RT_CambioOfferta',new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Phase__c'=>'Annullamento SII - Ricezione',
      'BillingProfile__c'=>billingProfileList[0].Id,
      'ServicePoint__c'=>servicePointList[0].Id
    } ));
    orders.addAll(HDT_UTL_DataFactoryTst.createOrderWithParams(1, false, salesList,'HDT_RT_SwitchIn',new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Phase__c'=>'Dati discordanti',     
      'BillingProfile__c'=>billingProfileList[0].Id,
      'ProcessType__c' =>'Prima Attivazione Fuori delibera',
      'ServicePoint__c'=>servicePointList[0].Id
    } )); 
    orders.addAll(HDT_UTL_DataFactoryTst.createOrderWithParams(1, false, salesList,'HDT_RT_SwitchIn',new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Phase__c'=>'Amm. Precheck KO SII',
      'BillingProfile__c'=>billingProfileList[0].Id,
      'ServicePoint__c'=>servicePointList[0].Id
    } ));
    List<Order> orderCompletata= HDT_UTL_DataFactoryTst.createOrderWithParams(1, true, salesList,'HDT_RT_SwitchIn',new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Phase__c'=>'Completata',
      'BillingProfile__c'=>billingProfileList[0].Id,
      'ServicePoint__c'=>servicePointList[0].Id,
      'ContractReference__c' => contractList[0].Id,
      'ProcessType__c' =>'Cambio Uso',
      'Pricebook2Id'=>pricebook.Id
    } );
    orders.addAll(HDT_UTL_DataFactoryTst.createOrderWithParams(1, false, salesList,'HDT_RT_AttivazioneConModifica',new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Contact__c'=>contactList[0].id,
      'Phase__c'=>'Annullamento - Esito OK da DL/SII',
      'BillingProfile__c'=>billingProfileList[0].Id,
      'ServicePoint__c'=>servicePointList[0].Id
    } )); 
    orders.addAll(HDT_UTL_DataFactoryTst.createOrderWithParams(1, false, salesList,'HDT_RT_AttivazioneConModifica',new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Contact__c'=>contactList[0].id,
      'Phase__c'=>'Annullamento - Esito KO da DL/SII',
      'BillingProfile__c'=>billingProfileList[0].Id,
      'ServicePoint__c'=>servicePointList[0].Id
    } ));
    List<Order> orderVolturaCompletata = HDT_UTL_DataFactoryTst.createOrderWithParams(1, true , salesList, 'HDT_RT_Voltura', new Map<String,Object>{
      'AccountId' => accountList[0].Id,
      'Contact__c' => contactList[0].Id,
      'Phase__c' => 'Completata',
      'BillingProfile__c' => billingProfileList[0].Id,
      'ServicePoint__c' => servicePointList[0].Id,
      'ContractReference__c' => contractList[0].Id,
      'ProcessType__c' =>'Cambio Uso',
      'Pricebook2Id' => pricebook.Id
    });
    orders.addAll(HDT_UTL_DataFactoryTst.createOrderWithParams(1, false, salesList,'HDT_RT_SwitchIn',new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Phase__c'=>'Dati TIMOE ricevuti',     
      'BillingProfile__c'=>billingProfileList[0].Id,
      'ProcessType__c' =>'Prima Attivazione Fuori delibera',
      'ServicePoint__c'=>servicePointList[0].Id
    } )); 
    insert orders;

    HDT_UTL_DataFactoryTst.createOrderItem(1, true, orderCompletata[0].id, servicePointList[0].id, product2List[0].Id, pricebookentryList[0].id);
    HDT_UTL_DataFactoryTst.createOrderItem(1, true, orderVolturaCompletata[0].id, servicePointList[0].id, product2List[0].Id, pricebookentryList[0].id);
  }



@isTest
static void testHandleSalesProcessCategoryAmmissibilita() {
  Order orderAmmissibilitaKo=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Ammissibilità KO' LIMIT 1];
  Order orderAmmissibilitaOk=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Ammissibilità OK' LIMIT 1];
  Order orderAnnullamentoAmmissibilita=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Annullamento - Ammissibilità OK' LIMIT 1];
  Test.startTest(); 
    new TestBuilderCallManageSalesProcessCategory(orderAmmissibilitaKo,'Ammissibilità KO','NOTIF_ES',null);
    new TestBuilderCallManageSalesProcessCategory(orderAmmissibilitaOk,'Ammissibilità OK','NOTIF_ES',new Map<String,Boolean>{'withImpPrevDist'=>false,'withDesErrAeeg'=>false});
    new TestBuilderCallManageSalesProcessCategory(orderAnnullamentoAmmissibilita,'Annullamento - Ammissibilità OK','NOTIF_ES',null);
    new TestBuilderCallManageSalesProcessCategory(orderAmmissibilitaOk,'Ammissibilità OK','NOTIF_ES',new Map<String,Boolean>{'withImpPrevDist'=>true,'withDesErrAeeg'=>false});
    System.assertNotEquals(400, RestContext.response.statusCode,'No errors triggered during the processes execution');
    System.assertEquals(200, RestContext.response.statusCode,'the processes are well completed');
  Test.stopTest();
}

@isTest
static void testHandleSalesProcessCategoryErrorCases() {
  Order orderAnnullamentoRicezione=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Annullamento SII - Ricezione' LIMIT 1];
  Test.startTest(); 
    new TestBuilderCallManageSalesProcessCategory(new Order(),null,'WSLead_Callback',new Map<String,Boolean>{'withoutObjects'=>true});
    new TestBuilderCallManageSalesProcessCategory(new Order(),null,'WSLead_Winback',new Map<String,Boolean>{'withoutObjects'=>true});
    new TestBuilderCallManageSalesProcessCategory(new Order(),null,'WSLead_CariBoll',new Map<String,Boolean>{'withoutObjects'=>true});
    new TestBuilderCallManageSalesProcessCategory(new Order(),null,'WSLead_HVAC',new Map<String,Boolean>{'withoutObjects'=>true});
    new TestBuilderCallManageSalesProcessCategory(new Order(),null,'WSLead_SOL',new Map<String,Boolean>{'withoutObjects'=>true});

    System.assertNotEquals(200, RestContext.response.statusCode,'errors happened because of lack of Objects.fields into the request');
    System.assertEquals(400, RestContext.response.statusCode,'the processes are not well completed');
    try{
      new TestBuilderCallManageSalesProcessCategory(orderAnnullamentoRicezione,'Annullamento SII - Ricezione','CMPDMP_ATTR',null);
    }
    catch(exception e){
        System.assertEquals('Missing Required Field runId',e.getMessage(),'the process return an error due to lack of runId');
    } 
    // new TestBuilderCallManageSalesProcessCategory(orderAnnullamentoRicezione,'Annullamento SII - Ricezione','CMPDMP_ATTR',null);
    // System.assertEquals(400, RestContext.response.statusCode,'the process return an error due to lack of runId');
    new TestBuilderCallManageSalesProcessCategory(orderAnnullamentoRicezione,'Annullamento SII - Ricezione','SIE34_7',null);
    System.assertEquals(400, RestContext.response.statusCode,'the process return an error due to lack of runId');
    new TestBuilderCallManageSalesProcessCategory(orderAnnullamentoRicezione,'RICH_PASS','RICH_PASS',null);
    System.assertEquals(200, RestContext.response.statusCode,'the processe is not well completed due to lack of fields');
    //test requestType=NOTIF_ES else 
    new TestBuilderCallManageSalesProcessCategory(orderAnnullamentoRicezione,'Annullamento SII - Ricezione','NOTIF_ES',null);
    System.assertEquals(200, RestContext.response.statusCode,'the processe is not well completed due to lack of fields');
    //test requestType=CMPDMP_PRV
    new TestBuilderCallManageSalesProcessCategory(orderAnnullamentoRicezione,'Annullamento SII - Ricezione','CMPDMP_PRV',null);
    System.assertNotEquals(200, RestContext.response.statusCode,'error code returned due to absence of runId');
  Test.stopTest();
}



@isTest
static void testHandleSalesProcessCategory3() {

  Order orderDatiTecnici=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c,SupplyType__c  FROM Order  WHERE Phase__c='Dati Tecnici Ricevuti' LIMIT 1];
  Test.startTest();
    new TestBuilderCallManageSalesProcessCategory(orderDatiTecnici,'Dati Tecnici Ricevuti','NOTIF_ES',null);
    //to cover the case without orderId and phase
    new TestBuilderCallManageSalesProcessCategory(new Order(),null,'NOTIF_ES',null);
    new TestBuilderCallManageSalesProcessCategory(orderDatiTecnici,'Dati Tecnici Ricevuti','NOTIF_ES',null);
    //to cover the case without orderId and phase
    new TestBuilderCallManageSalesProcessCategory(new Order(),null,'NOTIF_ES',null);
    System.assertNotEquals(400, RestContext.response.statusCode,'No errors triggered during the processes execution');
    System.assertEquals(200, RestContext.response.statusCode,'the processes are well completed');
  Test.stopTest();
}

@isTest
static void testHandleSalesProcessCategory4() {

  Order orderEsitoKoDaDl=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Esito KO da DL' LIMIT 1];
  Order orderEsitoOkDaDl=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Esito OK da DL' LIMIT 1];
  //Order orderAmmPrecheckOkS=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Amm. Precheck OK SII' LIMIT 1];
  Test.startTest();
    new TestBuilderCallManageSalesProcessCategory(orderEsitoKoDaDl,'Esito KO da DL','NOTIF_ES',null);
    new TestBuilderCallManageSalesProcessCategory(orderEsitoOkDaDl,'Esito OK da DL','NOTIF_ES',null);
    //new TestBuilderCallManageSalesProcessCategory(orderAmmPrecheckOkS,'Amm. Precheck OK SII','NOTIF_ES',null);
    System.assertNotEquals(400, RestContext.response.statusCode,'No errors triggered during the processes execution');
    System.assertEquals(200, RestContext.response.statusCode,'the processes are well completed');
  Test.stopTest();
}


/* @isTest
static void testHandleSalesProcessCategory6() {
  Order orderEsitoKoDaS=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Esito KO da SII' LIMIT 1];
  Order orderEsitoOkDaS=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Esito OK da SII' LIMIT 1];
  
  Test.startTest(); 
    //test requestType=NOTIF_ES with 'Esito KO da SII'
    new TestBuilderCallManageSalesProcessCategory(orderEsitoKoDaS,'Esito KO da SII','NOTIF_ES',null);
    System.assertNotEquals(false, RestContext.response.statusCode==200,'No errors triggered during the process');
    //test requestType=NOTIF_ES with 'Esito OK da SII'
    new TestBuilderCallManageSalesProcessCategory(orderEsitoOkDaS,'Esito OK da SII','NOTIF_ES',null);
    System.assertEquals(200, RestContext.response.statusCode,'the process is well completed');
  Test.stopTest();
} */


/* @isTest
static void testHandleSalesProcessCategory5() {
  Order orderEsitoKoDaSii=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Esito KO da SII' LIMIT 1];
  Order orderEsitoOkDaSii=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Esito OK da SII' LIMIT 1]; 
  // Order orderCompletata=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c,ServicePoint__c  FROM Order  WHERE Phase__c='Completata' LIMIT 1]; 
  Test.startTest(); 
    //new TestBuilderCallManageSalesProcessCategory(orderEsitoKoDaSii,'Esito KO da SII','NOTIF_ES',null);
    //new TestBuilderCallManageSalesProcessCategory(orderEsitoOkDaSii,'Esito OK da SII','NOTIF_ES',null); 
    System.assertNotEquals(400, RestContext.response.statusCode,'No errors triggered during the processes execution');
    System.assertEquals(200, RestContext.response.statusCode,'the processes are well completed');
  Test.stopTest();
} */


@isTest
static void testHandleSalesProcessCategory8() {
  //Order orderAmmPrecheckOkSii=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Amm. Precheck OK SII' LIMIT 1]; 
  Order orderDatiTecniciRicevuti=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Dati Tecnici Ricevuti' LIMIT 1]; 
  Order orderErrorelavorazione=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Errore lavorazione SAP' LIMIT 1]; 
  Test.startTest(); 
    //new TestBuilderCallManageSalesProcessCategory(orderAmmPrecheckOkSii,'Amm. Precheck OK SII','NOTIF_ES',null);
    new TestBuilderCallManageSalesProcessCategory(orderDatiTecniciRicevuti,'Dati Tecnici Ricevuti','NOTIF_ES',null); 
    new TestBuilderCallManageSalesProcessCategory(orderErrorelavorazione,'Errore lavorazione SAP','NOTIF_ES',null); 
    System.assertNotEquals(400, RestContext.response.statusCode,'No errors triggered during the processes execution');
    System.assertEquals(200, RestContext.response.statusCode,'the processes are well completed');
  Test.stopTest();
}



@isTest
static void testHandleSalesProcessCategory7() {
     Order orderAmmPrecheckKoSii=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Amm. Precheck KO SII' LIMIT 1]; 
  	Order orderDatidiscordanti=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Dati discordanti' LIMIT 1]; 
  	// Order orderErrorelavorazione=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Errore lavorazione SAP' LIMIT 1];
    Order orderCompletata=[ SELECT id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c FROM Order WHERE Phase__c='Completata' LIMIT 1];
    Test.startTest(); 
    new TestBuilderCallManageSalesProcessCategory(orderAmmPrecheckKoSii,'Amm. Precheck KO SII','NOTIF_ES',null);
    new TestBuilderCallManageSalesProcessCategory(orderDatidiscordanti,'Dati discordanti','NOTIF_ES',null); 
    new TestBuilderCallManageSalesProcessCategory(orderCompletata,'Completata','NOTIF_ES',null); 
    System.assertNotEquals(400, RestContext.response.statusCode,'No errors triggered during the processes execution');
    System.assertEquals(200, RestContext.response.statusCode,'the processes are well completed');
    Test.stopTest();
}


@isTest
static void testHandleSalesProcessCategoryAnnullamento() {

  Order orderAnnullamentoEsitoOkDa=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Annullamento - Esito OK da DL/SII' LIMIT 1];
  Order orderAnnullamentoEsitoKoDa=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Annullamento - Esito KO da DL/SII' LIMIT 1];
  Test.startTest();
    new TestBuilderCallManageSalesProcessCategory(orderAnnullamentoEsitoOkDa,'Esito OK da DL/SII','NOTIF_ES',null);
    new TestBuilderCallManageSalesProcessCategory(orderAnnullamentoEsitoKoDa,'Esito KO da DL/SII','NOTIF_ES',null);
    System.assertNotEquals(400, RestContext.response.statusCode,'No errors triggered during the processes execution');
    System.assertEquals(200, RestContext.response.statusCode,'the processes are well completed');
  Test.stopTest();

}

@isTest
static void testHandleSalesProcessCategoryAnnullamento2() {

  Order orderAnnullamentoInviato=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Annullamento - Inviato al DL/SII' LIMIT 1];
  Order orderAnnullamentoEsitoKoDa=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Annullamento - Esito KO da DL/SII' LIMIT 1];
  Order orderAnnullamentoRicezione=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Annullamento SII - Ricezione' LIMIT 1];
  Test.startTest();
    
    new TestBuilderCallManageSalesProcessCategory(orderAnnullamentoRicezione,'Annullamento SII - Ricezione','NOTIF_ES',null);
    new TestBuilderCallManageSalesProcessCategory(orderAnnullamentoInviato,'Annullamento - Inviato al DL/SII','NOTIF_ES',null);
    new TestBuilderCallManageSalesProcessCategory(orderAnnullamentoEsitoKoDa,'Errore tecnico invio a SAP','NOTIF_ES',null);
    new TestBuilderCallManageSalesProcessCategory(orderAnnullamentoRicezione,'Annullamento SII - Ricezione','RICH_PASS',null);
    new TestBuilderCallManageSalesProcessCategory(orderAnnullamentoRicezione,'Annullamento SII - Ricezione','WSLead_Callback',null);
    new TestBuilderCallManageSalesProcessCategory(orderAnnullamentoRicezione,'Annullamento SII - Ricezione','WSLead_Winback',null);
    new TestBuilderCallManageSalesProcessCategory(orderAnnullamentoRicezione,'Annullamento SII - Ricezione','WSLead_CariBoll',null);
    new TestBuilderCallManageSalesProcessCategory(orderAnnullamentoRicezione,'Annullamento SII - Ricezione','WSLead_HVAC',null);
    new TestBuilderCallManageSalesProcessCategory(orderAnnullamentoRicezione,'Annullamento SII - Ricezione','WSLead_SOL',null);
    new TestBuilderCallManageSalesProcessCategory(orderAnnullamentoRicezione,'Annullamento SII - Ricezione','CMPDMP_PRV',new Map<String,Boolean>{'withRunId'=>true});
    System.assertNotEquals(400, RestContext.response.statusCode,'No errors triggered during the processes execution');
    System.assertEquals(200, RestContext.response.statusCode,'the processes are well completed');
  Test.stopTest();

}


@isTest
static void testHandleSalesProcessCategoryAnnullamento1() {

  Order orderAnnullamentoRicezione=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Annullamento SII - Ricezione' LIMIT 1];
  // Order orderAnnullamentoInviato=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Annullamento - Inviato al DL/SII' LIMIT 1];
  Test.startTest();
    new TestBuilderCallManageSalesProcessCategory(orderAnnullamentoRicezione,'Annullamento SII - Ricezione','CMPDMP_ATTR',new Map<String,Boolean>{'withRunId'=>true});
    System.assertEquals(200, RestContext.response.statusCode,'the processes above are well completed');
    try {
      new TestBuilderCallManageSalesProcessCategory(orderAnnullamentoRicezione,'Annullamento SII - Ricezione','SIE34_7',new Map<String,Boolean>{'withRunId'=>true}); 
    } catch (Exception e) {
      System.assertEquals(true,e.getMessage().contains('List index out of bounds'),'Due to badvalue passed to updatedFrom ');
    }
    //test requestType=SIE34_6
    new TestBuilderCallManageSalesProcessCategory(orderAnnullamentoRicezione,'Annullamento SII - Ricezione','SIE34_6',null);
    try{
      new TestBuilderCallManageSalesProcessCategory(orderAnnullamentoRicezione,'Annullamento SII - Ricezione','SIE34_6',new Map<String,Boolean>{'withRunId'=>true});
    }catch(Exception e){
      System.assertEquals(true,e.getMessage().contains('List index out of bounds'),'Due to badvalue passed to updatedFrom ');
    }
    //test requestType=SIE34_3
    new TestBuilderCallManageSalesProcessCategory(orderAnnullamentoRicezione,'Annullamento SII - Ricezione','SIE34_3',null);
    try{
      new TestBuilderCallManageSalesProcessCategory(orderAnnullamentoRicezione,'Annullamento SII - Ricezione','SIE34_3',new Map<String,Boolean>{'withRunId'=>true});
    }catch(Exception e){
      System.assertEquals(true,e.getMessage().contains('List index out of bounds'),'Due to badvalue passed to updatedFrom ');
    }
    //test requestType=SIE34_2
    new TestBuilderCallManageSalesProcessCategory(orderAnnullamentoRicezione,'Annullamento SII - Ricezione','SIE34_2',null);
    try{
      new TestBuilderCallManageSalesProcessCategory(orderAnnullamentoRicezione,'Annullamento SII - Ricezione','SIE34_2',new Map<String,Boolean>{'withRunId'=>true});
    }catch(Exception e){
      System.assertEquals(true,e.getMessage().contains('List index out of bounds'),'Due to badvalue passed to updatedFrom ');
    }
    //test requestType=SIE34_1
    new TestBuilderCallManageSalesProcessCategory(orderAnnullamentoRicezione,'Annullamento SII - Ricezione','SIE34_1',null);
    try{
      new TestBuilderCallManageSalesProcessCategory(orderAnnullamentoRicezione,'Annullamento SII - Ricezione','SIE34_1',new Map<String,Boolean>{'withRunId'=>true});
    }catch(Exception e){
      System.assertEquals(true,e.getMessage().contains('List index out of bounds'),'Due to badvalue passed to updatedFrom ');
    }
    //test requestType=Else
    new TestBuilderCallManageSalesProcessCategory(orderAnnullamentoRicezione,'Annullamento SII - Ricezione','Else',null);
    System.assertEquals(400, RestContext.response.statusCode,'the processe above is not well completed due to unsupported requesttype:Else');
  Test.stopTest();

}

@isTest
static void updateServicePointTest() {
    Test.startTest(); 
    try {
      HDT_SRV_SalesHandler.updateServicePoint(new ServicePoint__c());
    } catch (Exception e) {
      System.assertEquals(true,e.getMessage().contains('MISSING_ARGUMENT'),'The Id is missing');
    }

    ServicePoint__c servicePoint=[SELECT Id,ServicePointCode__c,IsMigrated__c FROM ServicePoint__c LIMIT 1];
    servicePoint.IsMigrated__c=true;
    HDT_SRV_SalesHandler.updateServicePoint(servicePoint);
    Test.stopTest();

    System.assertNotEquals(false, [SELECT IsMigrated__c FROM ServicePoint__c WHERE Id=:servicePoint.Id].IsMigrated__c,'The service point has been successfully updated!');
}

@IsTest
static void moveOutTest()
{
    Order orderCompletata=[ SELECT  id,AccountId,ContractReference__c,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  
      FROM Order  WHERE Phase__c='Completata' AND RecordType.DeveloperName = 'HDT_RT_Voltura' LIMIT 1];
    
    Test.startTest();
    try
    {
      new TestBuilderCallManageSalesProcessCategory(orderCompletata,'Completata','NOTIF_ES',null); 
    }
    catch(Exception e)
    {
      System.assertEquals(true,e.getMessage().contains('List index out of bounds'),'Due to badvalue passed to updatedFrom ');
    }
    Test.stopTest();
    List<Contract> contractList = [SELECT Id, Status, EndDate FROM Contract WHERE AccountId = :orderCompletata.AccountId];
    System.assertEquals('Cessato', contractList[0].Status, 'Move Out: Status non corretto');
    System.assertEquals(System.today(), contractList[0].EndDate, 'Move Out: EndDate non corretta');
}

@IsTest
static void datiTimoeTst()
{
  Order datiTimoeOrder = [SELECT Id, Description FROM Order WHERE Phase__c = 'Dati TIMOE ricevuti' LIMIT 1];
  Test.startTest();
  try
  {
    new TestBuilderCallManageSalesProcessCategory(datiTimoeOrder,'Dati TIMOE ricevuti','NOTIF_ES',null); 
  }
  catch(Exception e)
  {
    System.assertEquals(true,e.getMessage().contains('List index out of bounds'),'Due to badvalue passed to updatedFrom ');
  }
  Test.stopTest();
  datiTimoeOrder = [SELECT Id, Description FROM Order WHERE Phase__c = 'Dati TIMOE ricevuti' LIMIT 1];
  System.assertEquals(true, String.isNotBlank(datiTimoeOrder.Description), 'Dati TIMOE: Fase non ricevuta correttamente');
}

@isTest
static void coverageWithoutObjectsNOTIF_ES() {

  RestResponse res = new RestResponse();
  res.statusCode = 200;
  RestContext.response = res;



  HDT_WRP_MrrRequest.HDT_WRP_Request request=new HDT_WRP_MrrRequest.HDT_WRP_Request();
  HDT_WRP_MrrRequest.HDT_WRP_Header header=new HDT_WRP_MrrRequest.HDT_WRP_Header();
  header.requestType='NOTIF_ES';
  request.header=header;

  HDT_WRP_MrrRequest.HDT_WRP_Object obj=new HDT_WRP_MrrRequest.HDT_WRP_Object();
  List<HDT_WRP_MrrRequest.HDT_WRP_Field> fieldList=new List<HDT_WRP_MrrRequest.HDT_WRP_Field> ();
  fieldList.add(null);
  obj.fields=fieldList;
  List<HDT_WRP_MrrRequest.HDT_WRP_Object> objList=new List<HDT_WRP_MrrRequest.HDT_WRP_Object> ();
  objList.add(obj);

  request.objects=objList;



  HDT_WRP_MrrResponse.HDT_WRP_Object objResponse =new HDT_WRP_MrrResponse.HDT_WRP_Object();
  List<HDT_WRP_MrrResponse.HDT_WRP_Object> objResponseList=new List<HDT_WRP_MrrResponse.HDT_WRP_Object> ();
  objResponseList.add(objResponse);
  HDT_WRP_MrrResponse.HDT_WRP_Response response =new HDT_WRP_MrrResponse.HDT_WRP_Response();
  response.objects=objResponseList;
  



  new HDT_SRV_SalesHandler().manageSalesProcessCategory(request,response);
}

@isTest
static void coverageWithoutObjectsRICH_PASS() {

  RestResponse res = new RestResponse();
  res.statusCode = 200;
  RestContext.response = res;



  HDT_WRP_MrrRequest.HDT_WRP_Request request=new HDT_WRP_MrrRequest.HDT_WRP_Request();
  HDT_WRP_MrrRequest.HDT_WRP_Header header=new HDT_WRP_MrrRequest.HDT_WRP_Header();
  header.requestType='RICH_PASS';
  request.header=header;

  HDT_WRP_MrrRequest.HDT_WRP_Object obj=new HDT_WRP_MrrRequest.HDT_WRP_Object();
  List<HDT_WRP_MrrRequest.HDT_WRP_Field> fieldList=new List<HDT_WRP_MrrRequest.HDT_WRP_Field> ();
  fieldList.add(null);
  obj.fields=fieldList;
  List<HDT_WRP_MrrRequest.HDT_WRP_Object> objList=new List<HDT_WRP_MrrRequest.HDT_WRP_Object> ();
  objList.add(obj);

  request.objects=objList;



  HDT_WRP_MrrResponse.HDT_WRP_Object objResponse =new HDT_WRP_MrrResponse.HDT_WRP_Object();
  List<HDT_WRP_MrrResponse.HDT_WRP_Object> objResponseList=new List<HDT_WRP_MrrResponse.HDT_WRP_Object> ();
  objResponseList.add(objResponse);
  HDT_WRP_MrrResponse.HDT_WRP_Response response =new HDT_WRP_MrrResponse.HDT_WRP_Response();
  response.objects=objResponseList;
  



  new HDT_SRV_SalesHandler().manageSalesProcessCategory(request,response);
}

@isTest
static void coverageWithoutObjectsNOTIF_ESDULL() {

  RestResponse res = new RestResponse();
  res.statusCode = 200;
  RestContext.response = res;


  List<HDT_WRP_MrrRequest.HDT_WRP_Field> fieldList=new List<HDT_WRP_MrrRequest.HDT_WRP_Field> ();
  HDT_WRP_MrrRequest.HDT_WRP_Request request=new HDT_WRP_MrrRequest.HDT_WRP_Request();
  HDT_WRP_MrrRequest.HDT_WRP_Header header=new HDT_WRP_MrrRequest.HDT_WRP_Header();
  header.requestType='NOTIF_ES';
  request.header=header;

  HDT_WRP_MrrRequest.HDT_WRP_Object obj=new HDT_WRP_MrrRequest.HDT_WRP_Object();
  HDT_WRP_MrrRequest.HDT_WRP_Field field=new HDT_WRP_MrrRequest.HDT_WRP_Field();
  field.name='RECORD_ID';
  field.value='a';
  HDT_WRP_MrrRequest.HDT_WRP_Field field1=new HDT_WRP_MrrRequest.HDT_WRP_Field();
  field1.name='FASE';
  field1.value='123';
  fieldList.add(field);
  fieldList.add(field1);
  obj.fields=fieldList;
  List<HDT_WRP_MrrRequest.HDT_WRP_Object> objList=new List<HDT_WRP_MrrRequest.HDT_WRP_Object> ();
  objList.add(obj);

  request.objects=objList;



  HDT_WRP_MrrResponse.HDT_WRP_Object objResponse =new HDT_WRP_MrrResponse.HDT_WRP_Object();
  List<HDT_WRP_MrrResponse.HDT_WRP_Object> objResponseList=new List<HDT_WRP_MrrResponse.HDT_WRP_Object> ();
  objResponseList.add(objResponse);
  HDT_WRP_MrrResponse.HDT_WRP_Response response =new HDT_WRP_MrrResponse.HDT_WRP_Response();
  response.objects=objResponseList;
  



  new HDT_SRV_SalesHandler().manageSalesProcessCategory(request,response);
}
@isTest
static void coverageWithoutObjectsNOTIF_ESMETHOD() {

  RestResponse res = new RestResponse();
  res.statusCode = 200;
  RestContext.response = res;
  List<HDT_WRP_MrrRequest.HDT_WRP_Field> fieldList=new List<HDT_WRP_MrrRequest.HDT_WRP_Field> ();
  List<HDT_WRP_MrrRequest.HDT_WRP_Field> fieldsList=new List<HDT_WRP_MrrRequest.HDT_WRP_Field> ();
  HDT_WRP_MrrRequest.HDT_WRP_Field field1=new HDT_WRP_MrrRequest.HDT_WRP_Field();
  field1.name='PROCESS_CATEGORY';
  field1.value='test';

  fieldsList.add(field1);

  HDT_WRP_MrrRequest.HDT_WRP_Request request=new HDT_WRP_MrrRequest.HDT_WRP_Request();
  HDT_WRP_MrrRequest.HDT_WRP_Header header=new HDT_WRP_MrrRequest.HDT_WRP_Header();
  header.requestType='NOTIF_ES';
  header.fields = fieldsList;
  request.header=header;

  HDT_WRP_MrrRequest.HDT_WRP_Object obj=new HDT_WRP_MrrRequest.HDT_WRP_Object();
  
  HDT_WRP_MrrRequest.HDT_WRP_Field field=new HDT_WRP_MrrRequest.HDT_WRP_Field();
  field.name='METHOD';
  field.value='AggiornaAppuntamento';
/*  HDT_WRP_MrrRequest.HDT_WRP_Field field1=new HDT_WRP_MrrRequest.HDT_WRP_Field();
  field1.name='RECORD_ID';
  field1.value=order.Id;*/
  fieldList.add(field);
  obj.fields=fieldList;
  List<HDT_WRP_MrrRequest.HDT_WRP_Object> objList=new List<HDT_WRP_MrrRequest.HDT_WRP_Object> ();
  objList.add(obj);

  request.objects=objList;



  HDT_WRP_MrrResponse.HDT_WRP_Object objResponse =new HDT_WRP_MrrResponse.HDT_WRP_Object();
  List<HDT_WRP_MrrResponse.HDT_WRP_Object> objResponseList=new List<HDT_WRP_MrrResponse.HDT_WRP_Object> ();
  objResponseList.add(objResponse);
  HDT_WRP_MrrResponse.HDT_WRP_Response response =new HDT_WRP_MrrResponse.HDT_WRP_Response();
  response.objects=objResponseList;
  
  try {
    new HDT_SRV_SalesHandler().manageSalesProcessCategory(request,response);
  } catch (Exception e) {
      System.debug(e);
  }


  
}

@isTest
static void coverageWithoutObjectsNOTIF_ESrecordnull() {

  RestResponse res = new RestResponse();
  res.statusCode = 200;
  RestContext.response = res;


  List<HDT_WRP_MrrRequest.HDT_WRP_Field> fieldList=new List<HDT_WRP_MrrRequest.HDT_WRP_Field> ();
  HDT_WRP_MrrRequest.HDT_WRP_Request request=new HDT_WRP_MrrRequest.HDT_WRP_Request();
  HDT_WRP_MrrRequest.HDT_WRP_Header header=new HDT_WRP_MrrRequest.HDT_WRP_Header();
  header.requestType='NOTIF_ES';
  request.header=header;

  HDT_WRP_MrrRequest.HDT_WRP_Object obj=new HDT_WRP_MrrRequest.HDT_WRP_Object();
  HDT_WRP_MrrRequest.HDT_WRP_Field field=new HDT_WRP_MrrRequest.HDT_WRP_Field();
  field.name='RECORD_ID';
  field.value='';
  HDT_WRP_MrrRequest.HDT_WRP_Field field1=new HDT_WRP_MrrRequest.HDT_WRP_Field();
  field1.name='FASE';
  field1.value='123';
  fieldList.add(field);
  fieldList.add(field1);
  obj.fields=fieldList;
  List<HDT_WRP_MrrRequest.HDT_WRP_Object> objList=new List<HDT_WRP_MrrRequest.HDT_WRP_Object> ();
  objList.add(obj);

  request.objects=objList;



  HDT_WRP_MrrResponse.HDT_WRP_Object objResponse =new HDT_WRP_MrrResponse.HDT_WRP_Object();
  List<HDT_WRP_MrrResponse.HDT_WRP_Object> objResponseList=new List<HDT_WRP_MrrResponse.HDT_WRP_Object> ();
  objResponseList.add(objResponse);
  HDT_WRP_MrrResponse.HDT_WRP_Response response =new HDT_WRP_MrrResponse.HDT_WRP_Response();
  response.objects=objResponseList;
  



  new HDT_SRV_SalesHandler().manageSalesProcessCategory(request,response);
}
}