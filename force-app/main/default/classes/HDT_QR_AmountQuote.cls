public without sharing class HDT_QR_AmountQuote {


    public static List<AdminPriceQuote__c> queryAmount(String distributor, String city, String caliber, Boolean hasCorrector, String market){

        return [SELECT Amount__c FROM AdminPriceQuote__c 
                    WHERE
                     
                    (   Distributor__c = :distributor
                        AND City__c = :city
                        AND Caliber__c = :caliber
                        AND   HasCorrector__c = :hasCorrector
                        AND   Market__c = :market
                        AND   Name != 'Default'
                    )

                    OR

                    (
                        Name = 'Default'       
                    )

                    LIMIT 1
                ];

    }

}