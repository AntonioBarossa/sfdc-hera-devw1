public inherited sharing class HDT_QR_Municipality {

    public static List<Municipality__c> getAllMunicipalities(List<Municipality__c> muniList){
        muniList = new List<Municipality__c>();
        muniList = [
            SELECT MunicipalityCode__c, ProvinceCode__c, RegionCode__c, Name, ProvinceName__c
            FROM Municipality__c
            WITH SECURITY_ENFORCED
            ORDER BY ProvinceName__c
        ];
        return muniList;
    }

    public static List<Folder> getFolder(List<Folder> folderList, String folderName){
        folderList = new List<Folder>();
        folderList = [
            SELECT Id, DeveloperName
            FROM Folder
            WHERE DeveloperName = :folderName
            WITH SECURITY_ENFORCED
        ];
        return folderList;
    }

}