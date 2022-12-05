/** NTTDATA Classe per la gestione del caricamento massivo del Consumo Anomalo Idrico, 
 * richiamata dal batch HDT_BA_ProcessOrderCreation dinamicamente in base la configurazione del metadata HDT_MassiveLoaderProcess__mdt
 * e utilizzando il mapping field nel metadata HDT_MassiveFieldsObjectMap__mdt.
 **/
@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_ProcessConsumoAnomaloIdrico extends HDT_UTL_ProcessExecution {
    private List<MassiveLoaderRequestItem__c> itemsToSave;
    private Map<String, String> mapCaseFields;
    private Map<String, String> mapWrapperCaseFields;
    private List<HDT_WRP_ProcessObjects> processObjList;
    private Integer contractIndex;
    private Integer accountIndex;
    private Integer pdrIndex;
    private Integer shipmentTypeIndex;
    private Integer shipmentEmailIndex;
    private Integer shipmentAddressIndex;
    private Integer shipmentStreetNameIndex;
    private Integer shipmentStreetNumberIndex;
    private Integer shipmentPlaceIndex;
    private Integer shipmentProvinceIndex;
    private Integer shipmentCityIndex;
    private Integer shipmentPostalCodeIndex;
    private Integer shipmentCountryIndex;
    private Set<String>contractCodes=new Set<String>();
    private Map<String,Contract> contractCodePodMap=new Map<String,Contract>();
    public override void checks(){
        //Carico mapping
        mapFieldsObject();
        contractIndex = mapHeaderForWrapper.get('CONTRATTO');
        accountIndex = mapHeaderForWrapper.get('ACCOUNTID');
        pdrIndex=mapHeaderForWrapper.get('POD');
        shipmentTypeIndex=mapHeaderForWrapper.get('MODALITASPEDIZIONE');
        shipmentEmailIndex=mapHeaderForWrapper.get('EMAILSPEDIZIONE');
        shipmentAddressIndex=mapHeaderForWrapper.get('INDIRIZZOSPEDIZIONE');
        shipmentStreetNameIndex=mapHeaderForWrapper.get('NOMEVIA');
        shipmentStreetNumberIndex=mapHeaderForWrapper.get('CIVICO');
        shipmentPlaceIndex=mapHeaderForWrapper.get('LOCALITA');
        shipmentProvinceIndex=mapHeaderForWrapper.get('PROVINCIA');
        shipmentCityIndex=mapHeaderForWrapper.get('COMUNE');
        shipmentPostalCodeIndex=mapHeaderForWrapper.get('CAP');
        shipmentCountryIndex=mapHeaderForWrapper.get('STATO');
        itemsToSave = new List<MassiveLoaderRequestItem__c>();
        HDT_WRP_ProcessObjects processObj;
        processObjList = new List<HDT_WRP_ProcessObjects>();
        List<String> tempSplitedFields;
        for(MassiveLoaderRequestItem__c item : requestItemList){
            tempSplitedFields = new List<String>();
            tempSplitedFields = item.Data__c.split(splitCharacter, -1);//valore dei campi
            checkRequiredFields(item, tempSplitedFields);
            if(String.isNotBlank(item.Status__c) && item.Status__c.equalsIgnoreCase('Errore')){
                itemsToSave.add(item);
                continue;
            }
            contractCodes.add(tempSplitedFields[contractIndex]);
            processObj = new HDT_WRP_ProcessObjects();
            processObj.requestItem = item;
            processObj.csvSplitted = tempSplitedFields;
            processObjList.add(processObj);
        }
    }

    public override void getRecords(){
        HDT_QR_Contract qrContract= new HDT_QR_Contract();
        for(Contract tmpContract:qrContract.getContractByContractCodeConsumoAnomaloIdrico(contractCodes)){
            contractCodePodMap.put(tmpContract.SAPContractCode__c,tmpContract);
        }
    }

    public override void registryCreation(){
        List<Case> caseToInsert = new List<Case>();
        List<MassiveLoaderRequestItem__c> requestItemForUpsert=new List<MassiveLoaderRequestItem__c>();
        for(HDT_WRP_ProcessObjects currentObj:processObjList){
            currentObj.newCase=new Case(Phase__c=Label.consumoAnomaloIdricoDefaultPhase, Status=Label.consumoAnomaloIdricoDefaultStatus,RecordTypeId=constant.CASE_RECORDTYPEID_CONSUMO_ANOMALO_IDRICO,Cluster__c=Label.consumoAnomaloIdricoDefaultCluster);
            String fieldConversionError='';
            Integer count = 0;
            for (String tempField : currentObj.csvSplitted) {
                if(String.isNotBlank(mapCaseFields.get(mapHeaderByPosition.get(count))) && String.isNotBlank(tempField)){
                    String fieldValue= String.isBlank(currentObj.csvSplitted[count]) ? '':currentObj.csvSplitted[count];
                    fieldConversionError = mapTypeField(currentObj.newCase, mapCaseFields, count, fieldValue);
                    if(String.isNotBlank(fieldConversionError)){
                        break;
                    }
                }
                count++;
            }
            if(String.isNotEmpty(fieldConversionError)){
                itemsToSave.add(setErrorItem(currentObj.requestItem, fieldConversionError));
                continue;
            }
            if(errorForPicklistValue('Case', 'Type', currentObj.newCase.Type)){
                itemsToSave.add(setErrorItem(currentObj.requestItem, Label.caseTypeError + currentObj.newCase.Type));
                continue;
            }
            Map<String,Object>integrityResult=integrityChecks(currentObj.csvSplitted);
            if(! (Boolean)integrityResult.get('checksAreValid')){
                itemsToSave.add(setErrorItem(currentObj.requestItem, (String) integrityResult.get('errorMessage')));
                continue;
            }
            try{
                currentObj.newCase=caseEnrichment(currentObj.newCase,contractCodePodMap.get(currentObj.csvSplitted[contractIndex]));
            }catch (Exception e){
                itemsToSave.add(setErrorItem(currentObj.requestItem, e.getMessage()));
                continue;
            }
            caseToInsert.add(currentObj.newCase);
            requestItemForUpsert.add(currentObj.requestItem);
        }
        if(caseToInsert.size()>0){
            HDT_WRP_SaveResponse saveResponse=databaseUpsert(caseToInsert,requestItemForUpsert,'Case');
            if(saveResponse.reponseItemList.size() > 0){
                itemsToSave.addAll(saveResponse.reponseItemList);
            }
        }
    }

    private Case caseEnrichment(Case caseToEnrich, Contract dataSource){
        caseToEnrich.ServicePoint__c=dataSource.ServicePoint__c;
        caseToEnrich.Contract__c=dataSource.Id;
        caseToEnrich.AccountId=dataSource.AccountId;
        caseToEnrich.ContactId=dataSource.Contact__c;
        caseToEnrich.JointBottomAdhesion__c=dataSource.ServicePoint__r.JointBottomAdhesion__c;
        caseToEnrich.PaySewer__c=dataSource.ServicePoint__r.PaySewer__c;
        caseToEnrich.PayPurification__c=dataSource.ServicePoint__r.PayPurification__c;
        caseToEnrich.MeterCode__c=dataSource.ServicePoint__r.MeterSN__c;
        caseToEnrich.Commodity__c =dataSource.ServicePoint__r.CommoditySector__c;
        caseToEnrich.Distributor__c=dataSource.ServicePoint__r.Distributor__c;
        caseToEnrich.SupplyType__c=dataSource.ServicePoint__r.SupplyType__c;
        caseToEnrich.AnnualConsumption__c=dataSource.ServicePoint__r.AnnualConsumption__c;
        caseToEnrich.Disconnectable__c=dataSource.ServicePoint__r.Disconnectable__c;
        caseToEnrich.DistributorCode__c=dataSource.ServicePoint__r.Distributor__r.Code__c;
        caseToEnrich.Market__c=dataSource.ServicePoint__r.MarketOrigin__c;
        caseToEnrich.PurificationInfoOnTheInvoice__c=dataSource.ServicePoint__r.PurificationInfoOnTheInvoice__c;
        caseToEnrich.RateCategory__c=dataSource.ServicePoint__r.RateCategory__c;
        caseToEnrich.ResidentDomesticHousingUnit__c=dataSource.ServicePoint__r.ResidentDomesticHousingUnit__c;
        caseToEnrich.SalesCompanyCode__c=dataSource.ServicePoint__r.Distributor__r.Code__c;
        caseToEnrich.ServicePointType__c=dataSource.ServicePoint__r.ImplantTypeTemp__c;
        caseToEnrich.SupplyCity__c=dataSource.ServicePoint__r.SupplyCity__c;
        caseToEnrich.SupplyCityCode__c=dataSource.ServicePoint__r.SupplySAPCityCode__c;
        caseToEnrich.SupplyCountry__c=dataSource.ServicePoint__r.SupplyCountry__c;
        caseToEnrich.SupplyPostalCode__c=dataSource.ServicePoint__r.SupplyPostalCode__c;
        caseToEnrich.SupplyProvince__c=dataSource.ServicePoint__r.SupplyProvince__c;
        caseToEnrich.SupplyStreetCode__c=dataSource.ServicePoint__r.SupplySAPStreetCode__c;
        caseToEnrich.SupplyStreetName__c=dataSource.ServicePoint__r.SupplyStreet__c;
        caseToEnrich.SupplyStreetNumber__c=dataSource.ServicePoint__r.SupplyStreetNumber__c;
        caseToEnrich.SuppliedEmail=dataSource.Account.PrimaryEmail__c;
        caseToEnrich.BillingProfile__c=dataSource.BillingProfile__c;
        return caseToEnrich;
    }

    private Map<String,Object> integrityChecks(List<String>csvSplitted){
        Map<String,Object> retMap=new Map<String,Object>{'errorMessage'=>'','checksAreValid'=>true};
        if(contractCodePodMap.containsKey(csvSplitted[contractIndex])){
            if(String.isBlank(contractCodePodMap.get(csvSplitted[contractIndex]).ServicePoint__c)){
                retMap.put('errorMessage',Label.consumoAnomaloIdricoMissingPOD +csvSplitted[contractIndex]);
                retMap.put('checksAreValid',false);
            } else if(contractCodePodMap.get(csvSplitted[contractIndex]).ServicePoint__r.ServicePointCode__c != csvSplitted[pdrIndex]){
                retMap.put('errorMessage',Label.consumoAnomaloIdricoPODCodeMismatch);
                retMap.put('checksAreValid',false);
            }
            if( contractCodePodMap.get(csvSplitted[contractIndex]).Account.SAPIntegrationID__c != csvSplitted[accountIndex]){
                retMap.put('errorMessage',Label.consumoAnomaloIdricoAccountCodeMismatch);
                retMap.put('checksAreValid',false);
            }
            if(String.isBlank(contractCodePodMap.get(csvSplitted[contractIndex]).BillingProfile__c)){
                retMap.put('errorMessage',Label.consumoAnomaloIdricoMissingBillingProf);
                retMap.put('checksAreValid',false);
            }
            if(csvSplitted[shipmentTypeIndex]=='E-Mail' && String.isBlank(csvSplitted[shipmentEmailIndex])){
                retMap.put('errorMessage','Indirizzo email assente nel CSV.');
                retMap.put('checksAreValid',false);
            }
            if(csvSplitted[shipmentTypeIndex]=='Posta Cartacea' && AddressFieldsInvalid(csvSplitted)){
                retMap.put('errorMessage','Dati di spedizione assenti nel CSV.');
                retMap.put('checksAreValid',false);
            }
        }else{
            retMap.put('errorMessage',Label.consumoAnomaloIdricoDefaultMissingContract + csvSplitted[contractIndex]);
            retMap.put('checksAreValid',false);
        }

        return retMap;
    }

    private Boolean AddressFieldsInvalid(List<String>csvSplitted){
        return String.isBlank(csvSplitted[shipmentStreetNameIndex]) ||
                String.isBlank(csvSplitted[shipmentStreetNumberIndex]) || String.isBlank(csvSplitted[shipmentPlaceIndex]) ||
                String.isBlank(csvSplitted[shipmentProvinceIndex]) || String.isBlank(csvSplitted[shipmentCityIndex]) ||
                String.isBlank(csvSplitted[shipmentPostalCodeIndex]) || String.isBlank(csvSplitted[shipmentCountryIndex]);
    }

    public override void finalUpdate(){
        if(itemsToSave.size() > 0){
            update itemsToSave;
        }
    }
    private void mapFieldsObject(){
        List<HDT_MassiveFieldsObjectMap__mdt> listCaseFields;
        List<HDT_MassiveFieldsObjectMap__mdt> listWrapperCaseFields;
        mapCaseFields = new Map<String, String>();
        mapWrapperCaseFields = new Map<String, String>();

        listCaseFields = getMapFieldsObject('Case', this.processName);
        listWrapperCaseFields = getMapFieldsObject('WrapperCase', this.processName);

        for(HDT_MassiveFieldsObjectMap__mdt temp : listCaseFields){
            mapCaseFields.put(temp.labelField__c, temp.nameField__c); //mappa header -> api
        }

        for(HDT_MassiveFieldsObjectMap__mdt temp : listWrapperCaseFields){
            mapWrapperCaseFields.put(temp.labelField__c, temp.nameField__c);
        }

    }

    private class HDT_WRP_ProcessObjects {
        private Case newCase;
        //private Contract contract;
        private MassiveLoaderRequestItem__c requestItem;
        private List<String> csvSplitted;
    }
}