/**
* @author Frida1995 (elfrida.kora@dunegroup.it)
* @date 18/06/2021
* @description HDT_QR_AgentMatrix
* @history Frida1995 – 18/06/2021 – Created class
*/


public inherited sharing class HDT_QR_AgentMatrix {

    public static List<AgentMatrix__c> getRecordsByChannel(String Channel){

        return [
            SELECT
            AgencyName__c,
            AgencyCode__c
            FROM AgentMatrix__c
            WHERE Channel__c = :Channel
            WITH SECURITY_ENFORCED
        ];

    }

    public static List<AgentMatrix__c> getAllRecords(){

        return [
            SELECT
            AgencyName__c,
            AgencyCode__c
            FROM AgentMatrix__c
            WITH SECURITY_ENFORCED
        ];

    }

    /**
    * @author Elfrida Kora (elfrida.kora@dunegroup.it)
    * @date 03/06/2021
    * @description Get list of records by Channel 
    * @param String Channel__c
    * @return List<AgentMatrix__c>
    */

    public static List<AgentMatrix__c> getRecordByAgencyName(String AgencyName){
        //Map<String,AgentMatrix__c> distinctAgency= new Map <String,AgentMatrix__c>();
        List<AgentMatrix__c> agents= [
            SELECT
            Name,
            Channel__c,
            LowerChannelAgency__c,
            UpperChannelAgency__c,
            AgentCode__c,
            AgencyCode__c,
            AgentLastName__c,
            CreatedById,
            CollaborationEndDate__c,
            UserIdentification__c,
            LastModifiedById,
            IsMonitoring__c,
            AgentFirstName__c,
            AgencyName__c,
            OwnerId
            FROM AgentMatrix__c WHERE AgencyName__c=:AgencyName   
            WITH SECURITY_ENFORCED
        ];

        //27/08/2021 gabriele.rota@webresults.it - Returning records without using map
        return agents;

        /*for (AgentMatrix__c agent : agents) {
            distinctAgency.put((String)agent.AgencyName__c,agent);   
        }
        System.debug('frida distinctAgency '+ distinctAgency);
        return distinctAgency.values();*/
    }

        public static List<AgentMatrix__c> getRecordByAgencyNameAndChannel(String AgencyName,String Channel){
            return [
                SELECT
                Name,
                Channel__c,
                LowerChannelAgency__c,
                UpperChannelAgency__c,
                AgentCode__c,
                AgencyCode__c,
                AgentLastName__c,
                CreatedById,
                CollaborationEndDate__c,
                UserIdentification__c,
                LastModifiedById,
                IsMonitoring__c,
                AgentFirstName__c,
                AgencyName__c,
                OwnerId
                FROM AgentMatrix__c WHERE AgencyName__c=:AgencyName AND Channel__c=:Channel      
                WITH SECURITY_ENFORCED
                ];
        
            }

        public static List<AgentMatrix__c> getAgentByUserNameAndChannel(String userName , String Channel){

            return[
                SELECT
                AgencyName__c,
                AgencyCode__c,
                AgentFirstName__c,
                AgentLastName__c,
                AgentCode__c,
                UpperChannelAgency__c,
                LowerChannelAgency__c,
                IsMonitoring__c	
                FROM AgentMatrix__c
                WHERE Channel__c=:Channel AND UserIdentification__c=:userName
                WITH SECURITY_ENFORCED
            ];

        }

        public static List<AgentMatrix__c> getAgentMatrixIsMonitoringTrue(){
            return[
                SELECT
                AgencyName__c,
                AgencyCode__c,
                UpperChannelAgency__c,
                LowerChannelAgency__c,
                IsMonitoring__c	
                FROM AgentMatrix__c
                WHERE IsMonitoring__c = true
                WITH SECURITY_ENFORCED
            ];
        }
        
}
