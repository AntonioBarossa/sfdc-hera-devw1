public class HDT_WRP_Appuntamento{
  
    public class HDT_WRP_RequestAppuntamento{
        public String documentkey;
        public String codFlusso;
        public String rifRich;
        public String modApp;
        public String appData;
        public String appFasciaOrario;
        public String codiceApp;
        public String desEsitoAttivita;
        public String self;
    }

    public class HDT_WRP_RequestAppuntamentoRoot{
        public HDT_WRP_RequestAppuntamento requestAppuntamento;
    }

    public class HDT_WRP_SlotAppuntamento{
        public String codiceApp;
        public String appData;
        public String appFasciaOrario;
        public String zLimApp;
        public String zLimAppOra;
        public String zStimaDurApp;
    }

    public class HDT_WRP_ResponseAppuntamento{
        public String codCaus;
        public String codFlusso;
        public String documentkey;
        public String rifExt;
        public String rifRich;
        public String zGestApp;
        public String extAnnotazioni;
        public String desEsitoConf;
        public String zCodCausApp;
        public String errInvioDis;
        public List<HDT_WRP_SlotAppuntamento> appuntamento;
    }

    public class HDT_WRP_ResponseAppuntamentoRoot{
        public HDT_WRP_ResponseAppuntamento responseAppuntamento;
    }
}

