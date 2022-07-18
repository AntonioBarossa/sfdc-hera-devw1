@SuppressWarnings('PMD.ExcessivePublicCount')
public class HDT_WRP_AccountStatement {

    public class HDT_WRP_ConfTabObjDetail {
        @AuraEnabled public String recordCode;
        @AuraEnabled public String customerCode;
        @AuraEnabled public String tabCode;
        @AuraEnabled public Boolean hasSecondLevel;
        @AuraEnabled public Boolean hasAmountField;
        @AuraEnabled public String secondLevelApiName;
        @AuraEnabled public List<HDT_WRP_ButtonObjDetail> buttonList;
    }

    public class HDT_WRP_ButtonObjDetail {
        @AuraEnabled public String label;
        @AuraEnabled public String name;
        @AuraEnabled public Boolean enable;
        @AuraEnabled public String type;
        @AuraEnabled public String parameters;
        @AuraEnabled public String accesskey;
        
        @SuppressWarnings('PMD.ExcessiveParameterList')
        public HDT_WRP_ButtonObjDetail(String labelTemp, String nameTemp, Boolean enableTemp, String typeTemp, String parametersTemp){
            label = labelTemp;
            name = nameTemp;
            enable = enableTemp;
            type = typeTemp;
            parameters = parametersTemp;
        }
        
        @SuppressWarnings('PMD.ExcessiveParameterList')
        public HDT_WRP_ButtonObjDetail(String labelTemp, String nameTemp, Boolean enableTemp, String typeTemp, String parametersTemp, String accesskeyTemp){
            label = labelTemp;
            name = nameTemp;
            enable = enableTemp;
            type = typeTemp;
            parameters = parametersTemp;
            accesskey = accesskeyTemp;
        }
    }

    public class HDT_WRP_ColumnsObj {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public HDT_WRP_ConfTabObjDetail confObj;
        @AuraEnabled public List<HDT_WRP_SingleColumn> columnObj;
    }

    public class HDT_WRP_SingleColumn {
        @AuraEnabled public HDT_WRP_ColumnDetail detail;
        @AuraEnabled public String label;
        @AuraEnabled public String fieldName;
        @AuraEnabled public Boolean showSort;
        @AuraEnabled public Boolean isFilter;
        @AuraEnabled public Boolean showAmount;
    }

    public class HDT_WRP_ColumnDetail {
        @AuraEnabled public String type;
        // montors fix 07/07/2022
        //@AuraEnabled public Boolean isAmount;
        @AuraEnabled public Decimal totAmountStored;
        @AuraEnabled public Decimal totAmount;
    }

    //public class HDT_WRP_ResponseObj {
    //    @AuraEnabled public Boolean success;
    //    @AuraEnabled public String message;
    //    @AuraEnabled public Boolean dataError;
    //    @AuraEnabled public String bodyBase64;
    //}

    public class HDT_WRP_ReturnPicklist {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public List<HDT_WRP_PicklistObj> companyList;
        @AuraEnabled public List<HDT_WRP_PicklistObj> joinLevelList;
    }

    public class HDT_WRP_PicklistObj {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }

    //SECOND LEVEL COLUMN OBJ
    public class HDT_WRP_SecLevColumnsObj {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public List<HDT_WRP_SingleSecCol> columnObj;
        @AuraEnabled public List<HDT_WRP_ButtonObjDetail> buttonList;
    }

    public class HDT_WRP_SingleSecCol {
        @AuraEnabled public Boolean isFilter;
        @AuraEnabled public String label;
        @AuraEnabled public String fieldName;
        @AuraEnabled public Boolean sortable;
        @AuraEnabled public Decimal initialWidth;
        @AuraEnabled public String type;
        // montors fix 07/07/2022
        @AuraEnabled public Boolean isAmountField;
    }

    public class HDT_WRP_ReponseWrapper {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public String data;
    }

    public class HDT_WRP_TechObj {
        public String requestType;
        public String recordId;
        public String customerCode;
        public String tabCode;
        public String statementType;
        public String aggregation;
        //public String transactionType;
    }

    public class HDT_WRP_HttpDataBodyRow {
        //REQUEST OBJ SEND TO MULESOFT
        public String applicativo;
        public String aggregazione;
        public String codiceCliente;
        public String tipoTransazione;
        public String tipoEstrattoConto;
        public String dataInizio;
        public String dataFine;
        public String numeroFattura;
        public String numeroBollettino;
        public String numeroDocumento;
        public String contoContrattuale;
        public String societa;
        public String servizio;
        public String contratto;
        public String loginId;
        public String stepSollecito;
        // not in webService, only for internal techinal purpose
        public String originLwc;
    }

    public class HDT_WRP_Tabs {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public List<HDT_WRP_TabDetail> tabDetail;
    }

    public class HDT_WRP_TabDetail {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }

    public class HDT_WRP_ServiceCatalogResponse {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public String serviceCatalogId;
    }

    public class HDT_WRP_DeserializeObj {
        public String contoContrattuale;
        public String rateizzato;
        public String numeroFattura;
        public String residuo;
        public String societa;
        public String fatturaPrescrivibile;
        public String fatturaPrescritta;
        public String DEL_569;
        public String documentoPareggio;
        /**@frpanico 21/10/2021
         * Added new parameter for "bonusSociale"
         * Added new parameter for "dataScadenza"
         */
        public String bonusSociale;
        public String dataScadenza;
        public List<HDT_WRP_SecondLevelObj> secondoLivelloInformativo;
        public List<HDT_WRP_SecondLevelObj> secondoLivelloInformativoF2;
    }

    public class HDT_WRP_SecondLevelObj {
        public String docPareggio;
    }

}