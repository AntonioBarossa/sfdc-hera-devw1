/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 30/06/2021
* @description Class HDT_QR_AtecoMatrix
* @history Keltin Mesonjesi – 30/06/2021 – Created class
*/
public inherited sharing class HDT_QR_AtecoMatrix {

    public static List<AtecoMatrix__c> getAtecoMatrixByComune(String comune){
        return [
            SELECT
            Id,
            Name,
            AtecoCode__c,
            City__c,
            IstatCode__c,
            Category__c
            FROM AtecoMatrix__c
            WHERE
            City__c = :comune
            WITH SECURITY_ENFORCED
        ];
    }

    public static List<AtecoMatrix__c> getAtecoMatrixByCodiceIstat(String codiceIstat){
        return [
            SELECT
            Id,
            Name,
            AtecoCode__c,
            City__c,
            IstatCode__c,
            Category__c
            FROM AtecoMatrix__c
            WHERE
            IstatCode__c = :codiceIstat
            WITH SECURITY_ENFORCED
        ];
    }
}
