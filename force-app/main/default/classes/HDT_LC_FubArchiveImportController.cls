/**
 * @author Lorenzo Gulotta (lorenzo.gulotta@webresults.it)
 * @date 28/06/2021
 * @description HDT_LC_FubArchiveImportController Classes
 * @history Lorenzo Gulotta 28/06/2021 – Created class
 */

public with sharing class HDT_LC_FubArchiveImportController {

    @AuraEnabled
    public static Boolean fubArchiveImportBatch(String recordId, String csvNumbers) {

        HDT_BA_ImportFubFile importFile = new HDT_BA_ImportFubFile(recordId,csvNumbers);
       // importFile.FUBProcessingId = recordId;
       // importFile.csvNumbers = csvNumbers;
        ID batchProcessId = Database.executeBatch(importFile);
        System.debug(batchProcessId);
        if (batchProcessId != null) { return true; } else { return false;}
    }
}