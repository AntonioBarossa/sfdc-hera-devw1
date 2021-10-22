/*
    @Author:        Davide Viola
    CreatedDate:    11/10/2021
*/

@isTest
public class HDT_WRP_DocumentalRequestTst {
    
    public static testMethod void testHDT_WRP_DocumentalPackage(){
        
        Test.startTest();
        
        String name = 'name';
        String value = 'value';
        HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalDriver docDriver = new HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalDriver();
        docDriver.name = name;
        docDriver.value = value;        
        HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalDriver docDriverConstructor = new HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalDriver(docDriver);
        
        HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalPackage docPack = new HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalPackage();
        docPack.driver = new List<HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalDriver>{docDriver};
            docPack.payloadBase64 = 'payloadBase64';
        HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalPackage docPackConstructor = new HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalPackage(docPack);
        docPackConstructor = new HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalPackage(
            new List<HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalDriver>{docDriver}, 'payloadBase64'
        );
        
        HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalSignInfo signInfo = new HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalSignInfo();
        signInfo.customerEnvironmentId = 'customerEnvironmentId';
        signInfo.pageUrl = 'pageUrl';
        signInfo.status = 'status';
        signInfo.idCheckConfigurationName = 'idCheckConfigurationName';
        signInfo.requireIdLookup = 'requireIdLookup';
        
        
        HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalDeliverPackageRequest request = new HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalDeliverPackageRequest();
        
        HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalCustomerInfo custInfo = new HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalCustomerInfo();
        custInfo.vatNumber = 'vatNumber';
        custInfo.fiscalCode = 'fiscalCode';
        custInfo.contractCode = 'contractCode';
        custInfo.creationUrl = 'creationUrl';
        custInfo.emailSubject = 'emailSubject';
        custInfo.email = 'email';
        custInfo.name = 'name';
        
        HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalTemplate docTemplate = new HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalTemplate();
        docTemplate.sequence = 'sequence';
        docTemplate.templateId = 'templateId';
        
        Test.stopTest();
    }
}