public with sharing class HDT_BA_CommercialCode implements Database.Batchable<CampaignMember> {
    private static HDT_QR_CampaignMember campaignMemberQr = new HDT_QR_CampaignMember();

    public Integer startNumber;
    public Integer numberLength;
    
    public HDT_BA_CommercialCode() {
        this.numberLength = 4;
        this.startNumber = 1;
    }

    public Iterable<CampaignMember> start(Database.BatchableContext bc) {
        System.debug('@@@@ HDT_BA_CommercialCode start');
        List<CampaignMember> context = [
            SELECT Id, FirstName, LastName, CampaignId,Campaign.MaxNumberEECodeUse__c,Campaign.MaxNumberGASCodeUse__c,Campaign.MaxNumberVASCodeUse__c , PromoCommercialCode__c, Campaign.CodeManagementModel__c, Campaign.PrefixCode__c, Campaign.CodeGenerationRule__c, PromoCommercialCode__r.FullCode__c 
            FROM CampaignMember 
            WHERE Campaign.CodeGenerationRule__c != 'Manuale'
            AND Campaign.CodeManagementModel__c IN ('Per singolo Campaign Member','Porta un amico')
            AND (PromoCommercialCode__c = null OR PromoCommercialCode__c = '')];
        System.debug('@@@@ found '+context.size()+' CampaignMembers to update');
        return context;
    }

    public void execute(Database.BatchableContext bc, List<CampaignMember> context) {
        System.debug('@@@@ HDT_BA_CommercialCode start');
        System.debug('@@@@ working on '+context.size()+' CampaignMembers');
        List<String> campaignIds = new List<String>();
        for(CampaignMember curCm : context){
            if(!campaignIds.contains(curCm.CampaignId)) campaignIds.add(curCm.CampaignId);
        }
        Database.QueryLocator query = Database.getQueryLocator('Select Id, FirstName, LastName, CampaignId, PromoCommercialCode__c, Campaign.CodeManagementModel__c, Campaign.PrefixCode__c, Campaign.CodeGenerationRule__c, PromoCommercialCode__r.FullCode__c FROM CampaignMember WHERE CampaignId IN :campaignIds AND Campaign.CodeGenerationRule__c != \'Manuale\' AND PromoCommercialCode__c  != \'\' AND Campaign.CodeManagementModel__c IN (\'Per singolo Campaign Member\',\'Porta un amico\')');
        Database.QueryLocatorIterator existingMembers =  query.iterator();

        //get existing campaginMember number
        List<AggregateResult> membersNumber = [Select Count(Id) members, CampaignId FROM CampaignMember WHERE CampaignId IN :campaignIds AND Campaign.CodeGenerationRule__c != 'Manuale' AND PromoCommercialCode__c  != '' AND Campaign.CodeManagementModel__c IN ('Per singolo Campaign Member','Porta un amico') GROUP BY CampaignId];
        Map<Id, Integer> campaignIdMemberTotal = new Map<Id, Integer>();
        for (AggregateResult cm : membersNumber) {
            campaignIdMemberTotal.put((Id)cm.get('CampaignId'), (Integer)cm.get('members'));
        }

        set<Integer> codeList = new set<Integer>();
        while (existingMembers.hasNext()){
            CampaignMember cm = (CampaignMember)existingMembers.next();
            String code = cm.PromoCommercialCode__r.FullCode__c;
           // Integer maxNumber = 0;
            if (cm.Campaign.CodeGenerationRule__c == 'PrefissoProgressivo') {
                code = code.removeStart(cm.Campaign.PrefixCode__c);
            } else if (cm.Campaign.CodeGenerationRule__c == 'Prefisso + Nome + Cognome + Progressivo') {
                String name = cm.FirstName.left(3) + cm.LastName.left(3);
                code = code.removeStart(cm.Campaign.PrefixCode__c + name);
            }
            this.numberLength = code.length();
            codeList.add(Integer.valueOf(code));
        }
        
        List<CampaignMember> membersToUpdate = new List<CampaignMember>();
        List<CommercialCode__c> ccList = new List<CommercialCode__c>();
        Map<String,String> memberCode = new Map<String,String>();
        Map<String,String> codeId = new Map<String,String>();
        for(CampaignMember cm : context) {
            String newCode = '';
            Integer startNumber = campaignIdMemberTotal.get(cm.CampaignId) != null ? campaignIdMemberTotal.get(cm.CampaignId) : 0;
            if (cm.Campaign.CodeGenerationRule__c == 'PrefissoProgressivo') {
                newCode = cm.Campaign.PrefixCode__c + ('0'.repeat(this.numberLength - String.valueOf(startNumber).length())) + startNumber;
            } else if (cm.Campaign.CodeGenerationRule__c == 'Prefisso + Nome + Cognome + Progressivo') {
                String name = cm.FirstName.left(3) + cm.LastName.left(3);
                newCode = cm.Campaign.PrefixCode__c + name + ('0'.repeat(this.numberLength - String.valueOf(startNumber).length())) + startNumber;
            }
            this.startNumber = this.startNumber + 1;
            campaignIdMemberTotal.put(cm.CampaignId, startNumber + 1);

            //new commercial code
            CommercialCode__c cc = new CommercialCode__c(
                Name = newCode,
                Campaign__c = cm.CampaignId,
                FullCode__c = newCode,
                MaximalUsesEE__c = cm.Campaign.MaxNumberEECodeUse__c   ,
                MaximalUsesGAS__c = cm.Campaign.MaxNumberGASCodeUse__c   ,
                MaximalUsesVAS__c = cm.Campaign.MaxNumberVASCodeUse__c  ,
                AvailabilityUsesGAS__c = 0  ,
                AvailabilityUsesEE__c = 0   ,
                AvailabilityUsesVAS__c = 0
            );
            ccList.add(cc);
            memberCode.put(cm.Id, newCode);
        }
        insert ccList; 
        for (CommercialCode__c cc : ccList) {
            codeId.put(cc.FullCode__c, cc.Id);
        }

        for (CampaignMember cm : context) {
            CampaignMember newCm = new CampaignMember();
            String cd = memberCode.get(cm.Id);
            newCm.Id = cm.Id;
            newCm.PromoCommercialCode__c = codeId.get(cd);
            membersToUpdate.add(newCm);
        }

        if (membersToUpdate.size() > 0) {
            System.debug('@@@@ updating '+membersToUpdate.size()+' CampaignMembers');
            update membersToUpdate;
        }
    }

    public void finish(Database.BatchableContext bc){
        System.debug('@@@@ finish batch, total size: ');
        System.scheduleBatch(new HDT_BA_CampaignBolletta(), 'HDT_BA_CampaignBolletta', 1, 100);
    }
}