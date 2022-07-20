public with sharing class HDT_LC_AgentMatrixSearchToolController {
    // INIZIALMENTE QUESTO CMP DOVEVA USARE IL CODICE AGENTE. E' STATO ROZZAMENTE CONVERTITO PER USARE IL CODICE AGENZIA
    @AuraEnabled
    public static List<AggregateResult> getCurrentAgent(String ruleId){
        //try {
            AssignmentRule__c rule = [SELECT Id, SalesAgency__c FROM AssignmentRule__c WHERE Id =: ruleId WITH SECURITY_ENFORCED];
            if(String.isNotBlank(rule.SalesAgency__c)) {
                List<String> agencyList = rule.SalesAgency__c.split(';');
                List<AggregateResult> matrix = [SELECT AgencyName__c, AgencyCode__c FROM AgentMatrix__c WHERE AgencyCode__c IN:agencyList WITH SECURITY_ENFORCED GROUP BY AgencyName__c, AgencyCode__c];
                if(matrix.size() > 0) {
                    return matrix;
                } /*else {
                    return new List <AgentMatrix__c>(
                        AgencyName__c = 'NON CENSITO',
                        AgencyCode__c = rule.SalesAgency__c + ' (NON CENSITO)'
                    );
                }*/
            }
            return null;
        /*} catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }*/
    }

    @AuraEnabled
    public static List<AgentMatrix__c> getAgents(String queryString){
        queryString = '%' + queryString +'%';
        //try {
            return [SELECT Id, AgentFirstName__c, AgentLastName__c, AgentCode__c, AgencyName__c, AgencyCode__c FROM AgentMatrix__c WHERE AgencyName__c LIKE: queryString OR AgentLastName__c LIKE: queryString OR AgencyCode__c LIKE:queryString  WITH SECURITY_ENFORCED];
        //} catch (Exception e) {
        //    throw new AuraHandledException(e.getMessage());
        //}
    }

    @AuraEnabled
    public static List<AggregateResult> getAgentsGrouped(String queryString){
        queryString = '%' + queryString +'%';
        //try {
            List<AggregateResult> agmList = [SELECT AgencyName__c, AgencyCode__c FROM AgentMatrix__c WHERE AgencyName__c LIKE: queryString OR AgentLastName__c LIKE: queryString OR AgencyCode__c LIKE:queryString WITH SECURITY_ENFORCED GROUP BY AgencyName__c, AgencyCode__c];
            return agmList;
        //} catch (Exception e) {
        //    throw new AuraHandledException(e.getMessage());
        //}
    }

    @AuraEnabled
    @SuppressWarnings('PMD.ApexCRUDViolation')
    public static String updateRule(String ruleId, String agentCode){
        //try {
            HDT_UTL_DatabaseService.updateSObject(new AssignmentRule__c(
                Id = ruleId,
                SalesAgency__c = agentCode
            ));
            return null;
        //} catch (Exception e) {
        //    return 'ERROR: ' + e.getMessage() + ' at line ' + e.getLineNumber() + ' | ' + e.getStackTraceString();
        //}
    }
}