/**​
* @author Andrei Necsulescu (andrei.necsulescu@webresults.it)​
* @date 09/04/2021
* @description HDT_WRP_MrrResponse – Wrapper class for JSON string in the Mrr format
* @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica​
*/

public with sharing class HDT_WRP_MrrResponse {
    
    Public with sharing class HDT_WRP_Header {
        Public String requestId;
        Public String requestTimeStamp;
        Public String requestType;
        Public List<HDT_WRP_Field> fields;
    }

    Public with sharing class HDT_WRP_Field {
        Public String fieldType;
        Public String name;
        Public String value;
        Public String rdo;
        Public String rds;
    }

    Public with sharing class HDT_WRP_Object {
        Public List<HDT_WRP_Field> fields;
        Public String id;
        Public String name;
        Public List<HDT_WRP_Object> objects;
        Public String objectType;

    }

    Public with sharing class HDT_WRP_Response {
        
        Public HDT_WRP_Header header;
        Public String code;
        Public String description;
        Public List<HDT_WRP_Object> objects;

    }

    Public List<HDT_WRP_Response> responses;
}