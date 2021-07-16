public inherited sharing class HDT_SCH_QueueAssignmentScheduler implements Schedulable {

    public List<Account> accounts= new List<Account>();

    public HDT_SCH_QueueAssignmentScheduler(List<Account> accts){
        this.accounts= accts;
    }
    public void execute(SchedulableContext ctx){
        HDT_BA_QueueAssignment batch = new HDT_BA_QueueAssignment(this.accounts);
        Database.executebatch(batch, 200);
    }

}
