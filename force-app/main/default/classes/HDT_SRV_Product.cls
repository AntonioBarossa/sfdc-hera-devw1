/**
 * @author Lorenzo Gulotta (lorenzo.gulotta@webresults.it)
 * @date 06/05/2021
 * @description Data Factory for Test Classes
 * @history Lorenzo Gulotta – 06/05/2021 – Created Class
 */

public inherited sharing class HDT_SRV_Product {
    
    private static HDT_UTL_HelperMethods helperMethods = new HDT_UTL_HelperMethods();
    private static final String READPERMISSION = 'read';
    private static final String CREATEPERMISSION = 'create';
    private static final String UPDATEPERMISSION = 'update';

    /**
    * @author Fatjola Memishaj (fatjola.memishaj@dunegroup.it)
    * @date 06/05/2021
    * @description Initialize security access instance
    * @param String fields - Fields to check for access
    * @param String crud - crud operation passed as a string (create, read, update, delete)
    */
    public void checkAccessInit(String fields, String crud){
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('Product2', fields, crud);
        securityAccess.checkSecurityAccess();
    }

    /**
     * @author Fatjola Memishaj (fatjola.memishaj@dunegroup.it)
     * @description Check if user has read access to fields and throw exception if access not granted
     * @param String fields
     */
    public void checkReadAccess(String fields){
        checkAccessInit(fields, READPERMISSION);
    }

    /**
    * @author Fatjola Memishaj (fatjola.memishaj@dunegroup.it)
    * @description Check if current user has create permission on object and specified fields
    * @param String fields - Fields to check for access
    */
    public void checkCreateAccess(String fields){
        checkAccessInit(fields, CREATEPERMISSION);
    }

    public Product2 createRecord(Product2 cc){
        List<String> fields = helperMethods.getObjAttrList(cc);
        checkUpdateAccess(String.join(fields, ','));
        HDT_UTL_DatabaseService.insertSObject(cc);
        return cc;
    }

    /**
    * @author Fatjola Memishaj (fatjola.memishaj@dunegroup.it)
    * @description Check if current user has update permission on object and specified fields
    * @param String fields - Fields to check for access
    */
    public void checkUpdateAccess(String fields){
        checkAccessInit(fields, UPDATEPERMISSION);
    }

    public void updateRecord(Product2 cc){
        List<String> fields = helperMethods.getObjAttrList(cc);
        checkUpdateAccess(String.join(fields, ','));

        HDT_UTL_DatabaseService.updateSObject(cc);
    }

    public void updateRecords(List<Product2> products){

        for (Product2 prod : products) {
            List<String> fields = helperMethods.getObjAttrList(prod);
            checkUpdateAccess(String.join(fields, ','));
        }

        HDT_UTL_DatabaseService.updateSObject(products);
    }
}