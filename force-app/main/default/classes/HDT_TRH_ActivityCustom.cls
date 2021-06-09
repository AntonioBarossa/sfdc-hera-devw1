public inherited sharing class  HDT_TRH_ActivityCustom extends HDT_TRH_TriggerHandler {
	
    public override void beforeInsert(){}

 	public override void beforeDelete(){}
 	public override void afterDelete(){}
  	public override void afterUndelete(){}
    
    public override void beforeUpdate(){}

    public override void afterUpdate(){

        HDT_UTL_ActivityCustomProcess.changeAssignRelatedRecord(trigger.new,trigger.old);

        // @Picchiri 08.06.21 Credit Check Annullamento Ordine
        HDT_UTL_ActivityCustomProcess.annullamentoActivityCustom(trigger.new,trigger.old);

    }

    public override void afterInsert(){}   

}