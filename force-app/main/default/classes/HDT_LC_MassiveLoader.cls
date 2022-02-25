/**
 * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)
 * @date 23/03/2021
 * @description HDT_LC_MassiveLoader - Controller class for hdtMassiveLoader
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */

public with sharing class HDT_LC_MassiveLoader {

    private static HDT_QR_ContentVersion contentVersionQr = new HDT_QR_ContentVersion();
    private static HDT_QR_MassiveLoaderProcess massiveLoaderProcessQr = new HDT_QR_MassiveLoaderProcess();
    private static HDT_QR_StaticResource staticResourceQr = new HDT_QR_StaticResource();
    private static HDT_SRV_MassiveLoaderRequest massiveLoaderRequestSrv = new HDT_SRV_MassiveLoaderRequest();
    private static HDT_UTL_Constants constantsUtl = new HDT_UTL_Constants();
    
    /**​
    * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)​
    * @date 23/03/2021
    * @description HDT_LC_MassiveLoader.getCsvBody(String selectedProcessName) – Get body of the Static Resource for the specified name
    * @param selectedProcessName name of the process selected by the user for the export
    * @return Map containig the body and/or potential errors
    */

    @AuraEnabled
    public static Map<String, Object> getCsvBody(String selectedProcessName) {
        //System.debug(LoggingLevel.DEBUG, 'HDT_LC_MassiveLoader.getCsvBody : '+selectedProcessName);
        Map<String, Object> response = new Map<String, Object>();
        
        try {

            List<StaticResource> staticResources = staticResourceQr.getRecordByName(selectedProcessName);

            if (!staticResources.isEmpty()) {

                String urlCsvResource = '/resource/'
                                           + staticResources.get(0).SystemModStamp.getTime()
                                           + '/' 
                                           + staticResources.get(0).Name;
                
                response.put('urlCSVResource', urlCsvResource);
                response.put('error', false);

            } else {
                
                response.put('error', true);
                response.put('errorMessage', Label.MassiveLoaderFileNotFound);

            }

            return response;
            
        } catch (Exception e) {
            
            response.put('error', true);
            response.put('errorMessage', e.getMessage());
            response.put('errorStackTraceString', e.getStackTraceString());

            return response;

        }

    }

    /**​
    * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)​
    * @date 24/03/2021
    * @description HDT_LC_MassiveLoader.initialize() – Initialize component, get processes for picklist
    * @return Map containig the picklist map and/or potential errors
    */

    @AuraEnabled
    public static Map<String, Object> initialize() {

        Map<String, Object> response = new Map<String, Object>();

        try {

            List<Map<String, String>> processesPicklist = new List<Map<String, String>>()            ;
            List<HDT_MassiveLoaderProcess__mdt> listProcess = massiveLoaderProcessQr.getAllRecords();
            listProcess.sort();
            for (HDT_MassiveLoaderProcess__mdt massiveLoaderProcess : listProcess) {

                processesPicklist.add(new Map<String, String>{'value' => massiveloaderProcess.DeveloperName, 'label' => massiveloaderProcess.MasterLabel});

            }

            if (!processesPicklist.isEmpty()) {
                
                response.put('error', false);
                response.put('processesPicklist', processesPicklist);

            } else {
                
                response.put('error', true);
                response.put('errorMessage', 'Tipi di processo non trovati');

            }

            return response;
            
        } catch (Exception e) {
            
            response.put('error', true);
            response.put('errorMessage', e.getMessage());
            response.put('errorStackTraceString', e.getStackTraceString());

            return response;

        }

    }

    /**​
    * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)​
    * @date 06/04/2021
    * @description HDT_LC_MassiveLoader.createMassiveLoaderRequest(...) – Create the MassiveLoaderRequest__c record
    * @param selectedProcessName the name of the selected process
    * @return Map containig the id of the new MassiveLoaderRequest__c and/or potential errors
    */

    @AuraEnabled
    public static Map<String, Object> createMassiveLoaderRequest(String selectedProcessName) {

        Map<String, Object> response = new Map<String, Object>();
        try {

            HDT_MassiveLoaderProcess__mdt selectedProcess = massiveLoaderProcessQr.getRecordByName(selectedProcessName);

            response.put('error', false);
            response.put('massiveLoaderRequestId', massiveLoaderRequestSrv.createNewRequestRecord(selectedProcessName, (Integer) selectedProcess.Priority__c).Id);


            return response;

        } catch (Exception e) {
            
            response.put('error', true);
            response.put('errorMessage', e.getMessage());
            response.put('errorStackTraceString', e.getStackTraceString());

            return response;

        }
    }

    /**​
    * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)​
    * @date 30/03/2021
    * @description HDT_LC_MassiveLoader.updateMassiveLoaderRequest() – updates request if the user changes process type
    * @param massiveLoaderRequestId Id of the Massive Loader Request to update
    * @param selectedProcessName New process name selected by user
    * @return Map containig the result of the update
    */

    @AuraEnabled
    public static Map<String, Object> updateMassiveLoaderRequest(String massiveLoaderRequestId, String selectedProcessName){

        Map<String, Object> response = new map<String, Object>();
        try {

            MassiveLoaderRequest__c request = new MassiveLoaderRequest__c(Id = massiveLoaderRequestId, 
                                                                          ProcessType__c = selectedProcessName);

            massiveLoaderRequestSrv.updateRequestRecord(new List<MassiveLoaderRequest__c>{request});

            response.put('error', false);

            return response;
            
        } catch (Exception e) {
            
            response.put('error', true);
            response.put('errorMessage', e.getMessage());
            response.put('errorStackTraceString', e.getStackTraceString());

            return response;

        }
    }

    @AuraEnabled
    public static Map<String, Object> convertCsvToRequestItem(String fileName, String contentVersionId, String selectedProcessName, String massiveLoaderRequestId){

        //massiveLoaderRequestId = 'a3d3O000000X5WEQA0';

        //System.debug(LoggingLevel.DEBUG, '>>> fileName: ' + fileName);
        //System.debug(LoggingLevel.DEBUG, '>>> contentVersionId: ' + contentVersionId);
        //System.debug(LoggingLevel.DEBUG, '>>> selectedProcessName: ' + selectedProcessName);
        //System.debug(LoggingLevel.DEBUG, '>>> massiveLoaderRequestId: ' + massiveLoaderRequestId);

        HDT_QR_ContentVersion contentVersionQr = new HDT_QR_ContentVersion();
        Map<String, Object> response = new Map<String, Object>();
        Integer csvLinesLimit = 4500;
        ContentVersion uploadedFile = contentVersionQr.getRecordById(contentVersionId);
        HDT_MassiveLoaderProcess__mdt selectedProcess = massiveLoaderProcessQr.getRecordByName(selectedProcessName);

        if(!fileName.equalsIgnoreCase(selectedProcess.DeveloperName   + '.' + constantsUtl.MASSIVLOADER_FILE_EXTENTION)) {                
            response.put('error', true);
            response.put('errorMessage', Label.MassiveLoaderFileNameError);
            return response;
        }

        if(uploadedFile.FileType.toUpperCase() != constantsUtl.MASSIVLOADER_FILE_EXTENTION.toUpperCase()) {
            response.put('error', true);
            response.put('errorMessage', Label.MassiveLoaderExtentionError);
            return response;
        }

        System.debug(LoggingLevel.DEBUG, '>>> HeapSize at start: ' + String.valueOf(Limits.getHeapSize()) + ' of ' + String.valueOf(Limits.getLimitHeapSize()));
    
        String fileBody = uploadedFile.VersionData.toString();

        Integer totLinesCounter = fileBody.countMatches('\n');
        System.debug(LoggingLevel.DEBUG, '>>> totLinesCounter: ' + totLinesCounter);

        if(totLinesCounter > csvLinesLimit){
            response.put('error', true);
            response.put('errorMessage', 'Il file csv contiene più di 1500 righe.');
            return response;
        }

        uploadedFile = null;
    
        System.debug(LoggingLevel.DEBUG, '>>> HeapSize after body to string: ' + String.valueOf(Limits.getHeapSize()) + ' of ' + String.valueOf(Limits.getLimitHeapSize()));
    
        List<MassiveLoaderRequestItem__c> requestItemList = new List<MassiveLoaderRequestItem__c>();
        List<String> csvRowList = new List<String>();
        Integer headerNewLineCharIndex = fileBody.indexof('\n');
    
        String newLine = fileBody.substring(0, headerNewLineCharIndex);
        System.debug(LoggingLevel.DEBUG, '>>> header row : ' + newLine);
    
        fileBody = fileBody.substring(headerNewLineCharIndex + 1);
    
        Boolean hasNewRow = true;
        Integer currentHeapSize = 0;
        Integer limitHeapSize = Limits.getLimitHeapSize();
        Integer rowNewLineCharIndex = fileBody.indexof('\n');
        String csvNewLine = '';
        MassiveLoaderRequestItem__c newRequestItem;
        
        while(hasNewRow){
            
            newRequestItem = new MassiveLoaderRequestItem__c();
            newRequestItem.Data__c = fileBody.substring(0, rowNewLineCharIndex);
            newRequestItem.MassiveLoaderRequest__c = massiveLoaderRequestId;
            requestItemList.add(newRequestItem);
    
            fileBody = fileBody.substring(rowNewLineCharIndex + 1);
            rowNewLineCharIndex = fileBody.indexof('\n');
    
            currentHeapSize = Limits.getHeapSize();
    
            if(currentHeapSize > limitHeapSize){
                // having problem with limit...do something...
            }
    
            System.debug('>>> ' + fileBody + ' : ' + rowNewLineCharIndex);
            if(String.isNotEmpty(fileBody)){
            //if(fileBody != null || rowNewLineCharIndex == -1){
                MassiveLoaderRequestItem__c lastRequestItem = new MassiveLoaderRequestItem__c();
                lastRequestItem.Data__c = fileBody;
                lastRequestItem.MassiveLoaderRequest__c = massiveLoaderRequestId;
                requestItemList.add(lastRequestItem);
                hasNewRow = false;
            }
    
        }
    
        try{

            SObjectType objtype = Schema.getGlobalDescribe().get('MassiveLoaderRequestItem__c');
            Schema.DescribeSObjectResult objRes = objtype.getDescribe();
     
            if(objRes.isCreateable() && objRes.isUpdateable()){
                insert requestItemList;
            }

        } catch(Exception e){
            response.put('error', false);
            response.put('reqName', e.getMessage());
            return response;
        }
        
        System.debug(LoggingLevel.DEBUG, '>>> csvRowList: ' + csvRowList.size());
    
        List<MassiveLoaderRequest__c> reqMass = [
            SELECT Id, Name, TotalRequest__c, Status__c
            FROM MassiveLoaderRequest__c
            WHERE Id = :massiveLoaderRequestId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        reqMass[0].TotalRequest__c = requestItemList.size();
        reqMass[0].Status__c = constantsUtl.MASSIVLOADER_STATUS_INATTESAlAVORAZIONE;
        //massReq.Phase__c = constantsUtl.MASSIVLOADER_PHASE_FILENONPROCESSATO

        try{
            SObjectType objtype = Schema.getGlobalDescribe().get('MassiveLoaderRequest__c');
            Schema.DescribeSObjectResult objRes = objtype.getDescribe();
     
            if(objRes.isCreateable() && objRes.isUpdateable()){
                update reqMass;
            }
        } catch(Exception e){
            System.debug(LoggingLevel.DEBUG, '>>> Exception: ' + e.getMessage());
        }

        response.put('error', false);
        response.put('reqName', reqMass[0].Name);

        System.debug(LoggingLevel.DEBUG, '>>> CpuTime: ' + String.valueOf(Limits.getCpuTime()) + ' of ' + String.valueOf(Limits.getLimitCpuTime()));
        System.debug(LoggingLevel.DEBUG, '>>> DML: ' + String.valueOf(Limits.getDMLStatements()) + ' of ' + String.valueOf(Limits.getLimitDMLStatements()));
        System.debug(LoggingLevel.DEBUG, '>>> HeapSize at finish: ' + String.valueOf(Limits.getHeapSize()) + ' of ' + String.valueOf(Limits.getLimitHeapSize()));

        return response;
            
    }

    /**​
    * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)​
    * @date 30/03/2021
    * @description HDT_LC_MassiveLoader.checkCsv() – Check file uploaded by the user
    * @param fileName the Name of the file as it was uploaded
    * @param contentVersionId the Id of the content version givven by the file uploader
    * @param selectedProcess the process which the user intendet to upload
    * @return Map containig confirmation of the file correctness or an error
    */

    @AuraEnabled
    public static Map<String, Object> checkCsv(String fileName, String contentVersionId, String selectedProcessName, String massiveLoaderRequestId){
       /* System.debug(LoggingLevel.DEBUG, 'HDT_LC_MassiveLoader.checkCsv');
        System.debug(LoggingLevel.DEBUG, 'fileName: '+fileName);
        System.debug(LoggingLevel.DEBUG, 'contentVersionId: '+contentVersionId);
        System.debug(LoggingLevel.DEBUG, 'selectedProcessName: '+selectedProcessName );
        System.debug(LoggingLevel.DEBUG, 'massiveLoaderRequestId: '+massiveLoaderRequestId );*/
        Map<String, Object> response = new Map<String, Object>();
        List<MassiveLoaderRequestItem__c> listRequestItem = new List<MassiveLoaderRequestItem__c>();
        try {

            HDT_MassiveLoaderProcess__mdt selectedProcess = massiveLoaderProcessQr.getRecordByName(selectedProcessName);

            ContentVersion uploadedFile = contentVersionQr.getRecordById(contentVersionId);
            Boolean deleteUploadedFile = false;
            //System.debug(LoggingLevel.DEBUG, 'selectedProcessName '+selectedProcessName);

            if (fileName.equalsIgnoreCase(selectedProcess.DeveloperName   + '.' + constantsUtl.MASSIVLOADER_FILE_EXTENTION)) {                
                if(uploadedFile.FileType.toUpperCase() == constantsUtl.MASSIVLOADER_FILE_EXTENTION.toUpperCase()) {
                    //System.debug(LoggingLevel.DEBUG, 'selectedProcessName '+selectedProcessName);
                    List<StaticResource> staticResources = staticResourceQr.getRecordByName(selectedProcess.DeveloperName );
                    //System.debug(LoggingLevel.DEBUG, 'staticResources '+staticResources.size());
                    Integer expectedNumberOfFields = staticResources.get(0).Body.toString().split(',').size();

                    String fileBody = uploadedFile.VersionData.toString();

                    Boolean parsingError = false;
                    Integer fileLines = 0;

                    //List<List<String>> file = new List<List<String>>();
                    for (String fileRow : fileBody.split('\n')) {
                        fileRow=fileRow.replaceAll(',,', ',null,');
                        List<String> rowFields = fileRow.split(',');
                        System.debug(LoggingLevel.DEBUG, 'row size '+rowFields.size());
                        //System.debug(LoggingLevel.DEBUG, 'expectedNumberOfFields '+expectedNumberOfFields);
                        if (rowFields.size() != expectedNumberOfFields) {
                            System.debug(LoggingLevel.DEBUG, 'problemi con la riga  '+fileLines);
           
                            parsingError = true;
                            break;
                        }
                       if (fileLines>0) {
                        //no header
                        MassiveLoaderRequestItem__c tempRequestItem=new MassiveLoaderRequestItem__c();
                        tempRequestItem.Data__c                 =   fileRow;
                        tempRequestItem.MassiveLoaderRequest__c =   massiveLoaderRequestId;
                        listRequestItem.add(tempRequestItem);
                       }
                       
                        fileLines ++;
                        
                    }

                    if (parsingError) {

                        response.put('error', true);
                        response.put('errorMessage', Label.MassiveLoaderParsingError);
                        
                        deleteUploadedFile = true;

                    } 
                    else {
                        
                        MassiveLoaderRequest__c request = new MassiveLoaderRequest__c(Id = massiveLoaderRequestId, 
                                                                                      TotalRequest__c = fileLines-1,
                                                                                      Status__c = constantsUtl.MASSIVLOADER_STATUS_INATTESAlAVORAZIONE 
                                                                                      //Phase__c = constantsUtl.MASSIVLOADER_PHASE_FILENONPROCESSATO
                                                                                      );
                                                                                      
                        if (listRequestItem!=null && listRequestItem.size()>0) {

                            SObjectType objtype = Schema.getGlobalDescribe().get('MassiveLoaderRequestItem__c');
                            Schema.DescribeSObjectResult objRes = objtype.getDescribe();
                     
                            if(objRes.isCreateable() && objRes.isUpdateable()){
                                insert listRequestItem;
                            }

                            integer  numberRequestProcessing= database.countQuery('SELECT count() FROM MassiveLoaderRequest__c WHERE  Status__c =\'In Lavorazione\'');

                            if (numberRequestProcessing==0 && !test.isRunningTest()) {
                                request.Status__c = constantsUtl.MASSIVLOADER_STATUS_INLAVORAZIONE;
                                //HDT_BA_ProcessRequestItem processReq = new HDT_BA_ProcessRequestItem(listRequestItem.get(0).MassiveLoaderRequest__c); 
                                //Database.executeBatch(processReq,1);
                            }
                        }
                        massiveLoaderRequestSrv.updateRequestRecord(new List<MassiveLoaderRequest__c>{request});
                        list <MassiveLoaderRequest__c> lrequest=[SELECT Id,Name  FROM MassiveLoaderRequest__c WHERE Id=:massiveLoaderRequestId  WITH SECURITY_ENFORCED LIMIT 1];
                        response.put('reqName',lrequest.get(0).Name );

                        response.put('error', false);

                    }

                } else {
                    
                    response.put('error', true);
                    response.put('errorMessage', Label.MassiveLoaderExtentionError);

                    deleteUploadedFile = true;
                }

            } else {

                response.put('error', true);
                response.put('errorMessage', Label.MassiveLoaderFileNameError);

                deleteUploadedFile = true;

            }

            if (deleteUploadedFile) {
                
                Database.delete(uploadedFile.ContentDocumentId);

            }

            return response;
            
        } catch (Exception e) {
            
            response.put('error', true);
            response.put('errorMessage', e.getMessage());
            response.put('errorStackTraceString', e.getStackTraceString());

            return response;

        }
    }

}