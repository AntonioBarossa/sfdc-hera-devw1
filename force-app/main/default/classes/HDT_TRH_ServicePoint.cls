public with sharing class HDT_TRH_ServicePoint extends HDT_TRH_TriggerHandler{
    public override void beforeUpdate(){
        HDT_UTL_ServicePoint.blockblankonfield(trigger.old,trigger.new);
    }
}
