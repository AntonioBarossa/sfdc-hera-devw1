/**
 * @description       : 
 * @author            : federico.defelice@webresults.it
 * @group             : WR
 * @last modified on  : 21-10-2022
 * @last modified by  : federico.defelice@webresults.it
 * This Class can take a Map<String, String> with keys that indicate a structure and generate a JSON with that structure:
 * 
 * Ex. Map('orderEntryMiOrders.0.orderEntryMiLineItems.0.action.0.hercodiceCentroLavoro'	=>	'1001001')
 * Creates this JSON:
 * { 
 *  orderEntryMiOrders:{
 *      [
*          {orderEntryMiLineItems:[
*              {action:[
*                  {hercodiceCentroLavoro : "1001001"}
*              ]}
*          ]}
 *      ]
 *  }
 * }
**/
public with sharing class HDT_UTL_GenerateMultilevelJson {

    private Map<String, String> namesValues;


    public HDT_UTL_GenerateMultilevelJson(){
        this.namesValues= new Map<String, String>();
        return;
    }

    public HDT_UTL_GenerateMultilevelJson(Map<String, String> namesValues){
        this.namesValues= namesValues;
        return;
    }    

    public String generateJson(){
        try{
            //namesValues = //Mappa chiave valori
            //new Map<String, String>{'k'=>'v', 'k.0.k2'=>'v', 'k0.k1'=>'vv', 'k0.k2.k4.k5'=>'vv2'};
            //new Map<String, String>{ 'k.0.k2.k11.1.k12'=>'dfd', 'k.0.k2.k11.0.k12'=>'v','k0.k1'=>'vv', 'k0.k2.k4.k5'=>'vv2'};
            //new Map<String, String>{'k.0.k2'=>'v'};

            Map<String, Object> root = new Map<String, Object>();//Mappa finale
            for (String path : this.namesValues.keySet()) {
                HDT_WRP_Row row = new HDT_WRP_Row(path, namesValues.get(path));
                row.recursiveInsertKeyValuePairOnMap(root);
            }
            //ora rootMap è ok, rimane da scorrerla per trasformare tutte le mappe con chiave intera in array
            checkMapForArrays(root);
            String jsonString = JSON.serializePretty(root);
            System.debug(jsonString);
            return jsonString;
        }catch(Exception e){
            system.debug(e.getStackTraceString()+'\n\n********\n\n'+e.getMessage());
        }
        return null;
    }

    
    /**
    * @description 
    * @author federico.defelice@webresults.it | 21-10-2022 
    * @param root 
    * This method get a String->Object map, and check infinitely inside
    * when it's in the 2nd deepest level of each branch, recursion stops
    * and began to check for Arrays, calling a method that may (or may not)
    * replace the lower map with an array, calling *transformSublevelMap*
    **/
    private void checkMapForArrays(Map<String, Object> root){
        for(String key : root.keySet()){
            if(root.get(key) instanceof Map<String, Object>){
                checkMapForArrays((Map<String, Object>) root.get(key));
                root.put(key, transformSublevelMap((Map<String, Object>) root.get(key)));
            }
        }
        return;

    }

    /**
    * @description 
    * @author federico.defelice@webresults.it | 21-10-2022 
    * @param sublevelMap 
    * @return Object 
    * this method recives a Map and may return that Map untouched 
    * or an Array of Object if he finds out that the map has only numeric keys
    **/
    private Object transformSublevelMap(Map<String, Object> sublevelMap){
        //if this sublevelMap is an Array, return an array, if not return the map
        List<Object> transformingList = new List<Object>();
        for(String key : sublevelMap.keySet()){
            if(!key.isNumeric())    return sublevelMap;
            transformingList.add(sublevelMap.get(key));
        }
        return transformingList;
    }

    

    class HDT_WRP_Row{
        String completePath;
        String value;
        List<String> pathList;

        HDT_WRP_Row(String completePath, String value){
            this.completePath=completePath;
            this.pathList=completePath.split('\\.');
            this.value=value;
        }

        private void recursiveInsertKeyValuePairOnMap(Map<String, Object> upperLevelMap){
            //recive a map and decide if just add key value or key and an indented map
            String key = this.pathList[0];
            if (1 == this.pathList.size()){
                if(upperLevelMap.get(key) instanceof Map<String, Object>){ throw new HDT_UTL_JsonGeneratorException('JSON ERROR, same key declared as both primitive and object: Key: '+key+'; path '+this.completePath); }
                //if(upperLevelMap.get(key) != null){     system.debug('Repeated Key-value pair, overwrite old Value');}
                upperLevelMap.put(key, this.value);
                return;
            }else{
                this.pathList.remove(0);//Si avanza nel path
                if(upperLevelMap.get(key) != null && !(upperLevelMap.get(key) instanceof Map<String, Object>)){    throw new HDT_UTL_JsonGeneratorException('JSON ERROR, same key declared as both primitive and object, Key: '+key+'; path '+this.completePath);}//aggiungere path completo    
                Map<String, Object> sublevelMap = (Map<String, Object>) upperLevelMap.get(key);
                if(sublevelMap==null){
                    sublevelMap= new Map<String, Object>();
                    upperLevelMap.put(key, sublevelMap);
                }
                upperLevelMap.put(key, sublevelMap);//si aggiunge la coppia chiave-subMap
                this.recursiveInsertKeyValuePairOnMap(sublevelMap);
            }
        }
    }

    class HDT_UTL_JsonGeneratorException extends Exception{}

}