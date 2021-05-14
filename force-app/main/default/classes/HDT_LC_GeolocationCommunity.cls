public with sharing class HDT_LC_GeolocationCommunity {
    private static HDT_QR_Contact contactQr = new HDT_QR_Contact();
    private static HDT_QR_CampaignMember campaignMemberQr = new HDT_QR_CampaignMember();

    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactsByOwnerId(String ownerId, String ownerName){
        try {
            return contactQr.getContactsByOwnerId(ownerId, ownerName);
        } catch (Exception e) {
            System.debug(e.getMessage());
            return null;
        }
    }

    @AuraEnabled(cacheable=true)
    public static Contact getContactCoordinates(String contactId){
        try {
            return contactQr.getContactCoordinates(contactId);
        } catch (Exception e) {
            System.debug(e.getMessage());
            return null;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<CampaignMember> getContactsWithinDistance(Decimal latitude, Decimal longitude, Decimal distanceKm){
        try {
            return campaignMemberQr.getContactsWithinDistance(latitude, longitude, distanceKm);
        } catch (Exception e) {
            System.debug(e.getMessage());
            return null;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<CampaignMember> getLeadsWithinDistance(Decimal latitude, Decimal longitude, Decimal distanceKm){
        try {
            return campaignMemberQr.getLeadsWithinDistance(latitude, longitude, distanceKm);
        } catch (Exception e) {
            System.debug(e.getMessage());
            return null;
        }
    }
}
