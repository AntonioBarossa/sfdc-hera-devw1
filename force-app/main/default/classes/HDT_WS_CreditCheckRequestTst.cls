/**
 * @author Valere (valere@noeli-it.net)
 * @date 01/10/2021
 * @description HDT_WS_CreditCheckRequestTst Test Class
 * @history valere - 01/10/2021– Created Class
 */
@isTest
public class HDT_WS_CreditCheckRequestTst {

    @isTest
    static void methodTst(){
        List<HDT_WS_CreditCheckRequest.HDT_WRP_InputWrapperDetail> details = new List<HDT_WS_CreditCheckRequest.HDT_WRP_InputWrapperDetail>(); 
        HDT_WS_CreditCheckRequest wrpVals = new HDT_WS_CreditCheckRequest();
        wrpVals.sistema='sistema';
        wrpVals.caso='caso';
        wrpVals.crmEntity='crmEntity';
        wrpVals.crmId='crmId';    
        wrpVals.userId='userId';
        wrpVals.activationUser='activationUser';
        wrpVals.account='account';
        wrpVals.jobTitle='jobTitle';
        wrpVals.internalCustomerId='internalCustomerId';
        wrpVals.companyName='companyName';
        wrpVals.externalCustomerId='externalCustomerId';
        wrpVals.secondaryCustomerId='secondaryCustomerId';
        wrpVals.bpClass='bpClass';
        wrpVals.bpCategory='bpCategory';
        wrpVals.bpType='bpType';
        wrpVals.customerType='customerType';
        wrpVals.address='address';
        wrpVals.municipality='municipality';
        wrpVals.district='district';
        wrpVals.postCode='postCode';
        wrpVals.operation='operation';
        wrpVals.companyGroup='companyGroup';
        wrpVals.market='market';
        wrpVals.offerType='offerType';    
        wrpVals.bpAlternative='bpAlternative';  
        wrpVals.alternativeCustomerId='alternativeCustomerId';
        wrpVals.details=details;

        String wrpValsStr = JSON.serialize(wrpVals);
        HDT_WS_CreditCheckRequest creditCheckRequest = (HDT_WS_CreditCheckRequest)json.deserialize(wrpValsStr, HDT_WS_CreditCheckRequest.class);

        System.assertEquals('sistema', creditCheckRequest.sistema, 'The values ​​of the corresponding fields are identical');
        System.assertNotEquals('caso', creditCheckRequest.sistema, 'A test of values ​​of different fields');
    }
}