 /**
* @author Sabina Levonja (sabina.levonja@dunegroup.it)
* @date 04/06/21
* @description HDT_TRH_User
* @history Sabina Levonja – 04/06/21 – created class
*/
public inherited sharing class HDT_TRH_User extends HDT_TRH_TriggerHandler{

    public static HDT_QR_Contact contactQr= new HDT_QR_Contact();

    public override void afterInsert(){
        publishPartnerAccount();
    }
    
    public void publishPartnerAccount(){
        List<User> users= Trigger.new;
        List<Id> accountIds= new List<Id>();
        List<Account> accountsToUpdate= new List<Account>();
        for(User u: users){
            accountIds.add(u.AccountId);
        }
        List<AggregateResult> usConn= [SELECT AccountId, COUNT(Id) c
        FROM User
        WHERE AccountId in :accountIds AND UserType = 'PowerPartner'
        GROUP BY AccountId ];

        for(AggregateResult u: usConn){
            if(Integer.valueOf(u.get('c'))== 1){
                Account a= new Account();
                a.Id = String.valueOf(u.get('AccountId'));
                a.Published__c= true;
                accountsToUpdate.add(a);
            }
        }
        update accountsToUpdate;
    }
}
