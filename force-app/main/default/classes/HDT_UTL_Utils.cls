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
    /**​
    * @author Enrico Capozzo (enrico.capozzo@webresults.it)​
    * @date 15/04/2021
    * @description HDT_UTL_Utils.codingSha256(...) – encodes the input string to Sha256
    * @param stringToCoding String to encoding
    * @return String EncodingUtil.convertToHex
    */
    public static String codingSha256(String stringToCoding){
        System.debug('method codingSha256 - param : ' + stringToCoding);
        String hashToString='';
        if (String.isNotBlank(stringToCoding)) {
            Blob targetBlob = Blob.valueOf(stringToCoding);
            Blob hash = Crypto.generateDigest('SHA-256', targetBlob);
            hashToString = EncodingUtil.convertToHex(hash);
            //String hashString = EncodingUtil.base64Encode(hash);
            System.debug('hashToString : '+hashToString);
        }
        return hashToString;
    }

    /**​
    * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)​
    * @date 12/08/2021
    * @description HDT_UTL_Utils.getCurrentUserRole() – Returns the DeveloperName of the user launching the class
    * @return the DeveloperName of the user
    */
    @AuraEnabled
    public static string getCurrentUserRole(){

        String userId = System.UserInfo.getUserId();

        return HDT_QR_UserQueries.getCurrentUser(userId).Userrole.DeveloperName;
            
    }
  
}