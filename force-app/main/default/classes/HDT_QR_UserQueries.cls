/**
 * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
 * @date 05/05/2021
 * @description HDT_QR_UserQueries.cls - Class that holds queries for User
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */
public inherited sharing class HDT_QR_UserQueries {
    public static List<User> getRoleAndProfile(String userId) {
        return [
            SELECT 
            Profile.Name,
            UserRole.Name
            FROM User
            WHERE Id = :userId
            WITH SECURITY_ENFORCED
        ];
    }

    // INIZIO SVILUPPI EVERIS

    public static User getCurrentUser(String userId) {
        List<User> users = [
            SELECT 
            Id,
            LoginChannel__c,
            CreatorGroup__c,
            Station__c
            FROM User
            WHERE Id = :userId
            WITH SECURITY_ENFORCED
        ];

        if (users.size() > 0) {
            return users[0];
        }

        return null;
    }

    // FINE SVILUPPI EVERIS

}
