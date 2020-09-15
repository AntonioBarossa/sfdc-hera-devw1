trigger HDT_Order on Order (before insert, before update, before delete, 
	                          after insert, after update, after delete, after undelete) {

	HDT_TRH_Order handler = new HDT_TRH_Order();

	if (Trigger.isUpdate && Trigger.isBefore){
		System.debug('order trigger: do before update');
    	handler.OnBeforeUpdate();       
	} else if(Trigger.isUpdate && Trigger.isAfter){
		System.debug('order trigger: do after update');
        handler.OnAfterUpdate();       
	} else if(Trigger.isInsert && Trigger.isBefore){
		System.debug('order trigger: do before insert');
		handler.OnBeforeInsert();
	} else if(Trigger.isInsert && Trigger.isAfter){
		System.debug('order trigger: do after insert');
		handler.OnAfterInsert();
	}
}