public inherited sharing class HDT_UTL_CaseApprovalProcess {

    @InvocableMethod(label = 'Submit for Approval')
    public static void submitForApproval(List<Case> cases){

        for(Case c: cases){

            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.SetComments('Sottomissione ad Approvazione Piano Rate');
            req.setObjectId(c.Id);

            Approval.ProcessResult result = Approval.process(req);

            System.assert(result.isSuccess());

        }

        return;

    }


}