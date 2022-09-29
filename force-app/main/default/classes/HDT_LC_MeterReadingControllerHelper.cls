@SuppressWarnings('PMD.AvoidDebugStatements, PMD.ExcessivePublicCount')
public inherited sharing class HDT_LC_MeterReadingControllerHelper {

    public static Boolean enableNewService(){
        return (Label.TRB_Enable.equalsIgnoreCase('Y'));
    }

    public static HDT_WRP_MeterReading.HDT_WRP_ColumnsMetadata getConfigurationDataHelper(){

        HDT_WRP_MeterReading.HDT_WRP_ColumnsMetadata columnsMetadata = new HDT_WRP_MeterReading.HDT_WRP_ColumnsMetadata();

        try{
            List<HDT_AccountDataEnrichment__mdt> contractMetadataList;
            contractMetadataList = HDT_QR_AccountDataEnrichment.getAccountDataEnrichment(contractMetadataList, 'contract');

            if(contractMetadataList.size()==0){
                columnsMetadata.success = false;
                columnsMetadata.message = 'No metadata found for contract';
                return columnsMetadata;
            }

            //columnsMetadata.trbEnable = enableNewService();
            //String code = columnsMetadata.trbEnable ? 'NewMeterReading' : 'meterReading';
            //
            //List<HDT_AccountDataEnrichment__mdt> meterRadingMetadataList;
            //meterRadingMetadataList = HDT_QR_AccountDataEnrichment.getAccountDataEnrichment(meterRadingMetadataList, code);
            //
            //if(meterRadingMetadataList.size()==0){
            //    columnsMetadata.success = false;
            //    columnsMetadata.message = 'No metadata found for meterRading';
            //    return columnsMetadata;
            //}

            columnsMetadata.success = true;
            columnsMetadata.contractTable = contractMetadataList[0].ColumnData__c;
            //columnsMetadata.meterReadingTable = meterRadingMetadataList[0].ColumnData__c;
            return columnsMetadata;

        } catch(Exception e){
            columnsMetadata.success = false;
            columnsMetadata.message = e.getMessage() + ' - at line [' + String.valueOf(e.getLineNumber()) + ']';
            return columnsMetadata;
        }

    }

    public static HDT_WRP_MeterReading.HDT_WRP_ColumnsMetadata getConfigurationDetailTableHelper(String contractService){

        HDT_WRP_MeterReading.HDT_WRP_ColumnsMetadata columnsMetadata = new HDT_WRP_MeterReading.HDT_WRP_ColumnsMetadata();

        try{

            String code;
            columnsMetadata.trbEnable = enableNewService();
            if(columnsMetadata.trbEnable){
                if(contractService.equalsIgnoreCase('Energia Elettrica')){
                    code = 'MeterReading_ele';
                } else if(contractService.equalsIgnoreCase('Gas')){
                    code = 'MeterReading_gas';
                }
            } else {
                code = 'meterReading';
            }

            List<HDT_AccountDataEnrichment__mdt> meterRadingMetadataList;
            meterRadingMetadataList = HDT_QR_AccountDataEnrichment.getAccountDataEnrichment(meterRadingMetadataList, code);

            if(meterRadingMetadataList.size()==0){
                columnsMetadata.success = false;
                columnsMetadata.message = 'No metadata found for meterRading';
                return columnsMetadata;
            }

            columnsMetadata.success = true;
            columnsMetadata.meterReadingTable = meterRadingMetadataList[0].ColumnData__c;
            return columnsMetadata;

        } catch(Exception e){
            columnsMetadata.success = false;
            columnsMetadata.message = e.getMessage() + ' - at line [' + String.valueOf(e.getLineNumber()) + ']';
            return columnsMetadata;
        }

    }

    public static HDT_WRP_MeterReading.HDT_WRP_ContractObj getContractRecordsHelper(String accountId) {
        HDT_WRP_MeterReading.HDT_WRP_ContractObj contrObj = new HDT_WRP_MeterReading.HDT_WRP_ContractObj();

        try {

            List<Contract> contractList;
            contractList = HDT_QR_MeterReading.getAccountContracts(contractList, accountId);

            if(contractList.size()==0){
                contrObj.success = false;
                contrObj.message = 'No contract found for this account';
                return contrObj;                
            }

            contrObj.contractList = new List<HDT_WRP_MeterReading.HDT_WRP_ContractDetail>();
            for(Contract c : contractList){
                HDT_WRP_MeterReading.HDT_WRP_ContractDetail contrWrp;
                contrObj.contractList.add(convertContractToWrapper(c, contrWrp));
            }

            contrObj.success = true;

        } catch (Exception e){
            contrObj.success = false;
            contrObj.message = '> ERROR > ' + e.getMessage() + ' at line [' + String.valueOf(e.getLineNumber() + ']');
        }

        return contrObj;

    }

    private static HDT_WRP_MeterReading.HDT_WRP_ContractDetail convertContractToWrapper(Contract c, HDT_WRP_MeterReading.HDT_WRP_ContractDetail contrWrp){
        contrWrp = new HDT_WRP_MeterReading.HDT_WRP_ContractDetail();
        contrWrp.id = c.Id;
        contrWrp.contractNumber = c.SAPContractCode__c;
        contrWrp.status = c.Status;
        contrWrp.startDate = String.valueOf(c.StartDate);
        contrWrp.endDate = String.valueOf(c.EndDate);
        contrWrp.asset = c.ServicePoint__r.SAPImplantCode__c;
        //contrWrp.service = c.ServicePoint__r.CommoditySector__c;
        contrWrp.service = 'Gas';
        contrWrp.serialNumber = c.ServicePoint__r.MeterSN__c;
        contrWrp.servicePoint = c.ServicePoint__r.ServicePointCode__c;
        return contrWrp;
    }

    public static HDT_WRP_MeterReading.HDT_WRP_MeterReadingObj getMeterReadingRecordsHelper(String contractCode, String modality, String contractService) {
        HDT_WRP_MeterReading.HDT_WRP_MeterReadingObj meterReadingObj = new HDT_WRP_MeterReading.HDT_WRP_MeterReadingObj();

        try{

            String code;
            if(enableNewService()){
                if(contractService.equalsIgnoreCase('Energia Elettrica')){
                    code = 'MeterReading_ele';
                } else if(contractService.equalsIgnoreCase('Gas')){
                    code = 'MeterReading_gas';
                }
            } else {
                code = 'meterReading';
            }

            HDT_WS_MulesoftCaller.HDT_WRP_HttpObj httpObj = setHttpObject(code);

            if(httpObj == null){
                meterReadingObj.success = false;
                meterReadingObj.message = 'Metadata error!';
                return meterReadingObj;
            }

            List<Contract> contractRecord;
            contractRecord= HDT_QR_MeterReading.getContract(contractRecord, contractCode);

            String body = generateBody(contractRecord[0], modality);
            System.debug(LoggingLevel.DEBUG, '>>> body obj > ' + body);

            HDT_WS_MulesoftCaller.HDT_WRP_Response responseCtrl = HDT_WS_MulesoftCaller.retrieveDataCtrl(body, httpObj);
     
            if(!responseCtrl.success){
                meterReadingObj.success = false;
                meterReadingObj.message = responseCtrl.message;
                return meterReadingObj;
            }

            HDT_WRP_MulesoftResponse.HDT_WRP_ReturnObj restMessage = (HDT_WRP_MulesoftResponse.HDT_WRP_ReturnObj)JSON.deserialize(responseCtrl.body, HDT_WRP_MulesoftResponse.HDT_WRP_ReturnObj.class);

            if(restMessage.status != 'success'){
                meterReadingObj.success = false;

                meterReadingObj.message += '[CODE: ' + restMessage.errorDetails[0].code + ']; DETAILS: ';
                for(Integer n=0; n < restMessage.errorDetails.size(); n++){
                    meterReadingObj.message += restMessage.errorDetails[n].message;
                    if(n < (restMessage.errorDetails.size()-1)){
                        meterReadingObj.message += ', ';
                    }
                }

                return meterReadingObj;
            }

            meterReadingObj.success = true;
            HDT_WRP_EstrattoLettureResponse responseWrapper;
            responseWrapper = (HDT_WRP_EstrattoLettureResponse) JSON.deserialize(responseCtrl.body, HDT_WRP_EstrattoLettureResponse.class);

            if(!enableNewService()){
                transcodeSapData(responseWrapper.data);
            }

            //meterReadingObj.data = JSON.serialize(responseWrapper);

            meterReadingObj.data = '{"data": [{"dataLetturaPianificata": "xxx"}]}';

        } catch (Exception e){
            meterReadingObj.success = false;
            meterReadingObj.message = '> ERROR > ' + e.getMessage() + ' at line [' + String.valueOf(e.getLineNumber());
        }

        return meterReadingObj;
    }

    public static String generateBody(Contract contr, String modality){
        String body;
        JSONGenerator jsonGen = JSON.createGenerator(true);
        jsonGen.writeStartObject();

        if(enableNewService()){
            if(contr.ServicePoint__r.CommoditySector__c.equalsIgnoreCase('Energia Elettrica')){
                jsonGen.writeStringField('pod', 'xyz');
            } else if(contr.ServicePoint__r.CommoditySector__c.equalsIgnoreCase('Gas')){
                jsonGen.writeStringField('pdr', '');
            }
            Date d = Date.today();
            String currentYear = String.valueOf(d.year());
            jsonGen.writeStringField('dataInizio', '01/01/' + currentYear);
            jsonGen.writeStringField('dataFine', '31/12/' + currentYear);
            jsonGen.writeStringField('commodity', contr.ServicePoint__r.CommoditySector__c);
            jsonGen.writeStringField('modalita', modality); //-- DEFAULT - FULL
        } else {
            jsonGen.writeStringField('codiceContratto', contr.SAPContractCode__c);
            jsonGen.writeStringField('codicePod', '');
            jsonGen.writeStringField('dataFineLettura', Datetime.now().format('dd/MM/yyyy'));
            jsonGen.writeStringField('letturaReale', '');
        }

        jsonGen.writeEndObject();
        body = jsonGen.getAsString();

        return body;
    }

    public static HDT_WS_MulesoftCaller.HDT_WRP_HttpObj setHttpObject(String code){

        HDT_WS_MulesoftCaller.HDT_WRP_HttpObj httpObj = new HDT_WS_MulesoftCaller.HDT_WRP_HttpObj();
        httpObj.headersMap = new Map<String, String>();

        List<HDT_AccountDataEnrichment__mdt> enrichmentbMetadataList;
        enrichmentbMetadataList = HDT_QR_AccountDataEnrichment.getAccountDataEnrichment(enrichmentbMetadataList, code);

        if(enrichmentbMetadataList.size()>0 && !String.isEmpty(enrichmentbMetadataList[0].Credential__c)){

            httpObj.endPoint = enrichmentbMetadataList[0].Credential__c;
            //httpObj.headersMap.put('Authorization', enrichmentbMetadataList[0].Authorization__c);
            httpObj.httpMethod = 'POST';
            httpObj.headersMap.put('Content-Type', 'application/json');

        } else {
            httpObj = null;
        }

        return httpObj;
    }

    private static void transcodeSapData(List<HDT_WRP_EstrattoLettureData> responseData) {

        List<HDT_MeterReadingTranscodeMap__mdt> maps = HDT_QR_AccountDataEnrichment.getReadingsTranscodeMap();
        Map<String, String> commodityMap = new Map<String, String>();
        Map<String, String> readingCategoryMap = new Map<String, String>();
        Map<String, String> numCategoryMap = new Map<String, String>();
        Map<String, String> readingStatusMap = new Map<String, String>();
        Map<String, String> readingTypeMap = new Map<String, String>();
        Map<String, String> numTypeMap = new Map<String, String>();
        Map<String, String> numIdMap = new Map<String, String>();

        for (HDT_MeterReadingTranscodeMap__mdt m : maps) {
            switch on m.TranscodeType__c {
                when 'Settore Merceologico' {
                    commodityMap.put(m.SapValue__c, m.SalesforceValue__c);
                }
                when 'Categoria Lettura' {
                    readingCategoryMap.put(m.SapValue__c, m.SalesforceValue__c);
                }
                when 'Categoria Numeratore' {
                    numCategoryMap.put(m.SapValue__c, m.SalesforceValue__c);
                }
                when 'Stato Lettura' {
                    readingStatusMap.put(m.SapValue__c, m.SalesforceValue__c);
                }
                when 'Tipo Lettura' {
                    readingTypeMap.put(m.SapValue__c, m.SalesforceValue__c);
                }
                when 'Tipo Numeratore' {
                    numTypeMap.put(m.SapValue__c, m.SalesforceValue__c);
                }
                when 'Identificazione Numeratore' {
                    numIdMap.put(m.SapValue__c, m.SalesforceValue__c);
                }
            }
        }

        for (HDT_WRP_EstrattoLettureData data : responseData) {
            data.identificazioneNumeratore = numIdMap.get(data.settoreMerceologico + '-' + data.identificazioneNumeratore);
            data.settoreMerceologico = commodityMap.get(data.settoreMerceologico);
            data.categoriaLettura = readingCategoryMap.get(data.categoriaLettura);
            data.categoriaNumeratore = numCategoryMap.get(data.categoriaNumeratore);
            data.statoLettura = readingStatusMap.get(data.statoLettura);
            data.tipoLettura = readingTypeMap.get(data.tipoLettura);
            data.tipoNumeratore = numTypeMap.get(data.tipoNumeratore);

            // In caso di lettura stornata, da as-is siebel gli unici campi da valorizzare sono: codiceContratto, apparecchiatura, dataLetturaPianificata, settoreMerceologico, letturaStornata
            // Per cui tutti gli altri campi vanno sbiancati.
            if (String.isNotBlank(data.letturaStornata)) {
                data.campo = null;
                data.posizioniPrecedentiLaVirgola = null;
                data.decimali = null;
                data.quantitaCalcolo = null;
                data.tipoLettura = null;
                data.categoriaLettura = null;
                data.statoLettura = null;
                data.consumoMedioGiornaliero = null;
                data.giorniConsumo = null;
                data.identificazioneNumeratore = null;
                data.unitaDiMisura = null;
                data.categoriaNumeratore = null;
                data.tipoNumeratore = null;
                data.motivazione = null;
            }
        }

    }


    public class HDT_WRP_EstrattoLettureData{
        public String campo;
        public String codiceContratto;
        public String apparecchiatura;
        public String dataLetturaPianificata;
        public String posizioniPrecedentiLaVirgola;
        public String decimali;
        public String quantitaCalcolo;
        public String tipoLettura;
        public String categoriaLettura;
        public String statoLettura;
        public String consumoMedioGiornaliero;
        public String giorniConsumo;
        public String settoreMerceologico;
        public String identificazioneNumeratore;
        public String unitaDiMisura;
        public String categoriaNumeratore;
        public String tipoNumeratore;
        public String motivazione;
        public String letturaStornata;
    }
    
    public class HDT_WRP_EstrattoLettureResponse{
        public String status;
        public String correlationId;
        public String timestamp;
        public List<HDT_WRP_EstrattoLettureData> data;
    }

}