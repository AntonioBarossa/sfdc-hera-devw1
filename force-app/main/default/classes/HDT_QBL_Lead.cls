public with sharing class HDT_QBL_Lead  implements Queueable{
    Map<id, id> leadOwner;
    public HDT_QBL_Lead(Map<id, id> leadOwner ) {
        this.leadOwner=leadOwner;
     
    }
    public void execute(QueueableContext context) {
      List<Lead> myLeads = new List<Lead>();
        for (id tempId : leadOwner.keySet()) {
            Lead tmp=new Lead(Id=tempId,OwnerId=leadOwner.get(tempId));
            myLeads.add(tmp);
        }
        if (myLeads!=null && !myLeads.isEmpty()) {
            update myLeads;
        }
     
        
    }
}
