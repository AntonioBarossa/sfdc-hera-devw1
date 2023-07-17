/**
 * @author Lorenzo Gulotta (lorenzo.gulotta@webresults.it)
 * @date 24/06/2021
 * @description HDT_BA_PraxidiaFront Class
 * @history Lorenzo Gulotta – 24/06/2021 – Created Class
 */
public class HDT_BA_PraxidiaFront implements Database.Batchable<HDT_WRP_CampaignPraxidia.wrapToIterate>, Database.Stateful,Database.AllowsCallouts{

    List<HDT_WRP_CampaignPraxidia.wrapToIterate> dtos = new List<HDT_WRP_CampaignPraxidia.wrapToIterate>();
    HDT_QR_Order qrOrder = new HDT_QR_Order();
    HDT_QR_Case caseQr = new HDT_QR_Case();
    HDT_SRV_ContentVersion contentSRV = new HDT_SRV_ContentVersion();
    HDT_QR_Contact contactQr = new HDT_QR_Contact();
    List<HDT_WRP_CampaignPraxidia.front> wrapFrontList = new List<HDT_WRP_CampaignPraxidia.front>();
    String header = 'ID_CLIENTE_SBL_SAP;ID_CLIENTE_SAP;ID_CLIENTE_SBL;CODICE_FISCALE;CODICE_FISCALE_SBL;COGNOME;NOME;NOME_SBL;RAGIONE_SOCIALE;RAGIONE_SOCIALE_SBL;NAZIONALITA;CATEGORIA_SBL;ID_CATEGORIA_CLIENTE;SEGMENTO;FLG_PRIVACY_GENERALE;TELEFONO_SBL;TELEFONO_FISSO_2;CELLULARE_2;CELLULARE_SBL;MAIL_SBL;DATA_VALIDITA_A;DATA_VALIDITA_DA;CODICE_RDS;CODICE_SERVIZIO;TIPO_RDS;SOTTOTIPO_RDS;AREA_RDS;ARGOMENTO_RDS;STATO_RDS;CODICE_ACR;POSTAZIONE;GRUPPO_CREATORE;GRUPPO_ASSEGNATARIO;CREAZIONE_DI;CANALE_DI_ACQUISIZIONE;DATA_RICEVIMENTO;STATO_RDO;ID_RDO;ID_ORDINE;TIPO_ORDINE;TIPO_PASSAGGIO;SETTORE_MERCEOLOGICO;TIPO_OPERAZIONE;DF_TIPO_OPERAZIONE_SR;X_CONN_ID;INDIRIZZO_EMAIL_CONTATTO;PROCEDURA\n';
    String generateFile = header;
    public String queryDateCase='';
    public String queryDateOrder='';
    public String startTm;
    public String endTm;

    public HDT_BA_PraxidiaFront(String start, String endTime){

        startTm=start; 
        endTm=endTime;
     }

    public Iterable<HDT_WRP_CampaignPraxidia.wrapToIterate> start(Database.BatchableContext context) {
        List<Order> listOrder =new List<Order>();
        List<Case> listCase =new List<Case>();
        try {
            Datetime startDtCase;
            Datetime endDCaset;
            Datetime dt=Date.Today().addDays(-1);
            string dtYesterday=dt.format('yyyy-MM-dd');

            if(String.isNotBlank(queryDateCase)){
                startDtCase=Datetime.valueOfGMT(queryDateCase + ' ' + startTm + ':00:00');
                endDCaset=Datetime.valueOfGMT(queryDateCase + ' ' + endTm + ':00:00');
                //Datetime endDCaset=startDtCase.addDays(1);
            }
            else {
                startDtCase=Datetime.valueOfGMT(dtYesterday + ' ' + startTm + ':00:00');
                endDCaset=Datetime.valueOfGMT(dtYesterday + ' ' + endTm + ':00:00');
                //listCase = caseQr.getRecordCreatedYesterdayDifferentBy('Reclami');
            }
            listCase = caseQr.getRecordCreatedInRequestedDateDifferentBy('Reclami', startDtCase, endDCaset);

            Datetime startDtOrd;
            Datetime endDtOrd;
            if(String.isNotBlank(queryDateOrder)){
                startDtOrd=Datetime.valueOfGMT(queryDateOrder + ' ' + startTm + ':00:00');
                endDtOrd=Datetime.valueOfGMT(queryDateOrder + ' ' + endTm + ':00:00');
                //Datetime endDtOrd=startDtOrd.addDays(1);
            }
            else {
                startDtOrd=Datetime.valueOfGMT(dtYesterday + ' ' + startTm + ':00:00');
                endDtOrd=Datetime.valueOfGMT(dtYesterday + ' ' + endTm + ':00:00');
                //listOrder = qrOrder.getOrderCreatedYesterday();
            }
            listOrder = qrOrder.getOrderCreatedInRequestedDate(startDtOrd, endDtOrd);
    
            for(Order ord : listOrder){
                dtos.add(new HDT_WRP_CampaignPraxidia.wrapToIterate(ord,null));
            }
            for(Case ca : listCase){
                dtos.add(new HDT_WRP_CampaignPraxidia.wrapToIterate(null,ca));
            }
        } catch (Exception ex) {
            throw ex;
        }
        return this.dtos;
    }


    public void execute(Database.BatchableContext context, List<HDT_WRP_CampaignPraxidia.wrapToIterate> wrapIterable)
    { 
        List<Order> ordList = new List<Order>();
        List<Case> csList = new List<Case>();
        // List<Contact> listContact = new List<Contact>(); //! Variable was not used
        List<String> accountIdList = new List<String>();
        Map<id,Contact> assignAccountIdCont = new Map<id,Contact>();
        for(HDT_WRP_CampaignPraxidia.wrapToIterate wr :wrapIterable){
            if(wr.o != null ){
                ordList.add(wr.o);
                accountIdList.add(wr.o.AccountId);
            }
            if(wr.c != null ){
                csList.add(wr.c);
                accountIdList.add(wr.c.AccountId);
            }
        }
        List<Contact> listContact2 = contactQr.getContactsIdByAccountIdList(accountIdList);
        for(Contact c : listContact2){
            assignAccountIdCont.put(c.accountid,c);
        }
        for(HDT_WRP_CampaignPraxidia.wrapToIterate wr :wrapIterable){
            if(wr.c != null){
                HDT_WRP_CampaignPraxidia.front fr = new HDT_WRP_CampaignPraxidia.front();
                fr.idClienteSblSap = wr.c.account.SAPIntegrationID__c != null ? wr.c.account.SAPIntegrationID__c: '';
                fr.idClienteSap = wr.c.account.SAPIntegrationID__c != null ?wr.c.account.SAPIntegrationID__c : '';
                fr.idClienteSbl = wr.c.account.RowIdSiebel__c != null ? wr.c.account.RowIdSiebel__c : '';
                fr.codiceFiscale =assignAccountIdCont.get(wr.c.accountid) != null ?  assignAccountIdCont.get(wr.c.accountid).FiscalCode__c != null ? assignAccountIdCont.get(wr.c.accountid).FiscalCode__c : ''  : '';
                fr.codiceFiscaleSbl = assignAccountIdCont.get(wr.c.accountid) != null ?  assignAccountIdCont.get(wr.c.accountid).FiscalCode__c != null ? assignAccountIdCont.get(wr.c.accountid).FiscalCode__c : ''  : '';
                fr.cognome = assignAccountIdCont.get(wr.c.accountid) != null ? assignAccountIdCont.get(wr.c.accountid).Lastname != null ? assignAccountIdCont.get(wr.c.accountid).Lastname : '' : '';
                fr.nome = assignAccountIdCont.get(wr.c.accountid) != null ? assignAccountIdCont.get(wr.c.accountid).Firstname != null ? assignAccountIdCont.get(wr.c.accountid).Firstname : '' : '';
                fr.nomeSbl = assignAccountIdCont.get(wr.c.accountid) != null ? assignAccountIdCont.get(wr.c.accountid).Firstname != null ? assignAccountIdCont.get(wr.c.accountid).Firstname : '' : '';
                fr.ragioneSociale = wr.c.Account.Name != null ? wr.c.Account.Name : '';
                fr.ragioneSocialeSbl = wr.c.Account.Name != null ? wr.c.Account.Name : '';
                fr.nazionalita = 'ITALIAN';
                fr.categoriaSbl = wr.c.Account.Category__c != null ? wr.c.Account.Category__c : '';
                fr.idCategoriaCliente = wr.c.Account.CategoryCode__c != null ? wr.c.Account.CategoryCode__c : '';
                fr.segmento = wr.c.Account.Segment__c != null ? wr.c.Account.Segment__c : '';
                fr.flgPrivacyGenerale = assignAccountIdCont.get(wr.c.accountid) != null ? assignAccountIdCont.get(wr.c.accountid).Individual.ProfilingCompanyConsent__c == 'SI' ? 1 : assignAccountIdCont.get(wr.c.accountid).Individual.ProfilingCompanyConsent__c == 'NO' ? 0 : 1 : 0;
                fr.telefonoSbl = assignAccountIdCont.get(wr.c.accountid) != null ? assignAccountIdCont.get(wr.c.accountid).Phone != null ? assignAccountIdCont.get(wr.c.accountid).Phone : '' : '';
                fr.telefonoFisso_2 = assignAccountIdCont.get(wr.c.accountid) != null ? assignAccountIdCont.get(wr.c.accountid).Phone != null ? assignAccountIdCont.get(wr.c.accountid).Phone : '' : '';
                fr.cellulare2 = assignAccountIdCont.get(wr.c.accountid) != null ? assignAccountIdCont.get(wr.c.accountid).mobilePhone != null ? assignAccountIdCont.get(wr.c.accountid).mobilePhone : '' : '';
                fr.cellulareSbl = assignAccountIdCont.get(wr.c.accountid) != null ? assignAccountIdCont.get(wr.c.accountid).mobilePhone != null ? assignAccountIdCont.get(wr.c.accountid).mobilePhone : '' : '';
                fr.mailSbl = assignAccountIdCont.get(wr.c.accountid) != null ? assignAccountIdCont.get(wr.c.accountid).Email != null ? assignAccountIdCont.get(wr.c.accountid).Email : '': '';
                fr.dataValiditaA = '31/1/9999';
                fr.dataValiditaDa = '31/1/9999';
                fr.codiceRds = 'C_' + wr.c.id;
                fr.codiceServizio = wr.c.CommodityFormula__c != null ? wr.c.CommodityFormula__c : '';
                fr.tipoRds = wr.c.Cluster__c != null ? wr.c.Cluster__c : '';
                fr.sottotipoRds = wr.c.type != null ? wr.c.type : '';
               //
                fr.areaRds = wr.c.MacroTopic__c;
                fr.argomentoRds = wr.c.Cluster__c;
                fr.statoRds = wr.c.Phase__c != null ? wr.c.Phase__c : '';
                //
                fr.codiceAcr = wr.c.SalesCompany__c;//wr.c.Account.ACRSegmentation__c;
                fr.postazione = wr.c.Station__c != null ? wr.c.Station__c : '';
                fr.gruppoCreatore = wr.c.CreatorGroup__c != null ? wr.c.CreatorGroup__c : '';
                fr.gruppoAssegnatario = 'ND';
                fr.creazioneDi = wr.c.Createdby.Name;
                fr.canaleDiAcquisizione = wr.c.Origin != null ? wr.c.Origin : '';
                fr.dataRicevimento = wr.c.CreatedDate;
                fr.statoRdo = '';
                fr.idRdo = '';
                fr.idOrdine = '';
                fr.tipoOrdine = 'ND';
                fr.tipoPassaggio = 'ND';
                fr.settoreMerceologico = '';
                fr.tipoOperazione = '';
                fr.dfTipoOperazioneSr = '';
                fr.xConnId = 'ND';
                fr.indirizzoEmailContatto = assignAccountIdCont.get(wr.c.accountid) != null ? assignAccountIdCont.get(wr.c.accountid).Email != null ? assignAccountIdCont.get(wr.c.accountid).Email : '' : '';
                fr.procedura = '';//assignAccountIdCont.get(wr.c.accountid).provenance__c;
                wrapFrontList.add(fr);
            }
            if(wr.o != null){
                HDT_WRP_CampaignPraxidia.front fr2 = new HDT_WRP_CampaignPraxidia.front();
                fr2.idClienteSblSap = wr.o.account.SAPIntegrationID__c != null ? wr.o.account.SAPIntegrationID__c: '';
                fr2.idClienteSap = wr.o.account.SAPIntegrationID__c != null ? wr.o.account.SAPIntegrationID__c : '';
                fr2.idClienteSbl = wr.o.account.RowIdSiebel__c != null ? wr.o.account.RowIdSiebel__c : '';
                fr2.codiceFiscale =assignAccountIdCont.get(wr.o.accountid) != null ?  assignAccountIdCont.get(wr.o.accountid).FiscalCode__c != null ? assignAccountIdCont.get(wr.o.accountid).FiscalCode__c : ''  : '';
                fr2.codiceFiscaleSbl = assignAccountIdCont.get(wr.o.accountid) != null ?  assignAccountIdCont.get(wr.o.accountid).FiscalCode__c != null ? assignAccountIdCont.get(wr.o.accountid).FiscalCode__c : ''  : '';
                fr2.cognome = assignAccountIdCont.get(wr.o.accountid) != null ? assignAccountIdCont.get(wr.o.accountid).Lastname != null ? assignAccountIdCont.get(wr.o.accountid).Lastname : '' : '';
                fr2.nome = assignAccountIdCont.get(wr.o.accountid) != null ? assignAccountIdCont.get(wr.o.accountid).Firstname != null ? assignAccountIdCont.get(wr.o.accountid).Firstname : '' : '';
                fr2.nomeSbl = assignAccountIdCont.get(wr.o.accountid) != null ? assignAccountIdCont.get(wr.o.accountid).Firstname != null ? assignAccountIdCont.get(wr.o.accountid).Firstname : '' : '';
                fr2.ragioneSociale = wr.o.account.Name != null ? wr.o.account.Name : '';
                fr2.ragioneSocialeSbl = wr.o.account.Name != null ? wr.o.account.Name : '';
                fr2.nazionalita = 'ITALIAN';
                fr2.categoriaSbl = wr.o.account.Category__c != null ? wr.o.account.Category__c : '';
                fr2.idCategoriaCliente = wr.o.account.CategoryCode__c != null ? wr.o.account.CategoryCode__c : '';
                fr2.segmento = wr.o.account.Segment__c != null ? wr.o.account.Segment__c : '';
                fr2.flgPrivacyGenerale = assignAccountIdCont.get(wr.o.accountid) != null ? assignAccountIdCont.get(wr.o.accountid).Individual.ProfilingCompanyConsent__c == 'SI' ? 1 : assignAccountIdCont.get(wr.o.accountid).Individual.ProfilingCompanyConsent__c == 'NO' ? 0 : 1 : 0;
                fr2.telefonoSbl = assignAccountIdCont.get(wr.o.accountid) != null ? assignAccountIdCont.get(wr.o.accountid).Phone != null ? assignAccountIdCont.get(wr.o.accountid).Phone : '' : '';
                fr2.telefonoFisso_2 = assignAccountIdCont.get(wr.o.accountid) != null ? assignAccountIdCont.get(wr.o.accountid).Phone != null ? assignAccountIdCont.get(wr.o.accountid).Phone : '' : '';
                fr2.cellulare2 = assignAccountIdCont.get(wr.o.accountid) != null ? assignAccountIdCont.get(wr.o.accountid).mobilePhone != null ? assignAccountIdCont.get(wr.o.accountid).mobilePhone : '' : '';
                fr2.cellulareSbl = assignAccountIdCont.get(wr.o.accountid) != null ? assignAccountIdCont.get(wr.o.accountid).mobilePhone != null ? assignAccountIdCont.get(wr.o.accountid).mobilePhone : '' : '';
                fr2.mailSbl = assignAccountIdCont.get(wr.o.accountid) != null ? assignAccountIdCont.get(wr.o.accountid).Email != null ? assignAccountIdCont.get(wr.o.accountid).Email : '': '';
                fr2.dataValiditaA = '31/12/9999';
                fr2.dataValiditaDa = '31/12/9999';
                fr2.codiceRds = 'O_' + wr.o.id;
                fr2.codiceServizio = wr.o.CommodityFormula__c != null ? wr.o.CommodityFormula__c : '';
                fr2.tipoRds = wr.o.Recordtype.Name;
                fr2.sottotipoRds = wr.o.processType__C != null ? wr.o.processType__C : '';
                fr2.areaRds = 'ND';
                fr2.argomentoRds = 'ND';
                fr2.statoRds = wr.o.Phase__c != null ? wr.o.Phase__c : '';
                fr2.codiceAcr = wr.o.SalesCompany__c;//wr.o.Account.ACRSegmentation__c;
                fr2.postazione = wr.o.LoginWorkstation__c;
                fr2.gruppoCreatore = wr.o.CreatorGroup__c;
                fr2.gruppoAssegnatario = 'ND';
                fr2.creazioneDi = wr.o.Createdby.Name;
                fr2.canaleDiAcquisizione = wr.o.Channel__c != null ? wr.o.Channel__c : '';
                fr2.dataRicevimento = wr.o.CreatedDate;
                fr2.statoRdo = wr.o.status;
                fr2.idRdo = wr.o.OriginalOrderId;
                fr2.idOrdine = wr.o.id;
                fr2.tipoOrdine = 'ND';
                fr2.tipoPassaggio = 'ND';
                fr2.settoreMerceologico = wr.o.CommodityFormula__c != null ? wr.o.CommodityFormula__c : '';
                fr2.tipoOperazione = wr.o.processType__c != null ? wr.o.processType__c : '';
                fr2.dfTipoOperazioneSr = '';
                fr2.xConnId = 'ND';
                fr2.indirizzoEmailContatto = assignAccountIdCont.get(wr.o.accountid) != null ? assignAccountIdCont.get(wr.o.accountid).Email != null ? assignAccountIdCont.get(wr.o.accountid).Email : '' : '';
                fr2.procedura = '';//assignAccountIdCont.get(wr.o.accountid) != null ? assignAccountIdCont.get(wr.o.accountid).provenance__c : '';
                wrapFrontList.add(fr2);
            }
        }
    }
    public void finish(Database.BatchableContext context) {
        For(HDT_WRP_CampaignPraxidia.front ob : wrapFrontList){
            String rowFile = '';
            rowFile = rowFile + ob.idClienteSblSap +';' ;
            rowFile = rowFile + ob.idClienteSap +';' ;
            rowFile = rowFile + ob.idClienteSbl  +';' ;
            rowFile = rowFile + ob.codiceFiscale +';' ;
            rowFile = rowFile + ob.codiceFiscaleSbl +';' ;
            rowFile = rowFile + ob.cognome +';' ;
            rowFile = rowFile + ob.nome+';' ;
            rowFile = rowFile + ob.nomeSbl +';' ;
            rowFile = rowFile + ob.ragioneSociale +';' ;
            rowFile = rowFile + ob.ragioneSocialeSbl +';' ;
            rowFile = rowFile + ob.nazionalita+';' ;
            rowFile = rowFile + ob.categoriaSbl +';' ;
            rowFile = rowFile + ob.idCategoriaCliente +';' ;
            rowFile = rowFile + ob.segmento+';' ;
            rowFile = rowFile + ob.flgPrivacyGenerale +';' ;
            rowFile = rowFile + ob.telefonoSbl+';' ;
            rowFile = rowFile + ob.telefonoFisso_2 +';' ;
            rowFile = rowFile + ob.cellulare2 +';' ;
            rowFile = rowFile + ob.cellulareSbl +';' ;
            rowFile = rowFile + ob.mailSbl +';' ;
            rowFile = rowFile + ob.dataValiditaA +';' ;
            rowFile = rowFile + ob.dataValiditaDa +';' ;
            rowFile = rowFile + ob.codiceRds +';' ;
            rowFile = rowFile + ob.codiceServizio+';' ;
            rowFile = rowFile + ob.tipoRds +';' ;
            rowFile = rowFile + ob.sottotipoRds +';' ;
            rowFile = rowFile + ob.areaRds +';' ;
            rowFile = rowFile + ob.argomentoRds +';' ;
            rowFile = rowFile + ob.statoRds +';' ;
            rowFile = rowFile + ob.codiceAcr+';' ;
            rowFile = rowFile + ob.postazione+';' ;
            rowFile = rowFile + ob.gruppoCreatore +';' ;
            rowFile = rowFile + ob.gruppoAssegnatario +';' ;
            rowFile = rowFile + ob.creazioneDi +';' ;
            rowFile = rowFile + ob.canaleDiAcquisizione +';' ;
            rowFile = rowFile + ob.dataRicevimento +';' ;
            rowFile = rowFile + ob.statoRdo+';' ;
            rowFile = rowFile + (ob.idRdo != null ? ob.idRdo : '')+';' ;
            rowFile = rowFile + ob.idOrdine +';' ;
            rowFile = rowFile + ob.tipoOrdine +';' ;
            rowFile = rowFile + ob.tipoPassaggio +';' ;
            rowFile = rowFile + ob.settoreMerceologico +';' ;
            rowFile = rowFile + ob.tipoOperazione+';' ;
            rowFile = rowFile + ob.dfTipoOperazioneSr +';' ;
            rowFile = rowFile + ob.xConnId +';' ;
            rowFile = rowFile + ob.indirizzoEmailContatto +';' ;
            rowFile = rowFile + ob.procedura +';' ;
            rowFile = rowFile + '\n';
            generateFile += rowFile;
        }
        Blob generateFileBlob = Blob.valueof(generateFile);
        ContentVersion cv = new ContentVersion();
       // cv.body = generateFileBlob;
        cv.ContentLocation = 'S';
        cv.VersionData = generateFileBlob;
        String dateTimeString = String.valueOf(Datetime.now()).replaceAll('-', '').replaceAll(':', '').replaceAll(' ', '_');
        cv.Title = 'PraxidiaFrontOffice_' + dateTimeString;
        cv.PathOnClient = 'PraxidiaFrontOffice' + dateTimeString + '.csv';
        contentSRV.insertRecords(new List<ContentVersion>{cv});
       /* ContentVersion cv2 = [Select id,contentDocumentId from ContentVersion Where id = :cv.id][0];
        ContentDocumentLink cnt = new ContentDocumentLink();
        cnt.ContentDocumentId = cv2.ContentDocumentId;
        cnt.LinkedEntityId = '0011q00000mvmFkAAI';
        insert cnt;*/
        system.debug('DOCUMENTO ID:' + cv.id);
        List<String> listIdToSend = new List<String>();
        listIdToSend.add(cv.id);
        HDT_BA_CalloutBatch baSend = new HDT_BA_CalloutBatch();
        baSend.typeCallout = 'Front Office';
        baSend.dtos = listIdToSend;
        Database.executebatch(baSend, 1);

        //HDT_WS_PraxidiaIntegration.callService(cv.id,'Front Office');
    }


}