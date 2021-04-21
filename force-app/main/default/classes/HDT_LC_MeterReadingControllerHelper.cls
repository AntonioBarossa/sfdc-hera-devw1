public inherited sharing class HDT_LC_MeterReadingControllerHelper {

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

            List<HDT_AccountDataEnrichment__mdt> meterRadingMetadataList;
            meterRadingMetadataList = HDT_QR_AccountDataEnrichment.getAccountDataEnrichment(meterRadingMetadataList, 'meterReading');

            if(meterRadingMetadataList.size()==0){
                columnsMetadata.success = false;
                columnsMetadata.message = 'No metadata found for meterRading';
                return columnsMetadata;
            }

            columnsMetadata.success = true;
            columnsMetadata.contractTable = contractMetadataList[0].ColumnData__c;
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
        contrWrp.service = c.ServicePoint__r.CommoditySector__c;
        return contrWrp;
    }

    public static HDT_WRP_MeterReading.HDT_WRP_MeterReadingObj getMeterReadingRecordsHelper(String contractCode) {
        HDT_WRP_MeterReading.HDT_WRP_MeterReadingObj meterReadingObj = new HDT_WRP_MeterReading.HDT_WRP_MeterReadingObj();

        try{
            //meterReadingObj.data = new List<HDT_WRP_MeterReading.HDT_WRP_MeterReadingDetail>();

            HDT_WS_MulesoftCaller.HDT_WRP_HttpObj httpObj = setHttpObject();

            if(httpObj == null){
                meterReadingObj.success = false;
                meterReadingObj.message = 'Metadata error!';
                return meterReadingObj;
            }

            HDT_WRP_MeterReading.HDT_WRP_HttpBody bodyWrp = new HDT_WRP_MeterReading.HDT_WRP_HttpBody();
            bodyWrp.codiceContratto = contractCode;
            //bodyWrp.codiceImpianto = '4005362981';
            bodyWrp.codicePod = '';
            //bodyWrp.dataInizioLettura = '01/12/2019';
            bodyWrp.dataFineLettura = Datetime.now().format('dd/MM/yyyy'); 
            bodyWrp.letturaReale = '';

            String body = JSON.serialize(bodyWrp, true);
            System.debug('>>> body obj > ' + body);
            HDT_WS_MulesoftCaller.HDT_WRP_Response responseCtrl = HDT_WS_MulesoftCaller.retrieveDataCtrl(body, httpObj);
     
            if(!responseCtrl.success){
                meterReadingObj.success = false;
                meterReadingObj.message = responseCtrl.message;
                return meterReadingObj;
            }

            HDT_WRP_MulesoftResponse.HDT_WRP_ReturnObj restMessage = (HDT_WRP_MulesoftResponse.HDT_WRP_ReturnObj)JSON.deserialize(responseCtrl.body, HDT_WRP_MulesoftResponse.HDT_WRP_ReturnObj.class);

            if(restMessage.status != 'success'){
                meterReadingObj.success = false;
                meterReadingObj.message = 'Mulesoft side [code: ' + restMessage.errorDetails.code;
                meterReadingObj.message += ']; Detail: ' + restMessage.errorDetails.message;
                meterReadingObj.message += '; Additional Info' + restMessage.errorDetails.additionalInfo;
                return meterReadingObj;
            }
    
            meterReadingObj.success = true;
            HDT_WRP_EstrattoLettureResponse responseWrapper = (HDT_WRP_EstrattoLettureResponse) JSON.deserialize(responseCtrl.body, HDT_WRP_EstrattoLettureResponse.class);

            transcodeSapData(responseWrapper.data);

            meterReadingObj.data = JSON.serialize(responseWrapper);

        } catch (Exception e){
            meterReadingObj.success = false;
            meterReadingObj.message = '> ERROR > ' + e.getMessage() + ' at line [' + String.valueOf(e.getLineNumber());
        }

        return meterReadingObj;
    }

    public static HDT_WS_MulesoftCaller.HDT_WRP_HttpObj setHttpObject(){

        HDT_WS_MulesoftCaller.HDT_WRP_HttpObj httpObj = new HDT_WS_MulesoftCaller.HDT_WRP_HttpObj();
        httpObj.headersMap = new Map<String, String>();

        List<HDT_AccountDataEnrichment__mdt> enrichmentbMetadataList;
        enrichmentbMetadataList = HDT_QR_AccountDataEnrichment.getAccountDataEnrichment(enrichmentbMetadataList, 'meterReading');

        if(enrichmentbMetadataList.size()>0 && !String.isEmpty(enrichmentbMetadataList[0].Credential__c)){

            httpObj.endPoint = enrichmentbMetadataList[0].Credential__c;
            httpObj.headersMap.put('Authorization', enrichmentbMetadataList[0].Authorization__c);

/*             if(enrichmentbMetadataList[0].UseMock__c){
                httpObj.endPoint = 'https://monted-dev-ed.my.salesforce.com/services/apexrest/meterreading';
                httpObj.headersMap.put('Authorization', 'Bearer ' + Label.MockSessionId);
            } */

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
        }

    }

    public class HDT_WRP_ArricchimentoTestata{
        public String esito;
    }
    
    public class HDT_WRP_ArricchimentoPosizioni{
        @InvocableVariable
        public String campo;
        @InvocableVariable
        public String valore;
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
    }
    
    public class HDT_WRP_EstrattoLettureResponse{
        public String status;
        public String correlationId;
        public String timestamp;
        public List<HDT_WRP_EstrattoLettureData> data;
    }

}