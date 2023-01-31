/**
 * @author Keltin Mesonjesi
 * @date 17/03/2021
 * @description HDT_LC_QuoteAmendContract Class
 * @history Keltin Mesonjesi - 17/03/2021 - Created Class
 */

public inherited sharing class HDT_LC_QuoteAmendContract {
    
    private static HDT_QR_QuoteLine quoteLineQr = new HDT_QR_QuoteLine();
    private static HDT_SRV_QuoteLine quoteLineSrv = new HDT_SRV_QuoteLine();
    private static HDT_QR_SaleServiceItem saleServiceItemQr = new HDT_QR_SaleServiceItem();
    private static HDT_SRV_SaleServiceItem saleServiceItemSrv = new HDT_SRV_SaleServiceItem();
    private static HDT_SRV_Contract contractSrv = new HDT_SRV_Contract();
    private static HDT_QR_Contract contractQr = new HDT_QR_Contract();

    private static void assocBillingProfileFromContract(String contractId, String saleId){
        contractSrv.checkReadAccess('Name,AccountId,ContractNumber,BillingProfile__c,Status');
        List<Contract> contract = contractQr.getRecordById(contractId);
        List<SBQQ__QuoteLine__c> quoteLine = quoteLineQr.getRecordsByContractFilteredPaymentMethodNotNull(contractId,saleId);
        // Set<String> famils = HDT_UTL_OrderProcessAssignment.getFamilySconto();
        //quoteLine.addAll([Select id, name, BillingProfile__c, SBQQ__Quote__c from SBQQ__QuoteLine__c where SBQQ__Quote__r.ContractReference__c=:contractId AND SBQQ__Quote__r.Sale__c=:saleId AND SBQQ__ProductFamily__c IN :famils WITH SECURITY_ENFORCED]);

        system.debug('HDT_LC_QuoteAmendContract - contract: ' + contract);
        system.debug('HDT_LC_QuoteAmendContract - quoteLine: ' + quoteLine);

        if (!contract.isEmpty() && !quoteLine.isEmpty()) {
            List<SBQQ__QuoteLine__c> qlToUpdate = new List<SBQQ__QuoteLine__c>();
            for(SBQQ__QuoteLine__c ql :quoteLine ){
                qlToUpdate.add(new SBQQ__QuoteLine__c(Id=ql.id, BillingProfile__c=contract[0].BillingProfile__c) );
            }
            quoteLineSrv.updateRecords(qlToUpdate);
        } else {
            system.debug('HDT_LC_QuoteAmendContract - assocBillingProfileFromContract - nessun contract o quoteLine trovato');
        }

    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Associate ServicePoint to QuoteLines of type "POD"
    * @param String contractId - SBQQ__Quote__r.ContractReference__c
    */
    private static void assocPodToQuoteLine(String contractId, String saleId){
       
        //get all quoteLine pods
        quoteLineSrv.checkReadAccess('Name,SBQQ__Product__r.Name,SBQQ__Quote__r.Name,SBQQ__Quote__r.SBQQ__Opportunity2__r.Name,ServicePoint__c');
        Map<id, SBQQ__QuoteLine__c> podsAndVas = new Map<id, SBQQ__QuoteLine__c>(quoteLineQr.getRecordsByContractAndProductPod(contractId, saleId));
        system.debug('HDT_LC_QuoteAmendContract - podsAndVas: ' + podsAndVas);

        Map<id, List<id>> podToChilds = new Map<id, List<id>>(); //id pod to other QL with the same father as the pod
        Map<id, id> podToFather = new Map<id, id>(); // this map connect father with pod, I use to increase efficiency on mapping podToChilds 
        List<SBQQ__QuoteLine__c> quoteLinePods = new List<SBQQ__QuoteLine__c>(); //this contains just the ql pod/pdr
        Set<String> spProductNameSet = new Set<String>();
        spProductNameSet.add('POD');
        spProductNameSet.add('PDR');
        spProductNameSet.add('Punto Fornitura Acqua');
        spProductNameSet.add('Punto Fornitura Ambiente');

        for(SBQQ__QuoteLine__c ql : podsAndVas.values()){
            if(String.isNotBlank(ql.SBQQ__Product__r.Name) && spProductNameSet.contains(ql.SBQQ__Product__r.Name)){
                quoteLinePods.add(ql);
                podToChilds.put(ql.id, new List<Id>());
                podToFather.put(ql.SBQQ__RequiredBy__c, ql.id);
            }
        }
        for(SBQQ__QuoteLine__c ql : podsAndVas.values()){
            id key = podToFather.get(ql.SBQQ__RequiredBy__c);
            if(key!= ql.id && key!=null){
                podToChilds.get(key).add(ql.id);
            }
        }
        system.debug('HDT_LC_QuoteAmendContract - quoteLinePods: ' + quoteLinePods);

        //get all saleServiceItems for this quote
        saleServiceItemSrv.checkReadAccess('Quote__c,ServicePoint__c,ServicePoint__r.RecordType.Name,ServicePoint__r.RecordType.DeveloperName');
        List<SaleServiceItem__c> saleServiceItems = saleServiceItemQr.getRecordsByContract(contractId, saleId);
        system.debug('HDT_LC_QuoteAmendContract - saleServiceItems: ' + saleServiceItems);

        //check ql number equal to number of service points
        if (quoteLinePods.size() == saleServiceItems.size()) {
            
            List<SBQQ__QuoteLine__c> quoteLinesWithoutServicePoint = new List<SBQQ__QuoteLine__c>();
            List<String> notAvailableServicePoints = new List<String>();
            List<String> availableServicePoints = new List<String>();

            //split ql without service point from those with service points
            for (SBQQ__QuoteLine__c quoteLinePod : quoteLinePods) {
                if (quoteLinePod.ServicePoint__c == null) {
                    quoteLinesWithoutServicePoint.add(quoteLinePod);
                } else {
                    notAvailableServicePoints.add(quoteLinePod.ServicePoint__c);
                }
            }

            //continue with assignment if there ql without service points
            if (!quoteLinesWithoutServicePoint.isEmpty()) {
                //get service points that haven't been assigned yet
                for (SaleServiceItem__c saleServiceItem : saleServiceItems) {
                    if (!notAvailableServicePoints.contains(saleServiceItem.ServicePoint__c)) {
                        system.debug('entered r74');
                        availableServicePoints.add(saleServiceItem.ServicePoint__c);
                    }
                }

                //new list with ql to update
                List<SBQQ__QuoteLine__c> quoteLinesToUpdate = new List<SBQQ__QuoteLine__c>();
                system.debug('availableServicePoints '+json.serialize(availableServicePoints));

                for (Integer i = 0; i < availableServicePoints.size(); i++) {
                    system.debug('entered r84');
                    quoteLinesToUpdate.add(new SBQQ__QuoteLine__c(
                        Id = quoteLinesWithoutServicePoint[i].Id,
                        ServicePoint__c = availableServicePoints[i]
                    ));
                    for(id childId : podToChilds.get(quoteLinesWithoutServicePoint[i].Id)){
                        if(childId==null){ break; }
                        quoteLinesToUpdate.add(new SBQQ__QuoteLine__c(
                            Id = childId,
                            ServicePoint__c = availableServicePoints[i]
                        ));
                    }
                }

                quoteLineSrv.updateRecords(quoteLinesToUpdate);

            } else {
                system.debug('HDT_LC_QuoteAmendContract - assocPodToQuoteLine - All Service Points have been assigned!');
            }

        } else {
            system.debug('HDT_LC_QuoteAmendContract - assocPodToQuoteLine - Configurare i prodotti per tutti i Service Point!');
        }

    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Check if products have been created for quote
    * @param String quoteId
    */
    private static Boolean haveProductsBeenCreated(String quoteId){
        List<SBQQ__QuoteLine__c> createdQuoteLines = quoteLineQr.getRecordsByQuoteId(quoteId);

        return !createdQuoteLines.isEmpty();
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Execute actions when exiting modal
    * @param String contractId - SBQQ__Quote__r.ContractReference__c
    */
    @AuraEnabled
    public static Boolean execModalExitActions(String contractId, String saleId, String quoteId){
        assocBillingProfileFromContract(contractId, saleId);
        assocPodToQuoteLine(contractId, saleId);

        return haveProductsBeenCreated(quoteId);
    }

}