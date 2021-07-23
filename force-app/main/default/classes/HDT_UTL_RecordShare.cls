public with sharing class HDT_UTL_RecordShare {

    public static AccountShare accountShareEditCreate(String recordId,String UserId){
        AccountShare accsh = new AccountShare();
        accsh.AccountId = recordId;
        accsh.ContactAccessLevel = 'Edit';
        accsh.OpportunityAccessLevel = 'Edit';
        accsh.UserOrGroupId = UserId;
        accsh.AccountAccessLevel = 'Edit';
        accsh.RowCause = 'Manual';
        return accsh;
    }
    public static void accountShareEditCreate(Map<String,String> listRecordIdOwner){
        List<AccountShare> lAccSh = new List<AccountShare>();
        for(String key : listRecordIdOwner.keyset()){
                AccountShare accsh = new AccountShare();
                accsh.AccountId = key;
                accsh.UserOrGroupId = listRecordIdOwner.get(key);
                accsh.AccountAccessLevel = 'Edit';
                accsh.RowCause = 'Manual';
                lAccSh.add(accsh);
            }
        HDT_SRV_RecordShare.createRecord(lAccSh);
    }
}
