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
}
