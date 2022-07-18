/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 07-07-2022
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
      return '{"data" : [{"NrAtto" : "1","DataAtto" : "2020-01-01","TipoTributo" : "TIA","AccertamentoPer" : "Infedele dichiarazione","Stato" : "Emesso","BaseDati" :"In Attesa Aggiornamento","DataInizio" :"2010-01-01","DataFine" :"2030-01-01","Soggetto" :"Rossi Mario","Indirizzo" :"Via Roma Libera - Roma (RM)","Civico" :"1","Contratto" :"12345","SuperficieAccertata" :"100","CategoriaAccertata" :"1"},{"NrAtto" : "2","DataAtto" : "2021-01-01","TipoTributo" : "TARI","AccertamentoPer" : "Infedele dichiarazione","Stato" : "Notificato","BaseDati" :"Aggiornamento Ordinato","DataInizio" :"2011-01-01","DataFine" :"2031-01-01","Soggetto" :"Rossi Mario","Indirizzo" :"Via Roma Libera - Roma (RM)","Civico" :"1","Contratto" :"67890","SuperficieAccertata" :"100","CategoriaAccertata" :"2"},{"NrAtto" : "3","DataAtto" : "2022-01-01","TipoTributo" : "TIA","AccertamentoPer" : "Omessa dichiarazione","Stato" : "Rateizzato","BaseDati" :"In Attesa Caricamento","DataInizio" :"2012-01-01","DataFine" :"2032-01-01","Soggetto" :"Rossi Mario","Indirizzo" :"Via Roma Libera - Roma (RM)","Civico" :"1","Contratto" :"12978","SuperficieAccertata" :"100","CategoriaAccertata" :"3"},{"NrAtto" : "4","DataAtto" : "2023-01-01","TipoTributo" : "TARI","AccertamentoPer" : "Omessa dichiarazione","Stato" : "Pagato","BaseDati" :"Caricamento Ordinato","DataInizio" :"2013-01-01","DataFine" :"2033-01-01","Soggetto" :"Rossi Mario","Indirizzo" :"Via Roma Libera - Roma (RM)","Civico" :"1","Contratto" :"98765","SuperficieAccertata" :"100","CategoriaAccertata" :"4"}]}';
  }
}