public class HDT_WS_ArrichmentDataEntityResponse extends HDT_WS_Response {
    @AuraEnabled public String status{get;set;}
    @AuraEnabled public String correlationId{get;set;}
    @AuraEnabled public String timestamp{get;set;}
    @AuraEnabled public HDT_WRP_dataResponseObject data{get;set;}
   // @AuraEnabled public List<HDT_WRP_posizioniResponseObject> posizioni{get;set;}
    @AuraEnabled public List<HDT_WRP_errorResponseObject> errorDetails{get;set;}

    public HDT_WS_ArrichmentDataEntityResponse(){
       this.data =  new HDT_WRP_dataResponseObject();
       this.errorDetails = new List<HDT_WRP_errorResponseObject>();
    }
    
    public class HDT_WRP_dataResponseObject{
        @AuraEnabled public HDT_WRP_testataObject testata{get;set;}
        @AuraEnabled public List<HDT_WRP_posizioniResponseObject> posizioni{get;set;}
    }
    public class HDT_WRP_testataObject{
        @AuraEnabled public String esito{get;set;}
        @AuraEnabled public String messaggio{get;set;}
    }
    public class HDT_WRP_posizioniResponseObject{
        @AuraEnabled public String campo{get;set;}
        @AuraEnabled public String valore{get;set;}
    }
    public class HDT_WRP_errorResponseObject{
        @AuraEnabled public String code{get;set;}
        @AuraEnabled public String message{get;set;}
        @AuraEnabled public String additionalInfo{get;set;}
    }
}