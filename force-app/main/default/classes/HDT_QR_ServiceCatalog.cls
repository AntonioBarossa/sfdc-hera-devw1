/**
 * @author Lorenzo Gulotta (lorenzo.gulotta@webresults.it)
 * @date 21/06/2021
 * @description HDT_QR_ServiceCatalog Class
 * @history Lorenzo Gulotta – 21/06/2021 – Created Class
 */

public with sharing class HDT_QR_ServiceCatalog {
    public static String getServiceLinkItemAccountRedirectUrlByCategory (String category,String subcategory){
        String result = '';
        List<wrts_prcgvr__ServiceLinkItem__c> lsitAction = [SELECT Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, wrts_prcgvr__ServiceLink__c, wrts_prcgvr__Label__c, wrts_prcgvr__LightningActionParams__c, wrts_prcgvr__LightningAction__c, wrts_prcgvr__ObjectType__c, wrts_prcgvr__URL__c 
                                                            FROM wrts_prcgvr__ServiceLinkItem__c 
                                                            WHERE wrts_prcgvr__serviceLink__r.wrts_prcgvr__label__c = :subcategory 
                                                            AND wrts_prcgvr__ObjectType__c = 'Account' WITH SECURITY_ENFORCED];
        if(lsitAction != null && !lsitAction.isEmpty()){
            for(Integer i=0; i< lsitAction.size(); i++){
                if(lsitAction[i].wrts_prcgvr__URL__c != null && lsitAction[i].wrts_prcgvr__URL__c != ''){
                    result = lsitAction[i].wrts_prcgvr__URL__c;
                    break;
                }
            }
            return result;
        } 
        else{
            return null;
        }

    }
}
