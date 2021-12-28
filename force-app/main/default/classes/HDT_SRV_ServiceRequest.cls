/**
 * @author Sabina Levonja (sabina.levonja@dunegroup.it)
 * @date 14/07/2021
 * @description Class that holds CRUD and business logic for ServiceRequest__c
 */

public inherited sharing class HDT_SRV_ServiceRequest {

    private static HDT_UTL_HelperMethods helperMethods = new HDT_UTL_HelperMethods();
    private static final String READPERMISSION = 'read';
    private static final String CREATEPERMISSION = 'create';
    private static final String DELETEPERMISSION = 'delete';
    private static final String UPDATEPERMISSION = 'update';

    /**
    * @author Sabina Levonja (sabina.levonja@dunegroup.it)
    * @description Initialize security access instance
    * @param String fields - Fields to check for access
    * @param String crud - crud operation passed as a string (create, read, update, delete)
    */
    public static void checkAccessInit(String fields, String crud){
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('ServiceRequest__c', fields, crud);
        securityAccess.checkSecurityAccess();
    }

    /**
     * @author Sabina Levonja (sabina.levonja@dunegroup.it)
     * @description Check if user has read access to fields and throw exception if access not granted
     * @param String fields
     */
    public static void checkReadAccess(String fields){
        checkAccessInit(fields, READPERMISSION);
    }
    public static void checkCreateAccess(ServiceRequest__c srvRequest){
        List<String> fields = helperMethods.getObjAttrList(srvRequest);
        checkAccessInit(String.join(fields, ','), CREATEPERMISSION);
    }
    public static void checkDeleteAccess(ServiceRequest__c srvRequest){
        List<String> fields = helperMethods.getObjAttrList(srvRequest);
        checkAccessInit(String.join(fields, ','), DELETEPERMISSION);
    }
    public static void checkUpdateAccess(ServiceRequest__c srvRequest){
        List<String> fields = helperMethods.getObjAttrList(srvRequest);
        checkAccessInit(String.join(fields, ','), UPDATEPERMISSION);
    }

    public static ServiceRequest__c createRecord(ServiceRequest__c srvRequest){
        checkCreateAccess(srvRequest);
        HDT_UTL_DatabaseService.insertSObject(srvRequest);
        return srvRequest;
    }

    public static void deleteRecord(ServiceRequest__c srvRequest){
        checkDeleteAccess(srvRequest);
        HDT_UTL_DatabaseService.deleteSObject(srvRequest.Id);
    }

    public static void deleteRecord(List<ServiceRequest__c> srvRequest){
        //checkDeleteAccess(srvRequest);
        HDT_UTL_DatabaseService.deleteSObject(srvRequest);
    }

    public static List<ServiceRequest__c> updateRecord(List<ServiceRequest__c> srvRequests){
        HDT_UTL_DatabaseService.updateSObject(srvRequests);
        return srvRequests;
    }
}