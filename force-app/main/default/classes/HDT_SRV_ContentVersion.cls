/**
* @author Lorenzo (lorenzo.gulotta@webresults.it)
* @date 04/08/2021
* @description HDT_SRV_ContentVersion
* @history Lorenzo – 04/08/2021 – created class
*/
public with sharing class HDT_SRV_ContentVersion {
    public ContentVersion createRecord(String title, String pathOnClient, String versionData) {
        ContentVersion cv = new ContentVersion();
        cv.Title = title;
        cv.PathOnClient = pathOnClient;
        cv.ContentLocation = 'S';
        cv.VersionData = Blob.valueOf(versionData);
        cv.IsMajorVersion = true;

        HDT_UTL_DatabaseService.insertSObject(cv);
        return cv;
        
    }
    public ContentVersion createRecordNoInsert(String title, String pathOnClient, String versionData) {
        ContentVersion cv = new ContentVersion();
        cv.Title = title;
        cv.PathOnClient = pathOnClient;
        cv.ContentLocation = 'S';
        cv.VersionData = Blob.valueOf(versionData);
        cv.IsMajorVersion = true;

        //HDT_UTL_DatabaseService.insertSObject(cv);
        return cv;
        
    }
    public ContentVersion createRecordNoInsert(String title, String pathOnClient, blob versionData) {
        ContentVersion cv = new ContentVersion();
        cv.Title = title;
        cv.PathOnClient = pathOnClient;
        cv.ContentLocation = 'S';
        cv.VersionData = versionData;
        cv.IsMajorVersion = true;

        //HDT_UTL_DatabaseService.insertSObject(cv);
        return cv;
        
    }
    public List<ContentVersion> insertRecords(List<ContentVersion> listFile){
        HDT_UTL_DatabaseService.insertSObject(listFile);
        return listFile;
    }
}