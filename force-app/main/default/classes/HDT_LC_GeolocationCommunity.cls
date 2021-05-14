public with sharing class HDT_LC_GeolocationCommunity {
    private static HDT_QR_Contact contactQR = new HDT_QR_Contact();
    private static HDT_QR_CampaignMember campaignMemberQR = new HDT_QR_CampaignMember();

    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactsByOwnerId(String ownerId, String ownerName){
        try {
            return contactQR.getContactsByOwnerId(ownerId, ownerName);
        } catch (Exception e) {
            System.debug(e.getMessage());
            return null;
        }
    }

    @AuraEnabled(cacheable=true)
    public static Contact getContactCoordinates(String contactId){
        try {
            return contactQR.getContactCoordinates(contactId);
        } catch (Exception e) {
            System.debug(e.getMessage());
            return null;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<CampaignMember> getContactsWithinDistance(Decimal latitude, Decimal longitude, Decimal distanceKm){
        try {
            return campaignMemberQR.getContactsWithinDistance(latitude, longitude, distanceKm);
        } catch (Exception e) {
            System.debug(e.getMessage());
            return null;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<CampaignMember> getLeadsWithinDistance(Decimal latitude, Decimal longitude, Decimal distanceKm){
        try {
            return campaignMemberQR.getLeadsWithinDistance(latitude, longitude, distanceKm);
        } catch (Exception e) {
            System.debug(e.getMessage());
            return null;
        }
    }
}
