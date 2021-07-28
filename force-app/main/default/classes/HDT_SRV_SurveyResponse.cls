/**
* @author Sabina Levonja (sabina.levonja@dunegroup.it)
* @date 09/03/2021
* @description Class that holds crud and business logic for SurveyResponse__c
* @history Sabina Levonja – 09/03/2021 – Created class
*/

public with sharing class HDT_SRV_SurveyResponse {
    private static HDT_UTL_HelperMethods helperMethods = new HDT_UTL_HelperMethods();
    private static final String CREATEPERMISSION = 'create';

     /**
    * @author Sabina Levonja (sabina.levonja@dunegroup.it)
    * @date 09/03/2021
    * @description Initialize security access instance
    * @param String fields - Fields to check for access
    * @param String crud - crud operation passed as a string (create)
    */
    public static void checkAccessInit(String fields, String crud){
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('SurveyResponse__c', fields, crud);
        securityAccess.checkSecurityAccess();
    }

    /**
    * @author Sabina Levonja (sabina.levonja@dunegroup.it)
    * @date 09/03/2021
    * @description Check if current user has create permission on object and specified fields
    * @param String fields - Fields to check for access
    */
    public static void checkCreateAccess(SurveyResponse__c survey){
        List<String> fields = helperMethods.getObjAttrList(survey);
        checkAccessInit(String.join(fields, ','), CREATEPERMISSION);
    }

    /**
     * @author Sabina Levonja (sabina.levonja@dunegroup.it)
     * @description Create SurveyResponse__c record
     * @param SurveyResponse__c survey
     * @return SurveyResponse__c
     */
    public static SurveyResponse__c createRecord(SurveyResponse__c survey){
        HDT_UTL_DatabaseService.insertSObject(survey);
        return survey;
    }

    
}