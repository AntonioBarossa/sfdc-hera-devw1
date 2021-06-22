/**
 * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)
 * @date 08/04/2021
 * @description HDT_BA_MassiveLoader - Batch class for the processing of MassiveLoader files
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */

global with sharing class HDT_BA_MassiveLoader implements Database.Batchable<sObject>, Database.Stateful{

    public with sharing class HDT_WRP_FileHeader{
        Public String columnName;
        Public String columnApiName;
        Public Boolean mandatory = false;
        Public String dataType;
        Public String validationRegex;
        Public String sobjectType;

    }

    HDT_QR_ContentDocumentLink contentDocumentLinkQr = new HDT_QR_ContentDocumentLink();
    HDT_QR_ContentVersion contentVersionQr = new HDT_QR_ContentVersion();
    HDT_QR_FileTemplate fileTemplateQr = new HDT_QR_FileTemplate();
    HDT_QR_MassiveLoaderRequest massiveLoaderRequestQr = new HDT_QR_MassiveLoaderRequest();
    HDT_UTL_Constants constantsUtl = new HDT_UTL_Constants();
    HDT_UTL_Utils utils = new HDT_UTL_Utils();

    MassiveLoaderRequest__c massiveLoaderRequest;
    FileTemplate__c fileTemplate;

    Map<String, List<String>> jsonMapForDml = new Map<String, List<String>>();

    List<String> importErrors = new List<String>();
    List<String> importSuccess = new List<String>();

    Integer requestOk;
    Integer requestKo;
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        massiveLoaderRequest = massiveLoaderRequestQr.getRecordForImport().get(0);

        fileTemplate = fileTemplateQr.getRecordByTemplateName(massiveLoaderRequest.ProcessType__c).get(0);

        return Database.getQueryLocator(contentVersionQr.recordByDocumentIdQueryString(massiveLoaderRequest.ContentDocumentLinks.get(0).ContentDocumentId));
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope) {

        massiveLoaderRequest.Status__c = constantsUtl.MASSIVLOADER_STATUS_INLAVORAZIONE;
        massiveLoaderRequest.Phase__c = constantsUtl.MASSIVLOADER_PHASE_FILEINELABORAZIONE;
        Database.update(massiveLoaderRequest);

        List<String> contentFileLines = ((ContentVersion) scope.get(0)).VersionData.toString().replaceAll('\r','').split('\n');
        List<String> dataLines = new List<String>();

        Map<Integer, HDT_WRP_FileHeader> headerIndexMap = new Map<Integer, HDT_WRP_FileHeader>();

        //Initialize result files structures
        for (Integer i = 0; i <= (Integer) fileTemplate.HeadLineIndex__c; i++) {
            this.importErrors.add(contentFileLines.get(I));
            this.importSuccess.add(contentFileLines.get(I));
        }

        //Map the columns and corrisponding header based on the uploaded file
        headerIndexMap = createHeaderMap(contentFileLines.get((Integer) fileTemplate.HeadLineIndex__c), fileTemplate.FileDelimiter__c, fileTemplate.FileTemplateColumns__r);

        // Extract lines from uploaded file
        for (Integer i = (Integer) fileTemplate.HeadLineIndex__c + 1; i < contentFileLines.size(); i++) {
            
            String line = contentFileLines.get(i);

            if(checkDataLine(line, fileTemplate.FileDelimiter__c, headerIndexMap)) {
                dataLines.add(line);
            } else {
                importErrors.add(line);
            }
            
        }

        // Create Map of JSON structure to parse into sObject Lists

        // List<String> test = new List<String>();

        for (String dataLine : dataLines) {
            
            Map<String, List<String>> dataLineJsonMap = createJsonStructure(dataLine, fileTemplate.FileDelimiter__c, headerIndexMap);

            for (String mapKey : dataLineJsonMap.keySet()) {
                
                if (this.jsonMapForDml.containsKey(mapKey)) {
                    jsonMapForDml.get(mapKey).add(String.join(dataLineJsonMap.get(mapKey), ','));
                    // test.add(String.join(dataLineJsonMap.get(mapKey), ','));
                }else {
                    jsonMapForDml.put(mapKey, new List<String>{String.join(dataLineJsonMap.get(mapKey), ',')});
                    // test.add(String.join(dataLineJsonMap.get(mapKey), ','));
                }
            }
        }

        System.debug('HDT_BA_MassiveLoader.execute jsonMapForDml: ' + jsonMapForDml);
        System.debug('HDT_BA_MassiveLoader.execute importErrors: ' + importErrors);

        // Create actual List of sObjects to final upsert operation

        // List<SObject> dmlList = new List<Sobject>();

        // for (String mapKey : jsonMapForDml.keySet()) {
            
        //     dmlList.addAll((List<Sobject>) JSON.deserialize(jsonMapForDml.get(mapKey), List<Sobject>.class));
        // }

        // insert dmlList;
        
        //TODO: Finish dml operation implementation
    }

    global void finish(Database.BatchableContext bc) {

        //TODO: Implement finish logic
    }

    /**​
    * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)​
    * @date 09/04/2021
    * @description HDT_BA_MassiveLoader.createHeaderMap(...) – Map the Header in the file to the actual Header from the FileTemplateColumn__c records
    * @param headerLine The header of the file
    * @param fieldDelimiter CSV file delimiter, usually ;
    * @param fileColumnsList List of file columns for the process currently handled
    * @return Map of the header whyere the key is the index of the column and the values are all the parameters for the column validation
    */

    private Map<Integer, HDT_WRP_FileHeader> createHeaderMap(String headerLine, String fieldDelimiter, List<FileTemplateColumn__c> fileColumnsList){

        Map<Integer, HDT_WRP_FileHeader> result = new Map<Integer, HDT_WRP_FileHeader> ();

        Map<String, SObject> templateColumnsMap = utils.createMapFromSobjectList(fileColumnsList, Schema.FileTemplateColumn__c.HeaderName__c);
        System.debug('HDT_BA_MassiveLoader.createHeaderMap templateColumnsMap ' + templateColumnsMap);
        
        List<String> headerColumnsList = headerLine.split(fieldDelimiter);
        
        for (Integer i = 0; i < headerColumnsList.size(); i++) {

            HDT_WRP_FileHeader fileHeader = new HDT_WRP_FileHeader();

            String currentColumn = headerColumnsList.get(i);
            System.debug('HDT_BA_MassiveLoader.createHeaderMap currentColumn ' + currentColumn);
            FileTemplateColumn__c columnTemplate = (FileTemplateColumn__c) templateColumnsMap.get(currentColumn);

            fileHeader.columnName = currentColumn;
            fileHeader.columnApiName = columnTemplate.HeaderApiName__c;
            fileHeader.mandatory = columnTemplate.Mandatory__c;
            fileHeader.dataType = columnTemplate.DataType__c;
            fileHeader.validationRegex = columnTemplate.ValidationRegex__c;
            fileHeader.sobjectType = columnTemplate.SobjectType__c;
            
            result.put(i, fileHeader);
        }

        return result;
    }

    /**​
    * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)​
    * @date 09/04/2021
    * @description HDT_BA_MassiveLoader.checkDataLine(...) – Check the data on each line of the file by comparing it top the regex of the column
    * @param dataLine A line connecting actual data to insert as extracted from the file
    * @param fieldDelimiter CSV file delimiter, usually ;
    * @param headerMap The Map of the header as build with createHeaderMap(...)
    * @return Boolean result of the validation
    */

    private Boolean checkDataLine(String dataLine, String fileDelimiter, Map<Integer, HDT_WRP_FileHeader> headerMap) {

        Boolean formatedCorrectly = true;        

        List<String> lineDataList = dataLine.split(fileDelimiter);

        for (Integer i = 0; i < lineDataList.size(); i++) {
            
            String dataField = lineDataList.get(i);
            Boolean fieldIsMandatoy = headerMap.get(i).mandatory;

            //Check Mandatory
            if (fieldIsMandatoy && String.isEmpty(dataField)) {
                formatedCorrectly = false;

            }else if(!String.isEmpty(dataField) && String.isNotEmpty(headerMap.get(i).validationRegex)) {
             
                //Check Regex Structure
                if(!Pattern.compile(headerMap.get(i).validationRegex).matcher(String.valueOf(dataField)).matches()) {
                    formatedCorrectly = false;
                }

            }

        }

        return formatedCorrectly;
    }
/**​
    * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)​
    * @date 09/04/2021
    * @description HDT_BA_MassiveLoader.createJsonStructure(...) – Build the JSON structure that can be parsed in the sObjects to insert
    * @param dataLine A line connecting actual data to insert as extracted from the file
    * @param fieldDelimiter CSV file delimiter, usually ;
    * @param headerMap The Map of the header as build with createHeaderMap(...)
    * @return Map map of the JSON structures needed for the DML where the key is sObject api name and the valuex is a list of records in the JSON format
    */

    private Map<String, List<String>> createJsonStructure(String dataLine, String fileDelimiter, Map<Integer, HDT_WRP_FileHeader> headerMap) {
        
        List<String> lineDataList = dataLine.split(fileDelimiter);

        Map<String, List<String>> mapForJsonStructure = new Map<String, List<String>>();

        for (Integer i = 0; i < lineDataList.size(); i++) {
            
            String dataField = lineDataList.get(i);
            HDT_WRP_FileHeader headerColumn = headerMap.get(i);
            
            if (mapForJsonStructure.containsKey(headerColumn.sobjectType)) {
                mapForJsonStructure.get(headerColumn.sobjectType).add('"' + headerColumn.columnApiName + '":"' + dataField + '"');
            } else {
                List<String> newFieldsList = new List<String>();
                
                newFieldsList.add('"attributes":{"type":"' + headerColumn.sobjectType + '"}');
                newFieldsList.add('"' + headerColumn.columnApiName + '":"' + dataField + '"');

                mapForJsonStructure.put(headerColumn.sobjectType, newFieldsList);
            }

        }

        return mapForJsonStructure;

    }

    //Keep in mind for insert list implementation
    // String test = '{"attributes":{"type":"Contact"},"FirstName":"gino","LastName":"rossi"}';
    // Contact testSo = (Contact) JSON.deserialize(test, Sobject.class);
    // system.debug('testSo ' + testSo);

    // Contact con = new Contact(FirstName = 'gino', LastName='rossi');
    // System.debug(JSON.serialize(con));

}