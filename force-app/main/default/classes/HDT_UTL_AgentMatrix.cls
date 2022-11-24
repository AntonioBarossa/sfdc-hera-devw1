/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 17/08/2021
* @description Class HDT_UTL_AgentMatrix
* @history Keltin Mesonjesi – 17/08/2021 – Created class
*/
public inherited sharing class HDT_UTL_AgentMatrix {
    public static List<String> agencyCodeIsMonitoringList(){
        List<AgentMatrix__c> agentMatrixList = HDT_QR_AgentMatrix.getAgentMatrixIsMonitoringTrue();
        
        List<String> isMonitoringList = new List<String>();
        
        for (AgentMatrix__c agentMatrix : agentMatrixList) {
            isMonitoringList.add(agentMatrix.AgencyCode__c);
        }

        return isMonitoringList;
    }
    /**@frpanico 2022-07-22
     * Il metodo interroga la matrice agenti
     * ritorna una lista con tutte gli agenti a monitoraggio attivp
     */
    public static List<String> agentCodeIsMonitoringList(){
        List<AgentMatrix__c> agentMatrixList = HDT_QR_AgentMatrix.getAgentMatrixIsMonitoringTrue();
        
        List<String> isMonitoringList = new List<String>();
        
        for (AgentMatrix__c agentMatrix : agentMatrixList) {
            isMonitoringList.add(agentMatrix.AgentCode__c);
        }

        return isMonitoringList;
    }
}
