public class HDT_UTL_IntegrationObject{

	public static Map<String,String> generateQueryString(HDT_WRP_IntegrationObject.HDT_WRP_IntegrationParentObject jsonStructure, String recordId){
		String queryQ = 'SELECT ' + jsonStructure.fields;
		String fromQ = ' FROM '+ jsonStructure.objectName;
		String whereQ = ' WHERE Id =\''+ recordId + '\'';

		String fieldLookup = '';
		for(HDT_WRP_IntegrationObject.HDT_WRP_IntegrationLookupObject singleLookupObject : jsonStructure.lookupObject){
			List<String> fields = singleLookupObject.fields.split(',');
			for(String singleField : fields){
				fieldLookup += ',' + singleLookupObject.relation + '.' + singleField.trim();
			} 
		}
		queryQ += fieldLookup;
		List<String> relatedQueryList = new List<String>();
		for(HDT_WRP_IntegrationObject.HDT_WRP_IntegrationRelatedObject singleRelatedObject : jsonStructure.relatedObject){
			String queryR = ',(SELECT ' + singleRelatedObject.fields;
			String fromR = ' FROM '+ singleRelatedObject.relation + ')';
			relatedQueryList.add(queryR+fromR);
		}
		String relatedQueryString = String.join(relatedQueryList, ',');
		queryQ  = queryQ + relatedQueryString + fromQ + whereQ; 
		system.debug('query ' + queryQ);
		return new Map<String,String>{'queryString' => queryQ, 'parentObject' => jsonStructure.objectName};
	}
	
	public static HDT_WRP_IntegrationObject.HDT_WRP_IntegrationParentObject getIntegrationObjectConfiguration(String objectName, String fields, String conditions, String jsonField){
		HDT_WRP_IntegrationObject.HDT_WRP_IntegrationParentObject toReturn = new HDT_WRP_IntegrationObject.HDT_WRP_IntegrationParentObject();
		List<sObject> configurationRecord = HDT_QR_GenericQuery.getGenericRecords(fields, objectName, conditions);
		if(configurationRecord != null && configurationRecord.size()>-1){
			toReturn = (HDT_WRP_IntegrationObject.HDT_WRP_IntegrationParentObject) JSON.deserialize((String) configurationRecord[0].get(jsonField), HDT_WRP_IntegrationObject.HDT_WRP_IntegrationParentObject.class);
		}
		return toReturn;
		
	}
}