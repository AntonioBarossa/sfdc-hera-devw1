public inherited sharing class HDT_TRH_EmailMessage extends HDT_TRH_TriggerHandler{
    public override void beforeDelete(){}
    public override void afterDelete(){}
    public override void afterUndelete(){}

    public override void afterInsert(){

        // Il controllo sul mittente va fatto in after insert, poichè in before insert il mittente sull'action del Case è ancora null.
        HDT_SRV_EmailMessage.checkEmailSender((List<EmailMessage>) Trigger.new);

        HDT_SRV_EmailMessage.checkIncomingEmails((List<EmailMessage>) Trigger.new);
    }
}
