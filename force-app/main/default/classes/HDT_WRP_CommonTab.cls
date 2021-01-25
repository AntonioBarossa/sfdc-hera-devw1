public class HDT_WRP_CommonTab {

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
        @AuraEnabled public String attivita;
        @AuraEnabled public String bloccoAlPagamento;
        @AuraEnabled public String bloccoAlSollecito;
        @AuraEnabled public String canaleIncassoRealTime;
        @AuraEnabled public String classeConto;
        @AuraEnabled public String contoContrattuale;
        @AuraEnabled public String contratto;
        @AuraEnabled public String dataEmissione;
        @AuraEnabled public String dataIncassoRealTime;
        @AuraEnabled public String dataScadenza;
        @AuraEnabled public String documento;
        @AuraEnabled public String documentoPareggio;
        @AuraEnabled public String importo;
        @AuraEnabled public String messaInMoraScaduta;
        @AuraEnabled public String note;
        @AuraEnabled public String noteRDS;
        @AuraEnabled public String numeroFattura;
        @AuraEnabled public String POD_PDR;
        @AuraEnabled public String predispPagamento;
        @AuraEnabled public String presenzaSospensione;
        @AuraEnabled public String R;
        @AuraEnabled public String rateizzato;
        @AuraEnabled public String RDS;
        @AuraEnabled public String residuo;
        @AuraEnabled public String riferimentoFattura2;
        @AuraEnabled public String settoreMerceologico;
        @AuraEnabled public String societa;
        @AuraEnabled public String statoIconMapCalc;
        @AuraEnabled public String stepSollecito;
        @AuraEnabled public String TD;
        @AuraEnabled public String tipoDoc;
        @AuraEnabled public String tipoDocumento;
        @AuraEnabled public String totaleCopertina;
        @AuraEnabled public List<SecondLevelObj> secondoLivello;
    }
    
    public class SecondLevelObj {
        @AuraEnabled public String id;
        @AuraEnabled public String contratto;
        @AuraEnabled public String dataEmissione;
        @AuraEnabled public String dataScadenza;
        @AuraEnabled public String dataScadenzaMessaInMora;
        @AuraEnabled public String documento;
        @AuraEnabled public String importo;
        @AuraEnabled public String messaInMoraScaduta;
        @AuraEnabled public String note;
        @AuraEnabled public String noteRDS;
        @AuraEnabled public String recuperoCrediti;
        @AuraEnabled public String riferimentoFattura;
        @AuraEnabled public String societa;
        @AuraEnabled public String tipoDoc;
    }

}