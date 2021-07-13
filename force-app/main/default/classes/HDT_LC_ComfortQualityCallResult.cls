public inherited sharing class HDT_LC_ComfortQualityCallResult {
    
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();

    @AuraEnabled
    public static void confirmContract(String ordId){
        orderSrv.updateRecord(new Order(
            Id = ordId,
            Phase__c = 'Comunicazione verso Heroku'
        ));
    }

    @AuraEnabled
    public static void cancelContract(String ordId){
        orderSrv.updateRecord(new Order(
            Id = ordId,
            Phase__c = 'Annullato per no conferma cliente'
        ));
    }
}
