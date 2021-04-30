global inherited sharing class HDT_WRP_ModificaLayoutFattura {

    global class HDT_WRP_Response{

        public String status;
        public String correlationId;
        public String timestamp;
        public HDT_WRP_Data data;

    }

    global class HDT_WRP_Data{

        public String rds;
        public String attivita;
        public String note;

    }


}
