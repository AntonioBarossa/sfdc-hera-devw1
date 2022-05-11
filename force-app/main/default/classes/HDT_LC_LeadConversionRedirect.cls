public with sharing class HDT_LC_LeadConversionRedirect {
    static final String KEY = 'local.ReitekAgentsSessionCache.campaignMemberId';

    @AuraEnabled
    public static void clearCache() {
        Cache.Session.remove(KEY);
    }

    @AuraEnabled
    public static void cachePush(String campaignMemberId) {
        if(String.isNotBlank(campaignMemberId)) {
            Cache.Session.put(KEY, campaignMemberId);
        }
    }

    @AuraEnabled
    public static String cachePop() {
        String id = (String) Cache.Session.get(KEY);
        clearCache();
        return id;
    }

    @AuraEnabled
    public static Boolean campaignMemberCached(){
        return Cache.Session.contains(KEY);
    }
}
