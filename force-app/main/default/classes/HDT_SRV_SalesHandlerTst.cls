@isTest
private class HDT_SRV_SalesHandlerTst {


/*

    public List<HDT_WRP_MrrRequest.HDT_WRP_Header> createWrpHeader(Integer amount, Boolean doInsert, Map<String,Object> params){
        List<HDT_WRP_MrrRequest.HDT_WRP_Header> headerList=new List<HDT_WRP_MrrRequest.HDT_WRP_Header>();

		for (Integer i=0; i<amount; i++){

			HDT_WRP_MrrRequest.HDT_WRP_Header header=new HDT_WRP_MrrRequest.HDT_WRP_Header();

			header.requestType=(String)params.get('requestType');

			headerList.add(header);
		}

		if (doInsert){

			insert headerList;
		}

		return headerList;
	}






     public List<HDT_WRP_MrrRequest.HDT_WRP_Request> createWrpRequest(Integer amount, Boolean doInsert, Map<String,List<Object>> params){
        List<HDT_WRP_MrrRequest.HDT_WRP_Request> requestList=new List<HDT_WRP_MrrRequest.HDT_WRP_Request>();

		for (Integer i=0; i<amount; i++){

			HDT_WRP_MrrRequest.HDT_WRP_Request request=new HDT_WRP_MrrRequest.HDT_WRP_Request();

			request.header=(HDT_WRP_MrrRequest.HDT_WRP_Header)params.get('header');
            request.objects=(List<HDT_WRP_MrrRequest.HDT_WRP_Object>)params.get('objects');
			requestList.add(request);
		}

		if (doInsert){

			insert requestList;
		}

		return requestList;
	}

*/

@testSetup 
  static void setup() {

    List<Account> accountList= HDT_UTL_DataFactoryTst.createAccountResidenziale(1,true,'HERA COMM','Persona fisica','Famiglie');

    List<Order> order = HDT_UTL_DataFactoryTst.createOrder(1,true, accountList[0].id,'Bozza');

  }
    
  @isTest
  static void testManageSalesProcessCategory() {


    Order order=[ SELECT  id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c  FROM Order];

    RestResponse res = new RestResponse();
    res.statusCode = 200;

    RestContext.response = res;


    /* Configuration of request */
    HDT_WRP_MrrRequest.HDT_WRP_Header header=new HDT_WRP_MrrRequest.HDT_WRP_Header();
    header.requestType='NOTIF_ES';

    // create fields
    HDT_WRP_MrrRequest.HDT_WRP_Field field=new HDT_WRP_MrrRequest.HDT_WRP_Field();
    field.name='ATTIVITA';
    field.value='Gestione Switch in Ripristinatorio';


    HDT_WRP_MrrRequest.HDT_WRP_Field field1=new HDT_WRP_MrrRequest.HDT_WRP_Field();
    field1.name='RECORD_ID';
    field1.value=order.Id;

    HDT_WRP_MrrRequest.HDT_WRP_Field field2=new HDT_WRP_MrrRequest.HDT_WRP_Field();
    field2.name='FASE';
    field2.value='Ammissibilità KO';

    List<HDT_WRP_MrrRequest.HDT_WRP_Field> fieldList=new List<HDT_WRP_MrrRequest.HDT_WRP_Field> ();
    fieldList.add(field);
    fieldList.add(field1);
    fieldList.add(field2);


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

    

    HDT_WRP_MrrResponse.HDT_WRP_Response processes = salesHandler.manageSalesProcessCategory(request,response);
      /*  System.assertEquals(23, processes.size(),'we created 23  HDT_WRP_Process');
      System.assertNotEquals(2, processes.size(),'we have created more than two HDT_WRP_Process');*/
  }


}