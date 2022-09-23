public with sharing class HDT_WRP_MeterSearchResponse {

    public Integer responseCode;
    public String responseStatus;
    public HDT_WRP_MeterSearchResponseRoot packageResponse;

    public HDT_WRP_MeterSearchResponse() {
        this.packageResponse = new HDT_WRP_MeterSearchResponseRoot();
    }

    public class HDT_WRP_MeterSearchResponseRoot{
        public String status;
        public String correlationId;
        public String timestamp;
        public HDT_WRP_MeterSearchData data;
        public String result;
        public String message;
    }

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
