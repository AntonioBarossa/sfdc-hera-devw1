public inherited sharing class HDT_QR_AmountQuote {

    private static Set<String> verificationProcess = new Set<String>{'Consegna copia chiave GdM','Richiesta lettura cliente','Sost. contatore cliente','Verifica GDM','Verifica Tensione - Pressione'};
    public static List<AdminPriceQuote__c> queryAmount(String distributor, String city, String caliber, Boolean hasCorrector, String market, String commodity, String processType,String year,String supplyUseType,String intendedUse){
         List<AdminPriceQuote__c> priceQuoteList =  [SELECT Amount__c FROM AdminPriceQuote__c 
                    WHERE
                    Distributor__r.Name = :distributor
                    AND City__c = :city
                    AND Caliber__c = :caliber
                    AND HasCorrector__c = :hasCorrector
                    AND Market__c = :market
                    AND Name != 'Default'
                    AND Commodity__c =: commodity
                    AND Name =: processType
                    AND MeterManufactureYear__c =: year
                    AND SupplyUseType__c =: supplyUseType
                    AND IntendedUse__c =: intendedUse
                    WITH SECURITY_ENFORCED
                    LIMIT 1
                ];
        if(priceQuoteList.size()>0){
            return priceQuoteList;
        }else {
            String name = verificationProcess.contains(processType) ? 'Default Verifiche' : 'Default';
            return [SELECT Amount__c FROM AdminPriceQuote__c 
            WHERE
            Name = :name
            WITH SECURITY_ENFORCED
            LIMIT 1
            ];
        }
    }

}