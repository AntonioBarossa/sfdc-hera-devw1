public with sharing class HDT_LC_hdtHighlightsPanel {
    @AuraEnabled
    public static string updateRecallerCount(String accountId){
        Integer x = 0;
        Integer y;
        try {
            Account account = [SELECT Id, Recaller__c FROM Account WHERE Id = :accountId WITH SECURITY_ENFORCED];
            for(AggregateResult ar : [SELECT COUNT(Id) FROM Case WHERE AccountId = :accountId AND CreatedDate = LAST_N_DAYS:15 AND Origin IN ('Web','Chat','Sportello','Telefono Inbound') WITH SECURITY_ENFORCED GROUP BY Cluster__c,ProcessType__c,Subprocess__c]) {
                y = (Integer) ar.get('expr0');
                if(y > x) {
                    x = y;
                }
            }

            x = (x > 0 ? x - 1 : 0);
            if(account.Recaller__c != x) {
                account.Recaller__c = x;
                update account;
            }

            return null;
        } catch (Exception e) {
            return e.getMessage();
        }
    }
}
