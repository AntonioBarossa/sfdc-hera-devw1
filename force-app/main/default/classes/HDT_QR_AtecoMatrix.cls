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
            Category__c,
            RonchiCode__c,
            RonchiSubcategory__c
            FROM AtecoMatrix__c
            WHERE
            City__c = :comune
            WITH SECURITY_ENFORCED
        ];
    }

    public static List<AtecoMatrix__c> getAtecoMatrixByComune(String comune, String whichCode){
        List<AtecoMatrix__c> resultList = new List<AtecoMatrix__c>();
        if('Ronchi'.equalsIgnoreCase(whichCode)){
            resultList = [
                SELECT
                Id,
                Name,
                AtecoCode__c,
                City__c,
                IstatCode__c,
                Category__c,
                RonchiCode__c,
                RonchiSubcategory__c,
                Type__c
                FROM AtecoMatrix__c
                WHERE City__c = :comune
                AND (
                    RonchiCode__c != null OR
                    RonchiSubcategory__c != null OR
                    Type__c != null
                )
                WITH SECURITY_ENFORCED
                ORDER BY RonchiCode__c ASC, RonchiSubcategory__c ASC
                NULLS LAST
            ];
        }else if('Istat'.equalsIgnoreCase(whichCode)){
            resultList = [
                SELECT
                Id,
                Name,
                AtecoCode__c,
                City__c,
                IstatCode__c,
                Category__c,
                RonchiCode__c,
                RonchiSubcategory__c,
                Type__c
                FROM AtecoMatrix__c
                WHERE City__c = :comune
                AND AtecoCode__c != null
                AND IstatCode__c != null
                WITH SECURITY_ENFORCED
                ORDER BY IstatCode__c DESC
                NULLS LAST
            ];
        }
        return resultList;
    }

    public static List<AtecoMatrix__c> getAtecoMatrixByCodiceIstat(String codiceIstat, String whichCode){
        List<AtecoMatrix__c> resultList = new List<AtecoMatrix__c>();
        if('Istat'.equalsIgnoreCase(whichCode)){
            resultList = [
                SELECT
                Id,
                Name,
                AtecoCode__c,
                City__c,
                IstatCode__c,
                Category__c,
                RonchiCode__c,
                RonchiSubcategory__c,
                Type__c
                FROM AtecoMatrix__c
                WHERE IstatCode__c = :codiceIstat
                AND AtecoCode__c != null
                AND IstatCode__c != null
                WITH SECURITY_ENFORCED
                ORDER BY IstatCode__c ASC
                NULLS LAST
            ];
        }else if('Ronchi'.equalsIgnoreCase(whichCode)){
            List<AtecoMatrix__c> getCity = [SELECT Id, City__c 
                                            FROM AtecoMatrix__c 
                                            WHERE IstatCode__c = :codiceIstat 
                                            WITH SECURITY_ENFORCED 
                                            LIMIT 1];
            
            resultList = getCity.size() != 0 ? getAtecoMatrixByComune(getCity[0]?.City__c,'Ronchi') : new List<AtecoMatrix__c>();
            /*
            resultList = [
                SELECT
                Id,
                Name,
                AtecoCode__c,
                City__c,
                IstatCode__c,
                Category__c,
                RonchiCode__c,
                RonchiSubcategory__c
                FROM AtecoMatrix__c
                WHERE RonchiCode__c = :codiceRonchi
                AND (
                    RonchiCode__c != null OR
                    RonchiSubcategory__c != null
                )
                WITH SECURITY_ENFORCED
                ORDER BY RonchiCode__c DESC, RonchiSubcategory__c ASC
                NULLS LAST
            ];
            */
        }
        return resultList;
    }

    /*
    public static List<AtecoMatrix__c> getAtecoMatrixByCodiceRonchi(String codiceRonchi, String whichCode){
        return [
            SELECT
            Id,
            Name,
            AtecoCode__c,
            City__c,
            IstatCode__c,
            Category__c,
            RonchiCode__c,
            RonchiSubcategory__c
            FROM AtecoMatrix__c
            WHERE RonchiCode__c = :codiceRonchi
            AND (
                RonchiCode__c != null OR
                RonchiSubcategory__c != null
            )
            WITH SECURITY_ENFORCED
            ORDER BY RonchiCode__c DESC, RonchiSubcategory__c ASC
            NULLS LAST
        ];
    }
    */

    public static List<AtecoMatrix__c> getAtecoMatrixByCodiceIstat(String codiceIstat){
        return [
            SELECT
            Id,
            Name,
            AtecoCode__c,
            City__c,
            IstatCode__c,
            Category__c,
            RonchiCode__c,
            RonchiSubcategory__c,
            Type__c
            FROM AtecoMatrix__c
            WHERE
            IstatCode__c = :codiceIstat
            WITH SECURITY_ENFORCED
        ];
    }
}
