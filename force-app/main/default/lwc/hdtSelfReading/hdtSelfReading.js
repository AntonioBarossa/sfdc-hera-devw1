import { LightningElement, track, api, wire } from 'lwc';
import insertSelfReading from '@salesforce/apex/HDT_LC_SelfReading.insertSelfReading';
import updateSelfReading from '@salesforce/apex/HDT_LC_SelfReading.updateSelfReading';
import getReadingId from '@salesforce/apex/HDT_LC_SelfReading.getReadingId';
import getRecordTypeId from '@salesforce/apex/HDT_LC_SelfReading.getRecordTypeId';
import checkLastReadings from '@salesforce/apex/HDT_LC_SelfReading.checkLastReadings';
import {FlowNavigationNextEvent, FlowNavigationFinishEvent,FlowNavigationBackEvent  } from 'lightning/flowSupport';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class HdtSelfReading extends LightningElement {

    @api commodity;

    @api recordId;

    @api object;

    @api servicePointId;

    @api isVolture;

    @api isRetroactive;

    @api availableActions = [];

    @api saveDraft;

    @api cancelCase;

    @api nextLabel;

    @api nextVariant;
    
    @api resumedFromDraft;

    @api showDraftButton;

    @api showBackButton;

    @api showCancelButton;

    @api readingCustomerDate;

    @api disabledReadingDate;

    @api isSaved = false;

    @api allowSmallerReading = false;

    @api oldTotalReadingValue;

    @api newTotalReadingValue;

    @api selectedReadingValue;

    @api selectedReadingsList;

    @api isRettificaConsumi;


    recordKey;

    selfReadingObj = [];

    rowObj = []

    outputObj = {};

    rowNumber;

    lastReading;

    buttonDisabled = false;

    advanceError = undefined;

    recordTypeId;

    errorAdvanceMessage = '';

    lastReadingsChecked = false;

    connectedCallback(){

        this.selectedReadingsList = JSON.parse(this.selectedReadingsList);
        this.oldTotalReadingValue = 0;
        this.newTotalReadingValue = 0;
        this.readingCustomerDate = this.sysdate();

        this.recordKey = this.object === 'Order' ? 
            (this.commodity === 'Energia Elettrica' ? 'OrderEle__c' : 'OrderGas__c') : 
            (this.commodity === 'Energia Elettrica' ? 'CaseEle__c' : 'CaseGas__c');

        this.rowNumber = this.commodity === 'Energia Elettrica' ? 9 : this.commodity === 'Gas' ? 2 : 0;

        if(this.commodity === 'Energia Elettrica'){

            console.log('loop energia elettrica')

            for(let i=1; i <= this.rowNumber; ++i){
                const headerText = i <= 3 ? 'Energia Attiva' : (i <= 6 ? 'Energia Reattiva' : 'Potenza');
                const headerIndex = i % 3 == 0 ? 3 : i % 3;  // L'indice è sempre 1, 2, o 3.

                this.rowObj = [...this.rowObj,{id:i, number: i, headerText: headerText, headerIndex: headerIndex}];
    
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
    
    @api
    handleClick(){

        this.buttonDisabled = true;
        this.lastReadingsChecked = true;

        checkLastReadings({servicePointId:this.servicePointId})
        .then(result =>{
            console.log('checkLastReadings results: ' + result);
            if (result == null) {
                this.errorAdvanceMessage = 'Errore di sistema, impossibile recuperare le ultime letture. Contattare un amministratore di sistema.';
                this.showToastMessage(this.errorAdvanceMessage);
                return;
            }
            const parsedResult = JSON.parse(result);
            // Verifichiamo se la response contiene un errore da SAP.
            if ("errorDetails" in parsedResult && "message" in parsedResult.errorDetails[0]) {
                this.errorAdvanceMessage = 'Errore da SAP: ' + parsedResult.errorDetails[0].message;
                this.showToastMessage(this.errorAdvanceMessage);
                return;
            }
            const lastReadings = this.fillLastReadingsArray(parsedResult);
            console.log('filled obj: ' + JSON.stringify( lastReadings));

            if(this.commodity == 'Energia Elettrica'){
                this.template.querySelectorAll('c-hdt-self-reading-register').forEach(element =>{
                    element.handleLastReading(lastReadings);
                    //element.handleLastReading('[{"register":"1", "readingType":"Multi Reg. Attiva", "readingDate":"2021-01-20", "readingBand":"F1","readingSerialNumber":"R00100000002956134", "readingOldValue":"1620"},{"register":"2", "readingType":"Multi Reg. Attiva", "readingDate":"2021-01-20", "readingBand":"F2","readingSerialNumber":"R00100000002956134", "readingOldValue":"1390"},{"register":"3", "readingType":"Multi Reg. Attiva", "readingDate":"2021-01-20", "readingBand":"F3","readingSerialNumber":"R00100000002956134", "readingOldValue":"1410"}]');
                });
            } else if(this.commodity == 'Gas'){
                this.template.querySelectorAll('c-hdt-self-reading-register').forEach(element =>{
                    element.handleLastReading(lastReadings);
                    //element.handleLastReading('[{"register":"Misuratore", "readingType":"Volumetrico","readingSerialNumber":"R00050030408819956","readingBand":"M1","readingRegister":"001","readingDate":"2021-02-11","readingOldValue":"3000","readingUnit":"M3"},{"register":"Correttore", "readingType":"Volumetrico","readingSerialNumber":"R00050030408819956","readingBand":"M1","readingRegister":"001","readingDate":"2021-02-11","readingOldValue":"3000","readingUnit":"M3"}]');
                });
            }

        }).catch(error =>{
            console.log('checkLastReadings failed: ' + error);
        });
    }

    fillLastReadingsArray(lastReadingsResponse){
        /*
        [{"register":"1", "readingType":"Multi Reg. Attiva", "readingDate":"2021-01-20", "readingBand":"F1","readingSerialNumber":"R00100000002956134", "readingOldValue":"1620"},{"register":"2", "readingType":"Multi Reg. Attiva", "readingDate":"2021-01-20", "readingBand":"F2","readingSerialNumber":"R00100000002956134", "readingOldValue":"1390"},{"register":"3", "readingType":"Multi Reg. Attiva", "readingDate":"2021-01-20", "readingBand":"F3","readingSerialNumber":"R00100000002956134", "readingOldValue":"1410"}]'
        */

        const lastReadings = lastReadingsResponse.data;

        let registers = [];
        let finalRegisters = []

        try {
            for (const key in lastReadings) {
                console.log('processing key: ' + key);
                const match = key.match(/\d+/);
                const index = match ? match[0] : -1;

                if (index < 0) {
                    continue;
                }

                const i = index - 1; // Indice effettivo, la response inizia da 1 anzichè da 0.
                if (registers[i] === undefined) {
                    registers[i] = {};
                }

                if (this.commodity === 'Energia Elettrica') {
                    registers[i].register = index;
                } else {
                    const gasIndex = index === '1' ? 'Misuratore' : 'Correttore';
                    registers[i].register = gasIndex;
                }

                console.log('index: ' + i);
                if (key.startsWith('herTipologiaMisuratore')) {
                    registers[i].readingType = lastReadings[key];
                } else if (key.startsWith('herMatricolaMisuratore')) {
                    registers[i].readingSerialNumber = lastReadings[key];
                } else if (key.startsWith('herDataLettura')) {
                    const readingDate = lastReadings[key];
                    // La response di SAP valorizza solo la data lettura a null se il registro non ha una lettura
                    // Skippiamo questa key in modo da marcare l'oggetto del registro come 'da rimuovere'
                    if (readingDate === null) {
                        continue;
                    }
                    registers[i].readingDate = this.convertItalianDate(readingDate);
                } else if (key.startsWith('herFascia')) {
                    registers[i].readingBand = lastReadings[key];
                } else if (key.startsWith('herLettura')) {
                    let reading = lastReadings[key];
                    reading = reading.split('.').join('');  // rimuoviamo il separatore delle migliaia per poter parsare come int.
                    registers[i].readingOldValue = reading;
                }
                // TODO: add missing fields
            }

            // Lasciamo solo i registri che hanno una lettura, ovvero quelli che hanno la property readingDate.
            registers.forEach(register => {
                if ('readingDate' in register) {
                    finalRegisters.push(register);
                }
            });

          } catch (error) {
            console.error(error);
          }

        return finalRegisters;
    }

    // event è definito solo per la voltura (this.isVolture) 
    @api
    handleSaveButton(){    

        console.log('Inside Reading Method');

        //console.log('handleSaveButton ' + event + ' is saved?' + this.isSaved);

        /*if(this.isVolture && event != undefined && event.target.name === 'previous'){

            let dispObj = {name: event.target.name};

            this.dispatchEvent(new CustomEvent('savereading', {detail: dispObj}));

            return;

        }*/


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

            try{
                const registers = this.template.querySelectorAll('c-hdt-self-reading-register');
                console.log('#registri: ' + registers.length);

                for (let i = 0; i < registers.length; i++) {
                let register = registers[i];

                let result = register.handleSave();

                if(String(result).includes("Impossibile")){
                    this.errorAdvanceMessage = result;
                    console.log('Error '+this.errorAdvanceMessage);
                    this.outputObj = {};
                    this.showToastMessage(this.errorAdvanceMessage);
                    throw BreakException;
                }

                console.log(result);

                this.oldTotalReadingValue += register.oldReadingValue();
                this.newTotalReadingValue += register.newReadingValue();
                console.log('lettura precedente a sistema: ' + this.oldTotalReadingValue)
                console.log('lettura comunicata dal cliente: ' + this.newTotalReadingValue)
                console.log('lettura selezionata da cruscotto letture: ' + this.selectedReadingValue);

                if (this.isRettificaConsumi === true) {
                    if ((this.selectedReadingValue === undefined && this.newTotalReadingValue > this.oldTotalReadingValue) ||
                        (this.selectedReadingValue > 0 && this.newTotalReadingValue > this.oldTotalReadingValue && 
                         this.newTotalReadingValue > this.selectedReadingValue)) {

                        console.log('Alert per verificare necessità di autolettura.');
                        this.errorAdvanceMessage = 'Verificare la lettura inserita. Se la lettura risulta corretta, è necessario annullare questo Case e proseguire con una Autolettura.';
                        this.showToastMessage(this.errorAdvanceMessage);
                        throw BreakException;
                    }
                }

                for(const [key,value] of Object.entries(result)){

                    this.outputObj[`${key}`] = value;

                }

                console.log('OutputObj '+this.outputObj);

            }

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

        if (this.resumedFromDraft === true) {
            console.log('Resumed from draft');

            getReadingId({
                objectName : this.object,
                objectId : this.recordId,
                commodity : this.commodity
            })
            .then(result => { 
                
                console.log('getReadingId result ' + result);
                if (result != null && result != undefined) {

                    this.outputObj['Id'] = result;

                    if (!this.isSaved) {
                        console.log('Update record oggetto Reading__c esistente: ' + this.outputObj['Id']);
                        updateSelfReading({fields : JSON.stringify(this.outputObj)})
                        .then(result => { 
                                       
                            this.isSaved = true;
                        
                        })
                        .catch(error => { console.log(error) });
                    }
                }
            })
            .catch(error => { console.log(error) });
        }

        //this.outputObj[`${commodity === 'Energia Elettrica' ? 'OrderElectricEnergy__c' : 'OrderGas__c'}`] = this.recordId

        console.log('stringify: ' + JSON.stringify(this.outputObj));

        if(!this.isSaved && !this.resumedFromDraft){

            console.log('Inserimento nuovo record oggetto Reading__c');
            insertSelfReading({fields : JSON.stringify(this.outputObj)})
            .then(result => { 
                
                this.isSaved = true;
            
            })
            .catch(error => { console.log(error) });

        } else {

            if(this.isVolture){            
                
                let errorVolture = 'Autolettura già inserita';

                this.showToastMessage(errorVolture);
            
            }

        }
    }

    handleNavigation(event){

        const action = event.detail;
        console.log('handleNavigation ' + action);

        if(action === 'next' || action === 'draft' || action === 'save'){

            this.saveDraft = action === 'draft'; 
            this.cancelCase = false;

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

    convertItalianDate(italianDate){
        var parts = italianDate.split("/");
        var date = new Date(parseInt(parts[2], 10),
                            parseInt(parts[1], 10) - 1,
                            parseInt(parts[0], 10));

        var dateIso = date.toISOString(); // Es: 2021-03-01T15:34:47.987Z
        return dateIso.substr(0, dateIso.indexOf('T'));
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