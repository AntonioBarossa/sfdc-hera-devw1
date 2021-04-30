public with sharing class HDT_LC_LeadChangeRecordType {

    private static HDT_SRV_Case caseSrv = new HDT_SRV_Case();
	private static HDT_QR_Recordtype qrRecordtype = new HDT_QR_Recordtype();
    @AuraEnabled
    public static String changeRecordTypeOfLead(Id leadId){

        HDT_QR_RecordType recordtypeQr= new HDT_QR_RecordType();
        Lead lead=new Lead(Id= leadId);
        lead.RecordTypeId= recordtypeQr.getRecordType('HDT_RT_Main', 'Lead').Id;
        HDT_SRV_Lead.checkUpdateAccess(lead);
        Lead l=HDT_SRV_Lead.updateRecord(lead);
		id r = qrRecordtype.getRecordType('HDT_RT_GestionePrivacy', 'Case').id;
   
        Case c=new Case(Subject='Acquisizione Privacy',recordtypeid=r,Type='Modifica Privacy'/*, Category__c= l.Categoria__c, Sottocategoria__c= l.Sottocategoria__c*/);
        Case ce= caseSrv.createRecord(c);

        return ce.Id;
    }
}