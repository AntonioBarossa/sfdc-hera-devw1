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
    private static String splitCharacter = '\\|';
    
    public static String getSplitCharacter(){
        return splitCharacter;
    }

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

    private static void deleteDocument(Id contentDocumentId, Id massiveLoaderRequestId){
        Database.delete(contentDocumentId);
        Database.delete(massiveLoaderRequestId);
    }

    @AuraEnabled
    public static Map<String, Object> convertCsvToRequestItem(String fileName, String contentVersionId, String selectedProcessName, String massiveLoaderRequestId){

        String splitCharacter = getSplitCharacter();//'\\|';
        HDT_QR_ContentVersion contentVersionQr = new HDT_QR_ContentVersion();
        Map<String, Object> response = new Map<String, Object>();
        Integer csvLinesLimit = 4500;
        ContentVersion uploadedFile = contentVersionQr.getRecordById(contentVersionId);
        HDT_MassiveLoaderProcess__mdt selectedProcess = massiveLoaderProcessQr.getRecordByName(selectedProcessName);
        Boolean parsingError = false;
        Id contentDocumentId = uploadedFile.ContentDocumentId;
        List<String> fileNameDetails = fileName.split('\\.');
        
        if(
            !fileNameDetails[0].containsIgnoreCase(selectedProcess.DeveloperName) ||
            !fileNameDetails[0].containsIgnoreCase(selectedProcess.MasterLabel) ||
            fileNameDetails[1] != constantsUtl.MASSIVLOADER_FILE_EXTENTION
        ){
        //if(!fileName.equalsIgnoreCase(selectedProcess.DeveloperName + '.' + constantsUtl.MASSIVLOADER_FILE_EXTENTION) &&
        //   !fileName.equalsIgnoreCase(selectedProcess.MasterLabel + '.' + constantsUtl.MASSIVLOADER_FILE_EXTENTION)
        //    ) {                
            response.put('error', true);
            response.put('errorMessage', Label.MassiveLoaderFileNameError);
            deleteDocument(contentDocumentId, massiveLoaderRequestId);
            return response;
        }

        if(uploadedFile.FileType.toUpperCase() != constantsUtl.MASSIVLOADER_FILE_EXTENTION.toUpperCase()) {
            response.put('error', true);
            response.put('errorMessage', Label.MassiveLoaderExtentionError);
            deleteDocument(contentDocumentId, massiveLoaderRequestId);
            return response;
        }

        System.debug(LoggingLevel.DEBUG, '>>> HeapSize at start: ' + String.valueOf(Limits.getHeapSize()) + ' of ' + String.valueOf(Limits.getLimitHeapSize()));
    
        String fileBody;

        try{
            fileBody = uploadedFile.VersionData.toString();
        } catch(exception e){
            response.put('error', true);
            response.put('errorMessage', 'Si è verificato un errore con il formato csv');
            deleteDocument(contentDocumentId, massiveLoaderRequestId);
            return response;  
        }

        Integer totLinesCounter = fileBody.countMatches('\n');
        System.debug(LoggingLevel.DEBUG, '>>> totLinesCounter: ' + totLinesCounter);

        if(totLinesCounter == 0){
            response.put('error', true);
            response.put('errorMessage', 'Il file csv non contiene nulla.');
            deleteDocument(contentDocumentId, massiveLoaderRequestId);
            return response;
        }

        if(totLinesCounter > csvLinesLimit){
            response.put('error', true);
            response.put('errorMessage', 'Il file csv contiene più di 1500 righe.');
            //deleteDocument(contentDocumentId);
            return response;
        }

        uploadedFile = null;
    
        List<StaticResource> staticResources = staticResourceQr.getRecordByName(selectedProcess.DeveloperName);
        Integer expectedNumberOfFields = staticResources.get(0).Body.toString().split(splitCharacter).size();

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

        if(String.isEmpty(fileBody)){
            response.put('error', true);
            response.put('errorMessage', 'Il file csv non contiene nulla.');
            deleteDocument(contentDocumentId, massiveLoaderRequestId);
            return response;
        }

        while(hasNewRow){

            if(rowNewLineCharIndex == -1){
                if(String.isNotEmpty(fileBody)){

                    if(checkSingleRow(fileBody, expectedNumberOfFields, splitCharacter)){
                        parsingError = true;
                        break;
                    }

                    newRequestItem = new MassiveLoaderRequestItem__c();
                    newRequestItem.Data__c = fileBody;
                    newRequestItem.MassiveLoaderRequest__c = massiveLoaderRequestId;
                    requestItemList.add(newRequestItem);           
                }
                break;
            }

            newRequestItem = new MassiveLoaderRequestItem__c();
            newRequestItem.Data__c = fileBody.substring(0, rowNewLineCharIndex);

            if(checkSingleRow(newRequestItem.Data__c, expectedNumberOfFields, splitCharacter)){
                parsingError = true;
                break;
            }

            newRequestItem.MassiveLoaderRequest__c = massiveLoaderRequestId;
            requestItemList.add(newRequestItem);

            fileBody = fileBody.substring(rowNewLineCharIndex + 1);
            rowNewLineCharIndex = fileBody.indexof('\n');
    
            currentHeapSize = Limits.getHeapSize();
    
            if(currentHeapSize > limitHeapSize){
                // having problem with limit...do something...
            }

            if(String.isNotEmpty(fileBody) && rowNewLineCharIndex == -1){
                if(checkSingleRow(fileBody, expectedNumberOfFields, splitCharacter)){
                    parsingError = true;
                    break;
                }
                MassiveLoaderRequestItem__c lastRequestItem = new MassiveLoaderRequestItem__c();
                lastRequestItem.Data__c = fileBody;
                lastRequestItem.MassiveLoaderRequest__c = massiveLoaderRequestId;
                requestItemList.add(lastRequestItem);
                hasNewRow = false;
            }

        }
    
        if(parsingError){
            response.put('error', true);
            response.put('errorMessage', Label.MassiveLoaderParsingError);
            deleteDocument(contentDocumentId, massiveLoaderRequestId);
            return response;
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

    private static Boolean checkSingleRow(String fileRow, Integer expectedNumberOfFields, String splitCharacter){
        fileRow = fileRow.replaceAll(splitCharacter + splitCharacter, splitCharacter + 'null' + splitCharacter);
        List<String> rowFields = fileRow.split(splitCharacter, -1);
        return rowFields.size() != expectedNumberOfFields;
    }

}