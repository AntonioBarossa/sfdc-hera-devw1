public inherited sharing class HDT_UTL_CaseApprovalProcess {

    //@frpanico 04/10/2021
    //Refactoring: Trigger is meant to be used for one record only

    @InvocableMethod(label = 'Submit for Approval')
    public static void submitForApproval(List<Case> cases){

        Case c = cases[0]; 
        Approval.ProcessResult result;

        String sessionId = UserInfo.getOrganizationId(); //current OrdId

        HDT_GenericTable__mdt possibleApprovers = [SELECT Id, Mapping__c FROM HDT_GenericTable__mdt WHERE Object__c = :sessionId ][0]; 
        System.debug(possibleApprovers.Mapping__c);

        List<HDT_WRP_UsersForSociety> userForSalesCompany = (List<HDT_WRP_UsersForSociety>)JSON.deserializeStrict( possibleApprovers.Mapping__c, List<HDT_WRP_UsersForSociety>.class); 
        
        HDT_WRP_UsersForSociety userOfSalesCompany = searchForSaleCompany(userForSalesCompany, c.SalesCompany__c); 
        System.debug(userOfSalesCompany); 

        Id approverId;

        if ( userOfSalesCompany.existsdefault && userOfSalesCompany.defaultusers.size() > 0 ){
            if( userOfSalesCompany.defaultusers.size() == 1 ){
                approverId = [SELECT Id FROM User WHERE Username = :userOfSalesCompany.defaultusers[0] ][0].Id;
            }else{
                Integer randomInt = (Integer) Math.floor(Math.Random() * (userOfSalesCompany.defaultusers.size())); 
                String approverUsername = userOfSalesCompany.defaultusers[randomInt];
                approverId = [SELECT Id FROM User WHERE Username = :approverUsername ][0].Id;
            }
        } else {
            Group approvalGroup = [SELECT Id, (SELECT Id, UserOrGroupId FROM GroupMembers) FROM Group WHERE DeveloperName = :userOfSalesCompany.groupname][0];
            Integer randomInt = (Integer) Math.floor(Math.Random() * (approvalGroup.GroupMembers.size())); 
            approverId = approvalGroup.GroupMembers[randomInt].UserOrGroupId;
        }

        List<Id> approverIdList = new List<Id>{approverId};
        System.debug(approverIdList);

        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.SetComments('Sottomissione ad Approvazione Piano Rate');
        req.setObjectId(c.Id);
        req.setNextApproverIds(approverIdList);

        result = Approval.process(req);

        return;

    }

    public static HDT_WRP_UsersForSociety searchForSaleCompany( List<HDT_WRP_UsersForSociety> userForSociety, string societa ){

        for (HDT_WRP_UsersForSociety ufs : userForSociety ) {
           

            if( ufs.nomesocieta.equalsIgnoreCase(societa) ){
                return ufs;
            }
        }
        return new HDT_WRP_UsersForSociety();
    }

    public class HDT_WRP_UsersForSociety{
        public String nomesocieta;
        public String groupname;
        public Boolean existsdefault;
        public String[] defaultusers;
    }


}