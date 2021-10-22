@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_WS_DocumentalIntegration {
    
    public static HDT_WRP_DocumentalResponse submitRequest(String body){
        HDT_WRP_DocumentalResponse documentalResponse = new HDT_WRP_DocumentalResponse();
        try{
            HttpRequest req = new HttpRequest();
            req.setEndpoint('Callout:Engage1');
            req.setMethod('POST');
            req.setBody(body);
            req.setHeader('Content-Type','application/json');
            req.setTimeout(120000);
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            // da scommentare solo per debug temporanei, la response può essere molto grande e causare un heap size exception.
            //System.debug(LoggingLevel.DEBUG, 'Engage1 response: ' + res.getBody());
            Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            if (responseBodyMap.containsKey('data')) {
                System.debug(LoggingLevel.DEBUG, JSON.serialize(responseBodyMap.get('data')));
                documentalResponse = (HDT_WRP_DocumentalResponse) JSON.deserialize(JSON.serialize(responseBodyMap.get('data')), HDT_WRP_DocumentalResponse.class);
            }
            documentalResponse.responseCode = res.getStatusCode();
            documentalResponse.responseStatus =  res.getStatus();             
        } catch (Exception ex) {
            System.debug(LoggingLevel.DEBUG, 'Errore WS ' + ex.getMessage() + ' at line ' + ex.getLineNumber());
        }

        return documentalResponse;
    }

    public static HDT_WRP_DocumentalResponse.HDT_WRP_PostelResponse submitGetAttachmentRequest(String body){
        HDT_WRP_DocumentalResponse.HDT_WRP_PostelResponse postelResponse = new HDT_WRP_DocumentalResponse.HDT_WRP_PostelResponse();
        try{
            HttpRequest req = new HttpRequest();
            req.setEndpoint('Callout:GetAttachmentPostel');
            req.setMethod('POST');
            req.setBody(body);
            req.setHeader('Content-Type','application/json');
            req.setTimeout(120000);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            if (responseBodyMap.containsKey('data')) {
                //System.debug(JSON.serialize(responseBodyMap.get('data')));
                postelResponse = (HDT_WRP_DocumentalResponse.HDT_WRP_PostelResponse) JSON.deserialize(JSON.serialize(responseBodyMap.get('data')), HDT_WRP_DocumentalResponse.HDT_WRP_PostelResponse.class);
            }
            postelResponse.responseCode = res.getStatusCode();
            postelResponse.responseStatus =  res.getStatus();
        } catch (Exception ex) {
            System.debug(LoggingLevel.DEBUG, 'Errore WS ' + ex.getMessage() + ' at line ' + ex.getLineNumber());
        }

        return postelResponse;
    }

    public static HDT_WRP_DocumentalResponse.HDT_WRP_PostelResponse submitGetEnvelopePostelRequest(String body){
        
        System.debug(LoggingLevel.DEBUG, 'HDT_WS_DocumentalIntegration - submitGetEnvelopePostelRequest');
        HDT_WRP_DocumentalResponse.HDT_WRP_PostelResponse postelResponse = new HDT_WRP_DocumentalResponse.HDT_WRP_PostelResponse();
        try{
            HttpRequest req = new HttpRequest();
            req.setEndpoint('Callout:GetEnvelopePostel');
            req.setMethod('POST');
            req.setBody(body);
            req.setHeader('Content-Type','application/json');
            Http http = new Http();
            HTTPResponse res = http.send(req);
            Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            if (responseBodyMap.containsKey('data')) {
                //System.debug(JSON.serialize(responseBodyMap.get('data')));
                postelResponse = (HDT_WRP_DocumentalResponse.HDT_WRP_PostelResponse) JSON.deserialize(JSON.serialize(responseBodyMap.get('data')), HDT_WRP_DocumentalResponse.HDT_WRP_PostelResponse.class);
            }
            postelResponse.responseCode = res.getStatusCode();
            postelResponse.responseStatus =  res.getStatus();
        } catch (Exception ex) {
            System.debug(LoggingLevel.DEBUG, 'Errore WS ' + ex.getMessage() + ' at line ' + ex.getLineNumber());
            System.debug(LoggingLevel.DEBUG, 'ex StackTraceString: ' + ex.getStackTraceString());
            
        }
        return postelResponse;
    }

    public static HDT_WRP_DocumentalResponse.HDT_WRP_PostelResponse submitGetIntesaZipRequest(String body){
        HDT_WRP_DocumentalResponse.HDT_WRP_PostelResponse responseWrap = new HDT_WRP_DocumentalResponse.HDT_WRP_PostelResponse();
        try{
            HttpRequest req = new HttpRequest();
            req.setEndpoint('Callout:MulesoftBasePath/zip-files');
            req.setMethod('POST');
            req.setBody(body);
            req.setHeader('Content-Type','application/json');
            req.setTimeout(120000);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            responseWrap.responseCode = res.getStatusCode();
            responseWrap.responseStatus =  res.getStatus();

            Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            if (responseBodyMap.containsKey('data')) {
                Map<String, Object> responseData = (Map<String, Object>) responseBodyMap.get('data');
                String status = (String) responseData.get('status');
                switch on status {
                    when 'ERROR' {
                        String zipBaseSixtyFour = (String) responseData.get('zipBase64');
                        if (String.isBlank(zipBaseSixtyFour)) {
                            throw new HDT_UTL_HeraException('Errore Intesa nel recupero della Busta archiviata.');
                        } else {
                            responseWrap.content = zipBaseSixtyFour;
                        }
                    }
                    when 'PROGRESS' {
                        String zipBaseSixtyFour = (String) responseData.get('zipBase64');
                        if (String.isBlank(zipBaseSixtyFour)) {
                            throw new HDT_UTL_HeraException('Impossibile visualizzare il plico (Busta Docusign non ancora completata)');
                        } else {
                            responseWrap.content = zipBaseSixtyFour;
                        }
                    }
                    when 'TERMINATE' {
                        String zipBaseSixtyFour = (String) responseData.get('zipBase64');
                        if (String.isBlank(zipBaseSixtyFour)) {
                            throw new HDT_UTL_HeraException('Impossibile visualizzare il plico (Busta Docusign non disponibile o non completata)');
                        } else {
                            responseWrap.content = zipBaseSixtyFour;
                        }
                    }
                }
            }

        }catch(Exception ex){
            System.debug(LoggingLevel.DEBUG, 'Errore WS ' + ex.getMessage() + ' at line ' + ex.getLineNumber());
            throw ex;
        }
        return responseWrap;
    }

    public static HDT_WRP_DocumentalResponse.HDT_WRP_IntesaResponse submitResendDocusignEnvelopeRequest(String body){
        HDT_WRP_DocumentalResponse.HDT_WRP_IntesaResponse responseWrap = new HDT_WRP_DocumentalResponse.HDT_WRP_IntesaResponse();
        try{
            HttpRequest req = new HttpRequest();
            req.setEndpoint('Callout:MulesoftBasePath/resend/communications');
            req.setMethod('POST');
            req.setBody(body);
            req.setHeader('Content-Type','application/json');
            req.setTimeout(120000);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            if (responseBodyMap.containsKey('errorDetails')) {
                System.debug(LoggingLevel.DEBUG, 'submitResendDocusignEnvelopeRequest - errorDetails: ' + JSON.serialize(responseBodyMap.get('errorDetails')));
                List<Object> errors = (List<Object>) responseBodyMap.get('errorDetails');
                if (errors != null && !errors.isEmpty()) {
                    Map<String, Object> errorObj = (Map<String, Object>) errors[0];
                    String errorMessage = (String) errorObj.get('additionalInfo');
                    if (String.isNotBlank(errorMessage)){
                        throw new HDT_UTL_HeraException(errorMessage);
                    }
                }
            }

            responseWrap.responseCode = res.getStatusCode();
            responseWrap.responseStatus =  res.getStatus();
        }catch(Exception ex){
            System.debug(LoggingLevel.DEBUG, 'Errore WS ' + ex.getMessage() + ' at line ' + ex.getLineNumber());
            throw ex;
        }
        return responseWrap;
    }

    public static HDT_WRP_DocumentalResponse.HDT_WRP_IntesaResponse submitDiscardDocusignEnvelopeRequest(String body){
        HDT_WRP_DocumentalResponse.HDT_WRP_IntesaResponse responseWrap = new HDT_WRP_DocumentalResponse.HDT_WRP_IntesaResponse();
        try{
            HttpRequest req = new HttpRequest();
            req.setEndpoint('Callout:MulesoftBasePath/envelopes');
            req.setMethod('DELETE');
            req.setBody(body);
            req.setHeader('Content-Type','application/json');
            req.setTimeout(120000);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            if (responseBodyMap.containsKey('errorDetails')) {
                System.debug(LoggingLevel.DEBUG, 'submitDiscardDocusignEnvelopeRequest - errorDetails: ' + JSON.serialize(responseBodyMap.get('errorDetails')));
                List<Object> errors = (List<Object>) responseBodyMap.get('errorDetails');
                if (errors != null && !errors.isEmpty()) {
                    Map<String, Object> errorObj = (Map<String, Object>) errors[0];
                    String errorMessage = (String) errorObj.get('additionalInfo');
                    if (String.isNotBlank(errorMessage)){
                        throw new HDT_UTL_HeraException(errorMessage);
                    }
                }
            }

            responseWrap.responseCode = res.getStatusCode();
            responseWrap.responseStatus =  res.getStatus();
        }catch(Exception ex){
            System.debug(LoggingLevel.DEBUG, 'Errore WS ' + ex.getMessage() + ' at line ' + ex.getLineNumber());
            throw ex;
        }
        return responseWrap;
    }
}