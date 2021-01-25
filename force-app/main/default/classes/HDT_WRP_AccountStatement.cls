public class HDT_WRP_AccountStatement {

    //RETURN OBJ FROM MULESOFT
    public class ReturnObj{
        public String status;
        public String correlationId;
        public String timestamp;
        public ErrorDetails errorDetails;
        public List<DataWrapper> data;
    }

    public class ErrorDetails {
        @AuraEnabled public String code;
        @AuraEnabled public String message;
        @AuraEnabled public String additionalInfo;
    }

    public class DataWrapper{
        @AuraEnabled public String id;
        @AuraEnabled public String codiceCliente;
        @AuraEnabled public String bloccoAlSollecito;
        @AuraEnabled public String contoContrattuale;
        @AuraEnabled public String classeConto;
        @AuraEnabled public String ceduta;
        @AuraEnabled public String dataEmissione;
        @AuraEnabled public String dataScadenza;
        @AuraEnabled public String dilazione;
        @AuraEnabled public String idPrimoLivelloSAP;
        @AuraEnabled public String importo;
        @AuraEnabled public String modalitaPagamento;
        @AuraEnabled public String modalitaPagamentoCA;
        @AuraEnabled public String codiceModalitaPagamento;
        @AuraEnabled public String numeroBollettino;
        @AuraEnabled public String numeroFattura;
        @AuraEnabled public String numeroDocumento;
        @AuraEnabled public String r;
        @AuraEnabled public String rateizzato;
        @AuraEnabled public String recuperoCrediti;
        @AuraEnabled public String residuo;
        @AuraEnabled public String societa;
        @AuraEnabled public String sollecitato;
        @AuraEnabled public String tipoDocumento;
        @AuraEnabled public String totaleCopertina;
        @AuraEnabled public String troncatura;
        @AuraEnabled public String codiceEsito;
        @AuraEnabled public String descrizioneEsito;
        @AuraEnabled public String dataEsito;
        @AuraEnabled public String loginId;
        @AuraEnabled public String fatturaPrescrivibile;
        @AuraEnabled public String fatturaPrescritta;
        @AuraEnabled public String dEL_569;
        @AuraEnabled public List<SecondLevelObj> secondoLivello;
    }
    
    public class SecondLevelObj{
        @AuraEnabled public String bloccoAlPagamento;
        @AuraEnabled public String bloccoAlSollecito;
        @AuraEnabled public String contratto;
        @AuraEnabled public String dataEmissionePianoRata;
        @AuraEnabled public String dataPareggio;
        @AuraEnabled public String dataRegistrazione;
        @AuraEnabled public String dataValPareggio;
        @AuraEnabled public String dilazione;
        @AuraEnabled public String docPareggio;
        @AuraEnabled public String documento;
        @AuraEnabled public String importo;
        @AuraEnabled public String letturaStimata;
        @AuraEnabled public String motivoDiPareggio;
        @AuraEnabled public String pianoRate;
        @AuraEnabled public String residuo;
        @AuraEnabled public String riferimentoFattura;
        @AuraEnabled public String scadenza;
        @AuraEnabled public String settoreMerceologico;
        @AuraEnabled public String societa;
        @AuraEnabled public String stepSollecito;
        @AuraEnabled public String testoDettaglio;
        @AuraEnabled public String tipoDocumento;
        @AuraEnabled public String recuperoCrediti;
        @AuraEnabled public String idSecondoLivelloSAP;
        @AuraEnabled public String tD_PAREGGIO;
        @AuraEnabled public String dataIncassoRealTime;
        @AuraEnabled public String canaleIncassoRealTime;
    }

}