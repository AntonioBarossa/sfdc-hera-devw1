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
        HDT_UTL_PaperProcessing.exportFile(trigger.new,trigger.old);
    }
    public override void afterUpdate(){  
        HDT_UTL_PaperProcessing.createCommunication(trigger.new,trigger.old);
    }
}