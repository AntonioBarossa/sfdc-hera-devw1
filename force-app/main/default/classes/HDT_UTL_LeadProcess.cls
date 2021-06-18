public with sharing class HDT_UTL_LeadProcess {
    
    public static HDT_WRP_MrrResponse.HDT_WRP_Response formCallback(HDT_WRP_MrrRequest.HDT_WRP_Request request, HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem,HDT_WRP_MrrResponse.HDT_WRP_Object responseObject){
        HDT_WRP_MrrResponse.HDT_WRP_Field responseField = new HDT_WRP_MrrResponse.HDT_WRP_Field();
        responseField.fieldType = 'TEXT';
        responseField.name = 'ESITO';
        responseField.value = 'OK';
        responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField};
        mrrResponseItem.objects.add(responseObject);
        return mrrResponseItem;

    }
    public static HDT_WRP_MrrResponse.HDT_WRP_Response formWinback(HDT_WRP_MrrRequest.HDT_WRP_Request request, HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem,HDT_WRP_MrrResponse.HDT_WRP_Object responseObject){
        HDT_WRP_MrrResponse.HDT_WRP_Field responseField = new HDT_WRP_MrrResponse.HDT_WRP_Field();
        responseField.fieldType = 'TEXT';
        responseField.name = 'ESITO';
        responseField.value = 'OK';
        responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField};
        mrrResponseItem.objects.add(responseObject);
        return mrrResponseItem;

    }
    public static HDT_WRP_MrrResponse.HDT_WRP_Response formCaricBoll(HDT_WRP_MrrRequest.HDT_WRP_Request request, HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem,HDT_WRP_MrrResponse.HDT_WRP_Object responseObject){
        HDT_WRP_MrrResponse.HDT_WRP_Field responseField = new HDT_WRP_MrrResponse.HDT_WRP_Field();
        responseField.fieldType = 'TEXT';
        responseField.name = 'ESITO';
        responseField.value = 'OK';
        responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField};
        mrrResponseItem.objects.add(responseObject);
        return mrrResponseItem;

    }
    public static HDT_WRP_MrrResponse.HDT_WRP_Response formHvac(HDT_WRP_MrrRequest.HDT_WRP_Request request, HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem,HDT_WRP_MrrResponse.HDT_WRP_Object responseObject){
        HDT_WRP_MrrResponse.HDT_WRP_Field responseField = new HDT_WRP_MrrResponse.HDT_WRP_Field();
        responseField.fieldType = 'TEXT';
        responseField.name = 'ESITO';
        responseField.value = 'OK';
        responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField};
        mrrResponseItem.objects.add(responseObject);
        return mrrResponseItem;

    }
    public static HDT_WRP_MrrResponse.HDT_WRP_Response formSol(HDT_WRP_MrrRequest.HDT_WRP_Request request, HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem,HDT_WRP_MrrResponse.HDT_WRP_Object responseObject){
        HDT_WRP_MrrResponse.HDT_WRP_Field responseField = new HDT_WRP_MrrResponse.HDT_WRP_Field();
        responseField.fieldType = 'TEXT';
        responseField.name = 'ESITO';
        responseField.value = 'OK';
        responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField};
        mrrResponseItem.objects.add(responseObject);
        return mrrResponseItem;

    }
}
