public with sharing class HDT_LC_CompleteCase {
    public static HDT_QR_Case caseQr = new HDT_QR_Case();
    public static HDT_SRV_Case caseSrv = new HDT_SRV_Case();
    @AuraEnabled
    public static String completeCase(String caseId){
        try {
            Case cs = caseQr.getRecordById(caseId);
            List<wrts_prcgvr__Activity__c> activities = HDT_QR_ActivityCustom.getRecordByCaseId(caseId);
            List<String> caseTypeList = new List<String>{
                'Contratti/Bonus Commerciale',
                'VOTIVE Modena/Intervento Riattivazione luce',
                'VOTIVE Modena/Nuovo contratto',
                'VOTIVE Modena/Subentro',
                'Modifica Contratti PreAttivazione',
                'Documentale/Copia Contratto'
            };
            if (caseTypeList.contains(cs.Type) || cs.RecordType.DeveloperName == 'HDT_RT_PostSalesVAS') {
                if(activities != null && !activities.isEmpty() && activities[0].wrts_prcgvr__Status__c == 'Completed' ){
                    Case caseToUpdate = new Case();
                    caseToUpdate.id = cs.Id;
                    caseToUpdate.Status = 'Closed';
                    caseToUpdate.Phase__c = 'Completata';
                    caseSrv.updateRecord(caseToUpdate);
                    return 'success';
                }
                else if(activities != null && !activities.isEmpty() && activities[0].wrts_prcgvr__Status__c != 'Completed'){
                    return 'Per poter chiudere il case, l\'activity  deve essere in stato "Completato"';
                } else {
                    return 'Il case non ha un activity associato';
                }
            } else {
                return 'Il case non è della tipologia di "Attivazioni"';
            }
        } catch (Exception e) {
            return e.getMessage();
        }
    }
}
