public with sharing class HDT_WRP_AddressObject {

    @AuraEnabled Public String Stato { get; set; }
	@AuraEnabled Public String Provincia { get; set; }
	@AuraEnabled Public String Comune { get; set; }
	@AuraEnabled Public string CAP { get; set; }
	@AuraEnabled Public string Via { get; set; }
	@AuraEnabled Public string Civico { get; set; }
	@AuraEnabled Public String CodiceComuneSAP { get; set; }
	@AuraEnabled Public String EstensCivico { get; set; }
    @AuraEnabled Public String CodiceViaStradarioSAP { get; set; }
    
    


    public HDT_WRP_AddressObject(){}
    
    public HDT_WRP_AddressObject(String Stato, string Provincia, string Comune, 
                                    string CAP, string Via, string Civico, 
                                    string CodiceComuneSAP, string EstensCivico, string CodiceViaStradarioSAP ) 
    {

        this.Stato = Stato;
		this.Provincia= Provincia;
		this.Via = Via;
		this.CAP= CAP;
		this.Comune = Comune;
		this.Civico = Civico;
		this.CodiceComuneSAP = CodiceComuneSAP	;
		this.EstensCivico= EstensCivico	;
        this.CodiceViaStradarioSAP = CodiceViaStradarioSAP;
        
    }

    @AuraEnabled(cacheable=true)
    public static HDT_WRP_AddressObject getInstance(){

        HDT_WRP_AddressObject h = new HDT_WRP_AddressObject();
        return h;
     
    }




}
