public with sharing class HDT_QBL_CreditCheckCall implements Queueable, Database.AllowsCallouts{
    List<Id> activityIdList;

    public HDT_QBL_CreditCheckCall(List<Id> activityIdList) {
        this.activityIdList = activityIdList;
    }

    public void execute(QueueableContext context) {
        HDT_UTL_ActivityCustomProcess.recheckCreditCheck(activityIdList);
    }
}
