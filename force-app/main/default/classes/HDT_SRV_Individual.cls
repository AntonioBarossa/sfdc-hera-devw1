public with sharing class HDT_SRV_Individual {
    private static final String CREATEPERMISSION = 'create';
    private static final String UPDATEPERMISSION = 'update';
    private static final String UPSERTPERMISSION = 'create';
    private static HDT_UTL_HelperMethods helperMethods = new HDT_UTL_HelperMethods();

    public static void checkAccessInit(String fields, String crud){
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('Individual', fields, crud);
        securityAccess.checkSecurityAccess();
    }
    /**
     * @author Sabina Levonja
     * @description Check if user has create access to fields and throw exception if access not granted
     */

    public static void checkCreateAccess(Individual indv){
        List<String> fields = helperMethods.getObjAttrList(indv);
        checkAccessInit(String.join(fields, ','), CREATEPERMISSION);
    }

    public static Individual createRecord(Individual indv){
        HDT_UTL_DatabaseService.insertSObject(indv);
        return indv;
    }
    public static List<Individual> createRecord(List<Individual> indv){
        HDT_UTL_DatabaseService.insertSObject(indv);
        return indv;
    }

    public static void checkUpdateAccess(Individual indv){
        List<String> fields = helperMethods.getObjAttrList(indv);
        checkAccessInit(String.join(fields, ','), UPDATEPERMISSION);
    }

    public static Individual updateRecord(Individual indv){
        HDT_UTL_DatabaseService.updateSObject(indv);
        return indv;
    }

    public static void upsertIndividuals(List<Individual> individuals){
        HDT_UTL_DatabaseService.upsertSObject(individuals);
        
        
    }

    public static void checkUpsertAccess(Individual indv){
        List<String> fields = helperMethods.getObjAttrList(indv);
        checkAccessInit(String.join(fields, ','), UPSERTPERMISSION);
    }
}
