/**
 * Created by goudiaby on 27/05/2019.
 */

public with sharing class HDT_QR_UserQueriesOriginal {
    public static HDT_QR_UserQueriesOriginal getInstance() {
        return new HDT_QR_UserQueriesOriginal();
    }
    // To Check
    /**
     * Returns the context division's company Id
     * @param userId
     *
     * @return User record
     */
   /* public User getCompanyDivisionId(String userId) {
        List<User> currentUsers = [
                SELECT Id//,CompanyDivisionId__c,CompanyDivisionEnforced__c
                FROM User
                WHERE Id = :userId AND IsActive = TRUE
                LIMIT 1
        ];
        return currentUsers.isEmpty() ? null : currentUsers.get(0);
    }*/
}
