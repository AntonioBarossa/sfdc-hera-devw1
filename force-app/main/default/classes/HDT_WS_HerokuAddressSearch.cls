public class HDT_WS_HerokuAddressSearch {
    
    @AuraEnabled
    public static HDT_WS_HerokuAddressSearchResponse callServiceCom(String city){
        
        HDT_WS_HerokuAddressSearchRequestCom req = new HDT_WS_HerokuAddressSearchRequestCom(city);
        HDT_WS_HerokuAddressSearchResponse res = (HDT_WS_HerokuAddressSearchResponse)HDT_WS_HTTPServiceCall.sendRequest('VerifIndirizzo', req,HDT_WS_HerokuAddressSearchResponse.class);
        
        return res;
    }    
	@AuraEnabled
    public static HDT_WS_HerokuAddressSearchResponse callServiceInd(String street,String cityCode){
        
        HDT_WS_HerokuAddressSearchRequestInd req = new HDT_WS_HerokuAddressSearchRequestInd(street,cityCode);
        HDT_WS_HerokuAddressSearchResponse res = (HDT_WS_HerokuAddressSearchResponse)HDT_WS_HTTPServiceCall.sendRequest('VerifIndirizzo', req,HDT_WS_HerokuAddressSearchResponse.class);
        
        return res;
    }    
    @AuraEnabled
    public static HDT_WS_HerokuAddressSearchResponse callServiceVer(String modality,String cityCode,String streetCode,String houseNumCode){
        
        HDT_WS_HerokuAddressSearchRequestVer req = new HDT_WS_HerokuAddressSearchRequestVer(modality,cityCode,streetCode,houseNumCode);
        HDT_WS_HerokuAddressSearchResponse res = (HDT_WS_HerokuAddressSearchResponse)HDT_WS_HTTPServiceCall.sendRequest('VerifIndirizzo', req,HDT_WS_HerokuAddressSearchResponse.class);
        
        return res;
    }    
    public class HDT_WS_HerokuAddressSearchRequestCom extends HDT_WS_Request{
        @AuraEnabled public HDT_WS_PrestazioneREQObj prestazione{get;set;}
        public HDT_WS_HerokuAddressSearchRequestCom(String city){
            this.prestazione = new HDT_WS_PrestazioneREQObj();
            this.prestazione.city1 = city;
        }
	}
    public class HDT_WS_HerokuAddressSearchRequestInd extends HDT_WS_Request{
        @AuraEnabled public HDT_WS_PrestazioneREQObjInd prestazione{get;set;}
        public HDT_WS_HerokuAddressSearchRequestInd(String street,String cityCode){
            this.prestazione = new HDT_WS_PrestazioneREQObjInd();
            this.prestazione.street = street;
            this.prestazione.cityCode = cityCode;
        }
	}
    public class HDT_WS_HerokuAddressSearchRequestVer extends HDT_WS_Request{
        @AuraEnabled public HDT_WS_PrestazioneREQObjVer prestazione{get;set;}
        public HDT_WS_HerokuAddressSearchRequestVer(String modality,String cityCode,String streetCode,String houseNumCode){
            this.prestazione = new HDT_WS_PrestazioneREQObjVer();
            this.prestazione.modality = modality;
            this.prestazione.cityCode = cityCode;
            this.prestazione.streetCode = streetCode;
            this.prestazione.houseNumCode = houseNumCode; 
        }
	}
    public class HDT_WS_HerokuAddressSearchResponse extends HDT_WS_Response{
        @AuraEnabled public List<HDT_WS_PrestazioneObj> prestazione{get;set;} 
	}
    public class HDT_WS_PrestazioneObj{
        @AuraEnabled public String city1 {get;set;}
        @AuraEnabled public String street {get;set;}
        @AuraEnabled public String streetCode {get;set;}
        @AuraEnabled public String region {get;set;}
        @AuraEnabled public String postCode1 {get;set;}
        @AuraEnabled public String strTypeAB {get;set;}
        @AuraEnabled public String houseNum1 {get;set;}
        @AuraEnabled public String modality {get;set;}
        @AuraEnabled public String cityCode {get;set;}
        @AuraEnabled public String houseNumCode {get;set;}       
    }
    public class HDT_WS_PrestazioneREQObj{
        @AuraEnabled public String city1 {get;set;}
      //  @AuraEnabled public String street {get;set;}
      //  @AuraEnabled public String houseNum1 {get;set;}
      //  @AuraEnabled public String modality {get;set;}
      //  @AuraEnabled public String cityCode {get;set;}
      //  @AuraEnabled public String streetCode {get;set;}
      //  @AuraEnabled public String houseNumCode {get;set;}       
    }
    public class HDT_WS_PrestazioneREQObjInd{
        @AuraEnabled public String street {get;set;}
        @AuraEnabled public String cityCode {get;set;}      
    }
    public class HDT_WS_PrestazioneREQObjVer{
      //  @AuraEnabled public String city1 {get;set;}
      //  @AuraEnabled public String street {get;set;}
      //  @AuraEnabled public String houseNum1 {get;set;}
        @AuraEnabled public String modality {get;set;}
        @AuraEnabled public String cityCode {get;set;}
        @AuraEnabled public String streetCode {get;set;}
        @AuraEnabled public String houseNumCode {get;set;}       
    }
    
    
}