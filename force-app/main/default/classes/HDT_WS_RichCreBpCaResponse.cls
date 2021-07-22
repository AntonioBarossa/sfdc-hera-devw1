public with sharing class HDT_WS_RichCreBpCaResponse extends HDT_WS_Response{
    
    public dataResponseWrap data {get; set;}

    public class dataResponseWrap{
        public String rdo {get;set;}
        public String codiceCausale {get;set;}
        public String codiceContatto {get;set;}
        public String codiceBPAlternativo {get;set;}
        public String rds {get;set;}
        public String tipoAttivita {get;set;}
        public String commenti {get;set;}
        public String codiceBP {get;set;}
    } 
}
