public inherited sharing class HDT_UTL_AgentMatrix {
    public static List<String> agencyCodeIsMonitoringList(){
        List<AgentMatrix__c> agentMatrixList = HDT_QR_AgentMatrix.getAgentMatrixIsMonitoringTrue();
        
        List<String> isMonitoringList = new List<String>();
        
        for (AgentMatrix__c agentMatrix : agentMatrixList) {
            isMonitoringList.add(agentMatrix.AgencyCode__c);
        }

        return isMonitoringList;
    }
}
