public inherited sharing class HDT_WRP_MeterReading {

    public class HDT_WRP_ContractObj {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public List<HDT_WRP_ContractDetail> contractList;
    }

    public class HDT_WRP_MeterReadingObj {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        //@AuraEnabled public List<HDT_WRP_MeterReadingDetail> data;
        @AuraEnabled public String data;
    }

    public class HDT_WRP_ContractDetail {
        @AuraEnabled public String id;
        @AuraEnabled public String contractNumber;
        @AuraEnabled public String status;
        @AuraEnabled public String startDate;
        @AuraEnabled public String endDate;
        @AuraEnabled public String asset;
        @AuraEnabled public String service;
    }

    /*public class HDT_WRP_MeterReadingDetail {
        @AuraEnabled public String id; 
        @AuraEnabled public String contractId; 
        @AuraEnabled public String lectureDate;
        @AuraEnabled public String slot; 
        @AuraEnabled public String lectureInt; 
        @AuraEnabled public String lectureDecimal; 
        @AuraEnabled public String assetCode; 
        @AuraEnabled public String contractCode; 
        @AuraEnabled public String status; 
        @AuraEnabled public String lectureType; 
        @AuraEnabled public String reason;
        @AuraEnabled public String billingDate; 
        @AuraEnabled public String consumedAvg; 
        @AuraEnabled public String regType; 
        @AuraEnabled public String consumed;
        @AuraEnabled public String consumedType;
        @AuraEnabled public String sector;
        @AuraEnabled public String reasonWhy;
    }*/

    public class HDT_WRP_HttpBody {
        public String codiceContratto;
        public String codiceImpianto;
        public String codicePod;
        public String dataInizioLettura;
        public String dataFineLettura;
        public String letturaReale;
    }

    public class HDT_WRP_ColumnsMetadata {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public String contractTable;
        @AuraEnabled public String meterReadingTable;
    }

}