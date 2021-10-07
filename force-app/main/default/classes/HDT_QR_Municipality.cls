public inherited sharing class HDT_QR_Municipality {

    public static List<City__c> getAllMunicipalities(List<City__c> muniList){
        muniList = new List<City__c>();
        muniList = [
            SELECT MunicipalityCode__c, Province__c, RegionCode__c, Name, ProvinceName__c
            FROM City__c
            WITH SECURITY_ENFORCED
            ORDER BY ProvinceName__c
        ];
        return muniList;
    }

    //public static List<Folder> getFolder(List<Folder> folderList, String folderName){
    //    folderList = new List<Folder>();
    //    folderList = [
    //        SELECT Id, DeveloperName
    //        FROM Folder
    //        WHERE DeveloperName = :folderName
    //        WITH SECURITY_ENFORCED
    //    ];
    //    return folderList;
    //}

}