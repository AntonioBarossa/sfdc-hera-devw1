public inherited sharing class HDT_TRH_EmailMessage extends HDT_TRH_TriggerHandler{
    public override void beforeInsert(){}
    public override void beforeDelete(){}
    public override void afterDelete(){}
    public override void afterUndelete(){}

    public override void afterInsert(){   
        HDT_SRV_EmailMessage.checkIncomingEmails((List<EmailMessage>) Trigger.new);
    }
}
