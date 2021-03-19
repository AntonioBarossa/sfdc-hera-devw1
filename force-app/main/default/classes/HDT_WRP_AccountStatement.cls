public class HDT_WRP_AccountStatement {

    public class HDT_WRP_ConfTabObjDetail {
        @AuraEnabled public String recordCode;
        @AuraEnabled public String customerCode;
        @AuraEnabled public String tabCode;
        @AuraEnabled public Boolean hasSecondLevel;
        @AuraEnabled public Boolean hasAmountField;
        @AuraEnabled public String secondLevelAPIname;
        @AuraEnabled public List<HDT_WRP_ButtonObjDetail> buttonList;
    }

    public class HDT_WRP_ButtonObjDetail {
        @AuraEnabled public String label;
        @AuraEnabled public String name;
        @AuraEnabled public Boolean enable;
        
        public HDT_WRP_ButtonObjDetail(String labelTemp, String nameTemp, Boolean enableTemp){
            label = labelTemp;
            name = nameTemp;
            enable = enableTemp;
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
        @AuraEnabled public Boolean showAmount;
    }

    public class HDT_WRP_ColumnDetail {
        @AuraEnabled public String type;
        @AuraEnabled public Boolean isAmount;
    }

    public class HDT_WRP_ResponseObj {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public Boolean dataError;
        @AuraEnabled public String bodyBase64;
    }

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
    }

    public class HDT_WRP_SingleSecCol {
        @AuraEnabled public Boolean isFilter;
        @AuraEnabled public String label;
        @AuraEnabled public String fieldName;
        @AuraEnabled public Boolean sortable;
        @AuraEnabled public Decimal initialWidth;
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
        public String contoContrattuale;
        public String societa;
        public String contratto;
        public String loginId;
    }

}