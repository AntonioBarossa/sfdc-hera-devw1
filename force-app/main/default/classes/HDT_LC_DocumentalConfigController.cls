@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_LC_DocumentalConfigController {

    @AuraEnabled
    public static List<Document> getDocument(){
        return HDT_QR_DocumentalConfiguration.getDocument();
    }

    @AuraEnabled
    public static HDT_WRP_DocumentalConfiguration.HDT_WRP_DatabaseResult controllerHandler(){
        
        HDT_WRP_DocumentalConfiguration.HDT_WRP_DatabaseResult response = new HDT_WRP_DocumentalConfiguration.HDT_WRP_DatabaseResult();

        try{

            List<DocumentalPayloadAdministration__c> docPayloadAdminList;
            docPayloadAdminList = HDT_QR_DocumentalConfiguration.getDocumentalPayloadAdministration(docPayloadAdminList);

            if(docPayloadAdminList.size()==0){
                response.success = false;
                response.message = 'No records found';
                return response;
            }

            response = generateJsonObject(docPayloadAdminList);
            return response;
            
        } catch(Exception e){
            System.debug(LoggingLevel.DEBUG, '>>> Error: ' + e.getMessage() + '; at line: [' + String.valueOf(e.getLineNumber()) + ']');
            response.success = false;
            response.message = '>>> Error: ' + e.getMessage() + '; at line: [' + String.valueOf(e.getLineNumber()) + ']';
            return response;
        }

    }

    public static HDT_WRP_DocumentalConfiguration.HDT_WRP_DatabaseResult generateJsonObject(List<DocumentalPayloadAdministration__c> docPayloadAdminList){

        Id folderId = [SELECT Id FROM Folder WHERE DeveloperName  =: 'DocumentalPayloadAdministration' LIMIT 1].Id;
        Map<String, List<DocumentalPayloadAdministration__c>> contextOneMap = new Map<String, List<DocumentalPayloadAdministration__c>>();
        Map<String, List<DocumentalPayloadAdministration__c>> contextTwoMap = new Map<String, List<DocumentalPayloadAdministration__c>>();
        Map<String, List<DocumentalPayloadAdministration__c>> contextThreeMap = new Map<String, List<DocumentalPayloadAdministration__c>>();
        Map<String, List<DocumentalPayloadAdministration__c>> contextFourMap = new Map<String, List<DocumentalPayloadAdministration__c>>();

        for(DocumentalPayloadAdministration__c dpa : docPayloadAdminList){

            if(dpa.Context1__c){
                if(contextOneMap.containsKey(dpa.Type__c)){
                    contextOneMap.get(dpa.Type__c).add(dpa);
                } else {
                    contextOneMap.put(dpa.Type__c, new List<DocumentalPayloadAdministration__c>{dpa});
                }
            }

            if(dpa.Context2__c){
                if(contextTwoMap.containsKey(dpa.Type__c)){
                    contextTwoMap.get(dpa.Type__c).add(dpa);
                } else {
                    contextTwoMap.put(dpa.Type__c, new List<DocumentalPayloadAdministration__c>{dpa});
                }              
            }

            if(dpa.Context3__c){
                if(contextThreeMap.containsKey(dpa.Type__c)){
                    contextThreeMap.get(dpa.Type__c).add(dpa);
                } else {
                    contextThreeMap.put(dpa.Type__c, new List<DocumentalPayloadAdministration__c>{dpa});
                }                 
            }

            if(dpa.Context4__c){
                if(contextFourMap.containsKey(dpa.Type__c)){
                    contextFourMap.get(dpa.Type__c).add(dpa);
                } else {
                    contextFourMap.put(dpa.Type__c, new List<DocumentalPayloadAdministration__c>{dpa});
                }              
            }

        }

        List<Document> docList = new List<Document>();
        HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalStructure docOneStructure;
        docOneStructure = convertMapToStructure(contextOneMap, docOneStructure);
        Document docOne = generateDocumentObject(docOneStructure, 'Context1', folderId);
        docList.add(docOne);
        docOneStructure = null;

        HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalStructure docTwoStructure;
        docTwoStructure = convertMapToStructure(contextTwoMap, docTwoStructure);
        Document docTwo = generateDocumentObject(docTwoStructure, 'Context2', folderId);
        docList.add(docTwo);
        docTwoStructure = null;

        HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalStructure docThreeStructure;
        docThreeStructure = convertMapToStructure(contextThreeMap, docThreeStructure);
        Document docThree = generateDocumentObject(docThreeStructure, 'Context3', folderId);
        docList.add(docThree);
        docThreeStructure = null;

        HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalStructure docFourStructure;
        docFourStructure = convertMapToStructure(contextFourMap, docFourStructure);
        Document docFour = generateDocumentObject(docFourStructure, 'Context4', folderId);
        docList.add(docFour);
        docFourStructure = null;

        Savepoint sp = Database.setSavepoint();
        List<Document> docToDelete = HDT_QR_DocumentalConfiguration.getDocument();

        if(docToDelete.size() > 0){
            HDT_UTL_DatabaseService.deleteSObject(docToDelete);
        }

        HDT_WRP_DocumentalConfiguration.HDT_WRP_DatabaseResult databaseResult;
        databaseResult = databaseInsert(docList, databaseResult);
        
        System.debug(LoggingLevel.DEBUG, 'generateJsonObject - databaseResult errordata size: ' + databaseResult.errorData.size());
        
        if(!databaseResult.success){
            System.debug(LoggingLevel.DEBUG, 'databaseInsert failed.');
            if(Document.SObjectType.getDescribe().isAccessible()){
                Database.rollback(sp);
            }
        }

        return databaseResult;

    }

    public static HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalStructure convertMapToStructure(Map<String, List<DocumentalPayloadAdministration__c>> contextMap, HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalStructure docStructure){
        docStructure = new HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalStructure();
        docStructure.sections = new List<HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalSection>();
        
        HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalSection sec;
        for(String key : contextMap.keySet()){
            sec = new HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalSection();
            sec.recordType = key;
            sec.records = new List<HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalRecord>();

            HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalRecord dr;
            for(DocumentalPayloadAdministration__c dpa : contextMap.get(key)){
                if(String.isEmpty(dpa.Iterative__c)){
                    dr = convertSobjectToWrap(dpa, dr);
                    sec.records.add(dr);
                } else {
                    sec.object1 = dpa.Object1__c;
                    sec.iterative = dpa.Iterative__c;
                }
            }

            docStructure.sections.add(sec);

        }

        return docStructure;
    }

    public static HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalRecord convertSobjectToWrap(DocumentalPayloadAdministration__c dpa, HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalRecord dr){
        dr = new HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalRecord();
		dr.classString = dpa.Class__c;
		dr.methodString = dpa.Method__c;
		dr.iterative = dpa.Iterative__c;
		dr.recordType = dpa.Type__c;
		dr.expression = dpa.Expression__c;
		dr.separetor = dpa.Separetor__c;
		dr.object1 = dpa.Object1__c;
		dr.object2 = dpa.Object2__c;
		dr.object3 = dpa.Object3__c;
		dr.object4 = dpa.Object4__c;
		dr.field1 = dpa.Field1__c;
		dr.field2 = dpa.Field2__c;
		dr.field3 = dpa.Field3__c;
		dr.field4 = dpa.Field4__c;
		dr.isData = (dpa.IsData__c) ? 'Y' : 'N';
		dr.manageAmount = (dpa.ManageAmount__c) ? 'Y' : 'N';
		dr.defaultVal = dpa.DefaultValue__c;
        dr.payloadField = dpa.PayloadField__c;
        return dr;
    }

    public static Document generateDocumentObject(HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalStructure docStructure, String docName, Id folderId){
        String jsonCode = JSON.serializePretty(docStructure);
        Document doc = new Document();
        doc.FolderId = folderId;
        doc.Name = docName;
        doc.Body = Blob.valueOf(jsonCode);
        doc.Type = 'txt';
        return doc;
    }

    public static HDT_WRP_DocumentalConfiguration.HDT_WRP_DatabaseResult databaseInsert(List<Document> docList, HDT_WRP_DocumentalConfiguration.HDT_WRP_DatabaseResult databaseResult){
        
        //DEBUG
        String debugString = 'HDT_LC_DocumentalConfigController - databaseInsert';
        System.debug(LoggingLevel.DEBUG, debugString + ' - docList size:' + docList.size() + ' - databaseResult: ' + databaseResult);
        System.debug(LoggingLevel.DEBUG, debugString + ' - Document.SObjectType.getDescribe().isAccessible(): ' + Document.SObjectType.getDescribe().isAccessible());  
        System.debug(LoggingLevel.DEBUG, debugString + ' - Document.SObjectType.getDescribe().isCreateable(): ' + Document.SObjectType.getDescribe().isCreateable());        
        
        databaseResult = new HDT_WRP_DocumentalConfiguration.HDT_WRP_DatabaseResult();
        databaseResult.docIdList = new List<Id>();
        databaseResult.errorData = new List<HDT_WRP_DocumentalConfiguration.HDT_WRP_LineError>();
        if (Document.SObjectType.getDescribe().isAccessible() && Document.SObjectType.getDescribe().isCreateable()) {
            List<Database.SaveResult> insertResults = Database.insert(docList, false);
            System.debug(LoggingLevel.DEBUG, debugString + ' - insertResults size:' + insertResults.size());
            System.debug(LoggingLevel.DEBUG, debugString + ' - insertResults:' + insertResults);
            
            for(Integer n=0; n<insertResults.size(); n++){
                Database.SaveResult sr = insertResults[n];
                
                if (!sr.isSuccess()) {
                    // Operation failed
                    /*
                        @Author: Davide Viola - 19/10/2021
                        Description: PMD -> Commentata variabile non utilizzata.
                    */
                    //String errorString = '';
                    HDT_WRP_DocumentalConfiguration.HDT_WRP_LineError lineError = new HDT_WRP_DocumentalConfiguration.HDT_WRP_LineError();
                    for(Database.Error err : sr.getErrors()) {
                        lineError.docName = docList[n].Name;
                        lineError.errorMessage = ' [' + err.getStatusCode() + ': ' + err.getMessage() + ' on field: ' + err.getFields() + ']';
                    }
                    databaseResult.errorData.add(lineError);
                } else {
                    databaseResult.docIdList.add(sr.getId());
                }
            }
    
            if(databaseResult.errorData.size()>0){
                System.debug(LoggingLevel.DEBUG, debugString + ' - has errors.');
                databaseResult.success = false;
                databaseResult.message = '>> Error during database insert';
                databaseResult.dataError = true;
                return databaseResult;
            }
        
            databaseResult.success = true;
            databaseResult.message = '>> No error during script';
        }
        return databaseResult;
    }
        

}