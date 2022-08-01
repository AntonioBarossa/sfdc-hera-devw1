public with sharing class HDT_SCH_InvioNumerazioni implements Schedulable {

    public void execute(SchedulableContext sc) {
        HDT_BA_InvioNumerazioni invioNumerazioni = new HDT_BA_InvioNumerazioni();
        Database.executeBatch(invioNumerazioni, 50);
    }
}
