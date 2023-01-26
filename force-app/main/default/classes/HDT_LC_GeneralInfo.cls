/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 11/11/2020
* @description Apex controller for hdtGeneralInfo.js component
* @history Keltin Mesonjesi – 11/11/2020 – Created class
*/

public inherited sharing class HDT_LC_GeneralInfo {

    private static HDT_SRV_Sale saleSrv = new HDT_SRV_Sale();
    private static HDT_QR_AccountContactRelation accoContRelQr = new HDT_QR_AccountContactRelation();
    private static HDT_SRV_AccountContactRelation accoContRelSrv = new HDT_SRV_AccountContactRelation();
    private static HDT_QR_CampaignMember campMembQr = new HDT_QR_CampaignMember();

    
    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Update Sale
     * @param Sale__c sale
     */
    @AuraEnabled
    public static void updateSale(Sale__c sale){
        try{

            List<wrts_prcgvr__Activity__c> listActi = HDT_QR_ActivityCustom.getActivityTelesellingOutboundByUser();
            if (listActi != null && !listActi.isEmpty()) {
                sale.Ecid__c = listActi[0].Ecid__c;
            }
            
        }catch(exception e){
            system.debug('***********' + e);
        }

        if(sale.SalesContact__c != null)
        {
            List<Contact> salesCon = [SELECT Phone, MobilePhone, Email FROM Contact WHERE Id = :sale.SalesContact__c WITH SECURITY_ENFORCED];
            if(!salesCon.isEmpty() && salesCon[0].Phone == null && salesCon[0].MobilePhone == null && salesCon[0].Email == null)
            {
                throw new AuraHandledException('Il contatto selezionato non dispone di alcun tipo di recapito. Aggiornare il contatto o selezionarne uno differente');
            }
        }

        saleSrv.updateRecord(sale);
        
        //if(sale.CommissioningCampaign__c != null){
          //  List<CampaignMember> campMembList = campMembQr.getCampaignMemberByCampaingAndContact(sale.CommissioningCampaign__c, sale.SalesContact__c);
            
           // if (!campMembList.isEmpty()) {
           //     sale.Ecid__c = campMembList[0].Ecid__c;
          //  }
        //}
    }
    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get current username
     * @return String username
     */
    @AuraEnabled
    public static String getCurrentUserName(){
        String userName = UserInfo.getName();
        return userName;
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get "Ruolo Contrattuale"
     * @param String accountId
     * @param String contactId
     * @return List<AccountContactRelation>
     */
    @AuraEnabled
    public static List<AccountContactRelation> getSaleContactRole(String accountId, String contactId){

        accoContRelSrv.checkReadAccess('Roles');
        return accoContRelQr.getRecordsFilteredByAccountAndContact(accountId, contactId);
    }

    @AuraEnabled
    public static List<AgentMatrix__c> getChannelAgency(String Channel){
        System.debug('test');
        Map<String,AgentMatrix__c> distinctAgency= new Map <String,AgentMatrix__c>();
        List<AgentMatrix__c> agentList = new List<AgentMatrix__c>();
        if('Back office'.equalsIgnoreCase(Channel)){
            agentList=HDT_QR_AgentMatrix.getAllRecords();
        }else{
            agentList=HDT_QR_AgentMatrix.getRecordsByChannel(Channel);
        }

        for (AgentMatrix__c agent : agentList) {
            distinctAgency.put((String)agent.AgencyName__c,agent);
        }
        agentList = distinctAgency.values();

        return agentList;
    }

    @AuraEnabled
    public static List<AgentMatrix__c> getAgents(String AgencyName, String Channel){
        System.debug('test');
        // Id userId=UserInfo.getUserId();

        List<AgentMatrix__c> agentList = new List<AgentMatrix__c>();

        if(Channel == 'Back office') {
            agentList = HDT_QR_AgentMatrix.getRecordByAgencyName(AgencyName);
        } else {
            agentList = HDT_QR_AgentMatrix.getRecordByAgencyNameAndChannel(AgencyName, Channel);
        }

        System.debug(agentList);
          return agentList;

          
    }
    @AuraEnabled
    public static List<AgentMatrix__c> handleAutomaticAgentAssign(String Channel,String saleId){
    List<AgentMatrix__c> agentList = HDT_QR_AgentMatrix.getAgentByUserNameAndChannel(UserInfo.getUserName(),Channel);
    System.debug('username '+UserInfo.getUserName());
    System.debug('Channel '+Channel);
    System.debug('agentList '+agentList);
    if(agentList.size()==0){
        throw new AuraHandledException('Per la tua utenza e per il canale selezionato non è censito un Id Commerciale. Selezionane uno tramite il tasto Seleziona Agenzia');
    }




    AgentMatrix__c agent = agentList[0];
    saleSrv.updateRecord(new Sale__c(
        Id = saleId,
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

    return agentList;

    }

    @AuraEnabled
    public static Map<String,String> initComp(){

        Map<String,String> result = new Map<String,String>();

        List<User> user = HDT_QR_UserQueries.getRoleAndProfile(UserInfo.getUserId());
        if(!user.isEmpty() && String.isNotBlank(user[0].LoginChannel__c))
        {
            result.put('loginchannel',user[0].LoginChannel__c);
        }
        if (user[0].UserRole != null) {
            result.put('userRole', user[0].UserRole.DeveloperName);
            result.put('userProfile', user[0].Profile.Name);
        }

        return result;
    }

}