@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_LC_CaseFileUpload {

    @AuraEnabled
    public static List<ContentDocument> getFiles(Id recordId) {

        List<ContentDocumentLink> cdl = new List<ContentDocumentLink>();
        List<ContentDocument> cd = new List<ContentDocument>();
        Set<Id> cdIds = new Set<Id>();

        cdl = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: recordId WITH SECURITY_ENFORCED];

        for(ContentDocumentLink cdlElement : cdl){
            cdIds.add(cdlElement.ContentDocumentId);
        }

        cd = [SELECT Id, Title, FileType, ContentSize, FileExtension, CreatedDate, LastModifiedDate FROM ContentDocument WHERE Id IN :cdIds WITH SECURITY_ENFORCED ORDER BY LastModifiedDate DESC];

        return cd;

    }

    @AuraEnabled
    public static void updatePhaseAllegatiRicevuti(String recordId){

      Id recordTypeConsumoAnomaloIdrico = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_ConsumoAnomaloIdrico').getRecordTypeId();

      List<Case> caseList = new List<Case>();
      List<Case> caseListToUpdate = new List<Case>();

           caseList = [SELECT Id, Phase__c, Cluster__c, RecordTypeId, AccountId, (SELECT Id FROM ContentDocumentLinks LIMIT 1) 
                              FROM Case WHERE Id =: recordId WITH SECURITY_ENFORCED];
          
          for (Case c : caseList) {
              if(c.Cluster__c == 'Segnalazioni' && c.RecordTypeId == recordTypeConsumoAnomaloIdrico){
                  if(c.Phase__c == 'Risposta ricevuta'){
                      c.Phase__c = 'Allegati ricevuti';
                      caseListToUpdate.add(c);
                  }
              }
          }   
          if(!caseListToUpdate.isEmpty()){
              HDT_UTL_DatabaseService.updateSObject(caseListToUpdate);
          }
    }


    @AuraEnabled
      public static void deleteFile(String recordId) {

        List<ContentDocument> cdList = [SELECT Id FROM ContentDocument WHERE Id =: recordId WITH SECURITY_ENFORCED];
        
        HDT_UTL_DatabaseService.deleteSObject(cdList);

      }
}
