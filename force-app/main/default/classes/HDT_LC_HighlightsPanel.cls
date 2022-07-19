public with sharing class HDT_LC_HighlightsPanel {
    @AuraEnabled
    public static String updateKpis(String accountId) {
        try {
            Account oldAccount = [SELECT Id, Recaller__c, ComplaintRateNum__c FROM Account WHERE Id = :accountId WITH SECURITY_ENFORCED];
            Account newAccount = new Account(
                Id = accountId,
                Recaller__c = getRecallerPercentage(accountId),
                ComplaintRateNum__c = getComplaintRate(accountId)
            );

            if(
                oldAccount.Recaller__c != newAccount.Recaller__c ||
                oldAccount.ComplaintRateNum__c != newAccount.ComplaintRateNum__c
            ) {
                HDT_UTL_DatabaseService.updateSObject(newAccount);
            }

            return null;
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    private static Integer getRecallerPercentage(String accountId){
        Integer x = 0;
        Integer y;
        try {
            for(AggregateResult result : [SELECT COUNT(Id) FROM Case WHERE AccountId = :accountId AND CreatedDate = LAST_N_DAYS:15 AND Origin IN ('Web','Chat','Sportello','Telefono Inbound') WITH SECURITY_ENFORCED GROUP BY Cluster__c,Type,Subprocess__c]) {
                y = (Integer) result.get('expr0');
                if(y > x) {
                    x = y;
                }
            }
            x = (x > 0 ? x - 1 : 0);
            AggregateResult caseCount = [SELECT COUNT(Id) FROM Case WHERE AccountId = :accountId AND CreatedDate = LAST_N_DAYS:15 AND Origin IN ('Web','Chat','Sportello','Telefono Inbound') WITH SECURITY_ENFORCED];
            y = (Integer) caseCount.get('expr0');
            y = y > 0 ? y : 1;
            // montors fix 904176C
            Double d = ((Double) x) / y;
            return Integer.valueOf(d * 100);
            //return (x / y) * 100;
            // ****
        } catch (Exception e) {
            throw e;
        }
    }

    private static Integer getComplaintRate(String accountId) {
        try {
            AggregateResult result = [SELECT COUNT(Id) FROM Case WHERE AccountId = :accountId AND Cluster__c = 'Reclami' AND CreatedDate = LAST_N_MONTHS:12 WITH SECURITY_ENFORCED];
            return (Integer) result.get('expr0');
        } catch (Exception e) {
            throw e;
        }
    }
}
