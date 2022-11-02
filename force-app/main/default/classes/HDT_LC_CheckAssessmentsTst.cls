/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 25-08-2022
 * @last modified by  : Giacinto Florio
**/
@isTest
public with sharing class HDT_LC_CheckAssessmentsTst {
    
    @TestSetup
    static void makedata(){     
     
         createWebServiceConfiguration('CheckAssessments', 'Callout:MulesoftBasePath/data-enrichment/paperworks/search', 'POST', 'testUser');
    }

    public static void createWebServiceConfiguration (String name, String endpoint, String method, String user) {

		HDT_WebServiceConfiguration__c wsConfig = new HDT_WebServiceConfiguration__c(
			Name = name,
			Endpoint__c = endpoint,
			Method__c = method,
			User__c = user         
		);
		
		insert wsConfig;
	}

    @isTest
    public static void handleSearchTest() {

        HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
		
        Test.setMock(HttpCalloutMock.class, mock);

        HDT_LC_CheckAssessments.HDT_WRP_RowAssessment dataObj = new HDT_LC_CheckAssessments.HDT_WRP_RowAssessment();
        dataObj.chiaveContribuente = '';
        dataObj.pratica = '';
        dataObj.numeroProvvedimento = '';
        dataObj.dataProvvedimento = '';
        dataObj.ab = '';
        dataObj.bs = '';
        dataObj.ragioneSociale = '';
        dataObj.citta = '';
        dataObj.via = '';
        dataObj.civico = '';
        dataObj.barrato = '';
        dataObj.scala = '';
        dataObj.provincia = '';
        dataObj.annoEmisProv = '';
        dataObj.tipoTributo = '';
        dataObj.causale = '';
        dataObj.dataNotifica = '';
        dataObj.dataAdesione = '';
        dataObj.dataRuolo = '';
        dataObj.dataCoattivo = '';
        dataObj.dataContenzioso = '';
        dataObj.datatRegistroPagamento = '';
        dataObj.dataPagamentoAvviso = '';
        dataObj.stato = '';
        dataObj.tipoAccertamento = '';
        dataObj.messaggio = '';

        List<HDT_LC_CheckAssessments.HDT_WRP_RowAssessment> dataList = new List<HDT_LC_CheckAssessments.HDT_WRP_RowAssessment>();
        dataList.add(dataObj);

        HDT_LC_CheckAssessments.HDT_WS_CheckAssessmentsResponse checkAssessmentsResp = new HDT_LC_CheckAssessments.HDT_WS_CheckAssessmentsResponse();
        checkAssessmentsResp.status = ''; 
        checkAssessmentsResp.data = dataList;

        Test.startTest(); 
        HDT_LC_CheckAssessments.HDT_WS_CheckAssessmentsResponse res = (HDT_LC_CheckAssessments.HDT_WS_CheckAssessmentsResponse) HDT_LC_CheckAssessments.handleSearch('01234567890','Roma','Persona');
        System.debug('@@@@' + res);
        // System.assertEquals(200, res.statusCode, 'The call was not successful');
        System.assertNotEquals(400, res.statusCode, 'The returned status code was not correct');
    }

}
