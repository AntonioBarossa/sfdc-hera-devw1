public with sharing class HDT_QR_ServiceCatalog {
    public static String getServiceLinkItemAccountRedirectUrlByCategory (String category,String subcategory){
        String res;
        List<wrts_prcgvr__ServiceLinkItem__c> lsitAction = [SELECT Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, wrts_prcgvr__ServiceLink__c, wrts_prcgvr__Label__c, wrts_prcgvr__LightningActionParams__c, wrts_prcgvr__LightningAction__c, wrts_prcgvr__ObjectType__c, wrts_prcgvr__URL__c FROM wrts_prcgvr__ServiceLinkItem__c Where wrts_prcgvr__serviceLink__r.wrts_prcgvr__label__c = :subcategory and wrts_prcgvr__ObjectType__c = 'Account'];
        if(lsitAction != null && !lsitAction.isEmpty()){
            return lsitAction[0].wrts_prcgvr__URL__c;
        } 
        else{
            return null;
        }

    }
}
