public class HDT_WRP_MulesoftResponse {

    //RETURN OBJ FROM MULESOFT
    public class HDT_WRP_ReturnObj{
        public String status;
        public String correlationId;
        public String timestamp;
        public HDT_WRP_ErrorDetails errorDetails;
    }

    public class HDT_WRP_ErrorDetails {
       public String code;
       public String message;
       public String additionalInfo;
    }
    
}