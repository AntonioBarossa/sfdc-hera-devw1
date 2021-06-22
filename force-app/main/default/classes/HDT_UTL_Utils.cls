/**
 * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)
 * @date 15/04/2021
 * @description HDT_UTL_Utils - Class that holds utility methods
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */

public with sharing class HDT_UTL_Utils {
    
    /**​
    * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)​
    * @date 15/04/2021
    * @description HDT_UTL_Utils.createMapFromSobjectList(...) – Create a Map from a List of sOObject using the specufied field as key (using Schema.sObjectField to identify the specific field)
    * @param sObjectList list of sObject containing the data for the Map
    * @param keyFieldSchema field to use as the key
    * @return Map containing one record for every key
    */

    public Map<String, sObject> createMapFromSobjectList(List<sObject> sObjectList, Schema.sObjectField keyFieldSchema) {

        Map<String, sObject> result = new Map<String, sObject>();

        for (sObject element : sObjectList) {
            
            String key = (String) element.get(keyFieldSchema);

            if (String.isNotBlank(key)) {
                result.put(key, element);    
            }            

        }

        return result;
    }
}