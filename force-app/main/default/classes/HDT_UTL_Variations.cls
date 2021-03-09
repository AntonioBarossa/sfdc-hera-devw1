public inherited sharing class HDT_UTL_Variations {


    public static Boolean consistencyCheck(String recordId, String useCategory, String supplyType, String servicePointType){

        return HDT_QR_Variations.queryConsistencyTable(recordId, useCategory, supplyType, servicePointType);

    }


}
