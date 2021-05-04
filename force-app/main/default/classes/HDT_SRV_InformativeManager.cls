public with sharing class HDT_SRV_InformativeManager implements HDT_UTL_ComboboxOptionsInterface {
    public String getOptions(String params) {
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
        String result;
        String context = (String) paramsMap.get('context');
        String sObjName;
        if(context instanceOf Id){

            Id contextId= (Id) Context;

            context = contextId.getSObjectType().getDescribe().getName();

        }
        List<HDT_ClusterProcess__mdt> clusterList =  HDT_QR_InformativeManager.getClusterProcess(context);
        return JSON.serialize(convertToListMap(distinctRecords(clusterList,'Cluster__c'),'Cluster__c'));
    }
    private String getProcess(Map<String, Object> paramsMap){
        String result;
        String process = HDT_QR_InformativeManager.getProcessByCluster((String) paramsMap.get('cluster'));
        return process;
    }
    private String getTopic(Map<String, Object> paramsMap){
        String result;
        String context = (String) paramsMap.get('context');
        String sObjName;
        if(context instanceOf Id){

            Id contextId= (Id) Context;

            context = contextId.getSObjectType().getDescribe().getName();

        }
        List<HDT_Informative_Configuration__mdt> topic = HDT_QR_InformativeManager.getTopicByCluster((String) paramsMap.get('cluster'),context);
        return JSON.serialize(convertToListMap(distinctRecords(topic,'MacroTopic__c'),'MacroTopic__c'));
    }
    private String getInfo(Map<String, Object> paramsMap){
        String result;
        String context = (String) paramsMap.get('context');
        String sObjName;
        if(context instanceOf Id){

            Id contextId= (Id) Context;

            context = contextId.getSObjectType().getDescribe().getName();

        }
        List<HDT_Informative_Configuration__mdt> topic = HDT_QR_InformativeManager.getInfoByTopicCluster((String) paramsMap.get('topic'),(String) paramsMap.get('cluster'),context);
        return JSON.serialize(convertToListMap(topic,'InformationDetail__c'));
    }
   
    private List<Map<String,String>> convertToListMap(List<SObject> records,String field){
        Map<String,String> resultMap = new Map<String,String>();
        List<Map<String,String>> resultList = new List<Map<String,String>>();
        for(SObject singleRecord : records){
            resultMap.put('label', (String) singleRecord.get(field));
            resultMap.put('value', (String) singleRecord.get(field));
            resultList.add(new Map<String,String>(resultMap));
        }
        return resultList;
    }
    private List<SObject> distinctRecords(List<SObject> records,String field){
        Set<String> setValue = new Set<String>();
        List<SObject> distinctRecords = new List<SObject>();
        Map<String,String> mapRecords = new Map<String,String>();
        for(SObject singleRecord : records){
            System.debug('field ' +(String)singleRecord.get(field) );
            System.debug('mappa ' + mapRecords.get((String)singleRecord.get(field)));
            System.debug('mappa intera ' + mapRecords);
            if(mapRecords.get((String)singleRecord.get(field)) != null){
                //go next
            }
            else{
                distinctRecords.add(singleRecord);
                mapRecords.put((String)singleRecord.get(field), (String)singleRecord.get(field));
            }
        }
        return distinctRecords;
    }
}