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
            

            for (HDT_MassiveLoaderProcess__mdt massiveLoaderProcess : massiveLoaderProcessQr.getAllRecords()) {

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
    * @description HDT_LC_MassiveLoader.checkCsv() – Check file uploaded by the user
    * @param fileName the Name of the file as it was uploaded
    * @param contentVersionId the Id of the content version givven by the file uploader
    * @param selectedProcess the process which the user intendet to upload
    * @return Map containig confirmation of the file correctness or an error
    */

    @AuraEnabled
    public static Map<String, Object> checkCsv(String fileName, String contentVersionId, String selectedProcessName, String massiveLoaderRequestId){

        Map<String, Object> response = new Map<String, Object>();

        try {

            HDT_MassiveLoaderProcess__mdt selectedProcess = massiveLoaderProcessQr.getRecordByName(selectedProcessName);

            ContentVersion uploadedFile = contentVersionQr.getRecordById(contentVersionId);
            Boolean deleteUploadedFile = false;

            if (fileName.toUpperCase() == (selectedProcess.MasterLabel + '.' + constantsUtl.MASSIVLOADER_FILE_EXTENTION).toUpperCase()) {                

                if(uploadedFile.FileType.toUpperCase() == constantsUtl.MASSIVLOADER_FILE_EXTENTION.toUpperCase()) {

                    List<StaticResource> staticResources = staticResourceQr.getRecordByName(selectedProcessName);
                    Integer expectedNumberOfFields = staticResources.get(0).Body.toString().split(',').size();

                    String fileBody = uploadedFile.VersionData.toString();

                    Boolean parsingError = false;
                    Integer fileLines = 0;

                    List<List<String>> file = new List<List<String>>();
                    for (String fileRow : fileBody.split('\n')) {
                        List<String> rowFields = fileRow.split(',');
                        
                        if (rowFields.size() != expectedNumberOfFields) {
                            parsingError = true;
                            break;
                        }

                        fileLines ++;
                        
                    }

                    if (parsingError) {

                        response.put('error', true);
                        response.put('errorMessage', Label.MassiveLoaderParsingError);
                        
                        deleteUploadedFile = true;

                    } else {
                        
                        MassiveLoaderRequest__c request = new MassiveLoaderRequest__c(Id = massiveLoaderRequestId, 
                                                                                      TotalRequest__c = fileLines,
                                                                                      Status__c = constantsUtl.MASSIVLOADER_STATUS_INATTESAlAVORAZIONE, 
                                                                                      Phase__c = constantsUtl.MASSIVLOADER_PHASE_FILENONPROCESSATO);
                                                                                      
                        massiveLoaderRequestSrv.updateRequestRecord(new List<MassiveLoaderRequest__c>{request});

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

}