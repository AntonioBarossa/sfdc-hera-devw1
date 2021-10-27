public without sharing class HDT_QR_VocalOrderPublicConfirm {
    public static List<VocalOrderPublicConfirm__C> getVocalPublicConfirm(String orderId){
        return [Select id from VocalOrderPublicConfirm__C where order__c = :orderId];
    }
}
