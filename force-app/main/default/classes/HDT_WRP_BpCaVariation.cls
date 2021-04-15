
public class HDT_WRP_BpCaVariation {

	public class HDT_WRP_BpCaVariationAccount {
		public String nome;
		public String alias;
		public String partner;
		public String tipoAccount;
		public String categoria;
		public String cellulare;
		public String fax;
		public String telefono;
		public String email;
		public String emailCont;
		public String marcaturaCliente;
		public String codiceFiscale;
		public String modelloCA;
		public String partitaIva;
		public HDT_WRP_BpCaVariationIndirizzo indirizzo;
		public HDT_WRP_BpCaVariationGruppoIva gruppoIva;
		public HDT_WRP_BpCaVariationAccount(){
			this.indirizzo = new HDT_WRP_BpCaVariationIndirizzo();
			this.gruppoIva = new HDT_WRP_BpCaVariationGruppoIva();
		}
	}

	public class HDT_WRP_BpCaVariationBanca {
		public String filiale;
		public String nome;
		public String comune;
		public String provincia;
		public String nazione;
	}

	public String numeroSR;
	public String codiceCausale;
	public String dataCreazione;
	public String cancellaBPAlternativo;
	public String nomeContatto;
	public HDT_WRP_BpCaVariationAccount account;
	public HDT_WRP_BpCaVariationOrdine ordine;
	
	public HDT_WRP_BpCaVariation(){
		this.account = new HDT_WRP_BpCaVariationAccount();
		this.ordine = new HDT_WRP_BpCaVariationOrdine();
	}

	public class HDT_WRP_BpCaVariationIndirizzo {
		public String comune;
		public String nazione;
		public String toponimo;
		public String frazione;
		public String piano;
		public String civico;
		public String suffissoCivico;
		public String cap;
		public String provincia;
		public String via;
	}

	public class HDT_WRP_BpCaVariationIndirizzo_Y {
		public String comune;
		public String nazione;
		public String piano;
		public String civico;
		public String suffissoCivico;
		public String cap;
		public String provincia;
		public String via;
	}

	public class HDT_WRP_BpCaVariationGruppoIva {
		public String adesione;
		public String partitaIva;
		//public String dataInizio;
		//public String dataFine;
        //public HDT_WRP_BpCaVariationGruppoIva(){
        //    this.dataInizio = '';
        //    this.dataFine = '';
        //}
	}

	public class HDT_WRP_BpCaVariationFattura {
		public String codiceUfficio;
		public String fatturaXML;
		public String mailPec;
		public String modello;
	}

	public class HDT_WRP_BpCaVariationOrdine {
		public String idOggetto;
		public String contoContrattuale;
		public String emailInvioBolletta;
		public String creaNuovoCA;
		public String pecInvioBolletta;
		public HDT_WRP_BpCaVariationBancari datiBancari;
		public HDT_WRP_BpCaVariationIndirizzo_Y indirizzo;
		public HDT_WRP_BpCaVariationDestinatarioDivergente destinatarioDivergente;
		public HDT_WRP_BpCaVariationFattura fattura;
		
		public HDT_WRP_BpCaVariationOrdine(){
			this.datiBancari = new HDT_WRP_BpCaVariationBancari();
			this.indirizzo = new HDT_WRP_BpCaVariationIndirizzo_Y();
			this.destinatarioDivergente = new HDT_WRP_BpCaVariationDestinatarioDivergente();
			this.fattura = new HDT_WRP_BpCaVariationFattura();
		}
	}

	public class HDT_WRP_BpCaVariationBancari {
		public HDT_WRP_BpCaVariationBanca banca;
		public String abi;
		public String cab;
		public String contoCorrente;
		public String codiceFiscale;
		public String cin;
		public String iban;
		public String cognome;
		public String nome;
		public String terminiPagamento;
		public String metodoPagamento;
		public String metodoPagamentoAlternativo;
		
		public HDT_WRP_BpCaVariationBancari(){
			this.banca = new HDT_WRP_BpCaVariationBanca();
		}
	}

	public class HDT_WRP_BpCaVariationDestinatarioDivergente {
		public String nome;
		public String codiceFiscale;
		public String fax;
		public String email;
		public String partitaIva;
		public String telefono;
		public String idIntegrazione;
		public String cognome;
		public HDT_WRP_BpCaVariationIndirizzo_Y indirizzo;
		
		public HDT_WRP_BpCaVariationDestinatarioDivergente(){
			this.indirizzo = new HDT_WRP_BpCaVariationIndirizzo_Y();
		}
	}
}