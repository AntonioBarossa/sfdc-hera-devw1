public with sharing class HDT_BA_CommercialCode implements Database.Batchable<SObject> {
    private static HDT_QR_CampaignMember campaignMemberQr = new HDT_QR_CampaignMember();

    public List<String> campaignIds= new List<String>() ;
    public Integer startNumber;
    public Integer numberLength;
    public List<String> campaignMembers= new List<String>();
    public HDT_BA_CommercialCode(Map<String,List<String>> allMembers) {
        this.campaignIds.addAll(allMembers.keySet());
        for (List<String> members : allMembers.values()) {
            this.campaignMembers.addAll(members);
        }
        this.numberLength = 4;
        this.startNumber = 1;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        //return new campaignMembers
        String query = 'Select Id, FirstName, LastName, CampaignId,Campaign.MaxNumberEECodeUse__c,Campaign.MaxNumberGASCodeUse__c,Campaign.MaxNumberVASCodeUse__c , PromoCommercialCode__c, Campaign.CodeManagementModel__c, Campaign.PrefixCode__c, Campaign.CodeGenerationRule__c, PromoCommercialCode__r.FullCode__c FROM CampaignMember WHERE Id IN :campaignMembers AND Campaign.CodeGenerationRule__c != \'Manuale\' AND Campaign.CodeManagementModel__c IN (\'Per singolo Campaign Member\',\'Porta un amico\')';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<CampaignMember> scope) {
        //get existing campaginMembers
        Database.QueryLocator query = Database.getQueryLocator('Select Id, FirstName, LastName, CampaignId, PromoCommercialCode__c, Campaign.CodeManagementModel__c, Campaign.PrefixCode__c, Campaign.CodeGenerationRule__c, PromoCommercialCode__r.FullCode__c FROM CampaignMember WHERE CampaignId IN :campaignIds AND Campaign.CodeGenerationRule__c != \'Manuale\' AND PromoCommercialCode__c  != \'\' AND Campaign.CodeManagementModel__c IN (\'Per singolo Campaign Member\',\'Porta un amico\')');
        Database.QueryLocatorIterator existingMembers =  query.iterator();

        //get existing campaginMember number
        Database.QueryLocator queryMembers = Database.getQueryLocator('Select Count(Id) members, CampaignId FROM CampaignMember WHERE CampaignId IN :campaignIds AND Campaign.CodeGenerationRule__c != \'Manuale\' AND PromoCommercialCode__c  != \'\' AND Campaign.CodeManagementModel__c IN (\'Per singolo Campaign Member\',\'Porta un amico\')');
        Database.QueryLocatorIterator membersNumber =  queryMembers.iterator();
        Map<Id, Integer> campaignIdMemberTotal = new Map<Id, Integer>();
        while (membersNumber.hasNext()) {
            AggregateResult cm = (AggregateResult) membersNumber.next();
            campaignIdMemberTotal.put((Id)cm.get('CampaignId'), (Integer)cm.get('members'));
        }
       // System.debug('campaignIdMemberTotal - ' + campaignIdMemberTotal);

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
        for(CampaignMember cm : scope) {
            String newCode = '';
            Integer startNumber = campaignIdMemberTotal.get(cm.CampaignId);
            if (cm.Campaign.CodeGenerationRule__c == 'PrefissoProgressivo') {
                newCode = cm.Campaign.PrefixCode__c + ('0'.repeat(this.numberLength - String.valueOf(startNumber).length())) + startNumber;
            } else if (cm.Campaign.CodeGenerationRule__c == 'Prefisso + Nome + Cognome + Progressivo') {
                String name = cm.FirstName.left(3) + cm.LastName.left(3);
                newCode = cm.Campaign.PrefixCode__c + name + ('0'.repeat(this.numberLength - String.valueOf(startNumber).length())) + startNumber;
            }
            this.startNumber = this.startNumber + 1;
            campaignIdMemberTotal.put(cm.CampaignId, startNumber + 1);
           // System.debug('final code --------  ' + newCode);

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
       // System.debug('cclist --------  ' + ccList);
        for (CommercialCode__c cc : ccList) {
            codeId.put(cc.FullCode__c, cc.Id);
        }

        for (CampaignMember cm : scope) {
            CampaignMember newCm = new CampaignMember();
            String cd = memberCode.get(cm.Id);
            newCm.Id = cm.Id;
            newCm.PromoCommercialCode__c = codeId.get(cd);
            membersToUpdate.add(newCm);
        }

        if (membersToUpdate.size() > 0) {
            update membersToUpdate;
        }

      //  System.debug('membersToUpdate --------  ' + membersToUpdate);
    }

    public void finish(Database.BatchableContext bc){
        System.debug('-------- finish batch');
        HDT_BA_CampaignBolletta cbBatch = new HDT_BA_CampaignBolletta(this.campaignIds);
        ID batchId = Database.executeBatch(cbBatch, 500);
        System.debug('batchCampaignBolletta ProcessId - ' + batchId);
    }
}