@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_LC_GenericTable {

    public static List<List<SObject>> rowData { get; set; }
    
    @SuppressWarnings('PMD.CyclomaticComplexity')
    @AuraEnabled
    public static String getData(String tableName, String searchKey, String searchTerm){
        
        //VariableDeclaration
        HDT_QR_GenericTable tableQr = new HDT_QR_GenericTable();

        List<HDT_WRP_Columns> columns = new List<HDT_WRP_Columns>();

        HDT_WRP_Mapping mappings = new HDT_WRP_Mapping();
        HDT_WRP_Ouput output = new HDT_WRP_Ouput();
    
        HDT_GenericTable__mdt tableConfig = new HDT_GenericTable__mdt();

        rowData = new List<List<SObject>>();

        List<Map<String,Object>> dataMap = new List<Map<String,Object>>();
        List<String> queryList = new List<String>();
        List<String> objList = new List<String>();
        List<String> columnList = new List<String>();

        /*
            @Author: Davide Viola - 19/10/2021
            Description: PMD -> Commentata variabile non utilizzata.
        */
        //Integer count = 0;
        Integer fieldCount = 0;

        //Actions
        tableConfig = tableQr.getTableConfiguration(tableName);
        mappings = (HDT_WRP_Mapping) JSON.deserialize(tableConfig.Mapping__c, HDT_WRP_Mapping.class);

        /*Create Queries */
        for(HDT_WRP_Object singleObj : mappings.objects){
            String query = 'Select ';
            fieldCount = 0;
            for(HDT_WRP_Fields field : singleObj.fields){
                ++fieldCount;
                if(!(columnList.contains(field.columnName))){
                    if(field.columnName != null){
                        columns.add(new HDT_WRP_Columns(field.columnName,field.columnName));
                        columnList.add(field.columnName);
                    }
                }
                if(fieldCount == singleObj.fields.size()){
                    query += field.apiName + ' ';
                }else{
                    query += field.apiName + ', ';
                }
            }
            query += 'From ' + singleObj.obj + ' ';
            if((searchKey!=null && searchKey != '') && (searchTerm != null && searchKey != null) && (singleObj.whereCond != null && singleObj.whereCond != '')){
                System.debug(LoggingLevel.DEBUG, 'singleObj.whereCond: ' + singleObj.whereCond);      
                query+='WHERE ' + searchKey + '= \'' + searchTerm + '\' AND ' + singleObj.whereCond + ' ';      
            }
            query += 'WITH SECURITY_ENFORCED';
            queryList.add(query);
            objList.add(singleObj.obj);
        }
        /*Execute Recursive Queries */
        System.debug(LoggingLevel.DEBUG, 'QueryList-> ' +queryList);
        System.debug(LoggingLevel.DEBUG, 'ObjList -> ' +objList);
        doRecursion(queryList, objList);
        System.debug(LoggingLevel.DEBUG, 'Data -> ' + rowData);
        /*Create Data Map*/
        for(List<SObject> sobjList : rowData){
            if(sobjList != null){
                for(SObject sobj : sobjList){
                    Map<String,Object> singleMap = new Map<String,Object>();
                    for(HDT_WRP_Object singleObj : mappings.objects){
                       if(singleObj.obj == sobj.getSObjectType().getDescribe().getName()){
                           singleMap.put('_id', sobj.get('Id'));
                           singleMap.put('_objName', sobj.getSObjectType().getDescribe().getName());
                           for(HDT_WRP_Fields field : singleObj.fields){
                               if(sobj.get(field.apiName) != null && sobj.get(field.apiName) != ''){
                                    singleMap.put(field.columnName, sobj.get(field.apiName));
                               }
                           }
                       }
                   }
                   if(singleMap != null && !(singleMap.isEmpty())){
                        dataMap.add(singleMap);
                   } 
                }
            }
        }
        System.debug(LoggingLevel.DEBUG, 'dataMap: ' + dataMap);
        System.debug(LoggingLevel.DEBUG, 'columns: ' + columns);
        System.debug(LoggingLevel.DEBUG, 'columns size: ' + columns.size());
        output.columns = columns;
        output.rowData = dataMap;
        System.debug(LoggingLevel.DEBUG, 'output: ' + output);
        // for(List<SObject> sObjList : rowData){
        //     if(sObjList != null){
        //         Map<String, Object> objMap = sObjList[0].getSObjectType().getDescribe().fields.getMap();
        //         Map<String, Object> singleObjMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(sObjList[0]));
        //         for(String key : singleObjMap.keySet()){
        //             Schema.sObjectField fieldObj= (Schema.sObjectField) objMap.get(key);
        //             if(fieldObj != null){
        //                 Schema.DescribeFieldResult fieldRes = fieldObj.getDescribe();
        //                 System.debug(LoggingLevel.DEBUG, 'Label: ' + fieldRes.getLabel());
        //                 System.debug(LoggingLevel.DEBUG, 'Value: ' + singleObjMap.get(key));
        //                 System.debug(LoggingLevel.DEBUG, 'Type: '  + String.valueOf(fieldRes.getType()));
        //                 //Customizations
        //             }
        //         } 
        //     }
        // }

        return JSON.serialize(output);
    }

    private static void doRecursion(List<String> queryList, List<String> objList){
        List<SObject> queryObj = new List<SObject>();
        if(queryList.size() > 0){
            queryObj = null;
            SObjectType objType = Schema.getGlobalDescribe().get(objList[(queryList.size()-1)]);
            Schema.DescribeSObjectResult objRes = objType.getDescribe();
            if(objRes.isAccessible()){
                queryObj = Database.query(queryList[(queryList.size()-1)]);
                System.debug(LoggingLevel.DEBUG, 'queryObj: ' + queryObj);
                rowData.add(queryObj);
            }
            queryList.remove((queryList.size()-1));
            doRecursion(queryList, objList);
        } else {
            return;
        }
    }

    public class HDT_WRP_Columns{
        public String label;
        public String fieldName;
        public HDT_WRP_Columns(String fieldName, String label){
            this.fieldName = fieldName;
            this.label = label;
        }
    }
    public class HDT_WRP_Mapping{
        List<HDT_WRP_Object> objects;
    }
    public class HDT_WRP_Object{
        public String obj;
        List<HDT_WRP_Fields> fields;
        public String whereCond;
    }
    public class HDT_WRP_Fields{
        public String columnName;
        public String apiName;
    }
    public class HDT_WRP_Ouput{
        public List<HDT_WRP_Columns> columns;
        public List<Map<String,Object>> rowData;
    }

}