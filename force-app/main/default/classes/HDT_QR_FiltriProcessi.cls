/**
* @author Luca Molino (luca.molino@dunegroup.it)
* @date 07/02/2021
* @description HDT_QR_FiltriProcessi for Test Classes
* @history Luca Molino – 07/02/2021 – Created class
* Fabio Palladino - 12/10/2022 - Adeguamento del valore di ritorno (lista invece che singolo record)
*/
public with sharing class HDT_QR_FiltriProcessi {
    
    private static HDT_SRV_Contract contractSrv = new HDT_SRV_Contract();

    @AuraEnabled
    public static HDT_FiltriProcessiSelFornitura__mdt getCustomMetadata(String processType){
        contractSrv.checkReadAccess('Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, ContrattiCliente__c, Disalimentabile__c, StatoContratto__c, StatoFornitura__c, TipoProcesso__c, TipoServizio__c, FornitureCliente__c, RateCategory__c');
        HDT_FiltriProcessiSelFornitura__mdt processi = new HDT_FiltriProcessiSelFornitura__mdt();
        system.debug('processType : '+processType);
        String query = 'SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, ContrattiCliente__c, Disalimentabile__c, StatoContratto__c, StatoFornitura__c, TipoProcesso__c, TipoServizio__c, FornitureCliente__c,RateCategory__c FROM HDT_FiltriProcessiSelFornitura__mdt WHERE  TipoProcesso__c=: processType WITH SECURITY_ENFORCED';
        List<HDT_FiltriProcessiSelFornitura__mdt> listProcessi = Database.query(query);
        if(listProcessi != null && listProcessi.size()> 0){
            processi= listProcessi[0];
        }
        return processi;
    }
    
    @AuraEnabled
    public static List<HDT_FiltriProcessiSelFornitura__mdt> getCustomMetadataList(String processType){
        //contractSrv.checkReadAccess('Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, ContrattiCliente__c, Disalimentabile__c, StatoContratto__c, StatoFornitura__c, TipoProcesso__c, TipoServizio__c, FornitureCliente__c, RateCategory__c');
        system.debug('processType : '+processType);
        String fields = 'Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, ContrattiCliente__c, Disalimentabile__c, StatoContratto__c, StatoFornitura__c, TipoProcesso__c, TipoServizio__c, FornitureCliente__c, RateCategory__c';
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('HDT_FiltriProcessiSelFornitura__mdt', fields, 'read');
        securityAccess.checkSecurityAccess();
        String query = 'SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, ContrattiCliente__c, Disalimentabile__c, StatoContratto__c, StatoFornitura__c, TipoProcesso__c, TipoServizio__c, FornitureCliente__c,RateCategory__c FROM HDT_FiltriProcessiSelFornitura__mdt WHERE  TipoProcesso__c=: processType WITH SECURITY_ENFORCED';
        return Database.query(query);
    }
}
