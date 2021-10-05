public inherited sharing class HDT_LC_SoldBy {
    private static HDT_QR_Lead leadQr = new HDT_QR_Lead();

    @AuraEnabled
    public static Lead getLeadInfo(String id){
        return leadQr.getRecordById(id);
    }

    @AuraEnabled
    public static void handleAutomaticAgentAssign(String channel,String leadId){

        List<AgentMatrix__c> agentList = HDT_QR_AgentMatrix.getAgentByUserNameAndChannel(UserInfo.getUserName(), channel);
    
        if(agentList.size()==0){
            throw new AuraHandledException('Per la tua utenza e per il canale selezionato non è censito un Id Commerciale. Contattare il proprio responsabile');
        }

        AgentMatrix__c agent = agentList[0];

        HDT_SRV_Lead.updateRecord(new Lead(
            Id = leadId,
            Channel__c = channel,
            Agency__c = agent.AgencyName__c,
            AgencyCode__c = agent.AgencyCode__c,
            VendorLastName__c = agent.AgentLastName__c,
            VendorFirstName__c = agent.AgentFirstName__c,
            CommercialId__c = agent.AgentCode__c,
            UpperChannelAgency__c = agent.UpperChannelAgency__c,
            LowerChannelAgency__c = agent.LowerChannelAgency__c,
            IsMonitoring__c = agent.IsMonitoring__c,
            AreaManager__c = agent.AreaManager__c
        ));

    }

    @AuraEnabled
    public static void updateLead(Lead lead){
        HDT_SRV_Lead.updateRecord(lead);
    }

    @AuraEnabled
    public static List<AgentMatrix__c> getChannelAgency(String channel){

        Map<String,AgentMatrix__c> distinctAgency = new Map <String,AgentMatrix__c>();

        List<AgentMatrix__c> agentList = new List<AgentMatrix__c>();

        if('Back office'.equalsIgnoreCase(channel)){
            agentList = HDT_QR_AgentMatrix.getAllRecords();
        }else{
            agentList = HDT_QR_AgentMatrix.getRecordsByChannel(channel);
        }

        for (AgentMatrix__c agent : agentList) {
            distinctAgency.put((String)agent.AgencyName__c, agent);
        }

        agentList = distinctAgency.values();

        return agentList;
    }

    @AuraEnabled
    public static List<AgentMatrix__c> getAgents(String agencyName, String channel){
        
        List<AgentMatrix__c> agentList = new List<AgentMatrix__c>();

        if(Channel == 'Back office') {
            agentList = HDT_QR_AgentMatrix.getRecordByAgencyName(agencyName);
        } else {
            agentList = HDT_QR_AgentMatrix.getRecordByAgencyNameAndChannel(agencyName, channel);
        }

        return agentList;
    }
}
