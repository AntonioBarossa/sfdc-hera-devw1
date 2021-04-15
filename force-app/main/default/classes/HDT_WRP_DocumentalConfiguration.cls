public class HDT_WRP_DocumentalConfiguration{
    
	public class HDT_WRP_DatabaseResult {
		@AuraEnabled public Boolean success;
		@AuraEnabled public String message;
		@AuraEnabled public List<Id> docIdList;		
		@AuraEnabled public Boolean dataError;
        @AuraEnabled public List<HDT_WRP_LineError> errorData;
	}

    public class HDT_WRP_LineError{
        @auraEnabled public String docName;
        @auraEnabled public String errorMessage;
    }

    //container
	public class HDT_WRP_DocumentalStructure{
		public List<HDT_WRP_DocumentalSection> sections;
	}
	
	public class HDT_WRP_DocumentalSection{
		public String iterative;
		public String recordType;
        public String object1;
		public List<HDT_WRP_DocumentalRecord> records;
	}
	
	public class HDT_WRP_DocumentalRecord{
		public String classString;
		public String methodString;
		public String iterative;
		public String recordType; 
		public String expression;
		public String separetor;
		public String object1;
		public String object2;
		public String object3;
		public String object4;
		public String field1;
		public String field2;
		public String field3;
		public String field4;
		public String isData;
		public String manageAmount;
		public String defaultVal;
		public String payloadField;
	}
}