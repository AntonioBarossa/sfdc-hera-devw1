public inherited sharing class HDT_WRP_VasOrder {
    public class HDT_WRP_ProcessObjects {
        public Id mainRequestItemId;
        public Boolean error;
        public List<MassiveLoaderRequestItem__c> allRequestItems;
        public String vasOrderType; // Standalone - 1 child order - 2 child order
        public Boolean isStandalone;
        public String orderNumber;
        public Order parentOrder;
        public Account account;
        public Contract contract;
        public Sale__c sale;
        public Opportunity opportunity;
        public List<HDT_WRP_ChildOrder> childOrderList;

        public HDT_WRP_ProcessObjects(){
            error = false;
            parentOrder = new Order();
            parentOrder.IsMassive__c = true;
            account = new Account();
            sale = new Sale__c();
            opportunity = new Opportunity();
            childOrderList = new List<HDT_WRP_ChildOrder>();
        }

    }

    public class HDT_WRP_ChildOrder {
        public Order childOrder;
        public List<HDT_WRP_OrderItem> orderItemList;

        public HDT_WRP_ChildOrder(){
            childOrder = new Order();
            childOrder.IsMassive__c = true;
            orderItemList = new List<HDT_WRP_OrderItem>();
        }

    }

    public class HDT_WRP_OrderItem {
        public String itemType;
        public Product2 product;
        public OrderItem orderItem;

        public HDT_WRP_OrderItem(String itemType) {
            this.itemType = itemType;
            product = new Product2();
            orderItem = new OrderItem();
        }

    }
}