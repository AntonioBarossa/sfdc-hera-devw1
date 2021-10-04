public inherited sharing class HDT_UTL_CaseApprovalProcess {

    //@frpanico 04/10/2021
    //Refactoring: Trigger is meant to be used for one record only

    @InvocableMethod(label = 'Submit for Approval')
    public static void submitForApproval(List<Case> cases){

        Case c = (Case)Trigger.new[0];
        Approval.ProcessResult result;

        List<Id> approversIds = new List<Id>();
        approversIds.add(UserInfo.getUserId());

        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.SetComments('Sottomissione ad Approvazione Piano Rate');
        req.setObjectId(c.Id);
        req.setNextApproverIds(approversIds);

        result = Approval.process(req);

        return;

    }


}   