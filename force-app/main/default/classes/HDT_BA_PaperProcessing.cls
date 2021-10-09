/**
* @author Lorenzo (lorenzo.gulotta@webresults.it)
* @date 25/06/2021
* @description HDT_UTL_Note
* @history Lorenzo – 25/06/2021 – created class
*/
public with sharing class HDT_BA_PaperProcessing implements Database.Batchable<sObject> {
    private static HDT_QR_CampaignMember campaignMemberQr = new HDT_QR_CampaignMember();
    private static HDT_QR_Contract contractQr = new HDT_QR_Contract();

    public List<String> paperProcessingIds = new List<String>();
    public List<CampaignMember> campaignMembers;
    public String contentVersionId;
    public list<String> contentVersionIdList = new List<String>();
    //public List<Contract> contractList = new List<Contract>();
    //public Map<String, Contract> cmContract = new Map<String, Contract>();
    //public List<HDT_WRP_PaperProcessing> ppWrapList = new List<HDT_WRP_PaperProcessing>();
    public HDT_BA_PaperProcessing(List<String> paperProcessingIds) {
        this.paperProcessingIds = paperProcessingIds;
      //  this.campaignMembers = campaignMemberQr.getCampaignMembersForPaperProcessing(paperProcessingId);
      //  Map<String, String> cmContractRef = new Map<String, String>();
      //  for (CampaignMember cm : this.campaignMembers) {
      //      if (cm.ContractReference__c != null) {
      //          cmContractRef.put(cm.Id, '\''+ String.join(cm.ContractReference__c.split(','), '\',\'') + '\'');
      //      }
      //  }
      //  String contractRefs = String.join(cmContractRef.values(), ',');
      //  if (contractRefs != '') {
         //   this.contractList = contractQr.getSupplyAddressByContractNumber(contractRefs.split(','));
       // }
      //  System.debug(contractRefs);
      //  Map<String, String> cmContractNumber = new Map<String, String>();
      ////  for (String ref : cmContractRef.values()) {
            
       // }
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        String query = 'SELECT Id,PaperProcess__c,ContactId,LeadId,Contact.Account.CustomerCode__c,Contact.Company__c,Lead.Company__c,Contact.FirstName,Contact.LastName,Lead.FirstName,Lead.LastName,Contact.FiscalCode__c,Lead.FiscalCode__c,Contact.VATNumber__c,Lead.VATNumber__c,Contact.MailingStreetName__c,Lead.Street,Contact.MailingStreetNumber__c,Lead.StreetNumber__c,Contact.MailingPostalCode,Lead.PostalCode,Contact.MailingCity,Lead.City,Contact.MailingState,Lead.State,Contact.MailingCountry,Lead.Country,ContractReference__c,Campaign.PaperCampaignParameter__r.LetterType__c,Campaign.PaperCampaignParameter__r.ShippingMode__c,Campaign.PaperCampaignParameter__r.Aggregation__c,Campaign.PaperCampaignParameter__r.Lot__c,Campaign.PaperCampaignParameter__r.LotDate__c,Campaign.PaperCampaignParameter__r.Field2__c,Campaign.PaperCampaignParameter__r.Field3__c,Campaign.PaperCampaignParameter__r.Field4__c,Campaign.PaperCampaignParameter__r.Field5__c,Campaign.PaperCampaignParameter__r.Field6__c,Campaign.PaperCampaignParameter__r.Field7__c,Campaign.PaperCampaignParameter__r.Field8__c,Campaign.PaperCampaignParameter__r.Field9__c,Campaign.PaperCampaignParameter__r.Field10__c,Campaign.PaperCampaignParameter__r.Field11__c,Campaign.PaperCampaignParameter__r.Field12__c,Campaign.PaperCampaignParameter__r.Field13__c,Campaign.PaperCampaignParameter__r.Field14__c,Campaign.PaperCampaignParameter__r.Field15__c,Campaign.PaperCampaignParameter__r.Field16__c,Campaign.PaperCampaignParameter__r.Field17__c,Campaign.PaperCampaignParameter__r.Field18__c,Campaign.PaperCampaignParameter__r.Field19__c,Campaign.PaperCampaignParameter__r.Field20__c,Campaign.PaperCampaignParameter__r.Field21__c,Campaign.PaperCampaignParameter__r.Field22__c,Campaign.PaperCampaignParameter__r.Field23__c,Campaign.PaperCampaignParameter__r.Field24__c,Campaign.PaperCampaignParameter__r.Field25__c,Campaign.PaperCampaignParameter__r.Field26__c,Campaign.PaperCampaignParameter__r.Field27__c,Campaign.PaperCampaignParameter__r.Field28__c,Campaign.PaperCampaignParameter__r.Field29__c,Campaign.PaperCampaignParameter__r.Field30__c,Campaign.PaperCampaignParameter__r.Field31__c,Campaign.PaperCampaignParameter__r.Field32__c,Campaign.PaperCampaignParameter__r.Field33__c,Campaign.PaperCampaignParameter__r.Field34__c,Campaign.PaperCampaignParameter__r.Field35__c,Campaign.PaperCampaignParameter__r.Field36__c,Campaign.PaperCampaignParameter__r.Field37__c,Campaign.PaperCampaignParameter__r.Field38__c,Campaign.PaperCampaignParameter__r.Field39__c,Campaign.PaperCampaignParameter__r.Field40__c FROM CampaignMember WHERE CampaignId IN(SELECT Campaign__c FROM PaperProcessing__c WHERE id IN :paperProcessingIds) AND PaperProcess__c IN :paperProcessingIds';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<CampaignMember> scope) {
        List<HDT_WRP_PaperProcessing> ppWrapList = new List<HDT_WRP_PaperProcessing>();
        for(CampaignMember cm : scope) { 
            //cm.PaperProcess__c = paperProcessingId;
            //campaignMembers.add(cm);
            HDT_WRP_PaperProcessing ppwrap =  new HDT_WRP_PaperProcessing();
            ppwrap.CRM_communication_Id =cm.PaperProcess__c+'_'+cm.id;
            ppwrap.codCliente = cm.Contact.Account.CustomerCode__c;
            ppwrap.nome = (cm.Contact.FirstName != '' && cm.Contact.FirstName != null) ? cm.Contact.FirstName : cm.Lead.FirstName;
            ppwrap.cognome = (cm.Contact.LastName != '' && cm.Contact.LastName != null) ? cm.Contact.LastName : cm.Lead.LastName;
            ppwrap.ragSociale = (cm.Contact.Company__c != '' && cm.Contact.Company__c != null) ? cm.Contact.Company__c : cm.Lead.Company__c;
            ppwrap.codFiscale = (cm.Contact.FiscalCode__c != '' && cm.Contact.FiscalCode__c != null) ? cm.Contact.FiscalCode__c : cm.Lead.FiscalCode__c;
            ppwrap.pIva = (cm.Contact.VATNumber__c != '' && cm.Contact.VATNumber__c != null) ? cm.Contact.VATNumber__c : cm.Lead.VATNumber__c;
            ppwrap.resIndirizo = (cm.Contact.MailingStreetName__c != '' && cm.Contact.MailingStreetName__c != null) ? cm.Contact.MailingStreetName__c : cm.Lead.Street;
            ppwrap.resCivico = (cm.Contact.MailingStreetNumber__c != '' && cm.Contact.MailingStreetNumber__c != null) ? cm.Contact.MailingStreetNumber__c : cm.Lead.StreetNumber__c;
            ppwrap.resCap = (cm.Contact.MailingPostalCode != '' && cm.Contact.MailingPostalCode != null)  ? cm.Contact.MailingPostalCode : cm.Lead.PostalCode;
            ppwrap.resComune = (cm.Contact.MailingCity != '' && cm.Contact.MailingCity != null)  ? cm.Contact.MailingCity : cm.Lead.City;
            ppwrap.resProv = (cm.Contact.MailingState != '' && cm.Contact.MailingState != null)  ? cm.Contact.MailingState : cm.Lead.State;
            ppwrap.codContratto = cm.ContractReference__c;
            ppwrap.tipoLettera = cm.Campaign.PaperCampaignParameter__r.LetterType__c;
            ppwrap.modalitaSpedizione = cm.Campaign.PaperCampaignParameter__r.ShippingMode__c;
            ppwrap.aggregazione = cm.Campaign.PaperCampaignParameter__r.Aggregation__c;
            ppwrap.lotto = cm.Campaign.PaperCampaignParameter__r.Lot__c;
            ppwrap.dataLotto = cm.Campaign.PaperCampaignParameter__r.LotDate__c;
            ppwrap.recIndirizzo = (cm.Contact.MailingStreetName__c != '' && cm.Contact.MailingStreetName__c != null) ? cm.Contact.MailingStreetName__c : cm.Lead.Street;
            ppwrap.recCivico = (cm.Contact.MailingStreetNumber__c != '' && cm.Contact.MailingStreetNumber__c != null) ? cm.Contact.MailingStreetNumber__c : cm.Lead.StreetNumber__c;
            ppwrap.recCap = (cm.Contact.MailingPostalCode != '' && cm.Contact.MailingPostalCode != null)  ? cm.Contact.MailingPostalCode : cm.Lead.PostalCode;
            ppwrap.recComune = (cm.Contact.MailingCity != '' && cm.Contact.MailingCity != null)  ? cm.Contact.MailingCity : cm.Lead.City;
            ppwrap.recProv = (cm.Contact.MailingState != '' && cm.Contact.MailingState != null)  ? cm.Contact.MailingState : cm.Lead.State;
            ppwrap.recNazione = (cm.Contact.MailingCountry != '' && cm.Contact.MailingCountry != null)  ? cm.Contact.MailingCountry : cm.Lead.Country;
            ppwrap.raccoIndirizzo = (cm.Contact.MailingStreetName__c != '' && cm.Contact.MailingStreetName__c != null) ? cm.Contact.MailingStreetName__c : cm.Lead.Street;
            ppwrap.raccoCivico = (cm.Contact.MailingStreetNumber__c != '' && cm.Contact.MailingStreetNumber__c != null) ? cm.Contact.MailingStreetNumber__c : cm.Lead.StreetNumber__c;
            ppwrap.raccoCap = (cm.Contact.MailingPostalCode != '' && cm.Contact.MailingPostalCode != null)  ? cm.Contact.MailingPostalCode : cm.Lead.PostalCode;
            ppwrap.raccoComune = (cm.Contact.MailingCity != '' && cm.Contact.MailingCity != null)  ? cm.Contact.MailingCity : cm.Lead.City;
            ppwrap.raccoProv = (cm.Contact.MailingState != '' && cm.Contact.MailingState != null)  ? cm.Contact.MailingState : cm.Lead.State;
            ppwrap.campo2 = cm.Campaign.PaperCampaignParameter__r.Field2__c;
            ppwrap.campo3 = cm.Campaign.PaperCampaignParameter__r.Field3__c;
            ppwrap.campo4 = cm.Campaign.PaperCampaignParameter__r.Field4__c;
            ppwrap.campo5 = cm.Campaign.PaperCampaignParameter__r.Field5__c;
            ppwrap.campo6 = cm.Campaign.PaperCampaignParameter__r.Field6__c;
            ppwrap.campo7 = cm.Campaign.PaperCampaignParameter__r.Field7__c;
            ppwrap.campo8 = cm.Campaign.PaperCampaignParameter__r.Field8__c;
            ppwrap.campo9 = cm.Campaign.PaperCampaignParameter__r.Field9__c;
            ppwrap.campo10 = cm.Campaign.PaperCampaignParameter__r.Field10__c;
            ppwrap.campo11 = cm.Campaign.PaperCampaignParameter__r.Field11__c;
            ppwrap.campo12 = cm.Campaign.PaperCampaignParameter__r.Field12__c;
            ppwrap.campo13 = cm.Campaign.PaperCampaignParameter__r.Field13__c;
            ppwrap.campo14 = cm.Campaign.PaperCampaignParameter__r.Field14__c;
            ppwrap.campo15 = cm.Campaign.PaperCampaignParameter__r.Field15__c;
            ppwrap.campo16 = cm.Campaign.PaperCampaignParameter__r.Field16__c;
            ppwrap.campo17 = cm.Campaign.PaperCampaignParameter__r.Field17__c;
            ppwrap.campo18 = cm.Campaign.PaperCampaignParameter__r.Field18__c;
            ppwrap.campo19 = cm.Campaign.PaperCampaignParameter__r.Field19__c;
            ppwrap.campo20 = cm.Campaign.PaperCampaignParameter__r.Field20__c;
            ppwrap.campo21 = cm.Campaign.PaperCampaignParameter__r.Field21__c;
            ppwrap.campo22 = cm.Campaign.PaperCampaignParameter__r.Field22__c;
            ppwrap.campo23 = cm.Campaign.PaperCampaignParameter__r.Field23__c;
            ppwrap.campo24 = cm.Campaign.PaperCampaignParameter__r.Field24__c;
            ppwrap.campo25 = cm.Campaign.PaperCampaignParameter__r.Field25__c;
            ppwrap.campo26 = cm.Campaign.PaperCampaignParameter__r.Field26__c;
            ppwrap.campo27 = cm.Campaign.PaperCampaignParameter__r.Field27__c;
            ppwrap.campo28 = cm.Campaign.PaperCampaignParameter__r.Field28__c;
            ppwrap.campo29 = cm.Campaign.PaperCampaignParameter__r.Field29__c;
            ppwrap.campo30 = cm.Campaign.PaperCampaignParameter__r.Field30__c;
            ppwrap.campo31 = cm.Campaign.PaperCampaignParameter__r.Field31__c;
            ppwrap.campo32 = cm.Campaign.PaperCampaignParameter__r.Field32__c;
            ppwrap.campo33 = cm.Campaign.PaperCampaignParameter__r.Field33__c;
            ppwrap.campo34 = cm.Campaign.PaperCampaignParameter__r.Field34__c;
            ppwrap.campo35 = cm.Campaign.PaperCampaignParameter__r.Field35__c;
            ppwrap.campo36 = cm.Campaign.PaperCampaignParameter__r.Field36__c;
            ppwrap.campo37 = cm.Campaign.PaperCampaignParameter__r.Field37__c;
            ppwrap.campo38 = cm.Campaign.PaperCampaignParameter__r.Field38__c;
            ppwrap.campo39 = cm.Campaign.PaperCampaignParameter__r.Field39__c;
            ppwrap.campo40 = cm.Campaign.PaperCampaignParameter__r.Field40__c;

            ppWrapList.add(ppwrap);
            String fileName = 'Report_Clienti_' + cm.PaperProcess__c + date.today().year() + date.today().month() + date.today().day();
            contentVersionIdList.add(HDT_UTL_PaperProcessing.generateFile(ppWrapList, cm.PaperProcess__c, fileName));
        }
        //update campaignMembers;
        System.debug('------ '+ppWrapList.size());
    }

    public void finish(Database.BatchableContext bc){
        //ws call
        /*List<String> listIdToSend = new List<String>();
        listIdToSend.add(cv.id);*/
        HDT_BA_CalloutBatch baSend = new HDT_BA_CalloutBatch();
        baSend.typeCallout = 'Comunicazione Cartacea';
        baSend.dtos = contentVersionIdList;
        baSend.filezipName = 'Lavorazione_Cartacea_'+ paperProcessingIds;
        Database.executebatch(baSend, 100);

        //String filezipName = 'Comunicazioni';
       // String type = 'Comunicazione Cartacea';
       // String wsResponse = HDT_UTL_PaperProcessing.postPaperProcessing(filezipName, type, this.contentVersionId);
        //System.debug(wsResponse);
      //  System.debug('-------- finish batch');
    }
}