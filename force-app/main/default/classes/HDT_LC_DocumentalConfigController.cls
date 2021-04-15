public inherited sharing class HDT_LC_DocumentalConfigController {

    @AuraEnabled
    public static List<Document> getDocument(){
        return HDT_QR_DocumentalConfiguration.getDocument();
    }

    @AuraEnabled
    public static HDT_WRP_DocumentalConfiguration.HDT_WRP_DatabaseResult controllerHandler(){

        HDT_WRP_DocumentalConfiguration.HDT_WRP_DatabaseResult response;

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
            System.debug('>>> Error: ' + e.getMessage() + '; at line: [' + String.valueOf(e.getLineNumber()) + ']');
            response.success = false;
            response.message = '>>> Error: ' + e.getMessage() + '; at line: [' + String.valueOf(e.getLineNumber()) + ']';
            return response;
        }

    }

    public static HDT_WRP_DocumentalConfiguration.HDT_WRP_DatabaseResult generateJsonObject(List<DocumentalPayloadAdministration__c> docPayloadAdminList){

        Id folderId = [SELECT Id FROM Folder WHERE DeveloperName  =: 'DocumentalPayloadAdministration' LIMIT 1].Id;
        Map<String, List<DocumentalPayloadAdministration__c>> context1Map = new Map<String, List<DocumentalPayloadAdministration__c>>();
        Map<String, List<DocumentalPayloadAdministration__c>> context2Map = new Map<String, List<DocumentalPayloadAdministration__c>>();
        Map<String, List<DocumentalPayloadAdministration__c>> context3Map = new Map<String, List<DocumentalPayloadAdministration__c>>();
        Map<String, List<DocumentalPayloadAdministration__c>> context4Map = new Map<String, List<DocumentalPayloadAdministration__c>>();

        for(DocumentalPayloadAdministration__c dpa : docPayloadAdminList){

            if(dpa.Context1__c){
                if(context1Map.containsKey(dpa.Type__c)){
                    context1Map.get(dpa.Type__c).add(dpa);
                } else {
                    context1Map.put(dpa.Type__c, new List<DocumentalPayloadAdministration__c>{dpa});
                }
            }

            if(dpa.Context2__c){
                if(context2Map.containsKey(dpa.Type__c)){
                    context2Map.get(dpa.Type__c).add(dpa);
                } else {
                    context2Map.put(dpa.Type__c, new List<DocumentalPayloadAdministration__c>{dpa});
                }              
            }

            if(dpa.Context3__c){
                if(context3Map.containsKey(dpa.Type__c)){
                    context3Map.get(dpa.Type__c).add(dpa);
                } else {
                    context3Map.put(dpa.Type__c, new List<DocumentalPayloadAdministration__c>{dpa});
                }                 
            }

            if(dpa.Context4__c){
                if(context4Map.containsKey(dpa.Type__c)){
                    context4Map.get(dpa.Type__c).add(dpa);
                } else {
                    context4Map.put(dpa.Type__c, new List<DocumentalPayloadAdministration__c>{dpa});
                }              
            }

        }

        List<Document> docList = new List<Document>();
        HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalStructure doc1Structure;
        doc1Structure = convertMapToStructure(context1Map, doc1Structure);
        Document doc1 = generateDocumentObject(doc1Structure, 'Context 1', folderId);
        docList.add(doc1);
        doc1Structure = null;

        HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalStructure doc2Structure;
        doc2Structure = convertMapToStructure(context2Map, doc2Structure);
        Document doc2 = generateDocumentObject(doc2Structure, 'Context 2', folderId);
        docList.add(doc2);
        doc2Structure = null;

        HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalStructure doc3Structure;
        doc3Structure = convertMapToStructure(context3Map, doc3Structure);
        Document doc3 = generateDocumentObject(doc3Structure, 'Context 3', folderId);
        docList.add(doc3);
        doc3Structure = null;

        HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalStructure doc4Structure;
        doc4Structure = convertMapToStructure(context4Map, doc4Structure);
        Document doc4 = generateDocumentObject(doc4Structure, 'Context 4', folderId);
        docList.add(doc4);
        doc4Structure = null;

        Savepoint sp = Database.setSavepoint();
        List<Document> docToDelete = HDT_QR_DocumentalConfiguration.getDocument();

        if(docToDelete.size() > 0){
            delete docToDelete;
        }

        HDT_WRP_DocumentalConfiguration.HDT_WRP_DatabaseResult databaseResult;
        databaseResult = databaseInsert(docList, databaseResult);

        if(!databaseResult.success){
            Database.rollback(sp);
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

        databaseResult = new HDT_WRP_DocumentalConfiguration.HDT_WRP_DatabaseResult();
        databaseResult.docIdList = new List<Id>();
        databaseResult.errorData = new List<HDT_WRP_DocumentalConfiguration.HDT_WRP_LineError>();

        List<Database.SaveResult> insertResults = Database.insert(docList, false);

        for(Integer n=0; n<insertResults.size(); n++){
            Database.SaveResult sr = insertResults[n];

            if (!sr.isSuccess()) {
                // Operation failed
                String errorString = '';
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
            databaseResult.success = false;
            databaseResult.message = '>> Error during database insert';
            databaseResult.dataError = true;
            return databaseResult;
        }
     
        databaseResult.success = true;
        databaseResult.message = '>> No error during script';
        return databaseResult;
    }

}