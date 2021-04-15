public class HDT_WRP_IntegrationObject{
	public class HDT_WRP_IntegrationParentObject{
		public String objectName;
		public String fields;
		public List<HDT_WRP_IntegrationRelatedObject> relatedObject;
		public List<HDT_WRP_IntegrationLookupObject> lookupObject;
	}

	public class HDT_WRP_IntegrationRelatedObject{
		public String objectName;
		public String relation;
		public String fields;
	}

	public class HDT_WRP_IntegrationLookupObject{
		public String objectName;
		public String relation;
		public String fields;
	}
}