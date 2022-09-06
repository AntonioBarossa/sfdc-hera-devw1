/**
    * @author Carmine Scalise (carmine.scalise@webresults.it)
    * @date 21/07/2022
    * @description gestione dei CaseItem correlati ai Documenti Selezionati nel Flow: Gestione Pagamenti - Comunicazione Pagamento
    */
    @SuppressWarnings('PMD.ClassNamingConventions, PMD.IfElseStmtsMustUseBraces, PMD.IfStmtsMustUseBraces')
    public with sharing class HDT_UTL_ManageCaseItemTari {
        
        @InvocableMethod
        public static void manageCaseItem(List<String> caseInput) {
    
            // Cerco tutti i CaseItem legati al Case
            List<CaseItem__c> allCaseItemList = [
                SELECT Id, DocumentSelected__c, Case__c
                FROM CaseItem__c
                WHERE Case__c =: caseInput[0]
            ];
    
            // Cerco tutti i DocumentSelected legati al Case
            List<DocumentSelected__c> documentSelectedList = [
                SELECT Id, Case__c
                FROM DocumentSelected__c
                WHERE Case__c =: caseInput[0]
            ];
    
            // Trova CaseItem legati ai Documet cancellati
            List<CaseItem__c> annulledList = new List<CaseItem__c>();
            for(CaseItem__c caseItem : allCaseItemList) {
                boolean found = false;	
                for(DocumentSelected__c docSel : documentSelectedList) {
                    if(found == false) {
                        if(caseItem.DocumentSelected__c == docSel.Id) {
                            found = true;
                        }
                    }
                }
                if(found == false) {
                    annulledList.add(caseItem);
                }
            }
    
            // Annulla CaseItem senza legati a Documeti cancellati
            for(CaseItem__c caseItemNull : annulledList) {
                caseItemNull.Status__c = 'Annullato';
            }
        }
    }
    