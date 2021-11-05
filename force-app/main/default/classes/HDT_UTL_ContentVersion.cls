public with sharing class HDT_UTL_ContentVersion {
    private static  HDT_QR_ContentDocument QrContentDocument =new HDT_QR_ContentDocument();

    public static Id makeFile(String body,String fileName,String fileTitle){
        Blob generateFileBlob   = Blob.valueof(body);
        ContentVersion cv       = new ContentVersion();
        cv.ContentLocation      = 'S';
        cv.VersionData          = generateFileBlob;
      //  Date runDate            = Date.today();
        cv.Title                = fileTitle;
        cv.PathOnClient         = fileName;
        HDT_UTL_DatabaseService.insertSObject(cv);
        return cv.id;
    }

    /**
    * @description Cancella tutti i content document che hanno il title passato in input
    * @param title 
    **/
    public static void deleteFiles(String title){
        List<ContentDocument> listFiles = QrContentDocument.getRecordsByTitle(title);
        if (listFiles!=null && listFiles.size()>0) {
            HDT_UTL_DatabaseService.deleteSObject(listFiles);

        }
    }
}
