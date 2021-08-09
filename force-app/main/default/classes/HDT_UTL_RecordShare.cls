public with sharing class HDT_UTL_RecordShare {

    public static AccountShare accountShareEditCreate(String recordId,String UserId){
        AccountShare accsh = new AccountShare();
        accsh.AccountId = recordId;
        accsh.ContactAccessLevel = 'Edit';
        accsh.OpportunityAccessLevel = 'Edit';
        accsh.UserOrGroupId = UserId;
        accsh.AccountAccessLevel = 'Edit';
        accsh.RowCause = 'Manual';
        //insert accsh;
        //removed DML
        return accsh;
    }

    //** [START MOD 2021-08-09] @Author:Luca Belometti WR (luca.belometti@webresults.it) @Description: Commented unused Method
    /*
    public static void accountShareEditCreate(Map<String,String> listRecordIdOwner){
        List<AccountShare> lAccSh = new List<AccountShare>();
        for(String key : listRecordIdOwner.keyset()){
                AccountShare accsh = new AccountShare();
                accsh.AccountId = key;
                accsh.UserOrGroupId = listRecordIdOwner.get(key);
                //** [START MOD 2021-08-06] @Author:Luca Belometti @Description: 
                accsh.OpportunityAccessLevel = 'Edit';
                accsh.ContactAccessLevel = 'Edit';
                //** [END MOD 2021-08-06] @Author:Luca Belometti @Description:
                accsh.AccountAccessLevel = 'Edit';
                accsh.RowCause = 'Manual';
                lAccSh.add(accsh);
            }
        HDT_SRV_RecordShare.createRecord(lAccSh);
    }
    */
    //** [END MOD 2021-08-09] @Author:Luca Belometti WR (luca.belometti@webresults.it) @Description: Commented unused Method
}
