public inherited sharing class HDT_QR_PriceBook {
    
    public static List<Pricebook2> getRecordByName(String name) {
        return [
            SELECT 
            Id
            FROM Pricebook2
            WHERE Name = :name
            WITH SECURITY_ENFORCED
        ];
    }

}
