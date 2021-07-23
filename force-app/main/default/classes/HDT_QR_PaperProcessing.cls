public with sharing class HDT_QR_PaperProcessing {
    public static PaperProcessing__c getParameterForName(List<String> listPaper){
        return [Select id,Campaign__r.PaperCampaignParameter__r.CostCenter__c,Campaign__r.PaperCampaignParameter__r.LetterType__c from PaperProcessing__c Where Id IN :listPaper];
    }
}
