public class HDT_WS_VistaDatiCatastaliResponse extends HDT_WS_Response {
    @AuraEnabled public String status {get;set;}
    @AuraEnabled public String correlationId {get;set;}
    @AuraEnabled public String timestamp {get;set;}
    @AuraEnabled public HDT_WRP_DataResponseObject data {get;set;}
    @AuraEnabled public List<HDT_WRP_ErrorResponseObject> errorDetails {get;set;}

    public HDT_WS_VistaDatiCatastaliResponse(){
       this.data =  new HDT_WRP_DataResponseObject();
       this.errorDetails = new List<HDT_WRP_ErrorResponseObject>();
    }
    
    public class HDT_WRP_DataResponseObject{
        @AuraEnabled public HDT_WRP_testataObject testata{get;set;}
        @AuraEnabled public List<HDT_WRP_posizioniResponseObject> posizioni{get;set;}
    }
    
    public class HDT_WRP_TestataObject{
        @AuraEnabled public String esito{get;set;}
        @AuraEnabled public String messaggio{get;set;}
    }

    public class HDT_WRP_PosizioniResponseObject{
        @AuraEnabled public String destinazioneUso {get;set;}
        @AuraEnabled public String descrizioneDestinazioneUso {get;set;}
        @AuraEnabled public String codiceAssenzaDatiCatastali {get;set;}
        @AuraEnabled public String descrizioneAssenzaDc {get;set;}
        @AuraEnabled public String comuneAmministrativo {get;set;}
        @AuraEnabled public String comuneCatastale {get;set;}
        @AuraEnabled public String codiceComuneCatastale {get;set;}
        @AuraEnabled public String codiceProvincia {get;set;}
        @AuraEnabled public String tipoUnita {get;set;}
        @AuraEnabled public String descrizioneTipoUnita {get;set;}
        @AuraEnabled public String sezioneUrbana {get;set;}
        @AuraEnabled public String foglio {get;set;}
        @AuraEnabled public String particella {get;set;}
        @AuraEnabled public String subalterno {get;set;}
        @AuraEnabled public String qualificaTitolareUtenza {get;set;}
        @AuraEnabled public String descrizioneQualifica {get;set;}
        @AuraEnabled public String superficieCatastale {get;set;}
        @AuraEnabled public String categoriaCatastale {get;set;}
    }

    public class HDT_WRP_ErrorResponseObject{
        @AuraEnabled public String code{get;set;}
        @AuraEnabled public String message{get;set;}
        @AuraEnabled public String additionalInfo{get;set;}
    }
}