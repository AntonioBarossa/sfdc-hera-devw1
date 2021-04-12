public inherited sharing class HDT_SRV_GenerateJsonSAP {

    public static String generateJSON(String requestType, Id recordId){
        String body = '';
        try {
            List<sObject> configSettings = getConfiguration(requestType);
            body = createBody(configSettings[0], recordId);
        } catch (Exception ex) {
            throw ex;
        }
        return body;
    }

    private static List<SObject> getConfiguration(String requestType){
        HDT_QR_GenerateJsonSAP queryClass = new HDT_QR_GenerateJsonSAP();
        String fields = 'Id, DeveloperName, JSON__c';
        String objectName = 'HDT_SapWsConfiguration__mdt';
        String conditions = 'DeveloperName = \''+ requestType + '\'';
        return queryClass.getGenericRecords(fields, objectName, conditions);
    }

    private static String createBody(sObject configSetting, Id recordId){
        String body = '';
        try {
            HDT_WRP_SetupParameter setupParameters  = getSetup((String) configSetting.get('JSON__c'));
            system.debug('setupParameters ' + setupParameters);
            HDT_WRP_QueryParameter queryParameters = getQuery(setupParameters, recordId);
            system.debug('queryParameters ' + queryParameters);
            Map<String,List<SObject>> records = getGenericRecords(queryParameters);
            system.debug('records ' + records);
            body = mapBodyValue(records, (String) configSetting.get('JSON__c'));
        } catch (Exception ex) {
            throw ex;
        }
        return body;
    }

    private static HDT_WRP_SetupParameter getSetup(String stringStructure){
        HDT_WRP_SetupParameter setupParameters = new HDT_WRP_SetupParameter();
        try{
            if(stringStructure != null && String.isNotBlank(stringStructure)){
                HDT_WRP_GenerateJsonSAP.HDT_WRP_SAPRequest jsonStructure = (HDT_WRP_GenerateJsonSAP.HDT_WRP_SAPRequest) JSON.deserialize(stringStructure, HDT_WRP_GenerateJsonSAP.HDT_WRP_SAPRequest.Class);
                String parentObject = jsonStructure.objects[0].objectName;
                String[] parentFieldsArray = new List<String>();
                for(HDT_WRP_GenerateJsonSAP.HDT_WRP_SAPFields singleField : jsonStructure.objects[0].fields){
                    parentFieldsArray.add(singleField.apiName);
                }
                String parentFields = String.join(parentFieldsArray, ',');
                setupParameters.objectName = parentObject;
                setupParameters.fields = parentFields;
                List<HDT_WRP_SetupParameter> childParametersList = new List<HDT_WRP_SetupParameter>();
                for(HDT_WRP_GenerateJsonSAP.HDT_WRP_SAPChildObjects child : jsonStructure.objects[0].childObjects){
                    HDT_WRP_SetupParameter childParameters = new HDT_WRP_SetupParameter();
                    String childObject = child.objectName;
                    String childRelation = child.relationName;
                    String childStaticConditions = child.staticCondition;
                    String childControllingField = child.controllingField;
                    String[] childFieldsArray = new List<String>();
                    for(HDT_WRP_GenerateJsonSAP.HDT_WRP_SAPFields singleChildField : child.fields){
                        childFieldsArray.add(singleChildField.apiName);
                    }
                    String childFields = String.join(childFieldsArray, ',');
                    childParameters.objectName = childObject;
                    childParameters.relationName = childRelation;
                    childParameters.fields = childFields;
                    childParameters.staticConditions = childStaticConditions;
                    childParameters.controllingField = childControllingField;
                    childParametersList.add(new HDT_WRP_SetupParameter(childParameters));
                }
                setupParameters.childs = childParametersList;
                
            }
            system.debug('setupParameters ' + setupParameters);
        }catch(Exception ex){
            throw ex;
        }
        return setupParameters;
    }

    private static HDT_WRP_QueryParameter getQuery(HDT_WRP_SetupParameter setupParameters, Id recordId){
        HDT_WRP_QueryParameter queryParameters = new HDT_WRP_QueryParameter();
        List<HDT_WRP_QueryParameter> childs = new List<HDT_WRP_QueryParameter>();
        try {
            String[] nestedQueryArray = new List<String>();
            String nestedQuery = '';
            for(HDT_WRP_SetupParameter singleElement : setupParameters.childs) {
                HDT_WRP_QueryParameter child = new HDT_WRP_QueryParameter();
                child.fields = singleElement.fields;
                child.objectName = singleElement.objectName;
                String conditions = singleElement.controllingField + ' = \''+recordId + '\'';
                if(singleElement.staticConditions != null && String.isNotBlank(singleElement.staticConditions)){
                    conditions += ' AND ' + singleElement.staticConditions;
                }
                child.conditions = conditions;
                child.relationName = singleElement.relationName;
                childs.add(new HDT_WRP_QueryParameter(child));
            }
            queryParameters.childs = childs;
            queryParameters.fields = setupParameters.fields;
            queryParameters.objectName = setupParameters.objectName;
            queryParameters.conditions = 'Id = \'' + recordId + '\'';
        } catch (Exception ex) {
            throw ex;
        }
        return queryParameters;
    }
    private static Map<String,List<SObject>> getGenericRecords(HDT_WRP_QueryParameter queryParameters){
        Map<String,List<SObject>> recordMap = new Map<String,List<SObject>>();
        HDT_QR_GenerateJsonSAP queryClass = new HDT_QR_GenerateJsonSAP();
        try {
            List<SObject> records = queryClass.getGenericRecords(queryParameters.fields, queryParameters.objectName, queryParameters.conditions);
            recordMap.put('parent', records);
            for(HDT_WRP_QueryParameter child : queryParameters.childs){
                recordMap.put(child.relationName, queryClass.getGenericRecords(child.fields, child.objectName, child.conditions));
            }
        } catch (Exception ex) {
            throw ex;
        }
        return recordMap;
    }
    private static String mapBodyValue(Map<String,List<SObject>> records, String stringStructure){
        String body = '';
        Map<String,Object> bodyMap = new Map<String,Object>();
        try {
            if(stringStructure != null && String.isNotBlank(stringStructure)){
                HDT_WRP_GenerateJsonSAP.HDT_WRP_SAPRequest jsonStructure = (HDT_WRP_GenerateJsonSAP.HDT_WRP_SAPRequest) JSON.deserialize(stringStructure, HDT_WRP_GenerateJsonSAP.HDT_WRP_SAPRequest.Class);
                SObject parentRecord = records.get('parent')[0];
                for(HDT_WRP_GenerateJsonSAP.HDT_WRP_SAPFields field : jsonStructure.objects[0].fields){
                    bodyMap.put(field.label, parentRecord.get(field.apiName));
                }
                List<Object> listChild = new List<Object>();
                for(HDT_WRP_GenerateJsonSAP.HDT_WRP_SAPChildObjects singleChild : jsonStructure.objects[0].childObjects){
                    List<SObject> childrecords = records.get(singleChild.relationName);
                    Map<String,Object> child = new Map<String,Object>();
                    listChild = new List<Object>();
                    for(SObject singleChildRecord : childrecords){
                        for(HDT_WRP_GenerateJsonSAP.HDT_WRP_SAPFields fieldChild : singleChild.fields){
                            child.put(fieldChild.label, singleChildRecord.get(fieldChild.apiName));
                        }
                        listChild.add(new Map<String,Object>(child));
                    }
                    
                    bodyMap.put(singleChild.relationName, listChild);
                }
            }
        } catch (Exception ex) {
            throw ex;
        }
        System.debug(JSON.serialize(bodyMap));
        return JSON.serialize(bodyMap);
    }

    private class HDT_WRP_SetupParameter{
        public String objectName{get;set;}
        public String fields{get;set;}
        public String staticConditions{get;set;}
        public String relationName{get;set;}
        public String controllingField{get;set;}
        public List<HDT_WRP_SetupParameter> childs;

        public HDT_WRP_SetupParameter(HDT_WRP_SetupParameter item){
            this.objectName = item.objectName;
            this.fields = item.fields;
            this.staticConditions = item.staticConditions;
            this.relationName = item.relationName;
            this.controllingField = item.controllingField;
            this.childs = item.childs;
        }
        public HDT_WRP_SetupParameter(){}

    }

    private class HDT_WRP_QueryParameter{
        public String fields;
        public String objectName;
        public String conditions;
        public String relationName;
        public List<HDT_WRP_QueryParameter> childs;

        public HDT_WRP_QueryParameter(){}
        public HDT_WRP_QueryParameter(HDT_WRP_QueryParameter item){
            this.fields = item.fields;
            this.objectName = item.objectName;
            this.conditions = item.conditions;
            this.relationName = item.relationName;
            this.childs = item.childs;

        }
    }
}