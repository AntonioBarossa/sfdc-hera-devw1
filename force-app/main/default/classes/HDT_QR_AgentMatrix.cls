/**
* @author Frida1995 (elfrida.kora@dunegroup.it)
* @date 18/06/2021
* @description HDT_QR_AgentMatrix
* @history Frida1995 – 18/06/2021 – Created class
*/
public inherited sharing class HDT_QR_AgentMatrix {

    /**
    * @author Frida1995 (elfrida.kora@dunegroup.it)
    * @description Get records by channel
    * @param channel
    * @return List<AgentMatrix__c>
    */
    public static List<AgentMatrix__c> getRecordsByChannel(String channel){

        return [
            SELECT
            AgencyName__c,
            AgencyCode__c
            FROM AgentMatrix__c
            WHERE Channel__c = :channel
            AND (CollaborationEndDate__c > TODAY OR CollaborationEndDate__c = NULL)
            WITH SECURITY_ENFORCED
        ];

    }

    /**
    * @author Frida1995 (elfrida.kora@dunegroup.it)
    * @description Get all records
    * @return List<AgentMatrix__c>
    */
    public static List<AgentMatrix__c> getAllRecords(){

        return [
            SELECT
            AgencyName__c,
            AgencyCode__c
            FROM AgentMatrix__c
            WHERE (CollaborationEndDate__c > TODAY OR CollaborationEndDate__c = NULL)
            WITH SECURITY_ENFORCED
        ];

    }

    /**
    * @author Elfrida Kora (elfrida.kora@dunegroup.it)
    * @date 03/06/2021
    * @description Get list of records by agency name
    * @param agencyName
    * @return List<AgentMatrix__c>
    */
    public static List<AgentMatrix__c> getRecordByAgencyName(String agencyName){
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
            OwnerId,
            AreaManager__c
            FROM AgentMatrix__c WHERE AgencyName__c=:agencyName AND (CollaborationEndDate__c > TODAY OR CollaborationEndDate__c = NULL)
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

    /**
    * @author Elfrida Kora (elfrida.kora@dunegroup.it)
    * @date 03/06/2021
    * @description Get list of records by agency name and channel
    * @param agencyName
    * @param channel
    * @return List<AgentMatrix__c>
    */
    public static List<AgentMatrix__c> getRecordByAgencyNameAndChannel(String agencyName,String channel){
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
            OwnerId,
            AreaManager__c
            FROM AgentMatrix__c WHERE AgencyName__c=:agencyName AND Channel__c=:channel AND (CollaborationEndDate__c > TODAY OR CollaborationEndDate__c = NULL)
            WITH SECURITY_ENFORCED
            ];
    
    }

    /**
    * @author Elfrida Kora (elfrida.kora@dunegroup.it)
    * @date 03/06/2021
    * @description Get list of records by user name and channel
    * @param userName
    * @param channel
    * @return List<AgentMatrix__c>
    */
    public static List<AgentMatrix__c> getAgentByUserNameAndChannel(String userName , String channel){

        return[
            SELECT
            AgencyName__c,
            AgencyCode__c,
            AgentFirstName__c,
            AgentLastName__c,
            AgentCode__c,
            UpperChannelAgency__c,
            LowerChannelAgency__c,
            IsMonitoring__c,
            AreaManager__c
            FROM AgentMatrix__c
            WHERE Channel__c=:channel 
            AND UserIdentification__c=:userName
            AND (CollaborationEndDate__c > TODAY OR CollaborationEndDate__c = NULL)
            WITH SECURITY_ENFORCED
        ];

    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Get list of records with monitoring set to true
    * @return List<AgentMatrix__c>
    */
    public static List<AgentMatrix__c> getAgentMatrixIsMonitoringTrue(){
        return[
            SELECT
            AgencyName__c,
            AgencyCode__c,
            UpperChannelAgency__c,
            LowerChannelAgency__c,
            IsMonitoring__c,
            AgentCode__c
            FROM AgentMatrix__c
            WHERE IsMonitoring__c = true
            WITH SECURITY_ENFORCED
        ];
    }

}
