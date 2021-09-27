/**
 * @author Lorenzo Gulotta (lorenzo.gulotta@dunegroup.it)
 * @date 24/06/2021
 * @description HDT_WRP_CampaignPraxidia Class
 * @history Lorenzo Gulotta 24/06/2021 – Created class
 */
public class HDT_WRP_CampaignPraxidia {
    public class front{
        public String idClienteSblSap;
        public String idClienteSap;
        public String idClienteSbl;
        public String codiceFiscale;
        public String codiceFiscaleSbl;
        public String cognome;
        public String nome;
        public String nomeSbl;
        public String ragioneSociale;
        public String ragioneSocialeSbl;
        public String nazionalita;
        public String categoriaSbl;
        public String idCategoriaCliente;
        public String segmento;
        public Integer flgPrivacyGenerale;
        public String telefonoSbl;
        public String telefonoFisso_2;
        public String cellulare2;
        public String cellulareSbl;
        public String mailSbl;
        public String dataValiditaA;
        public String dataValiditaDa;
        public String codiceRds;
        public String codiceServizio;
        public String tipoRds;
        public String sottotipoRds;
        public String areaRds;
        public String argomentoRds;
        public String statoRds;
        public String codiceAcr;
        public String postazione;
        public String gruppoCreatore;
        public String gruppoAssegnatario;
        public String creazioneDi;
        public String canaleDiAcquisizione;
        public DateTime dataRicevimento;
        public String statoRdo;
        public String idRdo;
        public String idOrdine;
        public String tipoOrdine;
        public String tipoPassaggio;
        public String settoreMerceologico;
        public String tipoOperazione;
        public String dfTipoOperazioneSr;
        public String xConnId;
        public String indirizzoEmailContatto;
        public String procedura;
    }
    public class reclami{
        public String idJob;
        public String rdsRiga;
        public String acr;
        public String societa;
        public String assegnatario;
        public String gruppo;
        public String dataRicevimento;
        public String dataChiusura;
        public String tipo;
        public String servizio;
        public String tipoFornitura;
        public String categoriaCliente;
        public String codiceCliente;
        public String statoPratica;
        public String canaleDiRicezione;
        public Integer reiterata;
        public String epSottotipo;
        public String epCausale;
        public String epClassificazione;
        public String teSol;
        public String teLav;
        public String fuoriStdAeegsi;
        public String chiamata;
        public String brand;
        public String segmento;
        public String comuneCorretto;
        public String dirittoRettifica;
        public String flussoPratica;
        public String canaleDiUscita;
        public String emailUscita;
        public String richiestePareri;
    }
    public class wrapToIterate{
        public Order o;
        public Case c;


        public wrapToIterate(Order o, Case c){
            this.o = o;
            this.c = c;
        }
    }
}