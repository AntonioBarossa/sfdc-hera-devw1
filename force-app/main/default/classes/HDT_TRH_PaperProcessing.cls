public class HDT_TRH_PaperProcessing extends HDT_TRH_TriggerHandler {
    public override void beforeInsert(){
        HDT_UTL_PaperProcessing.generateName(trigger.new);
    }
    
    public override void afterInsert(){
        List<PaperProcessing__c> listPaper = trigger.new;
        for(PaperProcessing__c p : listPaper){
            HDT_BA_PaperCampaignTargeting ba = new HDT_BA_PaperCampaignTargeting(p.id,p.campaign__c);
            ba.paperTriggerValue = p.TriggerCustomerReport__c;
            Database.executeBatch(ba);
        }

        //HDT_UTL_PaperProcessing.exportFile(trigger.new);
    }

    public override void beforeUpdate(){  
        List<PaperProcessing__c> triggerNew = trigger.new;
        Map<String,PaperProcessing__c> paperMap = new Map<String,PaperProcessing__c>();
        List<PaperProcessing__c> paperList = HDT_UTL_PaperProcessing.exportFile2(trigger.new,trigger.old);
        for (PaperProcessing__c paperItem : paperList) {
            paperMap.put(paperItem.Id, paperItem);
        }

        for (PaperProcessing__c newPaper : triggerNew) {
            if(paperMap.get(newPaper.Id) != null) {
                PaperProcessing__c pp = paperMap.get(newPaper.Id);
                newPaper.TriggerCustomerReport__c = pp.TriggerCustomerReport__c;
                newPaper.status__c = pp.status__c;
            } 
        }
    }
    public override void afterUpdate(){  
        HDT_UTL_PaperProcessing.createCommunication(trigger.new,trigger.old);
    }
}