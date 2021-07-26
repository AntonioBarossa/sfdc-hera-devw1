public inherited sharing class HDT_LC_ComunicationsSearchList {
    @AuraEnabled//(cacheable=true)
    public static Object getWsData(String wrapperObj) {
        return HDT_SRV_ComunicationsSearchList.getWsData(wrapperObj);
    }
}