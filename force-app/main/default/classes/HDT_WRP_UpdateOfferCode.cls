public with sharing class HDT_WRP_UpdateOfferCode {


    public class HDT_WRP_UpdateOfferCodeData {
        public String sapContractCode;
        public String pod;
        public String offerCode;
        public String profile;
        public String commodity;
        public String effectiveDate;
        public String codTzero;
        public String outcome;
        public String outcomeCode;
        public String effectiveMonths;
        public String causalCode;
    }

    public class HDT_WRP_UpdateOfferCodeRequest {
        public String method;
        public List<HDT_WRP_UpdateOfferCodeData> data;
    }
    public class HDT_WRP_UpdateOfferCodeResponse {
        public String outcome;
        public String outcomeCode;
        public List<HDT_WRP_UpdateOfferCodeData> data;
    }
}