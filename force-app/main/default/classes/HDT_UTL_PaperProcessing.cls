public with sharing class HDT_UTL_PaperProcessing {

    public static HDT_SRV_ContentVersion contentVersionSrv = new HDT_SRV_ContentVersion();
    public static HDT_QR_ContentVersion contentVersionQr = new HDT_QR_ContentVersion();
    public static HDT_SRV_ContentDocumentLink contentDocumentLinkSrv = new HDT_SRV_ContentDocumentLink();


    public static void createCommunication(List<PaperProcessing__c> newPaper,List<PaperProcessing__c> oldPaper){
        map<String,PaperProcessing__c> mapOld = new map<String,PaperProcessing__c>();
        for(PaperProcessing__c p : oldPaper){
            mapOld.put(p.id,p);
        }
        List<String> ppToBatch = new List<String>();
        for (PaperProcessing__c pp : newPaper) {
            if (mapOld.get(pp.id) != null && mapOld.get(pp.id).Status__c != 'Completata' && pp.status__c == 'Completata') {
                ppToBatch.add(pp.id);
            }
        }
        HDT_BA_PaperCampaignClosing ppBatch = new HDT_BA_PaperCampaignClosing(ppToBatch);
        ID batchProcessId = Database.executeBatch(ppBatch);
    }


    public static void generateName(List<PaperProcessing__c> newPaper){
        List<String> idCampaign = new List<String>();
        map<String,Campaign> mapCampaign = new Map<String,Campaign>();
        for(PaperProcessing__c p  : newPaper){
            idCampaign.add(p.Campaign__c);
        }
        List<Campaign> listCmp = HDT_QR_Campaign.getCampaign(idCampaign);
        for(Campaign c : listCmp){
            mapCampaign.put(c.id,c);
        }
        for(PaperProcessing__c p : newPaper){
            Campaign c = mapCampaign.get(p.campaign__c);
            p.Name = c.PaperCampaignParameter__r.LetterType__c + '_' + date.today().year() + date.today().month() + date.today().day() + '_' + c.PaperCampaignParameter__r.CostCenter__c;
        }
    }



    //execute batch
    public static void exportFile(List<PaperProcessing__c> newPaper,List<PaperProcessing__c> oldPaper) {
        map<String,PaperProcessing__c> mapOld = new map<String,PaperProcessing__c>();
        List<PaperProcessing__c> paperToUpdate = new List<PaperProcessing__c>();
        for(PaperProcessing__c p : oldPaper){
            mapOld.put(p.id,p);
        }
        List<String> ppToBatch = new List<String>();
        for (PaperProcessing__c pp : newPaper) {
            if (mapOld.get(pp.id) != null && mapOld.get(pp.id).TriggerCustomerReport__c == false && pp.TriggerCustomerReport__c == true) {
                ppToBatch.add(pp.id);
                PaperProcessing__c newpp = new PaperProcessing__c();
                newpp.Id = pp.Id;
                newpp.TriggerCustomerReport__c = false;
                newpp.status__c = 'In Corso';
                paperToUpdate.add(newpp);
            }
        }
        //execute batch
        HDT_BA_PaperProcessing ppBatch = new HDT_BA_PaperProcessing(ppToBatch);
        ID batchProcessId = Database.executeBatch(ppBatch, 10000);

        if (paperToUpdate.size() > 0) {
            HDT_SRV_PaperProcessing.updateRecords(paperToUpdate);
        }
    }

    //execute batch
    public static List<PaperProcessing__c> exportFile2(List<PaperProcessing__c> newPaper,List<PaperProcessing__c> oldPaper) {
        map<String,PaperProcessing__c> mapOld = new map<String,PaperProcessing__c>();
        List<PaperProcessing__c> paperToUpdate = new List<PaperProcessing__c>();
        for(PaperProcessing__c p : oldPaper){
            mapOld.put(p.id,p);
        }
        List<String> ppToBatch = new List<String>();
        for (PaperProcessing__c pp : newPaper) {
            if (mapOld.get(pp.id) != null && mapOld.get(pp.id).TriggerCustomerReport__c == false && pp.TriggerCustomerReport__c == true) {
                ppToBatch.add(pp.id);
                PaperProcessing__c newpp = new PaperProcessing__c();
                newpp.Id = pp.Id;
                newpp.TriggerCustomerReport__c = false;
                newpp.status__c = 'In Corso';
                paperToUpdate.add(newpp);
            }
        }
        //execute batch
        HDT_BA_PaperProcessing ppBatch = new HDT_BA_PaperProcessing(ppToBatch);
        ID batchProcessId = Database.executeBatch(ppBatch, 10000);
        
        return paperToUpdate;
    }

    public static void exportFileNotTrigger(List<PaperProcessing__c> newPaper) {
        List<String> ppToBatch = new List<String>();
        for (PaperProcessing__c pp : newPaper) {
            if (pp.TriggerCustomerReport__c == true) {
                ppToBatch.add(pp.Id);
                pp.TriggerCustomerReport__c = false;
                pp.status__c = 'In Corso';
            }
        }
        //execute batch
        HDT_BA_PaperProcessing ppBatch = new HDT_BA_PaperProcessing(ppToBatch);
        ID batchProcessId = Database.executeBatch(ppBatch, 500);
        HDT_SRV_PaperProcessing.updateRecords(newPaper);
    }

    //Generate xls file
    public static String generateFile(List<HDT_WRP_PaperProcessing> ppList, String paperProcessingId, String fileName){
        String csvFile = '';

        List<String> tableHeader = new List<String>{'codCliente','ragSociale','nome','cognome','codFiscale','pIva','resIndirizo','resCivico','resCap','resComune','resProv','codContratto','protocollo','dataLettera','servizio','codCa','codPodPdr','offerta','societa','dataAttivazione','impianto','frnIndirizzo','frnCivico','frnCap','frnComune','frnProv','tipoLettera','modalitaSpedizione','aggregazione','lotto','dataLotto','recIntestatario','recIndirizzo','recCivico','recCap','recComune','recProv','recNazione','raccoMittente','raccoIndirizzo','raccoCivico','raccoCap','raccoComune','raccoProv','campo2','campo3','campo4','campo5','campo6','campo7','campo8','campo9','campo10','campo11','campo12','campo13','campo14','campo15','campo16','campo17','campo18','campo19','campo20','campo21','campo22','campo23','campo24','campo25','campo26','campo27','campo28','campo29','campo30','campo31','campo32','campo33','campo34','campo35','campo36','campo37','campo38','campo39','campo40','CRM_communication_Id'};

        List<String> headerLabels = new List<String>{'COD_CLIENTE', 'RAG_SOCIALE', 'NOME', 'COGNOME', 'COD_FISCALE', 'P_IVA', 'RES_INDIRIZZO', 'RES_CIVICO', 'RES_CAP', 'RES_COMUNE', 'RES_PROV', 'COD_CONTRATTO', 'PROTOCOLLO', 'DATA_LETTERA', 'SERVIZIO', 'COD_CA', 'COD_POD_PDR', 'OFFERTA', 'SOCIETA', 'DATA_ATTIVAZIONE', 'IMPIANTO', 'FRN_INDIRIZZO', 'FRN_CIVICO', 'FRN_CAP', 'FRN_COMUNE', 'FRN_PROV', 'TIPO_LETTERA', 'MODALITA_SPEDIZIONE', 'AGGREGAZIONE', 'LOTTO', 'DATA_LOTTO', 'REC_INTESTATARIO', 'REC_INDIRIZZO', 'REC_CIVICO', 'REC_CAP', 'REC_COMUNE', 'REC_PROV', 'REC_NAZIONE', 'RACCO_MITTENTE', 'RACCO_INDIRIZZO', 'RACCO_CIVICO', 'RACCO_CAP', 'RACCO_COMUNE', 'RACCO_PROV', 'Campo 2', 'Campo 3', 'Campo 4', 'Campo 5', 'Campo 6', 'Campo 7', 'Campo 8', 'Campo 9', 'Campo 10', 'Campo 11', 'Campo 12', 'Campo 13', 'Campo 14', 'Campo 15', 'Campo 16', 'Campo 17', 'Campo 18', 'Campo 19', 'Campo 20', 'Campo 21', 'Campo 22', 'Campo 23', 'Campo 24', 'Campo 25', 'Campo 26', 'Campo 27', 'Campo 28', 'Campo 29', 'Campo 30', 'Campo 31', 'Campo 32', 'Campo 33', 'Campo 34', 'Campo 35', 'Campo 36', 'Campo 37', 'Campo 38', 'Campo 39', 'Campo 40','CRM_communication_Id'};

        //table header
        csvFile = '<table>';
        csvFile += '<tr>';
        for (String header : headerLabels) {
            csvFile += '<td>'+header+'</td>';
        }
        csvFile += '</tr>';

        List<Map<String, Object>> objMapList = new List<Map<String, Object>>();
        for (HDT_WRP_PaperProcessing pp : ppList) {
            objMapList.add((Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(pp)));
        }

        //table body
        for (Map<String, Object> objMap : objMapList) {
            csvFile += '<tr>';
            for (String key : tableHeader) {
                Object value = objMap.get(key);
                if (value == null) {
                    csvFile += '<td></td>';
                } else {
                    csvFile += '<td>'+(String)value+'</td>';
                }
            }
            csvFile += '</tr>';
        }

        csvFile += '</table>';

        //Create Document

        ContentVersion cv = contentVersionSrv.createRecord(fileName, fileName+'.csv', csvFile);

        //Get Content Document
        ContentVersion conDoc = contentVersionQr.getRecordById(cv.Id);
        
        //Create ContentDocumentLink
        ContentDocumentLink cdl = contentDocumentLinkSrv.createRecord(paperProcessingId, conDoc.ContentDocumentId, 'I');
        return cv.Id;
    }


    public static List<String> generateFile(Map<String,List<HDT_WRP_PaperProcessing>> mapLabCartListWrap){
        List<String> csvFiles = new List<String>();
        List<ContentVersion> listContentVersion = new List<ContentVersion>();
        List<String> tableHeader = new List<String>{'codCliente','ragSociale','nome','cognome','codFiscale','pIva','resIndirizo','resCivico','resCap','resComune','resProv','codContratto','protocollo','dataLettera','servizio','codCa','codPodPdr','offerta','societa','dataAttivazione','impianto','frnIndirizzo','frnCivico','frnCap','frnComune','frnProv','tipoLettera','modalitaSpedizione','aggregazione','lotto','dataLotto','recIntestatario','recIndirizzo','recCivico','recCap','recComune','recProv','recNazione','raccoMittente','raccoIndirizzo','raccoCivico','raccoCap','raccoComune','raccoProv','campo2','campo3','campo4','campo5','campo6','campo7','campo8','campo9','campo10','campo11','campo12','campo13','campo14','campo15','campo16','campo17','campo18','campo19','campo20','campo21','campo22','campo23','campo24','campo25','campo26','campo27','campo28','campo29','campo30','campo31','campo32','campo33','campo34','campo35','campo36','campo37','campo38','campo39','campo40','CRM_communication_Id'};
        Map<String,String> relateIdWithTitle = new Map<String,String>();
        List<String> headerLabels = new List<String>{'COD_CLIENTE', 'RAG_SOCIALE', 'NOME', 'COGNOME', 'COD_FISCALE', 'P_IVA', 'RES_INDIRIZZO', 'RES_CIVICO', 'RES_CAP', 'RES_COMUNE', 'RES_PROV', 'COD_CONTRATTO', 'PROTOCOLLO', 'DATA_LETTERA', 'SERVIZIO', 'COD_CA', 'COD_POD_PDR', 'OFFERTA', 'SOCIETA', 'DATA_ATTIVAZIONE', 'IMPIANTO', 'FRN_INDIRIZZO', 'FRN_CIVICO', 'FRN_CAP', 'FRN_COMUNE', 'FRN_PROV', 'TIPO_LETTERA', 'MODALITA_SPEDIZIONE', 'AGGREGAZIONE', 'LOTTO', 'DATA_LOTTO', 'REC_INTESTATARIO', 'REC_INDIRIZZO', 'REC_CIVICO', 'REC_CAP', 'REC_COMUNE', 'REC_PROV', 'REC_NAZIONE', 'RACCO_MITTENTE', 'RACCO_INDIRIZZO', 'RACCO_CIVICO', 'RACCO_CAP', 'RACCO_COMUNE', 'RACCO_PROV', 'Campo 2', 'Campo 3', 'Campo 4', 'Campo 5', 'Campo 6', 'Campo 7', 'Campo 8', 'Campo 9', 'Campo 10', 'Campo 11', 'Campo 12', 'Campo 13', 'Campo 14', 'Campo 15', 'Campo 16', 'Campo 17', 'Campo 18', 'Campo 19', 'Campo 20', 'Campo 21', 'Campo 22', 'Campo 23', 'Campo 24', 'Campo 25', 'Campo 26', 'Campo 27', 'Campo 28', 'Campo 29', 'Campo 30', 'Campo 31', 'Campo 32', 'Campo 33', 'Campo 34', 'Campo 35', 'Campo 36', 'Campo 37', 'Campo 38', 'Campo 39', 'Campo 40','CRM_communication_Id'};
        for(String key : mapLabCartListWrap.keySet()){
            //table header
            List<HDT_WRP_PaperProcessing> ppList = mapLabCartListWrap.get(key);
            String csvFile = '';
            for (String header : headerLabels) {
                csvFile += header + ';';
            }
            csvFile += '\n';
            List<Map<String, Object>> objMapList = new List<Map<String, Object>>();
            for (HDT_WRP_PaperProcessing pp : ppList) {
                objMapList.add((Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(pp)));
            }

            for (Map<String, Object> objMap : objMapList) {
                for (String key2 : tableHeader) {
                    Object value = objMap.get(key2);
                    if (value == null) {
                        csvFile += ';';
                    } else {
                        csvFile += (String)value+';';
                    }
                }
                csvFile += '\n';
            }
           /* csvFile = '<table>';
            csvFile += '<tr>';
            for (String header : headerLabels) {
                csvFile += '<td>'+header+'</td>';
            }
            csvFile += '</tr>';

            List<Map<String, Object>> objMapList = new List<Map<String, Object>>();
            for (HDT_WRP_PaperProcessing pp : ppList) {
                objMapList.add((Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(pp)));
            }

            //table body
            for (Map<String, Object> objMap : objMapList) {
                csvFile += '<tr>';
                for (String key2 : tableHeader) {
                    Object value = objMap.get(key2);
                    if (value == null) {
                        csvFile += '<td></td>';
                    } else {
                        csvFile += '<td>'+(String)value+'</td>';
                    }
                }
                csvFile += '</tr>';
            }

            csvFile += '</table>';*/
           // csvFiles.add(csvFile);
            String fileName = 'Report_Clienti_' + key + date.today().year() + date.today().month() + date.today().day();
            relateIdWithTitle.put(key,fileName);
            ContentVersion cv = contentVersionSrv.createRecordNoInsert(fileName, fileName+'.csv', csvFile);
            listContentVersion.add(cv);
        }
        //Create Document
        List<ContentVersion> listReturn = contentVersionSrv.insertRecords(listContentVersion);
        List<String> idContent = new List<String>();
        for(ContentVersion cvs : listReturn){
            idContent.adD(cvs.id);
        }
        Map<String,String> mapTitleToDocumentId = new Map<String,String>();
        //Get Content Document
        List<ContentVersion> conDoc = contentVersionQr.getRecordByIds(idContent);
        List<ContentDocumentLink> contLinkList = new List<ContentDocumentLink>();
        for(ContentVersion c : conDoc){
            mapTitleToDocumentId.put(c.title,c.ContentDocumentId);
        }
        System.debug('*********:1_' + relateIdWithTitle);
        System.debug('*********:2_' + mapTitleToDocumentId);
        for(String s : relateIdWithTitle.keyset()){
            contLinkList.add(contentDocumentLinkSrv.createRecordNoInsert(s,mapTitleToDocumentId.get(relateIdWithTitle.get(s)), 'I'));
        }
        if(contLinkList != null && !contLinkList.isEmpty()){
            contentDocumentLinkSrv.insertRecords(contLinkList);
        }
        //Create ContentDocumentLink
        //ContentDocumentLink cdl = contentDocumentLinkSrv.createRecord(paperProcessingId, conDoc.ContentDocumentId, 'I');
        return idContent;
    }

    //WS Post Call
    public static String postPaperProcessing(String filezipName, String type, String contentVersionId){
        //String nomeApi = 'postPaperProcessing';
        HDT_WS_Response wsCall = HDT_WS_PaperProcessing.postPaperProcessing(filezipName, type, contentVersionId);
        if (wsCall.status == 'OK') {
            //System.debug('- - - - - ' + wsCall.body);
            return wsCall.status;
        } else {
            return ((String) wsCall.errorDetails);
        }
    }
    public static String postPaperProcessing(String filezipName, String type, List<String> contentVersionId){
        //String nomeApi = 'postPaperProcessing';
        HDT_WS_Response wsCall = HDT_WS_PaperProcessing.postPaperProcessing(filezipName, type, contentVersionId);
        if (wsCall.status == 'OK') {
            //System.debug('- - - - - ' + wsCall.body);
            return wsCall.status;
        } else {
            return ((String) wsCall.errorDetails);
        }
    }
}