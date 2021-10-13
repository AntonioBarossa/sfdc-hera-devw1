/**
 * @author Valere (valere@noeli-it.net)
 * @date 01/10/2021
 * @description HDT_WS_CreditCheckRequestTst Test Class
 * @history valere - 01/10/2021– Created Class
 */
@istest
public class HDT_WS_CreditCheckRequestTst {
@istest
static void methodTst(){
    List<HDT_WS_CreditCheck.HDT_VFC_InputWrapperDetail> details = new List<HDT_WS_CreditCheck.HDT_VFC_InputWrapperDetail>(); 
    HDT_WS_CreditCheck.HDT_VFC_InputWrapper wrpVals = new HDT_WS_CreditCheck.HDT_VFC_InputWrapper();
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

     system.debug('HDT_WS_CreditCheckRequest - HDT_WS_CreditCheckRequest: wrpVals ----> ' + JSON.serialize(wrpVals));   
     HDT_WS_CreditCheckRequest CreditCheckRequest = new HDT_WS_CreditCheckRequest(wrpVals);
     system.debug('HDT_WS_CreditCheckRequest - HDT_WS_CreditCheckRequest: wrpVals ----> ' + JSON.serialize(wrpVals));   
     system.assertEquals(CreditCheckRequest.sistema,wrpVals.sistema, 'The values ​​of the corresponding fields are identical');
     system.assertNotEquals(CreditCheckRequest.caso,wrpVals.sistema, 'A test of values ​​of different fields');

    }
}