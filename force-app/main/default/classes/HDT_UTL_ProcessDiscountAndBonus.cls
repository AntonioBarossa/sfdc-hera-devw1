@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_ProcessDiscountAndBonus {

    public Map<String, String> productFamilyMap;
    public List<String> sapContractCodeList;
    public Map<String, Integer> mapHeaderForWrapper;
    public Set<String> contractSet;
    public List<Product2> additionalProduct2;
    public Map<String, List<SBQQ__Subscription__c>> subscriptionMap;

    public HDT_UTL_ProcessDiscountAndBonus(Map<String, Integer> mapHeaderForWrapper) {
        productFamilyMap = new Map<String, String>();
        sapContractCodeList = new List<String>();
        contractSet = new Set<String>();
        subscriptionMap = new Map<String, List<SBQQ__Subscription__c>>();
        this.mapHeaderForWrapper = mapHeaderForWrapper;
        additionalProduct2 = new List<Product2>();
        productFamilyMap.put('BONUS_PERC', 'Bonus Percentuale');
        productFamilyMap.put('BONUS_EUR_GG', 'Bonus Eur/Giorno');
        productFamilyMap.put('BONUS_EUR_MM', 'Bonus Eur/Mese');
        productFamilyMap.put('BONUS_EUR_KWH', 'Bonus Eur/kWh');
        productFamilyMap.put('BONUS_EUR_SMC', 'Bonus Eur/SMC');
        productFamilyMap.put('CONTR_EUR_KWH', 'Contributo Eur/kWh');
        productFamilyMap.put('CONTR_EUR_MM', 'Contributo Eur/Mese');
        productFamilyMap.put('CONTR_EUR_GG', '	Contributo Eur/Giorno');
        productFamilyMap.put('CONTR_EUR_KW', 'Contributo Eur/kW');
        productFamilyMap.put('CONTR_EUR_SMC', 'Contributo Eur/SMC');
    }

    public HDT_UTL_ProcessOrderCreation.HDT_WRP_ChildOrder handleDiscountAndBonus(HDT_UTL_ProcessOrderCreation.HDT_WRP_ChildOrder wrpChildOrder, List<String> csvValues){

        wrpChildOrder.sapContractCode = csvValues[mapHeaderForWrapper.get('CONTRATTO')];
        sapContractCodeList.add(wrpChildOrder.sapContractCode);
        String codiceBonus = '';
        HDT_UTL_ProcessOrderCreation.HDT_WRP_OrderItem wrpOrderItem;

        for(String productFamily : productFamilyMap.keySet()){
            for(Integer i=1; i<=4; i++){
                codiceBonus = csvValues[mapHeaderForWrapper.get(productFamily + '_' + i)];
                if(String.isNotBlank(codiceBonus)){
                    // set wrapper
                    wrpOrderItem = new HDT_UTL_ProcessOrderCreation.HDT_WRP_OrderItem();
                    wrpOrderItem.itemType = 'bonus';
                    wrpOrderItem.product = new Product2();
                    wrpOrderItem.product.ProductCode = codiceBonus;
                    wrpOrderItem.product.Family = productFamilyMap.get(productFamily);
                    wrpOrderItem.orderItem = new OrderItem();
                    wrpChildOrder.orderItemList.add(wrpOrderItem);
                    additionalProduct2.add(wrpOrderItem.product);
                }
            }
        }

        return wrpChildOrder;

    }

    public void getDataForDiscountAndBonus(){

        List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>();
        subscriptionList = [
            SELECT Id, SAPContractCode__c, SBQQ__Product__c, SBQQ__ProductName__c, ProductCode__c, VersionFormula__c, SBQQ__Product__r.Family
            FROM SBQQ__Subscription__c
            WHERE SAPContractCode__c IN :sapContractCodeList
            WITH SECURITY_ENFORCED
        ];
        
        List<Contract> contractList = [
            SELECT SAPContractCode__c
            FROM Contract
            WHERE SAPContractCode__c IN :sapContractCodeList
            WITH SECURITY_ENFORCED
        ];

        for(SBQQ__Subscription__c sub : subscriptionList){
            if(subscriptionMap.containsKey(sub.SAPContractCode__c)){
                subscriptionMap.get(sub.SAPContractCode__c).add(sub);
            } else {
                subscriptionMap.put(sub.SAPContractCode__c, new List<SBQQ__Subscription__c>{sub});
            }
        }

        for(Contract c : contractList){
            contractSet.add(c.SAPContractCode__c);
        }

    }

    public HDT_UTL_ProcessOrderCreation.HDT_WRP_ProcessObjects checkDiscountAndBonus(HDT_UTL_ProcessOrderCreation.HDT_WRP_ProcessObjects processObj){
        
        Set<String> subscriptionSet;
        Map<String, Integer> checkFamilyMap = new Map<String, Integer>();

        for(HDT_UTL_ProcessOrderCreation.HDT_WRP_ChildOrder wrpChildOrder : processObj.childOrderList){
            if(wrpChildOrder.orderType.equalsIgnoreCase('Attivazione')){

                if(!contractSet.contains(wrpChildOrder.sapContractCode)){
                    processObj.requestItem.Status__c = 'Errore';
                    processObj.requestItem.StatusDescription__c = 'Contratto ' + wrpChildOrder.sapContractCode + ' non presente a sistema';
                    return processObj;
                }

                if(subscriptionMap.containsKey(wrpChildOrder.sapContractCode)){
                    subscriptionSet = new Set<String>();
                    for(SBQQ__Subscription__c sub : subscriptionMap.get(wrpChildOrder.sapContractCode)){
                        subscriptionSet.add(sub.ProductCode__c);
                        if(checkFamilyMap.containsKey(sub.SBQQ__Product__r.Family)){
                            Integer i = checkFamilyMap.get(sub.SBQQ__Product__r.Family);
                            checkFamilyMap.put(sub.SBQQ__Product__r.Family, i+1);
                        } else {
                            checkFamilyMap.put(sub.SBQQ__Product__r.Family, 1);
                        }
                    }
                } else {
                    //processObj.requestItem.Status__c = 'Errore';
                    //processObj.requestItem.StatusDescription__c = 'Contratto ' + wrpChildOrder.sapContractCode + ' non presente a sistema';
                    //return processObj;
                }

                for(HDT_UTL_ProcessOrderCreation.HDT_WRP_OrderItem orderItem : wrpChildOrder.orderItemList){
                    if(subscriptionSet != null && subscriptionSet.size() > 0 && subscriptionSet.contains(orderItem.product.ProductCode)){
                        processObj.requestItem.Status__c = 'Errore';
                        processObj.requestItem.StatusDescription__c = 'Il prodotto ' + orderItem.product.ProductCode + ' risulta già inserito nel contratto ' + wrpChildOrder.sapContractCode;
                        return processObj;
                    }

                    if(checkFamilyMap.containsKey(orderItem.product.Family)){
                        Integer i = checkFamilyMap.get(orderItem.product.Family);
                        checkFamilyMap.put(orderItem.product.Family, i+1);
                    } else {
                        checkFamilyMap.put(orderItem.product.Family, 1);
                    }
                }

                if(checkFamilyMap.size() > 0){
                    for(String family : checkFamilyMap.keySet()){
                        if(checkFamilyMap.get(family) > 4){
                            processObj.requestItem.Status__c = 'Errore';
                            processObj.requestItem.StatusDescription__c = 'Per la Product Family ' + family + ' sono presenti 4 prodotti nel contratto ' + wrpChildOrder.sapContractCode;
                            return processObj;
                        }
                    }
                }

            }
        }

        return processObj;

    }

}