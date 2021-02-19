public inherited sharing class HDT_WRP_EligibilityCriteria {

    public class HDT_WRP_Criterion {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public Boolean recIsPresent;
        @AuraEnabled public String eligibilityId;
    }

    public class HDT_WRP_TreeObj {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public List<HDT_WRP_Region> regionList;
    }

	public class HDT_WRP_Region {
		@AuraEnabled public String regionName;
		@AuraEnabled public String regionCode;
		@AuraEnabled public List<HDT_WRP_Province> provinceList;
	}

	public class HDT_WRP_Province {
		@AuraEnabled public String label;
		@AuraEnabled public String value;
		@AuraEnabled public List<HDT_WRP_City> cityList;
	}

    public class HDT_WRP_City {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }

}