public inherited sharing class HDT_LC_GenericTable {

    public static List<List<SObject>> rowData { get; set; }
    
    @AuraEnabled
    public static string getData(String inputs, String tableName, String searchKey, String searchTerm){
        
        //Conviene fare una SOSL dato che in generale si avranno record diversi
        //La SOSL va fatta con un testo chiave sicuramente comune a tutti (ad esempio AccountId)
        
        //VariableDeclaration
        HDT_QR_GenericTable tableQr = new HDT_QR_GenericTable();

        HDT_WRP_Mapping mappings = new HDT_WRP_Mapping();
        HDT_GenericTable__mdt tableConfig = new HDT_GenericTable__mdt();

        rowData = new List<List<SObject>>();

        List<String> queryList = new List<String>();
        List<String> objList = new List<String>();

        Integer count = 0;
        Integer fieldCount = 0;
        

        //wrap inputs in wrapper Obj

        //HDT_WRP_Columns columns = (HDT_WRP_Columns) JSON.deserialize(inputs, HDT_WRP_Columns.class);

        tableConfig = tableQr.getTableConfiguration(tableName);
        mappings = (HDT_WRP_Mapping) JSON.deserialize(tableConfig.Mapping__c, HDT_WRP_Mapping.class);

        for(HDT_WRP_Object singleObj : mappings.objects){
            String query = 'Select ';
            fieldCount = 0;
            for(HDT_WRP_Fields field : singleObj.fields){
                ++fieldCount;
                if(fieldCount == singleObj.fields.size()){
                    query += field.apiName + ' ';
                }else{
                    query += field.apiName + ', ';
                }
            }
            query += 'From ' + singleObj.obj + ' ';
            if((searchKey!=null && searchKey != '') && (searchTerm != null && searchKey != null) && (singleObj.whereCond != null && singleObj.whereCond != '')){
                System.debug(singleObj.whereCond);      
                query+='WHERE ' + searchKey + '= \'' + searchTerm + '\' AND ' + singleObj.whereCond + ' ';      
            }
            query += 'WITH SECURITY_ENFORCED';
            queryList.add(query);
            objList.add(singleObj.obj);
        }
        System.debug('QueryList-> ' +queryList);
        System.debug('ObjList -> ' +objList);
        doRecursion(queryList, objList);
        System.debug('Data -> ' + rowData);
        /*try {
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }*/
        return 'Ok';
    }

    private static void doRecursion(List<String> queryList, List<String> objList){
        List<SObject> queryObj = new List<SObject>();
        if(queryList.size() > 0){
            queryObj = null;
            SObjectType objType = Schema.getGlobalDescribe().get(objList[(queryList.size()-1)]);
            Schema.DescribeSObjectResult objRes = objType.getDescribe();
            if(objRes.isAccessible()){
                queryObj = Database.query(queryList[(queryList.size()-1)]);
                System.debug(queryObj);
                rowData.add(queryObj);
            }
            queryList.remove((queryList.size()-1));
            doRecursion(queryList, objList);
        } else {
            return;
        }
    }

    /*public class HDT_WRP_Columns{
        public String label;
        public String name;
        public String type;
    }*/
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


}
