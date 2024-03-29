@SuppressWarnings('PMD.ExcessivePublicCount')
public inherited sharing class HDT_WRP_EligibilityCriteria {

    public class HDT_WRP_Criterion {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public Boolean recIsPresent;
        @AuraEnabled public String eligibilityId;
    }

    public class HDT_WRP_CityZipCode {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public Boolean isEditable;
        @AuraEnabled public List<HDT_WRP_Region> regionList;
    }

	public class HDT_WRP_Region {
		@AuraEnabled public String regionName;
		@AuraEnabled public String regionCode;
        @AuraEnabled public Boolean eligibleForAllCities;
		@AuraEnabled public List<HDT_WRP_Province> provinceList;
	}

	public class HDT_WRP_Province { 
		@AuraEnabled public String label;
		@AuraEnabled public String value;
        @AuraEnabled public Boolean isEnabled;
        //#### 24-02-2023 enhanced eligibleForAllCities
        //@AuraEnabled public Boolean eligibleForAllCities;
		@AuraEnabled public List<HDT_WRP_City> cityAvailable;
        @AuraEnabled public List<HDT_WRP_City> cityRemoved;
	}

    public class HDT_WRP_City {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }

    public class HDT_WRP_MunicipalityTreeObj {
        @AuraEnabled public Boolean eligibleForAllCities;
        @AuraEnabled public List<HDT_WRP_TreeObjItem> treeItemList;
        @AuraEnabled public List<HDT_WRP_TreeObjItem> treeNotAvailableItemList;
    }

    public class HDT_WRP_TreeObjItem {
        @AuraEnabled public String label;
        @AuraEnabled public String name;
        @AuraEnabled public Boolean expanded;
        @AuraEnabled public List<HDT_WRP_TreeObjItem> items;
    }

    public class HDT_WRP_SaveResponse {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public String criteriaId;
        @AuraEnabled public Boolean dataError;
        @AuraEnabled public List<HDT_WRP_LineError> errorData;
    }

    public class HDT_WRP_LineError{
        @auraEnabled public String rowId;
        @auraEnabled public String errorMessage;
    }

}