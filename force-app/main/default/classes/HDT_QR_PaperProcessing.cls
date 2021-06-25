public with sharing class HDT_QR_PaperProcessing {
    public static PaperProcessing__c getParameterForName(List<String> listPaper){
        return [Select id,Campaing__r.PaperCampaignParameter__r.CostCenter__c   Campaing__r.PaperCampaignParameter__r.LetterType__c from PaperProcessing__c Where Id :listPaper];
    }
}
