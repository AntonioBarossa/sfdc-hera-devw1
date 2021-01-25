public class HDT_WRP_Paperless {

    //RETURN OBJ FROM MULESOFT
    public class ReturnObj{
        public String status;
        public String correlationId;
        public String timestamp;
        public ErrorDetails errorDetails;
        public List<FirstLevelObj> data;
    }

    public class ErrorDetails {
        @AuraEnabled public String code;
        @AuraEnabled public String message;
        @AuraEnabled public String additionalInfo;
    }

    public class FirstLevelObj {
        @AuraEnabled public String id;
		@AuraEnabled public String societa;
		@AuraEnabled public String tipoDocumento;
		@AuraEnabled public String numeroDocumento;
		@AuraEnabled public String numeroFattura;
		@AuraEnabled public String dataEmissione;
		@AuraEnabled public String dataScadenza;
		@AuraEnabled public String indicatore;
		@AuraEnabled public String residuo;
		@AuraEnabled public String stepSollecito;
		@AuraEnabled public String messaInMoraScaduta;
		@AuraEnabled public String bloccoAlPagamento;
		@AuraEnabled public String recuperoCrediti;
		@AuraEnabled public String bloccoAlSollecito;
		@AuraEnabled public String POD_PDR;
    }
    
}