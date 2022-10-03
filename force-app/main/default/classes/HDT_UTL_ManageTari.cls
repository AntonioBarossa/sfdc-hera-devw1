@SuppressWarnings('PMD.ClassNamingConventions, PMD.IfElseStmtsMustUseBraces, PMD.IfStmtsMustUseBraces')
public with sharing class HDT_UTL_ManageTari {

    @InvocableMethod
    public static List<Boolean> checkTariProcess(List<String> serviceCatalogId) {
        List<Boolean> checkTari = new List<Boolean>();
        checkTari.add(false);

        List<AccountStatementFilter__c> accountStmList = [
            SELECT Id, DocumentSelected__c
            FROM AccountStatementFilter__c 
            WHERE Id =: serviceCatalogId[0]
            WITH SECURITY_ENFORCED
        ];
        
        if(accountStmList.isEmpty()) return checkTari;//Empty list return false
        
        AccountStatementFilter__c astm = accountStmList[0];
        
        List<Object> resultList = (List<Object>) JSON.deserializeUntyped(astm.DocumentSelected__c);
        
        if(resultList.isEmpty())    return checkTari;//Empty list return false
        
        Map<String, Object> resultMap = (Map<String, Object>) resultList[0];
        List<Object> indentedList = (List<Object>) resultMap.get('secondoLivelloInformativo');
        if(indentedList == null)return checkTari;
        for(Object secondLevelObj : indentedList){
            Map<String, Object> secondLevelMap = (Map<String, Object>) secondLevelObj;
            String resulString = (String)secondLevelMap.get('settoreMerceologico');
            checkTari[0] = 'Tari'.equalsIgnoreCase(resulString); // Potrebbe essere Ambiente e non Tari
            //system.debug(resulString);
            if(!checkTari[0])   break; // Devono essere tutti TARI ??? se si OK(Controllo !) Altrimenti Leva !!!
        }
        return checkTari;
    }
    
}