public with sharing class HDT_UTL_ContentVersion {
    public static Id makeFile(String body,String fileName,String fileTitle){
        Id rtId;
        if (String.isNotBlank(body)) {
            Blob generateFileBlob   = Blob.valueof(body);
            ContentVersion cv       = new ContentVersion();
            cv.ContentLocation      = 'S';
            cv.VersionData          = generateFileBlob;
            Date runDate            = Date.today();
            cv.Title                = fileTitle;
            cv.PathOnClient         = fileName+'.csv';
            insert cv;
            rtId                    =cv.id;

        }
        return rtId;
    }
}
