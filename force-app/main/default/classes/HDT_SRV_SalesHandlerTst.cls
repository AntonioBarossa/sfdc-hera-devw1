@isTest
private class HDT_SRV_SalesHandlerTst {

  class TestBuilder{
    public HDT_WRP_MrrResponse.HDT_WRP_Response processes;
    public TestBuilder(Order order,String phase, String requestType){

      RestResponse res = new RestResponse();
      res.statusCode = 200;
      RestContext.response = res;

      HDT_WRP_MrrRequest.HDT_WRP_Request request=new HDT_WRP_MrrRequest.HDT_WRP_Request();
      HDT_WRP_MrrRequest.HDT_WRP_Header header=new HDT_WRP_MrrRequest.HDT_WRP_Header();
      header.requestType=requestType;

     // For Pass the RICH_PASS and NOTIF_ES else    
      if(phase=='RICH_PASS'||phase=='NOTIF_ES'){
        HDT_WRP_MrrRequest.HDT_WRP_Field field=new HDT_WRP_MrrRequest.HDT_WRP_Field();
        field.name='ATTIVITA';
        field.value=null;
        List<HDT_WRP_MrrRequest.HDT_WRP_Field> fieldList=new List<HDT_WRP_MrrRequest.HDT_WRP_Field> ();
        fieldList.add(null);
        fieldList.add(field);
        HDT_WRP_MrrRequest.HDT_WRP_Object obj=new HDT_WRP_MrrRequest.HDT_WRP_Object();
        obj.fields=fieldList;
        List<HDT_WRP_MrrRequest.HDT_WRP_Object> objList=new List<HDT_WRP_MrrRequest.HDT_WRP_Object> ();
        objList.add(obj);
        request.header=header;
        request.objects=objList;
      }else{
        // create fields
        HDT_WRP_MrrRequest.HDT_WRP_Field field=new HDT_WRP_MrrRequest.HDT_WRP_Field();
        field.name='ATTIVITA';
        field.value='Gestione Switch in Ripristinatorio';
        HDT_WRP_MrrRequest.HDT_WRP_Field field1=new HDT_WRP_MrrRequest.HDT_WRP_Field();
        field1.name='RECORD_ID';
        field1.value=order.Id;
        HDT_WRP_MrrRequest.HDT_WRP_Field field2=new HDT_WRP_MrrRequest.HDT_WRP_Field();
        field2.name='FASE';
        field2.value=phase;
        HDT_WRP_MrrRequest.HDT_WRP_Field field3=new HDT_WRP_MrrRequest.HDT_WRP_Field();
        field3.name='CODERR_AEEG';
        field3.value='032';
        if(phase=='Ammissibilità OK'){
          field3.value='034';
        }
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
        
        List<HDT_WRP_MrrRequest.HDT_WRP_Field> fieldList=new List<HDT_WRP_MrrRequest.HDT_WRP_Field> ();
        fieldList.add(field);
        fieldList.add(field1);
        fieldList.add(field2);
        fieldList.add(field3);
        fieldList.add(field4);
        fieldList.add(field5);
        fieldList.add(field6);
        fieldList.add(field7);
        fieldList.add(field8);
        fieldList.add(field9);
        HDT_WRP_MrrRequest.HDT_WRP_Object obj=new HDT_WRP_MrrRequest.HDT_WRP_Object();
        obj.fields=fieldList;
        List<HDT_WRP_MrrRequest.HDT_WRP_Object> objList=new List<HDT_WRP_MrrRequest.HDT_WRP_Object> ();
        objList.add(obj);
        request.header=header;
        request.objects=objList;
     }
      
      /* Configuration of response */
      HDT_WRP_MrrResponse.HDT_WRP_Object objResponse =new HDT_WRP_MrrResponse.HDT_WRP_Object();
      List<HDT_WRP_MrrResponse.HDT_WRP_Object> objResponseList=new List<HDT_WRP_MrrResponse.HDT_WRP_Object> ();
      objResponseList.add(objResponse);
      HDT_WRP_MrrResponse.HDT_WRP_Response response =new HDT_WRP_MrrResponse.HDT_WRP_Response();
      response.objects=objResponseList;

      HDT_SRV_SalesHandler salesHandler =new HDT_SRV_SalesHandler();
      processes = salesHandler.manageSalesProcessCategory(request,response);
    }
  }


@testSetup 
  static void setup() {

    HDT_UTL_DataFactoryTst.pClickInstance();
    HDT_UTL_DataFactoryTst.pClickOrderPhase();  
    List<Account> accountList= HDT_UTL_DataFactoryTst.createAccountResidenziale(1,true,'HERA COMM','Persona fisica','Famiglie');
    List<BillingProfile__c> billingProfileList=HDT_UTL_DataFactoryTst.createBillingProfile(1, true, accountList[0].id);
    List<ServicePoint__c> servicePointList= HDT_UTL_DataFactoryTst.createServicePoint(3, true);
    List<Sale__c> salesList= HDT_UTL_DataFactoryTst.createSale(1, true, accountList[0].id, 'Bozza');
    Pricebook2 pricebook= HDT_UTL_DataFactoryTst.activeStandardPricebook();
    List<Product2> product2List = HDT_UTL_DataFactoryTst.createProduct2(1, true);
    List<PricebookEntry> pricebookentryList= HDT_UTL_DataFactoryTst.createPricebookEntry(product2List, true, pricebook.Id);
    List<Contact> contactList= HDT_UTL_DataFactoryTst.createContact(1, true,accountList[0].id);

    List<Order> orderAmmissibilitaKO= HDT_UTL_DataFactoryTst.createOrderWithPricebookAndPhaseNw(1, true, salesList,'HDT_RT_Attivazione',new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Phase__c'=>'Ammissibilità KO',
      'BillingProfile__c'=>billingProfileList[0].Id,
      'ServicePoint__c'=>servicePointList[0].Id
    } ); 
    List<Order> orderAmmissibilitaOK= HDT_UTL_DataFactoryTst.createOrderWithPricebookAndPhaseNw(1, true, salesList,'HDT_RT_Attivazione',new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Phase__c'=>'Ammissibilità OK',
      'BillingProfile__c'=>billingProfileList[0].Id,
      'ServicePoint__c'=>servicePointList[0].Id
    } ); 
    List<Order> orderDatiTecniciRicevuti= HDT_UTL_DataFactoryTst.createOrderWithPricebookAndPhaseNw(1, true, salesList,'HDT_RT_TemporaneaNuovaAtt',new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Phase__c'=>'Dati Tecnici Ricevuti',
      'BillingProfile__c'=>billingProfileList[0].Id,
      'ServicePoint__c'=>servicePointList[0].Id
    } ); 
    List<Order> orderEsitoOKdaDL= HDT_UTL_DataFactoryTst.createOrderWithPricebookAndPhaseNw(1, true, salesList,'HDT_RT_Attivazione',new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Phase__c'=>'Esito OK da DL',
      'BillingProfile__c'=>billingProfileList[0].Id,
      'ServicePoint__c'=>servicePointList[0].Id
    } ); 
    List<Order> orderEsitoKOdaDL= HDT_UTL_DataFactoryTst.createOrderWithPricebookAndPhaseNw(1, true, salesList,'HDT_RT_Attivazione',new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Phase__c'=>'Esito KO da DL',
      'BillingProfile__c'=>billingProfileList[0].Id,
      'ServicePoint__c'=>servicePointList[0].Id
    } ); 
    List<Order> orderAmmPrecheckOKSII= HDT_UTL_DataFactoryTst.createOrderWithPricebookAndPhaseNw(1, true, salesList,'HDT_RT_AttivazioneConModifica',new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Phase__c'=>'Amm. Precheck OK SII',
      'BillingProfile__c'=>billingProfileList[0].Id,
      'ServicePoint__c'=>servicePointList[0].Id
    } ); 
    List<Order> orderEsitoKOdaSII= HDT_UTL_DataFactoryTst.createOrderWithPricebookAndPhaseNw(1, true, salesList,'HDT_RT_AttivazioneConModifica',new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Phase__c'=>'Esito KO da SII',
      'BillingProfile__c'=>billingProfileList[0].Id,
      'ServicePoint__c'=>servicePointList[0].Id
    } );
    List<Order> orderEsitoOKdaSII= HDT_UTL_DataFactoryTst.createOrderWithPricebookAndPhaseNw(1, true, salesList,'HDT_RT_AttivazioneConModifica',new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Phase__c'=>'Esito OK da SII',
      'BillingProfile__c'=>billingProfileList[0].Id,
      'ServicePoint__c'=>servicePointList[0].Id
    } ); 
    List<Order> orderAnnullamentoInviato= HDT_UTL_DataFactoryTst.createOrderWithPricebookAndPhaseNw(1, true, salesList,'HDT_RT_AttivazioneConModifica',new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Phase__c'=>'Annullamento - Inviato al DL/SII',
      'BillingProfile__c'=>billingProfileList[0].Id,
      'ServicePoint__c'=>servicePointList[0].Id
    } ); 
    List<Order> orderAnnullamentoAmmissibilita= HDT_UTL_DataFactoryTst.createOrderWithPricebookAndPhaseNw(1, true, salesList,'HDT_RT_AttivazioneConModifica',new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Phase__c'=>'Annullamento - Ammissibilità OK',
      'BillingProfile__c'=>billingProfileList[0].Id,
      'ServicePoint__c'=>servicePointList[0].Id
    } );
    List<Order> orderErrorelavorazione= HDT_UTL_DataFactoryTst.createOrderWithPricebookAndPhaseNw(1, true, salesList,'HDT_RT_AttivazioneConModifica',new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Phase__c'=>'Errore lavorazione SAP',
      'BillingProfile__c'=>billingProfileList[0].Id,
      'ServicePoint__c'=>servicePointList[0].Id
    } ); 
    List<Order> orderAnnullamentoRicezione= HDT_UTL_DataFactoryTst.createOrderWithPricebookAndPhaseNw(1, true, salesList,'HDT_RT_CambioOfferta',new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Phase__c'=>'Annullamento SII - Ricezione',
      'BillingProfile__c'=>billingProfileList[0].Id,
      'ServicePoint__c'=>servicePointList[0].Id
    } ); 
    List<Order> orderCompletata= HDT_UTL_DataFactoryTst.createOrderWithPricebookAndPhaseNw(1, true, salesList,'HDT_RT_AttivazioneConModifica',new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Phase__c'=>'Completata',
      'BillingProfile__c'=>billingProfileList[0].Id,
      'ServicePoint__c'=>servicePointList[0].Id,
      'Pricebook2Id'=>pricebook.Id
    } );   
   // List<OrderItem> orderItem= HDT_UTL_DataFactoryTst.createOrderItem(1, true, orderCompletata[0].id, servicePointList[0].id, product2List[0].Id, pricebookentryList[0].id);

    //is not valid for all dev Name  List<Order> orderErroretecnicoinvio = HDT_UTL_DataFactoryTst.createOrderWithDeveloperName(1,true, accountList[0].id,'Errore tecnico invio a SAP','HDT_RT_VolturaConSwitch');//

    // INVALID_CROSS_REFERENCE_KEY, Record Type ID: this ID value isn't valid for the user: 0121X000002tnEsQAI:  List<Order> orderAmmPrecheckKOSII= HDT_UTL_DataFactoryTst.createOrderWithDeveloperName(1,true, accountList[0].id,'Amm. Precheck KO SII','HDT_RT_FlyingRequest');
    
    /* List<Order> orderEsitoOKdaDLS = HDT_UTL_DataFactoryTst.createOrderWithDeveloperName(1,true, accountList[0].id,'Esito OK da DL/SII','HDT_RT_Attivazione');

    List<Order> orderEsitoKOdaDLS = HDT_UTL_DataFactoryTst.createOrderWithDeveloperName(1,true, accountList[0].id,'Esito KO da DL/SII','HDT_RT_Attivazione');
   */
     //  INVALID_CROSS_REFERENCE_KEY, Record Type ID: this ID value isn't valid for the user: 0121X000002tnEsQAI:   List<Order> orderDatidiscordanti = HDT_UTL_DataFactoryTst.createOrderWithDeveloperName(1,true, accountList[0].id,'Dati discordanti','HDT_RT_FlyingRequest');
   
   
  }


@isTest
static void testHandleSalesProcessCategory2() {
  Order orderAmmissibilitaKO=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Ammissibilità KO' LIMIT 1];
  Order orderAmmissibilitaOK=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Ammissibilità OK' LIMIT 1];
  Order orderDatiTecnici=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Dati Tecnici Ricevuti' LIMIT 1];
  Test.startTest(); 
    //test requestType=NOTIF_ES with 'Esito KO da SII'
    new TestBuilder(orderAmmissibilitaKO,'Ammissibilità KO','NOTIF_ES');
    //test requestType=NOTIF_ES with 'Ammissibilità OK'
    new TestBuilder(orderAmmissibilitaOK,'Ammissibilità OK','NOTIF_ES');
    //test requestType=NOTIF_ES with 'Dati Tecnici Ricevuti'
    new TestBuilder(orderDatiTecnici,'Dati Tecnici Ricevuti','NOTIF_ES');
  Test.stopTest();
}



@isTest
static void testHandleSalesProcessCategory3() {

  Order orderEsitoKOdaDL=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Esito KO da DL' LIMIT 1];
  Order orderEsitoOKdaDL=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Esito OK da DL' LIMIT 1];
  Order orderAmmPrecheckOKS=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Amm. Precheck OK SII' LIMIT 1];
  Test.startTest(); 
    //test requestType=NOTIF_ES with 'Esito KO da DL'
    new TestBuilder(orderEsitoKOdaDL,'Esito KO da DL','NOTIF_ES');
    //test requestType=NOTIF_ES with 'Esito OK da DL'
    new TestBuilder(orderEsitoOKdaDL,'Esito OK da DL','NOTIF_ES');
    //test requestType=NOTIF_ES with 'Amm. Precheck OK SII'
    new TestBuilder(orderAmmPrecheckOKS,'Amm. Precheck OK SII','NOTIF_ES');
  Test.stopTest();
}


@isTest
static void testHandleSalesProcessCategory4() {
  Order orderEsitoKOdaS=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Esito KO da SII' LIMIT 1];
  Order orderEsitoOKdaS=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Esito OK da SII' LIMIT 1];
  Order orderAnnullamentoAmmissibilita=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Annullamento - Ammissibilità OK' LIMIT 1];
  Test.startTest(); 
    //test requestType=NOTIF_ES with 'Esito KO da SII'
    new TestBuilder(orderEsitoKOdaS,'Esito KO da SII','NOTIF_ES');
    //test requestType=NOTIF_ES with 'Esito OK da SII'
    new TestBuilder(orderEsitoOKdaS,'Esito OK da SII','NOTIF_ES');
     //test requestType=NOTIF_ES with 'Annullamento - Ammissibilità OK'
    new TestBuilder(orderAnnullamentoAmmissibilita,'Annullamento - Ammissibilità OK','NOTIF_ES');
  Test.stopTest();
}


@isTest
static void testHandleSalesProcessCategory5() {
  Order orderEsitoKOdaSII=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Esito KO da SII' LIMIT 1];
  Order orderEsitoOKdaSII=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Esito OK da SII' LIMIT 1]; 
  Order orderCompletata=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c,ServicePoint__c  FROM Order  WHERE Phase__c='Completata' LIMIT 1]; 
  Test.startTest(); 
    //test requestType=NOTIF_ES with 'Esito KO da SII'
    new TestBuilder(orderEsitoKOdaSII,'Esito KO da SII','NOTIF_ES');
    //test requestType=NOTIF_ES with 'Esito OK da SII'
    new TestBuilder(orderEsitoOKdaSII,'Esito OK da SII','NOTIF_ES'); 
    //test requestType=NOTIF_ES with 'Completata'
   // new TestBuilder(orderCompletata,'Completata','NOTIF_ES'); 
  Test.stopTest();
}


@isTest
static void testHandleSalesProcessCategory6() {
  Order orderAmmPrecheckOKSII=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Amm. Precheck OK SII' LIMIT 1]; 
  Order orderDatiTecniciRicevuti=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Dati Tecnici Ricevuti' LIMIT 1]; 
  Order orderErrorelavorazione=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Errore lavorazione SAP' LIMIT 1]; 
  Test.startTest(); 
    //test requestType=NOTIF_ES with 'Amm. Precheck OK SII'
    new TestBuilder(orderAmmPrecheckOKSII,'Amm. Precheck OK SII','NOTIF_ES');
    //test requestType=NOTIF_ES with 'Dati Tecnici Ricevuti'
    new TestBuilder(orderDatiTecniciRicevuti,'Dati Tecnici Ricevuti','NOTIF_ES'); 
    //test requestType=NOTIF_ES with 'Errore lavorazione SAP'
    new TestBuilder(orderErrorelavorazione,'Errore lavorazione SAP','NOTIF_ES'); 
  Test.stopTest();
}



@isTest
static void testHandleSalesProcessCategory7() {
  
  List<Account> accountList=[SELECT id FROM Account];
  List<ServicePoint__c> servicePointList=[SELECT id FROM ServicePoint__c];
  List<BillingProfile__c> billingProfileList=[SELECT id FROM BillingProfile__c];
  List<Sale__c> salesList=[SELECT id FROM Sale__c];
  List<Contact> contactList=[SELECT id FROM Contact];
  

  String profileId= HDT_UTL_DataFactoryTst.getProfileId('Hera Teleseller Partner User');
  String roleDevName=new HDT_UTL_Constants().USERROLE_DEVELOPERNAME_BACKOFFICE;  
  UserRole userrole = [SELECT Id  FROM UserRole  Where DeveloperName ='AG993UtentePartner' Limit 1];
  User  portalUser= HDT_UTL_DataFactoryTst.createCommunityUserWithRole(contactList[0], profileId,false,new Map<String,Object>{
    'UserRoleId'=>userrole.Id
  });
    List<Order> orderDatidiscordanti= HDT_UTL_DataFactoryTst.createOrderWithPricebookAndPhaseNw(1, true, salesList,'HDT_RT_SwitchInVolturaTecnica',new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Phase__c'=>'Dati discordanti',     
      'BillingProfile__c'=>billingProfileList[0].Id,
      'ServicePoint__c'=>servicePointList[0].Id
    } ); 
    List<Order> orderAmmPrecheckKOSII= HDT_UTL_DataFactoryTst.createOrderWithPricebookAndPhaseNw(1, true, salesList,'HDT_RT_SwitchInVolturaTecnica',new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Phase__c'=>'Amm. Precheck KO SII',
      'BillingProfile__c'=>billingProfileList[0].Id,
      'ServicePoint__c'=>servicePointList[0].Id
    } ); 
  /*
  system.runAs(portalUser){
    List<Order> orderDatidiscordanti= HDT_UTL_DataFactoryTst.createOrderWithPricebookAndPhaseNw(1, true, salesList,'HDT_RT_SwitchInVolturaTecnica',new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Phase__c'=>'Dati discordanti',     
      'BillingProfile__c'=>billingProfileList[0].Id,
      'ServicePoint__c'=>servicePointList[0].Id
    } ); 
    List<Order> orderAmmPrecheckKOSII= HDT_UTL_DataFactoryTst.createOrderWithPricebookAndPhaseNw(1, true, salesList,'HDT_RT_FlyingRequest',new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Phase__c'=>'Amm. Precheck KO SII',
      'BillingProfile__c'=>billingProfileList[0].Id,
      'ServicePoint__c'=>servicePointList[0].Id
    } ); 
  }*/
   
/*Test.startTest(); 
    //test requestType=NOTIF_ES with 'Amm. Precheck OK SII'
    new TestBuilder(orderAmmPrecheckOKSII,'Amm. Precheck OK SII','NOTIF_ES');
    //test requestType=NOTIF_ES with 'Dati Tecnici Ricevuti'
    new TestBuilder(orderDatiTecniciRicevuti,'Dati Tecnici Ricevuti','NOTIF_ES'); 
    //test requestType=NOTIF_ES with 'Errore lavorazione SAP'
    new TestBuilder(orderErrorelavorazione,'Errore lavorazione SAP','NOTIF_ES'); 
  Test.stopTest();*/
}


@isTest
static void testHandleSalesProcessCategory() {

  Order orderAnnullamentoRicezione=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Annullamento SII - Ricezione' LIMIT 1];
  Order orderAnnullamentoInviato=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Annullamento - Inviato al DL/SII' LIMIT 1];
  Test.startTest();
    //test requestType=NOTIF_ES  'Annullamento SII - Ricezione'
    new TestBuilder(orderAnnullamentoRicezione,'Annullamento SII - Ricezione','NOTIF_ES');
    //test requestType=NOTIF_ES with 'Annullamento - Inviato al DL/SII'
    new TestBuilder(orderAnnullamentoInviato,'Annullamento - Inviato al DL/SII','NOTIF_ES');

    //test requestType=RICH_PASS
    new TestBuilder(orderAnnullamentoRicezione,'Annullamento SII - Ricezione','RICH_PASS');
    //test requestType=RICH_PASS else 
    new TestBuilder(orderAnnullamentoRicezione,'RICH_PASS','RICH_PASS');
    //test requestType=NOTIF_ES else 
    new TestBuilder(orderAnnullamentoRicezione,'NOTIF_ES','NOTIF_ES');
    

    //test requestType=WSLead_Callback
    new TestBuilder(orderAnnullamentoRicezione,'Annullamento SII - Ricezione','WSLead_Callback');
    //test requestType=WSLead_Winback
    new TestBuilder(orderAnnullamentoRicezione,'Annullamento SII - Ricezione','WSLead_Winback');
    //test requestType=WSLead_CariBoll
    new TestBuilder(orderAnnullamentoRicezione,'Annullamento SII - Ricezione','WSLead_CariBoll');
    //test requestType=WSLead_HVAC
    new TestBuilder(orderAnnullamentoRicezione,'Annullamento SII - Ricezione','WSLead_HVAC');
    //test requestType=WSLead_SOL
    new TestBuilder(orderAnnullamentoRicezione,'Annullamento SII - Ricezione','WSLead_SOL');
    //test requestType=CMPDMP_PRV
    new TestBuilder(orderAnnullamentoRicezione,'Annullamento SII - Ricezione','CMPDMP_PRV');
    //test requestType=CMPDMP_ATTR
    new TestBuilder(orderAnnullamentoRicezione,'Annullamento SII - Ricezione','CMPDMP_ATTR');
    //test requestType=SIE34_7
    new TestBuilder(orderAnnullamentoRicezione,'Annullamento SII - Ricezione','SIE34_7');
    //test requestType=SIE34_6
    new TestBuilder(orderAnnullamentoRicezione,'Annullamento SII - Ricezione','SIE34_6');
    //test requestType=SIE34_3
    new TestBuilder(orderAnnullamentoRicezione,'Annullamento SII - Ricezione','SIE34_3');
    //test requestType=SIE34_2
    new TestBuilder(orderAnnullamentoRicezione,'Annullamento SII - Ricezione','SIE34_2');
    //test requestType=SIE34_1
    new TestBuilder(orderAnnullamentoRicezione,'Annullamento SII - Ricezione','SIE34_1');
    //test requestType=Else
    new TestBuilder(orderAnnullamentoRicezione,'Annullamento SII - Ricezione','Else');
  Test.stopTest();

}

}