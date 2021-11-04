/**
* @author Sabina Levonja (sabina.levonja@dunegroup.it)
* @date 9/08/2021
* @description HDT_QR_MatrixCompatibilityMap 
* @history Sabina Levonja – 9/08/2021 – created class 
*/

public with sharing class HDT_QR_MatrixCompatibilityMap {

    public static List<HDT_MatrixCompatibilityMap__mdt> getProcessTypeMap(String processType, String type){
        return [SELECT CommoditySector__c, ProcessType__c, ServiceRequestType__c, Type__c  
                FROM HDT_MatrixCompatibilityMap__mdt 
                WHERE ProcessType__c=:processType 
                AND Type__c=:type 
                WITH SECURITY_ENFORCED];
    }
}
