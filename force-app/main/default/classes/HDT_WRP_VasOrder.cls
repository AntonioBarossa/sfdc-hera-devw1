public inherited sharing class HDT_WRP_VasOrder {
    public class HDT_WRP_ProcessObjects {
        public MassiveLoaderRequestItem__c requestItem;
        public String vasOrderType; // Standalone - 1 child order - 2 child order
        public Boolean isStandalone;
        public String orderNumber;
        public String orderUniqueKey;
        public Order parentOrder;
        public Order order;
        public Contract contract;
        public List<HDT_WRP_OrderItem> wrapperOrdeItemList;
    }

    public class HDT_WRP_OrderItem {
        public String itemType;
        public OrderItem orderItem;
        public Product2 product;
    }
}