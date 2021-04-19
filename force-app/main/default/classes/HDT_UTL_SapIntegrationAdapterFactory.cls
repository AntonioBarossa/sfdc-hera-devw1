public inherited sharing class HDT_UTL_SapIntegrationAdapterFactory {
    public static HDT_UTL_SapIntegrationInterface getInstance(String validationClass){
        Type t = Type.forName(validationClass);
        HDT_UTL_SapIntegrationInterface retVal = (HDT_UTL_SapIntegrationInterface)t.newInstance();
        return retVal;
    }
}