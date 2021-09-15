/**
* @author Fatjola Memishaj (fatjola.memishaj@dunegroup.it)
* @date 19/03/2021
* @description HDT_UTL_CampaignMemberAssigmentItem
* @history Fatjola Memishaj – 19/03/2021 – Created class
*/
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
            //** [START MOD 2021-08-05] @Author:Luca Belometti WR (luca.belometti@webresults.it) @Description: Added this check by 2 vars to avoid the error of null values 
            Decimal queryResultValue = queryResults.get(item.CampaingMemberAssigment__c) != null ? queryResults.get(item.CampaingMemberAssigment__c) : 0;
            Decimal newItemValue = newItem.get(item.CampaingMemberAssigment__c) != null ? newItem.get(item.CampaingMemberAssigment__c) : 0;
            //OLD VALUE of TotalPercentage
            //Decimal totalPercentage = queryResults.get(item.CampaingMemberAssigment__c) + newItem.get(item.CampaingMemberAssigment__c);
            Decimal totalPercentage = queryResultValue + newItemValue;
            //** [END MOD 2021-08-05] @Author:Luca Belometti WR (luca.belometti@webresults.it) @Description: Added this check by 2 vars to avoid the error of null values
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
            //** [START MOD 2021-08-05] @Author:Fabricio Nunes WR) @Description: Added this check by 2 vars to avoid the error of null values 
            Decimal queryResultValue = queryResults.get(item.CampaingMemberAssigment__c) != null ? queryResults.get(item.CampaingMemberAssigment__c) : 0;
            Decimal newItemValue = newItem.get(item.CampaingMemberAssigment__c) != null ? newItem.get(item.CampaingMemberAssigment__c) : 0;
            //OLD VALUE of TotalPercentage
            //Decimal totalPercentage = queryResults.get(item.CampaingMemberAssigment__c) + newItem.get(item.CampaingMemberAssigment__c);
            Decimal totalPercentage = queryResultValue + newItemValue;
            //** [END MOD 2021-08-05] @Author:Fabricio Nunes WR (luca.belometti@webresults.it) @Description: Added this check by 2 vars to avoid the error of null values
            //throw Error if the total is > 100

            if (totalPercentage > 100) {
                item.addError('trigger error ' + totalPercentage);
            }
        }
    }
}
