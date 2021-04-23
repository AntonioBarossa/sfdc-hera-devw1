global inherited sharing class HDT_WRP_HerokuPostSalesProva {

    global class HDT_WRP_MultiResponse{

        public List<HDT_WRP_Response> responses;

    }


    global class HDT_WRP_Response{

        public String code;
        public String description;
        public HDT_WRP_Header header;
        public List<HDT_WRP_WObject> objects;


    }

    global class HDT_WRP_Header{

        public List<HDT_WRP_Field> fields;
        public String requestId;
        public String requestTimestamp;
        public String requestType;


    }

    global class HDT_WRP_Field{

        public String fieldType;
        public String name;
        public String value;

    }

    global class HDT_WRP_Wobject{

        public List<HDT_WRP_Field> fields;
        public String id;
        public String name;
        public List<HDT_WRP_WObject> objects;
        public String objectType;

    }


}
