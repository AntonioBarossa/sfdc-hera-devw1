public inherited sharing class HDT_UTL_CaseApprovalProcess {

    @InvocableMethod(label = 'Submit for Approval')
    public static void submitForApproval(List<Case> cases){

        for(Case c: cases){
            List<Id> approversIds = new List<Id>();
            approversIds.add(UserInfo.getUserId());

            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.SetComments('Sottomissione ad Approvazione Piano Rate');
            req.setObjectId(c.Id);
            req.setNextApproverIds(approversIds);

            Approval.ProcessResult result = Approval.process(req);

            //System.assert(result.isSuccess());

        }

        return;

    }


}   