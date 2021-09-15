public with sharing class HDT_WS_RicCreBpCaRequest extends HDT_WS_Request{
  public string numeroSR {get;set;}
  public string codiceCausale {get;set;}
  public Integer dataCreazione {get;set;}
  public string cancellaBPAlternativo {get;set;}
  public string nomeContatto {get;set;}
  public HDT_WS_RicCreBpCaRequestAccount account {get;set;}
  public HDT_WS_RicCreBpCaRequestGrupIva ordine {get;set;}
  
  public HDT_WS_RicCreBpCaRequest(){
    account = new HDT_WS_RicCreBpCaRequestAccount();
    account.indirizzo = new HDT_WS_RicCreBpCaRequestAddress();
    account.gruppoIva = new HDT_WS_RicCreBpCaRequestGrupIva2();
    ordine = new HDT_WS_RicCreBpCaRequestGrupIva();
    ordine.datiBancari = new HDT_WS_RicCreBpCaRequestdateBank();
    ordine.datiBancari.banca = new HDT_WS_RicCreBpCaRequestbank();
    ordine.indirizzo = new HDT_WS_RicCreBpCaRequestAddress();
    ordine.destinatarioDivergente = new HDT_WS_RicCreBpCaRequestDestination();
    ordine.destinatarioDivergente.indirizzo = new HDT_WS_RicCreBpCaRequestAddress();
    ordine.fattura = new HDT_WS_RicCreBpCaRequestBilling();
  }
 
public class HDT_WS_RicCreBpCaRequestAccount {
  public string nome {get;set;}
  public string alias {get;set;}
  public string partner {get;set;}
  public string tipoAccount {get;set;}
  public string categoria {get;set;}
  public string cellulare {get;set;}
  public string fax {get;set;}
  public string telefono {get;set;}
  public string email {get;set;}
  public string emailCont {get;set;}
  public string marcaturaCliente {get;set;}
  public string codiceFiscale {get;set;}
  public string modelloCA {get;set;}
  public string partitaIva {get;set;}
  public HDT_WS_RicCreBpCaRequestAddress indirizzo {get;set;}
  public HDT_WS_RicCreBpCaRequestGrupIva2 gruppoIva {get;set;}
}
public class HDT_WS_RicCreBpCaRequestAddress {
  public string comune {get;set;}
  public string nazione {get;set;}
  public string toponimo {get;set;}
  public string frazione {get;set;}
  public string piano {get;set;}
  public string civico {get;set;}
  public string suffissoCivico {get;set;}
  public string cap {get;set;}
  public string provincia {get;set;}
  public string via {get;set;}
}
public class HDT_WS_RicCreBpCaRequestGrupIva2 {
  public string adesione {get;set;}
  public string partitaIva {get;set;}
  public Date dataInizio {get;set;}
  public Date dataFine {get;set;} 
}
public class HDT_WS_RicCreBpCaRequestGrupIva {
  public string idOggetto {get;set;}
  public string contoContrattuale {get;set;}
  public string emailInvioBolletta {get;set;}
  public string creaNuovoCA {get;set;}
  public string pecInvioBolletta {get;set;}
  public HDT_WS_RicCreBpCaRequestdateBank datiBancari {get;set;}
  public HDT_WS_RicCreBpCaRequestAddress indirizzo {get;set;}
  public HDT_WS_RicCreBpCaRequestDestination destinatarioDivergente {get;set;}
  public HDT_WS_RicCreBpCaRequestBilling fattura {get;set;}
}
public class HDT_WS_RicCreBpCaRequestdateBank {
 public HDT_WS_RicCreBpCaRequestbank banca {get;set;}
 public string abi {get;set;}
 public string cab {get;set;}
 public string contoCorrente {get;set;}
 public string codiceFiscale {get;set;}
 public string cin {get;set;}
 public string iban {get;set;}
 public string cognome {get;set;}
 public string nome {get;set;}
 public string terminiPagamento {get;set;}
 public string metodoPagamento {get;set;}
 public string metodoPagamentoAlternativo {get;set;}
}
public class HDT_WS_RicCreBpCaRequestbank {
  public string filiale {get;set;}
  public string nome {get;set;}
  public string comune {get;set;}
  public string provincia {get;set;}
  public string nazione  {get;set;}
} 
public class HDT_WS_RicCreBpCaRequestDestination {
public string nome {get;set;}
public string codiceFiscale {get;set;}
public string fax {get;set;}
public string email {get;set;}
public string partitaIva {get;set;}
public string telefono {get;set;}
public string idIntegrazione {get;set;}
public string cognome {get;set;}
public HDT_WS_RicCreBpCaRequestAddress indirizzo {get;set;}
}

public class HDT_WS_RicCreBpCaRequestBilling {
public string codiceUfficio {get;set;}
public string fatturaXML {get;set;}
public string mailPec {get;set;}
public string modello {get;set;}
}

}
