@isTest
public class HDT_WRP_Scope_Test {

    @isTest
    static void testConstructors() {
        
        HDT_WRP_Scope defaultInstance = new HDT_WRP_Scope();
        System.assertEquals(null, defaultInstance.sobjList, 'Default constructor should set sobjList to null');

        
        List<SObject> testSobjList = new List<SObject>{ new Account(Name = 'Test Account') };
        HDT_WRP_Scope listInstance = new HDT_WRP_Scope(testSobjList);
        System.assertEquals(testSobjList, listInstance.sobjList, 'Constructor with List<SObject> parameter should set sobjList to the provided list');
    }
}