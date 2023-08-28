public with sharing class HDT_WRP_AlignSapOfferCodeTable {

    public class HDT_WRP_AlignSapOfferCodeTableData {
        public String Id;
        public String offerCode32;
        public String offerProductCode;
        public String offerProductVersion;
        public String codT0;
        public String effectiveMonths;
        public String driver1;
        public String driver2;
        public String driver3;
        public String commodity;
        public String company;
        public String market;
        public String outcome;
        public String outcomeCode;
    }

    public class HDT_WRP_AlignSapOfferCodeTableRequest extends HDT_WS_Request{
        public List<HDT_WRP_AlignSapOfferCodeTableData> data;
    }

    public class HDT_WRP_AlignSapOfferCodeTableResponse{
        public List<HDT_WRP_AlignSapOfferCodeTableData> data;
    }

}