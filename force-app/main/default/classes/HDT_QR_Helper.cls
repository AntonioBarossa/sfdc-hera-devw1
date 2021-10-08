/**
 * @author            : ECapozzo
 * @description       : 
 * @last modified on  : 09-09-2021
**/
public without sharing class HDT_QR_Helper {
    @TestVisible private String typeObject;
    @TestVisible private List<String> listNestedFields=new List<String>();
    @TestVisible private List<String> blackListFields=new List<String>();
    @TestVisible private String sFilter;

    /**
    * @description: Inserisce l'oggetto Salesforce per il quale si vuole effettuare la query
    * @author ECapozzo | 09-09-2021 
    * @param obj 
    **/
    public void setObj(String obj){
        System.debug('HDT_QR_Generic.setObj');
        this.typeObject=obj;
    }

    /**
    * @description: Inserisce la lista di campi innestati da aggiungere alla query 
    * @author ECapozzo | 09-09-2021 
    * @param nestedFields 
    **/
    public void setNestedFields(List<String> nestedFields){
        System.debug('HDT_QR_Generic.setNestedFields');
        this.listNestedFields=nestedFields;
    }
    /**
    * @description: Inserisce la lista di campi da escludere dalla query
    * @author ECapozzo | 09-09-2021 
    * @param listFields 
    **/
    public void setBlackListFields(List<String> listFields){
        System.debug('HDT_QR_Generic.blackListFields');
        this.blackListFields=listFields;
    }
    /**
    * @description: Inserisce i criteri per filtrare la query
    * @author ECapozzo | 09-09-2021 
    * @param filter 
    **/
    public void setFilter(String filter){
        System.debug('HDT_QR_Generic.setNestedFields');
        this.sFilter=filter;
    }

    public String getAllObjectFields(){
        System.debug('HDT_QR_Generic.getAllObjectFields');
        if (String.isBlank(typeObject)) {
            throw new HDT_WRP_HelperException( 'NullPointerException',' typeObject can\'t be null ' );
        }
        String filds;
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objSchema = schemaMap.get(typeObject);
        Map<String, Schema.SObjectField> fieldMap = objSchema.getDescribe().fields.getMap();
        List<String> listBlack = new List<String>();
        for (String tmpString : blackListFields) {
            listBlack.add(tmpString.toUpperCase());
        }
        for (String fieldName: fieldMap.keySet()) { 
            if (listBlack!=null && listBlack.size()>0 && listBlack.contains(String.valueOf(fieldName).toUpperCase()) ) {
                continue;
            }
            filds=String.isBlank(filds)?String.valueOf(fieldName):filds+','+String.valueOf(fieldName);
        }
        for (String fieldName: listNestedFields) { 
            filds=String.isBlank(filds)?String.valueOf(fieldName):filds+','+String.valueOf(fieldName);  
        }
        return filds;
    }
    /**
    * @description: Costruisce la query come stringa
    * @author ECapozzo | 09-09-2021
    * @return String 
    **/
    public String getQeryString(){
        String filter=String.isBlank(sFilter)?'':' WHERE '+sFilter;
        String fields=getAllObjectFields();
        return 'SELECT '+fields+' FROM '+typeObject+filter;
    }

    /**
    * @description: Effettua la query a DB restituendo una lista di SObject
    * @author ECapozzo | 09-09-2021
    * @return List<SObject> 
    **/
    public List<SObject> getListSObject(){
        List<SObject> s;
        try {
            s = Database.query(getQeryString());
 
        } catch (Exception e) {
            HDT_WRP_HelperException wrpExc=new HDT_WRP_HelperException(e.getTypeName(),e.getMessage());
            System.debug('wrpExc:  '+wrpExc);
        }
        
        return s;
    }


    public  class HDT_WRP_HelperException extends Exception{

        public String Type;
        public String Message;

        public HDT_WRP_HelperException(String type_v,String message_v){
            this.Type      = type_v;
            this.message   = message_v;
        }
    } 
}