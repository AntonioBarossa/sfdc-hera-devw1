public with sharing class HDT_BA_CommercialCode implements Database.Batchable<Commercial_Code_Batch_Context__c> {
    private static HDT_QR_CampaignMember campaignMemberQr = new HDT_QR_CampaignMember();

    public Integer startNumber;
    public Integer numberLength;
    public List<String> campaignIds= new List<String>() ;
    public List<String> campaignMembers= new List<String>();
    public List<Commercial_Code_Batch_Context__c> batchCSContext=new List<Commercial_Code_Batch_Context__c>();//>> 30/05/22 costanzo.lomele@webresults.it #fix for campagne performance tests
    
    //START>> 30/05/22 costanzo.lomele@webresults.it #fix for campagne performance tests
    //public HDT_BA_CommercialCode(Map<String,List<String>> allMembers) {
    public HDT_BA_CommercialCode() {
        this.numberLength = 4;
        this.startNumber = 1;
    }

    public Iterable<Commercial_Code_Batch_Context__c> start(Database.BatchableContext bc) {
        List<Commercial_Code_Batch_Context__c> context = [SELECT Id, CampaignId__c, CampaignMemberId__c 
                                                            FROM Commercial_Code_Batch_Context__c 
                                                            WHERE CommercialCodeDone__c = FALSE AND BollettaDone__c = FALSE];
        this.batchCSContext = context;
        return context;
    }

    public void execute(Database.BatchableContext bc, List<Commercial_Code_Batch_Context__c> context) {
        Map<String,List<String>> allMembers = new Map<String,List<String>>();
        for(Commercial_Code_Batch_Context__c curObj : context){
            List<String> temp = allMembers.get(curObj.CampaignId__c);
            if(temp != null) temp.add(curObj.CampaignMemberId__c);
			else temp = new List<String>{curObj.CampaignMemberId__c};
            allMembers.put(curObj.CampaignId__c, temp);
        }
        
        this.campaignIds.addAll(allMembers.keySet());
        for (List<String> members : allMembers.values()) {
            this.campaignMembers.addAll(members);
        }
        String queryStr = 'Select Id, FirstName, LastName, CampaignId,Campaign.MaxNumberEECodeUse__c,Campaign.MaxNumberGASCodeUse__c,Campaign.MaxNumberVASCodeUse__c , PromoCommercialCode__c, Campaign.CodeManagementModel__c, Campaign.PrefixCode__c, Campaign.CodeGenerationRule__c, PromoCommercialCode__r.FullCode__c FROM CampaignMember WHERE Id IN :campaignMembers AND Campaign.CodeGenerationRule__c != \'Manuale\' AND Campaign.CodeManagementModel__c IN (\'Per singolo Campaign Member\',\'Porta un amico\')';
        List<CampaignMember> scope = Database.query(queryStr);
        //get existing campaginMembers
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
        for(CampaignMember cm : scope) {
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

        for (CampaignMember cm : scope) {
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

        for(Commercial_Code_Batch_Context__c curObj : context) curObj.CommercialCodeDone__c = true;
        update context;
        System.debug('@@@@ finish executing context' + context);
    }

    public void finish(Database.BatchableContext bc){
        System.debug('@@@@ finish batch, total size: ' + this.batchCSContext.size());
        if(this.batchCSContext.size() > 0) System.scheduleBatch(new HDT_BA_CampaignBolletta(), 'HDT_BA_CampaignBolletta', 1);
    }
}