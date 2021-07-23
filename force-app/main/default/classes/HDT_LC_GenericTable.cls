public inherited sharing class HDT_LC_GenericTable {
    
    @AuraEnabled
    public static string getData(String inputs, String tableName, String searchKey){
        
        //Conviene fare una SOSL dato che in generale si avranno record diversi
        //La SOSL va fatta con un testo chiave sicuramente comune a tutti (ad esempio AccountId)
        
        //VariableDeclaration
        HDT_QR_GenericTable tableQr = new HDT_QR_GenericTable();

        HDT_WRP_Mapping mappings = new HDT_WRP_Mapping();
        HDT_GenericTable__mdt tableConfig = new HDT_GenericTable__mdt();

        String serializedString = '';
        String query = 'FIND \''+ String.escapeSingleQuotes(searchKey) + '\' IN ALL FIELDS RETURNING ';

        Integer count = 0;
        Integer fieldCount = 0;
        

        //wrap inputs in wrapper Obj

        //HDT_WRP_Columns columns = (HDT_WRP_Columns) JSON.deserialize(inputs, HDT_WRP_Columns.class);

        tableConfig = tableQr.getTableConfiguration(tableName);
        mappings = (HDT_WRP_Mapping) JSON.deserialize(tableConfig.Mapping__c, HDT_WRP_Mapping.class);

        for(HDT_WRP_Object singleObj : mappings.objects){
            ++count;
            fieldCount = 0;
            query += singleObj.obj +'(';
            for(HDT_WRP_Fields field : singleObj.fields){
                ++fieldCount;
                if(fieldCount == singleObj.fields.size()){
                    query += field.apiName;
                } else {
                    query += field.apiName + ',';
                }
            }
            if(count == mappings.objects.size()){
                query += ')';
            } else {
                query += '), ';
            }
        }

        System.debug(query);
        /*try {
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }*/
        return 'Ok';
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
    }
    public class HDT_WRP_Fields{
        public String columnName;
        public String apiName;
    }


}
