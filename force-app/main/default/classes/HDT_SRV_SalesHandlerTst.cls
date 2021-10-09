@isTest
private class HDT_SRV_SalesHandlerTst {

  class TestBuilder{
    public HDT_WRP_MrrResponse.HDT_WRP_Response processes;
    public TestBuilder(Order order,String phase, String requestType){
      RestResponse res = new RestResponse();
      res.statusCode = 200;
      RestContext.response = res;

      /* Configuration of request for 'Ammissibilità KO' */
      HDT_WRP_MrrRequest.HDT_WRP_Header header=new HDT_WRP_MrrRequest.HDT_WRP_Header();
      header.requestType=requestType;

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
      HDT_WRP_MrrRequest.HDT_WRP_Object obj=new HDT_WRP_MrrRequest.HDT_WRP_Object();
      obj.fields=fieldList;
      List<HDT_WRP_MrrRequest.HDT_WRP_Object> objList=new List<HDT_WRP_MrrRequest.HDT_WRP_Object> ();
      objList.add(obj);
      HDT_WRP_MrrRequest.HDT_WRP_Request request=new HDT_WRP_MrrRequest.HDT_WRP_Request();
      request.header=header;
      request.objects=objList;
    
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
    List<Order> orderAmmissibilitaKO = HDT_UTL_DataFactoryTst.createOrderWithDeveloperName(1,true, accountList[0].id,'Ammissibilità KO','HDT_RT_Attivazione');
    List<Order> orderAmmissibilitaOK = HDT_UTL_DataFactoryTst.createOrderWithDeveloperName(1,true, accountList[0].id,'Ammissibilità OK','HDT_RT_Attivazione');
    List<Order> orderDatiTecniciRicevuti = HDT_UTL_DataFactoryTst.createOrderWithDeveloperName(1,true, accountList[0].id,'Dati Tecnici Ricevuti','HDT_RT_TemporaneaNuovaAtt');

    //  is not valid for all dev Name  List<Order> orderErroretecnicoinvio = HDT_UTL_DataFactoryTst.createOrderWithDeveloperName(1,true, accountList[0].id,'Errore tecnico invio a SAP','HDT_RT_VolturaConSwitch');//

    List<Order> orderEsitoOKdaDL = HDT_UTL_DataFactoryTst.createOrderWithDeveloperName(1,true, accountList[0].id,'Esito OK da DL','HDT_RT_Attivazione');   
    List<Order> orderEsitoKOdaDL = HDT_UTL_DataFactoryTst.createOrderWithDeveloperName(1,true, accountList[0].id,'Esito KO da DL','HDT_RT_Attivazione');
    // INVALID_CROSS_REFERENCE_KEY, Record Type ID: this ID value isn't valid for the user: 0121X000002tnEsQAI:  List<Order> orderAmmPrecheckKOSII= HDT_UTL_DataFactoryTst.createOrderWithDeveloperName(1,true, accountList[0].id,'Amm. Precheck KO SII','HDT_RT_FlyingRequest');
    List<Order> orderAmmPrecheckOKSII= HDT_UTL_DataFactoryTst.createOrderWithDeveloperName(1,true, accountList[0].id,'Amm. Precheck OK SII','HDT_RT_AttivazioneConModifica');
    List<Order> orderEsitoKOdaSII = HDT_UTL_DataFactoryTst.createOrderWithDeveloperName(1,true, accountList[0].id,'Esito KO da SII','HDT_RT_AttivazioneConModifica');
    List<Order> orderEsitoOKdaSII = HDT_UTL_DataFactoryTst.createOrderWithDeveloperName(1,true, accountList[0].id,'Esito OK da SII','HDT_RT_AttivazioneConModifica');
    List<Order> orderAnnullamentoInviato = HDT_UTL_DataFactoryTst.createOrderWithDeveloperName(1,true, accountList[0].id,'Annullamento - Inviato al DL/SII','HDT_RT_AttivazioneConModifica');
    List<Order> orderAnnullamentoAmmissibilita = HDT_UTL_DataFactoryTst.createOrderWithDeveloperName(1,true, accountList[0].id,'Annullamento - Ammissibilità OK','HDT_RT_AttivazioneConModifica');

    /* List<Order> orderEsitoOKdaDLS = HDT_UTL_DataFactoryTst.createOrderWithDeveloperName(1,true, accountList[0].id,'Esito OK da DL/SII','HDT_RT_Attivazione');

    List<Order> orderEsitoKOdaDLS = HDT_UTL_DataFactoryTst.createOrderWithDeveloperName(1,true, accountList[0].id,'Esito KO da DL/SII','HDT_RT_Attivazione');
   */
    List<Order> orderErrorelavorazione  = HDT_UTL_DataFactoryTst.createOrderWithDeveloperName(1,true, accountList[0].id,'Errore lavorazione SAP','HDT_RT_AttivazioneConModifica');
    //  INVALID_CROSS_REFERENCE_KEY, Record Type ID: this ID value isn't valid for the user: 0121X000002tnEsQAI:   List<Order> orderDatidiscordanti = HDT_UTL_DataFactoryTst.createOrderWithDeveloperName(1,true, accountList[0].id,'Dati discordanti','HDT_RT_FlyingRequest');
    List<Order> orderCompletata = HDT_UTL_DataFactoryTst.createOrderWithDeveloperName(1,true, accountList[0].id,'Completata','HDT_RT_AttivazioneConModifica');
    List<Order> orderAnnullamentoRicezione = HDT_UTL_DataFactoryTst.createOrderWithDeveloperName(1,true, accountList[0].id,'Annullamento SII - Ricezione','HDT_RT_CambioOfferta');
  }

  /*
@isTest
static void testHandleSalesProcessCategory2() {

  Order orderAnnullamentoRicezione=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Annullamento SII - Ricezione' LIMIT 1];
  Order orderAnnullamentoAmmissibilita=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Annullamento - Ammissibilità OK' LIMIT 1];
  Order orderAnnullamentoInviato=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Annullamento - Inviato al DL/SII' LIMIT 1];
  
  Order orderEsitoKOdaSII=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Esito KO da SII' LIMIT 1];
 // Order orderEsitoOKdaSII=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Esito OK da SII' LIMIT 1]; 

  Order orderAmmissibilitaKO=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Ammissibilità KO' LIMIT 1];
  Order orderAmmissibilitaOK=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Ammissibilità OK' LIMIT 1];
  Order orderDatiTecnici=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Dati Tecnici Ricevuti' LIMIT 1];
  Order orderEsitoKOdaDL=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Esito KO da DL' LIMIT 1];
  Order orderEsitoOKdaDL=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Esito OK da DL' LIMIT 1];
 
  Order orderAmmPrecheckOKS=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Amm. Precheck OK SII' LIMIT 1];
  Order orderEsitoKOdaS=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Esito KO da SII' LIMIT 1];
  Order orderEsitoOKdaS=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Esito OK da SII' LIMIT 1];
 
Test.startTest(); 
  //test requestType=NOTIF_ES with 'Esito KO da SII'
  new TestBuilder(orderAmmissibilitaKO,'Ammissibilità KO','NOTIF_ES');
  //test requestType=NOTIF_ES with 'Ammissibilità OK'
  new TestBuilder(orderAmmissibilitaOK,'Ammissibilità OK','NOTIF_ES');
  //test requestType=NOTIF_ES with 'Dati Tecnici Ricevuti'
  new TestBuilder(orderDatiTecnici,'Dati Tecnici Ricevuti','NOTIF_ES');
  
  //test requestType=NOTIF_ES with 'Esito KO da DL'
  new TestBuilder(orderEsitoKOdaDL,'Esito KO da DL','NOTIF_ES');
  //test requestType=NOTIF_ES with 'Esito OK da DL'
  new TestBuilder(orderEsitoOKdaDL,'Esito OK da DL','NOTIF_ES');
  //test requestType=NOTIF_ES with 'Amm. Precheck OK SII'
  new TestBuilder(orderAmmPrecheckOKS,'Amm. Precheck OK SII','NOTIF_ES');

  Test.stopTest();
}

*/

@isTest
static void testHandleSalesProcessCategory() {

  Order orderAnnullamentoRicezione=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Annullamento SII - Ricezione' LIMIT 1];
  Order orderAnnullamentoAmmissibilita=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Annullamento - Ammissibilità OK' LIMIT 1];
  Order orderAnnullamentoInviato=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Annullamento - Inviato al DL/SII' LIMIT 1];
  
  Order orderEsitoKOdaSII=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Esito KO da SII' LIMIT 1];
  Order orderEsitoOKdaSII=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Esito OK da SII' LIMIT 1]; 

  Order orderAmmissibilitaKO=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Ammissibilità KO' LIMIT 1];
  Order orderAmmissibilitaOK=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Ammissibilità OK' LIMIT 1];
  Order orderDatiTecnici=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Dati Tecnici Ricevuti' LIMIT 1];
  Order orderEsitoKOdaDL=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Esito KO da DL' LIMIT 1];
  Order orderEsitoOKdaDL=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Esito OK da DL' LIMIT 1];
 
  Order orderAmmPrecheckOKS=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Amm. Precheck OK SII' LIMIT 1];
  Order orderEsitoKOdaS=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Esito KO da SII' LIMIT 1];
  Order orderEsitoOKdaS=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order  WHERE Phase__c='Esito OK da SII' LIMIT 1];
 

Test.startTest();
  //test requestType=NOTIF_ES with 'Esito KO da SII'
  new TestBuilder(orderAmmissibilitaKO,'Ammissibilità KO','NOTIF_ES');
  //test requestType=NOTIF_ES with 'Ammissibilità OK'
  new TestBuilder(orderAmmissibilitaOK,'Ammissibilità OK','NOTIF_ES');
  //test requestType=NOTIF_ES with 'Dati Tecnici Ricevuti'
  new TestBuilder(orderDatiTecnici,'Dati Tecnici Ricevuti','NOTIF_ES');
  
  //test requestType=NOTIF_ES with 'Esito KO da DL'
  new TestBuilder(orderEsitoKOdaDL,'Esito KO da DL','NOTIF_ES');
  //test requestType=NOTIF_ES with 'Esito OK da DL'
  new TestBuilder(orderEsitoOKdaDL,'Esito OK da DL','NOTIF_ES');
  //test requestType=NOTIF_ES with 'Amm. Precheck OK SII'
  new TestBuilder(orderAmmPrecheckOKS,'Amm. Precheck OK SII','NOTIF_ES');

  /*
  //test requestType=NOTIF_ES with 'Esito KO da SII'
  new TestBuilder(orderEsitoKOdaS,'Esito KO da SII','NOTIF_ES');
  //test requestType=NOTIF_ES with 'Esito OK da SII'
  new TestBuilder(orderEsitoOKdaS,'Esito OK da SII','NOTIF_ES');


 
 //test requestType=NOTIF_ES  'Annullamento SII - Ricezione'
  new TestBuilder(orderAnnullamentoRicezione,'Annullamento SII - Ricezione','NOTIF_ES');
   //test requestType=NOTIF_ES with 'Annullamento - Ammissibilità OK'
  new TestBuilder(orderAnnullamentoAmmissibilita,'Annullamento - Ammissibilità OK','NOTIF_ES');
  //test requestType=NOTIF_ES with 'Annullamento - Inviato al DL/SII'
  new TestBuilder(orderAnnullamentoInviato,'Annullamento - Inviato al DL/SII','NOTIF_ES');
  
  //test requestType=NOTIF_ES with 'Esito KO da SII'
  new TestBuilder(orderEsitoKOdaSII,'Esito KO da SII','NOTIF_ES');
*/

  //test requestType=NOTIF_ES with 'Esito OK da SII'
  new TestBuilder(orderEsitoOKdaSII,'Esito OK da SII','NOTIF_ES');
  //test requestType=NOTIF_ES with 'Annullamento - Inviato al DL/SII'
  new TestBuilder(orderAnnullamentoInviato,'Annullamento - Inviato al DL/SII','NOTIF_ES');




  //test requestType=RICH_PASS
  new TestBuilder(orderAnnullamentoRicezione,'Annullamento SII - Ricezione','RICH_PASS');
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