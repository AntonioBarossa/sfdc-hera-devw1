public with sharing class HDT_WRP_MeterSearchResponse {

    public String status;
    public String correlationId;
    public String timestamp;
    public String result;
    public String message;
    public HDT_WRP_MeterSearchData data;

    public class HDT_WRP_MeterSearchData{
        public String esito;
        public List<HDT_WRP_MeterSearchEtOut> etOut;
        public String responseMsg;
    }

    public class HDT_WRP_MeterSearchEtOut{
        public String matricola;
        public String indirizzo;
        public String puntoPresa;
        public String statoContratto;
        public String numeroContratto;
        public String tipoImpianto;
    }

}
