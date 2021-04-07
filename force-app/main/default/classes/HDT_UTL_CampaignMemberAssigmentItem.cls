public with sharing class HDT_UTL_CampaignMemberAssigmentItem {
    public static void createCampaignMemberAssigmentItem(List<CampaignMemberAssigmentItem__c> newAssgnmentItem) {
        //get the new percentage of every new inserted item
        List<String> campaignMemberAssignmentIds = new List<String>();
        Map<String,Decimal> newItem = new Map<String,Decimal>();
        for (CampaignMemberAssigmentItem__c itm : newAssgnmentItem) {
            campaignMemberAssignmentIds.add(itm.CampaingMemberAssigment__c);
            newItem.put(itm.CampaingMemberAssigment__c, (Decimal)itm.PercentageAllocation__c);
        }
        //query the sum of total percentage for every campaignMemberAssignment
        List<AggregateResult> query = [
            SELECT CampaingMemberAssigment__c memberId,
            Sum(PercentageAllocation__c)totalPercentage
            FROM CampaignMemberAssigmentItem__c 
            WHERE CampaingMemberAssigment__c IN :campaignMemberAssignmentIds
            WITH SECURITY_ENFORCED
            GROUP BY CampaingMemberAssigment__c
        ];
        //map the total percentage for every campaignMemberAssignment
        Map<String,Decimal> queryResults = new Map<String,Decimal>();
        for (AggregateResult row : query) {
            queryResults.put((String)row.get('memberId'), (Decimal)row.get('totalPercentage'));
        }

        for (CampaignMemberAssigmentItem__c item : newAssgnmentItem) {
            //Add the new inserted value to the existing total percentage to check it's validity
            Decimal totalPercentage = queryResults.get(item.CampaingMemberAssigment__c) + newItem.get(item.CampaingMemberAssigment__c);
            //throw Error if the total is > 100
            if (totalPercentage > 100) {
                item.addError('trigger error ' + totalPercentage);
            }
        }
    }

    public static void updateCampaignMemberAssigmentItem(List<CampaignMemberAssigmentItem__c> newAssgnmentItem) {
        List<Id> newAssignmentItemIds = new List<Id>(new Map<Id, CampaignMemberAssigmentItem__c>(newAssgnmentItem).keySet());
        List<String> campaignMemberAssignmentIds = new List<String>();
        //get the new percentage of every updated item
        Map<String,Decimal> newItem = new Map<String,Decimal>();
        for (CampaignMemberAssigmentItem__c itm : newAssgnmentItem) {
            campaignMemberAssignmentIds.add(itm.CampaingMemberAssigment__c);
            newItem.put(itm.CampaingMemberAssigment__c, (Decimal)itm.PercentageAllocation__c);
        }
        //query the sum of total percentage for every campaignMemberAssignment excluding the newAssignmentItemIds
        List<AggregateResult> query = [
            SELECT CampaingMemberAssigment__c memberId,
            Sum(PercentageAllocation__c)totalPercentage
            FROM CampaignMemberAssigmentItem__c 
            WHERE CampaingMemberAssigment__c IN :campaignMemberAssignmentIds
            AND Id NOT IN :newAssignmentItemIds 
            WITH SECURITY_ENFORCED
            GROUP BY CampaingMemberAssigment__c
        ];
        //map the total percentage for every campaignMemberAssignment
        Map<String,Decimal> queryResults = new Map<String,Decimal>();
        for (AggregateResult row : query) {
            queryResults.put((String)row.get('memberId'), (Decimal)row.get('totalPercentage'));
        }
        for (CampaignMemberAssigmentItem__c item : newAssgnmentItem) {
            //Add the new inserted value to the existing total percentage to check it's validity
            Decimal totalPercentage = queryResults.get(item.CampaingMemberAssigment__c) + newItem.get(item.CampaingMemberAssigment__c);
            //throw Error if the total is > 100
            if (totalPercentage > 100) {
                item.addError('trigger error ' + totalPercentage);
            }
        }
    }
}
