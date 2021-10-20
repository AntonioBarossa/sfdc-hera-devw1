@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_SRV_InformativeManager implements HDT_UTL_ComboboxOptionsInterface {
    public String getOptions(String params) {
        
        System.debug(LoggingLevel.DEBUG, 'getOptions - params: ' + params);
        
        Map<String, Object> paramsMap = (Map<String, Object>) JSON.deserializeUntyped(params);
        String method = (String) paramsMap.get('method');

        switch on method {
            when 'cluster' {
                return getCluster(paramsMap);
            }
            when 'topic' {
                return getTopic(paramsMap);
            }
            when 'process'{
                return getProcess(paramsMap);
            }
            when 'info'{
                return getInfo(paramsMap);
            }
            when else {
                return null;
            }
        }
    }

    private String getCluster(Map<String, Object> paramsMap){
        
        System.debug(LoggingLevel.DEBUG, 'getOptions - getCluster: ' + paramsMap);
        
        String context = (String) paramsMap.get('context');
        
        if(context instanceOf Id){
            Id contextId = (Id) Context;
            context = contextId.getSObjectType().getDescribe().getName();
        }
        
        System.debug(LoggingLevel.DEBUG, 'getCluster - context: ' + context);
        List<HDT_Informative_Configuration__mdt> clusterList =  HDT_QR_InformativeManager.getClusterProcess(context);
        return JSON.serialize(convertToListMap(distinctRecords(clusterList,'Cluster__c'),'Cluster__c'));
    }
    
    private String getTopic(Map<String, Object> paramsMap){
        
        System.debug(LoggingLevel.DEBUG, 'getOptions - getTopic: ' + paramsMap);
        
        String context = (String) paramsMap.get('context');
        
        if(context instanceOf Id){
            Id contextId = (Id) Context;
            context = contextId.getSObjectType().getDescribe().getName();
        }
        
        System.debug(LoggingLevel.DEBUG, 'getTopic - context: ' + context);
        List<HDT_Informative_Configuration__mdt> topic = HDT_QR_InformativeManager.getTopicByCluster((String) paramsMap.get('cluster'),context);
        return JSON.serialize(convertToListMap(distinctRecords(topic,'MacroTopic__c'),'MacroTopic__c'));
    }
    
    private String getProcess(Map<String, Object> paramsMap){
        
        System.debug(LoggingLevel.DEBUG, 'getOptions - getProcess: ' + paramsMap);
        
        String process = HDT_QR_InformativeManager.getProcessByCluster((String) paramsMap.get('cluster'));
        
        return process;
    }
    
    private String getInfo(Map<String, Object> paramsMap){
        
        System.debug(LoggingLevel.DEBUG, 'getOptions - getInfo: ' + paramsMap);
        
        String context = (String) paramsMap.get('context');
        
        if(context instanceOf Id){
            Id contextId = (Id) Context;
            context = contextId.getSObjectType().getDescribe().getName();
        }
        
        System.debug(LoggingLevel.DEBUG, 'getInfo - context: ' + context);
        
        String myTopic = (String) paramsMap.get('topic');
        System.debug(LoggingLevel.DEBUG, 'getInfo - myTopic: ' + myTopic);
        
        String myCluster = (String) paramsMap.get('cluster');
        System.debug(LoggingLevel.DEBUG, 'getInfo - myCluster: ' + myCluster);
        
        List<HDT_Informative_Configuration__mdt> topic = HDT_QR_InformativeManager.getInfoByTopicCluster(myTopic, myCluster, context);
        List<Map<String,String>> listMapInfo = convertToListMap(topic,'InformationDetail__c');
        
        Map<String,String> mapInfo = new Map<String,String>();
        mapInfo.put('label','Info non Censita');
        mapInfo.put('value','Info non Censita');
        listMapInfo.add(mapInfo);
        return JSON.serialize(listMapInfo);
    }
   
    private List<Map<String,String>> convertToListMap(List<SObject> records, String field){
        
        System.debug(LoggingLevel.DEBUG, 'convertToListMap - records: ' + records);
        System.debug(LoggingLevel.DEBUG, 'convertToListMap - field: ' + field);
        
        Map<String,String> resultMap = new Map<String,String>();
        List<Map<String,String>> resultList = new List<Map<String,String>>();
        
        for(SObject singleRecord : records){
            resultMap.put('label', (String) singleRecord.get(field));
            resultMap.put('value', (String) singleRecord.get(field));
            resultList.add(new Map<String,String>(resultMap));
        }
        
        return resultList;
    }
    
    private List<SObject> distinctRecords(List<SObject> records, String field){
        System.debug(LoggingLevel.DEBUG, 'distinctRecords - records: ' + records);
        System.debug(LoggingLevel.DEBUG, 'distinctRecords - field: ' + field);
        
        List<SObject> distinctRecords = new List<SObject>();
        Map<String,String> mapRecords = new Map<String,String>();
        
        for(SObject singleRecord : records){
            System.debug(LoggingLevel.DEBUG, 'field ' +(String)singleRecord.get(field) );
            System.debug(LoggingLevel.DEBUG, 'mappa ' + mapRecords.get((String)singleRecord.get(field)));
            System.debug(LoggingLevel.DEBUG, 'mappa intera ' + mapRecords);
            if(mapRecords.get((String)singleRecord.get(field)) == null){
                distinctRecords.add(singleRecord);
                mapRecords.put((String)singleRecord.get(field), (String)singleRecord.get(field));
            }
        }
        
        return distinctRecords;
    }
    
}