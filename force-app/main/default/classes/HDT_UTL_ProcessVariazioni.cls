@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_UTL_ProcessVariazioni extends HDT_UTL_ProcessExecution {

    private Map<String, HDT_MassiveFieldsObjectMap__mdt> sobjectMap;
    private Map<String, String> mapCaseFields;
    private Map<String, String> mapWrapperCaseFields;
    private Set<String> accountIdSet = new Set<String>();
    private Set<String> contractCodeSet = new Set<String>();
    private Map<String, List<String>> itemRequestMap = new Map<String, List<String>>();
    private Map<String, Id> recordTypeMap = new Map<String, Id>();
    private List<MassiveLoaderRequestItem__c> itemsToSave;
    private List<Contract> contractList;
    private Case newCase;
    private Id recordTypeId;
    private Integer podIndex;
    private Integer contractIndex;
    private Integer accountIdIndex;

    public override void checks(){
        System.debug(LoggingLevel.DEBUG, 'checks');
        mapFieldsObject();

        System.debug(LoggingLevel.DEBUG, '>>> mapCaseFields: ' + String.valueOf(mapCaseFields));
        System.debug(LoggingLevel.DEBUG, '>>> mapWrapperCaseFields: ' + String.valueOf(mapWrapperCaseFields));
        System.debug(LoggingLevel.DEBUG, '>>> mapHeaderForWrapper: ' + String.valueOf(mapHeaderForWrapper));
        System.debug(LoggingLevel.DEBUG, '>>> mapHeaderByPosition: ' + String.valueOf(mapHeaderByPosition));

        System.debug(LoggingLevel.DEBUG, '>>> sobjectMap: ' + String.valueOf(sobjectMap));

        podIndex = mapHeaderForWrapper.get(mapWrapperCaseFields.get('POD'));
        contractIndex = mapHeaderForWrapper.get(mapWrapperCaseFields.get('CONTRATTO'));
        accountIdIndex = mapHeaderForWrapper.get(mapWrapperCaseFields.get('ACCOUNTID'));

        List<String> dataSplitted;
        for(MassiveLoaderRequestItem__c item : currentProcess.currentRequestItemList){
            dataSplitted = item.Data__c.split(',', -1);
            accountIdSet.add(dataSplitted[accountIdIndex]);
            contractCodeSet.add(dataSplitted[contractIndex]);
            itemRequestMap.put(item.Id, dataSplitted);
        }

    }

    public override void getRecords(){
        System.debug(LoggingLevel.DEBUG, 'getRecords');

        contractList = HDT_QR_ProcessPostSales.getContracts(contractList, contractCodeSet);

        recordTypeId = HDT_QR_ProcessPostSales.getRecordTypeId('HDT_RT_VariazioniEle');
        recordTypeMap.put('Energia Elettrica', recordTypeId);
        recordTypeId = HDT_QR_ProcessPostSales.getRecordTypeId('HDT_RT_VariazioniGas');
        recordTypeMap.put('Gas', recordTypeId);
    }

    public override void finalUpdate(){
        System.debug(LoggingLevel.DEBUG, 'finalUpdate');

        if(itemsToSave.size() > 0){
            update itemsToSave;
        }

    }

    public override void manageCatchException(Integer batchSize, List<MassiveLoaderRequestItem__c> itemList, String message){
        for(MassiveLoaderRequestItem__c item : itemList){
            item.Status__c = 'Errore';
            item.StatusDescription__c = message;
        }
        update itemList;
    }

    private void mapFieldsObject(){

        List<HDT_MassiveFieldsObjectMap__mdt> allFieldForThisProcess;

        mapCaseFields = new Map<String, String>();
        mapWrapperCaseFields = new Map<String, String>();
        sobjectMap = new Map<String, HDT_MassiveFieldsObjectMap__mdt>();

        allFieldForThisProcess = HDT_QR_ProcessPostSales.getMapFieldsObjectByDeveloperName('Var%');

        for(HDT_MassiveFieldsObjectMap__mdt temp : allFieldForThisProcess){
            if(temp.objectType__c.equalsIgnoreCase('WrapperCase')){
                mapWrapperCaseFields.put(temp.labelField__c, temp.nameField__c);
            } else {
                mapCaseFields.put(temp.MasterLabel, temp.nameField__c);
                sobjectMap.put(temp.MasterLabel, temp);
            }
            
        }

    }

    public static void setDataForTest_ModificheAnagrafiche(){

        Id massiveLoaderRequestId = 'a3d3O000000WwZOQA0';

        delete [SELECT Id FROM MassiveLoaderRequestItem__c WHERE MassiveLoaderRequest__c = :massiveLoaderRequestId];
        delete [
            SELECT Id, Type, AccountId, NotPerformedBefore__c, WrittenReceiptRequestDate__c, CustomerRecessDate__c, VulturePracticeReference__c,
                   DistributorNote__c, ServicePoint__c, BillingProfile__c, Contract__c, RecordTypeId, ContactId, CausalCode__c, 
                   Phase__c, Status, CancellationReason__c
            FROM Case
            WHERE Createddate = today AND CreatedById = '0051X0000055rbNQAQ'
        ];
    
        List<MassiveLoaderRequestItem__c> itemsList = new List<MassiveLoaderRequestItem__c>();
        MassiveLoaderRequestItem__c item;
    
        for(Integer n=0; n<2; n++){
            item = new MassiveLoaderRequestItem__c();
            item.MassiveLoaderRequest__c = massiveLoaderRequestId;
            item.Status__c = 'In attesa di lavorazione';
            item.Data__c = '';
            item.Data__c += ',';// PROCESSO
            item.Data__c += ',';// ACCOUNTID
            item.Data__c += ',';// SOTTOPROCESSO
            item.Data__c += ',';// POD
            item.Data__c += ',';// CONTRATTO
            item.Data__c += ',';// ELEMENTI_DETTAGLIO
            item.Data__c += ',';// SERVIZIO_ENERGIA
            item.Data__c += ',';// DATA_VARIAZIONE
            item.Data__c += ',';// MATRICOLA
            item.Data__c += ',';// RIF_VOLTURA
            item.Data__c += ',';// NOTE_DL
            item.Data__c += ',';// CORRETTORE
            item.Data__c += ',';// DATA_LETTURA
            item.Data__c += ',';// DATA_VAR_RESIDENZA
            item.Data__c += ',';// RESIDENTE
            item.Data__c += ',';// INDIRIZZO_FORN
            item.Data__c += ',';// COMUNE
            item.Data__c += ',';// NAZIONE
            item.Data__c += ',';// LOCALITA
            item.Data__c += ',';// CAP
            item.Data__c += ',';// PROVINCIA
            item.Data__c += ',';// VIA
            item.Data__c += ',';// CIVICO
            item.Data__c += ',';// ESTENSIONE_CIVICO
            item.Data__c += ',';// CATEGORIA_USO
            item.Data__c += ',';// TIPO_FORNITURA
            item.Data__c += ',';// TIPO_IMPIANTO
            item.Data__c += ',';// IMPOSTE
            item.Data__c += ',';// DATA_DECORRENZA
            item.Data__c += ''; // IVA
            itemsList.add(item);
        }
        insert itemsList;
    
        MassiveLoaderRequest__c mlr = new MassiveLoaderRequest__c();
        mlr.Id = massiveLoaderRequestId;
        mlr.Status__c = 'In attesa di lavorazione';
        update mlr;
    
    }

}