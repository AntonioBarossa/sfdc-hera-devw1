/**
* @author Fatjola Memishaj (fatjola.memishaj@dunegroup.it)
* @date 18/03/2021
* @description HDT_TRH_TriggerHandler
* @history Fatjola Memishaj – 18/03/2021 – Created class
*/
public class HDT_TRH_Campaign extends HDT_TRH_TriggerHandler{
    
    // public override void afterInsert(){  
        
        //     HDT_UTL_CampaignMember.createCampaignMemberStatus(trigger.new);  
        // }
        
        public override void beforeInsert(){
            HDT_UTL_CompanyOwner.feedCompanyOwner(trigger.new);
        }
        
        public override void beforeUpdate() {
            HDT_UTL_CampaignMember.activateCampaign(trigger.new, trigger.old);
            HDT_UTL_CampaignMember.createCampaignMemberStatus(trigger.new, trigger.old);  
            HDT_UTL_CampaignMember.campaignSuspension(trigger.new, trigger.old);
            createCommercialCode((map<Id,Campaign>)Trigger.newMap,(map<Id,Campaign>)Trigger.oldMap);
            deactivateCampaign(Trigger.new, (Map<Id,Campaign>)Trigger.oldMap);
        }

        public static void deactivateCampaign(List<Campaign> newCampaigns, Map<Id,Campaign> oldCampaignsMap) {
            List<Id> deactivateCampaignsId = new List<Id>();
            for (Campaign cmp : newCampaigns) {
                if ((oldCampaignsMap.get(cmp.Id).Status == 'In Corso' || oldCampaignsMap.get(cmp.Id).Status == 'Pianificata') && (cmp.Status == 'Bloccata' || cmp.Status == 'Cancellata')) {
                    deactivateCampaignsId.add(cmp.Id);
                    cmp.IsActive = false;                    
                }
            }

            List<Id> campaignIdsToBatch = new List<Id>();

            List<AggregateResult> campaignsWithReitekStatusSend = [SELECT COUNT(id) members, CampaignId from CampaignMember WHERE isToSendStatusReitek__c = true AND CampaignId IN :deactivateCampaignsId GROUP BY CampaignId ];

            for (AggregateResult res : campaignsWithReitekStatusSend) {
                if ((Decimal) res.get('members') > 0) {
                    campaignIdsToBatch.add((Id)res.get('CampaignId'));
                } 
            }

            if (campaignIdsToBatch.size() > 0) {
                HDT_BA_DeactivateCampaign cbBatch = new HDT_BA_DeactivateCampaign(campaignIdsToBatch);
                ID batchId = Database.executeBatch(cbBatch, 50);
                System.debug('batchId - '+batchId);
            }
        }
        
        /**
        * @description : Crea CommercialCode per Modello Gestione Codici "Convenzione"
        * @param mapNewItem 
        * @param mapOldItem 
        **/

        public static void createCommercialCode(map<Id,Campaign> mapNewItem,map<Id,Campaign> mapOldItem){
            // Campaign cmp = campaignQr.getCommercialCodeCampaign(campaignId);
            HDT_SRV_CommercialCode commercialCodeSrv = new HDT_SRV_CommercialCode();
            HDT_QR_CommercialCode qrCommercialCode =new HDT_QR_CommercialCode();
            List<AggregateResult> listCommercialCodeNumber =qrCommercialCode.getCommercialCodeNumber(mapNewItem.keySet());
            Map<String,Integer> mapKeyToNumber = new Map<String,Integer>();
            for(AggregateResult aggTemp:listCommercialCodeNumber){
                mapKeyToNumber.put(string.valueOf(aggTemp.get('Campaign__c')),Integer.valueOf(aggtemp.get('conteggio')));
            }
            
            
            List<CommercialCode__c> listCommercialCode = new List<CommercialCode__c>();
            for (Campaign tempCamp : mapNewItem.values()) {
                if (String.isNotBlank((String.valueOf(tempCamp.CodeConventionQuantity__c)))&&tempCamp.CodeConventionQuantity__c!=0&& 'Convenzione'.equalsIgnoreCase( tempCamp.CodeManagementModel__c) && 'Pianificata'.equalsIgnoreCase(mapOldItem.get(tempCamp.id).Status)
                && 'PrefissoProgressivo'.equalsIgnoreCase( tempCamp.CodeGenerationRule__c)
                && 'In Corso'.equalsIgnoreCase(mapNewItem.get(tempCamp.id).Status)) {
                    for (Integer i = 0; i < tempCamp.CodeConventionQuantity__c; i++) { 
                        CommercialCode__c comCode = new CommercialCode__c ();
                        comCode.Campaign__c         = tempCamp.id;
                        Integer num=mapKeyToNumber.get(tempCamp.id)!=null?mapKeyToNumber.get(tempCamp.id)+1:1;
                        comCode.FullCode__c         = tempCamp.PrefixCode__c+num;
                        comCode.Name                = tempCamp.PrefixCode__c+num;
                        comCode.MaximalUsesEE__c    = tempCamp.MaxNumberEECodeUse__c;
                        comCode.MaximalUsesGAS__c   = tempCamp.MaxNumberGASCodeUse__c;
                        comCode.MaximalUsesVAS__c   = tempCamp.MaxNumberVASCodeUse__c;
                        comCode.ActualUsesEE__c     = 0;
                        comCode.ActualUsesGAS__c    = 0;
                        comCode.ActualUsesVAS__c    = 0;
                        comCode.RecoveryUsesEE__c   = 0;
                        comCode.RecoveryUsesGAS__c  = 0;
                        comCode.RecoveryUsesVAS__c  = 0;
                        listCommercialCode.add(comCode);
                        mapKeyToNumber.put(tempCamp.id,num); 
                    }
                    tempCamp.CodeConventionQuantity__c=0;
                }
            }
            if (!listCommercialCode.isEmpty()) {
                List<CommercialCode__c> res = commercialCodeSrv.createRecords(listCommercialCode);
            }
        }
    }