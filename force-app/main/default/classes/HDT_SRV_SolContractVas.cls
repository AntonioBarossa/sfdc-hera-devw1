public with sharing class HDT_SRV_SolContractVas {
    public static HDT_WRP_SolContractVas handleRequest(String accountId){
        HDT_WRP_SolContractVas response = new HDT_WRP_SolContractVas();
        if(String.isBlank(accountId))return response;
        
        List<SObject> contractWithOffer = HDT_QR_SolContractVas.getContractWithOffer(accountId);
        if(contractWithOffer.size()==0) return response;
        Set<String> offerSet = new Set<String>();
        
        for(Contract singleContract : (List<Contract>) contractWithOffer){
            List<SBQQ__Subscription__c> subscriptionList = (List<SBQQ__Subscription__c>) singleContract.SBQQ__Subscriptions__r;
            Product2  singleProduct = (Product2 )subscriptionList[0].SBQQ__Product__r;
            offerSet.add(singleProduct.ProductCode);
        }
        List<SObject> productOptionList = HDT_QR_SolContractVas.getProductOptionVas(offerSet);
        if (productOptionList.size()==0) return response;
        HDT_WRP_SolContractVas.HDT_WRP_Vas singleVas = new HDT_WRP_SolContractVas.HDT_WRP_Vas();
        Map<String,Sobject> offerWithVasMap = new Map<String,Sobject>();
        for(SBQQ__ProductOption__c singleOption : (List<SBQQ__ProductOption__c>)productOptionList){
            String offerCode = singleOption.SBQQ__ConfiguredSKU__r.ProductCode;
            offerWithVasMap.put(offerCode, singleOption);
        }

        for(Contract singleContract : (List<Contract>) contractWithOffer){
            singleVas = new HDT_WRP_SolContractVas.HDT_WRP_Vas();
            List<SBQQ__Subscription__c> subscriptionList = (List<SBQQ__Subscription__c>) singleContract.SBQQ__Subscriptions__r;
            Product2  singleProduct = (Product2 )subscriptionList[0].SBQQ__Product__r;
            String offerCode = singleProduct.ProductCode;
            SBQQ__ProductOption__c vasProduct = (SBQQ__ProductOption__c)offerWithVasMap.get(offerCode);
            singleVas.ownerAccountId = accountId;
            singleVas.herVincoloVas = '0';
            singleVas.herVersioneVas = vasProduct.Version__c;
            singleVas.herProfile = vasProduct.SBQQ__ConfiguredSKU__r.Version__c;
            singleVas.herNomeVas = vasProduct.SBQQ__ProductName__c;
            singleVas.herDurataVas = '999999';
            singleVas.herCodOfferta = offerCode;
            singleVas.herCanone = '0';
            singleVas.assetNumber = singleContract.SAPContractCode__c;
            singleVas.idVAS = vasProduct.Id;
            singleVas.herNameVersioneVas = vasProduct.SBQQ__ProductName__c+'_'+vasProduct.Version__c;
            response.listOfVas.add(singleVas);
        }
        return response;
    }
}
