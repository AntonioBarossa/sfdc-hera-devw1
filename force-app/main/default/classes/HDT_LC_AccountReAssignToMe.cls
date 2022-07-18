/*
    @Author:            Davide Viola
    LAstModifiedDate:   30/06/2022
*/
@SuppressWarnings('PMD.ApexCRUDViolation')
public with sharing class HDT_LC_AccountReAssignToMe {

    @AuraEnabled
    public static String assignAccountToUser(String accId){

        String retVal = 'OK';
        List<Account> accList = [SELECT Id, Name, OwnerId FROM Account WHERE Id =:accId];

        if(!accList.isEmpty()){

            String currentUserId = UserInfo.getUserId();
            Account myAcc = accList[0];
            myAcc.OwnerId = currentUserId;
            try {
                update myAcc;
            }
            catch (Exception ex) {
                retVal = ex.getMessage();
            }
            return retVal;
        }
        else {
            retVal = 'Errore. Assegnazione non riuscita.';
            return retVal;
        }
    }
}