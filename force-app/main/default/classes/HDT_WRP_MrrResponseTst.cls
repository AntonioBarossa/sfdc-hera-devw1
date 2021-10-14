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
        HDT_WRP_MrrResponse.HDT_WRP_Header HDT_WRP_HeaderClass = new HDT_WRP_MrrResponse.HDT_WRP_Header();
        HDT_WRP_HeaderClass.requestId ='requestId';
        HDT_WRP_HeaderClass.requestTimeStamp='requestTimeStamp';
        HDT_WRP_HeaderClass.requestType='requestType';
        System.assertEquals('requestId',HDT_WRP_HeaderClass.requestId,'It is the value of the variable');
        System.assertEquals('requestTimeStamp',HDT_WRP_HeaderClass.requestTimeStamp,'It is the value of the variable');
        System.assertNotEquals('requestTypeFalse',HDT_WRP_HeaderClass.requestType,'It is not the value of the variable');
        HDT_WRP_MrrResponse.HDT_WRP_Field fields = new HDT_WRP_MrrResponse.HDT_WRP_Field();     
        HDT_WRP_MrrResponse.HDT_WRP_Field HDT_WRP_FieldClass = new HDT_WRP_MrrResponse.HDT_WRP_Field();
        HDT_WRP_FieldClass.fieldType='fieldType';
        HDT_WRP_FieldClass.name='name'; 
        HDT_WRP_FieldClass.value='value';
        HDT_WRP_FieldClass.rdo='rdo';
        HDT_WRP_FieldClass.rds='rds';
        System.assertEquals('fieldType',HDT_WRP_FieldClass.fieldType,'It is the value of the variable');  
        System.assertNotEquals('nameFalse',HDT_WRP_FieldClass.name,'It is not the value of the variable');
        System.assertEquals('value',HDT_WRP_FieldClass.value,'It is the value of the variable');
        System.assertNotEquals('rdoFalse',HDT_WRP_FieldClass.rdo,'It is not the value of the variable');
        System.assertEquals('rds',HDT_WRP_FieldClass.rds,'It is the value of the variable');
        HDT_WRP_MrrResponse.HDT_WRP_Object HDT_WRP_ObjectClass = new HDT_WRP_MrrResponse.HDT_WRP_Object();
        HDT_WRP_ObjectClass.id='id';
        HDT_WRP_ObjectClass.objectType='objectType';
        System.assertEquals('id',HDT_WRP_ObjectClass.id,'It is the value of the variable');
        System.assertNotEquals('objectTypeFalse',HDT_WRP_ObjectClass.objectType,'It is not the value of the variable');
        HDT_WRP_MrrResponse.HDT_WRP_Response HDT_WRP_Response = new HDT_WRP_MrrResponse.HDT_WRP_Response();
        HDT_WRP_Response.code='code';
        HDT_WRP_Response.description='description';
        System.assertEquals('code',HDT_WRP_Response.code,'It is the value of the variable');
        System.assertNotEquals('descriptionFalse',HDT_WRP_Response.description,'It is not the value of the variable');

    }
}