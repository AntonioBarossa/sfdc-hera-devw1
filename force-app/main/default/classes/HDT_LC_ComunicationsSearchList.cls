public inherited sharing class HDT_LC_ComunicationsSearchList {
    @AuraEnabled//(cacheable=true)
    public static Object getWsData(String wrapperObj) {
        return HDT_SRV_ComunicationsSearchList.getWsData(wrapperObj);
    }

    @AuraEnabled
    public static HDT_WRP_ComunicationsSearchList.HDT_WRP_ResponseObj sendFileToPrint(String body){
        return HDT_SRV_ComunicationsSearchList.sendFileToPrint(body);
    }

    @AuraEnabled
    public static String getCompanyCode(String companyName){
        return HDT_SRV_ComunicationsSearchList.getCompanyCodeHelper(companyName);
    }

}