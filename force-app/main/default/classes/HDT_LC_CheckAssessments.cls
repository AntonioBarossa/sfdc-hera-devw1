/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 21-07-2022
 * @last modified by  : Giacinto Florio
**/
public with sharing class HDT_LC_CheckAssessments {

    private static final String REQUEST_PATH = '/data-enrichment/paperworks/search';

	public virtual class HDT_WRP_AssessmentsReq extends HDT_WS_Request{
		String codiceFiscalePartitaIva;
		String comuneFornitura;
		String tipoPersona;

		public HDT_WRP_AssessmentsReq(String cfPiva, String comuneFornitura, String tipoPersona) {
			this.codiceFiscalePartitaIva = cfPiva;
			this.comuneFornitura = comuneFornitura; 
			this.tipoPersona = tipoPersona;
		}
	}

	public class HDT_WS_CheckAssessmentsResponse extends HDT_WS_Response{
		@AuraEnabled public String status {get;set;}
		@AuraEnabled public List<HDT_WRP_RowAssessment> data {get;set;}
		public List<HDT_WRP_MulesoftResponse.HDT_WRP_ErrorDetails> errorDetails {get;set;}
	}

	@SuppressWarnings('PMD.TooManyFields')
	private class HDT_WRP_RowAssessment {

    	@AuraEnabled public String chiaveContribuente;
		@AuraEnabled public String pratica;
		@AuraEnabled public String numeroProvvedimento;
		@AuraEnabled public String dataProvvedimento;
		@AuraEnabled public String ab;
		@AuraEnabled public String bs;
		@AuraEnabled public String ragioneSociale;
		@AuraEnabled public String citta;
		@AuraEnabled public String via;
		@AuraEnabled public String civico;
		@AuraEnabled public String barrato;
		@AuraEnabled public String scala;
		@AuraEnabled public String provincia;
		@AuraEnabled public String annoEmisProv;
		@AuraEnabled public String tipoTributo;
		@AuraEnabled public String causale;
		@AuraEnabled public String dataNotifica;
		@AuraEnabled public String dataAdesione;
		@AuraEnabled public String dataRuolo;
		@AuraEnabled public String dataCoattivo;
		@AuraEnabled public String dataContenzioso;
		@AuraEnabled public String datatRegistroPagamento;
		@AuraEnabled public String dataPagamentoAvviso;
		@AuraEnabled public String stato;
		@AuraEnabled public String tipoAccertamento;
		@AuraEnabled public String messaggio;

	}
  
	private static HDT_WS_CheckAssessmentsResponse doCallout(String cfPiva, String comuneFornitura, String tipoPersona){
		HDT_WRP_AssessmentsReq req = new HDT_WRP_AssessmentsReq(cfPiva,comuneFornitura,tipoPersona);
		HDT_WS_CheckAssessmentsResponse res = (HDT_WS_CheckAssessmentsResponse)HDT_WS_HTTPServiceCall.sendRequest('MulesoftBasePath',REQUEST_PATH,'POST', req,HDT_WS_CheckAssessmentsResponse.class);
		return res;
	} 
  
	@AuraEnabled(cacheable=true)
	public static HDT_WS_CheckAssessmentsResponse handleSearch(String cfPiva, String comuneFornitura, String tipoPersona) {
		//String response = '{"data" : [{"NrAtto" : "1","DataAtto" : "23/11/2016","TipoTributo" : "3","AccertamentoPer" : "Infedele dichiarazione","Stato" : "5","BaseDati" :"In Attesa Aggiornamento","DataInizio" :"2010-01-01","DataFine" :"2030-01-01","Soggetto" :"9","Indirizzo" :"10","Civico" :"11","Contratto" :"12","SuperficieAccertata" :"13","CategoriaAccertata" :"14"},{"NrAtto" : "2","DataAtto" : "2021-01-01","TipoTributo" : "23","AccertamentoPer" : "Infedele dichiarazione","Stato" : "25","BaseDati" :"Aggiornamento Ordinato","DataInizio" :"2011-01-01","DataFine" :"2031-01-01","Soggetto" :"9","Indirizzo" :"10","Civico" :"11","Contratto" :"12","SuperficieAccertata" :"13","CategoriaAccertata" :"14"},{"NrAtto" : "3","DataAtto" : "2022-01-01","TipoTributo" : "33","AccertamentoPer" : "Omessa dichiarazione","Stato" : "35","BaseDati" :"In Attesa Caricamento","DataInizio" :"2012-01-01","DataFine" :"2032-01-01","Soggetto" :"9","Indirizzo" :"10","Civico" :"11","Contratto" :"12","SuperficieAccertata" :"13","CategoriaAccertata" :"14"},{"NrAtto" : "4","DataAtto" : "2023-01-01","TipoTributo" : "3","AccertamentoPer" : "Omessa dichiarazione","Stato" : "5","BaseDati" :"Caricamento Ordinato","DataInizio" :"2013-01-01","DataFine" :"2033-01-01","Soggetto" :"9","Indirizzo" :"10","Civico" :"11","Contratto" :"12","SuperficieAccertata" :"13","CategoriaAccertata" :"14"}]}';
		HDT_WS_CheckAssessmentsResponse response = doCallout(cfPiva, comuneFornitura, tipoPersona);
		//formatDate(response);
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