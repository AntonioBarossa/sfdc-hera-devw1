/**
 * @author alessandro.picchiri@eng.it
 * @date 28/05/2021 
*/
public class HDT_WS_CreditCheckResponse extends HDT_WS_Response {
   
    @AuraEnabled public String status{get;set;}
    @AuraEnabled public HDT_WRP_ResultObject result{get;set;}
    @AuraEnabled public String correlationId{get;set;}
    @AuraEnabled public String timestamp{get;set;}
    @AuraEnabled public HDT_WRP_dataResponseObject data{get;set;}
    @AuraEnabled public List<HDT_WRP_errorResponseObject> errorDetails{get;set;}

    public HDT_WS_CreditCheckResponse(){
        this.data =  new HDT_WRP_dataResponseObject();
        this.errorDetails = new List<HDT_WRP_errorResponseObject>();  
        system.debug('HDT_WS_CreditCheckResponse - HDT_WS_CreditCheckResponse: data ----> ' + JSON.serialize(this.data));   
        system.debug('HDT_WS_CreditCheckResponse - HDT_WS_CreditCheckResponse: errorDetails ----> ' + JSON.serialize(this.errorDetails));   
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
        @AuraEnabled public String campo{get;set;}
        @AuraEnabled public String valore{get;set;}
    }
    public class HDT_WRP_ErrorResponseObject{
        @AuraEnabled public String code{get;set;}
        @AuraEnabled public String message{get;set;}
        @AuraEnabled public String additionalInfo{get;set;}
    }

    public class HDT_WRP_ResultObject{
        @AuraEnabled public String applicationGuid{get;set;}
        @AuraEnabled public String applicationId{get;set;}
        @AuraEnabled public String identificativoCrm{get;set;}
        @AuraEnabled public String responseStatus{get;set;}
        @AuraEnabled public String errorTimestamp{get;set;}
    }
}