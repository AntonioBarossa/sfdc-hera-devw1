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

    //Account RecordType Business
    @AuraEnabled
    public final String ACCOUNT_RECORDTYPE_DEVELOPERNAME_BUSINESS = 'HDT_RT_Business';
    @AuraEnabled
    public final String ACCOUNT_RECORDTYPEID_BUSINESS =
    Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCOUNT_RECORDTYPE_DEVELOPERNAME_BUSINESS).getRecordTypeId();

    //Account RecordType Residenziale
    @AuraEnabled
    public final String ACCOUNT_RECORDTYPE_DEVELOPERNAME_RESINDEZIALE = 'HDT_RT_Residenziale';
    @AuraEnabled
    public final String ACCOUNT_RECORDTYPEID_RESINDEZIALE =
    Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCOUNT_RECORDTYPE_DEVELOPERNAME_RESINDEZIALE).getRecordTypeId();


    //Order RecordType Default
    @AuraEnabled
    public final String ORDER_RECORDTYPE_DEVELOPERNAME_DEFAULT = 'HDT_RT_Default';
    @AuraEnabled
    public final String ORDER_RECORDTYPEID_DEFAULT =
    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(ORDER_RECORDTYPE_DEVELOPERNAME_DEFAULT).getRecordTypeId();


    //Order RecordType Voltura
    @AuraEnabled
    public final String ORDER_RECORDTYPE_DEVELOPERNAME_VOLTURA = 'HDT_RT_Voltura';
    @AuraEnabled
    public final String ORDER_RECORDTYPEID_VOLTURA =
    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(ORDER_RECORDTYPE_DEVELOPERNAME_VOLTURA).getRecordTypeId();
    

    //Order RecordType OrderDossier
    @AuraEnabled
    public final String ORDER_RECORDTYPE_DEVELOPERNAME_ORDERDOSSIER = 'HDT_RT_OrderDossier';
    @AuraEnabled
    public final String ORDER_RECORDTYPEID_ORDERDOSSIER =
    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(ORDER_RECORDTYPE_DEVELOPERNAME_ORDERDOSSIER).getRecordTypeId();

    //Case RecordType Morosita (generico)
    @AuraEnabled
    public final String CASE_RECORDTYPE_DEVELOPERNAME_MOROSITA = 'HDT_RT_OrderDossier';
    @AuraEnabled
    public final String CASE_RECORDTYPEID_MOROSITA =
    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(CASE_RECORDTYPE_DEVELOPERNAME_MOROSITA).getRecordTypeId();
}
