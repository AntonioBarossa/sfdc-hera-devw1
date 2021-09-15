/**
* @author Lorenzo (lorenzo.gulotta@webresults.it)
* @date 31/05/2021
* @description HDT_SRV_Note.cls
* @history Lorenzo – 31/05/2021 – created class
*/
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
