/**
 * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)
 * @date 31/03/2021
 * @description HDT_UTL_Constants - Constants Utility Class
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */

@SuppressWarnings('PMD.ExcessivePublicCount,PMD.TooManyFields')
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

     //Account RecordType Partner
     @AuraEnabled
     public final String ACCOUNT_RECORDTYPE_DEVELOPERNAME_PARTNER = 'HDT_RT_Partner';
     @AuraEnabled
     public final String ACCOUNT_RECORDTYPEID_PARTNER =
     Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCOUNT_RECORDTYPE_DEVELOPERNAME_PARTNER).getRecordTypeId();

     //Account RecordType Distributore
     @AuraEnabled
     public final String ACCOUNT_RECORDTYPE_DEVELOPERNAME_DISTRIBUTORE = 'HDT_RT_Distributore';
     @AuraEnabled
     public final String ACCOUNT_RECORDTYPEID_DISTRIBUTORE =
     Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCOUNT_RECORDTYPE_DEVELOPERNAME_DISTRIBUTORE).getRecordTypeId();

    //Activity Custom RecordType Credit Check KO
    @AuraEnabled
    public final String ACTIVITYCUSTOM_RECORDTYPE_DEVELOPERNAME_CREDITCHECKKO = 'HDT_RT_CreditCheckKO';
    @AuraEnabled
    public final String ACTIVITYCUSTOM_RECORDTYPEID_CREDITCHECKKO =
    Schema.SObjectType.wrts_prcgvr__Activity__c.getRecordTypeInfosByDeveloperName().get(ACTIVITYCUSTOM_RECORDTYPE_DEVELOPERNAME_CREDITCHECKKO).getRecordTypeId();

    //Activity Custom RecordType Credit Check KO
    @AuraEnabled
    public final String ACTIVITYCUSTOM_RECORDTYPE_DEVELOPERNAME_KOPRECEDETECLIENTE = 'HDT_RT_KoPrecedeteCliente';
    @AuraEnabled
    public final String ACTIVITYCUSTOM_RECORDTYPEID_KOPRECEDETECLIENTE =
    Schema.SObjectType.wrts_prcgvr__Activity__c.getRecordTypeInfosByDeveloperName().get(ACTIVITYCUSTOM_RECORDTYPE_DEVELOPERNAME_KOPRECEDETECLIENTE).getRecordTypeId();

    //Activity Custom RecordType Credit Check KO
    @AuraEnabled
    public final String ACTIVITYCUSTOM_RECORDTYPE_DEVELOPERNAME_DISTRIBUTORAPPOINTMENT = 'HDT_RT_DistributorAppointment';
    @AuraEnabled
    public final String ACTIVITYCUSTOM_RECORDTYPEID_DISTRIBUTORAPPOINTMENT =
    Schema.SObjectType.wrts_prcgvr__Activity__c.getRecordTypeInfosByDeveloperName().get(ACTIVITYCUSTOM_RECORDTYPE_DEVELOPERNAME_DISTRIBUTORAPPOINTMENT).getRecordTypeId();

    //Activity Custom RecordType comfort quality call
    @AuraEnabled
    public final String ACTIVITYCUSTOM_RECORDTYPE_DEVELOPERNAME_COMFORTQUALITYCALL = 'HDT_RT_ComfortQualityCall';
    @AuraEnabled
    public final String ACTIVITYCUSTOM_RECORDTYPEID_COMFORTQUALITYCALL =
    Schema.SObjectType.wrts_prcgvr__Activity__c.getRecordTypeInfosByDeveloperName().get(ACTIVITYCUSTOM_RECORDTYPE_DEVELOPERNAME_COMFORTQUALITYCALL).getRecordTypeId();

    //Activity Custom RecordType Chiamata Outbound
    @AuraEnabled
    public final String ACTIVITYCUSTOM_RECORDTYPE_DEVELOPERNAME_CHIAMATAOUTBOUND = 'HDT_RT_ChiamataOutbound';
    @AuraEnabled
    public final String ACTIVITYCUSTOM_RECORDTYPEID_CHIAMATAOUTBOUND =
    Schema.SObjectType.wrts_prcgvr__Activity__c.getRecordTypeInfosByDeveloperName().get(ACTIVITYCUSTOM_RECORDTYPE_DEVELOPERNAME_CHIAMATAOUTBOUND).getRecordTypeId();

    //Order RecordType Default
    @AuraEnabled
    public final String ORDER_RECORDTYPE_DEVELOPERNAME_DEFAULT = 'HDT_RT_Default';
    @AuraEnabled
    public final String ORDER_RECORDTYPEID_DEFAULT =
    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(ORDER_RECORDTYPE_DEVELOPERNAME_DEFAULT).getRecordTypeId();

    //Order RecordType VAS
    @AuraEnabled
    public final String ORDER_RECORDTYPE_DEVELOPERNAME_VAS = 'HDT_RT_VAS';
    @AuraEnabled
    public final String ORDER_RECORDTYPEID_VAS =
    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(ORDER_RECORDTYPE_DEVELOPERNAME_VAS).getRecordTypeId();

    //Order RecordType Cambio Offerta
    @AuraEnabled
    public final String ORDER_RECORDTYPE_CAMBIO_OFFERTA = 'HDT_RT_CambioOfferta';
    @AuraEnabled
    public final String ORDER_RECORDTYPEID_CAMBIO_OFFERTA =
    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(ORDER_RECORDTYPE_CAMBIO_OFFERTA).getRecordTypeId();

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

    // Order RecordType Subentro
    @AuraEnabled
    public final String ORDER_RECORDTYPE_DEVELOPERNAME_SUBENTRO = 'HDT_RT_Subentro';
    @AuraEnabled
    public final String ORDER_RECORDTYPEID_SUBENTRO =
    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(ORDER_RECORDTYPE_DEVELOPERNAME_SUBENTRO).getRecordTypeId();

    // Order RecordType SwitchIn
    @AuraEnabled
    public final String ORDER_RECORDTYPE_DEVELOPERNAME_SWITCHIN = 'HDT_RT_SwitchIn';
    @AuraEnabled
    public final String ORDER_RECORDTYPEID_SWITCHIN =
    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(ORDER_RECORDTYPE_DEVELOPERNAME_SWITCHIN).getRecordTypeId();

    // Order RecordType Attivazione
    @AuraEnabled
    public final String ORDER_RECORDTYPE_DEVELOPERNAME_ATTIVAZIONE = 'HDT_RT_Attivazione';
    @AuraEnabled
    public final String ORDER_RECORDTYPEID_ATTIVAZIONE =
    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(ORDER_RECORDTYPE_DEVELOPERNAME_ATTIVAZIONE).getRecordTypeId();

    // Order RecordType Attivazione con Modifica
    @AuraEnabled
    public final String ORDER_RECORDTYPE_DEVELOPERNAME_ATTIVAZIONECONMODIFICA = 'HDT_RT_AttivazioneConModifica';
    @AuraEnabled
    public final String ORDER_RECORDTYPEID_ATTIVAZIONECONMODIFICA =
    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(ORDER_RECORDTYPE_DEVELOPERNAME_ATTIVAZIONECONMODIFICA).getRecordTypeId();

    //@frpanico 05/08 Case RecordType default Morosita
    @AuraEnabled
    public final String CASE_RECORDTYPE_DEVELOPERNAME_MOROSITA = 'HDT_RT_Morosita';
    @AuraEnabled
    public final String CASE_RECORDTYPEID_MOROSITA =
    Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CASE_RECORDTYPE_DEVELOPERNAME_MOROSITA).getRecordTypeId();

    //@anbuzzi 31/08 Case RecordType Documentale/Copia Contratto
    @AuraEnabled
    public final String CASE_RECORDTYPE_DEVELOPERNAME_DOCUMENTALECOPIACONTRATTO = 'HDT_RT_DocCopiaContratto';
    @AuraEnabled
    public final String CASE_RECORDTYPEID_DOCUMENTALECOPIACONTRATTO =
    Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CASE_RECORDTYPE_DEVELOPERNAME_DOCUMENTALECOPIACONTRATTO).getRecordTypeId();
    
    //@anbuzzi 31/08 Case RecordType AUTOLETTURA
    @AuraEnabled
    public final String CASE_RECORDTYPE_DEVELOPERNAME_AUTOLETTURA = 'HDT_RT_Autolettura';
    @AuraEnabled
    public final String CASE_RECORDTYPEID_AUTOLETTURA =
    Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CASE_RECORDTYPE_DEVELOPERNAME_AUTOLETTURA).getRecordTypeId();
    
    //@anbuzzi 12/09 Case RecordType PAGAMENTI - PIANO RATEIZZAZIONE
    @AuraEnabled
    public final String CASE_RECORDTYPE_DEVELOPERNAME_PAG_PIANORATEIZZAZIONE = 'HDT_RT_PianoRateizzazione';
    @AuraEnabled
    public final String CASE_RECORDTYPEID_PAG_PIANORATEIZZAZIONE =
    Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CASE_RECORDTYPE_DEVELOPERNAME_PAG_PIANORATEIZZAZIONE).getRecordTypeId();

    //Case RecordType Generiche Attivazioni
    @AuraEnabled
    public final String CASE_RECORDTYPE_DEVELOPERNAME_GENERICHE_ATTIVAZIONI = 'HDT_RT_GenericheAttivazioni';
    @AuraEnabled
    public final String CASE_RECORDTYPEID_GENERICHE_ATTIVAZIONI =
    Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CASE_RECORDTYPE_DEVELOPERNAME_GENERICHE_ATTIVAZIONI).getRecordTypeId();

    //Case RecordType PostSalesVAS
    @AuraEnabled
    public final String CASE_RECORDTYPE_DEVELOPERNAME_POST_SALES_VAS = 'HDT_RT_PostSalesVAS';
    @AuraEnabled
    public final String CASE_RECORDTYPEID_POST_SALES_VAS =
    Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CASE_RECORDTYPE_DEVELOPERNAME_POST_SALES_VAS).getRecordTypeId();

    //Case RecordType Consumo Anomalo Idrico
    @AuraEnabled
    public final String CASE_RECORDTYPE_DEVELOPERNAME_CONSUMO_ANOMALO_IDRICO='HDT_RT_ConsumoAnomaloIdrico';
    @AuraEnabled
    public final String CASE_RECORDTYPEID_CONSUMO_ANOMALO_IDRICO=
    Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CASE_RECORDTYPE_DEVELOPERNAME_CONSUMO_ANOMALO_IDRICO).getRecordTypeId();

    // Order RecordType Riattivazione Non Morose
    @AuraEnabled
    public final String ORDER_RECORDTYPE_DEVELOPERNAME_RIATTIVAZIONENONMOROSE = 'HDT_RT_RiattivazioniNonMorose';
    @AuraEnabled
    public final String ORDER_RECORDTYPEID_RIATTIVAZIONENONMOROSE =
    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(ORDER_RECORDTYPE_DEVELOPERNAME_RIATTIVAZIONENONMOROSE).getRecordTypeId();


    // Order RecordType Connessione Con Attivazione
    @AuraEnabled
    public final String ORDER_RECORDTYPE_DEVELOPERNAME_CONNESSIONECONATTIVAZIONE = 'HDT_RT_ConnessioneConAttivazione';
    @AuraEnabled
    public final String ORDER_RECORDTYPEID_CONNESSIONECONATTIVAZIONE =
    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(ORDER_RECORDTYPE_DEVELOPERNAME_CONNESSIONECONATTIVAZIONE).getRecordTypeId();

     // Order RecordType Temporanea Nuova Att
     @AuraEnabled
     public final String ORDER_RECORDTYPE_DEVELOPERNAME_TEMPORANEANUOVAATT = 'HDT_RT_TemporaneaNuovaAtt';
     @AuraEnabled
     public final String ORDER_RECORDTYPEID_TEMPORANEANUOVAATT =
     Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(ORDER_RECORDTYPE_DEVELOPERNAME_TEMPORANEANUOVAATT).getRecordTypeId();
    
    //ServicePoint RecordType Punto Elettrico
    @AuraEnabled
    public final String SERVICEPOINT_RECORDTYPE_DEVELOPERNAME_PELETRICCO = 'HDT_RT_Ele';
    @AuraEnabled
    public final String SERVICEPOINT_RECORDTYPEID_PELETRICCO =
    Schema.SObjectType.ServicePoint__c.getRecordTypeInfosByDeveloperName().get(SERVICEPOINT_RECORDTYPE_DEVELOPERNAME_PELETRICCO).getRecordTypeId();

    //ServicePoint Recordtype Gas
    public final String SERVICEPOINT_RECORDTYPE_DEVELOPERNAME_GAS = 'HDT_RT_Gas';
    @AuraEnabled
    public final String SERVICEPOINT_RECORDTYPEID_GAS =
    Schema.SObjectType.ServicePoint__c.getRecordTypeInfosByDeveloperName().get(SERVICEPOINT_RECORDTYPE_DEVELOPERNAME_GAS).getRecordTypeId();

    //Hera internal Profiles
    @AuraEnabled
    public final String SYSTEM_ADMINISTRATOR_NAME {
        get{

            switch on System.UserInfo.getLanguage() {
                when 'en_US' {
                    return 'System Administrator';
                } when 'it' {
                    return 'Amministratore del sistema';
                } when else {
                    return 'System Administrator';
                }
            }
            
        }
        set{
            SYSTEM_ADMINISTRATOR_NAME = 'System Administrator';
        }
    }

    @AuraEnabled
    public final String HERA_M2M_INTEGRATION_NAME = 'Hera M2M Integration User';
    @AuraEnabled
    public final String HERA_STANDARD_USER_NAME = 'Hera Standard User';
    @AuraEnabled
    public final String HERA_SYSTEM_ADMINISTRATOR_NAME = 'Hera System Administrator';
    @AuraEnabled
    public final String HERA_SYSTEM_INTEGRATOR_NAME = 'Hera System Integrator';

    //Hera partner Profiles
    @AuraEnabled
    public final String HERA_DOOR2DOOR_PARTNER_NAME = 'Hera Door2Door Partner User';
    @AuraEnabled
    public final String HERA_TELESELLER_PARTNER_NAME = 'Hera Teleseller Partner User';

    //Standard Salesforce Profiles
    @AuraEnabled
    public final string MINIMUM_ACCESS_SALESFORCE = 'Minimum Access - Salesforce';

    //Hera CPQ Permission Sets
    @AuraEnabled
    public final String PERMISSIONSET_HDT_SALESFORCE_CPQ_ADMIN_NAME = 'HDT_SalesforceCPQAdmin';
    @AuraEnabled
    public final String PERMISSIONSET_HDT_SALESFORCE_CPQ_LICENSE_NAME = 'HDT_SalesforceCPQLicense';
    @AuraEnabled
    public final String PERMISSIONSET_HDT_SUPER_USER_CPQ = 'HDT_SuperUserCPQ';

    //APEX Classes Permission Set
    @AuraEnabled
    public final String PERMISSIONSET_HDT_APEXCLASSES = 'HDT_ApexClasses';

    //Voltura Retroattiva Permission set
    @AuraEnabled
    public final string PERMISSIONSET_HDT_VOLTURARETROATTIVA = 'HDT_VolturaRetroattiva';

    // Enable Credit Check Permission set
    @AuraEnabled
    public final string PERMISSIONSET_HDT_ENABLECREDITCHECK = 'HDT_EnableCreditCheck';

    
    //ProtocolManualActivities
    @AuraEnabled
    public final string PERMISSIONSET_HDT_PROTOCOLMANUALACTIVITIES = 'HDT_ProtocolManualActivities';
    
    //Contact Point picklist domains
    @AuraEnabled
    public final String CONTACTPOINT_STATUS_VERIFICATO = 'Verificato';
    @AuraEnabled
    public final String CONTACTPOINT_STATUS_NON_VERIFICATO = 'Non Verificato';

    //Account picklist domains
    public final string ACCOUNT_CUSTOMER_ACCOUNT_STATUS_CUSTOMER = 'Customer';
    public final string ACCOUNT_CUSTOMER_ACCOUNT_STATUS_EX_CUSTOMER = 'Ex-Customer';
    public final string ACCOUNT_CUSTOMER_ACCOUNT_STATUS_PROSPECT = 'Prospect';
    
    //Knowledge Article Record Types
    @AuraEnabled
    public final String KNOWLEDGEARTICLE_RECORDTYPE_DEVELOPERNAME_FAQ = 'HDT_RT_FAQ';
    @AuraEnabled
    public final String KNOWLEDGEARTICLE_RECORDTYPEID_FAQ =
    Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get(KNOWLEDGEARTICLE_RECORDTYPE_DEVELOPERNAME_FAQ).getRecordTypeId();
    

     
    //Custom Permissions
    @AuraEnabled
    public final string CUSTOMPERMISSION_NAME_SALESFORCECPQADMIN = 'HDT_CP_SalesforceCPQAdmin';

    //Custom Permissions
    @AuraEnabled
    public final string CUSTOMPERMISSION_NAME_HIDEGLOBALHEADER = 'HideGlobalHeader';

    //User Roles
    @AuraEnabled
    public final string USERROLE_DEVELOPERNAME_BACKOFFICE = 'HDT_BackOffice';

    //User Roles
    @AuraEnabled
    public final string USERROLE_DEVELOPERNAME_FRONTOFFICE_AAAEBT = 'HDT_FrontOffice_AAAEBT';

    //User Roles
    @AuraEnabled
    public final string USERROLE_DEVELOPERNAME_FRONTOFFICE_MMS = 'HDT_FrontOffice_MMS';

    //User Roles
    @AuraEnabled
    public final string USERROLE_DEVELOPERNAME_FRONTOFFICE_RESELLER = 'HDT_FrontOffice_Reseller';

    //Other
    @AuraEnabled
    public final string QUOTE_PROFILEFIELD_SALESFORCECPQADMIN = 'Amministratore CPQ';

}
