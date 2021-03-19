/**​
* @author Andrei Necsulescu (andrei.necsulescu@webresults.it)​
* @date 17/03/2021
* @description HDT_WRP_MrrRequest – Wrapper class for JSON string in the Mrr format
* @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica​
*/

public with sharing class HDT_WRP_MrrRequest {

    Public with sharing class HDT_WRP_Header {
        Public String requestId;
        Public String requestTimeStamp;
        Public String requestType;
    }

    Public with sharing class HDT_WRP_Field {
        Public String fieldType;
        Public String name;
        Public String value;
    }

    Public with sharing class HDT_WRP_Object {
        Public List<HDT_WRP_Field> fields;
        Public String id;
        Public String name;
        Public List<HDT_WRP_Object> objects;
        Public String objectType;

    }

    Public with sharing class HDT_WRP_Request {
        
        Public HDT_WRP_Header header;
        Public List<HDT_WRP_Object> objects;

    }

    Public List<HDT_WRP_Request> requests;
    
}
