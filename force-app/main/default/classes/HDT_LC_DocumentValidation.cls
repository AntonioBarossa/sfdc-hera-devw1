public inherited sharing class HDT_LC_DocumentValidation {
    private static HDT_QR_Order orderQr = new HDT_QR_Order();
	private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    @AuraEnabled
    public static Boolean isValidPhase(String recordId){
        Order ord = orderQr.getRecordById(recordId);
        return ('Da Inviare'.equalsIgnoreCase(ord.phase__c) || 'In Attesa Validazione'.equalsIgnoreCase(ord.phase__c));
    }
    
    @AuraEnabled
    public static void saveValidation(Order ord){
        System.debug('**************:'+ord);
        // quelli mostrati ( non null) tutti validati -----> phase --->  Documentazione Validata
   		Boolean check = false;
        if(ord.CILegalRepresentative__c != null ||  ord.CIAccoutn__c != null || ord.QuickQuote__c != null || ord.ChamberCommerceRegistration__c != null || ord.Instance326__c != null || ord.DocumentLow80__c != null || ord.AutorizationVolturaThirdTrader__c != null)
        {
           	check = true;
            if(ord.CILegalRepresentative__c != null && !'Validato'.EqualsIgnoreCase(ord.CILegalRepresentative__c)){
                check = false;
            }
            if(ord.CIAccoutn__c != null && !'Validato'.EqualsIgnoreCase(ord.CIAccoutn__c)){
                check = false;
            }
            if(ord.QuickQuote__c != null && !'Validato'.EqualsIgnoreCase(ord.QuickQuote__c)){
                check = false;
            }
            if(ord.ChamberCommerceRegistration__c != null && !'Validato'.EqualsIgnoreCase(ord.ChamberCommerceRegistration__c)){
                check = false;
            }
            if(ord.Instance326__c != null && !'Validato'.EqualsIgnoreCase(ord.Instance326__c)){
                check = false;
            }
            if(ord.DocumentLow80__c != null && !'Validato'.EqualsIgnoreCase(ord.DocumentLow80__c)){
                check = false;
            }
            if(ord.AutorizationVolturaThirdTrader__c != null && !'Validato'.EqualsIgnoreCase(ord.AutorizationVolturaThirdTrader__c)){
                check = false;
            }
            
        }
        if(check){
            ord.Phase__c = 'Documentazione Validata';
        }
        System.debug('************:'+ord);
        orderSrv.updateRecord(ord);
        //update ord;
        //return true;
        //Order ord = orderQr.getRecordById(recordId);
        //return ('Da Inviare'.equalsIgnoreCase(ord.phase__c) || 'In Attesa Validazione'.equalsIgnoreCase(ord.phase__c));
    }
}