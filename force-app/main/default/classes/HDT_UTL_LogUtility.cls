@SuppressWarnings('PMD.CyclomaticComplexity,PMD.AvoidDebugStatements')
public with sharing class HDT_UTL_LogUtility {
    private final Set<String> STRING_FIELD = new Set<String>{'Service__c','Method__c','Request__c','Response__c','Error__c'};
    private final Set<String> DATETIME_FIELD = new Set<String>{'RequestDate__c','ResponseDate__c'};
    private final Map<String,String> FIELD_MAP = new Map<String,String>{
        'SERVICE' => 'Service__c',
        'METHOD' => 'Method__c',
        'REQUEST' => 'Request__c',
        'RESPONSE' => 'Response__c',
        'ERROR' => 'Error__c',
        'RECORD_ID' => 'RecordId__c',
        'REQUEST_DATE' => 'RequestDate__c',
        'RESPONSE_DATE' => 'ResponseDate__c'
    };

    private SObject logRecord;
    //private HDT_LogMappingRecord__mdt recordMap;
    private Map<String,String> mapFieldLog;
    private Map<String,Integer> mapFieldSize;
    private Boolean isChangeRecord;


    public HDT_UTL_LogUtility(String className) {
        this.mapFieldLog = new Map<String,String>();
        this.mapFieldSize = new Map<String,Integer>();
        this.setUtilityClass(className);
    }

    public Boolean newRecord(){
        Boolean response = false;
        this.isChangeRecord = false;
        if (!this.mapFieldLog.isEmpty()){
            try{
                this.logRecord = Schema.getGlobalDescribe().get(this.mapFieldLog.get('OBJECT')).newSObject();
                response = true;
            }catch(Exception ex){
                System.debug(LoggingLevel.ERROR, 'HDT_UTL_LogUtility - newRecord: ' + ex.getMessage());
                response = false;
            }
        }
        return response;
    }

    

    //Object__c,Service__c, Method__c, Request__c, Error__c, RecordId__c
    public HDT_UTL_LogUtility setService(String service){
        this.setField(service, this.mapFieldLog.get('SERVICE'), this.mapFieldSize.get('SERVICE'));
        return this;
    }

    public HDT_UTL_LogUtility setMethod(String method){
        this.setField(method, this.mapFieldLog.get('METHOD'), this.mapFieldSize.get('METHOD'));
        return this;
    }

    public HDT_UTL_LogUtility setRequest(String request){
        this.setField(request, this.mapFieldLog.get('REQUEST'), this.mapFieldSize.get('REQUEST'));
        return this;
    }

    public HDT_UTL_LogUtility setResponse(String response){
        this.setField(response, this.mapFieldLog.get('RESPONSE'), this.mapFieldSize.get('RESPONSE'));
        return this;
    }

    public HDT_UTL_LogUtility setError(String error){
        this.setField(error, this.mapFieldLog.get('ERROR'), this.mapFieldSize.get('ERROR'));
        return this;
    }

    public HDT_UTL_LogUtility setRecordId(String recordId){
        if (recordId == null || !(recordId instanceof Id) || this.logRecord == null || !this.mapFieldLog.containsKey('RECORD_ID')){
            return this;
        }
        try{
            if (this.mapFieldSize.get('RECORD_ID') > 0){
                this.setField((String)recordId, this.mapFieldLog.get('RECORD_ID'), this.mapFieldSize.get('RECORD_ID'));
            }else{
                this.logRecord.put(this.mapFieldLog.get('RECORD_ID'),recordId);
            }
            this.isChangeRecord = true;
        }catch(Exception ex){
            System.debug(LoggingLevel.ERROR, 'HDT_UTL_LogUtility - setRecordId: ' + ex.getMessage());
        }
        return this;
    }

    public HDT_UTL_LogUtility setRequestDate(Datetime requestDate){
        if (requestDate == null || !this.mapFieldLog.containsKey('REQUEST_DATE')){
            return this;
        }
        try{
            this.logRecord.put(this.mapFieldLog.get('REQUEST_DATE'),requestDate);
            this.isChangeRecord = true;
        }catch(Exception ex){
            System.debug(LoggingLevel.ERROR, 'HDT_UTL_LogUtility - setRequestDate: ' + ex.getMessage());
        }
        return this;
    }

    public HDT_UTL_LogUtility setResponseDate(Datetime responseDate){
        if (responseDate == null || !this.mapFieldLog.containsKey('RESPONSE_DATE')){
            return this;
        }
        try{
            this.logRecord.put(this.mapFieldLog.get('RESPONSE_DATE'),responseDate);
            this.isChangeRecord = true;
        }catch(Exception ex){
            System.debug(LoggingLevel.ERROR, 'HDT_UTL_LogUtility - setResponseDate: ' + ex.getMessage());
        }
        return this;
    }

    public Sobject workRecord(Boolean doInsert){
        if (doInsert && this.logRecord != null && this.isChangeRecord){
            HDT_UTL_DatabaseService.upsertSObject(this.logRecord);
        }
        return this.isChangeRecord? this.logRecord : null;
    }

    private void setField(String value, String field, Integer size){
        if (this.logRecord == null || String.isBlank(field) || String.isBlank(value)){
            return;
        }
        try{
            if (value.length() > size){
                value = value.substring(0,size);
            }
            this.logRecord.put(field,value);
            this.isChangeRecord = true;
        }catch(Exception ex){
            System.debug(LoggingLevel.ERROR, 'HDT_UTL_LogUtility - setField: ' + ex.getMessage());
        }
        
    }
    
    private void setUtilityClass(string configName){
        HDT_LogMappingRecord__mdt recordMap = HDT_LogMappingRecord__mdt.getInstance(configName);
        if (test.isRunningTest()){
            recordMap = HDT_SRV_LogServiceTst.getTestConfig(configName);
        }
        if (recordMap == null || !recordMap.IsActive__c || String.isBlank(recordMap.Object__c)){
            return;
        }

        this.mapFieldLog.put('OBJECT',recordMap.Object__c);
        String objectName = recordMap.Object__c;
        Map<String,Schema.SObjectField> objectLogFieldsMap;
        try{
            objectLogFieldsMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        }catch(Exception ex){
            System.debug(LoggingLevel.ERROR, 'HDT_UTL_LogUtility - setUtilityClass: ' + ex.getMessage());
            return;
        }
        for (String key : this.FIELD_MAP.keySet()){
            String field = this.FIELD_MAP.get(key);
            if (recordMap.get(field) != null){
                try{
                    String objectFieldApiName = (string)recordMap.get(field);
                    Schema.DescribeFieldResult objectLogField = objectLogFieldsMap.get(objectFieldApiName).getDescribe();
                    if (this.STRING_FIELD.contains(field) && (objectLogField.getType() == Schema.DisplayType.STRING || objectLogField.getType() == Schema.DisplayType.TEXTAREA || objectLogField.getType() == Schema.DisplayType.PICKLIST)){
                        this.mapFieldLog.put(key,objectFieldApiName);
                        this.mapFieldSize.put(key,objectLogField.getLength());
                        continue;
                    }
                    if ((this.DATETIME_FIELD.contains(field) && objectLogField.getType() == Schema.DisplayType.DATETIME)
                    ||('RecordId__c'.equalsIgnoreCase(field) && (objectLogField.getType() == Schema.DisplayType.STRING || objectLogField.getType() == Schema.DisplayType.ID))){
                        this.mapFieldLog.put(key,objectFieldApiName);
                        this.mapFieldSize.put(key,(objectLogField.getType() == Schema.DisplayType.STRING)? objectLogField.getLength() : -1);
                        continue;
                    }
                }catch(Exception ex){
                    System.debug(LoggingLevel.ERROR, 'HDT_UTL_LogUtility - setUtilityClass: ' + ex.getMessage());
                }
                
            }   
        }
        this.newRecord();
    }
}
