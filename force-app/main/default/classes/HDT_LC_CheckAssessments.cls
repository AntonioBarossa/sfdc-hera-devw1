/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 22-06-2022
 * @last modified by  : Giacinto Florio
**/
public with sharing class HDT_LC_CheckAssessments {

    private static final String REQUEST_PATH = '/assessments';

    public class HDT_WRP_DataResponseObject{
        @AuraEnabled public HDT_WRP_testataObject testata{get;set;}
        @AuraEnabled public List<HDT_WRP_posizioniResponseObject> posizioni{get;set;}
    }
    public class HDT_WRP_TestataObject{
        @AuraEnabled public String esito{get;set;}
        @AuraEnabled public String messaggio{get;set;}
    }
    public class HDT_WRP_PosizioniResponseObject{
        @AuraEnabled public String campo{get;set;}
        @AuraEnabled public String valore{get;set;}
    }
    public class HDT_WRP_ErrorResponseObject{
        @AuraEnabled public String code{get;set;}
        @AuraEnabled public String message{get;set;}
        @AuraEnabled public String additionalInfo{get;set;}
    }

    public virtual class HDT_WRP_AssessmentsReq extends HDT_WS_Request{
      String cfPiva;
      String comuneFornitura;
      String tipoPersona;

      public HDT_WRP_AssessmentsReq(String cfPiva, String comuneFornitura, String tipoPersona) {
        this.cfPiva = cfPiva;
        this.comuneFornitura = comuneFornitura; 
        this.tipoPersona = tipoPersona;
      }
  }

  public class HDT_WS_CheckAssessmentsResponse extends HDT_WS_Response {

    @AuraEnabled public String status{get;set;}
    @AuraEnabled public String correlationId{get;set;}
    @AuraEnabled public String timestamp{get;set;}
    @AuraEnabled public HDT_WRP_DataResponseObject data{get;set;}
    @AuraEnabled public List<HDT_WRP_ErrorResponseObject> errorDetails{get;set;}

    public HDT_WS_CheckAssessmentsResponse(){
       this.data =  new HDT_WRP_DataResponseObject();
       this.errorDetails = new List<HDT_WRP_ErrorResponseObject>();
    }
    
}
  
  public static HDT_WS_ArrichmentDataEntityResponse doCallout(String cfPiva, String comuneFornitura, String tipoPersona){
    
    HDT_WRP_AssessmentsReq req = new HDT_WRP_AssessmentsReq(cfPiva,comuneFornitura,tipoPersona);
    HDT_WS_ArrichmentDataEntityResponse res = (HDT_WS_ArrichmentDataEntityResponse) HDT_WS_HTTPServiceCall.sendRequest('BasePath',REQUEST_PATH,'POST', req,HDT_WS_CheckAssessmentsResponse.class);
    return res;
  } 
  
  @AuraEnabled(cacheable=true)
    public static String handleSearch(String cf_piva, String comune_fornitura, String tipo_persona) {
      String response = '';
      return '{"data" : [{"NrAtto" : "1","DataAtto" : "2020-01-01","TipoTributo" : "3","AccertamentoPer" : "4","Stato" : "5","BaseDati" :"6","DataInizio" :"2010-01-01","DataFine" :"8","Soggetto" :"9","Indirizzo" :"10","Civico" :"11","Contratto" :"12","SuperficieAccertata" :"13","CategoriaAccertata" :"14"},{"NrAtto" : "2","DataAtto" : "2021-01-01","TipoTributo" : "23","AccertamentoPer" : "24","Stato" : "25","BaseDati" :"6","DataInizio" :"2011-01-01","DataFine" :"8","Soggetto" :"9","Indirizzo" :"10","Civico" :"11","Contratto" :"12","SuperficieAccertata" :"13","CategoriaAccertata" :"14"},{"NrAtto" : "3","DataAtto" : "2022-01-01","TipoTributo" : "33","AccertamentoPer" : "34","Stato" : "35","BaseDati" :"6","DataInizio" :"2012-01-01","DataFine" :"8","Soggetto" :"9","Indirizzo" :"10","Civico" :"11","Contratto" :"12","SuperficieAccertata" :"13","CategoriaAccertata" :"14"}]}';
  }
}
