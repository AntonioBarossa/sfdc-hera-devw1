/**
* @author 'Lorenzo Gulotta' (lorenzo.gulotta@webresults.it)
* @date 11/06/2021
* @description Class HDT_UTL_DatabaseService.cls
* @history Lucas da Silva Fernandes – 11/06/2021 – Updated Header
*/

public without sharing class HDT_UTL_DatabaseServiceNoShare {
    
    private static final String MAXNUMBERRECORDSEXCEPTION = 'Puoi Passare Massimo 10000 Record in una singola azione di DML.';
    private static final String PERMISSIONEXCEPTION = 'Utente {0} non possiede i permessi per effettuare questa Specifica operazione sull oggetto {1}.';

    public static Boolean insertSObject(SObject sObj) {
        return insertSObject(new List<sObject>{sObj});
    }

    public static Boolean insertSObject(List<SObject> sObjectList) {
        if (checkBeforeDml(sObjectList, DmlOperation.DML_INSERT)) {
            return false;
        }
        List<Database.SaveResult> insertResult = Database.insert(sObjectList, true);
        System.debug('Insert result: '+insertResult);
        return true;
    }

    public static Boolean updateSObject(SObject sObj) {
        return updateSObject(new List<sObject>{sObj});
    }

    public static Boolean updateSObject(List<SObject> sObjectList) {
        if (checkBeforeDml(sObjectList, DmlOperation.DML_UPDATE)) {
            return false;
        }
        List<Database.SaveResult> updateResult = Database.update(sObjectList, true);
        System.debug('Update result: '+updateResult);
        return true;
    }

    public static Boolean upsertSObject(SObject sObj) {
        return upsertSObject(new List<sObject>{sObj});
    }

    public static Boolean upsertSObject(List<SObject> sObjectList) {
        if (checkBeforeDml(sObjectList, DmlOperation.DML_UPSERT)) {
            return false;
        }
        List<sObject> toInsert = new List<SObject>();
        List<sObject> toUpdate = new List<SObject>();
        for (sObject sObj : sObjectList) {
            if (String.isNotBlank(sObj.id)) {
                toUpdate.add(sObj);
            } else {
                toInsert.add(sObj);
            }
        }
        insertSObject(toInsert);
        updateSObject(toUpdate);
        return true;
    }
    public static Boolean upsertSObjectExternalId(List<SObject> sObjectList,String objectName,String fieldName){
        if (checkBeforeDml(sObjectList,DmlOperation.DML_UPSERT)){
            return false;
        }
        Schema.SobjectField theField = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName);
        List<Database.UpsertResult> upsertResult = Database.upsert(sObjectList,theField, true);
        System.debug('Upsert result: '+upsertResult);
        return true;
    }

    public static Boolean deleteSObject(Id sObjId) {
        return deleteSObject(new List<Id>{sObjId});
    }

    public static Boolean deleteSObject(List<SObject> sObjectList) {
        if (checkBeforeDml(sObjectList, DmlOperation.DML_DELETE)) {
            return false;
        }
        List<Database.DeleteResult> deleteResult = Database.delete(sObjectList, true);
        System.debug('Delete result: '+deleteResult);
        return true;
    }

    public static Boolean deleteSObject(List<Id> sObjectIds) {
        if (checkBeforeDml(sObjectIds, DmlOperation.DML_DELETE)) {
            return false;
        }
        List<Database.DeleteResult> deleteResult = Database.delete(sObjectIds, true);
        System.debug('Delete result: '+deleteResult);
        return true;
    }


    private static Boolean isDmlNotAllowed(Integer recordsNumber) {
        return (Limits.getDMLRows() + recordsNumber) > Limits.getLimitDMLRows();
    }

    private static Boolean checkBeforeDml(List<SObject> sObjectList, DmlOperation operation) {
        if (sObjectList.isEmpty()) {
            return true;
        }
        if (isDmlNotAllowed(sObjectList.size())) {
            throw new HDT_UTL_HeraException(MAXNUMBERRECORDSEXCEPTION);
        }
        if (!checkDmlPermissions(sObjectList, operation)) {
            throw new HDT_UTL_HeraException(String.format(
                PERMISSIONEXCEPTION, new List<String> {UserInfo.getUserId(), HDT_UTL_SobjectUtils.getSobjectTypeName(sObjectList)}));
        }
        return false;
    }

    private static Boolean checkBeforeDml(List<Id> idList, DmlOperation operation) {
        if (idList.isEmpty()) {
            return true;
        }
        if (isDmlNotAllowed(idList.size())) {
            throw new HDT_UTL_HeraException(MAXNUMBERRECORDSEXCEPTION);
        }
        if (!checkDmlPermissions(idList, operation)) {
            throw new HDT_UTL_HeraException(String.format(
                PERMISSIONEXCEPTION, new List<String> {UserInfo.getUserId(), HDT_UTL_SobjectUtils.getSobjectTypeName(idList)}));
        }
        return false;
    }

    private static Boolean checkDmlPermissions(List<SObject> sObjectList, DmlOperation operation) {
        for (sObject sObj : sObjectList) {
            Boolean isPermissionGranted = checkDmlPermission(sObj.getSObjectType(), operation);
            if (!isPermissionGranted) {
                return false;
            }
        }
        return true;
    }

    private static Boolean checkDmlPermissions(List<Id> idList, DmlOperation operation) {
        for (Id theId : idList) {
            Boolean isPermissionGranted = checkDmlPermission(theId.getSObjectType(), operation);
            if (!isPermissionGranted) {
                return false;
            }
        }
        return true;
    }

    private static Boolean checkDmlPermission(SObjectType sobjType, DmlOperation operation) {
        DescribeSObjectResult sObjectDescribe = sobjType.getDescribe();
        if (operation == DmlOperation.DML_INSERT) {
            return sObjectDescribe.isCreateable();
        } else if (operation == DmlOperation.DML_UPDATE) {
            return sObjectDescribe.isUpdateable();
        } else if (operation == DmlOperation.DML_UPSERT) {
            return sObjectDescribe.isCreateable() && sObjectDescribe.isUpdateable();
        } else if (operation == DmlOperation.DML_DELETE) {
            return sObjectDescribe.isDeletable();
        }
        return false;
    }

    enum DmlOperation { 
        DML_INSERT,
        DML_UPDATE,
        DML_UPSERT,
        DML_DELETE
    }
}
