public class HDT_WRP_MulesoftResponse {

    //RETURN OBJ FROM MULESOFT
    public class ReturnObj{
        public String status;
        public String correlationId;
        public String timestamp;
        public ErrorDetails errorDetails;
    }

    public class ErrorDetails {
        @AuraEnabled public String code;
        @AuraEnabled public String message;
        @AuraEnabled public String additionalInfo;
    }
    
}