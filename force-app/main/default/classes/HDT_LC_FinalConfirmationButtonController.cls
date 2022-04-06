public with sharing class HDT_LC_FinalConfirmationButtonController {
    @AuraEnabled
    public static String updateRecord(String orderId){
        System.debug('@@@@OrderId@@@'+orderId);
        
        Order order = [select Id, SignedDate__c, MethodSignedAccepted__c from Order where Id=:orderId];
        order.SignedDate__c = Date.today();
        order.MethodSignedAccepted__c = 'IVR';
        
        try{
            update order;
        }
        catch (Exception e) {
            System.debug('unable to update the record due to'+e.getMessage());
            return 'error';
        }

        List<Order> orders = [select Id, SignedDate__c, MethodSignedAccepted__c, confirmCustomerContract__c from Order where ParentOrder__c=:orderId];
        if(orders!=null && orders.size()>0){
            List<Order> newOrd = new List<Order>();
            for (Order ord : orders){
                ord.SignedDate__c = Date.today();
                ord.MethodSignedAccepted__c = 'IVR';
                ord.ConfirmCustomerContract__c = 'IVR';
                newOrd.add(ord);
            }
            try{
                update newOrd;
            }
            catch (Exception e) {
                System.debug('unable to update the record due to'+e.getMessage());
                return 'error';
            } 
        }
        return 'ok';
        }
    }