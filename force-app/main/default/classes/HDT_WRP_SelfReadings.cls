@SuppressWarnings('PMD.ExcessivePublicCount, PMD.TooManyFields')
public with sharing class HDT_WRP_SelfReadings {

    public class HDT_WRP_SelfReadingsRequest {
        public String id;
        public String contactId;
        public String accountId;
        public String customerCode;
        public String integrationId;
        public String contractCode;
        public String podPdr;
        public String serialNumber;
        public String commodity;
        public String outcome;
        public String outcomeCode;
        public String outcomeDescription;
        public String cluster;
        public String type;
        public String status;
        public String origin;
        public Date readingDate;
        public HDT_WRP_SelfReadingsData readings;
    }

    public class HDT_WRP_SelfReadingsData {
        public String id;
        public String sendTo;
        public String mru;
        public String digits1;
        public String digits2;
        public String digits3;
        public String digits4;
        public String digits5;
        public String digits6;
        public String digits7;
        public String digits8;
        public String digits9;
        public Date date1;
        public Date date2;
        public Date date3;
        public Date date4;
        public Date date5;
        public Date date6;
        public Date date7;
        public Date date8;
        public Date date9;
        public String band1;
        public String band2;
        public String band3;
        public String band4;
        public String band5;
        public String band6;
        public String band7;
        public String band8;
        public String band9;
        public Double value1;
        public Double value2;
        public Double value3;
        public Double value4;
        public Double value5;
        public Double value6;
        public Double value7;
        public Double value8;
        public Double value9;
        public String serialNumber1;
        public String serialNumber2;
        public String serialNumber3;
        public String serialNumber4;
        public String serialNumber5;
        public String serialNumber6;
        public String serialNumber7;
        public String serialNumber8;
        public String serialNumber9;
        public String register1;
        public String register2;
        public String register3;
        public String register4;
        public String register5;
        public String register6;
        public String register7;
        public String register8;
        public String register9;
        public String type1;
        public String type2;
        public String type3;
        public String type4;
        public String type5;
        public String type6;
        public String type7;
        public String type8;
        public String type9;
        public String unit1;
        public String unit2;
        public String unit3;
        public String unit4;
        public String unit5;
        public String unit6;
        public String unit7;
        public String unit8;
        public String unit9;
    }

    public class HDT_WRP_SelfReadingsResponse {
        public String caseId;
        public String readingId;
        public String integrationId;
        public String outcome;
        public String outcomeDescription;
    }
}
