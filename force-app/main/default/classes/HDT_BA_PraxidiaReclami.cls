/**
* @author Lorenzo (lorenzo.gulotta@webresults.it)
* @date 24/06/2021
* @description HDT_BA_PraxidiaReclami
* @history Lorenzo – 24/06/2021 – created class
*/
public class HDT_BA_PraxidiaReclami implements Database.Batchable<Case>, Database.Stateful,Database.AllowsCallouts{

    HDT_QR_Case caseQr = new HDT_QR_Case();
    HDT_QR_Contact contactQr = new HDT_QR_Contact();
    List<Case> dtos = new List<Case>();
    HDT_SRV_ContentVersion contentSRV = new HDT_SRV_ContentVersion();
    List<HDT_WRP_CampaignPraxidia.reclami> wrapReclamiList = new List<HDT_WRP_CampaignPraxidia.reclami>();
    List<String> caseIdList = new List<String>();
    String header = 'ID_JOB;RDS_RIGA;ACR;SOCIETA;ASSEGNATARIO;GRUPPO;DATA_RICEVIMENTO;DATA_CHIUSURA;TIPO;SERVIZIO;TIPO_FORNITURA;CATEGORIA_CLIENTE;CODICE_CLIENTE;STATO_PRATICA;CANALE_DI_RICEZIONE;REITERATA;EP_SOTTOTIPO;EP_CAUSALE;EP_CLASSIFICAZIONE;TE_SOL;TE_LAV;FUORI_STD_AEEGSI;CHIAMATA;BRAND;SEGMENTO;COMUNE_CORRETTO;ISTAT_CORRETTO;PROVINCIA;DIRITTO_RETTIFICA;FLUSSO_PRATICA;CANALE_DI_USCITA;EMAIL_USCITA;RICHIESTE_PARERI\n';
    String generateFile = header;
    public String queryDate='';
    public Iterable<Case> start(Database.BatchableContext context) {
        if(String.isNotBlank(queryDate)){
            Datetime startDt=Datetime.valueOfGMT(queryDate + ' 00:00:00');
            Datetime endDt=startDt.addDays(1);
            dtos = caseQr.getRecordCreatedInRequestedDate('Reclami', startDt, endDt);
            return this.dtos;
        }
        dtos = caseQr.getRecordCreatedLastDayEqualsBy('Reclami');
        return this.dtos;
    }


    public void execute(Database.BatchableContext context, List<Case> wrapIterable)
    { 
        String businessDateid = HDT_QR_BusinessDate.getWorkingBusinessDateConf();
        List<Case> csList = new List<Case>();
        Map<String,boolean> caseParentiIdChild = new Map<String,boolean>();
       
        List<String> accountIdList = new List<String>();
        Map<id,wrts_prcgvr__Activity__c> assigncaseToActivity= new Map<id,wrts_prcgvr__Activity__c>();
        for(Case ca :wrapIterable){
            csList.add(ca);
            accountIdList.add(ca.AccountId);
            caseParentiIdChild.put(ca.id,true);
            caseIdList.add(ca.id);
        }
        List<wrts_prcgvr__Activity__c> listActivity = HDT_QR_ActivityCustom.getRecordByCaseIdList(caseIdList);
        for(wrts_prcgvr__Activity__c a : listActivity){
            assigncaseToActivity.put(a.case__c,a);
        }
        for(Case ca :wrapIterable){
                HDT_WRP_CampaignPraxidia.reclami fr = new HDT_WRP_CampaignPraxidia.reclami();
                Long dayWorking = businessDateid != null ? BusinessHours.diff(businessDateid, ca.createddate, system.today()) : null ;
                fr.idJob = '';
                fr.rdsRiga = 'C_' + ca.Id;
                fr.acr = '';
                fr.societa = ca.CompanyOwner__c;
                fr.assegnatario = assigncaseToActivity.get(ca.id) != null ? assigncaseToActivity.get(ca.id).owner.name : '';
                fr.gruppo = ca.creatorGroup__c != null ? ca.creatorGroup__c : '';
                fr.dataRicevimento = ca.CustomerRequestDate__c != null ? ca.CustomerRequestDate__c+'' : '';
                fr.dataChiusura = ca.ClosedDate != null ?ca.ClosedDate +'' : '';
                fr.tipo = ca.cluster__c != null ? ca.cluster__c : '';
                fr.servizio = ca.commodityFormula__c != null ? ca.commodityFormula__c : '';
                fr.tipoFornitura =  ca.SupplyType__c != null ? ca.SupplyType__c : '';
                fr.categoriaCliente = ca.Account.category__c != null ? ca.Account.category__c : '';
                fr.codiceCliente = ca.Account.customerCode__c != null ? ca.Account.customerCode__c : '';
                fr.statoPratica = ca.status;
                fr.canaleDiRicezione = ca.origin != null ? ca.origin : '';
                fr.reiterata = ca.IsReiteration__c ? 1 : 0;
                fr.epSottotipo = ca.subprocess__c != null ? ca.subprocess__c : '';
                fr.epCausale = '';
                fr.epClassificazione = '';
                fr.teSol = ca.CustomerRequestNumberDay__c + '';
                fr.teLav = dayWorking != null ? dayWorking + '' : '';
                fr.fuoriStdAeegsi = ca.IndemnityConfirmed__c ? '1':'0';
                fr.chiamata = '';
                fr.brand = '';
                fr.segmento = ca.Account.segment__c != null ? ca.Account.segment__c : '';
                fr.comuneCorretto = ca.ServicePoint__r.SupplyCity__c != null ? ca.ServicePoint__r.SupplyCity__c : '';
                fr.istatCorretto = ca.SupplyCityCode__c != null ? ca.SupplyCityCode__c : '';
                fr.provincia = ca.ServicePoint__r.SupplyProvince__c != null ? ca.ServicePoint__r.SupplyProvince__c : '';
                fr.dirittoRettifica = ca.CorrectionRight__c != null ? ca.CorrectionRight__c : '';
                fr.flussoPratica = ca.parentId != null ? 'S' : caseParentiIdChild.get(ca.id) != null ? 'M' : 'U';
                fr.canaleDiUscita = ca.MotivatedResponseSendMode__c != null ? ca.MotivatedResponseSendMode__c : '';
                fr.emailUscita = '';
                fr.richiestePareri = ca.phase__c != null ? ca.phase__c : '';
                wrapReclamiList.add(fr);
            }

    }
    public void finish(Database.BatchableContext context) {
        System.debug('BeforeEnter:' + wrapReclamiList);
        for(HDT_WRP_CampaignPraxidia.reclami fr : wrapReclamiList){
            String rowFile = '';
            rowFile = fr.idJob = ';';
            rowFile = rowFile + fr.rdsRiga + ';' ;
            rowFile = rowFile + fr.acr + ';' ;
            rowFile = rowFile + fr.societa + ';' ;
            rowFile = rowFile + fr.assegnatario + ';' ;
            rowFile = rowFile + fr.gruppo+ ';' ;
            rowFile = rowFile + fr.dataRicevimento + ';' ;
            rowFile = rowFile + fr.dataChiusura + ';' ;
            rowFile = rowFile + fr.tipo+ ';' ;
            rowFile = rowFile + fr.servizio + ';' ;
            rowFile = rowFile + fr.tipoFornitura + ';' ;
            rowFile = rowFile + fr.categoriaCliente + ';' ;
            rowFile = rowFile + fr.codiceCliente + ';' ;
            rowFile = rowFile + fr.statoPratica + ';' ;
            rowFile = rowFile + fr.canaleDiRicezione + ';' ;
            rowFile = rowFile + fr.reiterata + ';' ;
            rowFile = rowFile + fr.epSottotipo + ';' ;
            rowFile = rowFile + fr.epCausale + ';' ;
            rowFile = rowFile + fr.epClassificazione + ';' ;
            rowFile = rowFile + fr.teSol + ';' ;
            rowFile = rowFile + fr.teLav + ';' ; 
            rowFile = rowFile + fr.fuoriStdAeegsi + ';' ; 
            rowFile = rowFile + fr.chiamata + ';' ; 
            rowFile = rowFile + fr.brand + ';' ;
            rowFile = rowFile + fr.segmento + ';' ;
            rowFile = rowFile + fr.comuneCorretto + ';' ; 
            rowFile = rowFile + fr.istatCorretto + ';' ; 
            rowFile = rowFile + fr.provincia + ';' ; 
            rowFile = rowFile + fr.dirittoRettifica + ';' ;
            rowFile = rowFile + fr.flussoPratica + ';' ;
            rowFile = rowFile + fr.canaleDiUscita + ';' ; 
            rowFile = rowFile + fr.emailUscita + ';' ; 
            rowFile = rowFile + fr.richiestePareri + ';' ; 
            rowFile = rowFile + '\n';
            generateFile += rowFile;
            System.debug('BeforeEnter2');
        }
        System.debug('BeforeEnter3');
        Blob generateFileBlob = Blob.valueof(generateFile);
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.VersionData = generateFileBlob;
        String dateTimeString = String.valueOf(Datetime.now()).replaceAll('-', '').replaceAll(':', '').replaceAll(' ', '_');
        cv.Title = 'PraxidiaReclami_' + dateTimeString;
        cv.PathOnClient = 'PraxidiaReclami' + dateTimeString + '.csv';
        contentSRV.insertRecords(new List<ContentVersion>{cv});
       /* ContentVersion cv2 = [Select id,contentDocumentId from ContentVersion Where id = :cv.id][0];
        ContentDocumentLink cnt = new ContentDocumentLink();
        cnt.ContentDocumentId = cv2.ContentDocumentId;
        cnt.LinkedEntityId = '0011q00000mvCKdAAM';
        insert cnt;*/
        system.debug('DOCUMENTO ID:' + cv.id);
        List<String> listIdToSend = new List<String>();
        listIdToSend.add(cv.id);
        HDT_BA_CalloutBatch baSend = new HDT_BA_CalloutBatch();
        baSend.typeCallout = 'Reclami';
        baSend.dtos = listIdToSend;
        Database.executebatch(baSend, 1);
        //HDT_WS_PraxidiaIntegration.callService(cv.id,'Reclami');
    }


}