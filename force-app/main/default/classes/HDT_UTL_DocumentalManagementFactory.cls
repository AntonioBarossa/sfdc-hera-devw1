public inherited sharing class HDT_UTL_DocumentalManagementFactory {
    public static HDT_UTL_DocumentalManagementInterface getInstance(String classString){
        Type t = Type.forName(classString);
        HDT_UTL_DocumentalManagementInterface retVal = (HDT_UTL_DocumentalManagementInterface)t.newInstance();
        return retVal;
    }
}