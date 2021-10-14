/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 04/12/2020
* @description HDT_LC_ApplyBillingProfileModal – Back-end controller for hdtApplyBillingProfileModal.js lwc component
* @history Keltin Mesonjesi – 04/12/2020 – Created class
*/
public inherited sharing class HDT_LC_ApplyBillingProfileModal {
    
    private static HDT_QR_QuoteLine quoteLineQr = new HDT_QR_QuoteLine();
    private static HDT_SRV_QuoteLine quoteLineSrv = new HDT_SRV_QuoteLine();

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 04/12/2020
    * @description Get SBQQ__QuoteLine__c based on payment method
    * @param String saleId
    * @param String paymentMethod
    * @return Map<String, List<SBQQ__QuoteLine__c>>
    */
    @AuraEnabled
    public static Map<String, List<SBQQ__QuoteLine__c>> getQuoteLineBundle(String saleId, String paymentMethod, String sendingBillMode){

        System.debug('saleId: ' + saleId);
        System.debug('paymentMethod: ' + paymentMethod);
        System.debug('sendingBillMode: ' + sendingBillMode);

        quoteLineSrv.checkReadAccess('SBQQ__RequiredBy__c,SBQQ__RequiredBy__r.Name,ServicePoint__c,ServicePoint__r.ServicePointCode__c,SBQQ__RequiredBy__r.SBQQ__Product__r.Name,SBQQ__Quote__r.Name,SBQQ__Quote__r.SBQQ__Opportunity2__r.Name');

        List<SBQQ__QuoteLine__c> listPodPdr = quoteLineQr.getRecordsBySaleFilteredPaymentMethodPodPdr(saleId, paymentMethod, sendingBillMode);
        System.debug('query result pod/pdr: ' + listPodPdr);
        
        
        List<SBQQ__QuoteLine__c> listVas = quoteLineQr.getRecordsBySaleFilteredPaymentMethodforVas(saleId);
        System.debug('query result vas: ' + listVas);
        
        //***2809 LG disattivato per problemi visibilita */
        //List<SBQQ__QuoteLine__c> listBonus =   quoteLineQr.getRecordsBySaleFilteredFamilyBonus(saleId);
        //system.debug('query result sconti: '+listBonus );
        //listBonus = getBonusPerOffer(listBonus);
        List<SBQQ__QuoteLine__c> listBonus = new List<SBQQ__QuoteLine__c>();
        /****** */
        List<SBQQ__QuoteLine__c> listVasCambioOfferta = quoteLineQr.getQuoteLinesWithCambioOfferta(saleId);
        System.debug('query result listVasCambioOfferta: ' + listVasCambioOfferta);

        Map<String, List<SBQQ__QuoteLine__c>> quoteLineMap = new Map<String, List<SBQQ__QuoteLine__c>>();
        quoteLineMap.put('listPodPdr', listPodPdr);
        quoteLineMap.put('listVas', listVas);
        quoteLineMap.put('listVasCambioOfferta', listVasCambioOfferta);
       quoteLineMap.put('listBonus', listBonus);

        return quoteLineMap;
    }

    public static List<SBQQ__QuoteLine__c> getBonusPerOffer(List<SBQQ__QuoteLine__c> allBonus){
        Map<id, SBQQ__QuoteLine__c> aQuoteLinePerOffer = new Map<id, SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLine__c line : allBonus ){
            if(!aQuoteLinePerOffer.containsKey(line.SBQQ__RequiredBy__c)){
                aQuoteLinePerOffer.put(line.SBQQ__RequiredBy__c, line);
            }
        }
        return aQuoteLinePerOffer.values();
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 04/12/2020
    * @description Update SBQQ__QuoteLine__c BillingProfile__C
    * @param List<SObject> quoteLinesToUpdate
    * @param String billingProfileId
    */
    @AuraEnabled
    public static void updateQuoteLinesBillingProfile(List<SObject> quoteLinesToUpdate, String billingProfileId){

        //get only ids from selected quoteLines
        Set<String> quoteLineIdsSet = (new Map<String,SObject>(quoteLinesToUpdate)).keySet().clone();

        List<String> quoteLineIdsList = new List<String>();
        quoteLineIdsList.addAll(quoteLineIdsSet);

        //get only ids from analisiConsumi quotelines
        List<SBQQ__QuoteLine__c> analisiConsumiList = quoteLineQr.getQuoteLineAnalisiConsumi(quoteLineIdsList);

        if (!analisiConsumiList.isEmpty()) {
            Set<String> quoteLineAnalisiConsumiIdsSet = (new Map<String,SObject>(analisiConsumiList)).keySet().clone();
            quoteLineIdsList.addAll(quoteLineAnalisiConsumiIdsSet);
        }
        
        //update billing profile on all retrieved quoteLines
        List<SBQQ__QuoteLine__c> quoteLineListUpdate = new List<SBQQ__QuoteLine__c>();

        for (String quoteLineId : quoteLineIdsList) {
            SBQQ__QuoteLine__c quoteLineUpdate = new SBQQ__QuoteLine__c(
                Id = quoteLineId,
                BillingProfile__c = billingProfileId
            );
            quoteLineListUpdate.add(quoteLineUpdate);
        }

        quoteLineSrv.updateRecords(quoteLineListUpdate);

    }

}