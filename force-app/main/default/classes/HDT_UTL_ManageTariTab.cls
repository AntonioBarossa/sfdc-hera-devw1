/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 09-01-2023
 * @last modified by  : Giacinto Florio
**/
public with sharing class HDT_UTL_ManageTariTab {
   
    @AuraEnabled(cacheable=false)
    public static Map<String, String> getAllManageableTab() {

        Map<String, String> values =  new Map<String, String>();
        for(Manage_Tari_Table__mdt table : Manage_Tari_Table__mdt.getAll().values()) {
            values.put(table.itemApiName__c, table.itemLabel__c);
        }
        return values;
    }
}