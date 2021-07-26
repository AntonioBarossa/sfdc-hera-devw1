global class HDT_SCH_OldDraftSalesSchedule implements Schedulable {

    global void execute(SchedulableContext sc) {
        HDT_BA_OldDraftSales oldDraftSales = new HDT_BA_OldDraftSales();
        Database.executeBatch(oldDraftSales);
    }
}
