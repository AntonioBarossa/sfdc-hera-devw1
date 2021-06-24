public class HDT_TRH_PaperProcessing extends HDT_TRH_TriggerHandler {
    public override void afterInsert(){
        //HDT_UTL_PaperProcessing.exportFile(trigger.new);
    }

    public override void beforeUpdate(){  
        HDT_UTL_PaperProcessing.exportFile(trigger.new);
    }
}