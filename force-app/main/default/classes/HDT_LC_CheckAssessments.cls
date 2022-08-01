/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 21-07-2022
 * @last modified by  : Giacinto Florio
**/
public with sharing class HDT_LC_CheckAssessments {

    private static final String REQUEST_PATH = '/assessments';

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

    String key_contribuente;
		String pratica;
		String nr_provvedimento;
		String data_provvedimento;
		String ab;
		String bis;
		String ragione_sociale;
		String citta;
		String via;
		String civico;
		String provincia;
		String anno_emis_prov;
		String tipo_tributo;
		String causale;
		String data_notifica;
		String data_contenzioso;
		String stato;
		String tipo_accertamento;

}
  
  public static HDT_WS_ArrichmentDataEntityResponse doCallout(String cfPiva, String comuneFornitura, String tipoPersona){
    
    HDT_WRP_AssessmentsReq req = new HDT_WRP_AssessmentsReq(cfPiva,comuneFornitura,tipoPersona);
    HDT_WS_ArrichmentDataEntityResponse res = (HDT_WS_ArrichmentDataEntityResponse)HDT_WS_HTTPServiceCall.sendRequest('BasePath',REQUEST_PATH,'POST', req,HDT_WS_ArrichmentDataEntityResponse.class);
    return res;
  } 
  
  @AuraEnabled(cacheable=true)
    public static String handleSearch(String cf_piva, String comune_fornitura, String tipo_persona) {
      String response = '{"data" : [{"NrAtto" : "1","DataAtto" : "23/11/2016","TipoTributo" : "3","AccertamentoPer" : "Infedele dichiarazione","Stato" : "5","BaseDati" :"In Attesa Aggiornamento","DataInizio" :"2010-01-01","DataFine" :"2030-01-01","Soggetto" :"9","Indirizzo" :"10","Civico" :"11","Contratto" :"12","SuperficieAccertata" :"13","CategoriaAccertata" :"14"},{"NrAtto" : "2","DataAtto" : "2021-01-01","TipoTributo" : "23","AccertamentoPer" : "Infedele dichiarazione","Stato" : "25","BaseDati" :"Aggiornamento Ordinato","DataInizio" :"2011-01-01","DataFine" :"2031-01-01","Soggetto" :"9","Indirizzo" :"10","Civico" :"11","Contratto" :"12","SuperficieAccertata" :"13","CategoriaAccertata" :"14"},{"NrAtto" : "3","DataAtto" : "2022-01-01","TipoTributo" : "33","AccertamentoPer" : "Omessa dichiarazione","Stato" : "35","BaseDati" :"In Attesa Caricamento","DataInizio" :"2012-01-01","DataFine" :"2032-01-01","Soggetto" :"9","Indirizzo" :"10","Civico" :"11","Contratto" :"12","SuperficieAccertata" :"13","CategoriaAccertata" :"14"},{"NrAtto" : "4","DataAtto" : "2023-01-01","TipoTributo" : "3","AccertamentoPer" : "Omessa dichiarazione","Stato" : "5","BaseDati" :"Caricamento Ordinato","DataInizio" :"2013-01-01","DataFine" :"2033-01-01","Soggetto" :"9","Indirizzo" :"10","Civico" :"11","Contratto" :"12","SuperficieAccertata" :"13","CategoriaAccertata" :"14"}]}';
      formatDate(response);
      return response;
    }

  //<DATA_PROVVEDIMENTO>23/11/2016</DATA_PROVVEDIMENTO> 2010-01-01
  public static String formatDate(String field){
    String giorno = field.substringBefore('/');
    String mese   = field.substringBetween('/');
    String anno   = field.substringAfterLast('/');
    return anno+'-'+mese+'-'+giorno;
  }
}