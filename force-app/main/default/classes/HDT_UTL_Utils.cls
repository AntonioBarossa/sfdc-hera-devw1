/**
 * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)
 * @date 15/04/2021
 * @description HDT_UTL_Utils - Class that holds utility methods
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */

public with sharing class HDT_UTL_Utils {

    private static HDT_QR_PermissionSet permissionSetQr = new HDT_QR_PermissionSet();
    
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

    /**​
    * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)​
    * @date 27/08/2021
    * @description HDT_UTL_Utils.isAssignedCustomPermission() – Check if the current user has a specific Custom permission assigned
    * @param custompermissionDeveloperName The developer name of the CustomPermission
    * @return Boolean value (true = custom permission is assigned)
    */
    public Boolean isAssignedCustomPermission(String custompermissionDeveloperName) {

        Boolean result = false;

        List<CustomPermission> customPermissions = permissionSetQr.getCustomPermissionsByUserId(UserInfo.getUserId());

        for (CustomPermission cmp : customPermissions) {
            
            if (cmp.DeveloperName.equals(customPermissionDeveloperName)) {
                
                result = true;
                break;

            }

        }

        return result;
        
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Exctract date for phase to transition from phase story string
     * @param phaseStory - String
     * @param phaseTo - String
     * @return Date
     */
    public static Date exctrPhaseTransDateFromStory(String phaseStory, String phaseTo){
        String[] strArr = phaseStory.split('@@');
        String unixDateTime = '';

        for (Integer i = 0; i < strArr.size(); i++) {
            if (phaseTo.equalsIgnoreCase(strArr[i]) && strArr.size() > i+1 && strArr[i+1]!= null && strArr[i+1].isNumeric()) {
                unixDateTime = strArr[i+1];
            }
        }
        if (''.equals(unixDateTime)){
            return null;
        }
        Datetime myDateTime = Datetime.newinstance(long.valueOf(unixDateTime));
        Date myDate = Date.newinstance(myDateTime.year(), myDateTime.month(), myDateTime.day());

        return myDate;
    }

    public static void setUsersField(List<SObject> newObjectList){

        HDT_SRV_LogService logService = new HDT_SRV_LogService('USER_FIELD_EXCEPTION');
        User u = HDT_QR_UserQueries.getCurrentUser(UserInfo.getUserId());

        for(Sobject newObject : newObjectList){
            setUsersField(newObject, logService, u);
        }

        logService.saveMassiveRecords();

    }

    public static void setUsersField(SObject newObject, HDT_SRV_LogService logService, User u){

        try{
            String sObjectName = String.valueOf(newObject.getSObjectType());
            if(u != null){
                newObject.put('CreatorGroup__c', u.CreatorGroup__c);
                if(sObjectName == 'Order'){
                    newObject.put('LoginChannel__c', u.LoginChannel__c);
                }
                else{
                    newObject.put('LoginGroup__c', u.LoginChannel__c); 
                }
                if(u.Station__c != '' && u.Station__c != null){
                    newObject.put('LoginWorkstation__c', u.Station__c);
                }
                else{
                    newObject.put('LoginWorkstation__c', '-');
                }
            }
        }
        catch(Exception e){
            logService.addLog('HDT_UTL_Utils', 'setUsersField', JSON.serialize(newObject), null, e.getMessage()+ ' line: '+ e.getLineNumber(), null, null, null);

        }
        
        
    }

    public static String beforeSapPhase(String phase, String pStory){
        if (String.isBlank(pStory)){
            return '';
        }
        pStory = pStory.replace('@@M||', '@@A||');
        Boolean isRightPhase = false;
        for (String trans : pStory.split('[@][@][A][|][|]')){
            List<String> phases = trans.split('@@');
            if (phases.size() < 3 || !phase.equalsIgnoreCase(phases[1])){
                break;
            }
            phase = phases[0];
            if (!HDT_UTL_GestioneScartiSap.skipPhaseManager(phase)){
                isRightPhase = true;
                break;
            }
        }
        return isRightPhase ? phase : '';
    }
    
    public static void setFieldsSize(SObject o){
        Map<String,Map<String,Integer>> mapField = new Map<String,Map<String,Integer>>{
            'Case' => new Map<String,Integer>{
                'CancellationNote__c' => 255, 
                'DiscardDescription__c' => 255
            }
        };
        String objectName = o?.getSObjectType().getDescribe().getName();
        setFieldsSize(mapField.get(objectName), o);
    }

    @SuppressWarnings('PMD.AvoidDebugStatements')
    private static void setFieldsSize(Map<String,Integer> mapFieldsSize, SObject o){
        if (o == null || mapFieldsSize.isEmpty()){
            return;
        }
        try{
            String objectName = o.getSObjectType().getDescribe().getName();
            Map<String,Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
            for(String fieldToCheck :mapFieldsSize.keySet()){
                Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldToCheck).getDescribe();
                if (fieldDescribe.getType() != Schema.DisplayType.STRING && fieldDescribe.getType() != Schema.DisplayType.TEXTAREA){
                    continue;
                }
                Integer sizeField = mapFieldsSize.get(fieldToCheck);
                String fieldValue = o.get(fieldToCheck) == null ? '' : (String)o.get(fieldToCheck);
                if (String.isNotBlank(fieldValue) && fieldValue.length() > sizeField){
                    o.put(fieldToCheck,fieldValue.substring(0,255));
                }
            }
        }catch (Exception e){
            System.debug(LoggingLevel.ERROR, 'HDT_UTL_Utils setFieldsSize : ' + e.getStackTraceString());
        }
        
    }
}