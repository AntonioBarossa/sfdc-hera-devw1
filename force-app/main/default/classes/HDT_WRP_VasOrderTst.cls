@isTest
public class HDT_WRP_VasOrderTst {

    @isTest
    static void testNestedClassConstructors() {
        
        HDT_WRP_VasOrder.HDT_WRP_ProcessObjects processObjects = new HDT_WRP_VasOrder.HDT_WRP_ProcessObjects();
        System.assertEquals(false, processObjects.error, 'ProcessObjects constructor should set error to false');
        System.assertNotEquals(null, processObjects.parentOrder, 'ProcessObjects constructor should initialize parentOrder');
        System.assertNotEquals(null, processObjects.account, 'ProcessObjects constructor should initialize account');
        System.assertNotEquals(null, processObjects.sale, 'ProcessObjects constructor should initialize sale');
        System.assertNotEquals(null, processObjects.opportunity, 'ProcessObjects constructor should initialize opportunity');
        System.assertEquals(new List<HDT_WRP_VasOrder.HDT_WRP_ChildOrder>(), processObjects.childOrderList, 'ProcessObjects constructor should initialize childOrderList');

        
        HDT_WRP_VasOrder.HDT_WRP_ChildOrder childOrder = new HDT_WRP_VasOrder.HDT_WRP_ChildOrder();
        System.assertNotEquals(null, childOrder.childOrder, 'ChildOrder constructor should initialize childOrder');
        System.assertEquals(new List<HDT_WRP_VasOrder.HDT_WRP_OrderItem>(), childOrder.orderItemList, 'ChildOrder constructor should initialize orderItemList');

        
        String testItemType = 'Test Item Type';
        HDT_WRP_VasOrder.HDT_WRP_OrderItem orderItem = new HDT_WRP_VasOrder.HDT_WRP_OrderItem(testItemType);
        System.assertEquals(testItemType, orderItem.itemType, 'OrderItem constructor should set itemType');
        System.assertNotEquals(null, orderItem.product, 'OrderItem constructor should initialize product');
        System.assertNotEquals(null, orderItem.orderItem, 'OrderItem constructor should initialize orderItem');
    }
}