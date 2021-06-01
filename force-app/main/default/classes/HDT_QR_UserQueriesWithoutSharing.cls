public class HDT_QR_UserQueriesWithoutSharing {
    public static List<User> getRoleAndProfile(String userId) {
        return [
            SELECT 
            Profile.Name,
            UserRole.Name
            FROM User
            WHERE Id = :userId
            //WITH SECURITY_ENFORCED
        ];
        
    }
}
