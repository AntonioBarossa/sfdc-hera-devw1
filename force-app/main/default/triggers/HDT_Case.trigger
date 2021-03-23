trigger HDT_Case on Case(before insert, before update, before delete, 
	                          after insert, after update, after delete, after undelete) {

	new HDT_TRH_Case().run();
/*
	if (Trigger.isUpdate && Trigger.isBefore){
		System.debug('case trigger: do before update');
    	handler.OnBeforeUpdate();       
	} else if(Trigger.isUpdate && Trigger.isAfter){
		System.debug('case trigger: do after update');
        handler.OnAfterUpdate();       
	} else if(Trigger.isInsert && Trigger.isBefore){
		System.debug('case trigger: do before insert');
		handler.OnBeforeInsert();
	} else if(Trigger.isInsert && Trigger.isAfter){
		System.debug('case trigger: do after insert');
		handler.OnAfterInsert();
	}*/
}