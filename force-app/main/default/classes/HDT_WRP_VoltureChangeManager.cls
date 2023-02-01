public with sharing class HDT_WRP_VoltureChangeManager {
    
    /**@frpanico 12/10/2021
     * Wrapper Class for the Volture Manager Package
     **/ 

    public class HDT_WRP_AccountCheck
    {
        public String nextPhase {get; set;}
        //public String activityId {get; set;}
    }

    /**@Author: Salvatore Alessandro Sarà 03/11/2021
     * Wrapper Servizi Q01-Q02
     **/ 
    public String header;
    public List<HDT_WRP_Request> requests;

    public class HDT_WRP_Header {
        public String requestId;
        public String requestTimeStamp;
        public String requestType;
        public List<HDT_WRP_Field> fields;
    }

    public class HDT_WRP_Field {
        public String fieldType;
        public String name;
        public String value;
    }

    public class HDT_WRP_Object {
        public List<HDT_WRP_Field> fields;
        public String id;
        public String name;
        public List<HDT_WRP_Object> objects;
        public String objectType;
    }

    public class HDT_WRP_Request {
        
        public HDT_WRP_Header header;
        public String code;
        public String description;
        public List<HDT_WRP_Object> objects;
    }

    /**@frpanico 01/02/2022
     * Wrapper for Process Check
     */
    public class HDT_WRP_ProcessCheck
    {
        public String result;
        public String message;
        public SObject sobj;

        public HDT_WRP_ProcessCheck(String result, String message)
        {
            this.result = result;
            this.message = message;
        }

        public HDT_WRP_ProcessCheck(String result, String message, SObject sobj)
        {
            this.result = result;
            this.message = message;
            this.sobj = sobj;
        }
    }

    public class HDT_WRP_BodyCall
    {
        public String rds;
        public String rdo;
        public String pod;
        public String contratto;
        public String prestazione;
        public String causale;
        public String tipologia;
    }

    public class HDT_WRP_Prestazione
    {        
        public String rds ='';
        public String rdo ='';
        public String pod ='';
        public String contratto ='';
        public String tipoAttivita ='';
        public String note ='';
    }

    public class HDT_WRP_Response
    {
        public String status ='';
        public String correlationId ='';
        public String timestamp ='';
        public HDT_WRP_Prestazione prestazione; 

        public HDT_WRP_Response( Map<String, Object> mapResponseBody )
        {
            this.status  = (String) mapResponseBody.get('status');
            this.correlationId = (String) mapResponseBody.get('correlationId');
            this.timestamp = (String) mapResponseBody.get('timestamp');
            this.prestazione = (HDT_WRP_Prestazione)JSON.deserialize(JSON.serialize((Map<String, Object>)mapResponseBody.get('prestazione')),HDT_WRP_Prestazione.class);
        }
    }

}