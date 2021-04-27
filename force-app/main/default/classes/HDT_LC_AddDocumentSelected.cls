public inherited sharing class HDT_LC_AddDocumentSelected {

    @AuraEnabled
    public static void insertDocuments(List<String> documents, String caseId){

        List<DocumentSelected__c> documenti = new List<DocumentSelected__c>();

        for(String document : documents){

            documenti.add(new DocumentSelected__c(Name = document, Case__c = caseId));

        }

        /*HDT_UTL_SecurityAccess securityClass = new HDT_UTL_SecurityAccess('DocumentSelected__c','Name, Case__c','create');

        securityClass.checkSecurityAccess();*/

        HDT_UTL_DatabaseService.insertSObject(documenti);

        /*try{

            if(DocumentSelected__c.SObjectType.getDescribe().isCreateable()){

                insert documenti;
        
            }
        } catch (Exception e){

            System.debug(e);

        }*/
        return;

    }

    @AuraEnabled
    public static List<string> checkExistingDocuments(List<String> documents, String caseId){

        List<DocumentSelected__c> documenti = [SELECT Name FROM DocumentSelected__c WHERE Case__c = :caseId WITH SECURITY_ENFORCED ];

        List<String> existingDocuments = new List<String>();

        for(DocumentSelected__c d : documenti){

            existingDocuments.add(d.Name);

        }

        return existingDocuments;

    }
}
