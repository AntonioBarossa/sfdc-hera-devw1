public with sharing class HDT_UTL_ActivityTracker {
	public static void track(List<SObject> sobjects) {
		Map<String,SObject> objectsByOwner = new Map<String,SObject>();
		for(SObject obj : sobjects) {
			objectsByOwner.put((String) obj.get('OwnerId'),(SObject) obj);
		}

		for(wrts_prcgvr__Activity__c activity : [
				SELECT Id
				FROM wrts_prcgvr__Activity__c
				WHERE
					OwnerId IN: objectsByOwner.keySet() AND
					Type__c = 'Chiamata' AND
					wrts_prcgvr__Status__c = 'In Progress' AND
					CreatedDate = TODAY
			]) {
			objectsByOwner.get(activity.OwnerId).put('Activity__c', activity.Id);
		}
	}
}