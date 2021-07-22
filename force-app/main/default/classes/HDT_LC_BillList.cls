public inherited sharing class HDT_LC_BillList {
    @AuraEnabled//(cacheable=true)
    public static Object getWsData(String wrapperObj) {
        return HDT_SRV_BillList.getWsData(wrapperObj);
    }
}