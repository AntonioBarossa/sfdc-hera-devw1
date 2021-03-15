import { LightningElement, track, api, wire } from 'lwc';
import updateSelfReading from '@salesforce/apex/HDT_LC_SelfReading.updateSelfReading';
import getRecordTypeId from '@salesforce/apex/HDT_LC_SelfReading.getRecordTypeId';
import {FlowNavigationNextEvent, FlowNavigationFinishEvent,FlowNavigationBackEvent  } from 'lightning/flowSupport';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class HdtSelfReading extends LightningElement {

    @api commodity;

    @api recordId;

    @api object;

    @api isVolture;

    @api isRetroactive;

    @api availableActions = [];

    @api saveDraft;

    @api cancelCase;

    @api nextLabel;

    @api nextVariant;
    
    @api isDraft;

    @api showBackButton;

    @api showCancelButton;

    @api readingCustomerDate;

    recordKey;

    selfReadingObj = [];

    rowObj = []

    outputObj = {};

    rowNumber;

    lastReading;

    buttonDisabled = false;

    advanceError = undefined;

    recordTypeId;

    isSaved = false;

    errorAdvanceMessage = '';

    lastReadingsChecked = false;

    connectedCallback(){

        this.readingCustomerDate = this.sysdate();

        this.recordKey = this.object === 'Order' ? 
            (this.commodity === 'Energia Elettrica' ? 'OrderEle__c' : 'OrderGas__c') : 
            (this.commodity === 'Energia Elettrica' ? 'CaseEle__c' : 'CaseGas__c');

        this.rowNumber = this.commodity === 'Energia Elettrica' ? 9 : this.commodity === 'Gas' ? 2 : 0;

        if(this.commodity === 'Energia Elettrica'){

            console.log('loop energia elettrica')

            for(let i=1; i <= this.rowNumber; ++i){
                const headerText = i <= 3 ? 'Energia Attiva' : (i <= 6 ? 'Energia Reattiva' : 'Potenza');
                const headerIndex = i % 3 == 0 ? 3 : i % 3;

                this.rowObj = [...this.rowObj,{id:i, number: i, headerText: headerText, headerIndex: headerIndex}]; // Modulo 4 per avere sempre indici 1/2/3
    
            }    

        } else if(this.commodity === 'Gas'){

            console.log('loop gas');

            this.rowObj = [...this.rowObj,{id:'Meter', number: "Misuratore", headerText: "Misuratore"},{id:'Corrector', number: "Correttore", headerText: "Correttore"}];


        }

        getRecordTypeId({commodity:this.commodity})
        .then(result =>{

            this.recordTypeId = result;

        }).catch(errror =>{

            console.log(error);

        });


    }


    handleDateChange(event){

        this.readingCustomerDate = event.target.value;

        console.log(event.target.value);

        var result = this.template.querySelector('c-hdt-self-reading-register').checkDate(event.target.value)

        console.log('Call result: '+result);

        if(result != undefined){

            event.target.setCustomValidity(result);

            this.advanceError = result;

        } else {

            this.advanceError = undefined;

            event.target.setCustomValidity("");

        }

        event.target.reportValidity();

        console.log('methodCalled');

        console.log('Check Error status '+this.advanceError);

    }
    
    handleClick(){

        this.buttonDisabled = true;

        if(this.commodity == 'Energia Elettrica'){

            this.template.querySelectorAll('c-hdt-self-reading-register').forEach(element =>{

                element.handleLastReading('[{"register":"1", "readingType":"Multi Reg. Attiva", "readingDate":"2021-01-20", "readingBand":"F1","readingSerialNumber":"R00100000002956134", "readingOldValue":"1620"},{"register":"2", "readingType":"Multi Reg. Attiva", "readingDate":"2021-01-20", "readingBand":"F2","readingSerialNumber":"R00100000002956134", "readingOldValue":"1390"},{"register":"3", "readingType":"Multi Reg. Attiva", "readingDate":"2021-01-20", "readingBand":"F3","readingSerialNumber":"R00100000002956134", "readingOldValue":"1410"}]');

            });

        } else if(this.commodity == 'Gas'){

            this.template.querySelectorAll('c-hdt-self-reading-register').forEach(element =>{

                element.handleLastReading('[{"register":"Misuratore", "readingType":"Volumetrico","readingSerialNumber":"R00050030408819956","readingBand":"M1","readingRegister":"001","readingDate":"2021-02-11","readingOldValue":"3000","readingUnit":"M3"}]');

            });

        }

        this.lastReadingsChecked = true;

    }

    // event è definito solo per la voltura (this.isVolture) 
    handleSaveButton(event){    

        console.log('handleSaveButton ' + event + ' is saved?' + this.isSaved);

        if(this.isVolture && event != undefined && event.target.name === 'previous'){

            let dispObj = {name: event.target.name};

            this.dispatchEvent(new CustomEvent('savereading', {detail: dispObj}));

            return;

        }


        if(this.advanceError != undefined){

            console.log(this.errorAdvanceMessage);

            return;

        } else if(this.readingCustomerDate == null || this.readingCustomerDate == undefined){

            this.errorAdvanceMessage = 'Impossibile procedere: Valorizzare Data Lettura Cliente';

            this.showToastMessage(this.errorAdvanceMessage);

            console.log(this.errorAdvanceMessage);

            throw BreakException;

        } else if(!this.isVolture && !this.lastReadingsChecked){
            this.errorAdvanceMessage = 'Premere il pulsante Verifica Ultima Lettura ed inserire le letture del cliente.';

            this.showToastMessage(this.errorAdvanceMessage);

            console.log(this.errorAdvanceMessage);

            throw BreakException;
        } else {

            try{this.template.querySelectorAll('c-hdt-self-reading-register').forEach(element =>{

                var result = element.handleSave();

                if(String(result).includes("Impossibile")){

                    this.errorAdvanceMessage = result;

                    console.log('Error '+this.errorAdvanceMessage);

                    this.outputObj = {};

                    this.showToastMessage(this.errorAdvanceMessage);

                    throw BreakException;

                }

                console.log(result);

                for(const [key,value] of Object.entries(result)){

                    this.outputObj[`${key}`] = value;

                }

                console.log('OutputObj '+this.outputObj);

            });

        } catch (e) { 

            if (e !== BreakException){

                console.log('exception: ' + e);
                this.outputObj = {};

                throw e;

            } ;

            }
        }

        this.outputObj['ReadingDate__c'] = this.readingCustomerDate;

        this.outputObj[`${this.recordKey}`] = this.recordId;

        this.outputObj['Name'] = 'Lettura ' + this.currentDateTime();

        this.outputObj['RecordTypeId'] = this.recordTypeId;

        //this.outputObj[`${commodity === 'Energia Elettrica' ? 'OrderElectricEnergy__c' : 'OrderGas__c'}`] = this.recordId

        console.log('stringify: ' + JSON.stringify(this.outputObj));

        if(!this.isSaved){

            updateSelfReading({fields : JSON.stringify(this.outputObj), 
                readingCustomerDate:String(this.readingCustomerDate),
                commodity:this.commodity})
            .then(result => { 
                
                console.log(result) 

                if (this.isVolture) {
                    let dispObj = {name: event.target.name, readingDate: this.readingCustomerDate};

                    console.log('Event Name '+dispObj.name);

                    this.dispatchEvent(new CustomEvent('savereading', {detail: dispObj}));
                }

                this.isSaved = true;
            
            })
            .catch(error => { console.log(error) });

        } else {

            if (this.isVolture) {
                let dispObj = {name: event.target.name, readingDate: this.readingCustomerDate};

                this.dispatchEvent(new CustomEvent('savereading', {detail: dispObj}));
            }
        }
    }

    handleNavigation(event){

        const action = event.detail;
        console.log('handleNavigation ' + action);

        if(action === 'next' || action === 'draft' || action === 'save'){

            this.saveDraft = action === 'draft'; 

            if(this.availableActions.find(action => action === 'NEXT')){

                try {
                    this.handleSaveButton();
                } catch (e) {
                    console.log('handleNavigation catch' + e);
                    this.showToastMessage(this.errorAdvanceMessage);
                    this.errorAdvanceMessage = '';
                    return;
                }

                const navigateNextEvent = new FlowNavigationNextEvent();
    
                this.dispatchEvent(navigateNextEvent);
    
            } else {

                try {
                    this.handleSaveButton();
                } catch (e) {
                    console.log('handleNavigation catch' + e);
                    this.showToastMessage(this.errorAdvanceMessage);
                    this.errorAdvanceMessage = '';
                    return;
                }

                const navigateFinish = new FlowNavigationFinishEvent();
    
                this.dispatchEvent(navigateFinish);
            }

        } else if(action === 'previous'){

            const navigateBackEvent = new FlowNavigationBackEvent();

            this.dispatchEvent(navigateBackEvent);
    
        } else if(action === 'cancel'){

            this.cancelCase = true;

            if(this.availableActions.find(action => action === 'NEXT')){

                const navigateNextEvent = new FlowNavigationNextEvent();
    
                this.dispatchEvent(navigateNextEvent);
    
            } else {
    
                const navigateFinish = new FlowNavigationFinishEvent();
    
                this.dispatchEvent(navigateFinish);
            }

        }

    }

    showToastMessage(errorMessage){

        const toastErrorMessage = new ShowToastEvent({
            title: 'Errore',
            message: errorMessage,
            variant: 'error',
        });
        this.dispatchEvent(toastErrorMessage);


    }

    // Genera la sysdate in formato DD/MM/YYYY HH:MM
    currentDateTime(){
        const today = new Date();
        const dateOptions = { day: '2-digit', month: '2-digit', year: 'numeric' };
        const timeOptions = { hour12: false, hour: '2-digit', minute:'2-digit' };

        // Usiamo en-GB per forzare il formato con gli slash (DD/MM/YYYY)
        return today.toLocaleString('en-GB', dateOptions) + ' ' + today.toLocaleTimeString('en-GB', timeOptions);
    }

    sysdate(){
        var sysdateIso = new Date().toISOString(); // Es: 2021-03-01T15:34:47.987Z
        return sysdateIso.substr(0, sysdateIso.indexOf('T'));
    }


    reverseDate(inputDate){

        var date = new Date(inputDate);

        var dd = String(date.getDate()).padStart(2, '0');
        var mm = String(date.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = date.getFullYear();

        date = dd + '/' + mm + '/' + yyyy;

        return date;


    }




}