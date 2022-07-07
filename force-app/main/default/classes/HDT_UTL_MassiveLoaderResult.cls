@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_MassiveLoaderResult {

    private id idLoaderRequest;
    public String rowSuccess;
    public String rowError;
    public String splitCharacter;
    public String headerSuccess;
    public String headerError;
    public String processName;
    public Blob generateErrorFileBlob;
    public String errorFileTitle;
    public Blob generateSuccessFileBlob;
    public String successFileTitle;
    public String reqName;
    public Integer errorFileNumber;
    public Integer successFileNumber;
    public HDT_QR_StaticResource staticResourceQr = new HDT_QR_StaticResource();

    public HDT_UTL_MassiveLoaderResult(Id varIdLoaderRequest, String splitCharacter) {
        this.errorFileNumber = 0;
        this.successFileNumber = 0;
        this.idLoaderRequest = varIdLoaderRequest;
        this.splitCharacter = splitCharacter;
    }

    public void generateHeaders(String processName, String reqName){
        this.processName = processName;
        this.reqName = reqName;
        List<StaticResource> staticResources = staticResourceQr.getRecordByName(processName);
        String header = staticResources.get(0).Body.toString().remove('\r').remove('\n');
        headerError = header + splitCharacter + 'Errore' + '\n';
        headerSuccess = header + splitCharacter + 'EsitoPositivo' + '\n';
    }

    public void setCurrentSuccessRow(MassiveLoaderRequestItem__c tempReq){
        rowSuccess = String.isBlank(rowSuccess) ? tempReq.Data__c + splitCharacter + tempReq.Result__c : rowSuccess + '\n' + tempReq.Data__c + splitCharacter + tempReq.Result__c;
    }

    public void setCurrentErrorRow(MassiveLoaderRequestItem__c tempReq){
        rowError = String.isBlank(rowError) ? tempReq.Data__c + splitCharacter + tempReq.StatusDescription__c : rowError + '\n' + tempReq.Data__c + splitCharacter + tempReq.StatusDescription__c;
    }

    public void setErrorFile(){
        generateErrorFileBlob = Blob.valueof(headerError + rowError);
        errorFileTitle = 'Errore_' + processName + '_' + reqName + String.valueOf(errorFileNumber);
    }

    public void setSuccessFile(){
        generateSuccessFileBlob = Blob.valueof(headerSuccess + rowSuccess);
        successFileTitle = 'EsitoPositivo_' + processName + '_' + reqName + String.valueOf(successFileNumber);
    }

    public void generateFile(String fileType){

        ContentVersion cvError = new ContentVersion();
        cvError.ContentLocation = 'S';

        switch on fileType {
            when 'success' {
                cvError.VersionData = generateSuccessFileBlob;
                cvError.Title = successFileTitle;
                this.successFileNumber++;
            }	
            when 'error' {
                cvError.VersionData = generateErrorFileBlob;
                cvError.Title = errorFileTitle;
                this.errorFileNumber++;
            }
        }

        cvError.PathOnClient = errorFileTitle + '.csv';
        insert cvError;
        
        ContentVersion cvErrorSaved = [SELECT id,contentDocumentId FROM ContentVersion WHERE id = :cvError.id  LIMIT 1][0];
        ContentDocumentLink cntError = new ContentDocumentLink();
        cntError.ContentDocumentId = cvErrorSaved.ContentDocumentId;
        cntError.LinkedEntityId = this.idLoaderRequest;
        insert cntError;
    }

    public void getLimit(){
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('StageName: ', 'fileGen');
        gen.writeStringField('CpuTime: ', String.valueOf(Limits.getCpuTime()) + ' of ' + String.valueOf(Limits.getLimitCpuTime()));
        gen.writeStringField('DML: ', String.valueOf(Limits.getDMLStatements()) + ' of ' + String.valueOf(Limits.getLimitDMLStatements()));
        gen.writeStringField('HeapSize: ', String.valueOf(Limits.getHeapSize()) + ' of ' + String.valueOf(Limits.getLimitHeapSize()));
        gen.writeStringField('Queries: ', String.valueOf(Limits.getQueries()) + ' of ' + String.valueOf(Limits.getLimitQueries()));
        gen.writeStringField('Callouts: ', String.valueOf(Limits.getCallouts()) + ' of ' + String.valueOf(Limits.getLimitCallouts()));
        gen.writeEndObject();

        System.debug(gen.getAsString());
    }

}