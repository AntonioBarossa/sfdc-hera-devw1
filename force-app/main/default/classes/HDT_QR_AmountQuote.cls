public inherited sharing class HDT_QR_AmountQuote {


    public static List<AdminPriceQuote__c> queryAmount(String distributor, String city, String caliber, Boolean hasCorrector, String market, String commodity, String processType,String year){
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
                    LIMIT 1
                ];
        if(priceQuoteList.size()>0){
            return priceQuoteList;
        }else {
            return [SELECT Amount__c FROM AdminPriceQuote__c 
            WHERE
            Name = 'Default'
            LIMIT 1
            ];
        }
    }

}