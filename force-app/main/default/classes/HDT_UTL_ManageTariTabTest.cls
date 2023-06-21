@isTest
public with sharing class HDT_UTL_ManageTariTabTest {
    
    @isTest
    public static void testManageableTabs(){
        Map<String, String> manageTariTableMap = HDT_UTL_ManageTariTab.getAllManageableTab();
        system.assert(!manageTariTableMap.isEmpty(), 'Errore, mappa vuota');
    }
}