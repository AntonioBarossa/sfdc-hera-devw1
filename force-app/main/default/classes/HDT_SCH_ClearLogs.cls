global with sharing class HDT_SCH_ClearLogs implements Schedulable {
    @SuppressWarnings('PMD.ApexSuggestUsingNamedCred')
    global void execute(SchedulableContext SC) {
        String idString = '';
        for(List<ApexLog> logs : [SELECT Id FROM ApexLog LIMIT 50000]) {
            // THE SERVICE HANDLES MAX 200 DELETES PER CALL
            for(ApexLog log : logs) {
                idString += log.id + ',';
            }
            idString.removeEnd(',');

            if(String.isNotBlank(idString) && Limits.getCallouts() < Limits.getLimitCallouts()) {
                HttpRequest req = new HttpRequest();
                req.setEndpoint(Url.getOrgDomainUrl().toExternalForm() + '/services/data/v44.0/composite/sobjects?ids=' + idString);
                req.setMethod('DELETE');
                req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
                req.settimeout(120000);
                new Http().send(req);
            } else {
                return;
            }
        }
    }
}
