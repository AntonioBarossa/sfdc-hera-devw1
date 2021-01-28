import { LightningElement, api, track } from 'lwc';

import getServicePointToContract from '@salesforce/apex/HDT_UTL_ServicePoint.getServicePointToContract';
import getInstanceWrapAddressObject from '@salesforce/apex/HDT_UTL_ServicePoint.getInstanceWrapAddressObject';

export default class hdtTargetObjectAddressFields extends LightningElement {
    @api objectapiname;
    @api fieldsAddressObject=[];
    @api wrapObjectInput= [];
    @api wrapAddressObject;
    @api fieldsDataReq;
    @api selectedservicepoint;
    @api servicePointRetrievedData ;
    hasAddressBeenVerified = false;
    @track submitedAddressFields = {};
    verifyDisabledOnUpdate = true;
    verifyFieldsAddressDisabled= true;
    @api recordtype;
    @api checkBoxFieldValue;
    @api textFieldValue;
    @api theRecord = {};
    @api stato;
    @api provincia;
    @api comune;
    @api cap;
    @api via;
    @api civico;
    @api estensCivico;
    @api codComuneSAP;
    @api codStradarioSAP;
    @api flagForzato ;
    @api flagVerifiacto ;

@api
handleAddressValues(servicePointRetrievedData){
    console.log('handleAddressValues START - servicePointRetrievedData :' + JSON.stringify(servicePointRetrievedData));
    Object.keys(servicePointRetrievedData).forEach(key=>{
        switch(key){
            case 'Stato':
                this.stato = servicePointRetrievedData[key] ;
            break;
            case 'Provincia':
                this.provincia= servicePointRetrievedData[key] ;
            break;
            case 'Comune':
                this.comune= servicePointRetrievedData[key] ;
            break;
            case 'CAP':
                this.cap = servicePointRetrievedData[key] ;
            break;
            case 'Via':
                this.via = servicePointRetrievedData[key] ;
            break;
            case 'Civico':
                console.log('servicePointRetrievedData[key] *************************************'+JSON.stringify(servicePointRetrievedData[key]));
                this.civico = servicePointRetrievedData[key] ;
            break;
            case 'EstensCivico':
                console.log('servicePointRetrievedData[key] *************************************'+JSON.stringify(servicePointRetrievedData[key]));
                this.estensCivico = servicePointRetrievedData[key] ;
            break;
            case 'CodiceComuneSAP':
                console.log('servicePointRetrievedData[key] *************************************'+JSON.stringify(servicePointRetrievedData[key]));
                this.codComuneSAP = servicePointRetrievedData[key] ;
            break;
            case 'CodiceViaStradarioSAP':
                console.log('servicePointRetrievedData[key] *************************************'+JSON.stringify(servicePointRetrievedData[key]));
                this.codStradarioSAP = servicePointRetrievedData[key] ;
            break;
            /*case 'FlagForzato':
                this.flagForzato = servicePointRetrievedData[key] ;
            break;*/
            case 'FlagVerificato':
                console.log('servicePointRetrievedData[key] *************************************'+JSON.stringify(servicePointRetrievedData[key]));

                this.flagVerifiacto = servicePointRetrievedData[key] ;
            break;
        }

    });
    console.log('handleAddressValues END ');
}


@api
handleCheckBoxChange(event){
    console.log('event detail : ******++'+ JSON.stringify(event.target.name));
    
        this.checkBoxFieldValue = event.target.checked;
        this.theRecord[event.target.name] = event.target.checked;
        console.log(event.target.name + ' now is set to ' + event.target.checked); 
        switch(event.target.name){
            case 'Flag Forzato':
                this.flagForzato = event.target.checked;
                console.log(JSON.stringify(this.flagForzato));
                break;
            case 'Flag Verificato':
                this.flagVerifiacto =  event.target.checked;
        }


        
        console.log('theRecord *********'+ JSON.stringify(this.theRecord));
}
@api
handleTextChange(event){
    console.log('event detail : ******++'+ JSON.stringify(event.target.value));
        this.textFieldValue = event.target.value;
        this.theRecord[event.target.name] = event.target.value;
        console.log(event.target.name + ' now is set to ' + event.target.value);
        console.log('theRecord *********'+ JSON.stringify(this.theRecord));
        switch(event.target.name){
            case 'Civico':
                this.civico = event.target.value;
                break;
            case 'Comune':
                this.comune =  event.target.value;
            case 'Stato':
                this.stato = event.target.value;
                break;
            case 'Provincia':
                this.provincia = event.target.value;
                break;
            case 'Via':
                this.via= event.target.value;
                break;
            case 'CAP':
                this.cap= event.target.value;
                break;
            case 'Estens.Civico':
                this.estensCivico = event.target.value;
                console.log('estensione civico'+ JSON.stringify(event.target.value));
                break;
            case 'Codice Comune SAP':
                this.codComuneSAP = event.target.value;
                console.log('codComSAP'+ JSON.stringify(this.estensCivico));
                break;
            case 'Codice Via Stradario SAP':
                this.codStradarioSAP = event.target.value;
                console.log('codStradario'+ JSON.stringify(this.estensCivico));
                break;
        }
        this.wrapAddressObject = this.toObjectAddressInit(this.theRecord);
        console.log('wrapAddressObject -handleTextChange ********************'+ JSON.stringify(this.wrapAddressObject));

}

@api
    handleAddressFields(){
        console.log('saveAddressField - wrapAddressObject START '+ JSON.stringify(this.theRecord));
        return this.theRecord;

    }

@api
disabledverifyFieldsAddressDisabled(){
    this.verifyFieldsAddressDisabled= false;
}

@api
    toObjectAddressInit(data){

        let fieldsDataObject = [];
        
        Object.keys(data).forEach(keys=> {
        

                fieldsDataObject.push(
                    {
                        fieldname: keys,
                        required : false,

                        value: data[keys],

                        disabled: false
                    }
                ) 

        });

        return fieldsDataObject;
    }


@api
    connectedCallback()
    {
       /* let bool = false;
        console.log('connectedCallback - selectedServicePoint**********'+ JSON.stringify(this.selectedservicepoint));
        for (var key in this.selectedservicepoint) {
            console.log('key ***********'+ JSON.stringify(key))
            if (key === 'Service Point'){
                console.log('key ********'+ JSON.stringify(this.selectedservicepoint[key]))
                getServicePointToContract({s:this.selectedservicepoint[key]}).then(data=>{
                    this.wrapAddressObject = this.toObjectAddressInit(data);
                    console.log('wrapAddressObject on getServicePointToContract' + JSON.stringify(this.wrapAddressObject));
                });
                bool=true;
                console.log('Service Point check *********');
                break;
            }
 
        }
        if(bool == false){
            getInstanceWrapAddressObject({s:this.selectedservicepoint}).then(data => {
                console.log('connectedCallback - getInstanceWrapAddressObject - on selectedservicepoint'+ JSON.stringify(data));
                this.wrapAddressObject = this.toObjectAddressInit(data);

                console.log('wrapAddressObject********************' + JSON.stringify(this.wrapAddressObject));
                //this.toObjectAddress();
                
            });
        }*/
        
        console.log('hdtTargetObjectAddressFields - fieldAddressObject : '+ JSON.stringify(this.fieldsaddressobject));
    }


@api

    getInstanceWrapObject(servicePointRetrievedData){
        console.log('getInstanceWrapObject - START');
        console.log('getInstanceWrapObject - servicePointRetrievedData' +JSON.stringify(servicePointRetrievedData));
        getInstanceWrapAddressObject({s:servicePointRetrievedData}).then(data => {

            this.handleAddressValues(data);
            console.log('getInstanceWrapObject - getInstanceWrapAddressObject Start '+ JSON.stringify(data));
            //this.wrapAddressObject = this.toObjectAddressInit(data);
            

            console.log('getInstanceWrapObject - wrapAddressObject' + JSON.stringify(this.wrapAddressObject));
            //this.toObjectAddress();
            
        });

        
        console.log('getInstanceWrapObject - END');
    }
    /**
     * Get availability of verify address button
     */
    
    /*get verifyFieldsAddressDisabled(){
        console.log('verifyFieldsAddressDisabled - START ' + JSON.stringify(this.wrapAddressObject));
        let result = true;       
        


        if(
            (
                (this.submitedAddressFields.SupplyCountry__c != undefined
                && this.submitedAddressFields.SupplyCity__c != undefined
                && this.submitedAddressFields.SupplyPostalCode__c != undefined)
                &&
                (this.submitedAddressFields.SupplyCountry__c != ''
                && this.submitedAddressFields.SupplyCity__c != ''
                && this.submitedAddressFields.SupplyPostalCode__c != '')
            )
            || !this.verifyDisabledOnUpdate
        ){
            result = false;
        }
        
        return result;

    }*/
@api
    stampWrapObject(){
        console.log('wrapAddressObject in StampWrapAddressObject*******************'+ this.wrapAddressObject);
    }


  @api  
     objectToMap(wrapAddressObject) {
        console.log('hdtTargetObjectAddressFields - objectToMap START');  
        let wrapObjectInput=[];
        console.log('arrivo qui');

        const ObjArray = Object.getOwnPropertyNames(wrapAddressObject);
        console.log('arrivo qui1');
        for(let i = 0; i < ObjArray.length; i++){
            console.log('entra nel for'+ ObjArray[i]);
           //inserting new key value pair inside map
           this.wrapObjectInput.set(ObjArray[i], obj[ObjArray[i]]);
        };
        console.log('hdtTargetObjectAddressFields - objectToMap END');
        return wrapObjectInput;

    }

    @api
     toObjectAddress(){
        console.log('hdtTargetObjectAddressFields - toObjectAddress START');
        this.fieldsAddressObject= this.wrapAddressObject;
        /*let fieldMap = this.objectToMap(this.wrapAddressObject);
        console.log(''+fieldMap.keys);
        fieldMap.forEach(element => {

                this.fieldsAddressObject.push(
                    {
                        fieldname: element,
                        required : false,
                        value: '',
                        disabled:  false
                    }
                ) 
        });*/
        console.log('hdtTargetObjectAddressFields - toObjectAddress END');


 }



    /**
     * Get address fields values
     * @param {*} event 
     */
    handleFieldsDataChange(event){

        this.disabledverifyFieldsAddressDisabled()
        console.log('hdtTargetObjectAddressFields - handleFieldsDataChange Start');

        this.submitedAddressFields[event.target.fieldName] = event.target.value;
        
        let evt = new CustomEvent("getaddressfields", {
            detail: this.submitedAddressFields
          });

        this.dispatchEvent(evt);

        if(this.selectedservicepoint != undefined){
            this.verifyDisabledOnUpdate = false;
            this.dispatchEvent(new CustomEvent("verifyaddressonupdate", {
                detail: this.verifyDisabledOnUpdate
              }));
        }

        this.hasAddressBeenVerified = false;
        this.dispatchEvent(new CustomEvent("addressverification", {
            detail: this.hasAddressBeenVerified
          }));

    }

    /**
     * Show errors for address fields
     * @param {*} fieldsWithError 
     */
    @api
    checkInvalidFields(fieldsWithError){
        for(var i=0; i<fieldsWithError.length; i++){
            
            let dataName = "[data-name='"+fieldsWithError[i]+"']";
            let dataField = this.template.querySelector(dataName);
            dataField.reportValidity();
        }
    }

    /**
     * Verify address
     */
    handleAddressVerification(){
        
        this.hasAddressBeenVerified = true;
        
        this.dispatchEvent(new CustomEvent("addressverification", {
            detail: this.hasAddressBeenVerified
          }));
    }


}

