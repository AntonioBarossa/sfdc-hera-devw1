public with sharing class HDT_BA_ErrorRequestItem implements Database.Batchable<SObject>, Database.Stateful,Database.AllowsCallouts {

    public static HDT_QR_StaticResource staticResourceQr = new HDT_QR_StaticResource();
    private id idLoaderRequest;
	public Integer fileNumber;
    public String splitCharacter = '|';

    public HDT_BA_ErrorRequestItem(Id varIdLoaderRequest) {
        this.idLoaderRequest = varIdLoaderRequest;
        this.fileNumber = 0;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        HDT_QR_Helper qrObj=new HDT_QR_Helper();
        qrObj.setObj('MassiveLoaderRequestItem__c');
        qrObj.setNestedFields(new list<String>{'MassiveLoaderRequest__r.ProcessType__c,MassiveLoaderRequest__r.Name'});
        qrObj.setFilter('MassiveLoaderRequest__c =\''+this.idLoaderRequest+'\' AND Status__c =\'Errore\' Order by CreatedDate DESC');
        String query =  qrObj.getQeryString();
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<MassiveLoaderRequestItem__c> scope) {
        String reqName;
        String processName;
        String row;

        for (MassiveLoaderRequestItem__c tempReq : scope) {

            if (String.isBlank(processName)){
                processName=tempReq.MassiveLoaderRequest__r.ProcessType__c;
            }

            if (String.isBlank(reqName)){
                reqName = tempReq.MassiveLoaderRequest__r.Name;
            }

            //if (tempReq.StatusDescription__c.contains(',')) {
            //    tempReq.StatusDescription__c=tempReq.StatusDescription__c.replace(',', '|');
            //}

            row = String.isBlank(row) ? tempReq.Data__c + splitCharacter + tempReq.StatusDescription__c : row + '\n' + tempReq.Data__c + splitCharacter + tempReq.StatusDescription__c;
        }

        List<StaticResource> staticResources = staticResourceQr.getRecordByName(processName);
        String header=staticResources.get(0).Body.toString().remove('\r').remove('\n');
        //header=header+',Errore'+'\n';
        header = header + splitCharacter + 'Errore' + '\n';

        if (String.isNotBlank(row)) {
            Blob generateFileBlob = Blob.valueof(header+row);
            ContentVersion cv = new ContentVersion();
            cv.ContentLocation = 'S';
            cv.VersionData = generateFileBlob;
            //Date runDate= Date.today();
           
            String fileTitle = 'Errore_' + processName + '_' + reqName + String.valueOf(fileNumber);
            cv.Title = fileTitle;
            cv.PathOnClient = fileTitle + '.csv';
            insert cv;
            
            //HDT_SRV_Attachment.insertContentVersion(cv);
            ContentVersion cv2 = [SELECT id,contentDocumentId FROM ContentVersion WHERE id = :cv.id  LIMIT 1][0];
            ContentDocumentLink cnt = new ContentDocumentLink();
            cnt.ContentDocumentId = cv2.ContentDocumentId;
            cnt.LinkedEntityId = this.idLoaderRequest;
            insert cnt;
            this.fileNumber=this.fileNumber+1;
        }
        
    }

    public void finish(Database.BatchableContext bc){
        System.debug('HDT_BA_ErrorRequestItem finish ');
    }

}