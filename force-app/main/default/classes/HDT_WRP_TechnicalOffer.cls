public inherited sharing class HDT_WRP_TechnicalOffer {
    
    public class HDT_WRP_MatrixData {
        public List<HDT_WRP_MatrixConfig> data;
    }

    public class HDT_WRP_MatrixConfig {
        public String opName;
        public List<HDT_WRP_MatrixDetail> fields;
    }

    public class HDT_WRP_MatrixDetail {
        public String fieldName;
        public Boolean enabled;
        public String relatedTo;
    }

    public class HDT_WRP_ProductObj {
        public String productId;
        public String template;
        public String version;
        public String rateCategory;
        public String productCode;
    }

    public class HDT_WRP_SaveResponse {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public String techOffId;
        @auraEnabled public String bodyResponse;
        @AuraEnabled public Boolean dataError;
        @AuraEnabled public List<HDT_WRP_LineError> errorData;
    }

    public class HDT_WRP_LineError{
        @auraEnabled public String rowId;
        @auraEnabled public String errorMessage;
    }

    public class HDT_WRP_ResponseTecOffer {
        @auraEnabled public Boolean success;
        @auraEnabled public String errorMessage;
        @auraEnabled public HDT_WRP_TecnicalOfferObj data;
    }

    public class HDT_WRP_TecnicalOfferObj {
        @auraEnabled public Boolean productCodeIsAlreadyPresent;
        @auraEnabled public String techOffIdToClone;
        @auraEnabled public Boolean offerIsPresent;
        @auraEnabled public List<TechnicalOffer__c> tecnicalOffers;
    }

    public class HDT_WRP_MatrixTable {
        @auraEnabled public Boolean success;
        @auraEnabled public String message;
        @auraEnabled public Boolean isEditable;
        @auraEnabled public List<HDT_WRP_MatrixSingleRow> rowList;
    }

    public class HDT_WRP_MatrixSingleRow {
        @auraEnabled public String id;
        @auraEnabled public String rowId;
        @auraEnabled public String tecName;
        @auraEnabled public String definition;
        @auraEnabled public String type;
        @auraEnabled public Boolean g;
        @auraEnabled public Boolean m;
        @auraEnabled public Boolean v;
        @auraEnabled public String s;
        //@auraEnabled public HDT_WRP_RowDetail startDate;
        //@auraEnabled public HDT_WRP_RowDetail endDate;
        @auraEnabled public HDT_WRP_RowDetail rateType;
        @auraEnabled public HDT_WRP_RowDetail infoGroup;
        @auraEnabled public HDT_WRP_RowDetail numValue;
        @auraEnabled public HDT_WRP_RowDetail flag;
        @auraEnabled public HDT_WRP_RowDetail priceCode;
        @auraEnabled public HDT_WRP_RowDetail discountCode;
        @auraEnabled public HDT_WRP_RowDetail stringValue;
    }

    public class HDT_WRP_RowDetail {
        @auraEnabled public String value;
        @auraEnabled public String label;
        @auraEnabled public String relatedTo;
        @auraEnabled public Boolean enabled;
    }

    public class HDT_WRP_TechnicalOfferWebService {
        public Boolean success;
        public String message;
        public HDT_WRP_Header header;
    }

    public class HDT_WRP_Header {
        public String codiceOfferta;
        public String profilo;
        public String categoriaTariffa;
        public String descrizioneOfferta;
        public String descrizioneProfilo;
        public String mercato;
        public String tipoProcesso;
        public Boolean isOffertaPLACET;
        public String prodotto;
        public String idContratto;
        public String dataInizioValidita;
        public String dataFineValidita;
        public Boolean isPassoAmmessoSN;
        public String numeroUnitaTempoProroga;
        public String unitaTempoProroga;
        public Boolean isDisdettaAmmessa;
        public String numeroUnitaTempoDisdetta;
        public String unitaTempoDisdetta;
        public Boolean isRecessoAmmesso;
        public String numeroUnitaTempoRecesso;
        public String unitaTempoRecesso;
        public Boolean isModificabile;
        public Boolean isOffertaDaModificare;
        public List<HDT_WRP_Position> input;
    }

    public class HDT_WRP_Position {
        public String operando;
        public Boolean isGestibile;
        public Boolean isModificabile;
        public String statoOperando;
        public String tariffa;
        public String gruppoInformativoTariffa;
        public String prezzo;
        public String sconto;
        public String valore;
        public String stringa;
    }

}