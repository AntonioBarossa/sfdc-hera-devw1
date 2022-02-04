public with sharing class HDT_LC_AgentMatrixSearchToolController {
    @AuraEnabled
    public static AgentMatrix__c getCurrentAgent(String ruleId){
        try {
            AssignmentRule__c rule = [SELECT Id, SalesAgency__c FROM AssignmentRule__c WHERE Id =: ruleId WITH SECURITY_ENFORCED];
            if(String.isNotBlank(rule.SalesAgency__c)) {
                List<AgentMatrix__c> matrix = [SELECT Id, AgentFirstName__c, AgentLastName__c, AgentCode__c, AgencyName__c, AgencyCode__c FROM AgentMatrix__c WHERE AgentCode__c =: rule.SalesAgency__c WITH SECURITY_ENFORCED LIMIT 1];
                if(matrix.size() > 0) {
                    return matrix[0];
                } else {
                    return new AgentMatrix__c(
                        AgentFirstName__c = 'NON CENSITO',
                        AgentLastName__c = 'NON CENSITO',
                        AgentCode__c = rule.SalesAgency__c,
                        AgencyName__c = 'NON CENSITO',
                        AgencyCode__c = 'NON CENSITO'
                    );
                }
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<AgentMatrix__c> getAgents(String queryString){
        queryString = '%' + queryString +'%';
        try {
            return [SELECT Id, AgentFirstName__c, AgentLastName__c, AgentCode__c, AgencyName__c, AgencyCode__c FROM AgentMatrix__c WHERE AgencyName__c LIKE: queryString OR AgentLastName__c =: queryString WITH SECURITY_ENFORCED];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String updateRule(String ruleId, String agentCode){
        try {
            update new AssignmentRule__c(
                Id = ruleId,
                SalesAgency__c = agentCode
            );
            return null;
        } catch (Exception e) {
            return 'ERROR: ' + e.getMessage() + ' at line ' + e.getLineNumber() + ' | ' + e.getStackTraceString();
        }
    }
}