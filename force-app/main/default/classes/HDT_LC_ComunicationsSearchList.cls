public inherited sharing class HDT_LC_ComunicationsSearchList {
    @AuraEnabled//(cacheable=true)
    public static Object getWsData(String wrapperObj) {
        return HDT_SRV_ComunicationsSearchList.getWsData(wrapperObj);
    }

    @AuraEnabled
    public static HDT_WRP_ComunicationsSearchList.HDT_WRP_ResponseObj sendFileToPrint(String dataList){
        return HDT_SRV_ComunicationsSearchList.sendFileToPrint(dataList);
    }

}