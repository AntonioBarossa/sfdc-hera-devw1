public with sharing class HDT_UTL_Note {
    public static void createNoteAndAssign(String recordId,String title,String body){
        ContentNote c = new ContentNote();
        c.Title = title;
        if(body != null && body != ''){
            c.Content = Blob.valueOf(' '); 
        }
        c = HDT_SRV_Note.createRecordNote(c);
        //create ContentDocumentLink  record to link with parentId 
        ContentDocumentLink objCntDocLink = new ContentDocumentLink();
        objCntDocLink.LinkedEntityId = recordId; // Specify your parent Id 
        objCntDocLink.ContentDocumentId = c.Id;  //Content Note Id
        objCntDocLink.shareType = 'V'; // Specify your sharing type 
        objCntDocLink.visibility = 'AllUsers';
        HDT_SRV_Note.createRecordAssign(objCntDocLink);
    }
}
