/**
 * @author 'Sabina Levonja' (sabina.levonja@dunegroup.it)
 * @description HDT_LC_LeadChangeRecordType - 
 */

 public with sharing class HDT_LC_LeadChangeRecordType {

    private static HDT_SRV_Case caseSrv = new HDT_SRV_Case();
	private static HDT_QR_Recordtype qrRecordtype = new HDT_QR_Recordtype();
    @AuraEnabled
    public static Map<String,String> changeRecordTypeOfLead(Id leadId){

        try{
            system.debug('ENTRATO IN changeRecordTypeOfLead');
            system.debug('leadId --> '+leadId);
            Map<String,String> mapRes = new Map<String,String>();
            boolean check = false;
            HDT_QR_RecordType recordtypeQr= new HDT_QR_RecordType();
            Lead lead=new Lead(Id= leadId);
            lead.RecordTypeId= recordtypeQr.getRecordType('HDT_RT_Main', 'Lead').Id;
            HDT_SRV_Lead.checkUpdateAccess(lead);
            HDT_SRV_Lead.updateRecord(lead);
            system.debug('PUNTO 1');
            String res = '';
            String s = HDT_QR_ServiceCatalog.getServiceLinkItemAccountRedirectUrlByCategory('', 'Modifica Privacy');
            system.debug('PUNTO 2');
            if(s != null){
               // res = s.replace('&c__accid={!Id}','');
               res = s.replace('&c__accid={!Id}','&c__leadId='+ leadId);
               system.debug('PUNTO 3');
            }
            system.debug('PUNTO 4');
    
            mapRes.put('url',res);
            String us= userinfo.getUserType();
            
            system.debug(us);
            system.debug('PUNTO 5');
    
            if (!'Standard'.Equals(us)){
                system.debug('PUNTO 6');
                check = true;
            }
            mapRes.put('comm',check +'');
    
            Id siteId = Site.getSiteId(); 
            system.debug('PUNTO 7');
                
            if (siteId != null) {
                system.debug('PUNTO 8');
                mapRes.put('isCommunity', 'true');
            } 
            else {
                system.debug('PUNTO 9');
                mapRes.put('isCommunity', 'false');
            }
    
            system.debug('PUNTO 10');
    
            return mapRes;
        }
        catch(Exception e){

            throw new AuraHandledException(e.getMessage());

        }

    }
}