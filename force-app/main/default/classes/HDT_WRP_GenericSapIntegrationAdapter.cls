public inherited sharing class HDT_WRP_GenericSapIntegrationAdapter {
    public class HDT_WRP_SapRequest{
        public String requestType;
        public List<HDT_WRP_SapParentObjects> objects;
    }
    
    public class HDT_WRP_SapFields{
        public String fieldType;
        public String label;
        public String apiName;
    }

    public class HDT_WRP_SapParentObjects{
        public String objectLabel;
        public String objectName;
        public List<HDT_WRP_SapFields> fields;
        public List<HDT_WRP_SapChildObjects> childObjects;
    }
    
    public class HDT_WRP_SapChildObjects{
        public String objectLabel;
        public String objectName;
        public String relationName;
        public String staticCondition;
        public String controllingField;
        public List<HDT_WRP_SapFields> fields;
    }
}
