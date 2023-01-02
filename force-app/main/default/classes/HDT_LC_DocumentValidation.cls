/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 27/02/2021
* @description HDT_LC_DocumentValidation
* @history Keltin Mesonjesi – 27/02/2021 – Created class
*/

public inherited sharing class HDT_LC_DocumentValidation {
    private static HDT_QR_Order orderQr = new HDT_QR_Order();
	private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();

    /**
    * @description isValidPhase
    * @param recordId
    * @return Boolean
    */
    @AuraEnabled
    public static Boolean isValidPhase(String recordId){
        Order ord = orderQr.getRecordById(recordId);
        return ('Credit Check KO'.equalsIgnoreCase(ord.phase__c) || 'Attesa Credit Check'.equalsIgnoreCase(ord.phase__c) ||'Da Inviare'.equalsIgnoreCase(ord.phase__c) || 'In Attesa Validazione'.equalsIgnoreCase(ord.phase__c) || 'Documentazione da validare'.equalsIgnoreCase(ord.Phase__c));
    }
    
    /**
    * @description saveValidation
    * @param ord
    */
    @AuraEnabled
    public static void saveValidation(Order ord){
        // quelli mostrati ( non null) tutti validati -----> phase --->  Documentazione Validata
   		Boolean check = false;
        if( /*Aggiunta carta identita*/ord.CIAccoutn__c != null 
            || ord.QuickQuote__c != null 
            || ord.ChamberCommerceRegistration__c != null 
            || ord.Instance326__c != null 
            || ord.DocumentLow80__c != null 
            || ord.AutorizationVolturaThirdTrader__c != null
            || ord.CILegalRepresentative__c != null)
        {
           	check = true;
            //Per voltura
            if(ord.CIAccoutn__c != null && !'Validato'.EqualsIgnoreCase(ord.CIAccoutn__c)){
                check = false;
            }
            //Per voltura
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
            if(ord.DocumentPackage__c != null && !'Validato'.EqualsIgnoreCase(ord.DocumentPackage__c)){
                check = false;
            }
            if(ord.CILegalRepresentative__c != null && !'Validato'.equalsIgnoreCase(ord.CILegalRepresentative__c))
            {
                check = false;
            }
            
        }
        if(check){

            Order orderRetrive = orderQr.getRecordById(ord.Id);
            if ('In Attesa validazione'.equalsIgnoreCase(orderRetrive.Phase__c)){
                ord.Phase__c = 'Documentazione Validata';
            }

            if(orderRetrive.ParentOrder__c == null){
                ord.Phase__c = 'Documentazione Gestita';
            }

        }
        orderSrv.updateRecord(ord);
        //update ord;
        //return true;
        //Order ord = orderQr.getRecordById(recordId);
        //return ('Da Inviare'.equalsIgnoreCase(ord.phase__c) || 'In Attesa Validazione'.equalsIgnoreCase(ord.phase__c));
    }

    /**
    * @description cancelOrder
    * @param recordId
    */
    @AuraEnabled
    public static void cancelOrder(String recordId){
        orderSrv.updateRecord(new Order(
            Id = recordId,
            Status = 'Annullato', //Chiuso
            Phase__c = 'Annullato'
        ));
    }

    @AuraEnabled
    public static string getOrderAccountId(Id orderRecordId){
        
        Order o = [SELECT Id, AccountId FROM Order WHERE Id =: orderRecordId with SECURITY_ENFORCED];
        return o.AccountId;
    }

    @AuraEnabled
    public static void updateOrder(Order ord){
        orderSrv.updateRecord(ord);
    }
}