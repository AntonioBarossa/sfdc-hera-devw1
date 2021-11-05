/**
 * @author Valere (valere@noeli-it.net)
 * @date 28/09/2021
 * @description HDT_WRP_MrrResponseTst Test Class
 * @history valere - 28/09/2021– Created Class
 */
@istest
public class HDT_WRP_MrrResponseTst {
    @istest 
    static void methodTst() {
        HDT_WRP_MrrResponse.HDT_WRP_Header header = new HDT_WRP_MrrResponse.HDT_WRP_Header();
        header.requestId ='requestId';
        header.requestTimeStamp='requestTimeStamp';
        header.requestType='requestType';
        System.assertEquals('requestId',header.requestId,'It is the value of the variable');
        System.assertEquals('requestTimeStamp',header.requestTimeStamp,'It is the value of the variable');
        System.assertNotEquals('requestTypeFalse',header.requestType,'It is not the value of the variable');  
        HDT_WRP_MrrResponse.HDT_WRP_Field field = new HDT_WRP_MrrResponse.HDT_WRP_Field();
        field.fieldType='fieldType';
        field.name='name'; 
        field.value='value';
        field.rdo='rdo';
        field.rds='rds';
        System.assertEquals('fieldType',field.fieldType,'It is the value of the variable');  
        System.assertNotEquals('nameFalse',field.name,'It is not the value of the variable');
        System.assertEquals('value',field.value,'It is the value of the variable');
        System.assertNotEquals('rdoFalse',field.rdo,'It is not the value of the variable');
        System.assertEquals('rds',field.rds,'It is the value of the variable');
        HDT_WRP_MrrResponse.HDT_WRP_Object obj = new HDT_WRP_MrrResponse.HDT_WRP_Object();
        obj.id='id';
        obj.objectType='objectType';
        System.assertEquals('id',obj.id,'It is the value of the variable');
        System.assertNotEquals('objectTypeFalse',obj.objectType,'It is not the value of the variable');
        HDT_WRP_MrrResponse.HDT_WRP_Response res = new HDT_WRP_MrrResponse.HDT_WRP_Response();
        res.code='code';
        res.description='description';
        System.assertEquals('code',res.code,'It is the value of the variable');
        System.assertNotEquals('descriptionFalse',res.description,'It is not the value of the variable');

    }
}