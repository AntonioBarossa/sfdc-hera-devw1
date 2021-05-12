import { LightningElement, api, wire } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationFinishEvent,FlowNavigationBackEvent  } from 'lightning/flowSupport';
import CALIBER_CLASS from '@salesforce/schema/Case.CaliberRequested__c'
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import getSystemCapacity from '@salesforce/apex/HDT_LC_SystemCapacityConversion.getSystemCapacity';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const conversionFactor = 860.421;

export default class HdtSystemCapacityConversion extends LightningElement {


    @api saveInDraft;
    @api cancelCase;
    @api outcomeCaliberClass;
    @api outcomeSystemCapacity;
    @api defaultCaliberClass;
    @api availableActions = [];

    caliberClassOptions = [];
    caliberClassValue;
    errorResult;
   

    systemCapacity;

    connectedCallback(){

        this.caliberClassValue = this.defaultCaliberClass;

        getSystemCapacity({field : "CaliberClass", value : this.caliberClassValue})
            .then(result => {

                if(result != null || result != undefined){

                    result = result.replace(",", ".");

                    console.log('Result: ' +result);

                    this.systemCapacity = parseFloat(result);

                    this.errorResult = undefined;

                }
            
            }).catch(error => {

                console.log('Error: ' +error);

                this.errorResult = error;

            });

        console.log('CaliberRequested: ' + this.caliberClassValue);

    }
    
    //Get Caliber Class values
    @wire(getPicklistValues,{recordTypeId: '012000000000000AAA', fieldApiName: CALIBER_CLASS})
    wiredPicklist({error,data}){
        if(data){

            data.values.forEach(element => {

                this.caliberClassOptions = [...this.caliberClassOptions,{value: element.label, label: element.label}];

                this.errorResult = undefined;

            });

        } else if(error){

            console.log(error);

            this.errorResult = error;

        }

    }

    get options(){

        return this.caliberClassOptions;

    }
    //Get Caliber Class values

    //Make logic to autofill inputfields
    handleChange(event){

        if(event.target.name === "CaliberClass"){

            this.caliberClassValue = event.target.value;

            console.log('CaliberRequestedOnchange: ' +this.caliberClassValue);

            getSystemCapacity({field : event.target.name, value : event.target.value})
            .then(result => {

                if(result != null || result != undefined){

                    result = result.replace(",", ".");

                    console.log('Result: ' +result);

                    this.systemCapacity = parseFloat(result);

                    this.errorResult = undefined;

                }
            
            }).catch(error => {

                console.log('Error: ' +error);

                this.errorResult = error;

            });

        } else {

            this.systemCapacity = event.target.value;

            console.log('SystemCapacityOnchange: ' +this.systemCapacity);

            getSystemCapacity({field : event.target.name, value : event.target.value})
            .then(result => {
                
                console.log('Result: ' +result);

                if(result != null || result != undefined){

                    this.caliberClassValue = result;

                    this.errorResult = undefined;

                }
            
            }).catch(error => {

                console.log('Error: ' +error);

                this.errorResult = error;

            });


        }




    }
    //Make logic to autofill inputfields


    //Advance the Flow
    handleClick(event){

        if(event.target.name === "save"){

            if(this.errorResult == undefined){

                if(this.availableActions.find(action => action === "NEXT")){

                    this.outcomeCaliberClass = this.caliberClassValue;

                    this.outcomeSystemCapacity = this.systemCapacity * conversionFactor;

                    this.saveInDraft = false;

                    this.cancelCase = false;

                    const navigateNextEvent = new FlowNavigationNextEvent();
        
                    this.dispatchEvent(navigateNextEvent);

                }

            } else {

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Errore',
                        message: 'Configurazione Classe Contatore - Portata (KWh) incorretta',
                        variant: 'error'
                    }),
                );

            }

        } else if(event.target.name === "draft"){

            if(this.errorResult == undefined){

                if(this.availableActions.find(action => action === "NEXT")){

                    this.outcomeCaliberClass = this.caliberClassValue;

                    this.outcomeSystemCapacity = this.systemCapacity * conversionFactor;

                    this.saveInDraft = true;

                    this.cancelCase = false;

                    const navigateNextEvent = new FlowNavigationNextEvent();
        
                    this.dispatchEvent(navigateNextEvent);

                }

            } else {

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Errore',
                        message: 'Configurazione Classe Contatore - Portata (KWh) incorretta',
                        variant: 'error'
                    }),
                );

            }

        } else if(event.target.name === "previous"){

            const navigateBackEvent = new FlowNavigationBackEvent();

            this.dispatchEvent(navigateBackEvent);

        } else if(event.target.name === "cancel"){

            if(this.availableActions.find(action => action === "NEXT")){

                this.cancelCase = true;

                const navigateNextEvent = new FlowNavigationNextEvent();
        
                this.dispatchEvent(navigateNextEvent);

            }
        }

    }

    //Advance the Flow



}