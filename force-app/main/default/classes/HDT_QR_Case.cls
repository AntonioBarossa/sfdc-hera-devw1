/**
* @author Fatjola Memishaj (fatjola.memishaj@dunegroup.it)
* @date 10/03/2021
* @description HDT_QR_Case– Contains queries for Case
* @history Fatjola Memishaj – 10/03/2021 – Created class
*/

public inherited sharing class HDT_QR_Case {
    
    public Case getRecordById(String Id) {
        return [
            SELECT 
            Id,
            Status,
            Subject,
            AccountId
            FROM Case
            where Id = :Id
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
    }    
}
