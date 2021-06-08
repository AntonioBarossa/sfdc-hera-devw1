/**
 * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)
 * @date 31/03/2021
 * @description HDT_UTL_Constants - Constants Utility Class
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */

public with sharing class HDT_UTL_Constants {

    @AuraEnabled
    public final String MASSIVLOADER_FILE_EXTENTION = 'csv';

    @AuraEnabled
    public final String MASSIVLOADER_STATUS_INATTESAlAVORAZIONE = 'In attesa di lavorazione';
    @AuraEnabled
    public final String MASSIVLOADER_STATUS_INLAVORAZIONE = 'In Lavorazione';
    @AuraEnabled
    public final String MASSIVLOADER_STATUS_CHIUSO = 'Chiuso';

    @AuraEnabled
    public final String MASSIVLOADER_PHASE_FILENONPROCESSATO = 'File non processato';
    @AuraEnabled
    public final String MASSIVLOADER_PHASE_FILEINELABORAZIONE = 'File in elaborazione';
    @AuraEnabled
    public final String MASSIVLOADER_PHASE_FILEPROCESSATO = 'File processato';

}