/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 13-06-2022
 * @last modified by  : Giacinto Florio
**/
public with sharing class HDT_LC_CheckAssessments {

  @AuraEnabled(cacheable=true)
    public static String handleSearch() {
      return '{"data" : [{"NrAtto" : "1","DataAtto" : "2020-01-01","TipoTributo" : "3","AccertamentoPer" : "4","Stato" : "5","BaseDati" :"6","DataInizio" :"2010-01-01","DataFine" :"8","Soggetto" :"9","Indirizzo" :"10","Civico" :"11","Contratto" :"12","SuperficieAccertata" :"13","CategoriaAccertata" :"14"},{"NrAtto" : "2","DataAtto" : "2021-01-01","TipoTributo" : "23","AccertamentoPer" : "24","Stato" : "25","BaseDati" :"6","DataInizio" :"2011-01-01","DataFine" :"8","Soggetto" :"9","Indirizzo" :"10","Civico" :"11","Contratto" :"12","SuperficieAccertata" :"13","CategoriaAccertata" :"14"},{"NrAtto" : "3","DataAtto" : "2022-01-01","TipoTributo" : "33","AccertamentoPer" : "34","Stato" : "35","BaseDati" :"6","DataInizio" :"2012-01-01","DataFine" :"8","Soggetto" :"9","Indirizzo" :"10","Civico" :"11","Contratto" :"12","SuperficieAccertata" :"13","CategoriaAccertata" :"14"}]}';
  }
}