trigger HDT_Contract on Contract (before insert, before update, before delete, after insert, after update, after delete ) {

	new HDT_TRH_Contract().run();
}