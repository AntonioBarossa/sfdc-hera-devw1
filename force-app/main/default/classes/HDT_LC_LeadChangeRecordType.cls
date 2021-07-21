/**
 * @author 'Sabina Levonja' (sabina.levonja@dunegroup.it)
 * @description HDT_LC_LeadChangeRecordType - 
 */

 public with sharing class HDT_LC_LeadChangeRecordType {

    private static HDT_SRV_Case caseSrv = new HDT_SRV_Case();
	private static HDT_QR_Recordtype qrRecordtype = new HDT_QR_Recordtype();
    @AuraEnabled
    public static String changeRecordTypeOfLead(Id leadId){

        HDT_QR_RecordType recordtypeQr= new HDT_QR_RecordType();
        Lead lead=new Lead(Id= leadId);
        lead.RecordTypeId= recordtypeQr.getRecordType('HDT_RT_Main', 'Lead').Id;
        HDT_SRV_Lead.checkUpdateAccess(lead);
        HDT_SRV_Lead.updateRecord(lead);
        String res = '';
        String s = HDT_QR_ServiceCatalog.getServiceLinkItemAccountRedirectUrlByCategory('', 'Modifica Privacy');
        if(s != null){
           // res = s.replace('&c__accid={!Id}','');
           res = s.replace('&c__accid={!Id}','&c__leadId='+ leadId);
        }
        return res;
    }
}