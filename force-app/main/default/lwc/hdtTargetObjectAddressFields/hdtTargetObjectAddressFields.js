import { LightningElement, api, track } from 'lwc';
import objectToList from '@salesforce/apex/HDT_UTL_ServicePoint.objectToList';
import getInstanceWrapAddressObject from '@salesforce/apex/HDT_UTL_ServicePoint.getInstanceWrapAddressObject';

export default class hdtTargetObjectAddressFields extends LightningElement {
    @api objectapiname;
    @api fieldsAddressObject=[];
    @api wrapObjectInput= [];
    @api wrapAddressObject;
    @api fieldsDataReq;
    @api fieldsaddressobject;
    @api selectedservicepoint;
    @api servicePointRetrievedData;
    hasAddressBeenVerified = false;
    @track submitedAddressFields = {};
    verifyDisabledOnUpdate = true;

    @api
    toObjectAddressInit(data){

        let fieldsDataObject = [];
        console.log('');
        Object.keys(data).forEach(keys=> {
        
                fieldsDataObject.push(
                    {
                        fieldname: keys,
                        required : false,
                        value: '',
                        disabled: false
                    }
                ) 

        });

        return fieldsDataObject;
    }

    @api
    connectedCallback()
    {
        console.log('connectedCallback - selectedServicePoint**********'+ JSON.stringify(this.selectedservicepoint));

            getInstanceWrapAddressObject({s:this.selectedservicepoint}).then(data => {
                console.log('connectedCallback - getInstanceWrapAddressObject - on selectedservicepoint'+ JSON.stringify(data));
                this.wrapAddressObject = this.toObjectAddressInit(data);
                
                console.log('wrapAddressObject********************' + JSON.stringify(this.wrapAddressObject));
                //this.toObjectAddress();
                
            });
      
        console.log('hdtTargetObjectAddressFields - fieldAddressObject : '+ this.fieldsaddressobject);
    }

    @api
    getInstanceWrapObject(servicePointRetrievedData){
        console.log('getInstanceWrapObject - START');
        console.log('getInstanceWrapObject - servicePointRetrievedData' +JSON.stringify(servicePointRetrievedData));
        getInstanceWrapAddressObject({s:servicePointRetrievedData}).then(data => {
            
            console.log('getInstanceWrapObject - getInstanceWrapAddressObject Start '+ JSON.stringify(data));
            this.wrapAddressObject = this.toObjectAddressInit(data);
            console.log('getInstanceWrapObject - wrapAddressObject' + JSON.stringify(this.wrapAddressObject));
            //this.toObjectAddress();
            
        });
        console.log('getInstanceWrapObject - END');
    }

    /**
     * Get availability of verify address button
     */
    get verifyFieldsAddressDisabled(){
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
    }

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

       /* objectToList({wrap: wrapAddressObject}).then(data=>{
            for(let i = 0; i < data.length; i++){
                console.log('arrivo qui'+ data[i]);
               //inserting new key value pair inside map
               this.wrapObjectInput.set(data[i], obj[data[i]]);
            };
            console.log('hdtTargetObjectAddressFields - objectToMap END');
            return wrapObjectInput;
        }).catch(error=>{
            this.loading= false;
            console.log(error.body.message);
            const toastErrorMessage = new ShowToastEvent({
                title:'errore',
                message: '',
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });*/


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