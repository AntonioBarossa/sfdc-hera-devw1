public with sharing class HDT_WRP_BpCaVariationVatGroup {

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
		public String modelloCa;
		public String partitaIva;
		public HDT_WRP_BpCaVariationGruppoIva gruppoIva;
		public HDT_WRP_BpCaVariationAccount(){
			this.gruppoIva = new HDT_WRP_BpCaVariationGruppoIva();
		}
	}

	public String numeroSr;
	public String codiceCausale;
	public String dataCreazione;
	public String cancellaBpAlternativo;
	public String nomeContatto;
	public HDT_WRP_BpCaVariationAccount account;
	
	public HDT_WRP_BpCaVariationVatGroup(){
		this.account = new HDT_WRP_BpCaVariationAccount();
	}

	public class HDT_WRP_BpCaVariationGruppoIva {
		public String adesione;
		public String partitaIva;
		public String dataInizio;
		public String dataFine;
	}
}
