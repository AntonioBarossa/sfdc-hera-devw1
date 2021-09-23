public class HDT_UTL_IntegrationObject{

	public static Map<String,String> generateQueryString(HDT_WRP_IntegrationObject.HDT_WRP_IntegrationParentObject jsonStructure, String recordId){
		
		String queryString = 'SELECT ' + jsonStructure.fields;
		String fromString = ' FROM '+ jsonStructure.objectName;
		String controllingField = jsonStructure.controllingField;
		String whereString = ' WHERE ' + controllingField + ' =\''+ recordId + '\'';
		String parentCondition = jsonStructure.condition;
		if(String.isNotBlank(parentCondition)){
			whereString = whereString + ' AND ' + parentCondition;
		}
		
		String fieldLookup = '';
		for(HDT_WRP_IntegrationObject.HDT_WRP_IntegrationLookupObject singleLookupObject : jsonStructure.lookupObject){
			List<String> fields = singleLookupObject.fields.split(',');
			for(String singleField : fields){
				fieldLookup += ',' + singleLookupObject.relation + '.' + singleField.trim();
			} 
		}
		queryString += fieldLookup;
		
		List<String> relatedQueryList = new List<String>();
		for(HDT_WRP_IntegrationObject.HDT_WRP_IntegrationRelatedObject singleRelatedObject : jsonStructure.relatedObject){
			String queryRelString = '(SELECT ' + singleRelatedObject.fields;
			String fromRelString = ' FROM ' + singleRelatedObject.relation;// + ')';
			String condition = ' WHERE ' + singleRelatedObject.condition + ')';
			if(String.isBlank(singleRelatedObject.condition)){
				relatedQueryList.add(queryRelString+fromRelString+')');
			}else {
				relatedQueryList.add(queryRelString+fromRelString+condition);
			}
				
		}
		String relatedQueryString = String.join(relatedQueryList, ',');
		if(String.isNotBlank(relatedQueryString)){
			queryString  = queryString + ',' + relatedQueryString + fromString + whereString; 
		}else{
			queryString  = queryString + fromString + whereString; 
		}
		
		System.debug('query ' + queryString);
		return new Map<String,String>{'queryString' => queryString, 'parentObject' => jsonStructure.objectName};
	}
	
	//esegue query generica ed estrae campo indicato da jsonField formattandolo come HDT_WRP_IntegrationObject.HDT_WRP_IntegrationParentObject
	public static HDT_WRP_IntegrationObject.HDT_WRP_IntegrationParentObject getIntegrationObjectConfiguration(String objectName, String fields, String conditions, String jsonField){
		HDT_WRP_IntegrationObject.HDT_WRP_IntegrationParentObject toReturn = new HDT_WRP_IntegrationObject.HDT_WRP_IntegrationParentObject();
		List<sObject> configurationRecord = HDT_QR_GenericQuery.getGenericRecords(fields, objectName, conditions);
		if(configurationRecord != null && configurationRecord.size()>-1){
			toReturn = (HDT_WRP_IntegrationObject.HDT_WRP_IntegrationParentObject) JSON.deserialize((String) configurationRecord[0].get(jsonField), HDT_WRP_IntegrationObject.HDT_WRP_IntegrationParentObject.class);
		}
		return toReturn;
		
	}
}