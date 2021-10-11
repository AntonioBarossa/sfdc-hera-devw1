public with sharing class HDT_SCH_PublicValidation implements Schedulable {
    public void execute(SchedulableContext ctx){
        HDT_BA_PublicValidation batch = new HDT_BA_PublicValidation();
        Database.executebatch(batch, 2000);
    }
}
