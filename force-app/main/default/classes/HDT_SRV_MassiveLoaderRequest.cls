/**
 * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)
 * @date 31/03/2021
 * @description HDT_SRV_MassiveLoaderRequest - Class that holds CRUD and business logic for MassiveLoaderRequest__c
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */

public with sharing class HDT_SRV_MassiveLoaderRequest {


    /**
    * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)
    * @description HDT_SRV_MassiveLoaderRequest.createNewRequestRecord() - Create new Massive Loader Request record
    * @param processType ProcessType__c of the new MassiveLoaderRequest
    * @param priority Priority__c of the new MassivoLoaderRequest
    * @return the inserted record
    */

    public MassiveLoaderRequest__c createNewRequestRecord(String processType, Integer priority) {

        MassiveLoaderRequest__c newMassiveLoaderRequest = new MassiveLoaderRequest__c(ProcessType__c = processType, Priority__c = priority);

        Database.insert(newMassiveLoaderRequest);

        return newMassiveLoaderRequest;
    }

    /**
    * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)
    * @description HDT_SRV_MassiveLoaderRequest.updateRequestRecord() - Update provided list of MassiveLoaderRequest__c
    * @param massiveLoaderRequests the list of MassiveLoaderRequest records to update
    * @return the provided list of records
    */

    public List<MassiveLoaderRequest__c> updateRequestRecord(List<MassiveLoaderRequest__c> massiveLoaderRequests) {

        Database.update(massiveLoaderRequests);

        return massiveLoaderRequests;

    }

}