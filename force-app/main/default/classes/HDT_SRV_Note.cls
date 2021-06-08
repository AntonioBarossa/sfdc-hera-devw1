public with sharing class HDT_SRV_Note {

    public static ContentNote createRecordNote(ContentNote c){
        HDT_UTL_DatabaseService.insertSObject(c);
        return c;
    }
    public static contentDocumentLink createRecordAssign(contentDocumentLink co){
        HDT_UTL_DatabaseService.insertSObject(co);
        System.debug('Check');
        return co;
    }
}
