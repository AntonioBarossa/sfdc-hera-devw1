public with sharing class HDT_QR_FiltriProcessi {
    
    private static HDT_SRV_Contract contractSrv = new HDT_SRV_Contract();

    public HDT_QR_FiltriProcessi() {

    }

    @AuraEnabled
    public static HDT_FiltriProcessiSelFornitura__mdt getCustomMetadata(String processType){
        contractSrv.checkReadAccess('Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, ContrattiCliente__c, Disalimentabile__c, StatoContratto__c, StatoFornitura__c, TipoProcesso__c, TipoServizio__c, FornitureCliente__c');
        HDT_FiltriProcessiSelFornitura__mdt processi = new HDT_FiltriProcessiSelFornitura__mdt();
        system.debug('processType : '+processType);
        String query = 'SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, ContrattiCliente__c, Disalimentabile__c, StatoContratto__c, StatoFornitura__c, TipoProcesso__c, TipoServizio__c, FornitureCliente__c FROM HDT_FiltriProcessiSelFornitura__mdt WHERE  TipoProcesso__c=: processType WITH SECURITY_ENFORCED';
        //processi = [SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, ContrattiCliente__c, Disalimentabile__c, StatoContratto__c, StatoFornitura__c, TipoProcesso__c, TipoServizio__c, FornitureCliente__c FROM HDT_FiltriProcessiSelFornitura__mdt WHERE TipoProcesso__c=: processType ];
        List<HDT_FiltriProcessiSelFornitura__mdt> listProcessi = Database.query(query);
        if(listProcessi != null && listProcessi.size()> 0){
            processi= listProcessi[0];
        }
         return processi;
    }




    
}
