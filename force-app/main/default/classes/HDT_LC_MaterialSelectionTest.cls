@isTest
public with sharing class HDT_LC_MaterialSelectionTest {

    @TestSetup
    static void setup(){

        HDT_UTL_DataFactoryTst.pClickCasePhase();
        
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, null, null);
        List<VolumetricEstimate__c> volums = new List<VolumetricEstimate__c>{
            new VolumetricEstimate__c(Name='Materiale1', CubicMeters__c=1), 
            new VolumetricEstimate__c(Name='Materiale2', CubicMeters__c=2), 
            new VolumetricEstimate__c(Name='Materiale3', CubicMeters__c=3)
        };
        insert volums;
        insert new CaseVolumetricaJunction__c(Case__c=caseList[0].Id, VolumetricEstimate__c=volums[0].Id);
    }
    
    @isTest
    public static void volumetricaQueries(){
        String caseId = [Select id from Case Limit 1].Id;
        HDT_LC_MaterialSelection.HDT_WRP_Data data = new HDT_LC_MaterialSelection.HDT_WRP_Data();
        data = HDT_LC_MaterialSelection.getTables(caseId);
        system.assertEquals(3, data.volumetricEstimate.size(), 'Size tabella volumetriche errato');
        system.assertEquals(1, data.preselectedValues.size(), 'Numero valori junction errati');
    }

    @isTest
    public static void volumetricaModify(){
        String caseId = [Select id from Case Limit 1].Id;
        List<String> volumetricIds = new List<String>();
        for(VolumetricEstimate__c vol :[select id from VolumetricEstimate__c where id NOT IN (Select VolumetricEstimate__c From CaseVolumetricaJunction__c)]){
            volumetricIds.add(vol.Id);
        }
        HDT_LC_MaterialSelection.createJunctionObj(caseId, volumetricIds);
        system.assertEquals(2, HDT_LC_MaterialSelection.getTables(caseId).preselectedValues.size(), 'Numero valori junction errati (non è aumentato)');
    }
}