public inherited sharing class HDT_TRH_OrderItem extends HDT_TRH_TriggerHandler {
    
    private Set<Id> product2Ids;
    private List<Product2> product2List;
    private Map<Id, Product2> product2Map;

    public override void beforeInsert(){

        product2Ids = new Set<Id>();
        product2List = new List<Product2>();

        try {
            for(OrderItem ordeItem : (OrderItem[])Trigger.new){
                product2Ids.add(ordeItem.Product2Id);
            }

            product2List = [
                SELECT Id, SpecialDay__c, DefaultSpecialDay__c, StartTimeSlot__c, DefaulStartTime__c
                FROM Product2
                WHERE Id IN :product2Ids
                WITH SECURITY_ENFORCED
            ];

            product2Map = new Map<Id, Product2>(product2List);

            Product2 iterProduct2;
            for(OrderItem ordeItem : (OrderItem[])Trigger.new){
                
                iterProduct2 = product2Map.get(ordeItem.Product2Id);

                if(String.isEmpty(iterProduct2.SpecialDay__c)){
                    if(String.isNotEmpty(iterProduct2.DefaultSpecialDay__c)){
                        ordeItem.SpecialDay__c = iterProduct2.DefaultSpecialDay__c;
                    }
                } else {
                    ordeItem.SpecialDay__c = iterProduct2.SpecialDay__c;
                }
                
                if(String.isEmpty(iterProduct2.StartTimeSlot__c)){
                    if(String.isNotEmpty(iterProduct2.DefaulStartTime__c)){
                        ordeItem.StartTimeSlot__c = iterProduct2.DefaulStartTime__c;
                    }
                } else {
                    ordeItem.StartTimeSlot__c = iterProduct2.StartTimeSlot__c;
                }
            }

        } catch(Exception e){
            System.debug('> ' + e.getMessage());
        }
    }

}