public inherited sharing class HDT_WRP_GenerateJsonSAP {
    public class HDT_WRP_SAPRequest{
        public String requestType;
        public List<HDT_WRP_SAPParentObjects> objects;
    }
    
    public class HDT_WRP_SAPFields{
        public String fieldType;
        public String label;
        public String apiName;
    }

    public class HDT_WRP_SAPParentObjects{
        public String objectLabel;
        public String objectName;
        public List<HDT_WRP_SAPFields> fields;
        public List<HDT_WRP_SAPChildObjects> childObjects;
    }
    
    public class HDT_WRP_SAPChildObjects{
        public String objectLabel;
        public String objectName;
        public String relationName;
        public String staticCondition;
        public String controllingField;
        public List<HDT_WRP_SAPFields> fields;
    }
}