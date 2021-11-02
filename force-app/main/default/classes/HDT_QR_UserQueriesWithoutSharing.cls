/**
* @author Lorenzo (lorenzo.gulotta@webresults.it)
* @date 28/May/2021
* @description HDT_QR_UserQueriesWithoutSharing
* @history Lorenzo – 28/May/2021 – created class 
*/

public  inherited sharing class HDT_QR_UserQueriesWithoutSharing {
    public static List<User> getRoleAndProfile(String userId) {
        return [
            SELECT 
            Profile.Name,
            UserRole.Name,
            UserRole.DeveloperName


            FROM User
            WHERE Id = :userId
            //WITH SECURITY_ENFORCED
        ];
        
    }
}
