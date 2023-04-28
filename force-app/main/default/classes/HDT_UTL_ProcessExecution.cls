@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing virtual class HDT_UTL_ProcessExecution {

    public static HDT_QR_StaticResource staticResourceQr = new HDT_QR_StaticResource();
    public static HDT_QR_AccountContactRelation accoContRelQr = new HDT_QR_AccountContactRelation();
    public static HDT_QR_Contact qrCont = new HDT_QR_Contact();
    public static HDT_QR_Order qrOrder = new HDT_QR_Order();
    public static HDT_QR_Case qrCase = new HDT_QR_Case();
    public HDT_UTL_Constants constant = new HDT_UTL_Constants();
    private static HDT_QR_MassiveLoaderProcess massiveLoaderProcessQr = new HDT_QR_MassiveLoaderProcess();
    public List<MassiveLoaderRequestItem__c> requestItemList;
    public Id requestId;
    public String processName;
    public Map<Integer, String> mapHeaderByPosition = new  Map<Integer, String>();
    public Map<String, Integer> mapHeaderForWrapper = new  Map<String, Integer>(); 
    public Map<Integer, String> mapRequiredByPosition = new  Map<Integer, String>(); 
    public Id recordTypeBus = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Business').getRecordTypeId();
    public Id recordTypeRes = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Residenziale').getRecordTypeId();
    public String splitCharacter = HDT_LC_MassiveLoader.getSplitCharacter();
    public Boolean isTest = true;
    public Boolean isDiscountAndBonusProcess = false;

    public void setRequestId(Id requestId){
        this.requestId = requestId;
        System.debug(LoggingLevel.DEBUG, '>>> set this requestId: ' + this.requestId);
    }

    public void setProcess(String processName){
        this.processName = processName;
        isDiscountAndBonusProcess = (processName.equalsIgnoreCase('TariffeSconti'));
        System.debug(LoggingLevel.DEBUG, '>>> set this process: ' + this.processName);
    }

    public void setMassiveLoaderRequestItemList(List<MassiveLoaderRequestItem__c> requestItemList){

        this.requestItemList = requestItemList;

        HDT_MassiveLoaderProcess__mdt selectedProcess = massiveLoaderProcessQr.getRecordByName(processName);
        List<StaticResource> staticResources = staticResourceQr.getRecordByName(selectedProcess.DeveloperName);
 
        mapHeaderByPosition = new Map<Integer, String>();
        Integer count = 0;
        for (String temp : staticResources.get(0).Body.toString().remove('\r').remove('\n').split(splitCharacter)) {
           if (temp.containsIgnoreCase('*')) {
                temp = temp.remove('*');
                mapRequiredByPosition.put(count,temp);
            }
            mapHeaderByPosition.put(count,temp);
            mapHeaderForWrapper.put(temp, count);
            count++;
        }

    }

    public virtual void checks(){
        System.debug(LoggingLevel.DEBUG, 'checks');
    }
    public virtual void getRecords(){
        System.debug(LoggingLevel.DEBUG, 'getRecords');
    }
    public virtual void registryCreation(){
        System.debug(LoggingLevel.DEBUG, 'registryCreation');
    }
    public virtual void makeProcess(){ // creazione processo
        System.debug(LoggingLevel.DEBUG, 'makeProcess');
    }
    public virtual void finalUpdate(){
        System.debug(LoggingLevel.DEBUG, 'finalUpdate');
    }
    public virtual void execute(){
        System.debug(LoggingLevel.DEBUG, 'execute');
        checks();
        getRecords();
        registryCreation();
        makeProcess();
        finalUpdate();

    }
   
    public virtual void manageCatchException(Integer batchSize, List<MassiveLoaderRequestItem__c> itemList, String message){
        System.debug(LoggingLevel.DEBUG, '>>> manageCatchException: ' + message);

        for(MassiveLoaderRequestItem__c mlr : itemList){
            mlr.Status__c = 'Errore';
            mlr.StatusDescription__c = message.abbreviate(250);
        }

        HDT_UTL_DatabaseService.updateSObject(itemList);

    }

    /**
    * @description :
    * @param objName 
    * @param fieldApiName 
    * @return String 
    **/
    public String getTypeField(String objName,String fieldApiName){
        String fieldTypeName = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(fieldApiName).getDescribe().getType().name().toupperCase(); 
        return fieldTypeName;
    }

    public String mapTypeField(SObject sObj, Map<String, String> mapSobjField, Integer position, String value){

        try {
            String typeField = getTypeField(String.valueOf(sObj.getSObjectType()),mapSobjField.get(mapHeaderByPosition.get(position)));
            switch on typeField.toUpperCase() {
                when 'BOOLEAN'  {
                    sObj.put(mapSobjField.get(mapHeaderByPosition.get(position)),Boolean.valueOf(value));
                }
                when 'DOUBLE'  {
                    sObj.put(mapSobjField.get(mapHeaderByPosition.get(position)),Decimal.valueOf(value));
                }
                when 'INTEGER'  {
                    sObj.put(mapSobjField.get(mapHeaderByPosition.get(position)),Integer.valueOf(value));
                }
                when 'DATETIME'  {
                    sObj.put(mapSobjField.get(mapHeaderByPosition.get(position)),Datetime.valueOf(value));
                }
                when 'DATE'  {
                    sObj.put(mapSobjField.get(mapHeaderByPosition.get(position)),Date.valueOf(value));
                }
                when else {
                    sObj.put(mapSobjField.get(mapHeaderByPosition.get(position)),value);
                }
            }
            return null;
        } catch (Exception e){
            System.debug('>>>>>>>>>>>>> ' + mapHeaderByPosition.get(position));
            //return e.getMessage() + ' - campo [' + mapSobjField.get(mapHeaderByPosition.get(position)) + ']';
            return e.getMessage() + ' - campo [' + mapHeaderByPosition.get(position) + ']';
        }
    }

    public List<HDT_MassiveFieldsObjectMap__mdt> getMapFieldsObject(String objectType, String processType){
        return [
            SELECT objectType__c, labelField__c, nameField__c 
            FROM HDT_MassiveFieldsObjectMap__mdt 
            WHERE objectType__c = :objectType
            AND processType__c = :processType
            WITH SECURITY_ENFORCED
        ];
    }

    public MassiveLoaderRequestItem__c checkRequiredFields(MassiveLoaderRequestItem__c item, List<String> tempSplitedFields){
        Integer count = 0;
        for(String field : tempSplitedFields){

            if(mapRequiredByPosition.containsKey(count) && mapRequiredByPosition.get(count) != null && String.isBlank(tempSplitedFields[count])) {
                System.debug(LoggingLevel.DEBUG, '>>> Missing Required Field');
                item.Status__c = 'Errore';
                item.StatusDescription__c = 'Missing Required Field: ' + mapHeaderByPosition.get(count);
                break;
            }
            count++;
        }
        return item;
    }

   //---------- Gestione Errore -------------
   public class HDT_WRP_ProcessEntitiesException extends Exception{
        public String Type;
        public String Message;

        public HDT_WRP_ProcessEntitiesException(String varType, String varMessage){
            this.Type = varType;
            this.message = varMessage;
        }
    }

    public static MassiveLoaderRequestItem__c setErrorItem(MassiveLoaderRequestItem__c itemError, String message){
        itemError.Status__c = 'Errore';
        itemError.StatusDescription__c = message.abbreviate(250);
        return itemError;
    }

    /*public static HDT_WRP_SaveResponse databaseUpsert(List<sObject> sObjectList, List<MassiveLoaderRequestItem__c> requetItems, String sObjectType){
        HDT_WRP_SaveResponse saveResponse = new HDT_WRP_SaveResponse();
        saveResponse.reponseItemList = new List<MassiveLoaderRequestItem__c>();
        saveResponse.savedObject = new List<sObject>();
        saveResponse.itemIdToObjId = new Map<Id, Id>();
        saveResponse.errorItemMap = new Map<Id, String>();

        SObjectType objtype = Schema.getGlobalDescribe().get(sObjectType);
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();
 
        if(objRes.isCreateable()){

            List<Database.UpsertResult> upsertResults = Database.upsert(sObjectList, false);

            for(Integer n=0; n<upsertResults.size(); n++){
                Database.UpsertResult sr = upsertResults[n];

                if(sr.isSuccess()) {
                    requetItems[n].Status__c = 'Chiuso';
                    saveResponse.reponseItemList.add(requetItems[n]);
                    saveResponse.savedObject.add(sObjectList[n]);
                    saveResponse.itemIdToObjId.put(requetItems[n].Id, sr.getId());

                } else {
                    requetItems[n].Status__c = 'Errore';

                    String errorMessage = '';
                    for(Database.Error err : sr.getErrors()) {
                        errorMessage += '[' + err.getStatusCode() + ': ' + err.getMessage() + ' on field: ' + err.getFields() + '] ';
                        System.debug(LoggingLevel.DEBUG, '>>> errorMessage ' + errorMessage);
                    }

                    requetItems[n].StatusDescription__c = errorMessage.abbreviate(250);
                    saveResponse.errorItemMap.put(requetItems[n].Id, errorMessage.abbreviate(250));
                    saveResponse.reponseItemList.add(requetItems[n]);
                    
                }
            }
        }

        return saveResponse;

    }*/

    public static HDT_WRP_SaveResponse databaseUpsertWithKey(List<sObject> sObjectList, List<MassiveLoaderRequestItem__c> requetItems, String sObjectType, String fieldUpsert){
        return databaseUpsertMethod(sObjectList, requetItems, sObjectType, fieldUpsert);
    }
    
    public static HDT_WRP_SaveResponse databaseUpsert(List<sObject> sObjectList, List<MassiveLoaderRequestItem__c> requetItems, String sObjectType){
        return databaseUpsertMethod(sObjectList, requetItems, sObjectType, null);
    }

    public static HDT_WRP_SaveResponse databaseUpsertMethod(List<sObject> sObjectList, List<MassiveLoaderRequestItem__c> requetItems, String sObjectType, String fieldUpsert){
        HDT_WRP_SaveResponse saveResponse = new HDT_WRP_SaveResponse();
        saveResponse.reponseItemList = new List<MassiveLoaderRequestItem__c>();
        saveResponse.savedObject = new List<sObject>();
        saveResponse.itemIdToObjId = new Map<Id, Id>();
        saveResponse.errorItemMap = new Map<Id, String>();

        SObjectType objtype = Schema.getGlobalDescribe().get(sObjectType);
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();
        Schema.SObjectField ftoken;
        List<Database.UpsertResult> upsertResults;

        if(objRes.isCreateable()){
            if(String.isNotBlank(fieldUpsert)){
                ftoken = objtype.getDescribe().fields.getMap().get(fieldUpsert);
                upsertResults = Database.upsert(sObjectList, ftoken, false);
            }else{
                upsertResults = Database.upsert(sObjectList, false);
            }
            
            for(Integer n=0; n<upsertResults.size(); n++){
                Database.UpsertResult sr = upsertResults[n];

                if(sr.isSuccess()) {
                    requetItems[n].Status__c = 'Chiuso';
                    saveResponse.reponseItemList.add(requetItems[n]);
                    saveResponse.savedObject.add(sObjectList[n]);
                    saveResponse.itemIdToObjId.put(requetItems[n].Id, sr.getId());

                } else {
                    requetItems[n].Status__c = 'Errore';

                    String errorMessage = '';
                    for(Database.Error err : sr.getErrors()) {
                        errorMessage += '[' + err.getStatusCode() + ': ' + err.getMessage() + ' on field: ' + err.getFields() + '] ';
                        System.debug(LoggingLevel.DEBUG, '>>> errorMessage ' + errorMessage);
                    }

                    requetItems[n].StatusDescription__c = errorMessage.abbreviate(250);
                    saveResponse.errorItemMap.put(requetItems[n].Id, errorMessage.abbreviate(250));
                    saveResponse.reponseItemList.add(requetItems[n]);
                    
                }
            }
        }

        return saveResponse;

    }

    public static void runCompatibility(List<Case> savedCase){
        Map<Id, String> compatibilityMap = checkCompatibilityPostSales(savedCase);
        System.debug(LoggingLevel.DEBUG, '>>> compatibilityMap ' + String.valueOf(compatibilityMap));
        updateCaseAfterCompatibility(compatibilityMap, savedCase);
        getLimitDetails('AFTER Compatibility');

    }
    
    private static Map<Id, String> checkCompatibilityPostSales(List<Case> csList){

        List<ServiceRequest__c> srList = new List<ServiceRequest__c>();
        List<ServiceRequest__c> srListToDelete = new List<ServiceRequest__c>();
        Map<Id, String> caseIdToCompatibility = new Map<Id, String>();

        try {
            String compatibility = '';
            Formula.recalculateFormulas(csList);
            ServiceRequest__c srvRequest;
            for(Case cs : csList){
                if(cs.Phase__c == 'Bozza Annullata')continue;
                srvRequest = new ServiceRequest__c();
                srvRequest.Case__c = cs.Id;
                srvRequest.ServicePointCode__c = cs.PODPDRFormula__c;
                srvRequest.Status__c = HDT_UTL_MatrixCompatibility.getStatus(cs.Status, 'Case');
                srvRequest.CommoditySector__c = cs.CommodityFormula__c;
                srvRequest.Type__c = 'Case';
    
                if(cs.ServicePoint__c != null){
                    srvRequest.ServicePoint__c = cs.ServicePoint__c;
                } else {
                    srvRequest.Account__c = cs.AccountId;
                    srvRequest.BillingProfile__c = cs.BillingProfile__c;
                }
    
                srvRequest.ProcessType__c = HDT_UTL_MatrixCompatibility.getProcessType(cs.Type, 'Case', cs.CommodityFormula__c);

                System.debug(LoggingLevel.DEBUG, '>>> srvRequest: ' + srvRequest);

                srList.add(srvRequest);
            }

            HDT_UTL_DatabaseService.insertSObject(srList);

            for(ServiceRequest__c sReq : srList){
                wrts_prcgvr.ObjectCompatibility_1_0.CheckResult result = HDT_UTL_MatrixCompatibility.checkCompatibility(sReq);

                System.debug(LoggingLevel.DEBUG, '>>> ObjectCompatibility: ' + result);

                //list of incompatible records
                if(!result.incompatibilities.isEmpty()){
                    compatibility = HDT_UTL_MatrixCompatibility.getIncompatibilityMessage((ServiceRequest__c[])result.incompatibilities);
                    System.debug(LoggingLevel.DEBUG, '>>> compatibilityMessage: ' + compatibility);

                    caseIdToCompatibility.put(sReq.Case__c, compatibility);
                    srListToDelete.add(sReq);
                }

            }
            
            if(srListToDelete.size() > 0){
                HDT_UTL_DatabaseService.deleteSObject(srListToDelete);
            }

            return caseIdToCompatibility;

        } catch (Exception e) {
            throw e;
        }
    }

    private static void updateCaseAfterCompatibility(Map<Id, String> incompatibleCaseIdSet, List<Case> savedCase){

        for(Case c : savedCase){
            if(c.Phase__c == 'Bozza Annullata')continue;
            if(incompatibleCaseIdSet.containsKey(c.Id)){
                c.Phase__c = 'Bozza Annullata';
                c.Status = 'Closed';
                c.CancellationReason__c = 'Processo incompatibile';
            } else {
                c.Phase__c = 'Da Inviare';
            }

            if(c.Type.equalsIgnoreCase('Modifica Tariffa Residente/Non Residente')){
                c.Phase__c = 'In Attesa Allineamento Anagrafica';
            }

        }

        HDT_UTL_DatabaseService.updateSObject(savedCase);

    }

    public static Case setCaseField(Case newCase, Id recordTypeId){
        newCase.RecordTypeId = recordTypeId;
        newCase.Status = 'In Lavorazione';
        newCase.Phase__c = 'Bozza';
        //Rimosso per W2 
        //newCase.CompanyOwner__c = 'HERA COMM';
        return newCase;
    }

    public static Map<Id, String> setCaseNumberMap(Map<Id, String> caseNumberMap, List<Id> caseIdList){
        
        List<Case> savedCaseList = [
            SELECT Id, CaseNumber
            FROM Case
            WHERE Id IN :caseIdList
            WITH SECURITY_ENFORCED
        ];

        for(Case cs : savedCaseList){
            caseNumberMap.put(cs.Id, cs.CaseNumber);
        }
        return caseNumberMap;
    }

    public static Boolean errorForPicklistValue(String objType, String fieldType, String valueToCheck){

        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(objType).getDescribe().fields.getMap().get(fieldType).getDescribe();

        if(fieldResult.getPicklistValues().size() == 0){
            return false;
        }

        for(Schema.PicklistEntry pickListVal : fieldResult.getPicklistValues()){
            if(valueToCheck.equalsIgnoreCase(pickListVal.getLabel()) && pickListVal.isActive()){
                return false;
            }
        }

        return true;

    }

    public static List<String> splitCsvRow(String csvRow){
        String unescapedString = csvRow.unescapeCsv();
        return unescapedString.split('","');
    }

    public static void getLimitDetails(String stageName){

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('StageName: ', stageName);
        gen.writeStringField('CpuTime: ', String.valueOf(Limits.getCpuTime()) + ' of ' + String.valueOf(Limits.getLimitCpuTime()));
        gen.writeStringField('DML: ', String.valueOf(Limits.getDMLStatements()) + ' of ' + String.valueOf(Limits.getLimitDMLStatements()));
        gen.writeStringField('HeapSize: ', String.valueOf(Limits.getHeapSize()) + ' of ' + String.valueOf(Limits.getLimitHeapSize()));
        gen.writeStringField('Queries: ', String.valueOf(Limits.getQueries()) + ' of ' + String.valueOf(Limits.getLimitQueries()));
        gen.writeStringField('Callouts: ', String.valueOf(Limits.getCallouts()) + ' of ' + String.valueOf(Limits.getLimitCallouts()));
        gen.writeEndObject();

        System.debug(gen.getAsString());

    }

    public class HDT_WRP_SaveResponse {
        public List<MassiveLoaderRequestItem__c> reponseItemList;
        public List<sObject> savedObject;
        public Map<Id, Id> itemIdToObjId;
        public Map<Id, String> errorItemMap;
    }

}