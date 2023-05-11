@SuppressWarnings('PMD.ApexCRUDViolation')
public  inherited sharing class HDT_QR_UserQueriesWithoutSharing {
    public static List<User> getRoleAndProfile(String userId) {

        return [SELECT LoginChannel__c, Profile.Name, UserRole.Name, UserRole.DeveloperName, IsPortalEnabled FROM User WHERE Id = :userId LIMIT 1];
    }
}