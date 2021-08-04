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
}