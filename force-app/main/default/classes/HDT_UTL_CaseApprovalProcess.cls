public inherited sharing class HDT_UTL_CaseApprovalProcess {

    //@frpanico 04/10/2021
    //Refactoring: Trigger is meant to be used for one record only

    @InvocableMethod(label = 'Submit for Approval')
    public static void submitForApproval(List<Case> cases){

        Case c = cases[0];
        Approval.ProcessResult result;

        List<Group> approvalGroup = [SELECT Id, (SELECT Id, UserOrGroupId FROM GroupMembers) FROM Group WHERE DeveloperName = 'HDT_PG_ApprovatoriPianoRata'];


        List<Id> approversIds = new List<Id>();
        for(GroupMember userMember : approvalGroup[0].GroupMembers)
        {
            if(!approversIds.contains(userMember.UserOrGroupId))
            {
                approversIds.add(userMember.UserOrGroupId);
            }
        }

        System.debug(approversIds.size());
        List<Id> approverIdList = new List<Id>{approversIds[0]};

        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.SetComments('Sottomissione ad Approvazione Piano Rate');
        req.setObjectId(c.Id);
        req.setNextApproverIds(approverIdList);

        result = Approval.process(req);

        return;

    }


}