@SuppressWarnings('PMD.ApexCRUDViolation')
public inherited sharing class HDT_QR_UserQueries {
    
    public static List<User> getRoleAndProfile(String userId) {
        return HDT_QR_UserQueriesWithoutSharing.getRoleAndProfile(userId);
    }

    public static User getCurrentUser(String userId) {

        List<User> users = [SELECT Id, LoginChannel__c, CreatorGroup__c, Station__c, UserRole.DeveloperName, IsPortalEnabled, Profile.Name FROM User WHERE Id = :userId];

        if (users.size() > 0) {
            return users[0];
        }
        return null;
    }

    public static List<User> getUsersStatus(Set<Id> idSet){
        return [SELECT Id,IsActive from User WHERE Id IN:idSet];
    }
}
