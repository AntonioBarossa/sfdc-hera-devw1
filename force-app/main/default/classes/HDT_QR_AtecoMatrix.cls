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
