/*
    @Author:        Davide Viola
    CreatedDate:    13/10/2021
*/

@isTest
public class HDT_UTL_KpiTrackingTst {
    
    @TestSetup
    static void testSetup(){
        
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(2, true, 'HERA COMM', 'Azienda', 'Aziende SME');
    }
    
    public static testMethod void testCreateKpiTracking(){
        
        List<Account> accList = new List<Account>();
        List<KpiTracking__c> kpiTrackList = new List<KpiTracking__c>();
        
        accList = [SELECT Id, CustomerCode__c FROM Account];
        
        Test.startTest();
        
        for(Account acc : accList) acc.CustomerCode__c += 1;
        update accList;
        
        //Mi aspetto di trovare 4 record di KpiTracking__c.
        kpiTrackList = [SELECT Id FROM KpiTracking__c];
        System.assertEquals(kpiTrackList.size(), 4);
        
        Test.stopTest();
    }
    
    public static testMethod void testDeleteKpiTracking(){
        
        Set<String> kpiTrackIdSet = new Set<String>();
        List<Account> accList = new List<Account>();
        List<KpiTracking__c> kpiTrackList = new List<KpiTracking__c>();
        
        accList = [SELECT Id, CustomerCode__c, KpiTracking__c FROM Account];
        for(Account acc : accList) kpiTrackIdSet.add(acc.KpiTracking__c);
        
        Test.startTest();
        
        HDT_UTL_KpiTracking.deleteKpiTracking(accList);
        
        //Mi aspetto che le KpiTracking__c agganciate agli Account siano stati cancellati:
        kpiTrackList = [SELECT Id FROM KpiTracking__c WHERE Id = :kpiTrackIdSet];
        System.assertEquals(kpiTrackList.size(), 0);
        
        Test.stopTest();
    }
    
    public static testMethod void testUpdateKpiRecord(){
        
        Account myAcc = new Account();
        KpiTracking__c kpiTrack = new KpiTracking__c();
        List<Account> accList = new List<Account>();
        
        accList = [SELECT Id, CustomerCode__c, KpiTracking__c FROM Account];
        myAcc = accList[0];
        kpiTrack = [SELECT Id, CustomerCode__c, LastModifiedDate FROM KpiTracking__c WHERE Id = :myAcc.KpiTracking__c LIMIT 1];
        
        Test.startTest();
        
        HDT_UTL_KpiTracking.updateKpiRecord(kpiTrack);
        kpiTrack = [SELECT Id, CustomerCode__c, LastModifiedDate FROM KpiTracking__c WHERE Id = :myAcc.KpiTracking__c LIMIT 1];
        
        Test.stopTest();
    }
    
    public static testMethod void testGetKpiRecord(){
        
        Account myAcc = new Account();
        KpiTracking__c kpiTrack = new KpiTracking__c();
        List<KpiTracking__c> kpiTrackList = new List<KpiTracking__c>();
        List<Account> accList = new List<Account>();
        
        accList = [SELECT Id, CustomerCode__c, KpiTracking__c FROM Account];
        myAcc = accList[0];
        kpiTrack = [SELECT Id, CustomerCode__c, LastModifiedDate FROM KpiTracking__c WHERE Id = :myAcc.KpiTracking__c LIMIT 1];
        
        Test.startTest();
        
        kpiTrackList = HDT_UTL_KpiTracking.getKpiRecord(myAcc.KpiTracking__c);
        system.assertEquals(kpiTrackList.size(), 1);
        system.assertEquals(kpiTrackList[0].Id, kpiTrack.Id);
        
        kpiTrackList = HDT_UTL_KpiTracking.getKpiRecord(myAcc.CustomerCode__c);
        system.assertEquals(kpiTrackList.size(), 1);
        system.assertEquals(kpiTrackList[0].Id, kpiTrack.Id);
        
        kpiTrackList = HDT_UTL_KpiTracking.getKpiRecord(null);
        system.assertEquals(kpiTrackList.size(), 0);
        
        Test.stopTest();
    }
}