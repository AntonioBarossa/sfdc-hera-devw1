/**
 * @author Lorenzo Gulotta (lorenzo.gulotta@webresults.it)
 * @date 28/09/2021
 * @description HDT_BA_RecurringCampaingCreation Class
 * @history Lorenzo Gulotta – 28/09/2021 – Created Class
 */
public with sharing class HDT_BA_PublicValidation implements Database.Batchable<sObject>, Database.Stateful{
   
    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    List<VocalOrderPublicConfirm__c> vocalToUpdate = new List<VocalOrderPublicConfirm__c>();
    Map<String,Order> orderToUpdate = new Map<String,Order>();
    public Database.QueryLocator start(Database.BatchableContext bc) {

        String query = 'SELECT Id,Order__c,Status__c,Createddate FROM VocalOrderPublicConfirm__c WHERE Status__c != \'Chiusa\'';
        System.debug(query);
        return Database.getQueryLocator(query);
        
    }
    public void execute(Database.BatchableContext bc, List<VocalOrderPublicConfirm__c> scope){
        System.debug(scope);
        List<String> orderParentList = new List<String>();
        for(VocalOrderPublicConfirm__c vo : scope){
            orderParentList.add(vo.order__c);
            vo.Status__c = 'Chiusa';
            vocalToUpdate.add(vo);
            Order ord = new Order();
            ord.id = vo.Order__c;
            ord.SignedDate__c = vo.createddate.date();
            ord.MethodSignedAccepted__c = 'web assistito';
            //orderToUpdate.add(ord);
            orderToUpdate.put(ord.id,ord);
        }
        List<order> childOrder = orderQr.getChildOrdersByParentIds(orderParentList);
        for(Order child : childOrder){
            Order ord = new Order();
            ord.id = child.id;
            ord.SignedDate__c = orderToUpdate.get(child.ParentOrder__c).SignedDate__c;
            ord.MethodSignedAccepted__c = 'web assistito';
            orderToUpdate.put(ord.id,ord);
        }
    }
    public void finish(Database.BatchableContext bc){
        if(orderToUpdate.values() != null && !orderToUpdate.values().isEmpty()){
            orderSrv.updateRecords(orderToUpdate.values());   
        }
        if(VocalToUpdate != null && !VocalToUpdate.isEmpty()){
            update vocalToUpdate;
        }
    }
}
